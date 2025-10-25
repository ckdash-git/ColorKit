import Foundation
#if SWIFT_PACKAGE
import ColorCore
#endif

// MARK: - Color Harmony Generation
public enum ColorHarmonyType {
    case complementary
    case analogous
    case triadic
    case tetradic
    case splitComplementary
    case monochromatic
}

public struct ColorHarmonyGenerator {
    /// Generate a color harmony scheme from a base color
    /// - Parameters:
    ///   - baseHex: Base color in hex format
    ///   - type: Type of harmony to generate
    /// - Returns: Array of hex colors including the base color
    public static func generateHarmony(from baseHex: String, type: ColorHarmonyType) -> [String] {
        guard let baseRGBA = try? HexColorFormatter.parse(baseHex) else { return [baseHex] }
        
        // Convert to HSL for easier hue manipulation
        let hsl = rgbaToHSL(baseRGBA)
        
        switch type {
        case .complementary:
            return generateComplementary(hsl: hsl)
        case .analogous:
            return generateAnalogous(hsl: hsl)
        case .triadic:
            return generateTriadic(hsl: hsl)
        case .tetradic:
            return generateTetradic(hsl: hsl)
        case .splitComplementary:
            return generateSplitComplementary(hsl: hsl)
        case .monochromatic:
            return generateMonochromatic(hsl: hsl)
        }
    }
    
    // MARK: - Private Harmony Generators
    
    private static func generateComplementary(hsl: HSL) -> [String] {
        let complementHue = (hsl.h + 180).truncatingRemainder(dividingBy: 360)
        let complement = HSL(h: complementHue, s: hsl.s, l: hsl.l)
        
        return [
            HexColorFormatter.format(hslToRGBA(hsl)),
            HexColorFormatter.format(hslToRGBA(complement))
        ]
    }
    
    private static func generateAnalogous(hsl: HSL) -> [String] {
        let hue1 = (hsl.h - 30 + 360).truncatingRemainder(dividingBy: 360)
        let hue2 = (hsl.h + 30).truncatingRemainder(dividingBy: 360)
        
        return [
            HexColorFormatter.format(hslToRGBA(HSL(h: hue1, s: hsl.s, l: hsl.l))),
            HexColorFormatter.format(hslToRGBA(hsl)),
            HexColorFormatter.format(hslToRGBA(HSL(h: hue2, s: hsl.s, l: hsl.l)))
        ]
    }
    
    private static func generateTriadic(hsl: HSL) -> [String] {
        let hue1 = (hsl.h + 120).truncatingRemainder(dividingBy: 360)
        let hue2 = (hsl.h + 240).truncatingRemainder(dividingBy: 360)
        
        return [
            HexColorFormatter.format(hslToRGBA(hsl)),
            HexColorFormatter.format(hslToRGBA(HSL(h: hue1, s: hsl.s, l: hsl.l))),
            HexColorFormatter.format(hslToRGBA(HSL(h: hue2, s: hsl.s, l: hsl.l)))
        ]
    }
    
    private static func generateTetradic(hsl: HSL) -> [String] {
        let hue1 = (hsl.h + 90).truncatingRemainder(dividingBy: 360)
        let hue2 = (hsl.h + 180).truncatingRemainder(dividingBy: 360)
        let hue3 = (hsl.h + 270).truncatingRemainder(dividingBy: 360)
        
        return [
            HexColorFormatter.format(hslToRGBA(hsl)),
            HexColorFormatter.format(hslToRGBA(HSL(h: hue1, s: hsl.s, l: hsl.l))),
            HexColorFormatter.format(hslToRGBA(HSL(h: hue2, s: hsl.s, l: hsl.l))),
            HexColorFormatter.format(hslToRGBA(HSL(h: hue3, s: hsl.s, l: hsl.l)))
        ]
    }
    
