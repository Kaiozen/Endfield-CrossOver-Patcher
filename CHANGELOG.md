# Changelog

## 1.0.1

- Added the custom wolf face app icon using the provided original image.
- Added the full original image to the About page.
- No compatibility or patching behavior changed.

## 1.0.0

First stable release.

- Tested the patcher from a completely fresh Endfield bottle instead of reusing my old working setup.
- Fresh install path worked: CrossOver Preview -> new bottle -> GRYPHLINK -> Endfield -> Set Up Endfield -> Play.
- The compatibility recipe is bundled with the app. Users do not generate it manually.
- One Set Up Endfield button handles the private runtime, compatibility changes, D3DMetal, MSync, backups, signing, and GRYPHLINK launcher setup.
- Rewrote the README in plain language and moved the deeper technical details out of the way.
- Updated the About page and kept prominent credit for stoicswe / Endfield_FineWine.
- The release includes the Wine/LGPL notices alongside the app.

## 0.1.0-alpha.1

- Made the verified R11 compatibility recipe part of the public app.
- Release builds now fail if the recipe is missing instead of shipping a disabled setup button.
- Tightened readiness checks so `Arknights Endfield` means the actual game executable is installed, not merely that the bottle exists.
- The player prerequisites are now only the supported CrossOver Preview build plus an `Arknights Endfield` bottle containing GRYPHLINK and Endfield.
- `Set Up Endfield` automatically handles D3DMetal, MSync, the bottle-private R11 runtime, backups, patch verification, code signing, and the GRYPHLINK bridge.
- Added one-click setup documentation and Wine/LGPL source-notice material.
- Added CI packaging for a downloadable macOS app artifact.

## 0.1.0-dev.2

- Verified the generated R11 profile by independently replaying every patch and reproducing all four golden target files byte-for-byte.
- Fixed the Swift 6 `execl(..., nil)` Menu Helper compile failure.
- Fixed a macOS 26 SwiftUI AttributeGraph startup crash caused by synchronous process waiting during `StateObject` initialization.
- Moved readiness/Rosetta inspection off the SwiftUI initialization path.
- Confirmed 4/4 Swift tests pass.
- Confirmed the native arm64 app builds and passes strict code-signature verification.
- Confirmed the GUI opens successfully after the startup fix.
- Completed a local GUI setup transaction against the reference Endfield installation.
- Kept the Wine-derived R11 binary profile private pending licensing/source-compliance review and final clean-machine validation.

## 0.1.0-dev

- New SwiftUI patcher architecture.
- Exact CrossOver Preview build gating.
- Bottle-private compatibility runtime design.
- Proven GRYPHLINK Menu Helper launch bridge.
- D3DMetal + MSync bottle configuration.
- Repair and local support-report workflow.
- Plain-language Apple-style setup UI.
- R11 release profile intentionally pending independent generation and verification.
