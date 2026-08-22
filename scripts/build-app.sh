#!/bin/bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP="$ROOT/dist/Endfield for CrossOver.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RES="$CONTENTS/Resources"

rm -rf "$APP"
mkdir -p "$MACOS" "$RES/Profiles" "$RES/Legal"

echo "Building Swift release binaries..."
swift build -c release --product EndfieldPatcher
swift build -c release --product EndfieldMenuHelper

BIN_PATH="$(swift build -c release --show-bin-path)"
cp "$BIN_PATH/EndfieldPatcher" "$MACOS/EndfieldPatcher"
cp "$BIN_PATH/EndfieldMenuHelper" "$RES/EndfieldMenuHelper"
chmod +x "$MACOS/EndfieldPatcher" "$RES/EndfieldMenuHelper"

PROFILES=(
  "$ROOT/Resources/Profiles/endfield-preview-20260717-r11.profile.json"
  "$ROOT/Resources/Profiles/endfield-stable-26.3-finewine.profile.json"
)
for PROFILE in "${PROFILES[@]}"; do
  if [[ ! -f "$PROFILE" ]]; then
    echo "ERROR: verified Endfield compatibility recipe is missing:" >&2
    echo "  $PROFILE" >&2
    echo "Refusing to build an incomplete Stable + Preview app." >&2
    exit 1
  fi
  cp "$PROFILE" "$RES/Profiles/"
done

HOOK_SOURCE="$ROOT/Resources/GreenButton/EndfieldGreenButton.m"
HOOK="$RES/EndfieldGreenButton.dylib"

if [[ ! -f "$HOOK_SOURCE" ]]; then
  echo "ERROR: macOS fullscreen helper source is missing:" >&2
  echo "  $HOOK_SOURCE" >&2
  exit 1
fi

echo "Building the Endfield macOS fullscreen helper..."
SDK="$(xcrun --sdk macosx --show-sdk-path)"

xcrun --sdk macosx clang \
  -arch x86_64 \
  -dynamiclib \
  -fobjc-arc \
  -fblocks \
  -mmacosx-version-min=14.0 \
  -isysroot "$SDK" \
  -framework AppKit \
  -framework Foundation \
  -install_name "@loader_path/EndfieldGreenButton.dylib" \
  "$HOOK_SOURCE" \
  -o "$HOOK"

codesign --force --sign - "$HOOK"
file "$HOOK" | grep -q 'x86_64'

cp "$ROOT/LICENSE" "$RES/Legal/PROJECT-LICENSE.txt"
cp "$ROOT/LICENSES/LGPL-2.1.txt" "$RES/Legal/LGPL-2.1.txt"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$RES/Legal/THIRD-PARTY-NOTICES.md"
cp "$ROOT/docs/WINE-SOURCE.md" "$RES/Legal/WINE-SOURCE.md"

cp "$ROOT/Resources/Branding/BrandFull.png" "$RES/BrandFull.png"
cp "$ROOT/Resources/Branding/EndfieldBrand.icns" "$RES/EndfieldBrand.icns"

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
  <string>1.2.0</string>
  <key>CFBundleVersion</key>
  <string>8</string>
  <key>CFBundleIconFile</key>
  <string>EndfieldBrand</string>
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
