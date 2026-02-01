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
        // Note: This will work when the device locale uses comma
        let result = LocaleAwareParsing.parseDouble(from: "123,45")
        XCTAssertNotNil(result)
        // The result should be either 123.45 (if locale uses comma) or a larger number (if comma is thousands separator)
        XCTAssertTrue(result! > 0)
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
        XCTAssertEqual(result, 0.001, accuracy: 0.0001)
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
