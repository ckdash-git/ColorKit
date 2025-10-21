# Getting Started with ColorKit

ColorKit simplifies color management in iOS apps by providing:
- Hex-based color creation for UIKit and SwiftUI
- Dynamic theming and dark/light auto-adaptation
- Accessibility contrast checking
- Palette generators and gradient builders
- Color-blindness simulation tools

## Installation

### Swift Package Manager
Use the GitHub URL and a tagged version in Xcode or `Package.swift`.

- URL: `https://github.com/ckdash-git/ColorKit.git`
- Example `Package.swift`:

```swift
.dependencies: [
    .package(url: "https://github.com/ckdash-git/ColorKit.git", from: "0.1.1")
]
.targets: [
    .target(
        name: "App",
        dependencies: [
            .product(name: "ColorKit", package: "ColorKit")
        ]
    )
]
```

In Xcode: File → Add Packages… → paste the URL → select the `ColorKit` product.

### CocoaPods
Install via CocoaPods using the published pod `ColorsKit`:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'App' do
  pod 'ColorsKit', '~> 0.1'
end
```

Then run `pod install` and import the module in your code:

```swift
import ColorKit
```

Note: The CocoaPods pod name is `ColorsKit`, but the Swift module remains `ColorKit`.

## Usage

```swift
import ColorKit

// Hex -> SwiftUI Color
let primary = Color(hex: "#0A84FF")

// Dynamic Color (adapts to dark/light mode)
let dynamic = Color.dynamic(lightHex: "#FFFFFF", darkHex: "#000000")

// UIKit
import UIKit
let uiPrimary = UIColor(hex: "#0A84FF")
let uiDynamic = UIColor.dynamic(lightHex: "#FFFFFF", darkHex: "#000000")

// Themes
let theme = Palettes.defaultLight
ThemeManager.shared.apply(theme: theme)
let backgroundRGBA = ThemeManager.shared.current.rgba(for: "background")

// Accessibility
if let bg = backgroundRGBA, let fg = try? HexColorFormatter.parse("#000000") {
    let ratio = ColorMath.contrastRatio(fg, bg)
    print("Contrast ratio:", ratio)
    print("Meets AA:", Accessibility.meets(.AA, foreground: fg, background: bg))
}

// Palette generation
let palette = PaletteGenerator.generate(from: "#0A84FF", steps: 4)

// SwiftUI Gradient
#if canImport(SwiftUI)
import SwiftUI
let gradient = SwiftUIGradientBuilder.linear(hexColors: ["#0A84FF", "#5E5CE6"]) 
#endif
```

## Notes
- Dynamic colors use `UIColor(dynamicProvider:)` on iOS 13+ and bridge to SwiftUI via `Color(uiColor:)`.
- Contrast checks implement WCAG formulas for relative luminance.
- Color-blindness simulation uses simple matrices for demo purposes.