#!/usr/bin/env python3
from __future__ import annotations

import base64
import hashlib
import json
import pathlib
import plistlib
import sys

MODULES = [
    "x86_64-unix/ntdll.so",
    "x86_64-windows/kernel32.dll",
    "x86_64-windows/ntoskrnl.exe",
]


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def info(app: pathlib.Path) -> tuple[str, str]:
    obj = plistlib.loads((app / "Contents/Info.plist").read_bytes())
    return (
        str(obj.get("CFBundleShortVersionString", "")),
        str(obj.get("CFBundleVersion", "")),
    )


def source_root(app: pathlib.Path) -> pathlib.Path:
    return app / "Contents/SharedSupport/CrossOver/lib/wine"


def chunks(source: bytes, target: bytes) -> list[dict]:
    if len(source) != len(target):
        return [{
            "offset": 0,
            "removeCount": len(source),
            "replacementBase64": base64.b64encode(target).decode(),
        }]

    positions = [i for i, (a, b) in enumerate(zip(source, target)) if a != b]
    if not positions:
        return []

    groups = []
    start = prev = positions[0]
    for pos in positions[1:]:
        if pos - prev <= 33:
            prev = pos
            continue
        groups.append((start, prev + 1))
        start = prev = pos
    groups.append((start, prev + 1))

    return [{
        "offset": start,
        "removeCount": end - start,
        "replacementBase64": base64.b64encode(target[start:end]).decode(),
    } for start, end in groups]


def apply(source: bytes, module: dict) -> bytes:
    data = bytearray(source)
    for chunk in sorted(module["chunks"], key=lambda x: x["offset"], reverse=True):
        off = chunk["offset"]
        count = chunk["removeCount"]
        replacement = base64.b64decode(chunk["replacementBase64"])
        data[off:off + count] = replacement
    return bytes(data)


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: generate-stable-profile.py STOCK_APP TARGET_MODULE_ROOT OUTPUT_JSON")
        return 2

    stock = pathlib.Path(sys.argv[1])
    targets = pathlib.Path(sys.argv[2])
    out = pathlib.Path(sys.argv[3])

    version, build = info(stock)
    if not version.startswith("26.3"):
        raise SystemExit(f"stock Stable app is {version} / {build}, expected CrossOver 26.3")

    modules = []
    for rel in MODULES:
        source = (source_root(stock) / rel).read_bytes()
        target = (targets / rel).read_bytes()
        module = {
            "relativePath": rel,
            "sourceSHA256": sha(source),
            "targetSHA256": sha(target),
            "sourceSize": len(source),
            "targetSize": len(target),
            "chunks": chunks(source, target),
        }
        rebuilt = apply(source, module)
        if rebuilt != target or sha(rebuilt) != module["targetSHA256"]:
            raise SystemExit(f"self-verification failed for {rel}")
        modules.append(module)
        payload = sum(len(base64.b64decode(c["replacementBase64"])) for c in module["chunks"])
        print(f"OK {rel}: {len(module['chunks'])} ranges, {payload/1024:.1f} KiB replacement data")

    profile = {
        "format": 1,
        "name": "Endfield CrossOver Stable 26.3 FineWine",
        "crossoverVersion": version,
        "crossoverBuild": build,
        "modules": modules,
    }
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(profile, indent=2) + "\n")
    print("Wrote:", out)
    print("SHA-256:", hashlib.sha256(out.read_bytes()).hexdigest())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