    private static func generateSplitComplementary(hsl: HSL) -> [String] {
        let complementBase = (hsl.h + 180).truncatingRemainder(dividingBy: 360)
        let hue1 = (complementBase - 30 + 360).truncatingRemainder(dividingBy: 360)
        let hue2 = (complementBase + 30).truncatingRemainder(dividingBy: 360)
        
        return [
            HexColorFormatter.format(hslToRGBA(hsl)),
            HexColorFormatter.format(hslToRGBA(HSL(h: hue1, s: hsl.s, l: hsl.l))),
            HexColorFormatter.format(hslToRGBA(HSL(h: hue2, s: hsl.s, l: hsl.l)))
        ]
    }
    
    private static func generateMonochromatic(hsl: HSL) -> [String] {
        let lightnesses: [Double] = [0.2, 0.4, hsl.l, 0.7, 0.9]
        return lightnesses.map { lightness in
            HexColorFormatter.format(hslToRGBA(HSL(h: hsl.h, s: hsl.s, l: lightness)))
        }
    }
    
    // MARK: - HSL Conversion Helpers
    
    private struct HSL {
        let h: Double // 0-360
        let s: Double // 0-1
        let l: Double // 0-1
    }
    
    private static func rgbaToHSL(_ rgba: RGBA) -> HSL {
        let r = rgba.r
        let g = rgba.g
        let b = rgba.b
        
        let max = Swift.max(r, g, b)
        let min = Swift.min(r, g, b)
        let delta = max - min
        
        // Lightness
        let l = (max + min) / 2.0
        
        // Saturation
        let s: Double
        if delta == 0 {
            s = 0
        } else {
            s = l > 0.5 ? delta / (2.0 - max - min) : delta / (max + min)
        }
        
        // Hue
        let h: Double
        if delta == 0 {
            h = 0
        } else if max == r {
            h = ((g - b) / delta + (g < b ? 6 : 0)) * 60
        } else if max == g {
            h = ((b - r) / delta + 2) * 60
        } else {
            h = ((r - g) / delta + 4) * 60
        }
        
        return HSL(h: h, s: s, l: l)
    }
    
    private static func hslToRGBA(_ hsl: HSL) -> RGBA {
        let h = hsl.h / 360.0
        let s = hsl.s
        let l = hsl.l
        
        if s == 0 {
            // Achromatic (gray)
            return RGBA(r: l, g: l, b: l, a: 1.0)
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
        
        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q
        
        let r = hueToRGB(p, q, h + 1/3)
        let g = hueToRGB(p, q, h)
        let b = hueToRGB(p, q, h - 1/3)
        
        return RGBA(r: r, g: g, b: b, a: 1.0)
    }
}

// MARK: - Color Temperature and Tint Adjustment

/// Tools for adjusting color temperature and tint, similar to photo editing software
public struct ColorTemperatureAdjustment {
    
    /// Adjust the color temperature of a color
    /// - Parameters:
    ///   - color: The input color in hex format
    ///   - temperature: Temperature adjustment (-100 to 100, where negative is cooler/bluer, positive is warmer/yellower)
    /// - Returns: Color with adjusted temperature
    public static func adjustTemperature(_ color: String, temperature: Double) -> String {
        guard let rgba = try? HexColorFormatter.parse(color) else { return color }
        let adjustedRGBA = adjustTemperature(rgba, temperature: temperature)
        return HexColorFormatter.format(adjustedRGBA)
    }
    
    /// Adjust the color temperature of an RGBA color
    /// - Parameters:
    ///   - rgba: The input RGBA color
    ///   - temperature: Temperature adjustment (-100 to 100)
    /// - Returns: RGBA color with adjusted temperature
    public static func adjustTemperature(_ rgba: RGBA, temperature: Double) -> RGBA {
        let clampedTemp = max(-100, min(100, temperature))
        let tempFactor = clampedTemp / 100.0
        
        // Convert to linear RGB for more accurate color manipulation
        let linearR = sRGBToLinear(rgba.r)
        let linearG = sRGBToLinear(rgba.g)
        let linearB = sRGBToLinear(rgba.b)
        
        var adjustedR = linearR
        var adjustedG = linearG
        var adjustedB = linearB
        
        if tempFactor > 0 {
            // Warmer (more yellow/red)
            adjustedR = linearR + tempFactor * 0.3
            adjustedG = linearG + tempFactor * 0.1
            adjustedB = linearB - tempFactor * 0.2
        } else {
            // Cooler (more blue)
            adjustedR = linearR + tempFactor * 0.2
            adjustedG = linearG + tempFactor * 0.1
            adjustedB = linearB - tempFactor * 0.3
        }
        
        return RGBA(
            r: RGBA.clamp(linearToSRGB(adjustedR)),
            g: RGBA.clamp(linearToSRGB(adjustedG)),
            b: RGBA.clamp(linearToSRGB(adjustedB)),
            a: rgba.a
        )
    }
    
