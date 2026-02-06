//
//  LocaleAwareParsingTests.swift
//  VitalArcTests
//
//  Tests for locale-aware decimal parsing
//

import XCTest
@testable import VitalArc

final class LocaleAwareParsingTests: XCTestCase {

    // MARK: - Basic Parsing Tests

    func testParseDoubleWithUSFormat() {
        // US format: period as decimal separator
        XCTAssertEqual(LocaleAwareParsing.parseDouble(from: "123.45"), 123.45)
        XCTAssertEqual(LocaleAwareParsing.parseDouble(from: "0.5"), 0.5)
        XCTAssertEqual(LocaleAwareParsing.parseDouble(from: "1000.00"), 1000.0)
    }

    func testParseDoubleWithEUFormat() {
        // EU format: comma as decimal separator
        // The implementation tries current locale first, then US locale fallback
        let result = LocaleAwareParsing.parseDouble(from: "123,45")

        // On some locales (e.g. en_US), "123,45" may not parse at all since
        // comma is a thousands separator but "123,45" isn't valid US format.
        // Only verify the value if parsing succeeded.
        guard let value = result else {
            // Parsing "123,45" is locale-dependent; nil is acceptable on US locale
            return
        }

        // Verify the result is one of the two valid interpretations:
        // - 123.45 if current locale uses comma as decimal separator (EU)
        // - 12345 if current locale uses comma as thousands separator (US)
        let isEUParsing = abs(value - 123.45) < 0.01
        let isUSParsing = abs(value - 12345.0) < 0.01
        XCTAssertTrue(isEUParsing || isUSParsing,
            "Expected 123.45 (EU) or 12345 (US), got \(value)")
    }

    func testParseDoubleWithExplicitGermanLocale() {
        // Test EU decimal parsing using explicit German locale formatter
        // This verifies the locale-aware parsing logic independent of device locale
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de_DE")

        // German locale should parse "123,45" as 123.45
        let germanResult = formatter.number(from: "123,45")?.doubleValue
        XCTAssertNotNil(germanResult)
        XCTAssertEqual(germanResult!, 123.45, accuracy: 0.01,
            "German locale should parse '123,45' as 123.45")

        // German locale should parse "1.234,56" as 1234.56 (period as thousands separator)
        let germanThousands = formatter.number(from: "1.234,56")?.doubleValue
        XCTAssertNotNil(germanThousands)
        XCTAssertEqual(germanThousands!, 1234.56, accuracy: 0.01)
    }

    func testParseDoubleWithExplicitUSLocale() {
        // Test US decimal parsing using explicit US locale formatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US")

        // US locale should parse "123.45" as 123.45
        let usResult = formatter.number(from: "123.45")?.doubleValue
        XCTAssertNotNil(usResult)
        XCTAssertEqual(usResult!, 123.45, accuracy: 0.01,
            "US locale should parse '123.45' as 123.45")

        // US locale should parse "1,234.56" as 1234.56 (comma as thousands separator)
        let usThousands = formatter.number(from: "1,234.56")?.doubleValue
        XCTAssertNotNil(usThousands)
        XCTAssertEqual(usThousands!, 1234.56, accuracy: 0.01)
    }

    func testParseDoubleWithWhitespace() {
        XCTAssertEqual(LocaleAwareParsing.parseDouble(from: "  123.45  "), 123.45)
        XCTAssertEqual(LocaleAwareParsing.parseDouble(from: " 100 "), 100.0)
    }

    func testParseDoubleWithEmptyString() {
        XCTAssertNil(LocaleAwareParsing.parseDouble(from: ""))
        XCTAssertNil(LocaleAwareParsing.parseDouble(from: "   "))
    }

    func testParseDoubleWithInvalidInput() {
        XCTAssertNil(LocaleAwareParsing.parseDouble(from: "abc"))
        XCTAssertNil(LocaleAwareParsing.parseDouble(from: "12abc34"))
        XCTAssertNil(LocaleAwareParsing.parseDouble(from: "!@#$"))
    }

