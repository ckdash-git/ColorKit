import Foundation

// Core RGBA model using sRGB color space
public struct RGBA: Equatable, Sendable {
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

// MARK: - Perceptually Uniform Color Spaces

/// CIE XYZ color space (1931 2° Standard Observer, D65 illuminant)
public struct CIEXYZ: Equatable, Sendable {
    public var x: Double // 0...95.047 (D65)
    public var y: Double // 0...100.0
    public var z: Double // 0...108.883 (D65)
    
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

/// CIE L*a*b* color space (perceptually uniform)
public struct CIELAB: Equatable, Sendable {
    public var l: Double // 0...100 (lightness)
    public var a: Double // -128...127 (green-red)
    public var b: Double // -128...127 (blue-yellow)
    
    public init(l: Double, a: Double, b: Double) {
        self.l = l
        self.a = a
        self.b = b
    }
}

/// CIE L*u*v* color space (perceptually uniform)
public struct CIELUV: Equatable, Sendable {
    public var l: Double // 0...100 (lightness)
    public var u: Double // -134...220
    public var v: Double // -140...122
    
    public init(l: Double, u: Double, v: Double) {
        self.l = l
        self.u = u
        self.v = v
    }
}

// MARK: - Color Space Conversions
public struct ColorSpaceConverter {
    
    // MARK: - Constants for D65 illuminant
    private static let xn: Double = 95.047  // D65 illuminant
    private static let yn: Double = 100.0
    private static let zn: Double = 108.883
    
