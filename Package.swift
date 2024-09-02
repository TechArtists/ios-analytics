// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "OverbaseAnalytics",
    platforms: [ .iOS(.v11), .macOS(.v10_13)],
    products: [
        .library(
            name: "OverbaseAnalytics",
            targets: ["OverbaseAnalytics"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "OverbaseAnalytics",
            dependencies: []),
        .testTarget(
            name: "OverbaseAnalyticsTests",
            dependencies: ["OverbaseAnalytics"]),
    ]
)
