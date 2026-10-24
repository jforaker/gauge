import AppKit
import SwiftUI
import GaugeCore
import CoreText

@main
struct GaugeApp: App {
    @StateObject private var store = UsageStore()

    init() {
        let appResources = Bundle.main.resourceURL.flatMap { Bundle(url: $0.appendingPathComponent("Gauge_Gauge.bundle")) }
        if let resources = (appResources ?? Bundle.module).resourceURL,
           let files = FileManager.default.enumerator(at: resources, includingPropertiesForKeys: nil) {
            for case let url as URL in files where url.pathExtension == "ttf" {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra {
            GaugePanel(store: store)
        } label: {
            Image(systemName: "gauge.with.dots.needle.33percent")
                .accessibilityLabel("Gauge — AI usage")
        }
        .menuBarExtraStyle(.window)
    }
}

@MainActor
final class UsageStore: ObservableObject {
    @Published var snapshots: [Provider: UsageSnapshot] = [:]
    @Published var failures: [Provider: String] = [:]
    @Published var refreshing = false
    private var timer: Timer?

    init() {
        if CommandLine.arguments.contains("--diagnose") || CommandLine.arguments.contains("--render-preview") {
            Task {
                for provider in Provider.allCases {
                    let snapshot = await ProviderClient.read(provider)
                    snapshots[provider] = snapshot
                    print("\(provider.rawValue): \(snapshot.message ?? snapshot.windows.map { "\($0.label) \($0.remainingPercent)% left" }.joined(separator: ", "))")
                }
                if CommandLine.arguments.contains("--render-preview") {
                    for scheme in [ColorScheme.light, .dark] {
                        let renderer = ImageRenderer(content: GaugePanel(store: self).environment(\.colorScheme, scheme))
                        renderer.scale = 2
                        if let image = renderer.nsImage, let tiff = image.tiffRepresentation,
                           let bitmap = NSBitmapImageRep(data: tiff), let png = bitmap.representation(using: .png, properties: [:]) {
                            let path = FileManager.default.currentDirectoryPath + "/.build/gauge-\(scheme == .dark ? "night" : "paper").png"
                            try? png.write(to: URL(fileURLWithPath: path))
                            print("Rendered \(path)")
                        }
                    }
                }
                NSApplication.shared.terminate(nil)
            }
        } else {
            Task { await refresh() }
            timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
                Task { await self?.refresh() }
            }
            NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
                Task { await self?.refresh() }
            }
        }
    }

    func refresh() async {
        guard !refreshing else { return }
        refreshing = true
        await withTaskGroup(of: UsageSnapshot.self) { group in
            for provider in Provider.allCases { group.addTask { await ProviderClient.read(provider) } }
            for await snapshot in group {
                if let error = snapshot.message, let previous = snapshots[snapshot.provider], !previous.windows.isEmpty {
                    failures[snapshot.provider] = error
                } else {
                    snapshots[snapshot.provider] = snapshot
                    failures[snapshot.provider] = nil
                }
            }
        }
        refreshing = false
    }
}

