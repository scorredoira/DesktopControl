// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DesktopControl",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "DesktopControl",
            path: "Sources",
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("Carbon"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("IOKit"),
                .linkedFramework("CoreGraphics")
            ]
        )
    ]
)
