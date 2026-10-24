#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift build -c release
APP="$(pwd)/dist/Gauge.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/Gauge "$APP/Contents/MacOS/Gauge"
rm -rf "$APP/Contents/Resources/Gauge_Gauge.bundle"
cp -R .build/release/Gauge_Gauge.bundle "$APP/Contents/Resources/"
rm -f "$APP/Contents/Resources/gauge-b2.icns"
iconutil -c icns Sources/Gauge/Resources/Icons/gauge.iconset -o "$APP/Contents/Resources/gauge.icns"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Gauge</string>
<key>CFBundleDisplayName</key><string>Gauge</string>
<key>CFBundleIdentifier</key><string>studio.scratch.gauge</string>
<key>CFBundleExecutable</key><string>Gauge</string>
<key>CFBundleIconFile</key><string>gauge.icns</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$APP"
printf 'Built %s\n' "$APP"
