// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ConsumerSample",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "ConsumerSample", targets: ["ConsumerSample"])
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "ConsumerSample",
            dependencies: [
                .product(name: "ColorKit", package: "ColorKit")
            ]
        )
    ]
)
