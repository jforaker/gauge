import XCTest
@testable import GaugeCore

final class GaugeVerdictTests: XCTestCase {
    func testVerdictBoundariesAndFixtures() {
        for (value, expected) in [(87.0, GaugeVerdict.good), (50.01, .good), (50, .fair), (40, .fair), (20, .fair), (19.99, .poor), (10, .poor), (0, .poor)] {
            XCTAssertEqual(GaugeVerdict(remainingPercent: value), expected, "\(value)% remaining")
        }
    }

    func testMenuBarUsesLowestAcrossProvidersAndWindows() {
        func snapshot(_ provider: Provider, _ values: [Double]) -> UsageSnapshot {
            UsageSnapshot(provider: provider, windows: values.enumerated().map { index, left in
                UsageWindow(id: "\(index)", label: "Session", usedPercent: 100 - left, resetsAt: nil)
            })
        }
        XCTAssertEqual(GaugeVerdict.lowest(in: [snapshot(.codex, [87, 90]), snapshot(.claude, [80, 40])]), .fair)
        XCTAssertEqual(GaugeVerdict.lowest(in: [snapshot(.codex, [87, 10]), snapshot(.claude, [80, 40])]), .poor)
        XCTAssertNil(GaugeVerdict.lowest(in: []))
    }

    func testLivePulseAndReduceMotion() {
        XCTAssertEqual(GaugeMotion.liveOpacity(elapsed: 0, reduceMotion: false), 1, accuracy: 0.0001)
        XCTAssertEqual(GaugeMotion.liveOpacity(elapsed: 1.2, reduceMotion: false), 0.35, accuracy: 0.0001)
        XCTAssertEqual(GaugeMotion.liveOpacity(elapsed: 2.4, reduceMotion: false), 1, accuracy: 0.0001)
        for elapsed in [0.0, 0.6, 1.2, 2.4] {
            XCTAssertEqual(GaugeMotion.liveOpacity(elapsed: elapsed, reduceMotion: true), 1)
        }
    }
}
