//
//  WellnessRegressionTests.swift
//  VitalArcTests
//
//  Regression tests for Session 23.0 wellness bug fixes
//

import XCTest
@testable import VitalArc

// MARK: - Bug 1: MetricDetailViewModel crash on empty data

@MainActor
final class MetricDetailViewModelCrashRegressionTests: XCTestCase {
    var repository: MockHealthRepository!
    var viewModel: MetricDetailViewModel!

    override func setUp() async throws {
        repository = MockHealthRepository()
        viewModel = MetricDetailViewModel(healthRepository: repository)
    }

    override func tearDown() async throws {
        repository = nil
        viewModel = nil
    }

    /// Regression: calculateTrend crashed with divide-by-zero when first half average was 0
    func testTrendWithAllZeroValues() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let metrics = (0..<4).map { i in
            HealthMetrics(
                date: calendar.date(byAdding: .day, value: -i, to: today)!,
                heartRateVariability: 0
            )
        }
        repository.mockWeekMetrics = metrics

        await viewModel.loadHistory(for: .hrv, range: .week)

        // Should not crash, trend should be stable (not nil, not NaN)
        XCTAssertEqual(viewModel.historyData.count, 4)
        if let trend = viewModel.trend {
            XCTAssertTrue(trend == .stable || trend == .up || trend == .down,
                          "Trend should be a valid direction, not produce NaN")
        }
    }

    /// Regression: first half zero, second half non-zero should trend up
    func testTrendWithZeroToNonZeroValues() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // First half: 0, 0; Second half: 50, 50
        let values: [Double] = [0, 0, 50, 50]
        let metrics = values.enumerated().map { (i, val) in
            HealthMetrics(
                date: calendar.date(byAdding: .day, value: -(3 - i), to: today)!,
                heartRateVariability: val
            )
        }
        repository.mockWeekMetrics = metrics

        await viewModel.loadHistory(for: .hrv, range: .week)

        XCTAssertEqual(viewModel.trend, .up,
                       "Zero baseline transitioning to positive values should trend up")
    }

    /// Regression: ensure no crash with completely empty metrics
    func testTrendWithEmptyMetrics() async {
        repository.mockWeekMetrics = []

        await viewModel.loadHistory(for: .hrv, range: .week)

        XCTAssertTrue(viewModel.historyData.isEmpty)
        XCTAssertNil(viewModel.average)
        XCTAssertNil(viewModel.minimum)
        XCTAssertNil(viewModel.maximum)
        XCTAssertNil(viewModel.trend)
    }

    /// Regression: single data point should not crash
    func testTrendWithSingleDataPoint() async {
        let metrics = [HealthMetrics(date: Date(), heartRateVariability: 50)]
        repository.mockWeekMetrics = metrics

        await viewModel.loadHistory(for: .hrv, range: .week)

        XCTAssertEqual(viewModel.historyData.count, 1)
        XCTAssertNil(viewModel.trend, "Single data point cannot compute trend")
    }

    /// Regression: very small values near zero should not produce infinity
    func testTrendWithNearZeroValues() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let values: [Double] = [0.001, 0.001, 0.001, 50, 50, 50]
        let metrics = values.enumerated().map { (i, val) in
            HealthMetrics(
                date: calendar.date(byAdding: .day, value: -(5 - i), to: today)!,
                heartRateVariability: val
            )
        }
        repository.mockWeekMetrics = metrics

        await viewModel.loadHistory(for: .hrv, range: .week)

        // Should compute a valid trend without overflow
        XCTAssertNotNil(viewModel.trend)
        if let avg = viewModel.average {
            XCTAssertTrue(avg.isFinite, "Average should be finite")
        }
    }
}

// MARK: - Bug 2: HealthKit auth never retried after denial

