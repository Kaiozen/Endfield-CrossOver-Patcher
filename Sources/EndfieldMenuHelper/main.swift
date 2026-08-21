import Darwin
import Foundation

let home = FileManager.default.homeDirectoryForCurrentUser.path
let payload = home
    + "/Library/Application Support/CrossOver/Bottles/Arknights Endfield"
    + "/.endfield-r11-runtime/launch-gryphlink-private-r11.sh"

let shell = Process()
shell.executableURL = URL(fileURLWithPath: "/bin/sh")
shell.arguments = [payload]

do {
    try shell.run()
    shell.waitUntilExit()
    exit(shell.terminationStatus)
} catch {
    let message =
        "EndfieldMenuHelper could not start the private Endfield launcher: "
        + error.localizedDescription
        + "\n"
    FileHandle.standardError.write(Data(message.utf8))
    exit(127)
}
