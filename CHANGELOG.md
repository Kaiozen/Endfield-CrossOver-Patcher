# Changelog

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