    /// Adjust the tint of a color
    /// - Parameters:
    ///   - color: The input color in hex format
    ///   - tint: Tint adjustment (-100 to 100, where negative is more green, positive is more magenta)
    /// - Returns: Color with adjusted tint
    public static func adjustTint(_ color: String, tint: Double) -> String {
        guard let rgba = try? HexColorFormatter.parse(color) else { return color }
        let adjustedRGBA = adjustTint(rgba, tint: tint)
        return HexColorFormatter.format(adjustedRGBA)
    }
    
    /// Adjust the tint of an RGBA color
    /// - Parameters:
    ///   - rgba: The input RGBA color
    ///   - tint: Tint adjustment (-100 to 100)
    /// - Returns: RGBA color with adjusted tint
    public static func adjustTint(_ rgba: RGBA, tint: Double) -> RGBA {
        let clampedTint = max(-100, min(100, tint))
        let tintFactor = clampedTint / 100.0
        
        // Convert to linear RGB
        let linearR = sRGBToLinear(rgba.r)
        let linearG = sRGBToLinear(rgba.g)
        let linearB = sRGBToLinear(rgba.b)
        
        var adjustedR = linearR
        var adjustedG = linearG
        var adjustedB = linearB
        
        if tintFactor > 0 {
            // More magenta
            adjustedR = linearR + tintFactor * 0.2
            adjustedG = linearG - tintFactor * 0.1
            adjustedB = linearB + tintFactor * 0.1
        } else {
            // More green
            adjustedR = linearR + tintFactor * 0.1
            adjustedG = linearG - tintFactor * 0.2
            adjustedB = linearB + tintFactor * 0.05
        }
        
        return RGBA(
            r: RGBA.clamp(linearToSRGB(adjustedR)),
            g: RGBA.clamp(linearToSRGB(adjustedG)),
            b: RGBA.clamp(linearToSRGB(adjustedB)),
            a: rgba.a
        )
    }
    
    /// Adjust both temperature and tint simultaneously
    /// - Parameters:
    ///   - color: The input color in hex format
    ///   - temperature: Temperature adjustment (-100 to 100)
    ///   - tint: Tint adjustment (-100 to 100)
    /// - Returns: Color with adjusted temperature and tint
    public static func adjustTemperatureAndTint(_ color: String, temperature: Double, tint: Double) -> String {
        guard let rgba = try? HexColorFormatter.parse(color) else { return color }
        let adjustedRGBA = adjustTemperatureAndTint(rgba, temperature: temperature, tint: tint)
        return HexColorFormatter.format(adjustedRGBA)
    }
    
    /// Adjust both temperature and tint of an RGBA color simultaneously
    /// - Parameters:
    ///   - rgba: The input RGBA color
    ///   - temperature: Temperature adjustment (-100 to 100)
    ///   - tint: Tint adjustment (-100 to 100)
    /// - Returns: RGBA color with adjusted temperature and tint
    public static func adjustTemperatureAndTint(_ rgba: RGBA, temperature: Double, tint: Double) -> RGBA {
        let tempAdjusted = adjustTemperature(rgba, temperature: temperature)
        return adjustTint(tempAdjusted, tint: tint)
    }
    
    /// Get the color temperature of a color in Kelvin (approximate)
    /// - Parameter color: The input color in hex format
    /// - Returns: Approximate color temperature in Kelvin (2000-12000K range)
    public static func getColorTemperature(_ color: String) -> Double {
        guard let rgba = try? HexColorFormatter.parse(color) else { return 6500 } // Default daylight
        return getColorTemperature(rgba)
    }
    