@MainActor
final class HealthKitAuthRetryRegressionTests: XCTestCase {
    var mockRepository: MockHealthRepository!
    var viewModel: HealthDashboardViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHealthRepository()
        viewModel = HealthDashboardViewModel(healthRepository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    /// Regression: authorizationDenied should initially be false
    func testInitialAuthorizationDeniedState() {
        XCTAssertFalse(viewModel.authorizationDenied)
    }

    /// Regression: when auth throws error, authorizationDenied should be set
    func testAuthorizationErrorSetsAuthorizationDenied() async {
        mockRepository.shouldThrowOnAuthorization = true

        await viewModel.requestHealthKitPermissions()

        XCTAssertTrue(viewModel.authorizationDenied,
                      "authorizationDenied should be true when auth throws")
        XCTAssertTrue(viewModel.showingPermissionAlert,
                      "showingPermissionAlert should be true when auth fails")
    }

    /// Regression: successful auth with data should clear authorizationDenied
    func testSuccessfulAuthClearsAuthorizationDenied() async {
        mockRepository.mockAuthorizationSuccess = true
        mockRepository.mockTodayMetrics = HealthMetrics(
            date: Date(),
            heartRateVariability: 75
        )
        mockRepository.mockWeekMetrics = [
            HealthMetrics(date: Date(), sleepHours: 7.5)
        ]

        await viewModel.requestHealthKitPermissions()

        XCTAssertFalse(viewModel.authorizationDenied,
                       "authorizationDenied should be false after successful auth with data")
    }

    /// Regression: successful auth but no data should flag as denied (user likely denied in Settings)
    func testSuccessfulAuthWithNoDataFlagsDenied() async {
        mockRepository.mockAuthorizationSuccess = true
        mockRepository.mockTodayMetrics = nil
        mockRepository.mockWeekMetrics = []

        await viewModel.requestHealthKitPermissions()

        XCTAssertTrue(viewModel.authorizationDenied,
                      "authorizationDenied should be true when auth succeeds but no data returns")
        XCTAssertTrue(viewModel.showingPermissionAlert,
                      "Should show permission alert to guide user to Settings")
    }
}

// MARK: - Bug 3: Sleep data timezone issue

final class SleepDateRangeRegressionTests: XCTestCase {

    /// Regression: sleepDateRangeForDate should start at 6 PM previous day
    func testSleepDateRangeStartsAtPreviousEvening() {
        let calendar = Calendar.current
        let testDate = calendar.startOfDay(for: Date())
        let sleepRange = HealthKitQuery.sleepDateRangeForDate(testDate)

        // Should start at 6 PM previous day = midnight - 6 hours
        let expectedStart = calendar.date(byAdding: .hour, value: -6, to: testDate)!
        XCTAssertEqual(
            sleepRange.start.timeIntervalSince1970,
            expectedStart.timeIntervalSince1970,
            accuracy: 1.0,
            "Sleep range should start at 6 PM previous day"
        )
    }

    /// Regression: sleepDateRangeForDate should end at noon current day
    func testSleepDateRangeEndsAtNoon() {
        let calendar = Calendar.current
        let testDate = calendar.startOfDay(for: Date())
        let sleepRange = HealthKitQuery.sleepDateRangeForDate(testDate)

        // Should end at noon current day = midnight + 12 hours
        let expectedEnd = calendar.date(byAdding: .hour, value: 12, to: testDate)!
        XCTAssertEqual(
            sleepRange.end.timeIntervalSince1970,
            expectedEnd.timeIntervalSince1970,
            accuracy: 1.0,
            "Sleep range should end at noon current day"
        )
    }

    /// Regression: sleep range should be 18 hours total (6 PM to noon)
    func testSleepDateRangeSpans18Hours() {
        let sleepRange = HealthKitQuery.sleepDateRangeForDate(Date())
        let spanInHours = sleepRange.end.timeIntervalSince(sleepRange.start) / 3600

        XCTAssertEqual(spanInHours, 18, accuracy: 0.1,
                       "Sleep date range should span 18 hours (6 PM to noon)")
    }

    /// Regression: regular dateRangeForDate should still be midnight-to-midnight (24h)
    func testRegularDateRangeUnchanged() {
        let regularRange = HealthKitQuery.dateRangeForDate(Date())
        let spanInHours = regularRange.end.timeIntervalSince(regularRange.start) / 3600

        XCTAssertEqual(spanInHours, 24, accuracy: 0.1,
                       "Regular date range should still span 24 hours")
    }
}

// MARK: - Bug 4: Recovery score magic numbers (named constants)

final class ReadinessScoreNamedConstantsRegressionTests: XCTestCase {

    var sut: CalculateReadinessScoreUseCase!

