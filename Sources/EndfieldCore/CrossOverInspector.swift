import Foundation

public struct CrossOverInspector: Sendable {
    public init() {}

    public func find(paths: EndfieldPaths = EndfieldPaths()) throws -> CrossOverInfo {
        for candidate in paths.candidateCrossOverApps() {
            if FileManager.default.fileExists(atPath: candidate.path) {
                return try inspect(candidate)
            }
        }
        throw EndfieldError.missingCrossOver
    }

    public func inspect(_ app: URL) throws -> CrossOverInfo {
        let plist = app.appendingPathComponent("Contents/Info.plist")
        let data = try Data(contentsOf: plist)
        guard
            let object = try PropertyListSerialization.propertyList(
                from: data,
                format: nil
            ) as? [String: Any]
        else {
            throw EndfieldError.fileOperation(
                "CrossOver Preview's version information could not be read."
            )
        }

        return CrossOverInfo(
            appURL: app,
            shortVersion: String(describing: object["CFBundleShortVersionString"] ?? ""),
            build: String(describing: object["CFBundleVersion"] ?? "")
        )
    }

    public func requireSupported(
        _ info: CrossOverInfo,
        supported: SupportedBuild = .firstRelease
    ) throws {
        guard info.matches(supported) else {
            throw EndfieldError.unsupportedBuild(
                foundVersion: info.shortVersion,
                foundBuild: info.build
            )
        }
    }

    public func runtimeRoot(for app: URL) -> URL {
        app.appendingPathComponent(
            "Contents/SharedSupport/CrossOver",
            isDirectory: true
        )
    }
}
