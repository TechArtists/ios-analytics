// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "TAAnalytics",
    platforms: [ .iOS(.v15), .macOS(.v10_14)],
    products: [
        .library(
            name: "TAAnalytics",
            targets: ["TAAnalytics"]
            )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TAAnalytics"
        ),
        .testTarget(
            name: "TAAnalyticsTests",
            dependencies: ["TAAnalytics"]),
    ]
)