    /// Get the color temperature of an RGBA color in Kelvin (approximate)
    /// - Parameter rgba: The input RGBA color
    /// - Returns: Approximate color temperature in Kelvin
    public static func getColorTemperature(_ rgba: RGBA) -> Double {
        // Simple approximation based on red/blue ratio
        let redBlueRatio = rgba.r / max(rgba.b, 0.001)
        
        // Map ratio to temperature (very approximate)
        if redBlueRatio > 1.5 {
            return 2000 + (redBlueRatio - 1.5) * 1000 // Warm colors
        } else if redBlueRatio < 0.8 {
            return 6500 + (0.8 - redBlueRatio) * 7000 // Cool colors
        } else {
            return 5500 + (redBlueRatio - 1.0) * 2000 // Neutral colors
        }
    }
    
    /// Convert color temperature in Kelvin to RGB color
    /// - Parameter kelvin: Temperature in Kelvin (1000-40000K)
    /// - Returns: RGB color representing the blackbody radiation at that temperature
    public static func kelvinToRGB(_ kelvin: Double) -> RGBA {
        let temp = max(1000, min(40000, kelvin)) / 100.0
        
        var red: Double
        var green: Double
        var blue: Double
        
        // Calculate red
        if temp <= 66 {
            red = 255
        } else {
            red = temp - 60
            red = 329.698727446 * pow(red, -0.1332047592)
            red = max(0, min(255, red))
        }
        
        // Calculate green
        if temp <= 66 {
            green = temp
            green = 99.4708025861 * log(green) - 161.1195681661
        } else {
            green = temp - 60
            green = 288.1221695283 * pow(green, -0.0755148492)
        }
        green = max(0, min(255, green))
        
        // Calculate blue
        if temp >= 66 {
            blue = 255
        } else if temp <= 19 {
            blue = 0
        } else {
            blue = temp - 10
            blue = 138.5177312231 * log(blue) - 305.0447927307
            blue = max(0, min(255, blue))
        }
        
        return RGBA(
            r: red / 255.0,
            g: green / 255.0,
            b: blue / 255.0,
            a: 1.0
        )
    }
    
    // MARK: - Helper Functions
    
    /// Convert sRGB to linear RGB
    private static func sRGBToLinear(_ value: Double) -> Double {
        return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
    }
    
    /// Convert linear RGB to sRGB
    private static func linearToSRGB(_ value: Double) -> Double {
        return value <= 0.0031308 ? value * 12.92 : 1.055 * pow(value, 1.0/2.4) - 0.055
    }
}

// MARK: - White Balance Presets

/// Common white balance presets for color temperature adjustment
public struct WhiteBalancePresets {
    
    /// Candlelight (1900K)
    public static let candlelight = ColorTemperatureAdjustment.kelvinToRGB(1900)
    
    /// Tungsten (2700K)
    public static let tungsten = ColorTemperatureAdjustment.kelvinToRGB(2700)
    
    /// Warm fluorescent (3000K)
    public static let warmFluorescent = ColorTemperatureAdjustment.kelvinToRGB(3000)
    
    /// Cool white fluorescent (4100K)
    public static let coolWhiteFluorescent = ColorTemperatureAdjustment.kelvinToRGB(4100)
    
    /// Daylight (5500K)
    public static let daylight = ColorTemperatureAdjustment.kelvinToRGB(5500)
    
    /// Flash (5500K)
    public static let flash = ColorTemperatureAdjustment.kelvinToRGB(5500)
    
    /// Cloudy (6500K)
    public static let cloudy = ColorTemperatureAdjustment.kelvinToRGB(6500)
    
    /// Shade (7500K)
    public static let shade = ColorTemperatureAdjustment.kelvinToRGB(7500)
    
    /// Get all presets as a dictionary
    public static let allPresets: [String: RGBA] = [
        "Candlelight": candlelight,
        "Tungsten": tungsten,
        "Warm Fluorescent": warmFluorescent,
        "Cool White Fluorescent": coolWhiteFluorescent,
        "Daylight": daylight,
        "Flash": flash,
        "Cloudy": cloudy,
        "Shade": shade
    ]
    
