import Foundation

public struct UninstallService: Sendable {
    public init() {}

    public func remove(
        paths: EndfieldPaths = EndfieldPaths()
    ) throws {
        let fm = FileManager.default

        guard
            let data = try? Data(contentsOf: paths.stateFile),
            let state = try? decodeState(data)
        else {
            throw EndfieldError.fileOperation(
                "The patcher could not find a complete setup record to restore safely."
            )
        }

        try MenuHelperInstaller().restore(
            paths: paths,
            backupPath: state.helperBackupPath
        )

        let backupApp = URL(
            fileURLWithPath: state.helperBackupPath,
            isDirectory: true
        )
        let configBackup = backupApp
            .deletingLastPathComponent()
            .appendingPathComponent("cxbottle.conf")

        if fm.fileExists(atPath: configBackup.path) {
            let staged = paths.bottleConfig
                .deletingLastPathComponent()
                .appendingPathComponent(
                    ".cxbottle.conf.endfield-remove-\(UUID().uuidString)"
                )
            try fm.copyItem(at: configBackup, to: staged)
            _ = try fm.replaceItemAt(
                paths.bottleConfig,
                withItemAt: staged
            )
        }

        if fm.fileExists(atPath: paths.privateContainer.path) {
            let removed = paths.bottle.appendingPathComponent(
                ".endfield-r11-runtime.removed-\(Int(Date().timeIntervalSince1970))",
                isDirectory: true
            )
            try fm.moveItem(
                at: paths.privateContainer,
                to: removed
            )
        }
    }

    private func decodeState(_ data: Data) throws -> InstallState {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(InstallState.self, from: data)
    }
}
