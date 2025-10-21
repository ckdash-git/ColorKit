// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ColorKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v12),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "ColorKit",
            targets: ["ColorKit"]
        ),
    ],
    targets: [
        // Core models and algorithms
        .target(
            name: "ColorCore",
            path: "Sources/ColorCore"
        ),
        // Utilities like contrast checking, palette generators, simulators
        .target(
            name: "ColorUtilities",
            dependencies: ["ColorCore"],
            path: "Sources/ColorUtilities"
        ),
        // UIKit & SwiftUI extensions, gradient builders
        .target(
            name: "ColorExtensions",
            dependencies: ["ColorCore", "ColorUtilities"],
            path: "Sources/ColorExtensions"
        ),
        // Predefined palettes
        .target(
            name: "ColorPalettes",
            dependencies: ["ColorCore"],
            path: "Sources/ColorPalettes"
        ),
        // Umbrella target that re-exports all modules for a single import
        .target(
            name: "ColorKit",
            dependencies: ["ColorCore", "ColorUtilities", "ColorExtensions", "ColorPalettes"],
            path: "Sources/ColorKit"
        ),
        // Tests
        .testTarget(
            name: "UnitTests",
            dependencies: ["ColorKit"],
            path: "Tests/UnitTests"
        ),

    ]
)