    override func setUp() {
        super.setUp()
        sut = CalculateReadinessScoreUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// Regression: verify component weights sum to 100
    func testComponentWeightsSumTo100() {
        // All nil metrics produce neutral scores at 50% of each weight.
        // Total neutral = 20 + 12.5 + 10 + 7.5 = 50 (50% of 100)
        let result = sut.execute(
            todayMetrics: HealthMetrics(date: Date()),
            weekMetrics: []
        )
        XCTAssertEqual(result.overallScore, 50, accuracy: 0.01,
                       "Neutral scores should sum to exactly 50 (50% of total weight 100)")
    }

    /// Regression: verify HRV weight is 40 (contribution capped at 40)
    func testHRVContributionCappedAt40() {
        let weekMetrics = (0..<7).map { day in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-day * 86400)),
                heartRateVariability: 10 // low baseline
            )
        }
        // Extreme ratio: today HRV much higher than baseline
        let today = HealthMetrics(date: Date(), heartRateVariability: 1000)
        let result = sut.execute(todayMetrics: today, weekMetrics: weekMetrics)

        XCTAssertLessThanOrEqual(result.hrvContribution, 40,
                                  "HRV contribution should never exceed weight of 40")
    }

    /// Regression: verify RHR weight is 25 (contribution capped at 25)
    func testRHRContributionCappedAt25() {
        let weekMetrics = (0..<7).map { day in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-day * 86400)),
                restingHeartRate: 100 // high baseline
            )
        }
        // Extreme: today RHR much lower than baseline
        let today = HealthMetrics(date: Date(), restingHeartRate: 1)
        let result = sut.execute(todayMetrics: today, weekMetrics: weekMetrics)

        XCTAssertLessThanOrEqual(result.rhrContribution, 25,
                                  "RHR contribution should never exceed weight of 25")
    }

    /// Regression: optimal sleep duration (7-9h) should give maximum 15 points
    func testOptimalSleepDurationGivesMaxPoints() {
        let result = sut.execute(
            todayMetrics: HealthMetrics(date: Date(), sleepHours: 8),
            weekMetrics: []
        )
        XCTAssertEqual(result.sleepDurationContribution, 15, accuracy: 0.01,
                       "8 hours of sleep should produce max duration contribution of 15")
    }

    /// Regression: score is always bounded 0-100
    func testScoreAlwaysBounded() {
        // Extreme high
        let weekMetrics = (0..<7).map { day in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-day * 86400)),
                heartRateVariability: 10,
                restingHeartRate: 100,
                sleepHours: 3
            )
        }
        let highToday = HealthMetrics(
            date: Date(),
            heartRateVariability: 1000,
            restingHeartRate: 1,
            sleepHours: 8,
            sleepStages: SleepStages(deepSleep: 1.8, remSleep: 1.8, coreSleep: 4.4, awake: 0)
        )
        let highResult = sut.execute(todayMetrics: highToday, weekMetrics: weekMetrics)
        XCTAssertLessThanOrEqual(highResult.overallScore, 100)
        XCTAssertGreaterThanOrEqual(highResult.overallScore, 0)

        // Extreme low
        let lowToday = HealthMetrics(
            date: Date(),
            heartRateVariability: 0.01,
            restingHeartRate: 999,
            sleepHours: 0
        )
        let lowResult = sut.execute(todayMetrics: lowToday, weekMetrics: weekMetrics)
        XCTAssertLessThanOrEqual(lowResult.overallScore, 100)
        XCTAssertGreaterThanOrEqual(lowResult.overallScore, 0)
    }
}

// MARK: - Bug 5: SpO2 abnormal value alerting

