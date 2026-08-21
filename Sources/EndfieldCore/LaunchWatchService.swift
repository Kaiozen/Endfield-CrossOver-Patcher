import Foundation

public struct LaunchWatchService: Sendable {
    public init() {}

    public func watch(
        paths: EndfieldPaths = EndfieldPaths(),
        duration: TimeInterval = 120
    ) async throws -> URL {
        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let report = paths.desktopSupportReports.appendingPathComponent(
            "Endfield-Launch-Watch-\(timestamp).txt"
        )

        let state = loadState(paths.stateFile)
        var seen = Set<Int>()
        var helperChanged = false
        var helperHit = false
        var gryphlinkSeen = false
        var gamesSeen = false
        var endfieldSeen = false
        var privateRuntimeSeen = false
        var stockRuntimeSeenInEndfieldChain = false

        try write(
            [
                "Endfield for CrossOver - launch watchdog",
                "Started: \(Date())",
                "Duration: \(Int(duration)) seconds",
                "",
                "Start Endfield normally now:",
                "CrossOver Preview → Arknights Endfield → GRYPHLINK → Play",
                "",
            ],
            to: report,
            append: false
        )

        let deadline = Date().addingTimeInterval(duration)

        while Date() < deadline {
            if Task.isCancelled {
                try write(
                    ["", "Watch stopped by you at \(Date())."],
                    to: report
                )
                throw CancellationError()
            }

            if let expected = state?.menuHelperSHA256,
               let current = try? SHA256File.hex(
                    url: paths.gryphlinkHelperExecutable
               ),
               current != expected {
                helperChanged = true
            }

            let rows = processRows()
            for row in rows {
                guard isRelevant(row.command) else { continue }

                if row.command.contains("Menu Helper") ||
                    row.command.contains("EndfieldMenuHelper") {
                    helperHit = true
                }
                if row.command.localizedCaseInsensitiveContains(
                    "GRYPHLINK"
                ) {
                    gryphlinkSeen = true
                }
                if row.command.localizedCaseInsensitiveContains(
                    "Games.exe"
                ) {
                    gamesSeen = true
                }
                if row.command.localizedCaseInsensitiveContains(
                    "Endfield.exe"
                ) {
                    endfieldSeen = true
                }

                guard seen.insert(row.pid).inserted else { continue }

                var block = [
                    "",
                    "NEW PROCESS",
                    "PID \(row.pid)  PPID \(row.ppid)",
                    row.command,
                ]

                let evidence = lsofEvidence(
                    pid: row.pid,
                    privateRoot: paths.privateRoot.path
                )

                if evidence.privateSeen {
                    privateRuntimeSeen = true
                }

                if evidence.stockSeen &&
                    isEndfieldChain(row.command) {
                    stockRuntimeSeenInEndfieldChain = true
                }

                if !evidence.lines.isEmpty {
                    block.append("Runtime/path evidence:")
                    block.append(contentsOf: evidence.lines)
                }

                try write(block, to: report)
            }

            if endfieldSeen && privateRuntimeSeen {
                // Keep watching briefly to catch a late child escaping
                // back into the stock Preview runtime.
                try await Task.sleep(
                    nanoseconds: 8_000_000_000
                )
                break
            }

            try await Task.sleep(
                nanoseconds: 400_000_000
            )
        }

        var result = "CHAIN_NOT_CONFIRMED"
        if helperChanged {
            result = "GRYPHLINK_HELPER_WAS_REGENERATED"
        } else if stockRuntimeSeenInEndfieldChain {
            result = "STOCK_RUNTIME_ENTERED_ENDFIELD_CHAIN"
        } else if endfieldSeen && privateRuntimeSeen {
            result = "PRIVATE_RUNTIME_ENDFIELD_SEEN"
        } else if gamesSeen && privateRuntimeSeen {
            result = "PRIVATE_RUNTIME_LAUNCHER_SEEN"
        } else if gryphlinkSeen {
            result = "GRYPHLINK_SEEN_GAME_NOT_CONFIRMED"
        }

        try write(
            [
                "",
                "================ SUMMARY ================",
                "MENU_HELPER_SEEN=\(yesNo(helperHit))",
                "GRYPHLINK_SEEN=\(yesNo(gryphlinkSeen))",
                "GAMES_EXE_SEEN=\(yesNo(gamesSeen))",
                "ENDFIELD_EXE_SEEN=\(yesNo(endfieldSeen))",
                "PRIVATE_RUNTIME_SEEN=\(yesNo(privateRuntimeSeen))",
                "STOCK_RUNTIME_IN_ENDFIELD_CHAIN=\(yesNo(stockRuntimeSeenInEndfieldChain))",
                "HELPER_CHANGED_DURING_WATCH=\(yesNo(helperChanged))",
                "RESULT=\(result)",
            ],
            to: report
        )

        return report
    }