    // MARK: - sRGB to CIE XYZ
    public static func rgbaToXYZ(_ rgba: RGBA) -> CIEXYZ {
        // Convert sRGB to linear RGB
        func sRGBToLinear(_ c: Double) -> Double {
            return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        
        let r = sRGBToLinear(rgba.r)
        let g = sRGBToLinear(rgba.g)
        let b = sRGBToLinear(rgba.b)
        
        // sRGB to XYZ matrix (D65)
        let x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
        let y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
        let z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041
        
        return CIEXYZ(x: x * 100, y: y * 100, z: z * 100)
    }
    
    // MARK: - CIE XYZ to sRGB
    public static func xyzToRGBA(_ xyz: CIEXYZ) -> RGBA {
        let x = xyz.x / 100
        let y = xyz.y / 100
        let z = xyz.z / 100
        
        // XYZ to sRGB matrix (D65)
        let r =  x * 3.2404542 + y * -1.5371385 + z * -0.4985314
        let g =  x * -0.9692660 + y * 1.8760108 + z * 0.0415560
        let b =  x * 0.0556434 + y * -0.2040259 + z * 1.0572252
        
        // Linear RGB to sRGB
        func linearToSRGB(_ c: Double) -> Double {
            let clamped = max(0, min(1, c))
            return clamped <= 0.0031308 ? clamped * 12.92 : 1.055 * pow(clamped, 1.0/2.4) - 0.055
        }
        
        return RGBA(
            r: RGBA.clamp(linearToSRGB(r)),
            g: RGBA.clamp(linearToSRGB(g)),
            b: RGBA.clamp(linearToSRGB(b)),
            a: 1.0
        )
    }
    
    // MARK: - CIE XYZ to CIE L*a*b*
    public static func xyzToLAB(_ xyz: CIEXYZ) -> CIELAB {
        func f(_ t: Double) -> Double {
            let delta = 6.0 / 29.0
            return t > pow(delta, 3) ? pow(t, 1.0/3.0) : t / (3 * delta * delta) + 4.0/29.0
        }
        
        let fx = f(xyz.x / xn)
        let fy = f(xyz.y / yn)
        let fz = f(xyz.z / zn)
        
        let l = 116 * fy - 16
        let a = 500 * (fx - fy)
        let b = 200 * (fy - fz)
        
        return CIELAB(l: l, a: a, b: b)
    }
    
    // MARK: - CIE L*a*b* to CIE XYZ
    public static func labToXYZ(_ lab: CIELAB) -> CIEXYZ {
        let fy = (lab.l + 16) / 116
        let fx = lab.a / 500 + fy
        let fz = fy - lab.b / 200
        
        func finv(_ t: Double) -> Double {
            let delta = 6.0 / 29.0
            return t > delta ? pow(t, 3) : 3 * delta * delta * (t - 4.0/29.0)
        }
        
        let x = xn * finv(fx)
        let y = yn * finv(fy)
        let z = zn * finv(fz)
        
        return CIEXYZ(x: x, y: y, z: z)
    }
    
    // MARK: - CIE XYZ to CIE L*u*v*
    public static func xyzToLUV(_ xyz: CIEXYZ) -> CIELUV {
        let yr = xyz.y / yn
        let l = yr > pow(6.0/29.0, 3) ? 116 * pow(yr, 1.0/3.0) - 16 : pow(29.0/3.0, 3) * yr
        
        let denom = xyz.x + 15 * xyz.y + 3 * xyz.z
        let denomN = xn + 15 * yn + 3 * zn
        
        guard denom != 0 && denomN != 0 else {
            return CIELUV(l: l, u: 0, v: 0)
        }
        
        let up = 4 * xyz.x / denom
        let vp = 9 * xyz.y / denom
        let upN = 4 * xn / denomN
        let vpN = 9 * yn / denomN
        
        let u = 13 * l * (up - upN)
        let v = 13 * l * (vp - vpN)
        
        return CIELUV(l: l, u: u, v: v)
    }
    
    // MARK: - CIE L*u*v* to CIE XYZ
    public static func luvToXYZ(_ luv: CIELUV) -> CIEXYZ {
        let yr = luv.l > 8 ? pow((luv.l + 16) / 116, 3) : luv.l / pow(29.0/3.0, 3)
        let y = yr * yn
        
        let denomN = xn + 15 * yn + 3 * zn
        let upN = 4 * xn / denomN
        let vpN = 9 * yn / denomN
        
        guard luv.l != 0 else {
            return CIEXYZ(x: 0, y: 0, z: 0)
        }
        
        let up = luv.u / (13 * luv.l) + upN
        let vp = luv.v / (13 * luv.l) + vpN
        
        guard vp != 0 else {
            return CIEXYZ(x: 0, y: y, z: 0)
        }
        
        let x = y * 9 * up / (4 * vp)
        let z = y * (12 - 3 * up - 20 * vp) / (4 * vp)
        
        return CIEXYZ(x: x, y: y, z: z)
    }
    
    // MARK: - Convenience conversions
    public static func rgbaToLAB(_ rgba: RGBA) -> CIELAB {
        return xyzToLAB(rgbaToXYZ(rgba))
    }
    
    public static func labToRGBA(_ lab: CIELAB) -> RGBA {
        return xyzToRGBA(labToXYZ(lab))
    }
    
    public static func rgbaToLUV(_ rgba: RGBA) -> CIELUV {
        return xyzToLUV(rgbaToXYZ(rgba))
    }
    
    public static func luvToRGBA(_ luv: CIELUV) -> RGBA {
        return xyzToRGBA(luvToXYZ(luv))
    }
}

// MARK: - Perceptual Color Operations
public struct PerceptualColorMath {
    
    /// Calculate perceptual distance between two colors using CIE Delta E 2000
    /// This is more accurate than RGB distance for human perception
    public static func deltaE2000(_ color1: RGBA, _ color2: RGBA) -> Double {
        let lab1 = ColorSpaceConverter.rgbaToLAB(color1)
        let lab2 = ColorSpaceConverter.rgbaToLAB(color2)
        
        // Simplified Delta E 2000 calculation
        // For full implementation, consider using a specialized color science library
        let deltaL = lab2.l - lab1.l
        let deltaA = lab2.a - lab1.a
        let deltaB = lab2.b - lab1.b
        
        let c1 = sqrt(lab1.a * lab1.a + lab1.b * lab1.b)
        let c2 = sqrt(lab2.a * lab2.a + lab2.b * lab2.b)
        let deltaC = c2 - c1
        
        let deltaH = sqrt(deltaA * deltaA + deltaB * deltaB - deltaC * deltaC)
        
        let sl = 1.0
        let sc = 1 + 0.045 * c1
        let sh = 1 + 0.015 * c1
        
        let deltaE = sqrt(
            pow(deltaL / sl, 2) +
            pow(deltaC / sc, 2) +
            pow(deltaH / sh, 2)
        )
        
        return deltaE
    }
    
