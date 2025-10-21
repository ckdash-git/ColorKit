import Foundation
#if SWIFT_PACKAGE
import ColorCore
#endif

public enum Palettes {
    public static let defaultLight = Theme(name: "DefaultLight", colors: [
        "primary": "#0A84FF",
        "secondary": "#5E5CE6",
        "background": "#FFFFFF",
        "surface": "#F2F2F7",
        "text": "#1C1C1E",
        "danger": "#FF3B30",
        "success": "#34C759"
    ])

    public static let defaultDark = Theme(name: "DefaultDark", colors: [
        "primary": "#0A84FF",
        "secondary": "#5E5CE6",
        "background": "#000000",
        "surface": "#1C1C1E",
        "text": "#FFFFFF",
        "danger": "#FF453A",
        "success": "#30D158"
    ])

    public static func materialBlue(name: String = "MaterialBlue") -> Theme {
        return Theme(name: name, colors: [
            "blue50": "#E3F2FD", "blue100": "#BBDEFB", "blue200": "#90CAF9",
            "blue300": "#64B5F6", "blue400": "#42A5F5", "blue500": "#2196F3",
            "blue600": "#1E88E5", "blue700": "#1976D2", "blue800": "#1565C0",
            "blue900": "#0D47A1"
        ])
    }
}