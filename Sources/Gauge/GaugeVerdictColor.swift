import SwiftUI
import GaugeCore

// Verdict mapping uses the shared design export; no local color values.
enum GaugeTokens {
    static func color(for verdict: GaugeVerdict) -> ScratchColor {
        switch verdict {
        case .good: return ScratchTokens.gaugeAccent
        case .fair: return ScratchTokens.ochre
        case .poor: return ScratchTokens.clay
        }
    }
}
