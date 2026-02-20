//
//  HRVTrackingTests.swift
//  VitalArcTests
//
//  Tests for HRV baseline calculation, deviation detection,
//  and correlation logic in HealthDashboardViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class HRVTrackingTests: XCTestCase {

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

    // MARK: - Test Helpers

    private func makeMetrics(
        date: Date = Date(),
        hrv: Double? = nil,
        rhr: Double? = nil,
        steps: Int? = nil,
        sleepHours: Double? = nil
    ) -> HealthMetrics {
        HealthMetrics(
            date: date,
            heartRateVariability: hrv,
            restingHeartRate: rhr,
            steps: steps,
            sleepHours: sleepHours
        )
    }

    private func makeWeekMetrics(hrvValues: [Double]) -> [HealthMetrics] {
        hrvValues.enumerated().map { index, hrv in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-6 + index) * 86400),
                hrv: hrv,
                sleepHours: 7.5
            )
        }
    }

    private func makeMonthMetrics(hrvValues: [Double]) -> [HealthMetrics] {
        hrvValues.enumerated().map { index, hrv in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-29 + index) * 86400),
                hrv: hrv,
                sleepHours: 7.5
            )
        }
    }

    // MARK: - HRV Baseline Tests

    func testHRVBaselineCalculatedFrom30DayData() async {
        // Given: 30 days of data with known HRV values
        let hrvValues = (0..<30).map { _ in 60.0 + Double.random(in: -5...5) }
        let expectedAverage = hrvValues.reduce(0, +) / Double(hrvValues.count)

        mockRepository.mockTodayMetrics = makeMetrics(hrv: 65)
        mockRepository.mockWeekMetrics = makeWeekMetrics(hrvValues: [60, 62, 58, 65, 63, 61, 64])

        // Mock month metrics through the range query
        // The ViewModel calls getHealthMetrics(from:to:) for month data
        // Since the mock returns the same data for all range queries, we set it up
        let monthData = hrvValues.enumerated().map { index, hrv in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-29 + index) * 86400),
                hrv: hrv,
                sleepHours: 7.5
            )
        }
        mockRepository.mockWeekMetrics = monthData

        await viewModel.loadAllMetrics()

        XCTAssertNotNil(viewModel.hrvBaseline)
        if let baseline = viewModel.hrvBaseline {
            XCTAssertEqual(baseline, expectedAverage, accuracy: 1.0,
                           "Baseline should be the average of 30-day HRV values")
        }
    }

    func testHRVBaselineNilWithNoData() async {
        mockRepository.mockTodayMetrics = makeMetrics()
        mockRepository.mockWeekMetrics = []

        await viewModel.loadAllMetrics()

        XCTAssertNil(viewModel.hrvBaseline, "Baseline should be nil when no HRV data")
    }

    func testHRVBaselineWithPartialData() async {
        // Only some days have HRV data
        let metricsWithHRV = (0..<5).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60 + Double(i),
                sleepHours: 7
            )
        }
        let metricsWithoutHRV = (5..<10).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                sleepHours: 7
            )
        }

        mockRepository.mockTodayMetrics = makeMetrics(hrv: 62)
        mockRepository.mockWeekMetrics = metricsWithHRV + metricsWithoutHRV

        await viewModel.loadAllMetrics()

        XCTAssertNotNil(viewModel.hrvBaseline, "Baseline should still be computed from available data")
        if let baseline = viewModel.hrvBaseline {
            let expected = (60.0 + 61.0 + 62.0 + 63.0 + 64.0) / 5.0
            XCTAssertEqual(baseline, expected, accuracy: 0.1)
        }
    }

    // MARK: - HRV Deviation Detection Tests

    func testDeviationSignificantWhenAbove15Percent() async {
        // Baseline of 60ms, today 72ms = 20% above
        let monthData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60,
                sleepHours: 7
            )
        }
        mockRepository.mockTodayMetrics = makeMetrics(hrv: 72)
        mockRepository.mockWeekMetrics = monthData

        await viewModel.loadAllMetrics()

        XCTAssertTrue(viewModel.hrvDeviationSignificant,
                      "20% above baseline should be flagged as significant")
    }

    func testDeviationSignificantWhenBelow15Percent() async {
        // Baseline of 60ms, today 48ms = 20% below
        let monthData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60,
                sleepHours: 7
            )
        }
        mockRepository.mockTodayMetrics = makeMetrics(hrv: 48)
        mockRepository.mockWeekMetrics = monthData

        await viewModel.loadAllMetrics()

        XCTAssertTrue(viewModel.hrvDeviationSignificant,
                      "20% below baseline should be flagged as significant")
    }

    func testDeviationNotSignificantWhenWithinThreshold() async {
        // Baseline of 60ms, today 63ms = 5% above (within 15% threshold)
        let monthData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60,
                sleepHours: 7
            )
        }
        mockRepository.mockTodayMetrics = makeMetrics(hrv: 63)
        mockRepository.mockWeekMetrics = monthData

        await viewModel.loadAllMetrics()

        XCTAssertFalse(viewModel.hrvDeviationSignificant,
                       "5% deviation should not be significant")
    }

    func testDeviationFalseWithNoBaseline() async {
        mockRepository.mockTodayMetrics = makeMetrics(hrv: 65)
        mockRepository.mockWeekMetrics = []

        await viewModel.loadAllMetrics()

        XCTAssertFalse(viewModel.hrvDeviationSignificant,
                       "No baseline means no deviation detection")
    }

    func testDeviationFalseWithNoTodayHRV() async {
        let monthData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60,
                sleepHours: 7
            )
        }
        mockRepository.mockTodayMetrics = makeMetrics() // no HRV
        mockRepository.mockWeekMetrics = monthData

        await viewModel.loadAllMetrics()

        XCTAssertFalse(viewModel.hrvDeviationSignificant,
                       "No today HRV means no deviation detection")
    }

    // MARK: - HRV Status Text Tests

    func testHRVStatusTextAboveBaseline() async {
        let monthData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60,
                sleepHours: 7
            )
        }
        mockRepository.mockTodayMetrics = makeMetrics(hrv: 72)
        mockRepository.mockWeekMetrics = monthData

        await viewModel.loadAllMetrics()

        XCTAssertTrue(viewModel.hrvStatusText.contains("above baseline"),
                      "Status should mention 'above baseline' when HRV is higher")
    }

    func testHRVStatusTextBelowBaseline() async {
        let monthData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60,
                sleepHours: 7
            )
        }
        mockRepository.mockTodayMetrics = makeMetrics(hrv: 48)
        mockRepository.mockWeekMetrics = monthData

        await viewModel.loadAllMetrics()

        XCTAssertTrue(viewModel.hrvStatusText.contains("below baseline"),
                      "Status should mention 'below baseline' when HRV is lower")
    }

    func testHRVStatusTextAtBaseline() async {
        let monthData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60,
                sleepHours: 7
            )
        }
        mockRepository.mockTodayMetrics = makeMetrics(hrv: 61) // ~1.7% above (within 5% threshold)
        mockRepository.mockWeekMetrics = monthData

        await viewModel.loadAllMetrics()

        XCTAssertTrue(viewModel.hrvStatusText.contains("At baseline"),
                      "Status should say 'At baseline' when difference is < 5%")
    }

    func testHRVStatusTextNoData() {
        XCTAssertEqual(viewModel.hrvStatusText, "No data")
    }

    // MARK: - HRV Above Baseline Tests

    func testIsHRVAboveBaseline() async {
        let monthData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60,
                sleepHours: 7
            )
        }
        mockRepository.mockTodayMetrics = makeMetrics(hrv: 70)
        mockRepository.mockWeekMetrics = monthData

        await viewModel.loadAllMetrics()

        XCTAssertTrue(viewModel.isHRVAboveBaseline)
    }

    func testIsHRVBelowBaseline() async {
        let monthData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60,
                sleepHours: 7
            )
        }
        mockRepository.mockTodayMetrics = makeMetrics(hrv: 50)
        mockRepository.mockWeekMetrics = monthData

        await viewModel.loadAllMetrics()

        XCTAssertFalse(viewModel.isHRVAboveBaseline)
    }

    // MARK: - HRV Trend Data Tests

    func testHRVTrendData7DaySorted() async {
        let weekData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-6 + i) * 86400),
                hrv: 55 + Double(i) * 3,
                sleepHours: 7
            )
        }
        mockRepository.mockTodayMetrics = makeMetrics(hrv: 73)
        mockRepository.mockWeekMetrics = weekData

        await viewModel.loadAllMetrics()

        XCTAssertEqual(viewModel.hrvTrendData7Day.count, 7)
        // Verify sorted by date
        for i in 1..<viewModel.hrvTrendData7Day.count {
            XCTAssertGreaterThanOrEqual(
                viewModel.hrvTrendData7Day[i].date,
                viewModel.hrvTrendData7Day[i - 1].date,
                "Trend data should be sorted chronologically"
            )
        }
    }

    func testHRVTrendDataEmptyWhenNoHRV() async {
        let weekData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                sleepHours: 7  // no HRV data
            )
        }
        mockRepository.mockTodayMetrics = makeMetrics(sleepHours: 7)
        mockRepository.mockWeekMetrics = weekData

        await viewModel.loadAllMetrics()

        XCTAssertTrue(viewModel.hrvTrendData7Day.isEmpty,
                      "No HRV data means empty trend chart data")
    }

    // MARK: - Sleep Correlation Tests

    func testSleepCorrelationHintWithSufficientData() async {
        // High sleep nights with high HRV, low sleep with low HRV
        let weekData = [
            makeMetrics(date: Date().addingTimeInterval(-6 * 86400), hrv: 80, sleepHours: 8),
            makeMetrics(date: Date().addingTimeInterval(-5 * 86400), hrv: 75, sleepHours: 7.5),
            makeMetrics(date: Date().addingTimeInterval(-4 * 86400), hrv: 45, sleepHours: 5),
            makeMetrics(date: Date().addingTimeInterval(-3 * 86400), hrv: 82, sleepHours: 8.5),
            makeMetrics(date: Date().addingTimeInterval(-2 * 86400), hrv: 40, sleepHours: 4.5),
            makeMetrics(date: Date().addingTimeInterval(-1 * 86400), hrv: 78, sleepHours: 7),
            makeMetrics(date: Date(), hrv: 42, sleepHours: 5)
        ]
        mockRepository.mockTodayMetrics = weekData.last
        mockRepository.mockWeekMetrics = weekData

        await viewModel.loadAllMetrics()

        XCTAssertNotNil(viewModel.hrvSleepCorrelationHint,
                        "Should detect HRV/sleep correlation when data supports it")
    }

    func testSleepCorrelationHintNilWithInsufficientData() async {
        let weekData = [
            makeMetrics(date: Date(), hrv: 65, sleepHours: 7)
        ]
        mockRepository.mockTodayMetrics = weekData.last
        mockRepository.mockWeekMetrics = weekData

        await viewModel.loadAllMetrics()

        XCTAssertNil(viewModel.hrvSleepCorrelationHint,
                     "Should not generate correlation hint with < 3 data points")
    }

    func testSleepCorrelationHintNilWhenNoSleepVariation() async {
        // All the same sleep and HRV - no variation to detect correlation
        let weekData = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60,
                sleepHours: 7.5  // all 7+ hours, so no "low sleep" group
            )
        }
        mockRepository.mockTodayMetrics = weekData.first
        mockRepository.mockWeekMetrics = weekData

        await viewModel.loadAllMetrics()

        // Can't compute correlation when all sleep is >=7 hours (no low-sleep group)
        XCTAssertNil(viewModel.hrvSleepCorrelationHint)
    }

    // MARK: - Readiness V2 Integration Tests

    func testReadinessResultPopulatedOnLoadAll() async {
        mockRepository.mockTodayMetrics = makeMetrics(hrv: 65, rhr: 58, steps: 10000, sleepHours: 8)
        mockRepository.mockWeekMetrics = (0..<7).map { i in
            makeMetrics(
                date: Date().addingTimeInterval(Double(-i) * 86400),
                hrv: 60,
                rhr: 60,
                steps: 8000,
                sleepHours: 7.5
            )
        }

        await viewModel.loadAllMetrics()

        XCTAssertNotNil(viewModel.readinessResult, "V2 result should be populated on loadAll")
        XCTAssertNotNil(viewModel.readinessScore, "Legacy score should still be populated")
    }

    func testReadinessResultNilWithoutTodayMetrics() async {
        mockRepository.mockTodayMetrics = nil
        mockRepository.mockWeekMetrics = []

        await viewModel.loadAllMetrics()

        XCTAssertNil(viewModel.readinessResult)
        XCTAssertNil(viewModel.readinessScore)
    }
}
