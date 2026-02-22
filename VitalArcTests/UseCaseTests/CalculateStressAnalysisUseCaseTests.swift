//
//  CalculateStressAnalysisUseCaseTests.swift
//  VitalArcTests
//
//  Unit tests for CalculateStressAnalysisUseCase
//

import XCTest
@testable import VitalArc

final class CalculateStressAnalysisUseCaseTests: XCTestCase {

    var useCase: CalculateStressAnalysisUseCase!
    let testDate = Date()

    override func setUp() {
        super.setUp()
        useCase = CalculateStressAnalysisUseCase()
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeDaytimeReading(value: Double, minutesAgo: Int = 0) -> HRVReading {
        HRVReading(
            timestamp: Date().addingTimeInterval(TimeInterval(-minutesAgo * 60)),
            value: value,
            context: .daytime
        )
    }

    private func makeSleepReading(value: Double, minutesAgo: Int = 0) -> HRVReading {
        HRVReading(
            timestamp: Date().addingTimeInterval(TimeInterval(-minutesAgo * 60)),
            value: value,
            context: .sleep
        )
    }

    // MARK: - No Data

    func testNoReadingsReturnsLowStress() {
        let result = useCase.execute(readings: [], baseline: nil, date: testDate)

        XCTAssertEqual(result.stressLevel, .low)
        XCTAssertNil(result.overallHRV)
        XCTAssertNil(result.daytimeHRV)
        XCTAssertNil(result.sleepHRV)
        XCTAssertEqual(result.daytimeReadingCount, 0)
        XCTAssertEqual(result.sleepReadingCount, 0)
    }

    func testNoReadingsWithBaselineReturnsLowStress() {
        let result = useCase.execute(readings: [], baseline: 60.0, date: testDate)

        XCTAssertEqual(result.stressLevel, .low)
    }

    // MARK: - Low Stress

    func testHighHRVAboveBaselineIsLowStress() {
        let readings = [
            makeDaytimeReading(value: 65, minutesAgo: 60),
            makeDaytimeReading(value: 70, minutesAgo: 30),
            makeSleepReading(value: 72, minutesAgo: 120),
            makeSleepReading(value: 68, minutesAgo: 90)
        ]

        let result = useCase.execute(readings: readings, baseline: 60.0, date: testDate)

        XCTAssertEqual(result.stressLevel, .low)
        XCTAssertNotNil(result.overallHRV)
    }

    // MARK: - High Stress

    func testVeryLowHRVBelowBaselineIsHighStress() {
        // Low absolute HRV + way below baseline + high variability
        let readings = [
            makeDaytimeReading(value: 15, minutesAgo: 60),
            makeDaytimeReading(value: 12, minutesAgo: 30),
            makeSleepReading(value: 45, minutesAgo: 120),
            makeSleepReading(value: 50, minutesAgo: 90)
        ]

        let result = useCase.execute(readings: readings, baseline: 60.0, date: testDate)

        XCTAssertEqual(result.stressLevel, .high)
    }

    // MARK: - Moderate Stress

    func testSlightlyBelowBaselineIsModerateStress() {
        let readings = [
            makeDaytimeReading(value: 48, minutesAgo: 60),
            makeDaytimeReading(value: 50, minutesAgo: 30),
            makeSleepReading(value: 55, minutesAgo: 120),
            makeSleepReading(value: 57, minutesAgo: 90)
        ]

        let result = useCase.execute(readings: readings, baseline: 60.0, date: testDate)

        // Below baseline (ratio ~0.88) gives +1, moderate daytime/sleep gap gives +1
        XCTAssertTrue(result.stressLevel == .moderate || result.stressLevel == .low)
    }

    // MARK: - Daytime vs Sleep Ratio

    func testLargeDaytimeSleepGapIncreasesStress() {
        // Very low daytime, high sleep = big gap
        let readings = [
            makeDaytimeReading(value: 25, minutesAgo: 60),
            makeDaytimeReading(value: 28, minutesAgo: 30),
            makeSleepReading(value: 70, minutesAgo: 120),
            makeSleepReading(value: 72, minutesAgo: 90)
        ]

        let result = useCase.execute(readings: readings, baseline: nil, date: testDate)

        XCTAssertNotNil(result.daytimeToSleepRatio)
        XCTAssertTrue(result.daytimeToSleepRatio! < 0.5)
        // Daytime/sleep gap contributes heavily
        XCTAssertTrue(result.stressLevel == .elevated || result.stressLevel == .high)
    }

    // MARK: - Only Daytime Readings

    func testOnlyDaytimeReadingsWorks() {
        let readings = [
            makeDaytimeReading(value: 55, minutesAgo: 60),
            makeDaytimeReading(value: 58, minutesAgo: 30)
        ]

        let result = useCase.execute(readings: readings, baseline: 60.0, date: testDate)

        XCTAssertNotNil(result.daytimeHRV)
        XCTAssertNil(result.sleepHRV)
        XCTAssertNil(result.daytimeToSleepRatio)
        XCTAssertEqual(result.daytimeReadingCount, 2)
        XCTAssertEqual(result.sleepReadingCount, 0)
    }

    // MARK: - Only Sleep Readings

    func testOnlySleepReadingsWorks() {
        let readings = [
            makeSleepReading(value: 65, minutesAgo: 120),
            makeSleepReading(value: 70, minutesAgo: 90)
        ]

        let result = useCase.execute(readings: readings, baseline: 60.0, date: testDate)

        XCTAssertNil(result.daytimeHRV)
        XCTAssertNotNil(result.sleepHRV)
        XCTAssertEqual(result.daytimeReadingCount, 0)
        XCTAssertEqual(result.sleepReadingCount, 2)
    }

    // MARK: - Coefficient of Variation

    func testCoefficientOfVariationIsCalculated() {
        let readings = [
            makeDaytimeReading(value: 30, minutesAgo: 60),
            makeDaytimeReading(value: 70, minutesAgo: 30),
            makeSleepReading(value: 40, minutesAgo: 120),
            makeSleepReading(value: 80, minutesAgo: 90)
        ]

        let result = useCase.execute(readings: readings, baseline: nil, date: testDate)

        XCTAssertNotNil(result.hrvCoefficientOfVariation)
        XCTAssertTrue(result.hrvCoefficientOfVariation! > 0)
    }

    func testSingleReadingHasNilCV() {
        let readings = [makeDaytimeReading(value: 55)]

        let result = useCase.execute(readings: readings, baseline: nil, date: testDate)

        XCTAssertNil(result.hrvCoefficientOfVariation)
    }

    // MARK: - Insight Generation

    func testLowStressInsight() {
        let readings = [
            makeDaytimeReading(value: 70, minutesAgo: 60),
            makeSleepReading(value: 72, minutesAgo: 120)
        ]

        let result = useCase.execute(readings: readings, baseline: 60.0, date: testDate)

        XCTAssertFalse(result.insight.isEmpty)
    }

    func testHighStressInsight() {
        let readings = [
            makeDaytimeReading(value: 12, minutesAgo: 60),
            makeDaytimeReading(value: 15, minutesAgo: 30),
            makeSleepReading(value: 45, minutesAgo: 120),
            makeSleepReading(value: 50, minutesAgo: 90)
        ]

        let result = useCase.execute(readings: readings, baseline: 60.0, date: testDate)

        XCTAssertTrue(result.insight.contains("High stress"))
    }

    // MARK: - Date Passthrough

    func testDateIsPassedThrough() {
        let specificDate = Date(timeIntervalSince1970: 1000000)
        let result = useCase.execute(readings: [], baseline: nil, date: specificDate)

        XCTAssertEqual(result.date, specificDate)
    }
}
