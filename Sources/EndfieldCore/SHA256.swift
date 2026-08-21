import CryptoKit
import Foundation

public enum SHA256File {
    public static func hex(data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    public static func hex(url: URL) throws -> String {
        try hex(data: Data(contentsOf: url, options: [.mappedIfSafe]))
    }
}
