import XCTest
@testable import GaugeCore

final class UsageParserTests: XCTestCase {
    func testCodexUsesDurationRatherThanPositionAndPrefersCodexBucket() {
        let result = UsageParser.codex([
            "rateLimits": ["primary": ["usedPercent": 99.0]],
            "rateLimitsByLimitId": ["codex": ["primary": ["usedPercent": 12.5, "windowDurationMins": 10080.0, "resetsAt": 1800000000.0]]]
        ])
        XCTAssertEqual(result.windows.first?.label, "Weekly")
        XCTAssertEqual(result.windows.first?.remainingPercent, 88)
        XCTAssertEqual(result.windows.first?.resetsAt, Date(timeIntervalSince1970: 1800000000))
    }

    func testClaudePercentIsNotFractionAndDatesSupportFractionalSeconds() {
        let result = UsageParser.claude(["rate_limits_available": true, "rate_limits": [
            "five_hour": ["utilization": 35.0, "resets_at": "2026-10-24T12:00:00.123Z"],
            "seven_day": ["utilization": 36.0, "resets_at": "2026-10-28T12:00:00Z"]
        ]])
        XCTAssertEqual(result.windows.map(\.remainingPercent), [65, 64])
        XCTAssertTrue(result.windows.allSatisfy { $0.resetsAt != nil })
    }

    func testUnavailableIsNotShownAsFullQuota() {
        let result = UsageParser.claude(["rate_limits_available": false])
        XCTAssertTrue(result.windows.isEmpty)
        XCTAssertNotNil(result.message)
        XCTAssertTrue(UsageParser.codex([:]).windows.isEmpty)
    }

    func testMonthlyFallbackAndClamping() {
        let result = UsageParser.codex(["rateLimits": ["planType": "free", "primary": ["usedPercent": 101.0]]])
        XCTAssertEqual(result.windows.first?.label, "Monthly")
        XCTAssertEqual(result.windows.first?.remainingPercent, 0)
    }
}
