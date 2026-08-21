# Compatibility profiles

A release profile is a version-bound transformation from an exact, legally obtained CrossOver Preview runtime to the tested Endfield-compatible private runtime.

The profile for the first release is intentionally absent from the development repository until it is generated from the known-good R11 runtime and independently reviewed.

Expected release filename:

```text
endfield-preview-20260717-r11.profile.json
```

Profile schema:

```json
{
  "format": 1,
  "name": "Endfield CrossOver Preview 20260717 R11",
  "crossoverVersion": "20260717",
  "crossoverBuild": "27.0.0.40734",
  "modules": [
    {
      "relativePath": "x86_64-unix/ntdll.so",
      "sourceSHA256": "...",
      "targetSHA256": "...",
      "sourceSize": 123,
      "targetSize": 123,
      "chunks": [
        {
          "offset": 100,
          "removeCount": 3,
          "replacementBase64": "..."
        }
      ]
    }
  ]
}
```

Profiles must never be accepted based only on a filename or version string. The patch engine validates the source bytes before applying any change and verifies the final target hash afterward.

Wine-derived replacement data must retain applicable Wine/LGPL obligations.
