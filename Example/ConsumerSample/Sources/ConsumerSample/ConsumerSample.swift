import Foundation
import ColorKit

@main
struct ConsumerSample {
    static func main() {
        // 1) Hex parsing
        let hexString = "#0A84FF"
        if let rgba = try? HexColorFormatter.parse(hexString) {
            let formatted = HexColorFormatter.format(rgba, includeAlpha: false)
            print("Parsed RGBA: r=\(rgba.r), g=\(rgba.g), b=\(rgba.b), a=\(rgba.a)")
            print("Formatted back to hex: \(formatted)")
        } else {
            print("Failed to parse hex: \(hexString)")
        }

        // 2) Contrast ratio and accessibility
        let white = RGBA(r: 1.0, g: 1.0, b: 1.0, a: 1.0)
        let black = RGBA(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
        let contrast = ColorMath.contrastRatio(white, black)
        print("Contrast ratio (white on black): \(String(format: "%.2f", contrast))")
        print("WCAG AA normal text: \(Accessibility.meets(.AA, foreground: white, background: black))")

        // 3) Palettes
        let theme = Palettes.defaultLight
        if let primaryHex = theme.colors["primary"], let primaryRGBA = try? HexColorFormatter.parse(primaryHex) {
            print("DefaultLight primary hex: \(primaryHex) -> rgba r=\(String(format: "%.3f", primaryRGBA.r))")
        }

        // 4) Generate tints and shades
        let generated = PaletteGenerator.generate(from: "#42A5F5", steps: 4, range: 0.25)
        print("Generated palette around #42A5F5 (\(generated.count) colors): \(generated.joined(separator: ", "))")

        // 5) Color blindness simulation (approximate)
        if let rgba = try? HexColorFormatter.parse("#FF0000") {
            let protanopia = ColorBlindnessSimulator.simulate(.protanopia, rgba: rgba)
            print("Protanopia sim for red => r=\(String(format: "%.3f", protanopia.r)), g=\(String(format: "%.3f", protanopia.g)), b=\(String(format: "%.3f", protanopia.b))")
        }

        print("\nConsumerSample finished successfully.")
    }
}
