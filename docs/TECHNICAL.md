# Technical architecture

This document is for developers and support. Normal players do not need it.

## Design objective

Keep one normal, unmodified `CrossOver Preview.app` while routing only the Arknights Endfield launch through the proven compatibility runtime.

## Runtime layout

```text
~/Applications/CrossOver Preview.app
    stock

~/Library/Application Support/CrossOver/Bottles/Arknights Endfield/
    cxbottle.conf
    .endfield-r11-runtime/
        CrossOver/
            bin/wine
            bin/wineserver
            lib/wine/...
        launch-gryphlink-private-r11.sh
        state.json

~/Applications/CrossOver/GRYPHLINK/GRYPHLINK.app/
    Contents/MacOS/Menu Helper
```

The private runtime starts as a user-local copy of:

```text
CrossOver Preview.app/Contents/SharedSupport/CrossOver
```

The patch profile transforms only version-bound Wine modules in that private copy.

## Why the Menu Helper matters

CrossOver's in-app GRYPHLINK tile does not simply execute the bottle's generated Unix `cxmenu` shell file.

Process tracing showed the GUI route:

```text
CrossOver Preview
→ ~/Applications/CrossOver/GRYPHLINK/GRYPHLINK.app/Contents/MacOS/Menu Helper
→ stock Preview winewrapper.exe
→ Windows GRYPHLINK shortcut
```

That stock `winewrapper` decision happens before later launcher wrappers can take control.

The working solution therefore replaces only this **GRYPHLINK-specific generated Menu Helper** with a tiny native helper that invokes the bottle-private R11 payload.

This is not a modification of `CrossOver Preview.app` itself.

## Helper behavior

The helper executable is built from `Sources/EndfieldMenuHelper`.

It resolves the current user's home directory and executes:

```text
~/Library/Application Support/CrossOver/Bottles/Arknights Endfield/
.endfield-r11-runtime/launch-gryphlink-private-r11.sh
```

The payload:

1. removes inherited CrossOver/Wine runtime selectors that could point back to stock Preview;
2. sets the Endfield bottle as `WINEPREFIX`;
3. stops only the Endfield prefix's stale Wine server;
4. launches private `bin/wine`;
5. starts the original Windows GRYPHLINK Start Menu shortcut.

## Bottle settings

Managed values:

```text
CX_GRAPHICS_BACKEND=d3dmetal
WINEMSYNC=1
WINEESYNC=0
WINEDXVK=0
WINED3DMETAL=1
```

Runtime-root selectors are intentionally **not** stored in `cxbottle.conf`.

## Golden R11 target hashes

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

A hash alone is not enough to reproduce a file. The missing release profile must be generated from the known-good runtime and verified before release.

## Transaction model

Setup:

1. inspect exact supported CrossOver version/build;
2. load and validate compatibility profile;
3. verify source module hashes;
4. copy stock CrossOver runtime to a temporary private-runtime directory;
5. apply profile chunks;
6. verify every target hash;
7. ad-hoc sign modified Mach-O module(s);
8. atomically replace previous private runtime;
9. edit bottle config with backup;
10. wait for generated GRYPHLINK helper;
11. back up helper app;
12. install project Menu Helper;
13. ad-hoc sign generated helper app;
14. save state file.

If any pre-commit verification fails, setup stops.

## Repair

Repair treats each managed surface independently:

- runtime integrity;
- bottle configuration;
- Menu Helper integrity;
- payload existence.

CrossOver can regenerate per-program helper apps. Reinstalling only the helper is therefore a supported repair path.

## Diagnostics

Diagnostics are local-only and look for:

- Menu Helper process;
- GRYPHLINK / Games.exe / Endfield.exe;
- runtime paths loaded by Endfield-related processes;
- whether stock CrossOver Preview modules entered the Endfield process chain.

The report intentionally avoids account/token collection.