    /// Apply a white balance preset to a color
    /// - Parameters:
    ///   - color: Input color in hex format
    ///   - preset: White balance preset name
    ///   - strength: Strength of the effect (0.0 to 1.0)
    /// - Returns: Color adjusted with the white balance preset
    public static func applyPreset(_ color: String, preset: String, strength: Double = 1.0) -> String {
        guard let rgba = try? HexColorFormatter.parse(color),
              let presetColor = allPresets[preset] else { return color }
        
        let clampedStrength = max(0, min(1, strength))
        let blended = PerceptualColorMath.perceptualBlend(rgba, presetColor, ratio: clampedStrength * 0.3)
        return HexColorFormatter.format(blended)
    }
}

// MARK: - Color Psychology Engine

/// Emotional categories for color psychology
public enum EmotionalCategory: String, CaseIterable {
    case calm = "calm"
    case energetic = "energetic"
    case warm = "warm"
    case cool = "cool"
    case professional = "professional"
    case creative = "creative"
    case trustworthy = "trustworthy"
    case luxurious = "luxurious"
    case playful = "playful"
    case natural = "natural"
    case romantic = "romantic"
    case mysterious = "mysterious"
    case confident = "confident"
    case peaceful = "peaceful"
    case exciting = "exciting"
    case sophisticated = "sophisticated"
    case friendly = "friendly"
    case powerful = "powerful"
    case fresh = "fresh"
    case elegant = "elegant"
}

/// Color psychology associations and emotional responses
public struct ColorPsychology {
    
    /// Get colors associated with a specific emotion
    /// - Parameter emotion: The desired emotional category
    /// - Returns: Array of hex colors that evoke the specified emotion
    public static func colorsFor(emotion: EmotionalCategory) -> [String] {
        switch emotion {
        case .calm:
            return ["#E8F4FD", "#B3D9F2", "#7FB8D3", "#4F94CD", "#2E8B57", "#87CEEB", "#F0F8FF", "#E6E6FA"]
        case .energetic:
            return ["#FF6B35", "#F7931E", "#FFD23F", "#EE4B2B", "#FF4500", "#FF1493", "#32CD32", "#ADFF2F"]
        case .warm:
            return ["#FF6347", "#FF7F50", "#FFA500", "#FFD700", "#F4A460", "#DEB887", "#CD853F", "#D2691E"]
        case .cool:
            return ["#4169E1", "#00CED1", "#20B2AA", "#48D1CC", "#87CEEB", "#B0E0E6", "#E0FFFF", "#F0F8FF"]
        case .professional:
            return ["#2C3E50", "#34495E", "#7F8C8D", "#95A5A6", "#BDC3C7", "#1ABC9C", "#3498DB", "#9B59B6"]
        case .creative:
            return ["#E74C3C", "#F39C12", "#F1C40F", "#2ECC71", "#3498DB", "#9B59B6", "#E67E22", "#1ABC9C"]
        case .trustworthy:
            return ["#3498DB", "#2980B9", "#1ABC9C", "#16A085", "#27AE60", "#2ECC71", "#34495E", "#2C3E50"]
        case .luxurious:
            return ["#8E44AD", "#9B59B6", "#2C3E50", "#34495E", "#F39C12", "#E67E22", "#C0392B", "#A93226"]
        case .playful:
            return ["#FF69B4", "#FF1493", "#00FF7F", "#FFD700", "#FF6347", "#32CD32", "#FF4500", "#DA70D6"]
        case .natural:
            return ["#228B22", "#32CD32", "#9ACD32", "#6B8E23", "#556B2F", "#8FBC8F", "#98FB98", "#F0FFF0"]
        case .romantic:
            return ["#FFB6C1", "#FFC0CB", "#FF69B4", "#FF1493", "#DC143C", "#B22222", "#CD5C5C", "#F08080"]
        case .mysterious:
            return ["#2F1B69", "#4B0082", "#483D8B", "#2E2E2E", "#36454F", "#1C1C1C", "#191970", "#000080"]
        case .confident:
            return ["#DC143C", "#B22222", "#8B0000", "#FF4500", "#FF6347", "#2F4F4F", "#000000", "#800000"]
        case .peaceful:
            return ["#E6E6FA", "#F0F8FF", "#F5F5DC", "#FFF8DC", "#FFFACD", "#F0FFF0", "#F5FFFA", "#FFFFF0"]
        case .exciting:
            return ["#FF0000", "#FF4500", "#FF6347", "#FF1493", "#FF69B4", "#ADFF2F", "#00FF00", "#FFD700"]
        case .sophisticated:
            return ["#2C2C2C", "#36454F", "#708090", "#2F4F4F", "#696969", "#A9A9A9", "#C0C0C0", "#D3D3D3"]
        case .friendly:
            return ["#FFA500", "#FFD700", "#FFFF00", "#ADFF2F", "#32CD32", "#00CED1", "#87CEEB", "#DDA0DD"]
        case .powerful:
            return ["#000000", "#8B0000", "#B22222", "#2F4F4F", "#36454F", "#191970", "#4B0082", "#800080"]
        case .fresh:
            return ["#00FF7F", "#32CD32", "#98FB98", "#90EE90", "#ADFF2F", "#7CFC00", "#00FA9A", "#00FF00"]
        case .elegant:
            return ["#2C2C2C", "#36454F", "#C0C0C0", "#D3D3D3", "#E6E6FA", "#F5F5DC", "#FFF8DC", "#FFFFF0"]
        }
    }
    
