// Scratch Studios Design System — tokens for Swift (AppKit, UIKit, SwiftUI).
// Generated from tokens.json (v3). Do not edit by hand: change the design system, then regenerate.
//
// Colors are dynamic: they resolve Paper or Night from the effective appearance.
// To force a theme, set NSApp.appearance (macOS) or overrideUserInterfaceStyle (iOS)
// with ScratchTheme; to follow the system, set it to nil.
import SwiftUI
#if canImport(AppKit)
import AppKit
public typealias ScratchPlatformColor = NSColor
public typealias ScratchPlatformFont = NSFont
#elseif canImport(UIKit)
import UIKit
public typealias ScratchPlatformColor = UIColor
public typealias ScratchPlatformFont = UIFont
#endif

public struct ScratchRGBA {
    public let r: Double, g: Double, b: Double, a: Double
    public init(_ r: Int, _ g: Int, _ b: Int, _ a: Double) {
        self.r = Double(r) / 255; self.g = Double(g) / 255; self.b = Double(b) / 255; self.a = a
    }
}

/// The user's Theme setting: System · Paper · Night.
public enum ScratchTheme: String, CaseIterable {
    case system, paper, night

#if canImport(AppKit)
    /// Value for NSApp.appearance. nil follows the system.
    public var appearance: NSAppearance? {
        switch self {
        case .system: return nil
        case .paper: return NSAppearance(named: .aqua)
        case .night: return NSAppearance(named: .darkAqua)
        }
    }
#endif
#if canImport(UIKit)
    public var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .paper: return .light
        case .night: return .dark
        }
    }
#endif
}

/// One token: a Paper value and a Night value, resolved from the appearance at draw time.
public struct ScratchColor {
    public let paper: ScratchRGBA
    public let night: ScratchRGBA
    public init(_ paper: ScratchRGBA, _ night: ScratchRGBA) { self.paper = paper; self.night = night }

    public var platform: ScratchPlatformColor {
        let paper = self.paper, night = self.night
        func make(_ c: ScratchRGBA) -> ScratchPlatformColor {
            ScratchPlatformColor(red: c.r, green: c.g, blue: c.b, alpha: c.a)
        }
#if canImport(AppKit)
        return NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? make(night) : make(paper)
        }
#else
        return UIColor { traits in traits.userInterfaceStyle == .dark ? make(night) : make(paper) }
#endif
    }

    public var color: Color {
#if canImport(AppKit)
        return Color(nsColor: platform)
#else
        return Color(uiColor: platform)
#endif
    }
}

