// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iOSAppDemo",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "iOSAppDemo",
            targets: ["iOSAppDemo"]
        )
    ],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .target(
            name: "iOSAppDemo",
            dependencies: [
                .product(name: "ColorsKit", package: "ColorsKit")
            ],
            path: "Sources"
        )
    ]
)