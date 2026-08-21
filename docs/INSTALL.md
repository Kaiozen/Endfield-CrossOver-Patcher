# Installation guide

This is the longer version of the setup instructions.

## What you need

- Apple Silicon Mac
- Rosetta 2
- supported CrossOver Preview build
- official GRYPHLINK installer
- Arknights: Endfield installed in a bottle named `Arknights Endfield`
- Endfield for CrossOver patcher

## Create the Endfield bottle

1. Open CrossOver Preview.
2. Click **Install**.
3. If GRYPHLINK is not listed, choose **Install an unlisted application**.
4. Pick the official GRYPHLINK installer.
5. Choose **New Bottle**.
6. Choose **Windows 11 64-bit**.
7. Name it exactly **Arknights Endfield**.
8. Finish installing GRYPHLINK.
9. In GRYPHLINK, install Arknights: Endfield.

After the game is downloaded, close GRYPHLINK and the game.

## Run the patcher

Open **Endfield for CrossOver.app**.

The setup page checks the prerequisites automatically.

If a row says **Needs attention**, its text gives one concrete next action.

When every required row says **Ready**, click **Set Up Endfield**.

## After setup

Open CrossOver Preview normally:

1. select **Arknights Endfield**;
2. double-click **GRYPHLINK**;
3. click **Play**.

## Renderer

The proven stable renderer for the first release is **DirectX 11**.

If a launcher/game update changes the renderer and the game stops opening correctly, set it back to DirectX 11 before assuming the compatibility setup is broken.

## If CrossOver updates

Do not force setup on a new CrossOver build.

Open the patcher. If it says your build is unsupported, wait for a tested profile for that build.

## If GRYPHLINK disappears or is rebuilt

Use **Repair**. CrossOver can regenerate its per-program helper. Repair detects this and restores the Endfield-specific launch bridge.
