// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "PostUI",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "PostUI",
            targets: ["PostUI"]
        ),
    ],
    dependencies: [
        .package(path: "../Models"),
    ],
    targets: [
        .target(
            name: "PostUI",
            dependencies: ["Models"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
