import XCTest
@testable import ColorsKit

final class HexAndContrastTests: XCTestCase {
    func testHexParsingShortRGB() throws {
        let rgba = try HexColorFormatter.parse("#0af")
        XCTAssertEqual(rgba.r, Double(0x00) / 255.0, accuracy: 0.001)
        XCTAssertEqual(rgba.g, Double(0xaa) / 255.0, accuracy: 0.001)
        XCTAssertEqual(rgba.b, Double(0xff) / 255.0, accuracy: 0.001)
        XCTAssertEqual(rgba.a, 1.0, accuracy: 0.001)
    }

    func testHexParsingWithAlpha() throws {
        let rgba = try HexColorFormatter.parse("336699CC")
        XCTAssertEqual(rgba.r, Double(0x33) / 255.0, accuracy: 0.001)
        XCTAssertEqual(rgba.g, Double(0x66) / 255.0, accuracy: 0.001)
        XCTAssertEqual(rgba.b, Double(0x99) / 255.0, accuracy: 0.001)
        XCTAssertEqual(rgba.a, Double(0xCC) / 255.0, accuracy: 0.001)
    }

    func testHexFormatting() {
        let s = HexColorFormatter.format(RGBA(r: 1, g: 0.5, b: 0, a: 0.75), includeAlpha: true)
        XCTAssertEqual(s, "#FF8000BF") // 0.75 -> 191 -> 0xBF
    }

    func testContrastRatioWhiteOnBlack() {
        let white = RGBA(r: 1, g: 1, b: 1)
        let black = RGBA(r: 0, g: 0, b: 0)
        let ratio = ColorMath.contrastRatio(white, black)
        XCTAssertGreaterThanOrEqual(ratio, 21.0 - 0.001) // max contrast ~21:1
        XCTAssertTrue(Accessibility.meets(.AAA, foreground: white, background: black))
    }
}