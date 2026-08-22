import EndfieldCore
import Foundation

enum AppResources {
    private static let previewProfile =
        "endfield-preview-20260717-r11.profile.json"
    private static let stableProfile =
        "endfield-stable-26.3-finewine.profile.json"

    static var profileURL: URL? {
        guard let info = try? CrossOverInspector().find() else {
            return locateProfile(named: previewProfile) ??
                locateProfile(named: stableProfile)
        }

        return locateProfile(
            named: info.isPreview ? previewProfile : stableProfile
        )
    }

    private static func locateProfile(named name: String) -> URL? {
        let fm = FileManager.default

        let release = Bundle.main.resourceURL?
            .appendingPathComponent("Profiles/\(name)")
        if let release, fm.fileExists(atPath: release.path) {
            return release
        }

        let dev = URL(
            fileURLWithPath: fm.currentDirectoryPath
        ).appendingPathComponent("Resources/Profiles/\(name)")

        return fm.fileExists(atPath: dev.path) ? dev : nil
    }

    static var menuHelperURL: URL? {
        let fm = FileManager.default

        let release = Bundle.main.resourceURL?
            .appendingPathComponent("EndfieldMenuHelper")
        if let release,
           fm.isExecutableFile(atPath: release.path) {
            return release
        }

        for candidate in [
            ".build/release/EndfieldMenuHelper",
            ".build/debug/EndfieldMenuHelper",
        ] {
            let url = URL(
                fileURLWithPath: fm.currentDirectoryPath
            ).appendingPathComponent(candidate)

            if fm.isExecutableFile(atPath: url.path) {
                return url
            }
        }
        return nil
    }

    static var greenButtonHookURL: URL? {
        let fm = FileManager.default

        let release = Bundle.main.resourceURL?
            .appendingPathComponent("EndfieldGreenButton.dylib")

        if let release,
           fm.fileExists(atPath: release.path) {
            return release
        }

        let dev = URL(
            fileURLWithPath: fm.currentDirectoryPath
        ).appendingPathComponent(
            "dist/Endfield for CrossOver.app/Contents/Resources/EndfieldGreenButton.dylib"
        )

        return fm.fileExists(atPath: dev.path) ? dev : nil
    }
}