    /// Get the primary emotion associated with a color
    /// - Parameter color: Hex color string
    /// - Returns: The primary emotional category for this color
    public static func primaryEmotion(for color: String) -> EmotionalCategory? {
        guard let rgba = try? HexColorFormatter.parse(color) else { return nil }
        return primaryEmotion(for: rgba)
    }
    
    /// Get the primary emotion associated with an RGBA color
    /// - Parameter rgba: RGBA color
    /// - Returns: The primary emotional category for this color
    public static func primaryEmotion(for rgba: RGBA) -> EmotionalCategory? {
        let hsl = rgbaToHSL(rgba)
        let hue = hsl.h
        let saturation = hsl.s
        let lightness = hsl.l
        
        // Analyze color properties to determine emotion
        if lightness > 0.8 && saturation < 0.3 {
            return .peaceful
        } else if saturation > 0.8 && lightness > 0.5 {
            if hue >= 0 && hue < 60 {
                return .energetic // Red-Orange
            } else if hue >= 60 && hue < 120 {
                return .fresh // Yellow-Green
            } else if hue >= 120 && hue < 180 {
                return .natural // Green-Cyan
            } else if hue >= 180 && hue < 240 {
                return .cool // Cyan-Blue
            } else if hue >= 240 && hue < 300 {
                return .mysterious // Blue-Purple
            } else {
                return .romantic // Purple-Red
            }
        } else if lightness < 0.3 {
            return saturation > 0.5 ? .powerful : .sophisticated
        } else if saturation < 0.2 {
            return .professional
        } else {
            // Medium saturation and lightness
            if hue >= 0 && hue < 60 {
                return .warm
            } else if hue >= 180 && hue < 240 {
                return .trustworthy
            } else {
                return .friendly
            }
        }
    }
    
    /// Get all emotions associated with a color (with confidence scores)
    /// - Parameter color: Hex color string
    /// - Returns: Dictionary of emotions with confidence scores (0.0 to 1.0)
    public static func emotionalProfile(for color: String) -> [EmotionalCategory: Double] {
        guard let rgba = try? HexColorFormatter.parse(color) else { return [:] }
        return emotionalProfile(for: rgba)
    }
    