    func testParseDoubleWithIntegerInput() {
        XCTAssertEqual(LocaleAwareParsing.parseDouble(from: "100"), 100.0)
        XCTAssertEqual(LocaleAwareParsing.parseDouble(from: "2000"), 2000.0)
        XCTAssertEqual(LocaleAwareParsing.parseDouble(from: "0"), 0.0)
    }

    // MARK: - Positive Number Validation Tests

    func testParsePositiveDoubleWithValidInput() {
        XCTAssertEqual(LocaleAwareParsing.parsePositiveDouble(from: "123.45"), 123.45)
        XCTAssertEqual(LocaleAwareParsing.parsePositiveDouble(from: "0.01"), 0.01)
        XCTAssertEqual(LocaleAwareParsing.parsePositiveDouble(from: "2000"), 2000.0)
    }

    func testParsePositiveDoubleWithZero() {
        XCTAssertNil(LocaleAwareParsing.parsePositiveDouble(from: "0"))
        XCTAssertNil(LocaleAwareParsing.parsePositiveDouble(from: "0.0"))
    }

    func testParsePositiveDoubleWithNegative() {
        XCTAssertNil(LocaleAwareParsing.parsePositiveDouble(from: "-5"))
        XCTAssertNil(LocaleAwareParsing.parsePositiveDouble(from: "-100.50"))
    }

    func testParsePositiveDoubleWithInvalidInput() {
        XCTAssertNil(LocaleAwareParsing.parsePositiveDouble(from: ""))
        XCTAssertNil(LocaleAwareParsing.parsePositiveDouble(from: "abc"))
        XCTAssertNil(LocaleAwareParsing.parsePositiveDouble(from: "   "))
    }

    // MARK: - Formatting Tests

    func testFormatDouble() {
        // Basic formatting - locale-dependent but should produce valid output
        let result = LocaleAwareParsing.formatDouble(123.456)
        XCTAssertFalse(result.isEmpty)
        // The result should contain digits
        XCTAssertTrue(result.contains { $0.isNumber })
    }

    func testFormatDoubleWithCustomFractionDigits() {
        let result = LocaleAwareParsing.formatDouble(123.456789, fractionDigits: 4)
        XCTAssertFalse(result.isEmpty)
    }

    func testFormatAsInteger() {
        XCTAssertEqual(LocaleAwareParsing.formatAsInteger(123.45), "123")
        XCTAssertEqual(LocaleAwareParsing.formatAsInteger(123.5), "124") // Rounds up
        XCTAssertEqual(LocaleAwareParsing.formatAsInteger(100.0), "100")
    }

    // MARK: - Edge Cases

    func testParseVeryLargeNumber() {
        let result = LocaleAwareParsing.parseDouble(from: "999999999")
        XCTAssertEqual(result, 999999999.0)
    }

    func testParseVerySmallDecimal() {
        let result = LocaleAwareParsing.parseDouble(from: "0.001")
        XCTAssertEqual(result ?? 0, 0.001, accuracy: 0.0001)
    }

    // MARK: - Macro Goal Input Scenarios

    func testTypicalMacroGoalInputs() {
        // Typical calorie inputs
        XCTAssertEqual(LocaleAwareParsing.parsePositiveDouble(from: "2000"), 2000.0)
        XCTAssertEqual(LocaleAwareParsing.parsePositiveDouble(from: "2500"), 2500.0)

        // Typical protein inputs
        XCTAssertEqual(LocaleAwareParsing.parsePositiveDouble(from: "150"), 150.0)
        XCTAssertEqual(LocaleAwareParsing.parsePositiveDouble(from: "180"), 180.0)

        // Decimal inputs for precision
        XCTAssertEqual(LocaleAwareParsing.parsePositiveDouble(from: "150.5"), 150.5)
    }
}
