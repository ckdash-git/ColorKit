import Foundation

// Core RGBA model using sRGB color space
public struct RGBA: Equatable {
    public var r: Double // 0...1
    public var g: Double // 0...1
    public var b: Double // 0...1
    public var a: Double // 0...1

    public init(r: Double, g: Double, b: Double, a: Double = 1.0) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    public static func clamp(_ v: Double) -> Double { max(0.0, min(1.0, v)) }
}

// MARK: - Hex parsing and formatting
public enum HexParsingError: Error { case invalidFormat }

public struct HexColorFormatter {
    /// Parse hex strings like "#RGB", "RGB", "#RRGGBB", "RRGGBB", "#RRGGBBAA", "RRGGBBAA"
    public static func parse(_ hex: String) throws -> RGBA {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .lowercased()

        func val(_ s: String) -> Double { Double(Int(s, radix: 16) ?? 0) / 255.0 }

        switch cleaned.count {
        case 3: // RGB
            let r = String(repeating: cleaned[cleaned.startIndex], count: 2)
            let g = String(repeating: cleaned[cleaned.index(cleaned.startIndex, offsetBy: 1)], count: 2)
            let b = String(repeating: cleaned[cleaned.index(cleaned.startIndex, offsetBy: 2)], count: 2)
            return RGBA(r: val(r), g: val(g), b: val(b))
        case 6: // RRGGBB
            let r = String(cleaned.prefix(2))
            let g = String(cleaned.dropFirst(2).prefix(2))
            let b = String(cleaned.dropFirst(4).prefix(2))
            return RGBA(r: val(r), g: val(g), b: val(b))
        case 8: // RRGGBBAA (alpha at end)
            let r = String(cleaned.prefix(2))
            let g = String(cleaned.dropFirst(2).prefix(2))
            let b = String(cleaned.dropFirst(4).prefix(2))
            let a = String(cleaned.dropFirst(6).prefix(2))
            return RGBA(r: val(r), g: val(g), b: val(b), a: val(a))
        default:
            throw HexParsingError.invalidFormat
        }
    }

    /// Format to #RRGGBB or #RRGGBBAA (if includeAlpha)
    public static func format(_ rgba: RGBA, includeAlpha: Bool = false) -> String {
        func hex2(_ v: Double) -> String {
            let iv = max(0, min(255, Int(round(v * 255.0))))
            return String(format: "%02X", iv)
        }
        let base = "#" + hex2(rgba.r) + hex2(rgba.g) + hex2(rgba.b)
        return includeAlpha ? base + hex2(rgba.a) : base
    }
}

// MARK: - Color math
public struct ColorMath {
    /// WCAG relative luminance in sRGB
    public static func relativeLuminance(_ c: RGBA) -> Double {
        func linearize(_ v: Double) -> Double {
            return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        let R = linearize(c.r)
        let G = linearize(c.g)
        let B = linearize(c.b)
        return 0.2126 * R + 0.7152 * G + 0.0722 * B
    }

    /// WCAG contrast ratio between two colors
    public static func contrastRatio(_ c1: RGBA, _ c2: RGBA) -> Double {
        let L1 = relativeLuminance(c1)
        let L2 = relativeLuminance(c2)
        let hi = max(L1, L2)
        let lo = min(L1, L2)
        return (hi + 0.05) / (lo + 0.05)
    }

    /// Lighten/darken by percentage (-1.0...+1.0)
    public static func adjustBrightness(_ c: RGBA, amount: Double) -> RGBA {
        let amt = max(-1.0, min(1.0, amount))
        let r = RGBA.clamp(c.r + amt)
        let g = RGBA.clamp(c.g + amt)
        let b = RGBA.clamp(c.b + amt)
        return RGBA(r: r, g: g, b: b, a: c.a)
    }

    /// Blend two colors (alpha compositing on c2)
    public static func blend(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let a = top.a + bottom.a * (1 - top.a)
        guard a > 0 else { return RGBA(r: 0, g: 0, b: 0, a: 0) }
        let r = (top.r * top.a + bottom.r * bottom.a * (1 - top.a)) / a
        let g = (top.g * top.a + bottom.g * bottom.a * (1 - top.a)) / a
        let b = (top.b * top.a + bottom.b * bottom.a * (1 - top.a)) / a
        return RGBA(r: r, g: g, b: b, a: a)
    }
}

// MARK: - Accessibility helpers
public enum WCAGLevel { case AA, AAA }

public struct Accessibility {
    /// Check contrast ratio against WCAG thresholds (normal text)
    public static func meets(_ level: WCAGLevel, foreground: RGBA, background: RGBA) -> Bool {
        let ratio = ColorMath.contrastRatio(foreground, background)
        switch level {
        case .AA: return ratio >= 4.5
        case .AAA: return ratio >= 7.0
        }
    }
}

// MARK: - Theme
public struct Theme: Sendable {
    public let name: String
    /// Map of token -> hex string (e.g. "primary": "#0A84FF")
    public let colors: [String: String]

    public init(name: String, colors: [String: String]) {
        self.name = name
        self.colors = colors
    }

    public func rgba(for key: String) -> RGBA? {
        guard let hex = colors[key] else { return nil }
        return try? HexColorFormatter.parse(hex)
    }
}

@MainActor public final class ThemeManager {
    public static let shared = ThemeManager()

    public private(set) var current: Theme
    public var darkModeFallback: Theme?

    public init(initial: Theme = Theme(name: "Default", colors: [
        "primary": "#0A84FF",
        "secondary": "#5E5CE6",
        "background": "#FFFFFF",
        "text": "#000000",
        "danger": "#FF3B30"
    ])) {
        self.current = initial
    }

    public func apply(theme: Theme) { self.current = theme }
}