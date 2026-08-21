import Foundation

public struct DiagnosticsService: Sendable {
    public init() {}

    public func createReport(
        paths: EndfieldPaths = EndfieldPaths()
    ) throws -> URL {
        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let report = paths.desktopSupportReports
            .appendingPathComponent(
                "Endfield-CrossOver-Support-\(timestamp).txt"
            )

        var lines = [
            "Endfield for CrossOver - local support report",
            "Created: \(Date())",
            "",
            "This report is created locally. Review it before sharing.",
            "",
        ]

        if let info = try? CrossOverInspector().find(paths: paths) {
            lines += [
                "CrossOver Preview: \(info.shortVersion) / \(info.build)",
                "CrossOver path: \(info.appURL.path)",
            ]
        } else {
            lines.append("CrossOver Preview: not found")
        }

        lines += [
            "Bottle: \(paths.bottle.path)",
            "Private runtime: \(paths.privateRoot.path)",
            "GRYPHLINK helper: \(paths.gryphlinkHelperExecutable.path)",
            "",
            "Bottle settings configured: \(BottleConfigEditor().isConfigured(paths.bottleConfig) ? "YES" : "NO")",
            "",
            "Relevant running processes:",
        ]

        if let ps = try? ProcessRunner.run(
            URL(fileURLWithPath: "/bin/ps"),
            ["axww", "-o", "pid=,ppid=,command="]
        ) {
            let terms = [
                "CrossOver Preview", "GRYPHLINK", "Games.exe",
                "Endfield.exe", "wineserver", "winewrapper",
                ".endfield-r11-runtime",
            ]
            lines += ps.stdout
                .split(separator: "\n")
                .map(String.init)
                .filter { row in
                    terms.contains {
                        row.localizedCaseInsensitiveContains($0)
                    }
                }
        }

        lines += ["", "Managed file hashes:"]

        let managed = [
            paths.gryphlinkHelperExecutable,
            paths.privateRoot.appendingPathComponent(
                "lib/wine/x86_64-unix/ntdll.so"
            ),
            paths.privateRoot.appendingPathComponent(
                "lib/wine/x86_64-windows/ntdll.dll"
            ),
            paths.privateRoot.appendingPathComponent(
                "lib/wine/x86_64-windows/kernel32.dll"
            ),
            paths.privateRoot.appendingPathComponent(
                "lib/wine/x86_64-windows/ntoskrnl.exe"
            ),
        ]

        for url in managed {
            if let hash = try? SHA256File.hex(url: url) {
                lines.append("\(hash)  \(url.path)")
            } else {
                lines.append("<missing>  \(url.path)")
            }
        }

        if let launchLog = try? String(
            contentsOf: paths.privateContainer
                .appendingPathComponent("launch.log"),
            encoding: .utf8
        ) {
            lines += ["", "Recent private launch log:", launchLog]
        }

        try (lines.joined(separator: "\n") + "\n")
            .write(to: report, atomically: true, encoding: .utf8)

        return report
    }
}
