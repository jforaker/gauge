import AppKit
import Combine
import SwiftUI
import GaugeCore

@MainActor
final class GaugeAppDelegate: NSObject, NSApplicationDelegate {
    private var store: UsageStore?
    private var statusController: GaugeStatusController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let store = UsageStore()
        self.store = store
        if !CommandLine.arguments.contains("--render-preview") && !CommandLine.arguments.contains("--diagnose") {
            statusController = GaugeStatusController(store: store)
        }
    }
}

@MainActor
final class GaugeStatusController: NSObject {
    private let item = NSStatusBar.system.statusItem(withLength: 40)
    private let popover = NSPopover()
    private let dot = GaugeVerdictDot(frame: NSRect(x: 33, y: 0, width: 4, height: 4))
    private var subscription: AnyCancellable?

    init(store: UsageStore) {
        super.init()
        guard let button = item.button else { return }
        let glyph = NSImage(size: NSSize(width: 22, height: 22))
        let appResources = Bundle.main.resourceURL.flatMap { Bundle(url: $0.appendingPathComponent("Gauge_Gauge.bundle")) }
        if let resources = (appResources ?? Bundle.module).resourceURL {
            for name in ["status-22", "status-22@2x"] {
                let url = resources.appendingPathComponent("Icons/\(name).png")
                if let data = try? Data(contentsOf: url),
                   let representation = NSBitmapImageRep(data: data) {
                    representation.size = NSSize(width: 22, height: 22)
                    glyph.addRepresentation(representation)
                }
            }
        }
        glyph.isTemplate = true
        button.image = glyph
        button.target = self
        button.action = #selector(togglePopover)
        button.setAccessibilityLabel("Gauge — AI usage")
        button.toolTip = "Gauge — AI usage"

        // Keep the badge separate: a composite non-template image would tint
        // the glyph and prevent macOS from choosing its menu-bar foreground.
        dot.frame.origin.y = (button.bounds.height - dot.frame.height) / 2
        dot.autoresizingMask = [.minYMargin, .maxYMargin]
        dot.isHidden = true
        dot.setAccessibilityElement(false)
        button.addSubview(dot)

        let host = NSHostingController(rootView: GaugePanel(store: store)
            .environment(\.gaugeReduceMotionOverride, CommandLine.arguments.contains("--reduce-motion")))
        host.sizingOptions = [.preferredContentSize]
        popover.contentViewController = host
        popover.contentSize = host.view.fittingSize
        popover.behavior = .transient
        popover.animates = false

        subscription = store.$snapshots.sink { [weak self] snapshots in
            let verdict = GaugeVerdict.combinedWeekly(in: Array(snapshots.values))
            self?.dot.token = verdict.map(GaugeTokens.color)
            self?.dot.isHidden = verdict == nil
        }
    }

    @objc private func togglePopover() {
        guard let button = item.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

private final class GaugeVerdictDot: NSView {
    var token: ScratchColor? { didSet { needsDisplay = true } }

    override func draw(_ dirtyRect: NSRect) {
        guard let token else { return }
        token.platform.setFill()
        NSBezierPath(ovalIn: bounds).fill()
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        needsDisplay = true
    }

    // The decorative badge must not intercept the status button's clicks.
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}
