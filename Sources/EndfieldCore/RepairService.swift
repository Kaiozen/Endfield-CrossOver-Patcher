import Foundation

public struct RepairReport: Sendable, Equatable {
    public let runtimeOK: Bool
    public let bottleSettingsOK: Bool
    public let helperOK: Bool
    public let payloadOK: Bool

    public var isHealthy: Bool {
        runtimeOK && bottleSettingsOK && helperOK && payloadOK
    }
}

public struct RepairService: Sendable {
    public init() {}

    public func inspect(
        profile: PatchProfile,
        paths: EndfieldPaths = EndfieldPaths()
    ) -> RepairReport {
        let fm = FileManager.default

        let runtimeOK: Bool = {
            do {
                try PatchEngine().verifyTargets(
                    profile: profile,
                    privateRoot: paths.privateRoot
                )
                return true
            } catch {
                return false
            }
        }()

        let payloadOK =
            fm.fileExists(atPath: paths.payload.path) &&
            fm.isExecutableFile(atPath: paths.payload.path)

        let helperOK: Bool = {
            guard
                let data = try? Data(contentsOf: paths.stateFile),
                let state = try? decodeState(data),
                fm.fileExists(
                    atPath: paths.gryphlinkHelperExecutable.path
                ),
                let hash = try? SHA256File.hex(
                    url: paths.gryphlinkHelperExecutable
                )
            else { return false }

            return hash == state.menuHelperSHA256
        }()

        return RepairReport(
            runtimeOK: runtimeOK,
            bottleSettingsOK:
                BottleConfigEditor().isConfigured(paths.bottleConfig),
            helperOK: helperOK,
            payloadOK: payloadOK
        )
    }

    public func repair(
        profileURL: URL,
        bundledMenuHelper: URL,
        paths: EndfieldPaths = EndfieldPaths(),
        progress: @Sendable (String) -> Void = { _ in }
    ) throws {
        let profile = try ProfileLoader().load(url: profileURL)
        let report = inspect(profile: profile, paths: paths)

        if !report.runtimeOK {
            progress("Rebuilding the private Endfield runtime")
            let inspector = CrossOverInspector()
            let info = try inspector.find(paths: paths)
            try inspector.requireSupported(info)
            try PatchEngine().preparePrivateRuntime(
                stockRuntime: inspector.runtimeRoot(for: info.appURL),
                destination: paths.privateRoot,
                profile: profile,
                progress: progress
            )
        }

        if !report.payloadOK {
            progress("Restoring the Endfield launcher connection")
            try PayloadWriter().write(paths: paths)
        }

        if !report.bottleSettingsOK {
            progress("Restoring the tested Endfield settings")
            try BottleConfigEditor().apply(to: paths.bottleConfig)
        }

        if !report.helperOK {
            progress("Repairing the GRYPHLINK launcher")
            let stamp = "repair-" +
                ISO8601DateFormatter().string(from: Date())
                .replacingOccurrences(of: ":", with: "-")
            let backup = paths.backupRoot.appendingPathComponent(
                stamp,
                isDirectory: true
            )

            _ = try MenuHelperInstaller().install(
                bundledHelper: bundledMenuHelper,
                paths: paths,
                backupDirectory: backup,
                progress: progress
            )

            if
                let data = try? Data(contentsOf: paths.stateFile),
                let oldState = try? decodeState(data)
            {
                let helperHash = try SHA256File.hex(
                    url: paths.gryphlinkHelperExecutable
                )
                let newState = InstallState(
                    format: oldState.format,
                    installedAt: oldState.installedAt,
                    crossoverVersion: oldState.crossoverVersion,
                    crossoverBuild: oldState.crossoverBuild,
                    profileName: oldState.profileName,
                    menuHelperSHA256: helperHash,
                    runtimeTargets: oldState.runtimeTargets,
                    helperBackupPath: oldState.helperBackupPath
                )
                try encodeState(newState).write(
                    to: paths.stateFile,
                    options: [.atomic]
                )
            }
        }

        progress("Repair complete")
    }

    private func decodeState(_ data: Data) throws -> InstallState {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(InstallState.self, from: data)
    }

    private func encodeState(_ state: InstallState) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(state)
    }
}
