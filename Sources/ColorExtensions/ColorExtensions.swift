import Foundation
#if SWIFT_PACKAGE
import ColorCore
import ColorUtilities
#endif

#if canImport(UIKit)
import UIKit
import QuartzCore

public extension UIColor {
    convenience init?(hex: String) {
        guard let rgba = try? HexColorFormatter.parse(hex) else { return nil }
        self.init(red: CGFloat(rgba.r), green: CGFloat(rgba.g), blue: CGFloat(rgba.b), alpha: CGFloat(rgba.a))
    }

    /// Dynamic color that switches between light and dark variants
    static func dynamic(lightHex: String, darkHex: String) -> UIColor {
        let light = UIColor(hex: lightHex) ?? UIColor.white
        let dark = UIColor(hex: darkHex) ?? UIColor.black
        if #available(iOS 13.0, *) {
            return UIColor { trait in
                return trait.userInterfaceStyle == .dark ? dark : light
            }
        } else {
            return light
        }
    }
}

public struct GradientBuilder {
    /// Create a CAGradientLayer from hex strings
    public static func layer(hexColors: [String], startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        layer.colors = hexColors.compactMap { UIColor(hex: $0)?.cgColor }
        return layer
    }
}
#endif

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Color {
    init?(hex: String) {
        guard let rgba = try? HexColorFormatter.parse(hex) else { return nil }
        self = Color(red: rgba.r, green: rgba.g, blue: rgba.b, opacity: rgba.a)
    }

    /// Dynamic Color that adapts to color scheme (uses UIKit bridge on iOS)
    static func dynamic(lightHex: String, darkHex: String) -> Color {
        #if canImport(UIKit)
        let ui = UIColor.dynamic(lightHex: lightHex, darkHex: darkHex)
        if #available(iOS 15.0, tvOS 15.0, *) {
            return Color(uiColor: ui)
        } else {
            // Fallback on iOS/tvOS < 15: return the light variant
            return Color(hex: lightHex) ?? Color.white
        }
        #else
        return Color(hex: lightHex) ?? Color.white
        #endif
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct SwiftUIGradientBuilder {
    public static func linear(hexColors: [String], startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) -> LinearGradient {
        let colors: [Color] = hexColors.compactMap { Color(hex: $0) }
        return LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
}
#endif