    /// Blend two colors in perceptually uniform LAB space
    /// This produces more natural-looking color transitions
    public static func perceptualBlend(_ color1: RGBA, _ color2: RGBA, ratio: Double) -> RGBA {
        let lab1 = ColorSpaceConverter.rgbaToLAB(color1)
        let lab2 = ColorSpaceConverter.rgbaToLAB(color2)
        
        let t = max(0, min(1, ratio))
        let blendedLab = CIELAB(
            l: lab1.l + (lab2.l - lab1.l) * t,
            a: lab1.a + (lab2.a - lab1.a) * t,
            b: lab1.b + (lab2.b - lab1.b) * t
        )
        
        return ColorSpaceConverter.labToRGBA(blendedLab)
    }
    
    /// Generate a perceptually uniform gradient between colors
    public static func perceptualGradient(from start: RGBA, to end: RGBA, steps: Int) -> [RGBA] {
        guard steps > 1 else { return [start] }
        
        var colors: [RGBA] = []
        for i in 0..<steps {
            let ratio = Double(i) / Double(steps - 1)
            colors.append(perceptualBlend(start, end, ratio: ratio))
        }
        return colors
    }
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

// MARK: - Advanced Blending Modes

/// Enumeration of available blending modes
public enum BlendMode: String, Sendable, CaseIterable {
    case normal = "normal"
    case multiply = "multiply"
    case screen = "screen"
    case overlay = "overlay"
    case softLight = "softLight"
    case hardLight = "hardLight"
    case colorDodge = "colorDodge"
    case colorBurn = "colorBurn"
    case darken = "darken"
    case lighten = "lighten"
    case difference = "difference"
    case exclusion = "exclusion"
    case hue = "hue"
    case saturation = "saturation"
    case color = "color"
    case luminosity = "luminosity"
}

/// Advanced color blending operations
public struct AdvancedBlending {
    
    /// Apply a specific blending mode to two colors
    /// - Parameters:
    ///   - top: The top (foreground) color
    ///   - bottom: The bottom (background) color
    ///   - mode: The blending mode to apply
    ///   - opacity: Opacity of the top color (0.0 to 1.0)
    /// - Returns: The blended color result
    public static func blend(_ top: RGBA, _ bottom: RGBA, mode: BlendMode, opacity: Double = 1.0) -> RGBA {
        let adjustedTop = RGBA(r: top.r, g: top.g, b: top.b, a: top.a * RGBA.clamp(opacity))
        
        switch mode {
        case .normal:
            return ColorMath.blend(adjustedTop, bottom)
        case .multiply:
            return multiply(adjustedTop, bottom)
        case .screen:
            return screen(adjustedTop, bottom)
        case .overlay:
            return overlay(adjustedTop, bottom)
        case .softLight:
            return softLight(adjustedTop, bottom)
        case .hardLight:
            return hardLight(adjustedTop, bottom)
        case .colorDodge:
            return colorDodge(adjustedTop, bottom)
        case .colorBurn:
            return colorBurn(adjustedTop, bottom)
        case .darken:
            return darken(adjustedTop, bottom)
        case .lighten:
            return lighten(adjustedTop, bottom)
        case .difference:
            return difference(adjustedTop, bottom)
        case .exclusion:
            return exclusion(adjustedTop, bottom)
        case .hue:
            return hue(adjustedTop, bottom)
        case .saturation:
            return saturation(adjustedTop, bottom)
        case .color:
            return color(adjustedTop, bottom)
        case .luminosity:
            return luminosity(adjustedTop, bottom)
        }
    }
    
    // MARK: - Basic Blending Modes
    
