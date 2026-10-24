import Foundation

/// Tick geometry in backing pixels. Remainder belongs to the trailing edge,
/// never to the tick widths or gaps.
public struct GaugeTickLayout {
    public let scale: Double
    public let tickWidth: Double
    public let gap: Double
    public let count: Int
    public let totalWidth: Double
    public let trailingWidth: Double

    public init(availableWidth: Double, scale: Double) {
        self.scale = scale.isFinite && scale > 0 ? scale : 1
        let tickPixels = max(1, Int((2 * self.scale).rounded()))
        let gapPixels = max(1, Int((2 * self.scale).rounded()))
        let availablePixels = max(0, Int((max(0, availableWidth) * self.scale).rounded(.down)))
        count = (availablePixels + gapPixels) / (tickPixels + gapPixels)
        tickWidth = Double(tickPixels) / self.scale
        gap = Double(gapPixels) / self.scale
        let occupiedPixels = count == 0 ? 0 : count * tickPixels + (count - 1) * gapPixels
        totalWidth = Double(occupiedPixels) / self.scale
        trailingWidth = max(0, availableWidth - totalWidth)
    }

    public func x(for tick: Int, globalOrigin: Double) -> Double {
        let x = Double(tick) * (tickWidth + gap)
        return ((globalOrigin + x) * scale).rounded() / scale - globalOrigin
    }

    public func snappedOffset(globalOrigin: Double) -> Double {
        (globalOrigin * scale).rounded() / scale - globalOrigin
    }
}
