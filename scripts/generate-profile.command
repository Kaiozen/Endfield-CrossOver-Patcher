#!/bin/bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STOCK="$HOME/Applications/CrossOver Preview.app"
GOLDEN="$HOME/Applications/CrossOver Endfield Preview R11.app"
OUT="$HOME/Desktop/endfield-preview-20260717-r11.profile.json"

echo
echo "Endfield R11 compatibility profile"
echo
echo "This reads the untouched Preview app and the known-good R11 app."
echo "It does not modify either app."
echo

python3 \
  "$ROOT/scripts/generate-profile.py" \
  "$STOCK" \
  "$GOLDEN" \
  "$OUT"

echo
echo "Do not publish the profile until its source/target hashes and licensing"
echo "have been reviewed."
