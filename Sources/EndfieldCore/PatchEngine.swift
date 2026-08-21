import Foundation

public struct PatchEngine: Sendable {
    public init() {}

    public func preparePrivateRuntime(
        stockRuntime: URL,
        destination: URL,
        profile: PatchProfile,
        greenButtonHook: URL? = nil,
        progress: @Sendable (String) -> Void = { _ in }
    ) throws {
        let fm = FileManager.default
        let parent = destination.deletingLastPathComponent()
        try fm.createDirectory(at: parent, withIntermediateDirectories: true)

        let staging = parent.appendingPathComponent(
            "CrossOver.staging-\(UUID().uuidString)",
            isDirectory: true
        )

        progress("Copying the Endfield compatibility runtime")
        try ProcessRunner.requireSuccess(
            URL(fileURLWithPath: "/usr/bin/ditto"),
            [stockRuntime.path, staging.path],
            userMessage: "The private Endfield runtime could not be copied."
        )

        do {
            progress("Applying the Endfield compatibility profile")
            try apply(profile: profile, toPrivateRoot: staging)

            progress("Verifying the finished compatibility files")
            try verifyTargets(profile: profile, privateRoot: staging)

            let ntdll = staging.appendingPathComponent(
                "lib/wine/x86_64-unix/ntdll.so"
            )
            if fm.fileExists(atPath: ntdll.path) {
                _ = try ProcessRunner.requireSuccess(
                    URL(fileURLWithPath: "/usr/bin/codesign"),
                    ["--force", "--sign", "-", ntdll.path],
                    userMessage: "macOS could not sign the private Endfield compatibility module."
                )
            }

            if let greenButtonHook {
                try GreenButtonInstaller().install(
                    bundledHook: greenButtonHook,
                    privateRoot: staging,
                    progress: progress
                )
            }

            let old = parent.appendingPathComponent(
                "CrossOver.previous-\(UUID().uuidString)",
                isDirectory: true
            )

            if fm.fileExists(atPath: destination.path) {
                try fm.moveItem(at: destination, to: old)
            }

            do {
                try fm.moveItem(at: staging, to: destination)
                if fm.fileExists(atPath: old.path) {
                    try? fm.removeItem(at: old)
                }
            } catch {
                if fm.fileExists(atPath: old.path),
                   !fm.fileExists(atPath: destination.path) {
                    try? fm.moveItem(at: old, to: destination)
                }
                throw error
            }
        } catch {
            try? fm.removeItem(at: staging)
            throw error
        }
    }

    public func apply(
        profile: PatchProfile,
        toPrivateRoot privateRoot: URL
    ) throws {
        let wineRoot = privateRoot.appendingPathComponent(
            "lib/wine",
            isDirectory: true
        )

        for module in profile.modules {
            try rejectUnsafe(relativePath: module.relativePath)
            let file = wineRoot.appendingPathComponent(module.relativePath)

            var data = try Data(contentsOf: file)

            guard data.count == module.sourceSize,
                  SHA256File.hex(data: data) ==
                    module.sourceSHA256.lowercased() else {
                throw EndfieldError.sourceMismatch(module.relativePath)
            }

            for chunk in module.chunks.sorted(by: { $0.offset > $1.offset }) {
                guard
                    let replacement = Data(
                        base64Encoded: chunk.replacementBase64
                    ),
                    chunk.offset <= data.count,
                    chunk.offset + chunk.removeCount <= data.count
                else {
                    throw EndfieldError.invalidProfile(
                        "patch range is outside \(module.relativePath)"
                    )
                }

                data.replaceSubrange(
                    chunk.offset..<(chunk.offset + chunk.removeCount),
                    with: replacement
                )
            }

            guard data.count == module.targetSize,
                  SHA256File.hex(data: data) ==
                    module.targetSHA256.lowercased() else {
                throw EndfieldError.targetMismatch(module.relativePath)
            }

            let temp = file.deletingLastPathComponent()
                .appendingPathComponent(
                    ".\(file.lastPathComponent).endfield-\(UUID().uuidString)"
                )
            try data.write(to: temp, options: [.atomic])
            _ = try FileManager.default.replaceItemAt(
                file,
                withItemAt: temp
            )
        }
    }

    public func verifyTargets(
        profile: PatchProfile,
        privateRoot: URL
    ) throws {
        let wineRoot = privateRoot.appendingPathComponent(
            "lib/wine",
            isDirectory: true
        )

        for module in profile.modules {
            let file = wineRoot.appendingPathComponent(module.relativePath)
            guard FileManager.default.fileExists(atPath: file.path),
                  try SHA256File.hex(url: file) ==
                    module.targetSHA256.lowercased() else {
                throw EndfieldError.targetMismatch(module.relativePath)
            }
        }
    }

    private func rejectUnsafe(relativePath: String) throws {
        let p = relativePath.replacingOccurrences(of: "\\", with: "/")
        guard
            !p.hasPrefix("/"),
            !p.contains("../"),
            !p.contains("/.."),
            !p.contains(":")
        else {
            throw EndfieldError.unsafePath(relativePath)
        }
    }
}
