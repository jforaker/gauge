import XCTest
@testable import GaugeCore

final class GaugeTickLayoutTests: XCTestCase {
    func testStandardAndRetinaUseSamePointGeometry() {
        for scale in [1.0, 2.0] {
            let layout = GaugeTickLayout(availableWidth: 164, scale: scale)
            XCTAssertEqual(layout.count, 41)
            XCTAssertEqual(layout.tickWidth, 2)
            XCTAssertEqual(layout.gap, 2)
            XCTAssertEqual(layout.totalWidth, 162)
            XCTAssertEqual(layout.trailingWidth, 2)
        }
    }

    func testFractionalWidthsAndOriginsStayOnBackingGrid() {
        for scale in [1.0, 1.5, 2.0, 3.0] {
            for width in [0.0, 1.0, 2.0, 163.25, 164, 165.75] {
                let layout = GaugeTickLayout(availableWidth: width, scale: scale)
                XCTAssertLessThanOrEqual(layout.totalWidth, width)
                XCTAssertEqual(layout.tickWidth * scale, (layout.tickWidth * scale).rounded(), accuracy: 0.0001)
                XCTAssertEqual(layout.gap * scale, (layout.gap * scale).rounded(), accuracy: 0.0001)
                for tick in 0..<layout.count {
                    let absoluteX = (24.13 + layout.x(for: tick, globalOrigin: 24.13)) * scale
                    XCTAssertEqual(absoluteX, absoluteX.rounded(), accuracy: 0.0001)
                }
                if layout.count > 0 {
                    XCTAssertGreaterThan(layout.totalWidth + layout.gap + layout.tickWidth, width)
                }
            }
        }
    }
}
