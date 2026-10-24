# SS-04 refinement verification

Branch: `design/refine`. No push.

Follow-up preference: the menu-bar glyph uses native monochrome template rendering rather than verdict tinting. A separate NSStatusBarButton child view draws the verdict dot, based on the lowest reading. Night Slate is now #9AAFC6; Paper remains #4A5866. Both popover dots use the local accent token. This follow-up was rebuilt only, without launching, as requested. The captures below predate this Night Slate update; rerender before running the pixel verifier against the new expected value.

Tick geometry follow-up: all four readings use the same 164-point column width. At 1× and 2×, each bar contains 41 ticks of 2 points, separated by 2-point gaps: 162 points occupied and 2 points left at the trailing edge. Widths, gaps, and global tick positions are snapped to backing pixels, with antialiasing disabled on the rectangles. Nine tests now pass, including fractional-width/origin and backing-scale cases. The app was rebuilt without launching; the saved captures also predate this geometry change.

The layout, fonts, and UI copy are unchanged. The status dot is an overlay on the existing wordmark so it does not move neighboring content. Gauge selection is defined locally; there is no hover/selected row in the current panel to apply it to.

## Checks

- `swift test`: seven passing tests, covering provider parsing, exact verdict boundaries, lowest quota selection across providers/windows, and the 2.4-second pulse with Reduce Motion.
- `bash scripts/build-app.sh`: release app build and ad-hoc signing.
- Fixtures 87%, 40%, and 10% produce Slate, Ochre, and Clay respectively, with Sand idle ticks and ink numerals in both appearances.
- `swift scripts/verify-captures.swift` checks the exact encoded RGB samples for filled and idle ticks in all eight captures.
- `--fixture 40 --reduce-motion`: static live dot and zero-duration reading updates. This override exercises the same reduced-motion branch as the system accessibility setting without changing the user's settings.
- Native SwiftUI `ImageRenderer` captures of the actual panel are in `screenshots/`; these are panel renders, not desktop screenshots containing the macOS menu bar or window shadow.
- The rebuilt app was also run with real provider readings and inspected through native accessibility and a live popover screenshot.
- No Gauge view references `ScratchTokens.nominal`. Kelp values remain only in the unmodified vendored shared token catalog and generated shared definitions, which also describe the other studio apps.
- The only `.opacity` call in Gauge is the requested live-dot pulse. Filled and unfilled ticks use opaque tokens. The live pulse is the explicit 2.4-second exception to the 160 ms limit; other animated changes use 160 ms ease-out, or zero under Reduce Motion.
- No shadows, gradients, springs, or other looping animations are defined in the panel. macOS owns any surrounding system popover chrome.

## Reproduce panel captures

```sh
swift build
.build/debug/Gauge --fixture 87 --render-preview
.build/debug/Gauge --fixture 40 --render-preview
.build/debug/Gauge --fixture 10 --render-preview
.build/debug/Gauge --fixture 40 --reduce-motion --render-preview
swift scripts/verify-captures.swift
```
