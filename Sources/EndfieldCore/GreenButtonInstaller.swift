import Foundation

public struct GreenButtonInstaller: Sendable {
    public static let expectedWinemacSHA256 =
        "6b88de59d3c32ccd43b6a0a54097b8da0cf225eef9ccf0598be142ce95a5d43d"

    public static let dependency =
        "@loader_path/EndfieldGreenButton.dylib"

    public init() {}

    public func install(
        bundledHook: URL,
        privateRoot: URL,
        progress: @Sendable (String) -> Void = { _ in }
    ) throws {
        let fm = FileManager.default
        let root = privateRoot.standardizedFileURL
        let wineDir = root.appendingPathComponent(
            "lib/wine/x86_64-unix",
            isDirectory: true
        )
        let driver = wineDir.appendingPathComponent("winemac.so")
        let installedHook = wineDir.appendingPathComponent(
            "EndfieldGreenButton.dylib"
        )

        guard
            driver.standardizedFileURL.path.hasPrefix(root.path + "/"),
            installedHook.standardizedFileURL.path.hasPrefix(root.path + "/")
        else {
            throw EndfieldError.unsafePath(driver.path)
        }

        guard fm.fileExists(atPath: driver.path) else {
            throw EndfieldError.fileOperation(
                "The private Endfield window driver is missing. Use Repair to rebuild the setup."
            )
        }

        guard fm.fileExists(atPath: bundledHook.path) else {
            throw EndfieldError.fileOperation(
                "This copy of Endfield for CrossOver is missing its fullscreen helper. Download it again."
            )
        }

        progress("Enabling the macOS fullscreen button")

        var data = try Data(contentsOf: driver)
        let alreadyPatched = try MachOLoadCommandEditor.hasLoadDylib(
            data,
            name: Self.dependency
        )

        if !alreadyPatched {
            guard SHA256File.hex(data: data) == Self.expectedWinemacSHA256 else {
                throw EndfieldError.sourceMismatch(
                    "x86_64-unix/winemac.so"
                )
            }

            data = try MachOLoadCommandEditor.addingLoadDylib(
                data,
                name: Self.dependency
            )

            let attrs = try fm.attributesOfItem(atPath: driver.path)
            let temp = wineDir.appendingPathComponent(
                ".winemac.so.green-\(UUID().uuidString)"
            )

            try data.write(to: temp, options: [.atomic])

            if let perms = attrs[.posixPermissions] {
                try fm.setAttributes(
                    [.posixPermissions: perms],
                    ofItemAtPath: temp.path
                )
            }

            _ = try fm.replaceItemAt(driver, withItemAt: temp)
        }

        if fm.fileExists(atPath: installedHook.path) {
            try fm.removeItem(at: installedHook)
        }
        try fm.copyItem(at: bundledHook, to: installedHook)
        try fm.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: installedHook.path
        )

        _ = try ProcessRunner.requireSuccess(
            URL(fileURLWithPath: "/usr/bin/codesign"),
            ["--verify", "--strict", installedHook.path],
            userMessage: "macOS could not verify the Endfield fullscreen helper."
        )

        _ = try ProcessRunner.requireSuccess(
            URL(fileURLWithPath: "/usr/bin/codesign"),
            ["--force", "--sign", "-", driver.path],
            userMessage: "macOS could not sign the private Endfield window driver."
        )

        let finished = try Data(contentsOf: driver)
        guard try MachOLoadCommandEditor.hasLoadDylib(
            finished,
            name: Self.dependency
        ) else {
            throw EndfieldError.targetMismatch("x86_64-unix/winemac.so")
        }

        guard
            try SHA256File.hex(url: bundledHook) ==
            SHA256File.hex(url: installedHook)
        else {
            throw EndfieldError.targetMismatch("EndfieldGreenButton.dylib")
        }
    }
}

enum MachOLoadCommandEditor {
    private static let magic64: UInt32 = 0xfeedfacf
    private static let segment64: UInt32 = 0x19
    private static let loadDylib: UInt32 = 0x0c
    private static let headerSize = 32
    private static let segmentCommandSize = 72
    private static let sectionSize = 80

