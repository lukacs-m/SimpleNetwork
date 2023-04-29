// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleNetwork",
    platforms: [
        .iOS(.v15),
        .tvOS(.v16),
        .watchOS(.v8),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SimpleNetwork",
            targets: ["SimpleNetwork"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SimpleNetwork",
            dependencies: []
        ),
        .testTarget(
            name: "SimpleNetworkTests",
            dependencies: ["SimpleNetwork"],
            resources: [
                .copy("Assets/tests.png")
            ]),
    ]
)
