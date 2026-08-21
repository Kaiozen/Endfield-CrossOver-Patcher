# Endfield for CrossOver

A native macOS setup app for running **Arknights: Endfield** from your normal **CrossOver Preview** installation on Apple Silicon.

The goal is simple:

> Open CrossOver Preview → open the **Arknights Endfield** bottle → click **GRYPHLINK** → click **Play**.

No second daily CrossOver app. No Terminal launcher. No global replacement of CrossOver's Wine runtime.

> [!IMPORTANT]
> **Development status:** the app architecture, installer, repair path, launcher bridge, diagnostics, tests, and documentation are implemented. The final R11 binary patch profile is intentionally **not committed yet**. It must be generated from the exact known-good runtime and reviewed before this project is release-ready. The app refuses setup when that profile is missing. We do not guess or patch unknown binaries.

---

## What this changes

The patcher keeps your normal `CrossOver Preview.app` unchanged.

For Endfield only, it:

1. makes a private copy of the required CrossOver runtime **inside the Arknights Endfield bottle**;
2. applies the version-locked Endfield compatibility changes to that private copy;
3. turns on the tested Endfield bottle settings: **D3DMetal + MSync**;
4. updates the **GRYPHLINK launcher generated for this one game** so it starts the private Endfield runtime;
5. keeps backups so **Repair** and **Remove Setup** can recover cleanly.

Other bottles continue using the normal CrossOver Preview runtime.

### In one picture

```text
CrossOver Preview.app                    unchanged
│
├─ your other bottles                   normal CrossOver runtime
│
└─ Arknights Endfield
   │
   ├─ private Endfield compatibility runtime
   │  └─ .endfield-r11-runtime/CrossOver/
   │
   └─ GRYPHLINK tile
      └─ Endfield-specific Menu Helper
         └─ private runtime → GRYPHLINK → Endfield
```

The generated GRYPHLINK helper lives at:

```text
~/Applications/CrossOver/GRYPHLINK/GRYPHLINK.app
```

That helper is specific to GRYPHLINK. **CrossOver Preview.app itself is not patched.**

---

# Before you start

## Supported release target

The first release is deliberately strict.

| Requirement | Supported |
|---|---|
| Mac | Apple Silicon |
| CrossOver | **CrossOver Preview** |
| Tested Preview | **20260717 / build 27.0.0.40734** |
| Wine architecture | x86_64 through Rosetta 2 |
| Graphics | D3DMetal |
| Sync | MSync |
| Game renderer | DirectX 11 |
| Bottle name | `Arknights Endfield` |

**Why only one CrossOver build?** Compatibility patches are binary-specific. A patcher that “tries anyway” on an unknown build is not user-friendly; it is risky. The app checks the exact build and stops with a clear explanation if it does not match.

Newer CrossOver Preview builds can change Wine, the launcher system, D3DMetal behavior, or CPU architecture. They need their own tested profile before support is added.

### A note about the newer ARM64 Preview

CodeWeavers introduced experimental native ARM64 Preview builds on July 31, 2026. Those builds are **not supported by this first profile**. CodeWeavers currently lists major limitations for that experimental path, including no D3DMetal and game launchers that may not work.

Do not use a random third-party reupload of an older CrossOver build just to satisfy the version check. Use software obtained legitimately from CodeWeavers. If the exact supported Preview is no longer available to you, wait for a profile that has been tested against a newer build.

Current references:

- CrossOver Mac User Guide: https://support.codeweavers.com/crossover-mac-user-guide
- CrossOver Preview Center: https://www.codeweavers.com/preview/
- CodeWeavers ARM64 Preview notes: https://www.codeweavers.com/blog/mjohnson/2026/7/31/crossover-preview-the-right-to-bear-arm64-on-mac

---

# Setup for normal players

You should not need to understand Wine, DLLs, patch offsets, or launch environments.

## 1. Install CrossOver Preview

Use a legally obtained CrossOver Preview installation.

For the first supported release, you need the exact supported build shown above. The patcher checks this automatically.

## 2. Install GRYPHLINK and Endfield in CrossOver

In CrossOver Preview:

1. Choose **Install**.
2. Choose **Install an unlisted application** if GRYPHLINK is not listed.
3. Select the official GRYPHLINK installer.
4. Create or choose a **Windows 11 64-bit** bottle.
5. Name the bottle **Arknights Endfield**.
6. Finish the GRYPHLINK installation.
7. Open GRYPHLINK and install Arknights: Endfield.
8. Close the game and launcher when the download is finished.

The patcher does not download the game, GRYPHLINK, or CrossOver for you.

## 3. Open Endfield for CrossOver

The app checks everything automatically.

You will see simple status rows such as:

- **CrossOver Preview — Ready**
- **Arknights Endfield — Found**
- **GRYPHLINK — Found**
- **Compatibility files — Ready**

If something is missing, the app tells you exactly what to do next.

## 4. Click **Set Up Endfield**

That is the main setup action.

The app creates backups before changing anything and verifies the result before reporting success.

## 5. Play normally

After setup:

1. Open **CrossOver Preview**.
2. Select **Arknights Endfield**.
3. Double-click **GRYPHLINK**.
4. Click **Play**.

That is the intended daily workflow.

---

# If something stops working

