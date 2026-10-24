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

Uses Scratch Studios v3 tokens, vendored from `scratch-studios-design/exports/swift/ScratchTokens.swift`, and the source token JSON. Barlow, IBM Plex Mono, and Cutive Mono are bundled with their SIL Open Font Licenses. Paper and Night follow the system appearance. Progress ticks use Kelp (`nominal`) above 25% remaining, Ochre at 25% or less, and Clay at 10% or less. Unfilled ticks use Sand. Numerals and status remain neutral ink.

Render the actual SwiftUI panel in both appearances using live readings:

```sh
swift run Gauge --render-preview
```

Images are written to `.build/gauge-paper.png` and `.build/gauge-night.png`.
