# ColorKit

Pragmatic color utilities for SwiftUI and UIKit.

ColorKit helps you parse hex colors, check accessibility contrast, generate palettes, build gradients, and simulate color‑vision deficiencies — all with a tiny, focused API that feels at home in Swift.

## Features
- Hex parsing to and from `RGBA` (`#RGB`, `#RGBA`, `#RRGGBB`, `#RRGGBBAA`)
- WCAG contrast ratio and AA/AAA compliance checks
- Palette generation around a base color
- SwiftUI/UIColor helpers (dynamic light/dark, gradients)
- Color‑blindness simulation (protanopia, deuteranopia, tritanopia)

## Installation (SPM)
Add the package to Xcode or your `Package.swift` using the public repo and a tag.

- URL: `https://github.com/ckdash-git/ColorKit.git`
- Minimum platforms: iOS 13+, macOS 12+, tvOS 13+, watchOS 6+

```swift
// Package.swift
.dependencies: [
    .package(url: "https://github.com/ckdash-git/ColorKit.git", from: "0.1.0")
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

In Xcode: File → Add Packages… → paste the URL → add the `ColorKit` product.

## Quick Start
```swift
import ColorKit

// Hex → RGBA
let fg = try HexColorFormatter.parse("#1A73E8")
let bg = try HexColorFormatter.parse("#FFFFFF")

// Contrast ratio + WCAG
let ratio = ColorMath.contrastRatio(fg, bg)
let isAA = Accessibility.meets(.AA, foreground: fg, background: bg)
let isAAA = Accessibility.meets(.AAA, foreground: fg, background: bg)

// Palette around a base color
let palette = PaletteGenerator.generate(from: "#1A73E8", steps: 6, range: 0.25)

// Simulate color‑vision deficiency
let protanopia = ColorBlindnessSimulator.simulate(.protanopia, rgba: fg)
```

### SwiftUI
```swift
import SwiftUI
import ColorKit

// Create Color from hex
let primary = Color(hex: "#0A84FF")

// Dynamic light/dark Color (bridges via UIKit on iOS)
let dynamic = Color.dynamic(lightHex: "#FFFFFF", darkHex: "#000000")

// LinearGradient from hex list
let gradient = SwiftUIGradientBuilder.linear(hexColors: ["#0A84FF", "#5E5CE6"]) 
```

### UIKit
```swift
import UIKit
import ColorKit

let primary = UIColor(hex: "#0A84FF")
let dynamic = UIColor.dynamic(lightHex: "#FFFFFF", darkHex: "#000000")
```

## Example CLI
A tiny command‑line demo lives in `Example/ConsumerSample/`.

- Run: `cd Example/ConsumerSample && swift run`
- Shows: hex parsing, contrast ratio, palette generation, and color‑blindness simulation.

## Modules at a Glance
- `ColorCore`: `RGBA`, `HexColorFormatter`, `ColorMath`, `Accessibility`, `Theme`, `ThemeManager`
- `ColorUtilities`: `PaletteGenerator`, `AccessibilityUtils`, `ColorBlindnessSimulator`
- `ColorExtensions`: SwiftUI/UIColor helpers, gradients
- `ColorPalettes`: Predefined themes and palette helpers

## Platform Notes
- `Color.dynamic` bridges to `Color(uiColor:)` on iOS/tvOS.
- On iOS/tvOS < 15, `Color.dynamic` falls back to the light variant.

## Versioning
This repo follows semantic versioning. Start with `0.1.0` and evolve via tags.

## License
MIT. See `LICENSE`.

## Contributing
Issues and PRs are welcome. If you have an idea or find a bug, open an issue with a short repro or proposal. Thank you!