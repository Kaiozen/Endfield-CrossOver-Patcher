# Validation record

This file records what has actually been demonstrated on the reference system.
It intentionally separates completed checks from release claims that still need
independent validation.

## Reference compatibility target

```text
CrossOver Preview: 20260717
CFBundleVersion: 27.0.0.40734
Wine: 11.12
Architecture: x86_64 through Rosetta 2
Graphics: D3DMetal
Sync: MSync
Renderer: DirectX 11
Bottle: Arknights Endfield
```

## Verified R11 profile

Local profile SHA-256:

```text
2babcd451a5e8ade5ec58ab10d0eb6bfa0ba15dc1d2458fd0ce2ff2151782a70
```

Golden target hashes:

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

The profile generator and an independent replay pass both reconstructed every
target module byte-for-byte from the exact supported CrossOver Preview source.

## Swift project validation

Completed:

- Swift 6 Menu Helper compile fix
- macOS 26 SwiftUI AttributeGraph startup-crash diagnosis and fix
- readiness/Rosetta inspection moved off StateObject initialization
- Swift test suite: 4/4 tests passed
- release build produced native arm64 executables
- app bundle passed `codesign --verify --deep --strict`
- embedded local profile hash matched the independently verified profile
- native GUI opened successfully after the startup fix
- the GUI setup transaction completed successfully on the reference Endfield installation

## Startup crash that was fixed

The initial development build synchronously called:

```text
AppModel.init
→ ReadinessService.check
→ PlatformInspector.rosettaCanRunX86
→ ProcessRunner.run
→ Process.waitUntilExit
```

while SwiftUI was constructing the StateObject. On macOS 26 this produced an
AttributeGraph cycle and an intentional SIGABRT.

The fixed architecture performs no blocking inspection in `AppModel.init()`.
`ContentView.task` triggers the readiness refresh, and subprocess-backed
inspection runs outside the main SwiftUI update path.

## Still required before a public binary release

- legal/source-compliance review for publishing the Wine-derived binary profile
- clean-machine install using only public release materials
- cold CrossOver Preview → GRYPHLINK → Play validation after GUI setup
- unrelated-bottle regression check after GUI setup
- Repair test after intentionally regenerating the GRYPHLINK helper
- Remove Setup rollback test
- accessibility/usability pass

Until these are complete, the project should be described as a tested
development build, not a final public release.
