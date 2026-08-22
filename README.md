# Endfield for CrossOver

I made this because getting **Arknights: Endfield** working through CrossOver on Apple Silicon was possible, but the setup was way too annoying to repeat or explain to someone else.

This app turns that setup into one button.

If you already have the supported CrossOver Preview build, GRYPHLINK, and Endfield installed in the right bottle, open **Endfield for CrossOver** and click **Set Up Endfield**. That's it.

## Download

Grab the newest version from the [Releases page](https://github.com/Kaiozen/Endfield-CrossOver-Patcher/releases/latest).

The download is:

```text
Endfield-for-CrossOver-v1.1.0.zip
```

Unzip it and open **Endfield for CrossOver.app**.

The app is currently ad-hoc signed, not Apple-notarized, so macOS may complain the first time. If it does, Control-click the app, choose **Open**, then confirm **Open** again.

## What you need

The app supports both normal CrossOver and CrossOver Preview:

```text
CrossOver 26.3 or newer
CrossOver Preview 20260717 or newer
Apple Silicon Mac
Rosetta 2
```

The verified baselines are CrossOver 26.3 and CrossOver Preview 20260717 / build 27.0.0.40734. Newer versions are allowed to try the compatibility recipe, but the patcher still verifies source hashes and stops safely if CodeWeavers changed the Wine modules.

You also need a **Windows 11 64-bit** bottle named exactly:

```text
Arknights Endfield
```

Inside that bottle:

- install GRYPHLINK
- install Arknights: Endfield through GRYPHLINK
- open GRYPHLINK from CrossOver at least once

You do **not** need to set D3DMetal or MSync yourself. The app handles those settings.

When Endfield is in **Windowed** mode, the app also enables the normal macOS green fullscreen button.

## Setup

Once the things above are installed:

1. Quit GRYPHLINK and the game.
2. Open **Endfield for CrossOver**.
3. Make sure the checks say everything is ready.
4. Click **Set Up Endfield**.
5. Wait for it to say it's done.

Then play normally:

```text
CrossOver
-> Arknights Endfield
-> GRYPHLINK
-> Play
```

No Terminal commands. No separate R11 app. No DLL copying. No extra profile download.

## What the app actually does

I tried to keep the app simple on purpose. Behind the Set Up button it:

- checks that you're using CrossOver 26.3+ or Preview 20260717+ and selects the matching compatibility baseline
- makes a separate Endfield-only copy of the parts of CrossOver that need the compatibility fixes
- applies the tested fixes to that private copy
- turns on D3DMetal and MSync for the Endfield bottle
- backs up the current bottle settings
- backs up the GRYPHLINK launcher helper
- connects GRYPHLINK to the private Endfield setup
- enables the macOS green fullscreen button in Windowed mode
- checks the finished files before saying the setup worked

Your normal **CrossOver Preview.app stays untouched**.

Your other CrossOver bottles keep using normal CrossOver.

The patcher does not modify `Endfield.exe` or ACE.

## What I tested before calling this v1.0.0

I didn't want to call this a real release just because it worked on the setup I had already been using.

I deleted my Endfield bottle and the old GRYPHLINK helper, made a completely fresh **Arknights Endfield** bottle, installed GRYPHLINK and Endfield again, ran this patcher, and launched the game normally through CrossOver.

It worked from the clean setup.

I also verified the compatibility recipe against the known-good R11 files, ran the Swift tests, rebuilt the app from source, and checked the finished app bundle before making the release.

That does not mean every future CrossOver or Endfield update will magically work. The verified baselines are listed above. Newer builds are experimental until someone confirms gameplay and reports the result.

## Green fullscreen button

When Endfield is in Windowed mode, the normal macOS green button works after setup. You can use it to enter native macOS fullscreen.

There is no extra download or switch. It is part of **Set Up Endfield** and **Repair**.

The change only lives inside Endfield's private runtime. My main CrossOver Preview app and other bottles stay untouched.

## If something breaks

Open **Endfield for CrossOver** and go to **Repair**.

There are also local support reports and a launch checker in the app. Nothing is uploaded automatically.

If a future CrossOver update changes the files this release expects, the patcher should stop instead of guessing.

## Big credit to Endfield_FineWine

The biggest credit goes to **stoicswe** and [Endfield_FineWine](https://github.com/stoicswe/Endfield_FineWine).

That project did the original compatibility research that made Endfield work on Apple Silicon through CrossOver. I did not invent that foundation, and I don't want to bury the credit in a footnote.

This project is my attempt to turn that work into something a normal person can download, click, and use without rebuilding the whole setup by hand.

Also thanks to the Wine and CodeWeavers developers, and to the upstream work credited by Endfield_FineWine.

More detailed credits and license information are in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Privacy

There is no telemetry.

The app does not send your game account, device information, CrossOver license information, or logs anywhere.

If you create a support report, it stays on your Mac until you decide to share it.

## Building it yourself

If you want to look through the code or build it yourself:

```bash
swift test
./scripts/build-app.sh
```

The finished app goes to:

```text
dist/Endfield for CrossOver.app
```

The compatibility recipe used by the release is included in the repository so the public build is the same kind of one-click build I tested.

Technical notes are in the `docs/` folder if you actually want the weeds.

## A few important notes

This is my independent project. It is **not** official software from Gryphline, Hypergryph, CodeWeavers, Apple, or any anti-cheat company.

You still need your own legitimate copy of CrossOver, GRYPHLINK, and Arknights: Endfield.

I do not redistribute CrossOver, GRYPHLINK, Endfield, ACE, or Game Porting Toolkit.

CrossOver, Wine, D3DMetal, GRYPHLINK, Arknights: Endfield, and the other names used here belong to their respective owners.

See [LICENSE](LICENSE), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), and [docs/WINE-SOURCE.md](docs/WINE-SOURCE.md) for the boring-but-important license details.