    /// Get all emotions associated with an RGBA color (with confidence scores)
    /// - Parameter rgba: RGBA color
    /// - Returns: Dictionary of emotions with confidence scores (0.0 to 1.0)
    public static func emotionalProfile(for rgba: RGBA) -> [EmotionalCategory: Double] {
        let hsl = rgbaToHSL(rgba)
        var profile: [EmotionalCategory: Double] = [:]
        
        let hue = hsl.h
        let saturation = hsl.s
        let lightness = hsl.l
        
        // Calculate confidence scores for each emotion based on color properties
        
        // Calm: High lightness, low saturation, cool hues
        let calmScore = (lightness * 0.4) + ((1.0 - saturation) * 0.3) + (coolHueScore(hue) * 0.3)
        profile[.calm] = min(1.0, calmScore)
        
        // Energetic: High saturation, warm hues
        let energeticScore = (saturation * 0.5) + (warmHueScore(hue) * 0.5)
        profile[.energetic] = min(1.0, energeticScore)
        
        // Professional: Medium lightness, low-medium saturation, neutral colors
        let professionalScore = (1.0 - abs(lightness - 0.5)) * 0.4 + ((1.0 - saturation) * 0.6)
        profile[.professional] = min(1.0, professionalScore)
        
        // Luxurious: Deep colors, high saturation, purple/gold hues
        let luxuriousScore = ((1.0 - lightness) * 0.4) + (saturation * 0.3) + (luxuryHueScore(hue) * 0.3)
        profile[.luxurious] = min(1.0, luxuriousScore)
        
        // Natural: Green hues, medium saturation
        let naturalScore = greenHueScore(hue) * 0.7 + (saturation * 0.3)
        profile[.natural] = min(1.0, naturalScore)
        
        // Add more emotion calculations...
        profile[.trustworthy] = min(1.0, blueHueScore(hue) * 0.8 + (saturation * 0.2))
        profile[.romantic] = min(1.0, pinkRedHueScore(hue) * 0.6 + (lightness * 0.4))
        profile[.mysterious] = min(1.0, ((1.0 - lightness) * 0.6) + (purpleHueScore(hue) * 0.4))
        profile[.peaceful] = min(1.0, (lightness * 0.5) + ((1.0 - saturation) * 0.5))
        profile[.powerful] = min(1.0, ((1.0 - lightness) * 0.7) + (saturation * 0.3))
        
        return profile.filter { $0.value > 0.1 } // Only return emotions with meaningful scores
    }
    
    /// Generate a color palette based on desired emotions
    /// - Parameters:
    ///   - emotions: Array of desired emotions
    ///   - count: Number of colors to generate
    /// - Returns: Array of hex colors that evoke the specified emotions
    public static func generatePalette(for emotions: [EmotionalCategory], count: Int = 5) -> [String] {
        var allColors: [String] = []
        
        // Collect colors from all specified emotions
        for emotion in emotions {
            allColors.append(contentsOf: colorsFor(emotion: emotion))
        }
        
        // Remove duplicates and select diverse colors
        let uniqueColors = Array(Set(allColors))
        
        guard uniqueColors.count >= count else {
            return Array(uniqueColors.prefix(count))
        }
        
        // Select colors that are visually diverse
        var selectedColors: [String] = []
        var remainingColors = uniqueColors
        
        // Start with a random color
        if let firstColor = remainingColors.randomElement() {
            selectedColors.append(firstColor)
            remainingColors.removeAll { $0 == firstColor }
        }
        
        // Select remaining colors based on diversity
        while selectedColors.count < count && !remainingColors.isEmpty {
            var bestColor = remainingColors[0]
            var maxMinDistance = 0.0
            
            for candidate in remainingColors {
                var minDistance = Double.infinity
                
                for selected in selectedColors {
                    let distance = colorDistance(candidate, selected)
                    minDistance = min(minDistance, distance)
                }
                
                if minDistance > maxMinDistance {
                    maxMinDistance = minDistance
                    bestColor = candidate
                }
            }
            
            selectedColors.append(bestColor)
            remainingColors.removeAll { $0 == bestColor }
        }
        
        return selectedColors
    }
    
