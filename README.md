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

Uses Scratch Studios v3 tokens, vendored from `scratch-studios-design/exports/swift/ScratchTokens.swift`, and the source token JSON. Barlow, IBM Plex Mono, and Cutive Mono are bundled with their SIL Open Font Licenses. Paper and Night follow the system appearance. Local `GaugeTokens` define Slate (Paper #4A5866, Night #9AAFC6) until SS-04 moves into the shared design system. Filled ticks use Slate above 50% remaining, Ochre from 20–50%, and Clay below 20%; unfilled ticks use Sand. Numerals stay in ink. The menu-bar glyph uses native template rendering (white on a dark menu bar); a separate dot beside it reflects the lowest quota's verdict. The wordmark status dot stays Slate; only the Slate live dot pulses, with a 2.4-second cycle, and it is static under Reduce Motion. Reading updates count over 160 ms, ease-out, or update immediately under Reduce Motion.

Render the actual SwiftUI panel in both appearances using live readings:

```sh
swift run Gauge --render-preview
```

Images are written to `.build/gauge-paper.png` and `.build/gauge-night.png`.

For deterministic verification without provider requests, use `--fixture 87`, `--fixture 40`, or `--fixture 10`. Add `--reduce-motion` to opt in to reduced motion without changing the macOS setting. Combine these with `--render-preview` to write Paper/Night captures of the actual SwiftUI popover to `docs/screenshots/`. Without `--render-preview`, fixtures run in the menu bar until quit. The override can only enable reduced motion; it cannot disable the system accessibility preference.
