# Supported versions

## First release target

The first public compatibility profile targets exactly:

```text
CrossOver Preview: 20260717
CFBundleVersion: 27.0.0.40734
Wine: 11.12
Architecture: x86_64 through Rosetta 2
Graphics: D3DMetal
Sync: MSync
Renderer: DirectX 11
```

The app rejects other CrossOver builds before patching.

## Why exact-build support matters

This project changes version-specific Wine modules in a private runtime copy. Offsets and bytes that are correct for one build are not assumed to be correct for another.

A new build is supported only after:

1. the game reaches real gameplay, not merely the launcher;
2. the generated compatibility profile reproduces the reviewed target hashes;
3. a cold launch from normal CrossOver Preview succeeds;
4. another bottle remains unaffected;
5. Repair and Remove Setup are tested.

## July 31, 2026 ARM64 Preview

CodeWeavers' first macOS ARM64 Preview is an experimental architecture change, not a routine update to the July 17 configuration. CodeWeavers currently documents important limitations, including no D3DMetal and game launchers that may not work.

Reference:
https://www.codeweavers.com/blog/mjohnson/2026/7/31/crossover-preview-the-right-to-bear-arm64-on-mac

The initial Endfield profile therefore stays on the proven x86_64/Rosetta path until the newer architecture is separately investigated and tested.
