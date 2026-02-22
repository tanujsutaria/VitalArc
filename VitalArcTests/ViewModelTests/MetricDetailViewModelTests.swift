//
//  MetricDetailViewModelTests.swift
//  VitalArcTests
//
//  Tests for MetricDetailViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class MetricDetailViewModelTests: XCTestCase {
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

    // MARK: - Test Helpers

    private func makeTestMetrics(
        date: Date,
        hrv: Double? = nil,
        restingHR: Double? = nil,
        steps: Int? = nil,
        activeEnergy: Double? = nil,
        sleepHours: Double? = nil,
        weight: Double? = nil
    ) -> HealthMetrics {
        HealthMetrics(
            date: date,
            heartRateVariability: hrv,
            restingHeartRate: restingHR,
            activeEnergy: activeEnergy,
            steps: steps,
            sleepHours: sleepHours,
            weight: weight
        )
    }

    private func generateMetricsForDays(
        days: Int,
        values: [Double],
        metricType: HealthMetricType
    ) -> [HealthMetrics] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return values.enumerated().map { index, value in
            let date = calendar.date(byAdding: .day, value: -(days - 1 - index), to: today)!

            switch metricType {
            case .hrv:
                return makeTestMetrics(date: date, hrv: value)
            case .restingHR:
                return makeTestMetrics(date: date, restingHR: value)
            case .steps:
                return makeTestMetrics(date: date, steps: Int(value))
            case .activeEnergy:
                return makeTestMetrics(date: date, activeEnergy: value)
            case .sleep:
                return makeTestMetrics(date: date, sleepHours: value)
            case .weight:
                return makeTestMetrics(date: date, weight: value)
            case .bodyFat, .leanBodyMass, .respiratoryRate, .spo2, .vo2Max, .hydration:
                return makeTestMetrics(date: date)
            }
        }
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertTrue(viewModel.historyData.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertNil(viewModel.average)
        XCTAssertNil(viewModel.minimum)
        XCTAssertNil(viewModel.maximum)
        XCTAssertNil(viewModel.trend)
    }

    // MARK: - Load History Tests

    func testLoadHistoryForHRV() async {
        // Given
        let values: [Double] = [50, 55, 52, 48, 60, 58, 55]
        repository.mockWeekMetrics = generateMetricsForDays(days: 7, values: values, metricType: .hrv)

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then
        XCTAssertEqual(viewModel.historyData.count, 7)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testLoadHistoryForRestingHR() async {
        // Given
        let values: [Double] = [60, 58, 62, 59, 61, 57, 58]
        repository.mockWeekMetrics = generateMetricsForDays(days: 7, values: values, metricType: .restingHR)

        // When
        await viewModel.loadHistory(for: .restingHR, range: .week)

        // Then
        XCTAssertEqual(viewModel.historyData.count, 7)
    }

    func testLoadHistoryForSteps() async {
        // Given
        let values: [Double] = [8000, 10000, 7500, 12000, 9000, 11000, 8500]
        repository.mockWeekMetrics = generateMetricsForDays(days: 7, values: values, metricType: .steps)

        // When
        await viewModel.loadHistory(for: .steps, range: .week)

        // Then
        XCTAssertEqual(viewModel.historyData.count, 7)
    }

    func testLoadHistoryForActiveEnergy() async {
        // Given
        let values: [Double] = [400, 500, 350, 600, 450, 550, 480]
        repository.mockWeekMetrics = generateMetricsForDays(days: 7, values: values, metricType: .activeEnergy)

        // When
        await viewModel.loadHistory(for: .activeEnergy, range: .week)

        // Then
        XCTAssertEqual(viewModel.historyData.count, 7)
    }

    func testLoadHistoryForSleep() async {
        // Given
        let values: [Double] = [7.5, 8.0, 6.5, 7.0, 8.5, 7.0, 7.5]
        repository.mockWeekMetrics = generateMetricsForDays(days: 7, values: values, metricType: .sleep)

        // When
        await viewModel.loadHistory(for: .sleep, range: .week)

        // Then
        XCTAssertEqual(viewModel.historyData.count, 7)
    }

    func testLoadHistoryForWeight() async {
        // Given - Weight in kg (will be converted to lbs for display)
        let values: [Double] = [75, 74.8, 75.2, 74.5, 75.0, 74.7, 74.9]
        repository.mockWeekMetrics = generateMetricsForDays(days: 7, values: values, metricType: .weight)

        // When
        await viewModel.loadHistory(for: .weight, range: .week)

        // Then - Values should be converted to lbs
        XCTAssertEqual(viewModel.historyData.count, 7)
        // Check that first value is converted (75kg ≈ 165 lbs)
        XCTAssertEqual(viewModel.historyData.first?.value ?? 0, 75 * 2.20462, accuracy: 0.5)
    }

    // MARK: - Date Range Tests

    func testLoadHistoryForWeek() async {
        // Given
        let values: [Double] = [50, 55, 52, 48, 60, 58, 55]
        repository.mockWeekMetrics = generateMetricsForDays(days: 7, values: values, metricType: .hrv)

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then
        XCTAssertEqual(viewModel.historyData.count, 7)
    }

    func testLoadHistoryForMonth() async {
        // Given
        let values = (0..<30).map { Double(50 + ($0 % 10)) }
        repository.mockWeekMetrics = generateMetricsForDays(days: 30, values: values, metricType: .hrv)

        // When
        await viewModel.loadHistory(for: .hrv, range: .month)

        // Then
        XCTAssertEqual(viewModel.historyData.count, 30)
    }

    func testLoadHistoryForThreeMonths() async {
        // Given
        let values = (0..<90).map { Double(50 + ($0 % 15)) }
        repository.mockWeekMetrics = generateMetricsForDays(days: 90, values: values, metricType: .hrv)

        // When
        await viewModel.loadHistory(for: .hrv, range: .threeMonths)

        // Then
        XCTAssertEqual(viewModel.historyData.count, 90)
    }

    // MARK: - Statistics Tests

    func testAverageCalculation() async {
        // Given
        let values: [Double] = [50, 60, 70, 80, 90, 100, 110]
        repository.mockWeekMetrics = generateMetricsForDays(days: 7, values: values, metricType: .hrv)

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then
        XCTAssertEqual(viewModel.average ?? 0, 80, accuracy: 0.1) // (50+60+70+80+90+100+110)/7
    }

    func testMinimumCalculation() async {
        // Given
        let values: [Double] = [50, 60, 30, 80, 90, 100, 110]
        repository.mockWeekMetrics = generateMetricsForDays(days: 7, values: values, metricType: .hrv)

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then
        XCTAssertEqual(viewModel.minimum, 30)
    }

    func testMaximumCalculation() async {
        // Given
        let values: [Double] = [50, 60, 30, 80, 150, 100, 110]
        repository.mockWeekMetrics = generateMetricsForDays(days: 7, values: values, metricType: .hrv)

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then
        XCTAssertEqual(viewModel.maximum, 150)
    }

    // MARK: - Trend Calculation Tests

    func testTrendCalculationUpward() async {
        // Given - Increasing values (first half avg 40, second half avg 60 = 50% increase)
        let values: [Double] = [30, 35, 40, 45, 55, 60, 65, 70]
        repository.mockWeekMetrics = generateMetricsForDays(days: 8, values: values, metricType: .hrv)

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then
        XCTAssertEqual(viewModel.trend, .up)
    }

    func testTrendCalculationDownward() async {
        // Given - Decreasing values
        let values: [Double] = [100, 95, 90, 85, 70, 65, 60, 55]
        repository.mockWeekMetrics = generateMetricsForDays(days: 8, values: values, metricType: .hrv)

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then
        XCTAssertEqual(viewModel.trend, .down)
    }

    func testTrendCalculationStable() async {
        // Given - Stable values (less than 5% change)
        let values: [Double] = [50, 51, 49, 50, 50, 51, 49, 50]
        repository.mockWeekMetrics = generateMetricsForDays(days: 8, values: values, metricType: .hrv)

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then
        XCTAssertEqual(viewModel.trend, .stable)
    }

    func testTrendWithSingleValue() async {
        // Given - Only one data point
        let values: [Double] = [50]
        repository.mockWeekMetrics = generateMetricsForDays(days: 1, values: values, metricType: .hrv)

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then
        XCTAssertNil(viewModel.trend)
    }

    // MARK: - Empty Data Tests

    func testLoadHistoryWithNoData() async {
        // Given
        repository.mockWeekMetrics = []

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then
        XCTAssertTrue(viewModel.historyData.isEmpty)
        XCTAssertNil(viewModel.average)
        XCTAssertNil(viewModel.minimum)
        XCTAssertNil(viewModel.maximum)
        XCTAssertNil(viewModel.trend)
    }

    func testLoadHistoryWithMissingValues() async {
        // Given - Metrics with nil values for requested type
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let metrics = (0..<7).map { index -> HealthMetrics in
            let date = calendar.date(byAdding: .day, value: -index, to: today)!
            return makeTestMetrics(date: date) // No HRV data
        }
        repository.mockWeekMetrics = metrics

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then - Should filter out metrics with nil values
        XCTAssertTrue(viewModel.historyData.isEmpty)
    }

    // MARK: - Loading State Tests

    func testLoadingStateTransitions() async {
        // Given
        let values: [Double] = [50, 55, 52]
        repository.mockWeekMetrics = generateMetricsForDays(days: 3, values: values, metricType: .hrv)

        // Initial state
        XCTAssertFalse(viewModel.isLoading)

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then - Loading should be false after completion
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Data Sorting Tests

    func testHistoryDataIsSortedChronologically() async {
        // Given - Data might come back in any order
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let metrics = [
            makeTestMetrics(date: calendar.date(byAdding: .day, value: -2, to: today)!, hrv: 50),
            makeTestMetrics(date: calendar.date(byAdding: .day, value: -4, to: today)!, hrv: 55),
            makeTestMetrics(date: calendar.date(byAdding: .day, value: -1, to: today)!, hrv: 60),
            makeTestMetrics(date: calendar.date(byAdding: .day, value: -3, to: today)!, hrv: 45)
        ]
        repository.mockWeekMetrics = metrics

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then - Data should be sorted oldest to newest
        for i in 1..<viewModel.historyData.count {
            XCTAssertTrue(viewModel.historyData[i-1].date < viewModel.historyData[i].date)
        }
    }

    // MARK: - Date Range Days Tests

    func testDateRangeDays() {
        XCTAssertEqual(MetricDetailViewModel.DateRange.week.days, 7)
        XCTAssertEqual(MetricDetailViewModel.DateRange.month.days, 30)
        XCTAssertEqual(MetricDetailViewModel.DateRange.threeMonths.days, 90)
    }

    // MARK: - Metric Type Extraction Tests

    func testExtractHRVValue() async {
        // Given
        let metrics = [makeTestMetrics(date: Date(), hrv: 55)]
        repository.mockWeekMetrics = metrics

        // When
        await viewModel.loadHistory(for: .hrv, range: .week)

        // Then
        XCTAssertEqual(viewModel.historyData.first?.value, 55)
    }

    func testExtractRestingHRValue() async {
        // Given
        let metrics = [makeTestMetrics(date: Date(), restingHR: 60)]
        repository.mockWeekMetrics = metrics

        // When
        await viewModel.loadHistory(for: .restingHR, range: .week)

        // Then
        XCTAssertEqual(viewModel.historyData.first?.value, 60)
    }

    func testExtractStepsValue() async {
        // Given
        let metrics = [makeTestMetrics(date: Date(), steps: 10000)]
        repository.mockWeekMetrics = metrics

        // When
        await viewModel.loadHistory(for: .steps, range: .week)

        // Then
        XCTAssertEqual(viewModel.historyData.first?.value, 10000)
    }

    func testExtractActiveEnergyValue() async {
        // Given
        let metrics = [makeTestMetrics(date: Date(), activeEnergy: 500)]
        repository.mockWeekMetrics = metrics

        // When
        await viewModel.loadHistory(for: .activeEnergy, range: .week)

        // Then
        XCTAssertEqual(viewModel.historyData.first?.value, 500)
    }

    func testExtractSleepValue() async {
        // Given
        let metrics = [makeTestMetrics(date: Date(), sleepHours: 7.5)]
        repository.mockWeekMetrics = metrics

        // When
        await viewModel.loadHistory(for: .sleep, range: .week)

        // Then
        XCTAssertEqual(viewModel.historyData.first?.value, 7.5)
    }

    func testExtractWeightValueConvertsToLbs() async {
        // Given - Weight stored in kg
        let weightInKg = 70.0
        let metrics = [makeTestMetrics(date: Date(), weight: weightInKg)]
        repository.mockWeekMetrics = metrics

        // When
        await viewModel.loadHistory(for: .weight, range: .week)

        // Then - Should be converted to lbs
        let expectedLbs = weightInKg * 2.20462
        XCTAssertEqual(viewModel.historyData.first?.value ?? 0, expectedLbs, accuracy: 0.1)
    }

    // MARK: - Edge Cases

    func testLoadHistoryOverwritesPreviousData() async {
        // Given - First load with HRV data
        let hrvValues: [Double] = [50, 55, 52]
        repository.mockWeekMetrics = generateMetricsForDays(days: 3, values: hrvValues, metricType: .hrv)
        await viewModel.loadHistory(for: .hrv, range: .week)
        XCTAssertEqual(viewModel.historyData.count, 3)

        // When - Load different data
        let stepsValues: [Double] = [8000, 10000, 7500, 12000, 9000]
        repository.mockWeekMetrics = generateMetricsForDays(days: 5, values: stepsValues, metricType: .steps)
        await viewModel.loadHistory(for: .steps, range: .week)

        // Then - Previous data should be replaced
        XCTAssertEqual(viewModel.historyData.count, 5)
    }

}
