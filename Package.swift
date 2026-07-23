// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VaporSaaSBillingEngine",
    // CI runs on macos-15-arm64 with Swift 6.0.3. The transitive
    // async-http-client requires macOS 13+ for Network.framework
    // (NWPOSIXError). `.v13` was being normalized to macOS 10.13 in the
    // build (SPM 6.0 quirk with the executable target's platform floor);
    // using a string version explicitly avoids the macOS-13-vs-10.13
    // enum aliasing.
    platforms: [.macOS("13.0")],
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
