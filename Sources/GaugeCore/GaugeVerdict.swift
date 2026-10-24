import Foundation

public enum GaugeVerdict: Equatable {
    case good, fair, poor

    // Poor below 20%; fair from 20% through 50%; good above 50%.
    public static let thresholds = (poorBelow: 20.0, goodAbove: 50.0)

    public init(remainingPercent: Double) {
        self = remainingPercent < Self.thresholds.poorBelow ? .poor : remainingPercent <= Self.thresholds.goodAbove ? .fair : .good
    }

    public static func lowest(in snapshots: [UsageSnapshot]) -> GaugeVerdict? {
        snapshots.flatMap(\.windows).map { 100 - $0.usedPercent }.min().map { GaugeVerdict(remainingPercent: $0) }
    }
}

public enum GaugeMotion {
    public static let transitionDuration = 0.16
    public static let pulseDuration = 2.4

    public static func liveOpacity(elapsed: TimeInterval, reduceMotion: Bool) -> Double {
        guard !reduceMotion else { return 1 }
        // Cosine easing gives a smooth ease-in-out in each half of the cycle.
        return 0.675 + 0.325 * cos(elapsed * 2 * .pi / pulseDuration)
    }
}
