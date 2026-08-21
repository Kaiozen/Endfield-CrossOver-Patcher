import Foundation

public struct PayloadWriter: Sendable {
    public init() {}

    public func write(paths: EndfieldPaths) throws {
        let bottle = shQuote(paths.bottle.path)
        let root = shQuote(paths.privateRoot.path)
        let log = shQuote(
            paths.privateContainer.appendingPathComponent("launch.log").path
        )

        let script = """
        #!/bin/sh
        set -u

        BOTTLE=\(bottle)
        ROOT=\(root)
        LOG=\(log)

        {
          echo "============================================================"
          echo "Endfield launch: $(date)"
          echo "pid=$$ ppid=$PPID"
        } >> "$LOG" 2>&1

        unset CX_ROOT CX_BOTTLE WINELOADER WINESERVER WINEWRAPPER
        unset WINEDLLPATH WINEDLLPATH_PREPEND WINESERVERSOCKET
        unset CX_WINEWRAPPER_ALT_LOADER_SOCKET WINE_WAIT_CHILD_PIPE
        unset DYLD_LIBRARY_PATH DYLD_FALLBACK_LIBRARY_PATH

        export WINEPREFIX="$BOTTLE"
        export PATH="$ROOT/bin:/usr/bin:/bin:/usr/sbin:/sbin"

        "$ROOT/bin/wineserver" -k >> "$LOG" 2>&1 || true
        "$ROOT/bin/wineserver" -w >> "$LOG" 2>&1 || true

        exec "$ROOT/bin/wine" \
          --bottle "Arknights Endfield" \
          --check \
          --wait-children \
          --start "C:/ProgramData/Microsoft/Windows/Start Menu/Programs/GRYPHLINK/GRYPHLINK.lnk" \
          >> "$LOG" 2>&1
        """

        try FileManager.default.createDirectory(
            at: paths.privateContainer,
            withIntermediateDirectories: true
        )
        try script.write(
            to: paths.payload,
            atomically: true,
            encoding: .utf8
        )
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: paths.payload.path
        )
    }

    private func shQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(
            of: "'",
            with: "'\"'\"'"
        ) + "'"
    }
}
