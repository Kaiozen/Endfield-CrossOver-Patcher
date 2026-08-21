# Third-party notices

This project is a compatibility installer. It depends conceptually on work from several independent projects, but it does not claim ownership of that work.

## Endfield_FineWine

Project: https://github.com/stoicswe/Endfield_FineWine

Endfield_FineWine published the original working Endfield-on-Apple-Silicon CrossOver research that made this project possible. Its repository documents Rosetta-specific compatibility findings and Wine changes, including work informed by dw-proton.

Its tooling/documentation is MIT-licensed. Wine-derived patches remain subject to Wine's LGPL licensing. Refer to the upstream repository for the exact license boundaries and attribution.

## Wine

Project: https://www.winehq.org/

Wine is licensed under the GNU Lesser General Public License, version 2.1 or later.

This repository does not ship a complete Wine runtime. If a release includes a compatibility profile containing data derived from modified Wine modules, that profile must retain the relevant LGPL obligations.

## CodeWeavers / CrossOver

Product: https://www.codeweavers.com/crossover

CrossOver is commercial software from CodeWeavers. This project does not redistribute CrossOver or bypass its licensing. The installer works from a user's own compatible CrossOver installation.

## dw-proton / Dawn Winery

The original Endfield compatibility research credits upstream Wine compatibility work from the dw-proton / Dawn Winery project. Any code derived from Wine or that upstream work retains its applicable upstream licensing.

## dazi2011/crossover-patcher

Project: https://github.com/dazi2011/crossover-patcher

Referenced for public examples of exact-build gating and patcher/release workflow. This repository does not include, copy, or depend on its proprietary PatchCore.

## Apple

Swift, SwiftUI, macOS, Rosetta 2, SF Symbols, and D3DMetal / Game Porting Toolkit are Apple technologies or trademarks. This project is not endorsed by Apple and does not redistribute Game Porting Toolkit.
