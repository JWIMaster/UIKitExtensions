// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIKitExtensions",
    platforms: [
        .iOS("7.0"),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "UIKitExtensions",
            targets: ["UIKitExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JWIMaster/UIKitCompatKit", branch: "master"),
        .package(url: "https://github.com/JWIMaster/FoundationCompatKit.git", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "UIKitExtensions",
            dependencies: ["UIKitCompatKit", "FoundationCompatKit"],
            path: "Sources/UIKitExtensions"),
        .target(
            name: "iOS6BarFix",
            dependencies: [],
            path: "Sources/iOS6BarFix",
            publicHeadersPath: "."),
        .testTarget(
            name: "UIKitExtensionsTests",
            dependencies: ["UIKitExtensions"]),
    ]
)








