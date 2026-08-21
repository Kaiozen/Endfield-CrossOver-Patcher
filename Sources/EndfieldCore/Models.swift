import Foundation

public struct SupportedBuild: Sendable, Equatable {
    public let shortVersion: String
    public let build: String

    public init(shortVersion: String, build: String) {
        self.shortVersion = shortVersion
        self.build = build
    }

    public static let firstRelease = SupportedBuild(
        shortVersion: "20260717",
        build: "27.0.0.40734"
    )
}

public struct CrossOverInfo: Sendable, Equatable {
    public let appURL: URL
    public let shortVersion: String
    public let build: String

    public init(appURL: URL, shortVersion: String, build: String) {
        self.appURL = appURL
        self.shortVersion = shortVersion
        self.build = build
    }

    public func matches(_ supported: SupportedBuild) -> Bool {
        shortVersion == supported.shortVersion && build == supported.build
    }
}

public enum CheckState: Sendable, Equatable {
    case ready
    case needsAttention(String)
    case checking
}

public struct ReadinessSnapshot: Sendable, Equatable {
    public var crossover: CheckState
    public var bottle: CheckState
    public var gryphlink: CheckState
    public var profile: CheckState
    public var isInstalled: Bool

    public init(
        crossover: CheckState,
        bottle: CheckState,
        gryphlink: CheckState,
        profile: CheckState,
        isInstalled: Bool
    ) {
        self.crossover = crossover
        self.bottle = bottle
        self.gryphlink = gryphlink
        self.profile = profile
        self.isInstalled = isInstalled
    }

    public var canInstall: Bool {
        [crossover, bottle, gryphlink, profile].allSatisfy {
            if case .ready = $0 { return true }
            return false
        }
    }
}

public struct PatchProfile: Codable, Sendable, Equatable {
    public let format: Int
    public let name: String
    public let crossoverVersion: String
    public let crossoverBuild: String
    public let modules: [PatchModule]

    public init(
        format: Int,
        name: String,
        crossoverVersion: String,
        crossoverBuild: String,
        modules: [PatchModule]
    ) {
        self.format = format
        self.name = name
        self.crossoverVersion = crossoverVersion
        self.crossoverBuild = crossoverBuild
        self.modules = modules
    }
}

public struct PatchModule: Codable, Sendable, Equatable {
    public let relativePath: String
    public let sourceSHA256: String
    public let targetSHA256: String
    public let sourceSize: Int
    public let targetSize: Int
    public let chunks: [PatchChunk]

    public init(
        relativePath: String,
        sourceSHA256: String,
        targetSHA256: String,
        sourceSize: Int,
        targetSize: Int,
        chunks: [PatchChunk]
    ) {
        self.relativePath = relativePath
        self.sourceSHA256 = sourceSHA256
        self.targetSHA256 = targetSHA256
        self.sourceSize = sourceSize
        self.targetSize = targetSize
        self.chunks = chunks
    }
}

public struct PatchChunk: Codable, Sendable, Equatable {
    public let offset: Int
    public let removeCount: Int
    public let replacementBase64: String

    public init(offset: Int, removeCount: Int, replacementBase64: String) {
        self.offset = offset
        self.removeCount = removeCount
        self.replacementBase64 = replacementBase64
    }
}

public struct InstallState: Codable, Sendable, Equatable {
    public let format: Int
    public let installedAt: Date
    public let crossoverVersion: String
    public let crossoverBuild: String
    public let profileName: String
    public let menuHelperSHA256: String
    public let runtimeTargets: [String: String]
    public let helperBackupPath: String

    public init(
        format: Int,
        installedAt: Date,
        crossoverVersion: String,
        crossoverBuild: String,
        profileName: String,
        menuHelperSHA256: String,
        runtimeTargets: [String: String],
        helperBackupPath: String
    ) {
        self.format = format
        self.installedAt = installedAt
        self.crossoverVersion = crossoverVersion
        self.crossoverBuild = crossoverBuild
        self.profileName = profileName
        self.menuHelperSHA256 = menuHelperSHA256
        self.runtimeTargets = runtimeTargets
        self.helperBackupPath = helperBackupPath
    }
}

public enum EndfieldError: LocalizedError, Sendable {
    case unsupportedBuild(foundVersion: String, foundBuild: String)
    case missingCrossOver
    case missingBottle
    case missingGryphlink
    case missingProfile
    case invalidProfile(String)
    case sourceMismatch(String)
    case targetMismatch(String)
    case processFailed(String)
    case unsafePath(String)
    case fileOperation(String)

    public var errorDescription: String? {
        switch self {
        case .unsupportedBuild(let version, let build):
            return "This CrossOver Preview build is not supported yet. Found \(version) / \(build). Nothing was changed."
        case .missingCrossOver:
            return "CrossOver Preview was not found. Install the supported Preview build, then check again."
        case .missingBottle:
            return "The Arknights Endfield bottle was not found. Create it in CrossOver Preview and install GRYPHLINK first."
        case .missingGryphlink:
            return "GRYPHLINK was not found in the Endfield bottle. Install it in CrossOver Preview, then check again."
        case .missingProfile:
            return "The compatibility profile is not included in this development build. Setup is disabled until the reviewed R11 profile is added."
        case .invalidProfile(let detail):
            return "The compatibility profile is not valid: \(detail)"
        case .sourceMismatch(let path):
            return "A CrossOver file is different from the supported build: \(path). Nothing was patched."
        case .targetMismatch(let path):
            return "Setup could not verify the finished compatibility file: \(path). The operation stopped."
        case .processFailed(let message):
            return message
        case .unsafePath(let path):
            return "The patcher refused an unexpected path: \(path)"
        case .fileOperation(let message):
            return message
        }
    }
}
