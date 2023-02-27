// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "MenuBarExtraAccess",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "MenuBarExtraAccess",
            targets: ["MenuBarExtraAccess"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MenuBarExtraAccess",
            dependencies: []),
        .testTarget(
            name: "MenuBarExtraAccessTests",
            dependencies: ["MenuBarExtraAccess"]),
    ]
)
