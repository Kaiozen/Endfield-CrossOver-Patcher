#!/bin/bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Checking repository for files that must not be committed..."

bad=0

if find . \
  \( -name ".build" -o -name "DerivedData" -o -name "__pycache__" \) \
  -print | grep -q .; then
  echo "ERROR: development build/cache directory found."
  bad=1
fi

if find . -type f \
  \( -name "Endfield.exe" -o -name "ACE-BASE.sys" -o -name "Launcher.exe" \) \
  -print | grep -q .; then
  echo "ERROR: game/launcher binary found in source tree."
  bad=1
fi

if grep -RIn \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude=verify-source.sh \
  -E 'BEGIN (RSA|OPENSSH|EC) PRIVATE KEY|ghp_[A-Za-z0-9]{20,}|github_pat_' \
  . >/dev/null 2>&1; then
  echo "ERROR: possible secret detected."
  bad=1
fi

if [[ "$bad" != "0" ]]; then
  exit 1
fi

echo "Source hygiene: PASS"
