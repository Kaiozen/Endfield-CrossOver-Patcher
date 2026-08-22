import Foundation

public struct ProfileLoader: Sendable {
    public init() {}

    public func load(url: URL) throws -> PatchProfile {
        let profile = try JSONDecoder().decode(
            PatchProfile.self,
            from: Data(contentsOf: url)
        )
        try validate(profile)
        return profile
    }

    public func validate(_ profile: PatchProfile) throws {
        guard profile.format == 1 else {
            throw EndfieldError.invalidProfile(
                "unsupported format \(profile.format)"
            )
        }

        let allowed = Set([
            "x86_64-unix/ntdll.so",
            "x86_64-windows/ntdll.dll",
            "x86_64-windows/kernel32.dll",
            "x86_64-windows/ntoskrnl.exe",
        ])

        let paths = profile.modules.map(\.relativePath)
        guard Set(paths).isSubset(of: allowed), Set(paths).count == paths.count else {
            throw EndfieldError.invalidProfile(
                "unexpected or duplicate module path"
            )
        }
        guard !paths.isEmpty else {
            throw EndfieldError.invalidProfile(
                "profile contains no compatibility modules"
            )
        }

        for module in profile.modules {
            guard module.sourceSize >= 0, module.targetSize >= 0 else {
                throw EndfieldError.invalidProfile("negative module size")
            }
            guard module.sourceSHA256.count == 64,
                  module.targetSHA256.count == 64 else {
                throw EndfieldError.invalidProfile("invalid SHA-256 value")
            }
            for chunk in module.chunks {
                guard chunk.offset >= 0, chunk.removeCount >= 0 else {
                    throw EndfieldError.invalidProfile("invalid patch range")
                }
                guard Data(base64Encoded: chunk.replacementBase64) != nil else {
                    throw EndfieldError.invalidProfile(
                        "invalid Base64 replacement"
                    )
                }
            }
        }
    }
}
