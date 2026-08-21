# One-click player setup

The player should never need Terminal, a separate patch profile, a golden R11
CrossOver app, Wine knowledge, or manual DLL replacement.

## Player prerequisites

1. Apple Silicon Mac.
2. The exact supported CrossOver Preview release.
3. A Windows 11 64-bit bottle named `Arknights Endfield`.
4. GRYPHLINK installed in that bottle.
5. Arknights: Endfield installed from GRYPHLINK in that bottle.
6. GRYPHLINK opened at least once through CrossOver so its normal macOS launcher
   helper exists.

The player does not need to manually configure D3DMetal or MSync. The app
applies the tested bottle settings itself and saves the previous configuration.

## The only setup action

Open **Endfield for CrossOver** and click:

```text
Set Up Endfield
```

That action automatically:

1. verifies the exact supported CrossOver Preview build;
2. verifies the bundled compatibility recipe;
3. verifies the user's unmodified source Wine modules;
4. copies the required runtime into the Endfield bottle only;
5. applies and verifies the R11 compatibility changes;
6. signs the modified native Wine module where required;
7. backs up the current bottle settings;
8. applies D3DMetal + MSync and removes stale runtime selector overrides;
9. writes the private GRYPHLINK launch payload;
10. backs up the generated GRYPHLINK macOS helper;
11. installs the Endfield-specific Menu Helper;
12. records target hashes and rollback state;
13. reports success only after verification finishes.

CrossOver Preview.app itself remains unchanged. Other bottles remain on the
normal CrossOver runtime.

## Daily use

```text
CrossOver Preview
-> Arknights Endfield
-> GRYPHLINK
-> Play
```