    /// Suggest complementary emotions for a given emotion
    /// - Parameter emotion: The base emotion
    /// - Returns: Array of emotions that work well together
    public static func complementaryEmotions(for emotion: EmotionalCategory) -> [EmotionalCategory] {
        switch emotion {
        case .calm:
            return [.peaceful, .trustworthy, .professional]
        case .energetic:
            return [.exciting, .confident, .playful]
        case .warm:
            return [.friendly, .romantic, .natural]
        case .cool:
            return [.calm, .trustworthy, .professional]
        case .professional:
            return [.trustworthy, .sophisticated, .confident]
        case .creative:
            return [.playful, .energetic, .exciting]
        case .trustworthy:
            return [.professional, .calm, .confident]
        case .luxurious:
            return [.sophisticated, .elegant, .mysterious]
        case .playful:
            return [.creative, .friendly, .energetic]
        case .natural:
            return [.fresh, .calm, .peaceful]
        case .romantic:
            return [.warm, .elegant, .luxurious]
        case .mysterious:
            return [.sophisticated, .powerful, .luxurious]
        case .confident:
            return [.powerful, .professional, .trustworthy]
        case .peaceful:
            return [.calm, .natural, .fresh]
        case .exciting:
            return [.energetic, .playful, .creative]
        case .sophisticated:
            return [.elegant, .luxurious, .professional]
        case .friendly:
            return [.warm, .playful, .trustworthy]
        case .powerful:
            return [.confident, .mysterious, .sophisticated]
        case .fresh:
            return [.natural, .energetic, .peaceful]
        case .elegant:
            return [.sophisticated, .luxurious, .romantic]
        }
    }
    
    // MARK: - Helper Functions
    
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
    
    private static func warmHueScore(_ hue: Double) -> Double {
        // Red to yellow range (0-60 and 300-360)
        if hue <= 60 || hue >= 300 {
            return 1.0
        } else if hue <= 120 {
            return 1.0 - (hue - 60) / 60.0
        } else if hue >= 240 {
            return (hue - 240) / 60.0
        }
        return 0.0
    }
    
    private static func coolHueScore(_ hue: Double) -> Double {
        // Blue to cyan range (180-240)
        if hue >= 180 && hue <= 240 {
            return 1.0
        } else if hue >= 120 && hue < 180 {
            return (hue - 120) / 60.0
        } else if hue > 240 && hue <= 300 {
            return 1.0 - (hue - 240) / 60.0
        }
        return 0.0
    }
    
    private static func greenHueScore(_ hue: Double) -> Double {
        // Green range (60-180)
        if hue >= 90 && hue <= 150 {
            return 1.0
        } else if hue >= 60 && hue < 90 {
            return (hue - 60) / 30.0
        } else if hue > 150 && hue <= 180 {
            return 1.0 - (hue - 150) / 30.0
        }
        return 0.0
    }
    
    private static func blueHueScore(_ hue: Double) -> Double {
        // Blue range (200-260)
        if hue >= 200 && hue <= 260 {
            return 1.0
        } else if hue >= 180 && hue < 200 {
            return (hue - 180) / 20.0
        } else if hue > 260 && hue <= 280 {
            return 1.0 - (hue - 260) / 20.0
        }
        return 0.0
    }
    
    private static func purpleHueScore(_ hue: Double) -> Double {
        // Purple range (260-320)
        if hue >= 260 && hue <= 320 {
            return 1.0
        } else if hue >= 240 && hue < 260 {
            return (hue - 240) / 20.0
        } else if hue > 320 && hue <= 340 {
            return 1.0 - (hue - 320) / 20.0
        }
        return 0.0
    }
    
    private static func pinkRedHueScore(_ hue: Double) -> Double {
        // Pink-red range (320-360 and 0-20)
        if (hue >= 320 && hue <= 360) || (hue >= 0 && hue <= 20) {
            return 1.0
        } else if hue >= 300 && hue < 320 {
            return (hue - 300) / 20.0
        } else if hue > 20 && hue <= 40 {
            return 1.0 - (hue - 20) / 20.0
        }
        return 0.0
    }
    
    private static func luxuryHueScore(_ hue: Double) -> Double {
        // Purple and gold hues
        let purpleScore = purpleHueScore(hue)
        let goldScore = hue >= 40 && hue <= 60 ? 1.0 : 0.0
        return max(purpleScore, goldScore)
    }
    
    private static func colorDistance(_ color1: String, _ color2: String) -> Double {
        guard let rgba1 = try? HexColorFormatter.parse(color1),
              let rgba2 = try? HexColorFormatter.parse(color2) else { return 0.0 }
        
        // Simple Euclidean distance in RGB space
        let dr = rgba1.r - rgba2.r
        let dg = rgba1.g - rgba2.g
        let db = rgba1.b - rgba2.b
        
        return sqrt(dr * dr + dg * dg + db * db)
    }
}

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
