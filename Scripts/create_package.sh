#
//  create_package.sh
//  ColorsKit
//
//  Created by CHANDAN on 20/07/25.
//


#!/usr/bin/env bash
# scripts/create_package.sh
set -euo pipefail

NAME=${1:-ColorsKit}
ROOT_DIR=${PWD}/${NAME}

echo "Creating package ${NAME} at ${ROOT_DIR}"
mkdir -p "${ROOT_DIR}"
cd "${ROOT_DIR}"

# basic files
cat > Package.swift <<'SWIFT'
import PackageDescription

let package = Package(
    name: "ColorsKit",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(name: "ColorsKit", targets: ["ColorsKit"]),
    ],
    targets: [
        .target(
            name: "ColorsKit",
            path: "Sources/ColorsKit",
            resources: [
                // Add asset catalogs or other resources if needed
            ]),
        .testTarget(name: "ColorsKitTests", dependencies: ["ColorsKit"], path: "Tests/ColorsKitTests")
    ],
    swiftLanguageVersions: [.v5]
)
SWIFT

cat > ColorsKit.podspec <<'POD'
Pod::Spec.new do |s|
  s.name         = "ColorsKit"
  s.version      = "0.1.0"
  s.summary      = "Color helpers for iOS/macOS: hex parsing, dynamic colors, blending, contrast."
  s.homepage     = "https://github.com/your-org/ColorsKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Your Name" => "you@example.com" }
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/your-org/ColorsKit.git", :tag => s.version }
  s.source_files = "Sources/ColorsKit/**/*.swift"
  s.swift_version = "5.0"
end
POD

mkdir -p Sources/ColorsKit Tests/ColorsKitTests Examples/iOSExample .github/workflows scripts

cat > LICENSE <<'LICENSE'
MIT License
Copyright (c) 2025 Your Name
Permission is hereby granted...
LICENSE

cat > README.md <<'MD'
# ColorsKit
Utility package for colors (hex, dynamic colors, blending, contrast). Works with SPM and CocoaPods.
MD

# Add initial Swift files (minimal)
cat > Sources/ColorsKit/Colors.swift <<'SWIFT'
import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

public enum ColorsKit {
    // intentionally empty - namespace
}
SWIFT

# Add core helpers (more complete files will be added later)
cat > Sources/ColorsKit/HexColor+UIKit.swift <<'SWIFT'
#if canImport(UIKit)
import UIKit

public extension UIColor {
    /// Initialize UIColor with hex string like "#RRGGBB", "#RRGGBBAA", "RRGGBB", "RGB"
    convenience init?(hex: String) {
        let s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let str = s.hasPrefix("#") ? String(s.dropFirst()) : s

        var r: UInt64 = 0
        guard Scanner(string: str).scanHexInt64(&r) else { return nil }

        switch str.count {
        case 3: // RGB shorthand
            let rs = (r & 0xF00) >> 8, gs = (r & 0x0F0) >> 4, bs = r & 0x00F
            self.init(red: CGFloat((rs * 17))/255.0, green: CGFloat((gs * 17))/255.0, blue: CGFloat((bs * 17))/255.0, alpha: 1.0)
        case 4: // RGBA shorthand
            let rs = (r & 0xF000) >> 12, gs = (r & 0x0F00) >> 8, bs = (r & 0x00F0) >> 4, as_ = r & 0x000F
            self.init(red: CGFloat((rs * 17))/255.0, green: CGFloat((gs * 17))/255.0, blue: CGFloat((bs * 17))/255.0, alpha: CGFloat((as_ * 17))/255.0)
        case 6:
            self.init(
                red: CGFloat((r & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((r & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(r & 0x0000FF) / 255.0,
                alpha: 1.0)
        case 8:
            self.init(
                red: CGFloat((r & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((r & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((r & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(r & 0x000000FF) / 255.0)
        default:
            return nil
        }
    }
}
#endif
SWIFT

cat > Sources/ColorsKit/HexColor+SwiftUI.swift <<'SWIFT'
#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
public extension Color {
    init?(hex: String) {
        #if canImport(UIKit)
        if let ui = UIColor(hex: hex) {
            self.init(uiColor: ui)
        } else {
            return nil
        }
        #else
        return nil
        #endif
    }
}
#endif
SWIFT

cat > Sources/ColorsKit/Utilities.swift <<'SWIFT'
import Foundation
#if canImport(UIKit)
import UIKit
#endif

public extension UIColor {
    /// Returns luminance (0...1)
    var relativeLuminance: CGFloat {
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        func srgb(_ x: CGFloat) -> CGFloat {
            return (x <= 0.03928) ? (x/12.92) : pow((x+0.055)/1.055, 2.4)
        }
        return 0.2126 * srgb(r) + 0.7152 * srgb(g) + 0.0722 * srgb(b)
    }

    /// Contrast ratio between two colors as per WCAG (1...21)
    func contrastRatio(with other: UIColor) -> CGFloat {
        let l1 = max(self.relativeLuminance, other.relativeLuminance)
        let l2 = min(self.relativeLuminance, other.relativeLuminance)
        return (l1 + 0.05) / (l2 + 0.05)
    }

    /// Blend with another color by fraction (0..1)
    func blended(with other: UIColor, fraction: CGFloat) -> UIColor {
        let f = min(max(0, fraction), 1)
        var r1: CGFloat=0,g1: CGFloat=0,b1: CGFloat=0,a1: CGFloat=0
        var r2: CGFloat=0,g2: CGFloat=0,b2: CGFloat=0,a2: CGFloat=0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return UIColor(red: r1*(1-f)+r2*f,
                       green: g1*(1-f)+g2*f,
                       blue: b1*(1-f)+b2*f,
                       alpha: a1*(1-f)+a2*f)
    }
}
SWIFT

cat > Tests/ColorsKitTests/ColorsKitTests.swift <<'TEST'
import XCTest
@testable import ColorsKit

final class ColorsKitTests: XCTestCase {
    func testHexInit() {
        #if canImport(UIKit)
        let c = UIColor(hex: "#FF0000")
        XCTAssertNotNil(c)
        #endif
    }
}
TEST

cat > .github/workflows/ci.yml <<'YAML'
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Install Swift toolchain
        uses: fwal/setup-swift@v2
        with:
          swift-version: '5.9'
      - name: Run tests
        run: swift test
YAML

cat > scripts/release_spm.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
# Usage: ./scripts/release_spm.sh 0.1.0
version=${1:-}
if [ -z "$version" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi
git tag -a "v${version}" -m "Release ${version}"
git push origin "v${version}"
echo "Create GitHub release for tag v${version} and add to Package.swift releases (SPM pulls via Git tags)"
SH

cat > scripts/release_cocoapods.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
# Usage: ./scripts/release_cocoapods.sh 0.1.0
version=${1:-}
if [ -z "$version" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi
# Update version in podspec (manual step recommended)
# Run local lint
pod lib lint --allow-warnings
# Push to trunk (you must be logged in with 'pod trunk register' previously)
pod trunk push --allow-warnings ColorsKit.podspec
SH

echo "Done. Open the folder ${ROOT_DIR} and start editing!"