public enum ScratchTokens {
    /** Page ground. Paper by day, Night by night. */
    public static let ground = ScratchColor(ScratchRGBA(246, 245, 241, 1), ScratchRGBA(17, 17, 16, 1))
    /** Raised layer: Card on paper, Graphite on night (sidebars). Separated from ground by a ground shift and a hairline, never a shadow. */
    public static let raised = ScratchColor(ScratchRGBA(252, 251, 248, 1), ScratchRGBA(28, 28, 26, 1))
    /** Recessed track behind a segmented control or stepper, a step below the ground. The selected segment sits on raised. */
    public static let track = ScratchColor(ScratchRGBA(237, 234, 227, 1), ScratchRGBA(11, 11, 10, 1))
    /** Primary text, headings and numerals. 16.6:1 on paper, 15.7:1 on night. */
    public static let ink = ScratchColor(ScratchRGBA(22, 22, 22, 1), ScratchRGBA(236, 234, 228, 1))
    /** Secondary text: descriptions, units beside a numeral, inactive segments. 8.4:1 on paper, 8.9:1 on night. */
    public static let inkSoft = ScratchColor(ScratchRGBA(74, 72, 67, 1), ScratchRGBA(181, 178, 170, 1))
    /** Mono labels and metadata (Stone on paper, Ash on night). 4.5:1 and 5.5:1: small caps labels only, never body text. */
    public static let label = ScratchColor(ScratchRGBA(115, 112, 106, 1), ScratchRGBA(140, 138, 132, 1))
    /** 1px hairlines between rows, blocks and panels. Full rules divide; partial edges never highlight. */
    public static let rule = ScratchColor(ScratchRGBA(22, 22, 22, 0.12), ScratchRGBA(255, 255, 255, 0.1))
    /** 1px outline of a control: pills, secondary buttons, steppers, the edges of a window. */
    public static let ruleStrong = ScratchColor(ScratchRGBA(22, 22, 22, 0.2), ScratchRGBA(255, 255, 255, 0.2))
    /** Idle marks: empty rating dots, unfilled progress ticks. */
    public static let sand = ScratchColor(ScratchRGBA(216, 211, 201, 1), ScratchRGBA(58, 57, 53, 1))
    /** Kelp. Break's instrument accent: chart line, live dot, the status dot on the mark, and 'good' on Break's verdicts. Text, 1px lines and dots only. 5.5:1 on paper, 7.9:1 on night. */
    public static let nominal = ScratchColor(ScratchRGBA(76, 106, 85, 1), ScratchRGBA(147, 174, 152, 1))
    /** Selected row or cell ground in Break. Never an edge highlight. */
    public static let nominalSelection = ScratchColor(ScratchRGBA(232, 234, 229, 1), ScratchRGBA(33, 36, 32, 1))
    /** Peak of the chart fade under a nominal line. Fades to nothing at the baseline. */
    public static let nominalChartFill = ScratchColor(ScratchRGBA(212, 217, 210, 1), ScratchRGBA(43, 48, 43, 1))
    /** Olive phosphor, after a P1 scope trace. Trace's instrument accent: chart line, sparklines, live dot, progress ticks, and 'good' on Trace's verdicts. 5.4:1 on paper, 9.7:1 on night. */
    public static let phosphor = ScratchColor(ScratchRGBA(92, 107, 36, 1), ScratchRGBA(179, 192, 122, 1))
    /** Selected row or nav item ground in Trace. Never an edge highlight. */
    public static let phosphorSelection = ScratchColor(ScratchRGBA(234, 234, 225, 1), ScratchRGBA(36, 38, 29, 1))
    /** Peak of the chart fade under a phosphor line. */
    public static let phosphorChartFill = ScratchColor(ScratchRGBA(215, 217, 200, 1), ScratchRGBA(49, 52, 37, 1))
    /** Cyanotype. Scratch's accent: links, cursor, current state. 7.0:1 on paper, 8.1:1 on night. */
    public static let scratchAccent = ScratchColor(ScratchRGBA(47, 88, 114, 1), ScratchRGBA(142, 174, 196, 1))
    /** Selected note or row ground in Scratch. Never an edge highlight. */
    public static let scratchSelection = ScratchColor(ScratchRGBA(230, 232, 231, 1), ScratchRGBA(32, 36, 38, 1))
    /** Peak of the chart fade under a cyanotype line. */
    public static let scratchChartFill = ScratchColor(ScratchRGBA(206, 214, 216, 1), ScratchRGBA(42, 48, 52, 1))
    /** Ground of a marked span: Break's best window, Trace's test interval, a found match in Scratch. Always bounded by a rule-strong hairline at each edge; labels sit outside it. */
    public static let window = ScratchColor(ScratchRGBA(231, 228, 221, 1), ScratchRGBA(36, 34, 30, 1))
    /** Verdict 'fair' in every instrument. 5.6:1 on paper, 6.5:1 on night. */
    public static let ochre = ScratchColor(ScratchRGBA(124, 93, 41, 1), ScratchRGBA(178, 147, 98, 1))
    /** Verdict 'poor', the Stop ring, and the only signal for a destructive action (clay text, never a red panel). 4.9:1 on paper, 6.4:1 on night. */
    public static let clay = ScratchColor(ScratchRGBA(160, 88, 63, 1), ScratchRGBA(197, 135, 111, 1))
    /** Studio accent. Studio surfaces only (site, guide), never inside an app. 7.6:1 on paper, 8.8:1 on night. */
    public static let survey = ScratchColor(ScratchRGBA(51, 74, 148, 1), ScratchRGBA(160, 177, 219, 1))
    /** Text selection on studio surfaces only. */
    public static let surveyWash = ScratchColor(ScratchRGBA(219, 221, 228, 1), ScratchRGBA(42, 48, 66, 1))

    /** Scratch (SS-03) instrument: its accent and the two grounds tinted from it. */
    public static let accent = scratchAccent
    public static let selection = scratchSelection
    public static let chartFill = scratchChartFill
}

