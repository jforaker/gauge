import SwiftUI
import GaugeCore

// Local until SS-04 is added to @scratch-studios/design.
enum GaugeTokens {
    static let accent = ScratchColor(ScratchRGBA(74, 88, 102, 1), ScratchRGBA(154, 175, 198, 1))
    static let selection = ScratchColor(ScratchRGBA(231, 232, 232, 1), ScratchRGBA(33, 35, 38, 1))

    static func color(for verdict: GaugeVerdict) -> ScratchColor {
        switch verdict {
        case .good: return accent
        case .fair: return ScratchTokens.ochre
        case .poor: return ScratchTokens.clay
        }
    }
}