    private static func multiply(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let blended = RGBA(
            r: top.r * bottom.r,
            g: top.g * bottom.g,
            b: top.b * bottom.b,
            a: 1.0
        )
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func screen(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let blended = RGBA(
            r: 1.0 - (1.0 - top.r) * (1.0 - bottom.r),
            g: 1.0 - (1.0 - top.g) * (1.0 - bottom.g),
            b: 1.0 - (1.0 - top.b) * (1.0 - bottom.b),
            a: 1.0
        )
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func overlay(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        func overlayChannel(_ a: Double, _ b: Double) -> Double {
            return b < 0.5 ? 2.0 * a * b : 1.0 - 2.0 * (1.0 - a) * (1.0 - b)
        }
        
        let blended = RGBA(
            r: overlayChannel(top.r, bottom.r),
            g: overlayChannel(top.g, bottom.g),
            b: overlayChannel(top.b, bottom.b),
            a: 1.0
        )
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func softLight(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        func softLightChannel(_ a: Double, _ b: Double) -> Double {
            if a <= 0.5 {
                return b - (1.0 - 2.0 * a) * b * (1.0 - b)
            } else {
                let d = b <= 0.25 ? ((16.0 * b - 12.0) * b + 4.0) * b : sqrt(b)
                return b + (2.0 * a - 1.0) * (d - b)
            }
        }
        
        let blended = RGBA(
            r: softLightChannel(top.r, bottom.r),
            g: softLightChannel(top.g, bottom.g),
            b: softLightChannel(top.b, bottom.b),
            a: 1.0
        )
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func hardLight(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        func hardLightChannel(_ a: Double, _ b: Double) -> Double {
            return a < 0.5 ? 2.0 * a * b : 1.0 - 2.0 * (1.0 - a) * (1.0 - b)
        }
        
        let blended = RGBA(
            r: hardLightChannel(top.r, bottom.r),
            g: hardLightChannel(top.g, bottom.g),
            b: hardLightChannel(top.b, bottom.b),
            a: 1.0
        )
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func colorDodge(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        func colorDodgeChannel(_ a: Double, _ b: Double) -> Double {
            if a >= 1.0 { return 1.0 }
            return min(1.0, b / (1.0 - a))
        }
        
        let blended = RGBA(
            r: colorDodgeChannel(top.r, bottom.r),
            g: colorDodgeChannel(top.g, bottom.g),
            b: colorDodgeChannel(top.b, bottom.b),
            a: 1.0
        )
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func colorBurn(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        func colorBurnChannel(_ a: Double, _ b: Double) -> Double {
            if a <= 0.0 { return 0.0 }
            return max(0.0, 1.0 - (1.0 - b) / a)
        }
        
        let blended = RGBA(
            r: colorBurnChannel(top.r, bottom.r),
            g: colorBurnChannel(top.g, bottom.g),
            b: colorBurnChannel(top.b, bottom.b),
            a: 1.0
        )
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func darken(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let blended = RGBA(
            r: min(top.r, bottom.r),
            g: min(top.g, bottom.g),
            b: min(top.b, bottom.b),
            a: 1.0
        )
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func lighten(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let blended = RGBA(
            r: max(top.r, bottom.r),
            g: max(top.g, bottom.g),
            b: max(top.b, bottom.b),
            a: 1.0
        )
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func difference(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let blended = RGBA(
            r: abs(top.r - bottom.r),
            g: abs(top.g - bottom.g),
            b: abs(top.b - bottom.b),
            a: 1.0
        )
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func exclusion(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let blended = RGBA(
            r: top.r + bottom.r - 2.0 * top.r * bottom.r,
            g: top.g + bottom.g - 2.0 * top.g * bottom.g,
            b: top.b + bottom.b - 2.0 * top.b * bottom.b,
            a: 1.0
        )
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    // MARK: - HSL-based Blending Modes
    
    private static func hue(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let topHSL = rgbaToHSL(top)
        let bottomHSL = rgbaToHSL(bottom)
        let blended = hslToRGBA(HSL(h: topHSL.h, s: bottomHSL.s, l: bottomHSL.l))
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func saturation(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let topHSL = rgbaToHSL(top)
        let bottomHSL = rgbaToHSL(bottom)
        let blended = hslToRGBA(HSL(h: bottomHSL.h, s: topHSL.s, l: bottomHSL.l))
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func color(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let topHSL = rgbaToHSL(top)
        let bottomHSL = rgbaToHSL(bottom)
        let blended = hslToRGBA(HSL(h: topHSL.h, s: topHSL.s, l: bottomHSL.l))
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    private static func luminosity(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let topHSL = rgbaToHSL(top)
        let bottomHSL = rgbaToHSL(bottom)
        let blended = hslToRGBA(HSL(h: bottomHSL.h, s: bottomHSL.s, l: topHSL.l))
        return ColorMath.blend(RGBA(r: blended.r, g: blended.g, b: blended.b, a: top.a), bottom)
    }
    
    // MARK: - HSL Conversion Helpers
    
    private struct HSL {
        let h: Double // 0...360
        let s: Double // 0...1
        let l: Double // 0...1
    }
    
    private static func rgbaToHSL(_ rgba: RGBA) -> HSL {
        let max = Swift.max(rgba.r, rgba.g, rgba.b)
        let min = Swift.min(rgba.r, rgba.g, rgba.b)
        let delta = max - min
        
        let l = (max + min) / 2.0
        
        guard delta > 0 else {
            return HSL(h: 0, s: 0, l: l)
        }
        
        let s = l > 0.5 ? delta / (2.0 - max - min) : delta / (max + min)
        
        var h: Double
        switch max {
        case rgba.r:
            h = ((rgba.g - rgba.b) / delta) + (rgba.g < rgba.b ? 6 : 0)
        case rgba.g:
            h = (rgba.b - rgba.r) / delta + 2
        default: // rgba.b
            h = (rgba.r - rgba.g) / delta + 4
        }
        h *= 60
        
        return HSL(h: h, s: s, l: l)
    }
    
    private static func hslToRGBA(_ hsl: HSL) -> RGBA {
        guard hsl.s > 0 else {
            return RGBA(r: hsl.l, g: hsl.l, b: hsl.l, a: 1.0)
        }
        
        func hueToRGB(_ p: Double, _ q: Double, _ t: Double) -> Double {
            var t = t
            if t < 0 { t += 1 }
            if t > 1 { t -= 1 }
            if t < 1/6 { return p + (q - p) * 6 * t }
            if t < 1/2 { return q }
            if t < 2/3 { return p + (q - p) * (2/3 - t) * 6 }
            return p
        }
        
        let q = hsl.l < 0.5 ? hsl.l * (1 + hsl.s) : hsl.l + hsl.s - hsl.l * hsl.s
        let p = 2 * hsl.l - q
        let h = hsl.h / 360
        
        return RGBA(
            r: hueToRGB(p, q, h + 1/3),
            g: hueToRGB(p, q, h),
            b: hueToRGB(p, q, h - 1/3),
            a: 1.0
        )
    }
}

// MARK: - Accessibility helpers
public enum WCAGLevel: Sendable { case AA, AAA }

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

// MARK: - Advanced Gradient Generation

/// Gradient interpolation methods for different use cases
public enum GradientInterpolation: Sendable, CaseIterable {
    case linear      // Simple linear interpolation in RGB
    case perceptual  // Perceptually uniform interpolation in LAB space
    case hsl         // HSL interpolation for smooth hue transitions
    case bezier      // Bezier curve interpolation for smooth transitions
    case ease        // Eased interpolation with smooth acceleration/deceleration
}

/// Gradient generation optimized for data visualization and smooth transitions
public struct GradientGenerator {
    
    /// Generate a gradient between two colors
    /// - Parameters:
    ///   - startColor: Starting color (hex string)
    ///   - endColor: Ending color (hex string)
    ///   - steps: Number of steps in the gradient
    ///   - interpolation: Interpolation method to use
    /// - Returns: Array of hex color strings representing the gradient
    public static func generateGradient(
        from startColor: String,
        to endColor: String,
        steps: Int,
        interpolation: GradientInterpolation = .perceptual
    ) -> [String] {
        guard let startRGBA = try? HexColorFormatter.parse(startColor),
              let endRGBA = try? HexColorFormatter.parse(endColor),
              steps > 1 else { return [startColor, endColor] }
        
        return generateGradient(from: startRGBA, to: endRGBA, steps: steps, interpolation: interpolation)
    }
    
    /// Generate a gradient between two RGBA colors
    /// - Parameters:
    ///   - startColor: Starting RGBA color
    ///   - endColor: Ending RGBA color
    ///   - steps: Number of steps in the gradient
    ///   - interpolation: Interpolation method to use
    /// - Returns: Array of hex color strings representing the gradient
    public static func generateGradient(
        from startColor: RGBA,
        to endColor: RGBA,
        steps: Int,
        interpolation: GradientInterpolation = .perceptual
    ) -> [String] {
        guard steps > 1 else { return [HexColorFormatter.format(startColor), HexColorFormatter.format(endColor)] }
        
        var colors: [String] = []
        
        for i in 0..<steps {
            let t = Double(i) / Double(steps - 1)
            let adjustedT = applyEasing(t, for: interpolation)
            
            let interpolatedColor: RGBA
            
            switch interpolation {
            case .linear:
                interpolatedColor = linearInterpolate(startColor, endColor, t: adjustedT)
            case .perceptual:
                interpolatedColor = perceptualInterpolate(startColor, endColor, t: adjustedT)
            case .hsl:
                interpolatedColor = hslInterpolate(startColor, endColor, t: adjustedT)
            case .bezier:
                interpolatedColor = bezierInterpolate(startColor, endColor, t: adjustedT)
            case .ease:
                interpolatedColor = linearInterpolate(startColor, endColor, t: adjustedT)
            }
            
            colors.append(HexColorFormatter.format(interpolatedColor))
        }
        
        return colors
    }
    
    /// Generate a multi-stop gradient
    /// - Parameters:
    ///   - colors: Array of color stops (hex strings)
    ///   - steps: Total number of steps in the gradient
    ///   - interpolation: Interpolation method to use
    /// - Returns: Array of hex color strings representing the gradient
    public static func generateMultiStopGradient(
        colors: [String],
        steps: Int,
        interpolation: GradientInterpolation = .perceptual
    ) -> [String] {
        guard colors.count >= 2, steps > 1 else { return colors }
        
        let rgbaColors = colors.compactMap { try? HexColorFormatter.parse($0) }
        guard rgbaColors.count == colors.count else { return colors }
        
        return generateMultiStopGradient(colors: rgbaColors, steps: steps, interpolation: interpolation)
    }
    
    /// Generate a multi-stop gradient with RGBA colors
    /// - Parameters:
    ///   - colors: Array of RGBA color stops
    ///   - steps: Total number of steps in the gradient
    ///   - interpolation: Interpolation method to use
    /// - Returns: Array of hex color strings representing the gradient
    public static func generateMultiStopGradient(
        colors: [RGBA],
        steps: Int,
        interpolation: GradientInterpolation = .perceptual
    ) -> [String] {
        guard colors.count >= 2, steps > 1 else {
            return colors.map { HexColorFormatter.format($0) }
        }
        
        var gradientColors: [String] = []
        let segmentCount = colors.count - 1
        let stepsPerSegment = max(1, steps / segmentCount)
        
        for i in 0..<segmentCount {
            let startColor = colors[i]
            let endColor = colors[i + 1]
            
            let segmentSteps = (i == segmentCount - 1) ? (steps - gradientColors.count + 1) : stepsPerSegment
            let segmentGradient = generateGradient(
                from: startColor,
                to: endColor,
                steps: segmentSteps,
                interpolation: interpolation
            )
            
            // Avoid duplicating colors at segment boundaries
            if i == 0 {
                gradientColors.append(contentsOf: segmentGradient)
            } else {
                gradientColors.append(contentsOf: Array(segmentGradient.dropFirst()))
            }
        }
        
        return Array(gradientColors.prefix(steps))
    }
    
    /// Generate a data visualization gradient optimized for readability
    /// - Parameters:
    ///   - type: Type of data visualization gradient
    ///   - steps: Number of steps in the gradient
    /// - Returns: Array of hex color strings optimized for data visualization
    public static func generateDataVisualizationGradient(
        type: DataVisualizationType,
        steps: Int
    ) -> [String] {
        switch type {
        case .sequential:
            return generateGradient(
                from: "#F7FBFF",
                to: "#08306B",
                steps: steps,
                interpolation: .perceptual
            )
        case .diverging:
            return generateMultiStopGradient(
                colors: ["#D73027", "#FFFFBF", "#1A9850"],
                steps: steps,
                interpolation: .perceptual
            )
        case .heatmap:
            return generateMultiStopGradient(
                colors: ["#000428", "#004e92", "#009ffd", "#00d2ff"],
                steps: steps,
                interpolation: .perceptual
            )
        case .viridis:
            return generateMultiStopGradient(
                colors: ["#440154", "#31688e", "#35b779", "#fde725"],
                steps: steps,
                interpolation: .perceptual
            )
        case .plasma:
            return generateMultiStopGradient(
                colors: ["#0d0887", "#7e03a8", "#cc4778", "#f89441", "#f0f921"],
                steps: steps,
                interpolation: .perceptual
            )
        case .temperature:
            return generateMultiStopGradient(
                colors: ["#313695", "#74add1", "#ffffbf", "#f46d43", "#a50026"],
                steps: steps,
                interpolation: .perceptual
            )
        }
    }
    
    /// Generate a smooth color transition optimized for UI animations
    /// - Parameters:
    ///   - startColor: Starting color (hex string)
    ///   - endColor: Ending color (hex string)
    ///   - duration: Animation duration in seconds
    ///   - fps: Frames per second for the animation
    /// - Returns: Array of hex color strings for smooth animation
    public static func generateAnimationGradient(
        from startColor: String,
        to endColor: String,
        duration: Double,
        fps: Int = 60
    ) -> [String] {
        let totalFrames = Int(duration * Double(fps))
        return generateGradient(
            from: startColor,
            to: endColor,
            steps: totalFrames,
            interpolation: .ease
        )
    }
    
    // MARK: - Private Helper Methods
    
    private static func linearInterpolate(_ start: RGBA, _ end: RGBA, t: Double) -> RGBA {
        return RGBA(
            r: start.r + (end.r - start.r) * t,
            g: start.g + (end.g - start.g) * t,
            b: start.b + (end.b - start.b) * t,
            a: start.a + (end.a - start.a) * t
        )
    }
    
    private static func perceptualInterpolate(_ start: RGBA, _ end: RGBA, t: Double) -> RGBA {
        let startLAB = ColorSpaceConverter.rgbaToLAB(start)
        let endLAB = ColorSpaceConverter.rgbaToLAB(end)
        
        let interpolatedLAB = CIELAB(
            l: startLAB.l + (endLAB.l - startLAB.l) * t,
            a: startLAB.a + (endLAB.a - startLAB.a) * t,
            b: startLAB.b + (endLAB.b - startLAB.b) * t
        )
        
        var result = ColorSpaceConverter.labToRGBA(interpolatedLAB)
        result.a = start.a + (end.a - start.a) * t
        return result
    }
    
    private static func hslInterpolate(_ start: RGBA, _ end: RGBA, t: Double) -> RGBA {
        let startHSL = rgbaToHSL(start)
        let endHSL = rgbaToHSL(end)
        
        // Handle hue interpolation (shortest path around the color wheel)
        var hueDiff = endHSL.h - startHSL.h
        if hueDiff > 180 {
            hueDiff -= 360
        } else if hueDiff < -180 {
            hueDiff += 360
        }
        
        let interpolatedHSL = HSL(
            h: (startHSL.h + hueDiff * t).truncatingRemainder(dividingBy: 360),
            s: startHSL.s + (endHSL.s - startHSL.s) * t,
            l: startHSL.l + (endHSL.l - startHSL.l) * t
        )
        
        var result = hslToRGBA(interpolatedHSL)
        result.a = start.a + (end.a - start.a) * t
        return result
    }
    
    private static func bezierInterpolate(_ start: RGBA, _ end: RGBA, t: Double) -> RGBA {
        // Use cubic bezier curve for smooth interpolation
        let controlPoint1 = RGBA(
            r: start.r + (end.r - start.r) * 0.33,
            g: start.g + (end.g - start.g) * 0.33,
            b: start.b + (end.b - start.b) * 0.33,
            a: start.a + (end.a - start.a) * 0.33
        )
        
        let controlPoint2 = RGBA(
            r: start.r + (end.r - start.r) * 0.67,
            g: start.g + (end.g - start.g) * 0.67,
            b: start.b + (end.b - start.b) * 0.67,
            a: start.a + (end.a - start.a) * 0.67
        )
        
        // Cubic bezier interpolation
        let oneMinusT = 1.0 - t
        let oneMinusTSquared = oneMinusT * oneMinusT
        let oneMinusTCubed = oneMinusTSquared * oneMinusT
        let tSquared = t * t
        let tCubed = tSquared * t
        
        return RGBA(
            r: oneMinusTCubed * start.r + 3 * oneMinusTSquared * t * controlPoint1.r + 3 * oneMinusT * tSquared * controlPoint2.r + tCubed * end.r,
            g: oneMinusTCubed * start.g + 3 * oneMinusTSquared * t * controlPoint1.g + 3 * oneMinusT * tSquared * controlPoint2.g + tCubed * end.g,
            b: oneMinusTCubed * start.b + 3 * oneMinusTSquared * t * controlPoint1.b + 3 * oneMinusT * tSquared * controlPoint2.b + tCubed * end.b,
            a: oneMinusTCubed * start.a + 3 * oneMinusTSquared * t * controlPoint1.a + 3 * oneMinusT * tSquared * controlPoint2.a + tCubed * end.a
        )
    }
    
    private static func applyEasing(_ t: Double, for interpolation: GradientInterpolation) -> Double {
        guard interpolation == .ease else { return t }
        
        // Ease-in-out cubic function
        return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
    }
    
    private struct HSL {
        let h: Double // 0...360
        let s: Double // 0...1
        let l: Double // 0...1
    }
    
    private static func rgbaToHSL(_ rgba: RGBA) -> HSL {
        let max = Swift.max(rgba.r, rgba.g, rgba.b)
        let min = Swift.min(rgba.r, rgba.g, rgba.b)
        let delta = max - min
        
        let l = (max + min) / 2.0
        
        guard delta > 0 else {
            return HSL(h: 0, s: 0, l: l)
        }
        
        let s = l > 0.5 ? delta / (2.0 - max - min) : delta / (max + min)
        
        var h: Double
        switch max {
        case rgba.r:
            h = ((rgba.g - rgba.b) / delta) + (rgba.g < rgba.b ? 6 : 0)
        case rgba.g:
            h = (rgba.b - rgba.r) / delta + 2
        default: // rgba.b
            h = (rgba.r - rgba.g) / delta + 4
        }
        h *= 60
        
        return HSL(h: h, s: s, l: l)
    }
    
    private static func hslToRGBA(_ hsl: HSL) -> RGBA {
        let c = (1.0 - abs(2.0 * hsl.l - 1.0)) * hsl.s
        let x = c * (1.0 - abs((hsl.h / 60.0).truncatingRemainder(dividingBy: 2.0) - 1.0))
        let m = hsl.l - c / 2.0
        
        var r, g, b: Double
        
        switch hsl.h {
        case 0..<60:
            (r, g, b) = (c, x, 0)
        case 60..<120:
            (r, g, b) = (x, c, 0)
        case 120..<180:
            (r, g, b) = (0, c, x)
        case 180..<240:
            (r, g, b) = (0, x, c)
        case 240..<300:
            (r, g, b) = (x, 0, c)
        default:
            (r, g, b) = (c, 0, x)
        }
        
        return RGBA(r: r + m, g: g + m, b: b + m, a: 1.0)
    }
}

/// Data visualization gradient types
public enum DataVisualizationType: Sendable {
    case sequential  // Single hue progression
    case diverging   // Two-hue progression with neutral center
    case heatmap     // Heat map visualization
    case viridis     // Perceptually uniform colormap
    case plasma      // High contrast colormap
    case temperature // Temperature visualization
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