#if canImport(AppKit)
/// Objective-C access for AppKit views (`SSTokens.ink`). Colors are dynamic, like the Swift ones.
@objc(SSTokens) public final class ScratchObjCTokens: NSObject {
    @objc public static let ground: NSColor = ScratchTokens.ground.platform
    @objc public static let raised: NSColor = ScratchTokens.raised.platform
    @objc public static let track: NSColor = ScratchTokens.track.platform
    @objc public static let ink: NSColor = ScratchTokens.ink.platform
    @objc public static let inkSoft: NSColor = ScratchTokens.inkSoft.platform
    @objc public static let label: NSColor = ScratchTokens.label.platform
    @objc public static let rule: NSColor = ScratchTokens.rule.platform
    @objc public static let ruleStrong: NSColor = ScratchTokens.ruleStrong.platform
    @objc public static let sand: NSColor = ScratchTokens.sand.platform
    @objc public static let nominal: NSColor = ScratchTokens.nominal.platform
    @objc public static let nominalSelection: NSColor = ScratchTokens.nominalSelection.platform
    @objc public static let nominalChartFill: NSColor = ScratchTokens.nominalChartFill.platform
    @objc public static let phosphor: NSColor = ScratchTokens.phosphor.platform
    @objc public static let phosphorSelection: NSColor = ScratchTokens.phosphorSelection.platform
    @objc public static let phosphorChartFill: NSColor = ScratchTokens.phosphorChartFill.platform
    @objc public static let scratchAccent: NSColor = ScratchTokens.scratchAccent.platform
    @objc public static let scratchSelection: NSColor = ScratchTokens.scratchSelection.platform
    @objc public static let scratchChartFill: NSColor = ScratchTokens.scratchChartFill.platform
    @objc public static let window: NSColor = ScratchTokens.window.platform
    @objc public static let ochre: NSColor = ScratchTokens.ochre.platform
    @objc public static let clay: NSColor = ScratchTokens.clay.platform
    @objc public static let survey: NSColor = ScratchTokens.survey.platform
    @objc public static let surveyWash: NSColor = ScratchTokens.surveyWash.platform

    /// Apply the Theme setting ("system", "paper" or "night") to the whole app, so every
    /// native view resolves the same Paper or Night values as the React Native side.
    @objc public static func applyTheme(_ name: String) {
        NSApp?.appearance = (ScratchTheme(rawValue: name) ?? .system).appearance
    }
}
#endif

/// PostScript names of the bundled font files, by weight.
public enum ScratchFonts {
    public static let grotesk: [Int: String] = [300: "Barlow-Light", 400: "Barlow-Regular", 500: "Barlow-Medium"]
    public static let mark: [Int: String] = [400: "CutiveMono-Regular"]
    public static let mono: [Int: String] = [300: "IBMPlexMono-Light", 400: "IBMPlexMono-Regular", 500: "IBMPlexMono-Medium"]
    public static let personal: [Int: String] = [400: "CourierPrime-Regular"]
}

public struct ScratchTextStyle {
    public let face: String
    public let size: CGFloat
    public let lineHeight: CGFloat
    public let tracking: CGFloat
    public var platformFont: ScratchPlatformFont {
        ScratchPlatformFont(name: face, size: size) ?? ScratchPlatformFont.systemFont(ofSize: size)
    }
    public var font: Font { Font.custom(face, fixedSize: size) }
}

public enum ScratchType {
    public static let numeralXl = ScratchTextStyle(face: ScratchFonts.grotesk[300]!, size: 112, lineHeight: 112, tracking: -3.36)
    public static let numeralL = ScratchTextStyle(face: ScratchFonts.grotesk[300]!, size: 60, lineHeight: 60, tracking: 0)
    public static let numeralMono = ScratchTextStyle(face: ScratchFonts.mono[300]!, size: 56, lineHeight: 56, tracking: -1.12)
    public static let title = ScratchTextStyle(face: ScratchFonts.grotesk[400]!, size: 36, lineHeight: 41, tracking: 0)
    public static let mark = ScratchTextStyle(face: ScratchFonts.mark[400]!, size: 24, lineHeight: 24, tracking: 10.08)
    public static let place = ScratchTextStyle(face: ScratchFonts.grotesk[500]!, size: 18, lineHeight: 22, tracking: 2.52)
    public static let heading = ScratchTextStyle(face: ScratchFonts.grotesk[400]!, size: 22, lineHeight: 29, tracking: 0)
    public static let body = ScratchTextStyle(face: ScratchFonts.grotesk[400]!, size: 15, lineHeight: 23, tracking: 0)
    public static let small = ScratchTextStyle(face: ScratchFonts.grotesk[400]!, size: 13, lineHeight: 20, tracking: 0)
    public static let label = ScratchTextStyle(face: ScratchFonts.mono[400]!, size: 11, lineHeight: 15, tracking: 1.76)
}

public enum ScratchSpace {
    public static let s1: CGFloat = 4 // Base unit. Gap between a numeral and its unit.
    public static let s2: CGFloat = 8 // Label to value.
    public static let s3: CGFloat = 12 // Row padding, tight.
    public static let s4: CGFloat = 16 // Row padding, default; mobile side gutter.
    public static let s6: CGFloat = 24 // Between blocks.
    public static let s8: CGFloat = 32 // Between blocks, roomy.
    public static let s12: CGFloat = 48 // Between sections.
    public static let s16: CGFloat = 64 // Between sections, roomy.
}

public enum ScratchRadius {
    public static let none: CGFloat = 0 // Panels, rows, cells, charts.
    public static let sm: CGFloat = 2 // Small controls.
    public static let md: CGFloat = 7 // Desktop controls: segmented controls, steppers, secondary buttons.
    public static let round: CGFloat = 999 // Pills, dots and ring buttons.
}