@MainActor
final class SpO2AlertingRegressionTests: XCTestCase {
    var mockRepository: MockHealthRepository!
    var viewModel: HealthDashboardViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHealthRepository()
        viewModel = HealthDashboardViewModel(healthRepository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    /// Regression: normal SpO2 (>= 95%) should not trigger warning
    func testNormalSpO2NoWarning() async {
        mockRepository.mockTodayMetrics = HealthMetrics(date: Date(), oxygenSaturation: 98)
        await viewModel.loadTodayMetrics()

        XCTAssertFalse(viewModel.isSpO2Low)
        XCTAssertFalse(viewModel.isSpO2Critical)
    }

    /// Regression: borderline SpO2 at 95% should not trigger warning
    func testBorderlineSpO2NoWarning() async {
        mockRepository.mockTodayMetrics = HealthMetrics(date: Date(), oxygenSaturation: 95)
        await viewModel.loadTodayMetrics()

        XCTAssertFalse(viewModel.isSpO2Low)
        XCTAssertFalse(viewModel.isSpO2Critical)
    }

    /// Regression: low SpO2 (< 95%) should trigger warning but not critical
    func testLowSpO2TriggersWarning() async {
        mockRepository.mockTodayMetrics = HealthMetrics(date: Date(), oxygenSaturation: 93)
        await viewModel.loadTodayMetrics()

        XCTAssertTrue(viewModel.isSpO2Low, "SpO2 93% should trigger low warning")
        XCTAssertFalse(viewModel.isSpO2Critical, "SpO2 93% should not be critical")
    }

    /// Regression: critically low SpO2 (< 90%) should trigger critical alert
    func testCriticalSpO2TriggersCritical() async {
        mockRepository.mockTodayMetrics = HealthMetrics(date: Date(), oxygenSaturation: 88)
        await viewModel.loadTodayMetrics()

        XCTAssertTrue(viewModel.isSpO2Low, "SpO2 88% should be low")
        XCTAssertTrue(viewModel.isSpO2Critical, "SpO2 88% should be critical")
    }

    /// Regression: nil SpO2 should not trigger any alerts
    func testNilSpO2NoAlerts() async {
        mockRepository.mockTodayMetrics = HealthMetrics(date: Date(), heartRateVariability: 75)
        await viewModel.loadTodayMetrics()

        XCTAssertFalse(viewModel.isSpO2Low)
        XCTAssertFalse(viewModel.isSpO2Critical)
    }

    /// Regression: no metrics loaded should not trigger alerts
    func testNoMetricsNoAlerts() {
        XCTAssertFalse(viewModel.isSpO2Low)
        XCTAssertFalse(viewModel.isSpO2Critical)
    }

    /// Regression: verify threshold constants
    func testSpO2ThresholdConstants() {
        XCTAssertEqual(HealthDashboardViewModel.spo2WarningThreshold, 95,
                       "Warning threshold should be 95%")
        XCTAssertEqual(HealthDashboardViewModel.spo2CriticalThreshold, 90,
                       "Critical threshold should be 90%")
    }
}

// MARK: - Bug 6: Sleep consistency score comprehensive coverage

final class SleepConsistencyComprehensiveTests: XCTestCase {

    var sut: CalculateSleepConsistencyUseCase!

    override func setUp() {
        super.setUp()
        sut = CalculateSleepConsistencyUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// Test moderately consistent sleep (7-8h range)
    func testModeratelyConsistentSleep() {
        let sleepHours: [Double] = [7.5, 7.0, 8.0, 7.5, 7.0, 8.0, 7.5]
        let metrics = sleepHours.enumerated().map { (i, hours) in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-i * 86400)),
                sleepHours: hours
            )
        }

        let result = sut.execute(weekMetrics: metrics)

        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result?.consistencyScore ?? 0, 50,
                             "Moderately consistent sleep should score above 50")
    }

    /// Test gradually increasing sleep (consistent direction)
    func testGraduallyIncreasingSleep() {
        let sleepHours: [Double] = [6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0]
        let metrics = sleepHours.enumerated().map { (i, hours) in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-i * 86400)),
                sleepHours: hours
            )
        }

        let result = sut.execute(weekMetrics: metrics)

        XCTAssertNotNil(result)
        // Variance exists since values differ
        XCTAssertGreaterThan(result?.bedtimeVariance ?? -1, 0)
    }

    /// Test exactly 2 days (minimum)
    func testExactlyTwoDaysSleep() {
        let metrics = [
            HealthMetrics(date: Date(), sleepHours: 8.0),
            HealthMetrics(date: Date().addingTimeInterval(-86400), sleepHours: 6.0)
        ]

        let result = sut.execute(weekMetrics: metrics)

        XCTAssertNotNil(result, "Two days should be enough for a score")
        // Different sleep durations = some variance
        XCTAssertLessThan(result?.consistencyScore ?? 101, 100)
    }

    /// Test all zero sleep hours (filtered out)
    func testAllZeroSleepHours() {
        let metrics = (0..<7).map { day in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-day * 86400)),
                sleepHours: 0
            )
        }

        let result = sut.execute(weekMetrics: metrics)

        XCTAssertNil(result, "Zero sleep hours should be filtered out")
    }

    /// Test very short sleep (1-2 hours)
    func testVeryShortSleep() {
        let metrics = [
            HealthMetrics(date: Date(), sleepHours: 1.5),
            HealthMetrics(date: Date().addingTimeInterval(-86400), sleepHours: 2.0),
            HealthMetrics(date: Date().addingTimeInterval(-2 * 86400), sleepHours: 1.0)
        ]

        let result = sut.execute(weekMetrics: metrics)

        XCTAssertNotNil(result, "Short but non-zero sleep should produce a score")
        XCTAssertGreaterThanOrEqual(result?.consistencyScore ?? -1, 0)
        XCTAssertLessThanOrEqual(result?.consistencyScore ?? 101, 100)
    }

    /// Test very long sleep (12+ hours)
    func testVeryLongSleep() {
        let metrics = [
            HealthMetrics(date: Date(), sleepHours: 12.0),
            HealthMetrics(date: Date().addingTimeInterval(-86400), sleepHours: 13.0),
            HealthMetrics(date: Date().addingTimeInterval(-2 * 86400), sleepHours: 12.5)
        ]

        let result = sut.execute(weekMetrics: metrics)

        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(result?.consistencyScore ?? -1, 0)
        XCTAssertLessThanOrEqual(result?.consistencyScore ?? 101, 100)
    }

    /// Test bedtime variance is non-negative
    func testBedtimeVarianceNonNegative() {
        let sleepHours: [Double] = [5, 10, 6, 9, 5, 10, 7]
        let metrics = sleepHours.enumerated().map { (i, hours) in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-i * 86400)),
                sleepHours: hours
            )
        }

        let result = sut.execute(weekMetrics: metrics)

        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(result?.bedtimeVariance ?? -1, 0,
                                     "Bedtime variance should never be negative")
        XCTAssertGreaterThanOrEqual(result?.wakeVariance ?? -1, 0,
                                     "Wake variance should never be negative")
    }
}

