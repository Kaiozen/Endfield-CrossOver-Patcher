# Contributing

Thanks for helping.

## Ground rules

1. Keep the normal-player flow simple.
2. Do not add a “force patch unknown build” switch.
3. Do not bundle CrossOver, GRYPHLINK, Endfield, ACE, GPTK, or proprietary patch cores.
4. Keep normal UI text in plain language. Put implementation terms behind **Technical details**.
5. Add tests for setup/repair behavior.
6. Destructive changes require a clear confirmation and a recovery path.
7. Accessibility is part of the feature, not a later polish pass.

## Pull requests

Before opening a PR:

```sh
swift test
./scripts/verify-source.sh
```

For UI changes, explain which user task the change improves and how you checked it.