    static func hasLoadDylib(_ data: Data, name: String) throws -> Bool {
        let header = try readHeader(data)
        var offset = headerSize

        for _ in 0..<header.ncmds {
            let command = try read32(data, offset)
            let size = Int(try read32(data, offset + 4))

            guard size >= 8, offset + size <= data.count else {
                throw EndfieldError.fileOperation(
                    "The private Endfield window driver has an invalid Mach-O command."
                )
            }

            if command == loadDylib {
                let nameOffset = Int(try read32(data, offset + 8))
                guard nameOffset >= 24, nameOffset < size else {
                    throw EndfieldError.fileOperation(
                        "The private Endfield window driver has an invalid dylib command."
                    )
                }

                let start = offset + nameOffset
                let limit = offset + size
                var end = start
                while end < limit && data[end] != 0 { end += 1 }

                if String(data: data[start..<end], encoding: .utf8) == name {
                    return true
                }
            }

            offset += size
        }
        return false
    }

    static func addingLoadDylib(_ data: Data, name: String) throws -> Data {
        if try hasLoadDylib(data, name: name) { return data }

        let header = try readHeader(data)
        let firstSection = try firstSectionOffset(data, header.ncmds)
        let nameBytes = Array(name.utf8) + [0]
        let commandSize = (24 + nameBytes.count + 7) & ~7
        let oldEnd = headerSize + Int(header.sizeofcmds)
        let newEnd = oldEnd + commandSize

        guard newEnd <= firstSection, newEnd <= data.count else {
            throw EndfieldError.fileOperation(
                "The supported Endfield window driver does not have enough safe header space for fullscreen support."
            )
        }

        guard data[oldEnd..<newEnd].allSatisfy({ $0 == 0 }) else {
            throw EndfieldError.fileOperation(
                "The patcher refused to overwrite non-empty Mach-O header data."
            )
        }

        var result = data
        write32(loadDylib, &result, oldEnd)
        write32(UInt32(commandSize), &result, oldEnd + 4)
        write32(24, &result, oldEnd + 8)
        write32(0, &result, oldEnd + 12)
        write32(0x00010000, &result, oldEnd + 16)
        write32(0x00010000, &result, oldEnd + 20)

        result.replaceSubrange(
            (oldEnd + 24)..<(oldEnd + 24 + nameBytes.count),
            with: nameBytes
        )

        write32(header.ncmds + 1, &result, 16)
        write32(header.sizeofcmds + UInt32(commandSize), &result, 20)

        guard try hasLoadDylib(result, name: name) else {
            throw EndfieldError.targetMismatch("x86_64-unix/winemac.so")
        }

        return result
    }

    private static func readHeader(
        _ data: Data
    ) throws -> (ncmds: UInt32, sizeofcmds: UInt32) {
        guard data.count >= headerSize, try read32(data, 0) == magic64 else {
            throw EndfieldError.fileOperation(
                "The private Endfield window driver is not the expected x86_64 Mach-O file."
            )
        }
        return (try read32(data, 16), try read32(data, 20))
    }

    private static func firstSectionOffset(
        _ data: Data,
        _ ncmds: UInt32
    ) throws -> Int {
        var offset = headerSize
        var first = data.count

        for _ in 0..<ncmds {
            let command = try read32(data, offset)
            let size = Int(try read32(data, offset + 4))
            guard size >= 8, offset + size <= data.count else {
                throw EndfieldError.fileOperation(
                    "The private Endfield window driver has an invalid Mach-O command."
                )
            }

            if command == segment64 {
                guard size >= segmentCommandSize else {
                    throw EndfieldError.fileOperation(
                        "The private Endfield window driver has an invalid segment."
                    )
                }

                let count = Int(try read32(data, offset + 64))
                let start = offset + segmentCommandSize
                guard start + count * sectionSize <= offset + size else {
                    throw EndfieldError.fileOperation(
                        "The private Endfield window driver has an invalid section table."
                    )
                }

                for index in 0..<count {
                    let section = start + index * sectionSize
                    let fileOffset = Int(try read32(data, section + 48))
                    if fileOffset > 0 { first = min(first, fileOffset) }
                }
            }

            offset += size
        }
        return first
    }

    private static func read32(_ data: Data, _ offset: Int) throws -> UInt32 {
        guard offset >= 0, offset + 4 <= data.count else {
            throw EndfieldError.fileOperation(
                "The private Endfield window driver ended unexpectedly."
            )
        }
        return UInt32(data[offset])
            | (UInt32(data[offset + 1]) << 8)
            | (UInt32(data[offset + 2]) << 16)
            | (UInt32(data[offset + 3]) << 24)
    }

    private static func write32(
        _ value: UInt32,
        _ data: inout Data,
        _ offset: Int
    ) {
        data[offset] = UInt8(value & 0xff)
        data[offset + 1] = UInt8((value >> 8) & 0xff)
        data[offset + 2] = UInt8((value >> 16) & 0xff)
        data[offset + 3] = UInt8((value >> 24) & 0xff)
    }
}
