// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ImplicitOpenExistentials"),
    .enableUpcomingFeature("StrictConcurrency"),
    .unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"])
]

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
        .package(url: "https://github.com/lukacs-m/SimpleKeychain", from: "0.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SimpleNetwork",
            dependencies: [
                .product(name: "SimpleKeychain", package: "SimpleKeychain")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SimpleNetworkTests",
            dependencies: ["SimpleNetwork"],
            resources: [
                .copy("Assets/tests.png")
            ]),
    ]
)
