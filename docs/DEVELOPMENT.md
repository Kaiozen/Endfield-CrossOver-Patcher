# Development

## Current release blocker

The repository intentionally does not contain:

```text
Resources/Profiles/endfield-preview-20260717-r11.profile.json
```

Generate it on the machine that still has:

```text
~/Applications/CrossOver Preview.app
~/Applications/CrossOver Endfield Preview R11.app
```

Then review it before committing.

## Generate the profile

```sh
./scripts/generate-profile.command
```

Expected output:

```text
~/Desktop/endfield-preview-20260717-r11.profile.json
```

Review checklist:

- format is `1`;
- version is `20260717`;
- build is `27.0.0.40734`;
- only the four expected modules are present;
- every source SHA matches the pristine Preview module;
- every target SHA matches the golden R11 module;
- applying the chunks to pristine files reproduces each target SHA;
- Wine/LGPL attribution is present.

Only after that review should the file be copied to `Resources/Profiles/`.

## Build

```sh
./scripts/build-app.sh
```

## Automated checks

```sh
swift test
./scripts/verify-source.sh
```

## Release checklist

- [ ] real profile committed and verified
- [ ] clean-machine setup test
- [ ] cold CrossOver launch test
- [ ] actual gameplay test, not launcher-only
- [ ] another bottle verified unaffected
- [ ] Repair tested after deliberately restoring original GRYPHLINK helper
- [ ] Remove Setup tested
- [ ] VoiceOver pass
- [ ] keyboard-only pass
- [ ] reduced-motion pass
- [ ] task-completion usability test with people who did not build the project
- [ ] source ZIP contains no `.build`, `DerivedData`, caches, game files, or CrossOver files
- [ ] SHA-256 published for release ZIP
