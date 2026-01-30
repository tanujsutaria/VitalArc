//
//  HealthDashboardViewModelTests.swift
//  VitalArcTests
//
//  Unit tests for HealthDashboardViewModel
//  Note: Some basic tests exist in HealthKitTests.swift; this file provides comprehensive coverage
//

import XCTest
@testable import VitalArc

@MainActor
final class HealthDashboardViewModelTests: XCTestCase {

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

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertNil(viewModel.todayMetrics)
        XCTAssertTrue(viewModel.weekMetrics.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.showingPermissionAlert)
    }

    // MARK: - Load Today Metrics Tests

    func testLoadTodayMetricsSuccess() async {
        // Setup
        let metrics = createHealthMetrics(hrv: 75, heartRate: 65, steps: 10000)
        mockRepository.mockTodayMetrics = metrics

        // Execute
        await viewModel.loadTodayMetrics()

        // Verify
        XCTAssertNotNil(viewModel.todayMetrics)
        XCTAssertEqual(viewModel.todayMetrics?.heartRateVariability ?? 0, 75, accuracy: 0.1)
        XCTAssertEqual(viewModel.todayMetrics?.steps, 10000)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testLoadTodayMetricsError() async {
        // Setup
        mockRepository.shouldThrowOnGetMetrics = true

        // Execute
        await viewModel.loadTodayMetrics()

        // Verify
        XCTAssertNil(viewModel.todayMetrics)
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadTodayMetricsSetsLoading() async {
        // Verify initial state
        XCTAssertFalse(viewModel.isLoading)

        // Execute
        await viewModel.loadTodayMetrics()

        // After completion, loading should be false
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Load Week Metrics Tests

    func testLoadWeekMetricsSuccess() async {
        // Setup
        mockRepository.mockWeekMetrics = createWeekMetrics()

        // Execute
        await viewModel.loadWeekMetrics()

        // Verify
        XCTAssertEqual(viewModel.weekMetrics.count, 7)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testLoadWeekMetricsError() async {
        // Setup
        mockRepository.shouldThrowOnGetRange = true

        // Execute
        await viewModel.loadWeekMetrics()

        // Verify
        XCTAssertTrue(viewModel.weekMetrics.isEmpty)
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Load All Metrics Tests

    func testLoadAllMetricsCallsBoth() async {
        // Setup
        mockRepository.mockTodayMetrics = createHealthMetrics()
        mockRepository.mockWeekMetrics = createWeekMetrics()

        // Execute
        await viewModel.loadAllMetrics()

        // Verify - both should be populated
        XCTAssertNotNil(viewModel.todayMetrics)
        XCTAssertFalse(viewModel.weekMetrics.isEmpty)
    }

    // MARK: - Refresh Tests

    func testRefreshSyncsAndReloads() async {
        // Setup
        mockRepository.mockTodayMetrics = createHealthMetrics()
        mockRepository.mockWeekMetrics = createWeekMetrics()

        // Execute
        await viewModel.refresh()

        // Verify
        XCTAssertTrue(mockRepository.syncRequested)
        XCTAssertNotNil(viewModel.todayMetrics)
        XCTAssertFalse(viewModel.weekMetrics.isEmpty)
    }

    // MARK: - HealthKit Permission Tests

    func testRequestPermissionsSuccess() async {
        // Setup
        mockRepository.mockAuthorizationSuccess = true
        mockRepository.mockTodayMetrics = createHealthMetrics()
        mockRepository.mockWeekMetrics = createWeekMetrics()

        // Execute
        await viewModel.requestHealthKitPermissions()

        // Verify
        XCTAssertTrue(mockRepository.authorizationRequested)
        XCTAssertNotNil(viewModel.todayMetrics) // Data loaded after authorization
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.showingPermissionAlert)
    }

    func testRequestPermissionsDenied() async {
        // Setup
        mockRepository.mockAuthorizationSuccess = false

        // Execute
        await viewModel.requestHealthKitPermissions()

        // Verify - no sync or load should happen
        XCTAssertTrue(mockRepository.authorizationRequested)
        XCTAssertFalse(mockRepository.syncRequested)
        XCTAssertNil(viewModel.todayMetrics)
    }

    func testRequestPermissionsError() async {
        // Setup
        mockRepository.shouldThrowOnAuthorization = true

        // Execute
        await viewModel.requestHealthKitPermissions()

        // Verify
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.showingPermissionAlert)
    }

    // MARK: - Sync Tests

    func testSyncFromHealthKitSuccess() async {
        // Execute
        await viewModel.syncFromHealthKit()

        // Verify
        XCTAssertTrue(mockRepository.syncRequested)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testSyncFromHealthKitError() async {
        // Setup
        mockRepository.shouldThrowOnSync = true

        // Execute
        await viewModel.syncFromHealthKit()

        // Verify
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Computed Properties Tests

    func testAverageHRVComputed() async {
        // Setup
        mockRepository.mockWeekMetrics = [
            createHealthMetrics(hrv: 70),
            createHealthMetrics(hrv: 80),
            createHealthMetrics(hrv: 75)
        ]
        await viewModel.loadWeekMetrics()

        // Verify - average of 70, 80, 75 = 75
        XCTAssertEqual(viewModel.averageHRV ?? 0, 75, accuracy: 0.1)
    }

    func testAverageHRVWithEmptyData() {
        // No metrics loaded
        XCTAssertNil(viewModel.averageHRV)
    }

    func testAverageHRVWithNilValues() async {
        // Setup - some metrics without HRV
        mockRepository.mockWeekMetrics = [
            createHealthMetrics(hrv: 70),
            createHealthMetrics(hrv: nil),
            createHealthMetrics(hrv: 80)
        ]
        await viewModel.loadWeekMetrics()

        // Verify - average of 70, 80 = 75 (nil excluded)
        XCTAssertEqual(viewModel.averageHRV ?? 0, 75, accuracy: 0.1)
    }

    func testAverageHeartRateComputed() async {
        // Setup
        mockRepository.mockWeekMetrics = [
            createHealthMetrics(heartRate: 60),
            createHealthMetrics(heartRate: 70),
            createHealthMetrics(heartRate: 65)
        ]
        await viewModel.loadWeekMetrics()

        // Verify - average of 60, 70, 65 = 65
        XCTAssertEqual(viewModel.averageHeartRate ?? 0, 65, accuracy: 0.1)
    }

    func testTotalStepsComputed() async {
        // Setup
        mockRepository.mockWeekMetrics = [
            createHealthMetrics(steps: 10000),
            createHealthMetrics(steps: 8000),
            createHealthMetrics(steps: 12000)
        ]
        await viewModel.loadWeekMetrics()

        // Verify - 10000 + 8000 + 12000 = 30000
        XCTAssertEqual(viewModel.totalSteps, 30000)
    }

    func testAverageStepsComputed() async {
        // Setup
        mockRepository.mockWeekMetrics = [
            createHealthMetrics(steps: 10000),
            createHealthMetrics(steps: 8000),
            createHealthMetrics(steps: 12000)
        ]
        await viewModel.loadWeekMetrics()

        // Verify - average of 10000, 8000, 12000 = 10000
        XCTAssertEqual(viewModel.averageSteps, 10000)
    }

    func testTotalActiveEnergyComputed() async {
        // Setup
        mockRepository.mockWeekMetrics = [
            createHealthMetrics(activeEnergy: 400),
            createHealthMetrics(activeEnergy: 500),
            createHealthMetrics(activeEnergy: 450)
        ]
        await viewModel.loadWeekMetrics()

        // Verify - 400 + 500 + 450 = 1350
        XCTAssertEqual(viewModel.totalActiveEnergy, 1350, accuracy: 0.1)
    }

    func testAverageSleepHoursComputed() async {
        // Setup
        mockRepository.mockWeekMetrics = [
            createHealthMetrics(sleepHours: 7),
            createHealthMetrics(sleepHours: 8),
            createHealthMetrics(sleepHours: 6)
        ]
        await viewModel.loadWeekMetrics()

        // Verify - average of 7, 8, 6 = 7
        XCTAssertEqual(viewModel.averageSleepHours ?? 0, 7, accuracy: 0.1)
    }

    func testAverageSleepHoursWithEmptyData() {
        XCTAssertNil(viewModel.averageSleepHours)
    }

    // MARK: - Helper Methods

    private func createHealthMetrics(
        hrv: Double? = 75,
        heartRate: Double? = 65,
        steps: Int? = 10000,
        activeEnergy: Double? = 450,
        sleepHours: Double? = 7.5
    ) -> HealthMetrics {
        HealthMetrics(
            date: Date(),
            heartRateVariability: hrv,
            restingHeartRate: heartRate,
            activeEnergy: activeEnergy,
            steps: steps,
            sleepHours: sleepHours,
            weight: nil
        )
    }

    private func createWeekMetrics() -> [HealthMetrics] {
        (0..<7).map { day in
            HealthMetrics(
                date: Date().addingTimeInterval(Double(-day * 86400)),
                heartRateVariability: Double(70 + day),
                restingHeartRate: Double(60 + day),
                activeEnergy: Double(400 + day * 50),
                steps: 10000 + day * 1000,
                sleepHours: 7.0 + Double(day) * 0.2,
                weight: nil
            )
        }
    }
}
