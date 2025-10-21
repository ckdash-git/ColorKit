import Foundation
#if SWIFT_PACKAGE
import ColorCore
#endif

// MARK: - Palette Generator
public struct PaletteGenerator {
    /// Generate tints and shades around a base color
    /// - Parameters:
    ///   - base: Base color (hex string)
    ///   - steps: Number of tints/shades per side
    ///   - range: Brightness adjustment range (0...1)
    /// - Returns: Array of hex strings ordered: shades -> base -> tints
    public static func generate(from base: String, steps: Int = 5, range: Double = 0.25) -> [String] {
        guard let baseRGBA = try? HexColorFormatter.parse(base) else { return [] }
        var colors: [RGBA] = []
        // Shades
        for i in stride(from: steps, through: 1, by: -1) {
            let amt = -range * Double(i) / Double(steps)
            colors.append(ColorMath.adjustBrightness(baseRGBA, amount: amt))
        }
        // Base
        colors.append(baseRGBA)
        // Tints
        for i in 1...steps {
            let amt = range * Double(i) / Double(steps)
            colors.append(ColorMath.adjustBrightness(baseRGBA, amount: amt))
        }
        return colors.map { HexColorFormatter.format($0) }
    }
}

// MARK: - Accessibility utilities
public struct AccessibilityUtils {
    public static func contrastRatio(hex1: String, hex2: String) -> Double? {
        guard let c1 = try? HexColorFormatter.parse(hex1), let c2 = try? HexColorFormatter.parse(hex2) else { return nil }
        return ColorMath.contrastRatio(c1, c2)
    }

    public static func meetsAA(foreground: String, background: String) -> Bool {
        guard let f = try? HexColorFormatter.parse(foreground), let b = try? HexColorFormatter.parse(background) else { return false }
        return Accessibility.meets(.AA, foreground: f, background: b)
    }

    public static func meetsAAA(foreground: String, background: String) -> Bool {
        guard let f = try? HexColorFormatter.parse(foreground), let b = try? HexColorFormatter.parse(background) else { return false }
        return Accessibility.meets(.AAA, foreground: f, background: b)
    }
}

// MARK: - Color Blindness Simulation (approximate)
public enum ColorBlindnessType { case protanopia, deuteranopia, tritanopia }

public struct ColorBlindnessSimulator {
    // Simple matrix approximations for demonstration purposes
    // Note: For clinical-grade simulation consider validated matrices from research literature
    private static let protanopiaMatrix: [[Double]] = [
        [0.56667, 0.43333, 0.0],
        [0.55833, 0.44167, 0.0],
        [0.0,     0.24167, 0.75833]
    ]

    private static let deuteranopiaMatrix: [[Double]] = [
        [0.625, 0.375, 0.0],
        [0.7,   0.3,   0.0],
        [0.0,   0.3,   0.7]
    ]

    private static let tritanopiaMatrix: [[Double]] = [
        [0.95,  0.05,  0.0],
        [0.0,   0.433, 0.567],
        [0.0,   0.475, 0.525]
    ]

    public static func simulate(_ type: ColorBlindnessType, rgba: RGBA) -> RGBA {
        let m: [[Double]]
        switch type {
        case .protanopia: m = protanopiaMatrix
        case .deuteranopia: m = deuteranopiaMatrix
        case .tritanopia: m = tritanopiaMatrix
        }
        let r = RGBA.clamp(m[0][0] * rgba.r + m[0][1] * rgba.g + m[0][2] * rgba.b)
        let g = RGBA.clamp(m[1][0] * rgba.r + m[1][1] * rgba.g + m[1][2] * rgba.b)
        let b = RGBA.clamp(m[2][0] * rgba.r + m[2][1] * rgba.g + m[2][2] * rgba.b)
        return RGBA(r: r, g: g, b: b, a: rgba.a)
    }

    public static func simulateHex(_ type: ColorBlindnessType, hex: String) -> String? {
        guard let rgba = try? HexColorFormatter.parse(hex) else { return nil }
        return HexColorFormatter.format(simulate(type, rgba: rgba))
    }
}