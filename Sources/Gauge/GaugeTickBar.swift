import SwiftUI
import GaugeCore

enum GaugePanelLayout {
    static let width: CGFloat = 400
    static let inset: CGFloat = 24
    static let columnGap: CGFloat = 24

    static func columnWidth(scale: CGFloat) -> CGFloat {
        let available = (width - 2 * inset - columnGap) / 2
        return floor(available * scale) / scale
    }
}

struct GaugeTickBar: View {
    let remainingFraction: Double
    let filledColor: Color
    let width: CGFloat
    @Environment(\.displayScale) private var scale

    var body: some View {
        let layout = GaugeTickLayout(availableWidth: width, scale: scale)
        GeometryReader { geometry in
            let origin = geometry.frame(in: .global).origin
            ZStack(alignment: .topLeading) {
                ForEach(0..<layout.count, id: \.self) { tick in
                    Rectangle()
                        .fill(Double(tick) / Double(layout.count) < remainingFraction ? filledColor : ScratchTokens.sand.color,
                              style: FillStyle(antialiased: false))
                        .frame(width: layout.tickWidth, height: (8 * scale).rounded() / scale)
                        .offset(x: layout.x(for: tick, globalOrigin: origin.x),
                                y: layout.snappedOffset(globalOrigin: origin.y))
                }
            }
            .frame(width: width, height: 8, alignment: .topLeading)
        }
        .frame(width: width, height: 8, alignment: .leading)
        .accessibilityHidden(true)
    }
}
