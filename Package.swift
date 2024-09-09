// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "TAAnalytics",
    platforms: [ .iOS(.v11), .macOS(.v10_13)],
    products: [
        .library(
            name: "TAAnalytics",
            targets: ["TAAnalytics"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TAAnalytics",
            dependencies: []),
        .testTarget(
            name: "TAAnalyticsTests",
            dependencies: ["TAAnalytics"]),
    ]
)
