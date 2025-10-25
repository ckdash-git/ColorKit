# ColorsKit

[![version](https://img.shields.io/github/v/tag/ckdash-git/ColorsKit?label=version)](https://github.com/ckdash-git/ColorsKit/tags) [![lines of code](https://tokei.rs/b1/github/ckdash-git/ColorsKit?category=code)](https://github.com/ckdash-git/ColorsKit) [![license](https://img.shields.io/github/license/ckdash-git/ColorsKit)](https://github.com/ckdash-git/ColorsKit/blob/main/LICENSE)

Pragmatic color utilities for SwiftUI and UIKit.

ColorsKit helps you parse hex colors, check accessibility contrast, generate palettes, build gradients, and simulate color‑vision deficiencies — all with a tiny, focused API that feels at home in Swift.

## Installation (SPM)
Add the package to Xcode or your `Package.swift` using the public repo and a tag.

- URL: `https://github.com/ckdash-git/ColorsKit.git`
- Minimum platforms: iOS 13+, macOS 12+, tvOS 13+, watchOS 6+

```swift
// Package.swift
.dependencies: [
    .package(url: "https://github.com/ckdash-git/ColorsKit.git", from: "0.1.2")
]
.targets: [
    .target(
        name: "App",
        dependencies: [
            .product(name: "ColorsKit", package: "ColorsKit")
        ]
    )
]
```

In Xcode: File → Add Packages… → paste the URL → add the `ColorsKit` product.

## Installation (CocoaPods)
Add to your Podfile (iOS example):

```ruby
platform :ios, '13.0'
use_frameworks!

target 'App' do
  pod 'ColorsKit', '~> 0.1'
end
```

Then run `pod install` and import the module:

```swift
import ColorsKit
```

## 💖 Support This Project

ColorsKit is an open source project that helps developers build better color experiences in their apps. Your support helps maintain and improve this library for the entire Swift community.

### Why Sponsor?

- **🚀 Faster Development**: Sponsorship enables dedicated time for new features, bug fixes, and performance improvements
- **📚 Better Documentation**: More comprehensive guides, examples, and API documentation
- **🔧 Enhanced Tooling**: Additional utilities, CLI tools, and developer experience improvements
- **🌟 Community Growth**: Support for community contributions, issue triage, and user support

### Sponsorship Options

<div align="center">

[![GitHub Sponsors](https://img.shields.io/badge/GitHub-Sponsors-ff69b4?style=for-the-badge&logo=github)](https://github.com/sponsors/ckdash-git)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Support-orange?style=for-the-badge&logo=buy-me-a-coffee)](https://buymeacoffee.com/ckdash)

</div>

#### 🎯 GitHub Sponsors
- **Monthly Support**: Recurring sponsorship with tiered benefits
- **One-time Contributions**: Flexible support options
- **Sponsor Recognition**: Listed in project documentation and releases
- **Early Access**: Preview new features and provide feedback

#### ☕ Buy Me a Coffee
- **Quick Support**: Simple one-time or recurring donations
- **Personal Messages**: Send encouragement and feature requests
- **Community Building**: Join a supportive community of users
- **Flexible Amounts**: Choose what works for your budget

### Sponsor Benefits

| Tier | Monthly | Benefits |
|------|---------|----------|
| ☕ **Coffee** | $5 | Sponsor badge, early access to releases |
| 🌟 **Supporter** | $15 | Above + priority issue responses |
| 🚀 **Advocate** | $50 | Above + feature request priority |
| 💎 **Champion** | $100+ | Above + direct consultation access |

### Current Sponsors

*Thank you to all our amazing sponsors! Your support makes ColorsKit possible.*

<!-- SPONSORS_START -->
*Become our first sponsor and see your name here!*
<!-- SPONSORS_END -->

---

## Quick Start
```swift
import ColorsKit

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

// 🚀 Advanced Features
// Data visualization palettes
let scientificColors = DataVisualizationPalettes.viridis
let heatmapColors = DataVisualizationPalettes.heatmap

// Color harmony generation
let complementary = ColorHarmony.complementary(from: "#1A73E8")
let analogous = ColorHarmony.analogous(from: "#1A73E8", count: 5)

// Color psychology
let calmColors = ColorPsychology.colorsFor(emotion: .calm)
let primaryEmotion = ColorPsychology.primaryEmotion(for: fg)

// Perceptual color operations
let perceptualGradient = PerceptualColorMath.perceptualGradient(from: fg, to: bg, steps: 10)
let deltaE = PerceptualColorMath.deltaE2000(fg, bg)
```

## 🚀 Advanced Features

ColorsKit goes beyond basic color utilities with powerful advanced features for professional color work:

### 📊 Data Visualization Palettes
Professional color schemes optimized for charts, graphs, and scientific visualization:

```swift
// Sequential palettes for continuous data
let blues = DataVisualizationPalettes.blues
let greens = DataVisualizationPalettes.greens

// Diverging palettes for data with meaningful center
let redBlue = DataVisualizationPalettes.redBlue
let purpleGreen = DataVisualizationPalettes.purpleGreen

// Scientific colormaps (perceptually uniform)
let viridis = DataVisualizationPalettes.viridis
let plasma = DataVisualizationPalettes.plasma

// Accessibility-friendly palettes
let colorblindSafe = DataVisualizationPalettes.colorblindSafe
let highContrast = DataVisualizationPalettes.highContrast
```

### 🔬 Perceptual Color Mathematics
Advanced color space conversions and perceptually uniform operations:

```swift
// Convert between color spaces
let xyz = ColorSpaceConverter.rgbaToXYZ(rgba)
let lab = ColorSpaceConverter.xyzToLAB(xyz)
let luv = ColorSpaceConverter.xyzToLUV(xyz)

// Perceptually uniform gradients
let gradient = PerceptualColorMath.perceptualGradient(from: color1, to: color2, steps: 10)

// Perceptual color blending
let blended = PerceptualColorMath.perceptualBlend(color1, color2, ratio: 0.5)

// Delta E color difference (CIE Delta E 2000)
let difference = PerceptualColorMath.deltaE2000(color1, color2)
```

### 🎨 Color Harmony Generation
Generate harmonious color schemes based on color theory:

```swift
// Generate complementary colors
let complementary = ColorHarmony.complementary(from: "#FF6B6B")

// Create analogous color schemes
let analogous = ColorHarmony.analogous(from: "#4ECDC4", count: 5)

// Generate triadic and tetradic schemes
let triadic = ColorHarmony.triadic(from: "#45B7D1")
let tetradic = ColorHarmony.tetradic(from: "#96CEB4")

// Split complementary for balanced contrast
let splitComplementary = ColorHarmony.splitComplementary(from: "#FFEAA7")
```

### 🎭 Advanced Color Blending
Professional blend modes for sophisticated color mixing:

```swift
// Multiple blend modes available
let multiplied = BlendMode.multiply.blend(base: baseColor, overlay: overlayColor)
let screened = BlendMode.screen.blend(base: baseColor, overlay: overlayColor)
let overlayed = BlendMode.overlay.blend(base: baseColor, overlay: overlayColor)

// Soft light, hard light, color dodge, color burn, and more
let softLight = BlendMode.softLight.blend(base: baseColor, overlay: overlayColor)
let colorDodge = BlendMode.colorDodge.blend(base: baseColor, overlay: overlayColor)
```

### 🧠 Color Psychology Engine
Emotion-based color generation and analysis:

```swift
// Generate colors for specific emotions
let calmColors = ColorPsychology.colorsFor(emotion: .calm)
let energeticColors = ColorPsychology.colorsFor(emotion: .energetic)
let professionalColors = ColorPsychology.colorsFor(emotion: .professional)

// Analyze emotional properties of colors
let primaryEmotion = ColorPsychology.primaryEmotion(for: rgba)
let emotionalProfile = ColorPsychology.emotionalProfile(for: rgba)

// Generate multi-emotion palettes
let palette = ColorPsychology.generatePalette(for: [.trustworthy, .creative], count: 8)
```

### 🌡️ Temperature & Advanced Gradients
Multiple interpolation methods and temperature-based color schemes:

```swift
// Different interpolation methods
let linearGradient = GradientGenerator.generate(from: color1, to: color2, steps: 10, method: .linear)
let perceptualGradient = GradientGenerator.generate(from: color1, to: color2, steps: 10, method: .perceptual)
let hslGradient = GradientGenerator.generate(from: color1, to: color2, steps: 10, method: .hsl)

// Temperature-based gradients
let thermal = TemperatureGradient.thermal(steps: 20)
let coolToWarm = TemperatureGradient.coolToWarm(steps: 15)
```

### SwiftUI
```swift
import SwiftUI
import ColorsKit

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
import ColorsKit

let primary = UIColor(hex: "#0A84FF")
let dynamic = UIColor.dynamic(lightHex: "#FFFFFF", darkHex: "#000000")
```

## Example CLI
A tiny command‑line demo lives in `Example/ConsumerSample/`.

- Run: `cd Example/ConsumerSample && swift run`
- Shows: hex parsing, contrast ratio, palette generation, and color‑blindness simulation.

## 📱 Comprehensive iOS Demo App
Explore all ColorsKit features with our full-featured SwiftUI demo app in `Example/iOSAppDemo/`:

### Features Showcased:
- **🎨 Color Harmony**: Generate complementary, analogous, triadic, and tetradic color schemes
- **🔬 Perceptual Colors**: Color space conversions, perceptual gradients, and Delta E analysis  
- **🎭 Blending Modes**: 12 different blend modes with real-time preview
- **🧠 Color Psychology**: Emotion-based color generation and analysis
- **📊 Data Visualization**: Scientific colormaps, heatmaps, and specialized gradients
- **🌡️ Temperature Gradients**: Multiple interpolation methods and thermal imaging colors

### Running the Demo:
```bash
cd Example/iOSAppDemo
open ColorsKitDemo.xcodeproj
# Build and run in Xcode or iOS Simulator
```

The demo app serves as both a showcase and reference implementation for integrating ColorsKit's advanced features into iOS applications.

## Modules at a Glance
- `ColorCore`: `RGBA`, `HexColorFormatter`, `ColorMath`, `Accessibility`, `Theme`, `ThemeManager`, `PerceptualColorMath`, `ColorSpaceConverter`, `ColorHarmony`, `BlendMode`
- `ColorUtilities`: `PaletteGenerator`, `AccessibilityUtils`, `ColorBlindnessSimulator`, `ColorPsychology`, `EmotionalCategory`, `GradientGenerator`, `TemperatureGradient`, `WhiteBalancePresets`
- `ColorExtensions`: SwiftUI/UIColor helpers, gradients, `GradientBuilder`, `SwiftUIGradientBuilder`
- `ColorPalettes`: `DataVisualizationPalettes`, predefined themes (`defaultLight`, `defaultDark`, `materialBlue`), scientific colormaps

## Platform Notes
- `Color.dynamic` bridges to `Color(uiColor:)` on iOS/tvOS.
- On iOS/tvOS < 15, `Color.dynamic` falls back to the light variant.
- CocoaPods support: iOS and macOS in `0.1.0`; tvOS/watchOS coming in a follow‑up release.

## Versioning
This repo follows semantic versioning. Start with `0.1.0` and evolve via tags.

## License & Trademarks
Apache-2.0. See `LICENSE` and `NOTICE`. "ColorsKit" is a trademark — see `TRADEMARKS.md`.

Community: See `CONTRIBUTING.md` (DCO) and `CODE_OF_CONDUCT.md`.
