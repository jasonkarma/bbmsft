// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BMSwiftApp",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "BMSwiftApp",
            targets: ["BMSwiftApp"])
    ],
    dependencies: [
        .package(path: "../BMSwift")
    ],
    targets: [
        .target(
            name: "BMSwiftApp",
            dependencies: ["BMSwift"],
            path: "BMSwiftApp"
        ),
        .testTarget(
            name: "BMSwiftAppTests",
            dependencies: ["BMSwiftApp"],
            path: "BMSwiftAppTests"
        )
    ]
)
