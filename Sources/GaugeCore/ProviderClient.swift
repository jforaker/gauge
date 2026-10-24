import Foundation
import Darwin

public enum ProviderClient {
    public static func read(_ provider: Provider) async -> UsageSnapshot {
        await Task.detached(priority: .utility) {
            do {
                let environment = CLIEnvironment.load()
                guard let executable = CLIEnvironment.find(provider.executable, in: environment) else {
                    return UsageSnapshot(provider: provider, message: "Install the \(provider.rawValue) CLI, then run \(provider.loginCommand).")
                }
                return try provider == .codex ? readCodex(executable, environment) : readClaude(executable, environment)
            } catch {
                return UsageSnapshot(provider: provider, message: error.localizedDescription)
            }
        }.value
    }

    private static func readCodex(_ executable: String, _ environment: [String: String]) throws -> UsageSnapshot {
        let session = try JSONLineProcess(executable: executable, arguments: ["app-server"], environment: environment)
        defer { session.close() }
        try session.send(["id": 1, "method": "initialize", "params": ["clientInfo": ["name": "gauge", "title": "Gauge", "version": "0.1.0"]]])
        _ = try session.receive { ($0["id"] as? Int) == 1 }
        try session.send(["method": "initialized"])
        try session.send(["id": 2, "method": "account/rateLimits/read", "params": NSNull()])
        let response = try session.receive { ($0["id"] as? Int) == 2 }
        guard let result = response["result"] as? [String: Any] else {
            throw ProbeError.message("Codex could not read usage. Run codex login, then refresh.")
        }
        return UsageParser.codex(result)
    }

    private static func readClaude(_ executable: String, _ environment: [String: String]) throws -> UsageSnapshot {
        var env = environment
        env.removeValue(forKey: "CLAUDECODE")
        env["ENABLE_CLAUDEAI_MCP_SERVERS"] = "false"
        env["CLAUDE_CODE_AUTO_CONNECT_IDE"] = "0"
        env["CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL"] = "1"
        var arguments = [
            "--print", "--input-format", "stream-json", "--output-format", "stream-json", "--verbose",
            "--no-session-persistence", "--setting-sources", "user", "--settings", "{\"disableAllHooks\":true}",
            "--tools", "", "--mcp-config", "{\"mcpServers\":{}}"
        ]
        // Claude enforces managed MCP policy itself and rejects the strict flag
        // on managed hosts. Elsewhere, prevent loading the user's MCP servers.
        if !FileManager.default.fileExists(atPath: "/Library/Application Support/ClaudeCode/managed-mcp.json") {
            arguments.append("--strict-mcp-config")
        }
        let session = try JSONLineProcess(executable: executable, arguments: arguments, environment: env)
        defer { session.close() }
        try session.send(["type": "control_request", "request_id": "gauge-init", "request": ["subtype": "initialize"]])
        _ = try session.receive { (($0["response"] as? [String: Any])?["request_id"] as? String) == "gauge-init" }
        try session.send(["type": "control_request", "request_id": "gauge-usage", "request": ["subtype": "get_usage", "skip_behaviors": true]])
        let response = try session.receive { (($0["response"] as? [String: Any])?["request_id"] as? String) == "gauge-usage" }
        guard let envelope = response["response"] as? [String: Any], envelope["subtype"] as? String == "success",
              let usage = envelope["response"] as? [String: Any] else {
            throw ProbeError.message("Claude could not read usage. Run claude auth login, then refresh.")
        }
        return UsageParser.claude(usage)
    }
}

private enum ProbeError: LocalizedError {
    case message(String)
    var errorDescription: String? { if case let .message(message) = self { return message }; return nil }
}

// Only control messages are sent. No user prompt or model generation is requested.
private final class JSONLineProcess {
    private let process = Process()
    private let input = Pipe()
    private let output = Pipe()
    private var buffer = Data()
    private let deadline: Date

    init(executable: String, arguments: [String], environment: [String: String], timeout: TimeInterval = 25) throws {
        deadline = Date().addingTimeInterval(timeout)
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.environment = environment
        process.currentDirectoryURL = FileManager.default.temporaryDirectory
        process.standardInput = input
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        try process.run()
    }

    func send(_ object: [String: Any]) throws {
        var data = try JSONSerialization.data(withJSONObject: object)
        data.append(10)
        try input.fileHandleForWriting.write(contentsOf: data)
    }

    func receive(where matches: ([String: Any]) -> Bool) throws -> [String: Any] {
        while Date() < deadline {
            while let newline = buffer.firstIndex(of: 10) {
                let line = buffer.prefix(upTo: newline)
                buffer.removeSubrange(...newline)
                if let object = try? JSONSerialization.jsonObject(with: line) as? [String: Any], matches(object) { return object }
            }
            var descriptor = pollfd(fd: output.fileHandleForReading.fileDescriptor, events: Int16(POLLIN), revents: 0)
            let ready = poll(&descriptor, 1, 200)
            if ready < 0 && errno != EINTR { throw ProbeError.message("Could not read the provider process.") }
            if ready > 0 {
                var bytes = [UInt8](repeating: 0, count: 16384)
                let count = Darwin.read(descriptor.fd, &bytes, bytes.count)
                guard count > 0 else { throw ProbeError.message("Provider exited before reporting usage. Check its CLI login and version.") }
                buffer.append(contentsOf: bytes.prefix(count))
                guard buffer.count < 4_000_000 else { throw ProbeError.message("Provider returned an unexpectedly large response.") }
            }
        }
        throw ProbeError.message("Provider did not respond within 25 seconds. Try refreshing.")
    }

    func close() {
        try? input.fileHandleForWriting.close()
        if process.isRunning {
            process.terminate()
            for _ in 0..<20 {
                if !process.isRunning { break }
                Thread.sleep(forTimeInterval: 0.025)
            }
            if process.isRunning { kill(process.processIdentifier, SIGKILL) }
        }
        process.waitUntilExit()
        try? output.fileHandleForReading.close()
    }
}

private enum CLIEnvironment {
    static func load() -> [String: String] {
        var env = ProcessInfo.processInfo.environment
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        env["HOME"] = env["HOME"] ?? home
        // Finder-launched apps do not inherit the terminal PATH. Read PATH only,
        // preserving the app's environment and leaving credentials with the CLI.
        let shell = env["SHELL"] ?? "/bin/zsh"
        if let session = try? JSONLineProcess(executable: shell, arguments: ["-ilc", "printf '{\"path\":\"%s\"}\\n' \"$PATH\""], environment: env, timeout: 3) {
            if let result = try? session.receive(where: { $0["path"] is String }), let path = result["path"] as? String { env["PATH"] = path }
            session.close()
        }
        let fallback = ["\(home)/.local/bin", "\(home)/.npm-global/bin", "/opt/homebrew/bin", "/usr/local/bin", "/usr/bin", "/bin"]
        env["PATH"] = ([env["PATH"] ?? ""] + fallback).joined(separator: ":")
        return env
    }

    static func find(_ name: String, in env: [String: String]) -> String? {
        (env["PATH"] ?? "").split(separator: ":").map { "\($0)/\(name)" }.first { FileManager.default.isExecutableFile(atPath: $0) }
    }
}
