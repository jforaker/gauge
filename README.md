# Gauge

**SS–04 · AI usage · by Scratch Studios**

A quiet read on what remains. Native macOS menu bar readings for Codex and Claude subscription usage.

## Run

Requires macOS 14 or later and Swift 5.9 or later (Xcode Command Line Tools).

```sh
swift run Gauge
```

Build a standalone app:

```sh
bash scripts/build-app.sh
open dist/Gauge.app
```

## Provider login

Install the provider CLIs and sign in normally with `codex login` and `claude auth login`. Gauge launches those CLIs as your macOS user and reuses their existing authentication. It does not collect, copy, or store credentials. Finder launches discover the executable PATH through your login shell, with common install locations as fallbacks.

Custom `CODEX_HOME` and `CLAUDE_CONFIG_DIR` values are honored when present in Gauge's launch environment. Shell discovery imports PATH only; custom account variables set solely in shell startup files are not imported.

Codex is queried through its app-server JSON-RPC protocol (`account/rateLimits/read`). Claude is queried through its stream-JSON control protocol (`initialize`, then `get_usage` with `skip_behaviors`). No user prompt is submitted. Claude hooks are disabled, no tools are enabled, and the probe does not persist a conversation. These provider interfaces are experimental and may change with CLI updates.

Readings refresh on startup, every five minutes, after wake, and on manual refresh. If a refresh fails, the previous reading stays visible with a failure notice and its original timestamp. Countdown expiry does not fabricate a refreshed quota. API-key accounts may not report subscription limits.

## Verify

```sh
swift test
swift run Gauge --diagnose
```

The diagnostic command performs real account-usage reads and prints only quota percentages or a status message. No credentials or account identifiers are printed.

The app is distributed locally with ad-hoc signing. Developer ID signing, notarization, launch at login, account selection, and release packaging are future work.

## Design

Uses the generated Swift export from `jforaker/scratch-studios-design` at tag `v1.6.1` (commit `012fa7ae7c05ab04778bed9d2d7da50c9da86412`). Before building a fresh checkout, prepare the sibling repository:

```sh
git clone --branch v1.6.1 https://github.com/jforaker/scratch-studios-design.git ../scratch-studios-design
```

`Sources/Gauge/ScratchTokens.swift` is a relative symlink to `../scratch-studios-design/exports/swift/ScratchTokens.swift`; never edit it in Gauge. The design repo has no `Package.swift`. Barlow, IBM Plex Mono, and Cutive Mono are bundled with their SIL Open Font Licenses. Paper and Night follow the system appearance. Colors use shared tokens, including `gaugeAccent`, `ochre`, `clay`, and `sand`. Verdict cutoffs match the design repo's `quotaThresholds`: above 50% remaining is good, 20–50% fair, below 20% poor. The template menu-bar glyph has a separate live dot reflecting the lowest reading across providers and windows. The wordmark dot stays in the Gauge accent. Existing motion and Reduce Motion behavior are unchanged.

The app icon is built with `iconutil` from the ten full-bleed PNGs in `Sources/Gauge/Resources/Icons/gauge.iconset`, sourced unchanged from the same design release. The menu-bar PNGs are from that release's `icons/gauge/menubar`.

Render the actual SwiftUI panel in both appearances using live readings:

```sh
swift run Gauge --render-preview
```

Images are written to `.build/gauge-paper.png` and `.build/gauge-night.png`.

For deterministic verification without provider requests, use `--fixture 87`, `--fixture 40`, or `--fixture 10`. Add `--reduce-motion` to opt in to reduced motion without changing the macOS setting. Combine these with `--render-preview` to write Paper/Night captures of the actual SwiftUI popover to `docs/screenshots/`. Without `--render-preview`, fixtures run in the menu bar until quit. The override can only enable reduced motion; it cannot disable the system accessibility preference.
