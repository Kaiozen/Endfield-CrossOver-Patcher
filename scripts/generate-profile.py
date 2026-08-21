#!/usr/bin/env python3
from __future__ import annotations

import base64
import hashlib
import json
import pathlib
import plistlib
import sys

EXPECTED = ("20260717", "27.0.0.40734")
MODULES = [
    "x86_64-unix/ntdll.so",
    "x86_64-windows/ntdll.dll",
    "x86_64-windows/kernel32.dll",
    "x86_64-windows/ntoskrnl.exe",
]
EXPECTED_TARGETS = {
    "x86_64-unix/ntdll.so":
        "f51300212988de8d753d997e57f1e226ed8a97d7810529e8d13baf2313e8f83d",
    "x86_64-windows/ntdll.dll":
        "6b8dab5e4f32d95b33ac7b7ba1920de05ba2fbaa7111264afa4505cf0f04adb2",
    "x86_64-windows/kernel32.dll":
        "8acad669c3721d862953214ea719557c96e3ee587cdca50adddbbaaf31b35848",
    "x86_64-windows/ntoskrnl.exe":
        "43dffd0b1bc95df1d1c0a89489268047eddeb62cc7a69a90592023f3d1b8cfe2",
}


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def info(app: pathlib.Path) -> tuple[str, str]:
    obj = plistlib.loads(
        (app / "Contents/Info.plist").read_bytes()
    )
    return (
        str(obj.get("CFBundleShortVersionString", "")),
        str(obj.get("CFBundleVersion", "")),
    )


def root(app: pathlib.Path) -> pathlib.Path:
    return app / "Contents/SharedSupport/CrossOver/lib/wine"


def chunks(source: bytes, target: bytes) -> list[dict]:
    if len(source) != len(target):
        return [{
            "offset": 0,
            "removeCount": len(source),
            "replacementBase64":
                base64.b64encode(target).decode(),
        }]

    positions = [
        i for i, (a, b) in enumerate(
            zip(source, target)
        )
        if a != b
    ]

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
        "replacementBase64":
            base64.b64encode(
                target[start:end]
            ).decode(),
    } for start, end in groups]


def apply(source: bytes, module: dict) -> bytes:
    data = bytearray(source)
    for chunk in sorted(
        module["chunks"],
        key=lambda x: x["offset"],
        reverse=True
    ):
        off = chunk["offset"]
        count = chunk["removeCount"]
        repl = base64.b64decode(
            chunk["replacementBase64"]
        )
        data[off:off + count] = repl
    return bytes(data)


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: generate-profile.py "
            "STOCK_APP GOLDEN_R11_APP OUTPUT_JSON"
        )
        return 2

    stock = pathlib.Path(sys.argv[1])
    golden = pathlib.Path(sys.argv[2])
    out = pathlib.Path(sys.argv[3])

    for app, label in [
        (stock, "untouched Preview"),
        (golden, "golden R11")
    ]:
        if not app.is_dir():
            raise SystemExit(
                f"{label} app is missing: {app}"
            )

        version = info(app)
        if version != EXPECTED:
            raise SystemExit(
                f"{label} is {version[0]} / "
                f"{version[1]}, expected "
                f"{EXPECTED[0]} / {EXPECTED[1]}"
            )

    modules = []

    for rel in MODULES:
        source = (root(stock) / rel).read_bytes()
        target = (root(golden) / rel).read_bytes()

        target_hash = sha(target)
        if target_hash != EXPECTED_TARGETS[rel]:
            raise SystemExit(
                f"Golden R11 check failed for "
                f"{rel}: {target_hash}"
            )

        module = {
            "relativePath": rel,
            "sourceSHA256": sha(source),
            "targetSHA256": target_hash,
            "sourceSize": len(source),
            "targetSize": len(target),
            "chunks": chunks(source, target),
        }

        rebuilt = apply(source, module)
        if rebuilt != target or sha(rebuilt) != target_hash:
            raise SystemExit(
                f"Self-verification failed for {rel}"
            )

        modules.append(module)

        raw = sum(
            len(
                base64.b64decode(
                    c["replacementBase64"]
                )
            )
            for c in module["chunks"]
        )
        print(
            f"OK {rel}: "
            f"{len(module['chunks'])} ranges, "
            f"{raw / 1024:.1f} KiB replacement data"
        )

    profile = {
        "format": 1,
        "name":
            "Endfield CrossOver Preview 20260717 R11",
        "crossoverVersion": EXPECTED[0],
        "crossoverBuild": EXPECTED[1],
        "modules": modules,
    }

    out.write_text(
        json.dumps(profile, indent=2) + "\n"
    )

    print()
    print("Wrote:", out)
    print(
        "SHA-256:",
        hashlib.sha256(
            out.read_bytes()
        ).hexdigest()
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
