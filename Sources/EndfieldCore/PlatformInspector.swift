import Foundation

public struct PlatformInspector: Sendable {
    public init() {}

    public var isAppleSilicon: Bool {
        #if arch(arm64)
        return true
        #else
        return false
        #endif
    }

    public func rosettaCanRunX86() -> Bool {
        guard isAppleSilicon else { return false }
        do {
            let result = try ProcessRunner.run(
                URL(fileURLWithPath: "/usr/bin/arch"),
                ["-x86_64", "/usr/bin/true"]
            )
            return result.status == 0
        } catch {
            return false
        }
    }
}
