import Foundation

public struct BottleConfigEditor: Sendable {
    public init() {}

    public let managedValues: [String: String] = [
        "CX_GRAPHICS_BACKEND": "d3dmetal",
        "WINEMSYNC": "1",
        "WINEESYNC": "0",
        "WINEDXVK": "0",
        "WINED3DMETAL": "1",
    ]

    private let forbiddenRuntimeKeys: Set<String> = [
        "CX_ROOT", "PATH", "DYLD_LIBRARY_PATH", "WINEDLLPATH",
        "WINEDLLPATH_PREPEND", "WINELOADER", "WINESERVER",
        "WINEWRAPPER", "WINESERVERSOCKET",
        "CX_WINEWRAPPER_ALT_LOADER_SOCKET", "WINE_WAIT_CHILD_PIPE",
    ]

    public func apply(to url: URL) throws {
        var lines = try String(contentsOf: url, encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)

        guard let start = lines.firstIndex(where: {
            $0.trimmingCharacters(in: .whitespaces) ==
                "[EnvironmentVariables]"
        }) else {
            throw EndfieldError.fileOperation(
                "The Endfield bottle settings file is missing its EnvironmentVariables section."
            )
        }

        var end = lines.count
        if start + 1 < lines.count {
            for i in (start + 1)..<lines.count {
                let s = lines[i].trimmingCharacters(in: .whitespaces)
                if s.hasPrefix("[") && s.hasSuffix("]") {
                    end = i
                    break
                }
            }
        }

        let keyRegex = try NSRegularExpression(
            pattern: #"^\s*"([^"]+)"\s*="#
        )
        var kept: [String] = []

        for i in (start + 1)..<end {
            let line = lines[i]
            let range = NSRange(line.startIndex..<line.endIndex, in: line)
            var shouldDrop = false

            if let match = keyRegex.firstMatch(in: line, range: range),
               let r = Range(match.range(at: 1), in: line) {
                let key = String(line[r])
                if forbiddenRuntimeKeys.contains(key) ||
                    managedValues[key] != nil {
                    shouldDrop = true
                }
            }

            if !shouldDrop { kept.append(line) }
        }

        let inserted = managedValues.keys.sorted().map {
            "\"\($0)\" = \"\(managedValues[$0]!)\""
        }

        lines.replaceSubrange((start + 1)..<end, with: kept + inserted)
        try (lines.joined(separator: "\n") + "\n")
            .write(to: url, atomically: true, encoding: .utf8)
    }

    public func isConfigured(_ url: URL) -> Bool {
        guard let text = try? String(contentsOf: url, encoding: .utf8)
        else { return false }

        for (key, value) in managedValues {
            guard text.contains("\"\(key)\" = \"\(value)\"")
            else { return false }
        }

        for key in forbiddenRuntimeKeys {
            if text.range(
                of: "\"\(key)\"\\s*=",
                options: .regularExpression
            ) != nil {
                return false
            }
        }
        return true
    }
}
