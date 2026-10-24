import SwiftUI
import GaugeCore

private struct GaugeReduceMotionOverrideKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    // Verification can opt in to reduced motion, but can never disable the OS setting.
    var gaugeReduceMotionOverride: Bool {
        get { self[GaugeReduceMotionOverrideKey.self] }
        set { self[GaugeReduceMotionOverrideKey.self] = newValue }
    }
}

struct GaugeLiveDot: View {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.gaugeReduceMotionOverride) private var forcedReduceMotion
    private var reduceMotion: Bool { systemReduceMotion || forcedReduceMotion }
    @State private var startedAt = Date.now

    var body: some View {
        if reduceMotion {
            dot
        } else {
            TimelineView(.animation(minimumInterval: 1 / 30)) { context in
                dot
                    // The live dot is the sole exception to the no-accent-opacity rule.
                    .opacity(GaugeMotion.liveOpacity(elapsed: context.date.timeIntervalSince(startedAt), reduceMotion: false))
            }
        }
    }

    private var dot: some View {
        Circle().fill(ScratchTokens.gaugeAccent.color).frame(width: 4, height: 4).accessibilityHidden(true)
    }
}

// Interpolate the value itself, rather than sliding or crossfading the glyphs.
struct CountingReading: View, Animatable {
    var value: Double
    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text("\(Int(value.rounded()))").font(ScratchType.numeralMono.font).tracking(-1.12)
            .foregroundStyle(ScratchTokens.ink.color)
    }
}
