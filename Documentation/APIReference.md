# ColorsKit API Reference

This document provides a high-level overview of the ColorsKit modules and key types.

- Platforms: iOS 13+, macOS 12+, tvOS 13+, watchOS 6+
- Repo: `https://github.com/ckdash-git/ColorsKit.git`

## Modules

- ColorCore
  - `struct RGBA` — sRGB color representation with components in 0...1
  - `HexColorFormatter` — Parse and format hex strings (RGB, RGBA)
  - `ColorMath` — Relative luminance and contrast ratio
  - `Accessibility` — WCAG AA/AAA compliance checks
  - `Theme` — Token-based color theme
  - `ThemeManager` — Manage current theme

- ColorUtilities
  - `PaletteGenerator` — Generate tints/shades around a base color
  - `AccessibilityUtils` — Convenience helpers for hex-based contrast
  - `ColorBlindnessSimulator` — Approximate protanopia/deuteranopia/tritanopia simulation

- ColorExtensions
  - `UIColor.init?(hex:)` — Create UIKit color from hex
  - `UIColor.dynamic(lightHex:darkHex:)` — Dynamic color adapting to dark mode
  - `GradientBuilder.layer(hexColors:...)` — Build `CAGradientLayer`
  - `Color.init?(hex:)` — Create SwiftUI color from hex
  - `Color.dynamic(lightHex:darkHex:)` — Dynamic SwiftUI color (bridges via UIKit)
  - `SwiftUIGradientBuilder.linear(hexColors:...)` — Build `LinearGradient`

- ColorPalettes
  - `Palettes.defaultLight` — Predefined light theme
  - `Palettes.defaultDark` — Predefined dark theme
  - `Palettes.materialBlue(name:)` — Material-style blue palette

## Key Functions

### HexColorFormatter
- `parse(_ hex: String) throws -> RGBA`
- `format(_ rgba: RGBA, includeAlpha: Bool = false) -> String`

### ColorMath
- `relativeLuminance(_ c: RGBA) -> Double`
- `contrastRatio(_ c1: RGBA, _ c2: RGBA) -> Double`
- `adjustBrightness(_ c: RGBA, amount: Double) -> RGBA`
- `blend(_ top: RGBA, _ bottom: RGBA) -> RGBA`

### Accessibility
- `meets(_ level: WCAGLevel, foreground: RGBA, background: RGBA) -> Bool`

### Theme/ThemeManager
- `Theme.rgba(for key: String) -> RGBA?`
- `ThemeManager.apply(theme:)`
- `ThemeManager.current`

### PaletteGenerator
- `generate(from:steps:range:) -> [String]`

### ColorBlindnessSimulator
- `simulate(_ type: ColorBlindnessType, rgba: RGBA) -> RGBA`
- `simulateHex(_ type: ColorBlindnessType, hex: String) -> String?`