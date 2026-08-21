import Foundation

public struct InstallService: Sendable {
    public init() {}

    public func install(
        profileURL: URL,
        bundledMenuHelper: URL,
        bundledGreenButtonHook: URL,
        paths: EndfieldPaths = EndfieldPaths(),
        progress: @Sendable (String) -> Void = { _ in }
    ) throws {
        let fm = FileManager.default
        let inspector = CrossOverInspector()
        let profile = try ProfileLoader().load(url: profileURL)

        progress("Checking CrossOver Preview")
        let info = try inspector.find(paths: paths)
        try inspector.requireSupported(info)

        guard fm.fileExists(atPath: paths.bottleConfig.path) else {
            throw EndfieldError.missingBottle
        }

        guard fm.fileExists(atPath: paths.endfieldExe.path) else {
            throw EndfieldError.fileOperation(
                "Arknights: Endfield was not found in the Arknights Endfield bottle. Install the game from GRYPHLINK first, then check again."
            )
        }

        guard
            fm.fileExists(atPath: paths.gryphlinkLauncherExe.path) ||
            fm.fileExists(atPath: paths.gryphlinkWindowsShortcut.path)
        else {
            throw EndfieldError.missingGryphlink
        }

        progress("Preparing Endfield")
        try PatchEngine().preparePrivateRuntime(
            stockRuntime: inspector.runtimeRoot(for: info.appURL),
            destination: paths.privateRoot,
            profile: profile,
            greenButtonHook: bundledGreenButtonHook,
            progress: progress
        )

        try PayloadWriter().write(paths: paths)

        let stamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let backupDir = paths.backupRoot.appendingPathComponent(
            stamp,
            isDirectory: true
        )
        try fm.createDirectory(
            at: backupDir,
            withIntermediateDirectories: true
        )

        progress("Saving your current Endfield settings")
        try fm.copyItem(
            at: paths.bottleConfig,
            to: backupDir.appendingPathComponent("cxbottle.conf")
        )

        progress("Applying the tested Endfield settings")
        try BottleConfigEditor().apply(to: paths.bottleConfig)

        guard fm.fileExists(
            atPath: paths.gryphlinkHelperExecutable.path
        ) else {
            throw EndfieldError.fileOperation(
                "CrossOver has not created the GRYPHLINK launcher helper yet. Open CrossOver Preview once, open the Endfield bottle, then check again."
            )
        }

        let helperHash = try MenuHelperInstaller().install(
            bundledHelper: bundledMenuHelper,
            paths: paths,
            backupDirectory: backupDir,
            progress: progress
        )

        let targets = Dictionary(
            uniqueKeysWithValues: profile.modules.map {
                ($0.relativePath, $0.targetSHA256)
            }
        )

        let state = InstallState(
            format: 1,
            installedAt: Date(),
            crossoverVersion: info.shortVersion,
            crossoverBuild: info.build,
            profileName: profile.name,
            menuHelperSHA256: helperHash,
            runtimeTargets: targets,
            helperBackupPath: backupDir
                .appendingPathComponent(
                    "GRYPHLINK.app.original",
                    isDirectory: true
                ).path
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        try encoder.encode(state).write(
            to: paths.stateFile,
            options: [.atomic]
        )

        progress("Setup complete")
    }
}
