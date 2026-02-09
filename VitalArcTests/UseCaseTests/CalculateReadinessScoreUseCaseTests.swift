//
//  CalculateReadinessScoreUseCaseTests.swift
//  VitalArcTests
//
//  Tests for CalculateReadinessScoreUseCase edge cases and scoring logic
//

import XCTest
@testable import VitalArc

final class CalculateReadinessScoreUseCaseTests: XCTestCase {

    var sut: CalculateReadinessScoreUseCase!

    override func setUp() {
        super.setUp()
        sut = CalculateReadinessScoreUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Test Helpers

    private func makeMetrics(
        date: Date = Date(),
        hrv: Double? = nil,
        rhr: Double? = nil,
        sleepHours: Double? = nil,
        sleepStages: SleepStages? = nil
    ) -> HealthMetrics {
        HealthMetrics(
            date: date,
            heartRateVariability: hrv,
            restingHeartRate: rhr,
            sleepHours: sleepHours,
            sleepStages: sleepStages
        )
    }

    private func makeWeek(hrv: Double, rhr: Double, sleepHours: Double) -> [HealthMetrics] {
        (0..<7).map { day in
            makeMetrics(
                date: Calendar.current.date(byAdding: .day, value: -day, to: Date()) ?? Date(),
                hrv: hrv,
                rhr: rhr,
                sleepHours: sleepHours
            )
        }
    }

    // MARK: - Tests

    func testOptimalScore() {
        // HRV 10% above baseline -> ratio 1.1 -> min(40, 34 + 0.1*60) = 40
        // RHR 10% below baseline -> baseline/today = 60/54.5 ~1.1 -> min(25, 21 + 0.1*40) = 25
        // Good sleep stages -> high quality score
        // Sleep 8h -> duration = 15
        let weekMetrics = makeWeek(hrv: 60, rhr: 60, sleepHours: 8)

        let goodStages = SleepStages(deepSleep: 1.8, remSleep: 1.8, coreSleep: 4.4, awake: 0.5)
        let today = makeMetrics(
            hrv: 66, // 10% above baseline of 60
            rhr: 54, // 10% below baseline of 60
            sleepHours: 8,
            sleepStages: goodStages
        )

        let result = sut.execute(todayMetrics: today, weekMetrics: weekMetrics)

        XCTAssertGreaterThanOrEqual(result.overallScore, 80, "Optimal conditions should produce score >= 80")
        XCTAssertFalse(result.recommendation.isEmpty)
    }

    func testPoorScore() {
        // HRV 50% below baseline -> ratio 0.5 -> max(0, 34 + (-0.5)*60) = max(0, 4) = 4
        // RHR 50% above baseline -> ratio 60/90=0.667 -> max(0, 21 + (-0.333)*40) = max(0, 7.67) = 7.67
        // No sleep stages -> neutral quality = 10
        // Sleep 3h -> max(0, 15 - |3-8|*3) = max(0, 0) = 0
        let weekMetrics = makeWeek(hrv: 60, rhr: 60, sleepHours: 7)

        let today = makeMetrics(
            hrv: 30, // 50% below baseline
            rhr: 90, // 50% above baseline
            sleepHours: 3
        )

        let result = sut.execute(todayMetrics: today, weekMetrics: weekMetrics)

        XCTAssertLessThan(result.overallScore, 50, "Poor conditions should produce score < 50")
    }

    func testAllNilMetrics() {
        // All nil today metrics, empty week -> all neutral fallbacks
        // HRV neutral: 20, RHR neutral: 12.5, Sleep quality neutral: 10, Sleep duration neutral: 7.5
        // Total: 50
        let today = makeMetrics()
        let result = sut.execute(todayMetrics: today, weekMetrics: [])

        XCTAssertEqual(result.overallScore, 50, accuracy: 0.01, "All nil metrics should produce neutral score of 50")
        XCTAssertEqual(result.hrvContribution, 20, accuracy: 0.01)
        XCTAssertEqual(result.rhrContribution, 12.5, accuracy: 0.01)
        XCTAssertEqual(result.sleepQualityContribution, 10, accuracy: 0.01)
        XCTAssertEqual(result.sleepDurationContribution, 7.5, accuracy: 0.01)
    }

    func testEmptyWeekBaseline() {
        // Today has data but weekMetrics is empty -> baselines are nil
        // HRV: baseline nil -> neutral 20
        // RHR: baseline nil -> neutral 12.5
        // Sleep quality: no stages, no baseline -> neutral 10
        // Sleep duration: no baseline, todaySleep = 8 -> sleepDurationScore(8) = 15
        let today = makeMetrics(hrv: 70, rhr: 60, sleepHours: 8)

        let result = sut.execute(todayMetrics: today, weekMetrics: [])

        XCTAssertEqual(result.hrvContribution, 20, accuracy: 0.01, "No baseline should give neutral HRV")
        XCTAssertEqual(result.rhrContribution, 12.5, accuracy: 0.01, "No baseline should give neutral RHR")
        XCTAssertEqual(result.sleepDurationContribution, 15, accuracy: 0.01, "8h sleep should give max duration score")
    }

    func testNilTodayHRV() {
        // Today HRV is nil -> hrvContribution = 20 (neutral)
        let weekMetrics = makeWeek(hrv: 60, rhr: 60, sleepHours: 7)
        let today = makeMetrics(rhr: 60, sleepHours: 7)

        let result = sut.execute(todayMetrics: today, weekMetrics: weekMetrics)

        XCTAssertEqual(result.hrvContribution, 20, accuracy: 0.01, "Nil today HRV should produce neutral 20")
    }

    func testZeroBaselineHRV() {
        // Week has HRV values all 0 -> baseline = 0 -> guard catches (baseline > 0 fails)
        // -> neutral fallback 20
        let weekMetrics = makeWeek(hrv: 0, rhr: 60, sleepHours: 7)
        let today = makeMetrics(hrv: 50, rhr: 60, sleepHours: 7)

        let result = sut.execute(todayMetrics: today, weekMetrics: weekMetrics)

        XCTAssertEqual(result.hrvContribution, 20, accuracy: 0.01, "Zero baseline HRV should produce neutral 20")
    }

    func testZeroTodayRHR() {
        // Today RHR is 0 -> guard catches (todayRHR > 0 fails) -> neutral 12.5
        let weekMetrics = makeWeek(hrv: 60, rhr: 60, sleepHours: 7)
        let today = makeMetrics(hrv: 60, rhr: 0, sleepHours: 7)

        let result = sut.execute(todayMetrics: today, weekMetrics: weekMetrics)

        XCTAssertEqual(result.rhrContribution, 12.5, accuracy: 0.01, "Zero today RHR should produce neutral 12.5")
    }

    func testVeryShortSleep() {
        // sleepHours = 2.0 -> sleepDurationScore(2) = max(0, 15 - |2-8|*3) = max(0, 15 - 18) = 0
        let today = makeMetrics(sleepHours: 2)

        let result = sut.execute(todayMetrics: today, weekMetrics: [])

        XCTAssertEqual(result.sleepDurationContribution, 0, accuracy: 0.01, "2h sleep should produce 0 duration contribution")
    }

    func testScoreClamping() {
        // Verify the overall score is always between 0 and 100
        // Test with extreme values that could push individual contributions to their limits
        let weekMetrics = makeWeek(hrv: 10, rhr: 100, sleepHours: 3)

        // Extreme high: HRV way above baseline, RHR way below baseline
        let highToday = makeMetrics(hrv: 100, rhr: 10, sleepHours: 9)
        let highResult = sut.execute(todayMetrics: highToday, weekMetrics: weekMetrics)
        XCTAssertLessThanOrEqual(highResult.overallScore, 100, "Score should never exceed 100")
        XCTAssertGreaterThanOrEqual(highResult.overallScore, 0, "Score should never be negative")

        // Extreme low: HRV way below baseline, RHR way above
        let lowToday = makeMetrics(hrv: 1, rhr: 200, sleepHours: 0)
        let lowResult = sut.execute(todayMetrics: lowToday, weekMetrics: weekMetrics)
        XCTAssertLessThanOrEqual(lowResult.overallScore, 100, "Score should never exceed 100")
        XCTAssertGreaterThanOrEqual(lowResult.overallScore, 0, "Score should never be negative")
    }
}
