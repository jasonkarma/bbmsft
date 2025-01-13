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
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2")
    ],
    targets: [
        .target(
            name: "BMSwift",
            dependencies: [
                "KeychainAccess"
            ],
            path: "BMSwift/Sources/BMSwift",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "BMSwiftTests",
            dependencies: ["BMSwift"],
            path: "BMSwift/Tests/BMSwiftTests"
        )
    ]
)
