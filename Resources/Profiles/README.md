# Compatibility recipe

The public app includes the verified compatibility recipe for:

```text
CrossOver Preview 20260717
build 27.0.0.40734
```

File:

```text
endfield-preview-20260717-r11.profile.json
```

Verified profile SHA-256:

```text
2babcd451a5e8ade5ec58ab10d0eb6bfa0ba15dc1d2458fd0ce2ff2151782a70
```

Players do not generate or install this file manually. It is bundled inside
**Endfield for CrossOver.app** and consumed automatically when the player clicks
**Set Up Endfield**.

The patch engine verifies the exact source size and SHA-256 of every supported
Wine module before changing a byte, applies the version-bound replacement
ranges only to a bottle-private runtime, and verifies the final target hashes.

This profile contains Wine-derived compatibility data and is distributed under
the applicable Wine LGPL-2.1-or-later terms. It does not contain CrossOver's
complete runtime, GRYPHLINK, Endfield, ACE, or Game Porting Toolkit.
