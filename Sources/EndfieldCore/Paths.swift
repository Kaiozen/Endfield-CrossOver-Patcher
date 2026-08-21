import Foundation

public struct EndfieldPaths: Sendable {
    public let home: URL

    public init(home: URL = FileManager.default.homeDirectoryForCurrentUser) {
        self.home = home.standardizedFileURL
    }

    public var bottle: URL {
        home.appendingPathComponent(
            "Library/Application Support/CrossOver/Bottles/Arknights Endfield",
            isDirectory: true
        )
    }

    public var bottleConfig: URL { bottle.appendingPathComponent("cxbottle.conf") }

    public var privateContainer: URL {
        bottle.appendingPathComponent(".endfield-r11-runtime", isDirectory: true)
    }

    public var privateRoot: URL {
        privateContainer.appendingPathComponent("CrossOver", isDirectory: true)
    }

    public var payload: URL {
        privateContainer.appendingPathComponent("launch-gryphlink-private-r11.sh")
    }

    public var stateFile: URL { privateContainer.appendingPathComponent("state.json") }

    public var backupRoot: URL {
        bottle.appendingPathComponent(".endfield-patcher-backups", isDirectory: true)
    }

    public var gryphlinkHelperApp: URL {
        home.appendingPathComponent(
            "Applications/CrossOver/GRYPHLINK/GRYPHLINK.app",
            isDirectory: true
        )
    }

    public var gryphlinkHelperExecutable: URL {
        gryphlinkHelperApp.appendingPathComponent("Contents/MacOS/Menu Helper")
    }

    public var gryphlinkWindowsShortcut: URL {
        bottle.appendingPathComponent(
            "drive_c/ProgramData/Microsoft/Windows/Start Menu/Programs/GRYPHLINK/GRYPHLINK.lnk"
        )
    }

    public var gryphlinkLauncherExe: URL {
        bottle.appendingPathComponent("drive_c/Program Files/GRYPHLINK/Launcher.exe")
    }

    public var desktopSupportReports: URL {
        home.appendingPathComponent("Desktop", isDirectory: true)
    }

    public func candidateCrossOverApps() -> [URL] {
        [
            home.appendingPathComponent("Applications/CrossOver Preview.app", isDirectory: true),
            URL(fileURLWithPath: "/Applications/CrossOver Preview.app", isDirectory: true),
        ]
    }
}
