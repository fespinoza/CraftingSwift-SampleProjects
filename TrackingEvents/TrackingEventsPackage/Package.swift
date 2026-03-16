// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TrackingEventsPackage",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(
            name: "TrackingEvents",
            targets: ["TrackingEvents"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "6.0.1"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.15.1"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "TrackingEvents"
        ),
        .executableTarget(
            name: "TrackingGenerator",
            dependencies: [
                "Yams",
                "Stencil",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .process("Stencil/Templates"),
            ]
        ),
        .testTarget(
            name: "TrackingGeneratorTests",
            dependencies: [
                "TrackingGenerator",
                "Yams",
                "Stencil",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
