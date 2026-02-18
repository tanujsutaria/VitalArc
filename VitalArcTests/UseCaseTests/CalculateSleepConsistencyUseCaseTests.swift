//
//  CalculateSleepConsistencyUseCaseTests.swift
//  VitalArcTests
//
//  Unit tests for CalculateSleepConsistencyUseCase
//

import XCTest
@testable import VitalArc

final class CalculateSleepConsistencyUseCaseTests: XCTestCase {

    var sut: CalculateSleepConsistencyUseCase!

    override func setUp() {
        super.setUp()
        sut = CalculateSleepConsistencyUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Consistent Sleep Tests

    func testConsistentSleepReturnsHighScore() {
        // All 7 days with exactly 8 hours of sleep = zero variance = score 100
        let metrics = (0..<7).map { day in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-day * 86400)),
                sleepHours: 8.0
            )
        }

        let result = sut.execute(weekMetrics: metrics)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.consistencyScore, 100)
        XCTAssertEqual(result?.bedtimeVariance ?? -1, 0, accuracy: 0.1)
        XCTAssertEqual(result?.wakeVariance ?? -1, 0, accuracy: 0.1)
    }

    // MARK: - Irregular Sleep Tests

    func testIrregularSleepReturnsLowScore() {
        // Wide variance in sleep hours: 4, 10, 5, 11, 4, 10, 5
        let sleepHours: [Double] = [4, 10, 5, 11, 4, 10, 5]
        let metrics = sleepHours.enumerated().map { (index, hours) in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-index * 86400)),
                sleepHours: hours
            )
        }

        let result = sut.execute(weekMetrics: metrics)

        XCTAssertNotNil(result)
        // Score should be low due to high variance
        XCTAssertLessThan(result?.consistencyScore ?? 100, 50)
    }

    // MARK: - Edge Cases

    func testNoDataReturnsNil() {
        let result = sut.execute(weekMetrics: [])
        XCTAssertNil(result)
    }

    func testSingleDayReturnsNil() {
        let metrics = [HealthMetrics(date: Date(), sleepHours: 7.5)]
        let result = sut.execute(weekMetrics: metrics)
        XCTAssertNil(result)
    }

    func testMetricsWithoutSleepDataReturnsNil() {
        // Metrics that have other data but no sleep hours
        let metrics = (0..<7).map { day in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-day * 86400)),
                heartRateVariability: 75.0,
                steps: 10000
            )
        }

        let result = sut.execute(weekMetrics: metrics)
        XCTAssertNil(result)
    }

    func testTwoDaysIsMinimumForScore() {
        let metrics = [
            HealthMetrics(date: Date(), sleepHours: 7.5),
            HealthMetrics(date: Date().addingTimeInterval(-86400), sleepHours: 7.5)
        ]

        let result = sut.execute(weekMetrics: metrics)
        XCTAssertNotNil(result)
        // Same sleep hours = high score
        XCTAssertEqual(result?.consistencyScore, 100)
    }

    func testMixedDataPartialSleep() {
        // Some days with sleep, some without — should only consider days with sleep
        let metrics = [
            HealthMetrics(date: Date(), sleepHours: 8.0),
            HealthMetrics(date: Date().addingTimeInterval(-86400), heartRateVariability: 75),
            HealthMetrics(date: Date().addingTimeInterval(-2 * 86400), sleepHours: 7.5),
            HealthMetrics(date: Date().addingTimeInterval(-3 * 86400), sleepHours: 8.0),
        ]

        let result = sut.execute(weekMetrics: metrics)
        XCTAssertNotNil(result)
        // 3 days with sleep: 8.0, 7.5, 8.0 — fairly consistent
        XCTAssertGreaterThan(result?.consistencyScore ?? 0, 60)
    }

    // MARK: - Score Range Tests

    func testScoreIsWithinValidRange() {
        // Various sleep patterns
        let patterns: [[Double]] = [
            [8, 8, 8, 8, 8, 8, 8],     // Perfect
            [6, 7, 8, 9, 10, 6, 7],     // Moderate
            [3, 12, 4, 11, 3, 12, 4],   // Very irregular
        ]

        for pattern in patterns {
            let metrics = pattern.enumerated().map { (index, hours) in
                HealthMetrics(
                    date: Date().addingTimeInterval(Double(-index * 86400)),
                    sleepHours: hours
                )
            }

            let result = sut.execute(weekMetrics: metrics)
            XCTAssertNotNil(result)
            XCTAssertGreaterThanOrEqual(result?.consistencyScore ?? -1, 0)
            XCTAssertLessThanOrEqual(result?.consistencyScore ?? 101, 100)
        }
    }
}
