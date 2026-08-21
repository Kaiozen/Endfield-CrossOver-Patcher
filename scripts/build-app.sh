#!/bin/bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP="$ROOT/dist/Endfield for CrossOver.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RES="$CONTENTS/Resources"

rm -rf "$APP"
mkdir -p "$MACOS" "$RES/Profiles"

echo "Building Swift release binaries..."
swift build -c release --product EndfieldPatcher
swift build -c release --product EndfieldMenuHelper

BIN_PATH="$(swift build -c release --show-bin-path)"
cp "$BIN_PATH/EndfieldPatcher" "$MACOS/EndfieldPatcher"
cp "$BIN_PATH/EndfieldMenuHelper" "$RES/EndfieldMenuHelper"
chmod +x "$MACOS/EndfieldPatcher" "$RES/EndfieldMenuHelper"

PROFILE="$ROOT/Resources/Profiles/endfield-preview-20260717-r11.profile.json"
if [[ -f "$PROFILE" ]]; then
  cp "$PROFILE" "$RES/Profiles/"
else
  echo "NOTE: release R11 profile is not present."
  echo "The app will build, but setup will remain disabled."
fi

cat > "$CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>EndfieldPatcher</string>
  <key>CFBundleIdentifier</key>
  <string>com.kaiozen.EndfieldCrossOverPatcher</string>
  <key>CFBundleName</key>
  <string>Endfield for CrossOver</string>
  <key>CFBundleDisplayName</key>
  <string>Endfield for CrossOver</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0-dev</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP"

echo
echo "Built:"
echo "  $APP"
