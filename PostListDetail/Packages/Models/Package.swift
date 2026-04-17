// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged")
            ],
            resources: [
                .process("posts.json"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
