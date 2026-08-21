import Foundation

enum AppResources {
    static var profileURL: URL? {
        let fm = FileManager.default

        let release = Bundle.main.resourceURL?
            .appendingPathComponent(
                "Profiles/endfield-preview-20260717-r11.profile.json"
            )
        if let release,
           fm.fileExists(atPath: release.path) {
            return release
        }

        let dev = URL(
            fileURLWithPath: fm.currentDirectoryPath
        ).appendingPathComponent(
            "Resources/Profiles/endfield-preview-20260717-r11.profile.json"
        )

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
}