Open the patcher and choose **Repair**.

Repair checks:

- the private Endfield runtime;
- the exact compatibility hashes;
- D3DMetal and MSync settings;
- the GRYPHLINK Menu Helper;
- whether CrossOver regenerated the helper after an update or menu refresh.

Repair only reapplies the pieces that are missing or changed.

There is also **Create Support Report**. It records the relevant Endfield launch chain locally so a developer can see whether GRYPHLINK, `Games.exe`, or `Endfield.exe` started with the private runtime.

**No report is uploaded automatically. This project has no telemetry.**

---

# What the patcher does not do

- It does **not** patch `Endfield.exe`.
- It does **not** patch ACE game/driver files.
- It does **not** download or crack the game.
- It does **not** bypass CrossOver licensing.
- It does **not** replace CrossOver Preview's runtime globally.
- It does **not** change other CrossOver bottles.
- It does **not** promise that an unsupported game configuration can never lead to account action.

This is unofficial compatibility work. Game, launcher, anti-cheat, macOS, or CrossOver updates can break it.

---

# A huge thank-you ❤️

## stoicswe / Endfield_FineWine

This project would **not exist** without the original work by **stoicswe** and the
[Endfield_FineWine](https://github.com/stoicswe/Endfield_FineWine) project.

That project published the first known working Endfield-on-Apple-Silicon CrossOver setup and documented the compatibility research that made the breakthrough possible, including Rosetta behavior and the Wine-side compatibility work built on upstream community research.

This patcher is an attempt to turn that hard-won engineering into something a normal Mac player can set up safely and understand.

**Please visit the original project, read the technical work, and give it a star.** The foundation belongs in the credits, not hidden in a footnote.

Additional thanks:

- the **Wine** and **CodeWeavers** developers whose compatibility work makes projects like this possible;
- the **dw-proton / Dawn Winery** contributors whose upstream Wine compatibility work informed the original Endfield research;
- **dazi2011/crossover-patcher** for useful ideas around exact-build validation and safe patcher packaging. This project does **not** include or depend on its proprietary PatchCore.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

---

# Why the interface is intentionally simple

The UI is based on current Apple Human Interface Guidelines and established usability guidance, not on a “gaming dashboard” full of unexplained switches.

The design uses:

- **one obvious primary action** for setup;
- visible readiness checks so people can **recognize** what is needed instead of remembering instructions;
- immediate progress and status feedback;
- plain-language errors with a next step;
- progressive disclosure for developer details;
- reversible changes and backups;
- system controls, SF Symbols, keyboard navigation, VoiceOver labels, and semantic colors;
- no color-only success/failure communication;
- no telemetry and no surprise network behavior.

Read the design rationale and references in [docs/UX-DESIGN.md](docs/UX-DESIGN.md).

“Evidence-based” does not mean that one layout is scientifically guaranteed to be perfect for every person. The project follows established human-interface and usability principles, and the release process includes task-based usability testing so the design can be improved with evidence instead of assumption.

---

# For developers

## Repository layout

```text
Sources/
  EndfieldCore/          setup, inspection, patching, repair, diagnostics
  EndfieldPatcher/       native SwiftUI macOS app
  EndfieldMenuHelper/    tiny launcher installed into GRYPHLINK.app

Resources/
  Profiles/              version-bound compatibility profiles

Tests/
  EndfieldCoreTests/

docs/
  INSTALL.md
  TECHNICAL.md
  UX-DESIGN.md
  DEVELOPMENT.md
  SUPPORTED-VERSIONS.md

scripts/
  build-app.sh
  generate-profile.py
  generate-profile.command
  verify-source.sh
```

## Build

Requirements:

- macOS 14 or newer
- Xcode Command Line Tools / Xcode
- Swift 6

```sh
./scripts/verify-source.sh
./scripts/build-app.sh
```

Output:

```text
dist/Endfield for CrossOver.app
```

The development build compiles without a real R11 profile, but setup remains disabled until a reviewed profile is present in `Resources/Profiles/`.

## Tests

```sh
swift test
```

The tests use synthetic fixtures. They do not contain CrossOver or game files.

---

# Release safety

A release profile is accepted only when it identifies:

- the exact CrossOver Preview version and build;
- the exact source file size and SHA-256;
- the exact target SHA-256;
- the bounded replacement ranges.

The patch engine copies the user's own local CrossOver runtime into the Endfield bottle, applies the profile there, and verifies every target hash. If validation fails, setup stops.

Unknown builds are rejected. There is no “force patch anyway” button.

---

# Privacy

Everything runs locally.

The app does not collect:

- game account information;
- device identifiers;
- gameplay data;
- CrossOver license information;
- logs unless you explicitly create a support report.

Support reports stay on your Mac until **you** choose to share them.

---

# Legal / project status

This is an independent, unofficial compatibility project. It is not affiliated with or endorsed by Gryphline, Hypergryph, Tencent, CodeWeavers, Apple, or an anti-cheat vendor.

CrossOver, Wine, D3DMetal, GRYPHLINK, Arknights: Endfield, and other names belong to their respective owners.

The repository does not redistribute CrossOver, GRYPHLINK, Endfield, ACE, or a complete Wine runtime. Users provide their own legitimate software.

See [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