    private struct Row {
        let pid: Int
        let ppid: Int
        let command: String
    }

    private struct Evidence {
        let lines: [String]
        let privateSeen: Bool
        let stockSeen: Bool
    }

    private func processRows() -> [Row] {
        guard let result = try? ProcessRunner.run(
            URL(fileURLWithPath: "/bin/ps"),
            ["axww", "-o", "pid=,ppid=,command="]
        ) else { return [] }

        return result.stdout.split(separator: "\n").compactMap {
            line in
            let parts = line
                .trimmingCharacters(in: .whitespaces)
                .split(
                    separator: " ",
                    maxSplits: 2,
                    omittingEmptySubsequences: true
                )

            guard parts.count == 3,
                  let pid = Int(parts[0]),
                  let ppid = Int(parts[1])
            else { return nil }

            return Row(
                pid: pid,
                ppid: ppid,
                command: String(parts[2])
            )
        }
    }

    private func isRelevant(_ command: String) -> Bool {
        [
            "GRYPHLINK",
            "Games.exe",
            "QtWebEngineProcess.exe",
            "Endfield.exe",
            "wineserver",
            "winewrapper",
            ".endfield-r11-runtime",
            "Menu Helper",
            "EndfieldMenuHelper",
        ].contains {
            command.localizedCaseInsensitiveContains($0)
        }
    }

    private func isEndfieldChain(_ command: String) -> Bool {
        [
            "GRYPHLINK",
            "Games.exe",
            "Endfield.exe",
            "winewrapper",
        ].contains {
            command.localizedCaseInsensitiveContains($0)
        }
    }

    private func lsofEvidence(
        pid: Int,
        privateRoot: String
    ) -> Evidence {
        guard let result = try? ProcessRunner.run(
            URL(fileURLWithPath: "/usr/sbin/lsof"),
            ["-p", String(pid)]
        ) else {
            return Evidence(
                lines: [],
                privateSeen: false,
                stockSeen: false
            )
        }

        var lines: [String] = []
        var privateSeen = false
        var stockSeen = false

        for raw in result.stdout.split(separator: "\n") {
            let line = String(raw)

            if line.contains(privateRoot) ||
                line.contains(".endfield-r11-runtime") {
                privateSeen = true
                lines.append(line)
            } else if line.contains(
                "CrossOver Preview.app/Contents/SharedSupport/CrossOver"
            ) {
                stockSeen = true
                lines.append(line)
            }
        }

        return Evidence(
            lines: Array(lines.prefix(120)),
            privateSeen: privateSeen,
            stockSeen: stockSeen
        )
    }

    private func loadState(_ url: URL) -> InstallState? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(
            InstallState.self,
            from: data
        )
    }

    private func write(
        _ lines: [String],
        to url: URL,
        append: Bool = true
    ) throws {
        let text = lines.joined(separator: "\n") + "\n"
        let data = Data(text.utf8)

        if !append ||
            !FileManager.default.fileExists(atPath: url.path) {
            try data.write(to: url, options: [.atomic])
            return
        }

        let handle = try FileHandle(forWritingTo: url)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: data)
    }

    private func yesNo(_ value: Bool) -> String {
        value ? "YES" : "NO"
    }
}
