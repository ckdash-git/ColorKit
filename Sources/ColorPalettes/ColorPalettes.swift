import Foundation
#if SWIFT_PACKAGE
import ColorCore
#endif

// MARK: - Default Themes
public let defaultLight = Theme(name: "Light", colors: [
    "primary": "#007AFF",
    "secondary": "#5856D6",
    "success": "#34C759",
    "warning": "#FF9500",
    "danger": "#FF3B30",
    "background": "#FFFFFF",
    "surface": "#F2F2F7",
    "text": "#000000",
    "textSecondary": "#8E8E93"
])

public let defaultDark = Theme(name: "Dark", colors: [
    "primary": "#0A84FF",
    "secondary": "#5E5CE6",
    "success": "#30D158",
    "warning": "#FF9F0A",
    "danger": "#FF453A",
    "background": "#000000",
    "surface": "#1C1C1E",
    "text": "#FFFFFF",
    "textSecondary": "#8E8E93"
])

// MARK: - Material Blue Theme
public func materialBlue() -> Theme {
    return Theme(name: "Material Blue", colors: [
        "primary": "#2196F3",
        "primaryLight": "#BBDEFB",
        "primaryDark": "#1976D2",
        "accent": "#FF4081",
        "background": "#FAFAFA",
        "surface": "#FFFFFF",
        "text": "#212121",
        "textSecondary": "#757575"
    ])
}

// MARK: - Data Visualization Palettes

/// Specialized color palettes for data visualization
public struct DataVisualizationPalettes {
    
    // MARK: - Sequential Palettes (for continuous data)
    
    /// Blues sequential palette - ideal for showing data progression
    public static let blues: [String] = [
        "#F7FBFF", "#DEEBF7", "#C6DBEF", "#9ECAE1",
        "#6BAED6", "#4292C6", "#2171B5", "#08519C", "#08306B"
    ]
    
    /// Greens sequential palette - great for positive metrics
    public static let greens: [String] = [
        "#F7FCF5", "#E5F5E0", "#C7E9C0", "#A1D99B",
        "#74C476", "#41AB5D", "#238B45", "#006D2C", "#00441B"
    ]
    
    /// Reds sequential palette - effective for highlighting issues
    public static let reds: [String] = [
        "#FFF5F0", "#FEE0D2", "#FCBBA1", "#FC9272",
        "#FB6A4A", "#EF3B2C", "#CB181D", "#A50F15", "#67000D"
    ]
    
    /// Purples sequential palette - elegant for general data
    public static let purples: [String] = [
        "#FCFBFD", "#EFEDF5", "#DADAEB", "#BCBDDC",
        "#9E9AC8", "#807DBA", "#6A51A3", "#54278F", "#3F007D"
    ]
    
    /// Oranges sequential palette - warm and attention-grabbing
    public static let oranges: [String] = [
        "#FFF5EB", "#FEE6CE", "#FDD0A2", "#FDAE6B",
        "#FD8D3C", "#F16913", "#D94801", "#A63603", "#7F2704"
    ]
    
    // MARK: - Diverging Palettes (for data with meaningful center)
    
    /// Red-Blue diverging palette - classic for showing opposing values
    public static let redBlue: [String] = [
        "#67001F", "#B2182B", "#D6604D", "#F4A582", "#FDDBC7",
        "#F7F7F7", "#D1E5F0", "#92C5DE", "#4393C3", "#2166AC", "#053061"
    ]
    
    /// Red-Yellow-Blue diverging palette - great for temperature-like data
    public static let redYellowBlue: [String] = [
        "#A50026", "#D73027", "#F46D43", "#FDAE61", "#FEE090",
        "#FFFFBF", "#E0F3F8", "#ABD9E9", "#74ADD1", "#4575B4", "#313695"
    ]
    
    /// Purple-Green diverging palette - sophisticated alternative
    public static let purpleGreen: [String] = [
        "#40004B", "#762A83", "#9970AB", "#C2A5CF", "#E7D4E8",
        "#F7F7F7", "#D9F0D3", "#A6DBA0", "#5AAE61", "#1B7837", "#00441B"
    ]
    
    /// Brown-Teal diverging palette - earthy and modern
    public static let brownTeal: [String] = [
        "#8C510A", "#BF812D", "#DFC27D", "#F6E8C3", "#F5F5F5",
        "#C7EAE5", "#80CDC1", "#35978F", "#01665E", "#003C30"
    ]
    
    // MARK: - Qualitative Palettes (for categorical data)
    
    /// Set1 qualitative palette - high contrast for distinct categories
    public static let set1: [String] = [
        "#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
        "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"
    ]
    
    /// Set2 qualitative palette - softer colors for better readability
    public static let set2: [String] = [
        "#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3",
        "#A6D854", "#FFD92F", "#E5C494", "#B3B3B3"
    ]
    
    /// Set3 qualitative palette - pastel colors for subtle distinctions
    public static let set3: [String] = [
        "#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072",
        "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5",
        "#D9D9D9", "#BC80BD", "#CCEBC5", "#FFED6F"
    ]
    
