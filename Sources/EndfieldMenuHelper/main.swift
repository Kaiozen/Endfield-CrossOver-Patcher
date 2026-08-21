import Darwin
import Foundation

let home = FileManager.default.homeDirectoryForCurrentUser.path
let payload = home
    + "/Library/Application Support/CrossOver/Bottles/Arknights Endfield"
    + "/.endfield-r11-runtime/launch-gryphlink-private-r11.sh"

execl("/bin/sh", "sh", payload, nil)
exit(127)
