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
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.0.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2")
    ],
    targets: [
        .target(
            name: "BMSwift",
            dependencies: [
                "KeychainAccess"
            ],
            path: "Sources/BMSwift",
            resources: [
                .process("Resources")  // This will include Resources/Assets.xcassets
            ],
            swiftSettings: [
                .define("ENABLE_PREVIEWS", .when(configuration: .debug))
            ]
        ),
        .testTarget(
            name: "BMSwiftTests",
            dependencies: [
                "BMSwift",
                "Quick",
                "Nimble"
            ])
    ]
)
