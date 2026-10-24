import Foundation

public enum Provider: String, CaseIterable, Identifiable, Sendable {
    case codex = "Codex", claude = "Claude"
    public var id: String { rawValue }
    public var executable: String { rawValue.lowercased() }
    public var loginCommand: String { self == .codex ? "codex login" : "claude auth login" }
}

public struct UsageWindow: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let usedPercent: Double
    public let resetsAt: Date?
    public var remainingPercent: Int { Int((100 - usedPercent).rounded()) }

    public init(id: String, label: String, usedPercent: Double, resetsAt: Date?) {
        self.id = id
        self.label = label
        self.usedPercent = min(100, max(0, usedPercent.isFinite ? usedPercent : 0))
        self.resetsAt = resetsAt
    }
}

public struct UsageSnapshot: Sendable {
    public let provider: Provider
    public let windows: [UsageWindow]
    public let checkedAt: Date
    public let message: String?

    public init(provider: Provider, windows: [UsageWindow] = [], checkedAt: Date = .now, message: String? = nil) {
        self.provider = provider
        self.windows = windows
        self.checkedAt = checkedAt
        self.message = message
    }
}

public enum UsageParser {
    public static func codex(_ response: [String: Any]) -> UsageSnapshot {
        let byID = response["rateLimitsByLimitId"] as? [String: Any]
        guard let limits = (byID?["codex"] ?? response["rateLimits"]) as? [String: Any] else {
            return UsageSnapshot(provider: .codex, message: "No subscription limits reported. Check your Codex login.")
        }
        let monthly = ["free", "go"].contains(limits["planType"] as? String ?? "")
        let windows = ["primary", "secondary"].compactMap { id -> UsageWindow? in
            guard let window = limits[id] as? [String: Any], let used = window["usedPercent"] as? Double, used.isFinite else { return nil }
            let duration = window["windowDurationMins"] as? Double ?? (id == "secondary" ? 10080 : monthly ? 43200 : 300)
            return UsageWindow(id: id, label: duration >= 43200 ? "Monthly" : duration >= 10080 ? "Weekly" : "Session", usedPercent: used,
                               resetsAt: (window["resetsAt"] as? Double).map { Date(timeIntervalSince1970: $0) })
        }
        return UsageSnapshot(provider: .codex, windows: windows, message: windows.isEmpty ? "This account has no subscription limits." : nil)
    }

    public static func claude(_ response: [String: Any]) -> UsageSnapshot {
        guard response["rate_limits_available"] as? Bool == true, let limits = response["rate_limits"] as? [String: Any] else {
            return UsageSnapshot(provider: .claude, message: "No subscription limits reported. Check your Claude login.")
        }
        let windows = [("five_hour", "Session"), ("seven_day", "Weekly")].compactMap { id, label -> UsageWindow? in
            guard let window = limits[id] as? [String: Any], let used = window["utilization"] as? Double, used.isFinite else { return nil }
            let reset = (window["resets_at"] as? String).flatMap(parseDate)
            return UsageWindow(id: id, label: label, usedPercent: used, resetsAt: reset)
        }
        return UsageSnapshot(provider: .claude, windows: windows, message: windows.isEmpty ? "No quota windows reported." : nil)
    }

    private static func parseDate(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: value) ?? ISO8601DateFormatter().date(from: value)
    }
}