    /// Dark2 qualitative palette - darker colors for professional look
    public static let dark2: [String] = [
        "#1B9E77", "#D95F02", "#7570B3", "#E7298A",
        "#66A61E", "#E6AB02", "#A6761D", "#666666"
    ]
    
    /// Tableau10 qualitative palette - optimized for data visualization
    public static let tableau10: [String] = [
        "#4E79A7", "#F28E2C", "#E15759", "#76B7B2",
        "#59A14F", "#EDC949", "#AF7AA1", "#FF9DA7",
        "#9C755F", "#BAB0AB"
    ]
    
    // MARK: - Accessibility-Friendly Palettes
    
    /// Colorblind-safe qualitative palette
    public static let colorblindSafe: [String] = [
        "#1F77B4", "#FF7F0E", "#2CA02C", "#D62728",
        "#9467BD", "#8C564B", "#E377C2", "#7F7F7F",
        "#BCBD22", "#17BECF"
    ]
    
    /// High contrast palette for accessibility
    public static let highContrast: [String] = [
        "#000000", "#FFFFFF", "#FF0000", "#00FF00",
        "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF"
    ]
    
    // MARK: - Specialized Palettes
    
    /// Traffic light palette for status indicators
    public static let trafficLight: [String] = [
        "#FF4444", "#FFAA00", "#00AA00"
    ]
    
    /// Heatmap palette for intensity visualization
    public static let heatmap: [String] = [
        "#000428", "#004CFF", "#009FFF", "#00FFFF",
        "#5AFF00", "#FFFF00", "#FF9500", "#FF0000"
    ]
    
    /// Viridis palette - perceptually uniform and colorblind-friendly
    public static let viridis: [String] = [
        "#440154", "#482777", "#3F4A8A", "#31678E",
        "#26838F", "#1F9D8A", "#6CCE5A", "#B6DE2B", "#FEE825"
    ]
    
    /// Plasma palette - vibrant and perceptually uniform
    public static let plasma: [String] = [
        "#0C0786", "#40039A", "#6A00A7", "#8F0DA4",
        "#B12A90", "#CC4678", "#E16462", "#F1834C", "#FCA636", "#FCCE25"
    ]
    
    // MARK: - Palette Utilities
    
    /// Get a subset of colors from a palette
    /// - Parameters:
    ///   - palette: Source color palette
    ///   - count: Number of colors needed
    /// - Returns: Evenly distributed colors from the palette
    public static func subset(from palette: [String], count: Int) -> [String] {
        guard count > 0 && !palette.isEmpty else { return [] }
        guard count < palette.count else { return palette }
        
        var result: [String] = []
        let step = Double(palette.count - 1) / Double(count - 1)
        
        for i in 0..<count {
            let index = Int(round(Double(i) * step))
            result.append(palette[index])
        }
        
        return result
    }
    
    /// Generate a custom sequential palette from a base color
    /// - Parameters:
    ///   - baseColor: Starting color in hex format
    ///   - steps: Number of steps in the palette
    /// - Returns: Sequential palette from light to the base color
    public static func generateSequential(from baseColor: String, steps: Int = 9) -> [String] {
        guard let baseRGBA = try? HexColorFormatter.parse(baseColor) else { return [baseColor] }
        
        let lightRGBA = RGBA(r: 0.98, g: 0.98, b: 0.98, a: 1.0)
        var colors: [String] = []
        
        for i in 0..<steps {
            let ratio = Double(i) / Double(steps - 1)
            let blended = PerceptualColorMath.perceptualBlend(lightRGBA, baseRGBA, ratio: ratio)
            colors.append(HexColorFormatter.format(blended))
        }
        
        return colors
    }
    
    /// Generate a custom diverging palette from two colors
    /// - Parameters:
    ///   - startColor: Starting color in hex format
    ///   - endColor: Ending color in hex format
    ///   - steps: Number of steps in the palette (should be odd for symmetric center)
    /// - Returns: Diverging palette with neutral center
    public static func generateDiverging(from startColor: String, to endColor: String, steps: Int = 11) -> [String] {
        guard let startRGBA = try? HexColorFormatter.parse(startColor),
              let endRGBA = try? HexColorFormatter.parse(endColor) else {
            return [startColor, endColor]
        }
        
        let centerRGBA = RGBA(r: 0.97, g: 0.97, b: 0.97, a: 1.0) // Light gray center
        let halfSteps = steps / 2
        var colors: [String] = []
        
        // First half: start to center
        for i in 0..<halfSteps {
            let ratio = Double(i) / Double(halfSteps)
            let blended = PerceptualColorMath.perceptualBlend(startRGBA, centerRGBA, ratio: ratio)
            colors.append(HexColorFormatter.format(blended))
        }
        
        // Center color
        if steps % 2 == 1 {
            colors.append(HexColorFormatter.format(centerRGBA))
        }
        
        // Second half: center to end
        for i in 0..<halfSteps {
            let ratio = Double(i + 1) / Double(halfSteps)
            let blended = PerceptualColorMath.perceptualBlend(centerRGBA, endRGBA, ratio: ratio)
            colors.append(HexColorFormatter.format(blended))
        }
        
        return colors
    }
}