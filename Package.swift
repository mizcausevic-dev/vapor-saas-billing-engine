// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "VaporSaaSBillingEngine",
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
