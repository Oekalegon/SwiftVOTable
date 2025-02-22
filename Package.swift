// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftVOTable",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftVOTable",
            targets: ["SwiftVOTable"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftVOTable",
            plugins: [
                .plugin(name: "DocumentationPlugin", package: "swift-docc-plugin"),
            ]
        ),
        .testTarget(
            name: "SwiftVOTableTests",
            dependencies: ["SwiftVOTable"]
        ),
    ]
)
