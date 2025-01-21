// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BMSwift",
    defaultLocalization: "zh-Hant",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)  // For development support
    ],
    products: [
        .library(
            name: "BMSwift",
            type: .dynamic,  // Make it dynamic to avoid linking issues
            targets: ["BMSwift"]
        ),
        .library(
            name: "BMNetwork",
            type: .dynamic,
            targets: ["BMNetwork"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2")
    ],
    targets: [
        .target(
            name: "BMSwift",
            dependencies: [
                "KeychainAccess",
                "BMNetwork"
            ],
            path: "Sources/BMSwift",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .define("BMSWIFT_MODULE")
            ]
        ),
        .target(
            name: "BMNetwork",
            dependencies: [],
            path: "Sources/BMNetwork",
            swiftSettings: [
                .define("BMNETWORK_MODULE")
            ]
        ),
        .testTarget(
            name: "BMSwiftTests",
            dependencies: ["BMSwift"],
            path: "Tests/BMSwiftTests"
        )
    ]
)
