# Validation

This is what I actually tested before publishing v1.0.0.

## Supported setup

```text
CrossOver Preview: 20260717
Build: 27.0.0.40734
Wine: 11.12
Mac: Apple Silicon
Rosetta 2
D3DMetal
MSync
DirectX 11
Bottle name: Arknights Endfield
```

## The clean-slate test

Before calling the patcher stable, I removed the old Endfield bottle and the
old generated GRYPHLINK helper.

Then I:

1. created a brand-new Windows 11 64-bit bottle named `Arknights Endfield`;
2. installed GRYPHLINK;
3. installed Arknights: Endfield through GRYPHLINK;
4. opened GRYPHLINK once through normal CrossOver Preview;
5. opened Endfield for CrossOver;
6. clicked Set Up Endfield;
7. launched the game through normal CrossOver Preview -> GRYPHLINK -> Play.

The patch completed and the game worked from the fresh setup.

## macOS green fullscreen button

I tested the Endfield-only window fix with the game in Windowed mode. The macOS green button became active and native fullscreen worked.

The exact tested private macOS Wine driver was:

```text
lib/wine/x86_64-unix/winemac.so
6b88de59d3c32ccd43b6a0a54097b8da0cf225eef9ccf0598be142ce95a5d43d
```

v1.1.0 builds the same proven hook into the app. The patcher checks that exact driver before changing it.

## Compatibility recipe

Release profile SHA-256:

```text
2babcd451a5e8ade5ec58ab10d0eb6bfa0ba15dc1d2458fd0ce2ff2151782a70
```

Known-good target hashes:

```text
x86_64-unix/ntdll.so
f51300212988de8d753d997e57f1e226ed8a97d7810529e8d13baf2313e8f83d

x86_64-windows/ntdll.dll
6b8dab5e4f32d95b33ac7b7ba1920de05ba2fbaa7111264afa4505cf0f04adb2

x86_64-windows/kernel32.dll
8acad669c3721d862953214ea719557c96e3ee587cdca50adddbbaaf31b35848

x86_64-windows/ntoskrnl.exe
43dffd0b1bc95df1d1c0a89489268047eddeb62cc7a69a90592023f3d1b8cfe2
```

The generated recipe was independently replayed against the exact supported
CrossOver files and reproduced the known-good target files.

## App checks

Before release I also checked:

- Swift tests pass
- release build succeeds
- the finished app is arm64
- the bundled compatibility recipe has the expected SHA-256
- the app bundle passes `codesign --verify --deep --strict`
- the startup crash found during development is fixed

## Scope

v1.1.0 is for the exact CrossOver Preview build listed above.

A future CrossOver, macOS, GRYPHLINK, Endfield, or anti-cheat update can still
change compatibility. Unsupported CrossOver builds are rejected instead of
being patched blindly.

Repair and Remove Setup are included as safety tools. I still welcome more
testing of those paths on other Macs and future updates.
