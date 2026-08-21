import Foundation

public struct ProcessResult: Sendable {
    public let status: Int32
    public let stdout: String
    public let stderr: String
}

public enum ProcessRunner {
    @discardableResult
    public static func run(
        _ executable: URL,
        _ arguments: [String] = [],
        environment: [String: String]? = nil,
        currentDirectory: URL? = nil
    ) throws -> ProcessResult {
        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        process.environment = environment
        process.currentDirectoryURL = currentDirectory

        let out = Pipe()
        let err = Pipe()
        process.standardOutput = out
        process.standardError = err

        do {
            try process.run()
        } catch {
            throw EndfieldError.processFailed(
                "Could not start \(executable.lastPathComponent): \(error.localizedDescription)"
            )
        }

        process.waitUntilExit()

        return ProcessResult(
            status: process.terminationStatus,
            stdout: String(
                decoding: out.fileHandleForReading.readDataToEndOfFile(),
                as: UTF8.self
            ),
            stderr: String(
                decoding: err.fileHandleForReading.readDataToEndOfFile(),
                as: UTF8.self
            )
        )
    }

    public static func requireSuccess(
        _ executable: URL,
        _ arguments: [String] = [],
        environment: [String: String]? = nil,
        currentDirectory: URL? = nil,
        userMessage: String
    ) throws -> ProcessResult {
        let result = try run(
            executable,
            arguments,
            environment: environment,
            currentDirectory: currentDirectory
        )
        guard result.status == 0 else {
            let detail = result.stderr.trimmingCharacters(in: .whitespacesAndNewlines)
            throw EndfieldError.processFailed(
                detail.isEmpty ? userMessage : "\(userMessage)\n\n\(detail)"
            )
        }
        return result
    }
}