struct GaugePanel: View {
    @ObservedObject var store: UsageStore
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("GAUGE").font(ScratchType.mark.font).tracking(ScratchType.mark.tracking)
                Spacer()
                Text("SS–04").font(ScratchType.label.font).tracking(1.76).foregroundStyle(ScratchTokens.label.color)
            }
            .padding(.bottom, 8)
            Text("AI USAGE").font(ScratchType.label.font).tracking(1.76).foregroundStyle(ScratchTokens.label.color)
            rule.padding(.top, 24)

            TimelineView(.periodic(from: .now, by: 30)) { context in
                VStack(spacing: 0) {
                    ForEach(Provider.allCases) { provider in
                        providerSection(provider, now: context.date)
                        rule
                    }
                }
            }

            HStack {
                Circle().fill(ScratchTokens.ink.color).frame(width: 4, height: 4)
                Text(store.refreshing ? "READING PROVIDERS" : "REFRESHES EVERY 5 MIN")
                    .font(.custom("IBMPlexMono-Regular", size: 10)).tracking(1.6).foregroundStyle(ScratchTokens.label.color)
                Spacer()
                Button {
                    Task { await store.refresh() }
                } label: { Image(systemName: "arrow.clockwise").font(.system(size: 12)) }
                    .disabled(store.refreshing)
                    .help("Refresh provider usage")
                    .accessibilityLabel("Refresh provider usage")
            }
            .padding(.top, 16)
            HStack {
                Text("by Scratch Studios").font(ScratchType.small.font).foregroundStyle(ScratchTokens.inkSoft.color)
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
                    .font(ScratchType.small.font).foregroundStyle(ScratchTokens.inkSoft.color)
                    .keyboardShortcut("q")
            }
            .padding(.top, 16)
        }
        .buttonStyle(.plain)
        .padding(24)
        .frame(width: 400)
        .foregroundStyle(ScratchTokens.ink.color)
        .background(ScratchTokens.ground.color)
    }

    private var rule: some View { Rectangle().fill(ScratchTokens.rule.color).frame(height: 1 / displayScale) }

    private func providerSection(_ provider: Provider, now: Date) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(provider.rawValue.uppercased()).font(ScratchType.label.font).tracking(1.76)
                Spacer()
                if let snapshot = store.snapshots[provider], !snapshot.windows.isEmpty {
                    Text("READ \(snapshot.checkedAt, style: .time)")
                        .font(.custom("IBMPlexMono-Regular", size: 10)).tracking(1).foregroundStyle(ScratchTokens.label.color)
                }
            }
            if let snapshot = store.snapshots[provider] {
                HStack(alignment: .top, spacing: 24) {
                    ForEach(snapshot.windows) { window in
                        windowRow(window, now: now).frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                if let message = store.failures[provider] ?? snapshot.message {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(store.failures[provider] == nil ? message : "LAST READING · \(message)")
                            .font(ScratchType.small.font).lineSpacing(3).foregroundStyle(ScratchTokens.inkSoft.color)
                        if snapshot.windows.isEmpty {
                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(provider.loginCommand, forType: .string)
                            } label: {
                                Label("Copy login command", systemImage: "doc.on.doc").font(ScratchType.small.font)
                            }
                        }
                    }
                }
            } else {
                Text("Taking the first reading.").font(ScratchType.small.font).foregroundStyle(ScratchTokens.inkSoft.color)
                    .padding(.vertical, 12)
            }
        }
        .padding(.vertical, 24)
    }

    private func windowRow(_ window: UsageWindow, now: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(window.label.uppercased()).font(ScratchType.label.font).tracking(1.76).foregroundStyle(ScratchTokens.label.color)
            HStack(alignment: .firstTextBaseline) {
                Text("\(window.remainingPercent)").font(ScratchType.numeralMono.font).tracking(-1.12)
                Text("% LEFT").font(ScratchType.label.font).tracking(1.76).foregroundStyle(ScratchTokens.inkSoft.color)
            }
            HStack(spacing: 4) {
                ForEach(0..<25, id: \.self) { tick in
                    Rectangle()
                        .fill(Double(tick) / 25 < 1 - window.usedPercent / 100 ? readingColor(window) : ScratchTokens.sand.color)
                        .frame(height: 8)
                }
            }
            .accessibilityHidden(true)
            if let reset = window.resetsAt {
                Text(resetLabel(reset, now: now)).font(.custom("IBMPlexMono-Regular", size: 10)).tracking(1.6).foregroundStyle(ScratchTokens.label.color)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func readingColor(_ window: UsageWindow) -> Color {
        window.remainingPercent <= 10 ? ScratchTokens.clay.color : window.remainingPercent <= 25 ? ScratchTokens.ochre.color : ScratchTokens.nominal.color
    }

    private func resetLabel(_ date: Date, now: Date) -> String {
        let minutes = max(0, Int(ceil(date.timeIntervalSince(now) / 60)))
        if minutes == 0 { return "RESET DUE" }
        let days = minutes / 1440, hours = minutes % 1440 / 60
        return "RESET " + (days > 0 ? "\(days)D \(hours)H" : hours > 0 ? "\(hours)H \(minutes % 60)M" : "\(minutes)M")
    }
}
