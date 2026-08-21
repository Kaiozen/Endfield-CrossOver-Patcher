import Foundation

public struct MenuHelperInstaller: Sendable {
    public init() {}

    public func install(
        bundledHelper: URL,
        paths: EndfieldPaths,
        backupDirectory: URL,
        progress: @Sendable (String) -> Void = { _ in }
    ) throws -> String {
        let fm = FileManager.default
        let helperApp = paths.gryphlinkHelperApp
        let helperExe = paths.gryphlinkHelperExecutable

        guard fm.fileExists(atPath: helperExe.path) else {
            throw EndfieldError.missingGryphlink
        }
        guard fm.isExecutableFile(atPath: bundledHelper.path) else {
            throw EndfieldError.fileOperation(
                "The patcher's GRYPHLINK helper is missing from this app build."
            )
        }

        try fm.createDirectory(
            at: backupDirectory,
            withIntermediateDirectories: true
        )
        let helperBackup = backupDirectory.appendingPathComponent(
            "GRYPHLINK.app.original",
            isDirectory: true
        )

        progress("Saving the GRYPHLINK launcher backup")
        if fm.fileExists(atPath: helperBackup.path) {
            try fm.removeItem(at: helperBackup)
        }

        try ProcessRunner.requireSuccess(
            URL(fileURLWithPath: "/usr/bin/ditto"),
            [helperApp.path, helperBackup.path],
            userMessage: "The GRYPHLINK launcher backup could not be created."
        )

        progress("Connecting GRYPHLINK to the private Endfield runtime")
        try fm.removeItem(at: helperExe)
        try fm.copyItem(at: bundledHelper, to: helperExe)
        try fm.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: helperExe.path
        )

        try ProcessRunner.requireSuccess(
            URL(fileURLWithPath: "/usr/bin/codesign"),
            ["--force", "--deep", "--sign", "-", helperApp.path],
            userMessage: "macOS could not sign the Endfield-specific GRYPHLINK launcher."
        )

        return try SHA256File.hex(url: helperExe)
    }

    public func restore(
        paths: EndfieldPaths,
        backupPath: String
    ) throws {
        let fm = FileManager.default
        let backup = URL(
            fileURLWithPath: backupPath,
            isDirectory: true
        )

        guard fm.fileExists(atPath: backup.path) else {
            throw EndfieldError.fileOperation(
                "The saved GRYPHLINK launcher backup is missing."
            )
        }

        if fm.fileExists(atPath: paths.gryphlinkHelperApp.path) {
            try fm.removeItem(at: paths.gryphlinkHelperApp)
        }

        try ProcessRunner.requireSuccess(
            URL(fileURLWithPath: "/usr/bin/ditto"),
            [backup.path, paths.gryphlinkHelperApp.path],
            userMessage: "The original GRYPHLINK launcher could not be restored."
        )
    }
}
