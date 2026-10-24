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

    public static func combinedWeekly(in snapshots: [UsageSnapshot]) -> GaugeVerdict? {
        let remaining = snapshots.compactMap { snapshot in
            snapshot.windows.first { $0.label == "Weekly" }.map { 100 - $0.usedPercent }
        }
        guard !remaining.isEmpty else { return nil }
        return GaugeVerdict(remainingPercent: remaining.reduce(0, +) / Double(remaining.count))
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
