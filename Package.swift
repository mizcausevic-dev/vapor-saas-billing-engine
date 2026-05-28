// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "VaporSaaSBillingEngine",
    // Vapor 4.x requires macOS 10.15+; without an explicit platform pin
    // SPM defaults the executable to macOS 10.13, producing
    // "executable 'App' requires macos 10.13, but depends on the product
    // 'Vapor' which requires macos 10.15" on every CI run.
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "vapor-saas-billing-engine", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.118.0")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                "App",
                .product(name: "XCTVapor", package: "vapor")
            ]
        )
    ]
)
