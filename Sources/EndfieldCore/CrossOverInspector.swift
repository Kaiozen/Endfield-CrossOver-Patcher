import Foundation

public struct CrossOverInspector: Sendable {
    public init() {}

    public func find(paths: EndfieldPaths = EndfieldPaths()) throws -> CrossOverInfo {
        var found: [CrossOverInfo] = []

        for candidate in paths.candidateCrossOverApps() {
            if FileManager.default.fileExists(atPath: candidate.path) {
                found.append(try inspect(candidate))
            }
        }

        guard !found.isEmpty else {
            throw EndfieldError.missingCrossOver
        }

        if let tested = found.first(where: { $0.isBaselineTested }) {
            return tested
        }

        if let supported = found.first(where: { $0.matches(.firstRelease) }) {
            return supported
        }

        return found[0]
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
