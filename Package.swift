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
        .library(name: "BMSwift", targets: ["BMSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2")
    ],
    targets: [
        // Main App Module
        .target(
            name: "BMSwift",
            dependencies: [
                "KeychainAccess"
            ],
            path: "BMSwift/Sources/BMSwift",
            exclude: [
                "Features/Encyclopedia/Views/ArticleDetailView.swift.bak",
                "Features/SkinAnalysis/README.md"
            ],
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
