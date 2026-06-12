// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "com.awareframework.ios.sensor.barometer",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "com.awareframework.ios.sensor.barometer",
            targets: [
                "com.awareframework.ios.sensor.barometer"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/awareframework/com.awareframework.ios.core.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "com.awareframework.ios.sensor.barometer",
            dependencies: [
                .product(name: "com.awareframework.ios.core", package: "com.awareframework.ios.core", condition: .when(platforms: [.iOS]))
            ],
            path: "Sources/com.awareframework.ios.sensor.barometer"
        ),
        .testTarget(
            name: "com.awareframework.ios.sensor.barometerTests",
            dependencies: ["com.awareframework.ios.core", "com.awareframework.ios.sensor.barometer"]
        )
    ],
    swiftLanguageModes: [.v5]
)