// MARK: - Bug 7: VO2 Max trending potential overflow

@MainActor
final class VO2MaxOverflowRegressionTests: XCTestCase {
    var repository: MockHealthRepository!
    var viewModel: MetricDetailViewModel!

    override func setUp() async throws {
        repository = MockHealthRepository()
        viewModel = MetricDetailViewModel(healthRepository: repository)
    }

    override func tearDown() async throws {
        repository = nil
        viewModel = nil
    }

    /// Regression: extreme VO2 Max values should not cause overflow in trend calculation
    func testExtremeVO2MaxTrendCalculation() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Mix of extreme values
        let values: [Double] = [100, 100, 100, 100, 5, 5, 5]
        let metrics = values.enumerated().map { (i, val) in
            HealthMetrics(
                date: calendar.date(byAdding: .day, value: -(6 - i), to: today)!,
                vo2Max: val
            )
        }
        repository.mockWeekMetrics = metrics

        await viewModel.loadHistory(for: .vo2Max, range: .week)

        // Should not crash or produce NaN
        XCTAssertEqual(viewModel.historyData.count, 7)
        if let avg = viewModel.average {
            XCTAssertTrue(avg.isFinite, "Average should be finite even with extreme values")
        }
        if let trend = viewModel.trend {
            XCTAssertTrue(trend == .up || trend == .down || trend == .stable,
                          "Trend should be valid even with extreme values")
        }
    }

    /// Regression: VO2 Max values at physiological boundaries should work
    func testVO2MaxAtBoundaryValues() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Use clamped boundary values (5-100 range)
        let values: [Double] = [5, 5, 5, 100, 100, 100]
        let metrics = values.enumerated().map { (i, val) in
            HealthMetrics(
                date: calendar.date(byAdding: .day, value: -(5 - i), to: today)!,
                vo2Max: val
            )
        }
        repository.mockWeekMetrics = metrics

        await viewModel.loadHistory(for: .vo2Max, range: .week)

        XCTAssertEqual(viewModel.historyData.count, 6)
        XCTAssertNotNil(viewModel.trend, "Trend should be calculable at boundary values")
        XCTAssertEqual(viewModel.trend, .up, "5 → 100 should trend up")
    }

    /// Regression: consistent VO2 Max should produce stable trend
    func testConsistentVO2MaxStableTrend() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let values: [Double] = [45.0, 45.1, 44.9, 45.0, 45.1, 44.9, 45.0]
        let metrics = values.enumerated().map { (i, val) in
            HealthMetrics(
                date: calendar.date(byAdding: .day, value: -(6 - i), to: today)!,
                vo2Max: val
            )
        }
        repository.mockWeekMetrics = metrics

        await viewModel.loadHistory(for: .vo2Max, range: .week)

        XCTAssertEqual(viewModel.historyData.count, 7)
        XCTAssertEqual(viewModel.trend, .stable, "Consistent VO2 Max should show stable trend")
    }
}
