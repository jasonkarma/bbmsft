// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BMSwift",
    defaultLocalization: "zh-Hant",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)  // For development support
    ],
    products: [
        .library(
            name: "BMSwift",
            type: .dynamic,  // Make it dynamic to avoid linking issues
            targets: ["BMSwift"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BMSwift",
            dependencies: [],
            path: "Sources/BMSwift",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .define("ENABLE_PREVIEWS", .when(configuration: .debug))
            ]
        ),
        .testTarget(
            name: "BMSwiftTests",
            dependencies: ["BMSwift"])
    ]
)

