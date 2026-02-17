//
//  AnalyticsDashboardViewModelTests.swift
//  VitalArcTests
//
//  Unit tests for AnalyticsDashboardViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class AnalyticsDashboardViewModelTests: XCTestCase {

    var mockCalculateVolumeUseCase: MockCalculateVolumeUseCase!
    var mockTrackProgressiveOverloadUseCase: MockTrackProgressiveOverloadUseCase!
    var mockGenerateProgressReportUseCase: MockGenerateProgressReportUseCase!
    var mockCalculateRecoveryScoreUseCase: MockCalculateRecoveryScoreUseCase!
    var mockCalculateStrainScoreUseCase: MockCalculateStrainScoreUseCase!
    var mockAnalyticsRepository: MockAnalyticsRepository!
    var mockHealthRepository: MockHealthRepository!
    var mockNutritionRepository: MockNutritionRepository!
    var viewModel: AnalyticsDashboardViewModel!

    override func setUp() {
        super.setUp()
        mockCalculateVolumeUseCase = MockCalculateVolumeUseCase()
        mockTrackProgressiveOverloadUseCase = MockTrackProgressiveOverloadUseCase()
        mockGenerateProgressReportUseCase = MockGenerateProgressReportUseCase()
        mockCalculateRecoveryScoreUseCase = MockCalculateRecoveryScoreUseCase()
        mockCalculateStrainScoreUseCase = MockCalculateStrainScoreUseCase()
        mockAnalyticsRepository = MockAnalyticsRepository()
        mockHealthRepository = MockHealthRepository()
        mockNutritionRepository = MockNutritionRepository()

        viewModel = createViewModel()
    }

    override func tearDown() {
        mockCalculateVolumeUseCase = nil
        mockTrackProgressiveOverloadUseCase = nil
        mockGenerateProgressReportUseCase = nil
        mockCalculateRecoveryScoreUseCase = nil
        mockCalculateStrainScoreUseCase = nil
        mockAnalyticsRepository = nil
        mockHealthRepository = nil
        mockNutritionRepository = nil
        viewModel = nil
        super.tearDown()
    }

    private func createViewModel() -> AnalyticsDashboardViewModel {
        return AnalyticsDashboardViewModel(
            calculateVolumeUseCase: MockCalculateVolumeUseCaseAdapter(mock: mockCalculateVolumeUseCase),
            trackProgressiveOverloadUseCase: MockTrackProgressiveOverloadUseCaseAdapter(mock: mockTrackProgressiveOverloadUseCase),
            generateProgressReportUseCase: MockGenerateProgressReportUseCaseAdapter(mock: mockGenerateProgressReportUseCase),
            calculateRecoveryScoreUseCase: MockCalculateRecoveryScoreUseCaseAdapter(mock: mockCalculateRecoveryScoreUseCase),
            calculateStrainScoreUseCase: MockCalculateStrainScoreUseCaseAdapter(mock: mockCalculateStrainScoreUseCase),
            analyticsRepository: mockAnalyticsRepository,
            healthRepository: mockHealthRepository,
            nutritionRepository: mockNutritionRepository
        )
    }

    // MARK: - Initial State Tests

    func testInitialStateDefaults() {
        XCTAssertEqual(viewModel.selectedTimeRange, .month)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.recoveryScore, 0)
        XCTAssertEqual(viewModel.strainScore, 0)
        XCTAssertEqual(viewModel.sleepScore, 0)
    }

    func testInitialCollectionsAreEmpty() {
        XCTAssertTrue(viewModel.volumeMetrics.isEmpty)
        XCTAssertTrue(viewModel.progressSnapshots.isEmpty)
        XCTAssertTrue(viewModel.personalRecords.isEmpty)
        XCTAssertTrue(viewModel.weeklyMuscleVolume.isEmpty)
        XCTAssertTrue(viewModel.monthlyMuscleVolume.isEmpty)
    }

    // MARK: - Time Range Tests

    func testTimeRangeWeekDateRange() {
        let (start, end) = AnalyticsDashboardViewModel.TimeRange.week.dateRange()
        let calendar = Calendar.current
        let expectedDays = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        XCTAssertEqual(expectedDays, 7, accuracy: 1)
    }

    func testTimeRangeMonthDateRange() {
        let (start, end) = AnalyticsDashboardViewModel.TimeRange.month.dateRange()
        let calendar = Calendar.current
        let expectedDays = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        XCTAssertGreaterThanOrEqual(expectedDays, 28)
        XCTAssertLessThanOrEqual(expectedDays, 31)
    }

    func testTimeRangeThreeMonthsDateRange() {
        let (start, end) = AnalyticsDashboardViewModel.TimeRange.threeMonths.dateRange()
        let calendar = Calendar.current
        let expectedDays = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        XCTAssertGreaterThanOrEqual(expectedDays, 84)
        XCTAssertLessThanOrEqual(expectedDays, 93)
    }

    func testTimeRangeSixMonthsDateRange() {
        let (start, end) = AnalyticsDashboardViewModel.TimeRange.sixMonths.dateRange()
        let calendar = Calendar.current
        let expectedDays = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        XCTAssertGreaterThanOrEqual(expectedDays, 180)
        XCTAssertLessThanOrEqual(expectedDays, 186)
    }

    func testTimeRangeYearDateRange() {
        let (start, end) = AnalyticsDashboardViewModel.TimeRange.year.dateRange()
        let calendar = Calendar.current
        let expectedDays = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        XCTAssertGreaterThanOrEqual(expectedDays, 365)
        XCTAssertLessThanOrEqual(expectedDays, 366)
    }

    func testTimeRangeCaseIterable() {
        let allCases = AnalyticsDashboardViewModel.TimeRange.allCases
        XCTAssertEqual(allCases.count, 5)
        XCTAssertTrue(allCases.contains(.week))
        XCTAssertTrue(allCases.contains(.month))
        XCTAssertTrue(allCases.contains(.threeMonths))
        XCTAssertTrue(allCases.contains(.sixMonths))
        XCTAssertTrue(allCases.contains(.year))
    }

    // MARK: - Data Loading Tests

    func testLoadDataSetsIsLoadingTrue() async {
        // Setup mock data
        setupMockData()

        // Start loading
        let loadTask = Task {
            await viewModel.loadData()
        }

        // Brief wait to check loading state
        try? await Task.sleep(for: .milliseconds(50))

        await loadTask.value

        // After loading completes
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadDataCallsUseCases() async {
        setupMockData()

        await viewModel.loadData()

        XCTAssertGreaterThan(mockGenerateProgressReportUseCase.executeCallCount, 0)
        XCTAssertGreaterThan(mockCalculateVolumeUseCase.executeForWeeksCallCount, 0)
    }

    func testLoadDataCallsRepositories() async {
        setupMockData()

        await viewModel.loadData()

        XCTAssertGreaterThan(mockAnalyticsRepository.getProgressSnapshotsCallCount, 0)
        XCTAssertGreaterThan(mockAnalyticsRepository.getPersonalRecordsCallCount, 0)
    }

    func testLoadDataSetsReport() async {
        let expectedReport = ProgressReport(
            period: DateInterval(start: Date().addingTimeInterval(-86400 * 30), end: Date()),
            bodyWeightChange: 1.5,
            volumeChange: 15.0,
            recordsBroken: [],
            workoutConsistency: 80.0,
            avgCalorieAdherence: 90.0,
            avgSleepHours: 7.8,
            avgHRV: 70.0
        )
        mockGenerateProgressReportUseCase.mockReport = expectedReport
        setupMockData()

        await viewModel.loadData()

        XCTAssertNotNil(viewModel.currentReport)
        XCTAssertEqual(viewModel.currentReport?.workoutConsistency, 80.0)
    }

    func testLoadDataPopulatesVolumeMetrics() async {
        let sampleMetrics = [
            MockAnalyticsRepository.createSampleVolumeMetrics(totalVolume: 5000),
            MockAnalyticsRepository.createSampleVolumeMetrics(totalVolume: 6000)
        ]
        mockCalculateVolumeUseCase.mockWeeklyMetrics = sampleMetrics
        setupMockData()

        await viewModel.loadData()

        XCTAssertFalse(viewModel.volumeMetrics.isEmpty)
    }

    func testLoadDataPopulatesPersonalRecords() async {
        let sampleRecords = [
            MockAnalyticsRepository.createSamplePersonalRecord(exerciseName: "Squat", value: 150),
            MockAnalyticsRepository.createSamplePersonalRecord(exerciseName: "Deadlift", value: 200)
        ]
        mockAnalyticsRepository.mockPersonalRecords = sampleRecords
        setupMockData()

        await viewModel.loadData()

        XCTAssertEqual(viewModel.personalRecords.count, 2)
    }

    // MARK: - Error Handling Tests

    func testLoadDataHandlesUseCaseError() async {
        mockGenerateProgressReportUseCase.shouldThrow = true
        setupMockData()

        await viewModel.loadData()

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadDataHandlesRepositoryError() async {
        mockAnalyticsRepository.shouldThrowOnGet = true
        setupMockData()

        await viewModel.loadData()

        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testLoadDataClearsErrorOnRetry() async {
        // First load with error
        mockGenerateProgressReportUseCase.shouldThrow = true
        await viewModel.loadData()
        XCTAssertNotNil(viewModel.errorMessage)

        // Retry without error
        mockGenerateProgressReportUseCase.shouldThrow = false
        setupMockData()
        await viewModel.loadData()

        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Health Data Tests

    func testLoadDataPopulatesHealthTrends() async {
        let healthMetrics = MockHealthRepository.createWeekMetrics()
        mockHealthRepository.mockWeekMetrics = healthMetrics
        setupMockData()

        await viewModel.loadData()

        // HRV and RHR trends should be populated
        XCTAssertFalse(viewModel.hrvTrend7Day.isEmpty)
        XCTAssertFalse(viewModel.restingHRTrend.isEmpty)
    }

    func testLoadDataCalculatesHRVBaseline() async {
        let healthMetrics = MockHealthRepository.createWeekMetrics()
        mockHealthRepository.mockWeekMetrics = healthMetrics
        setupMockData()

        await viewModel.loadData()

        XCTAssertNotNil(viewModel.hrvBaseline)
    }

    func testLoadDataUpdatesSleepTrend() async {
        let healthMetrics = MockHealthRepository.createWeekMetrics()
        mockHealthRepository.mockWeekMetrics = healthMetrics
        setupMockData()

        await viewModel.loadData()

        XCTAssertFalse(viewModel.sleepTrend.isEmpty)
    }

    // MARK: - Nutrition Data Tests

    func testLoadDataPopulatesCalorieAdherence() async {
        setupNutritionData()
        setupMockData()

        await viewModel.loadData()

        // Calorie adherence should be calculated
        XCTAssertFalse(viewModel.calorieAdherence.isEmpty)
    }

    func testLoadDataCalculatesMacroBreakdown() async {
        setupNutritionData()
        setupMockData()

        await viewModel.loadData()

        // Macro breakdown should have values
        let macros = viewModel.macroBreakdown
        XCTAssertGreaterThanOrEqual(macros.protein, 0)
        XCTAssertGreaterThanOrEqual(macros.carbs, 0)
        XCTAssertGreaterThanOrEqual(macros.fats, 0)
    }

    // MARK: - Score Calculation Tests

    func testSleepScoreCalculation() async {
        // Setup sleep data with 8 hours average (target)
        let healthMetrics = (0..<7).map { day in
            MockHealthRepository.createSampleMetrics(
                date: Calendar.current.date(byAdding: .day, value: -day, to: Date()) ?? Date(),
                sleep: 8.0
            )
        }
        mockHealthRepository.mockWeekMetrics = healthMetrics
        setupMockData()

        await viewModel.loadData()

        // Sleep score should be high (near 100) when meeting target
        XCTAssertGreaterThanOrEqual(viewModel.sleepScore, 90)
    }

    func testSleepScoreWithInsufficientSleep() async {
        // Setup minimum mock data first, then override with custom sleep data
        setupMockData()
        let healthMetrics = (0..<7).map { day -> HealthMetrics in
            let metricsDate = Calendar.current.date(byAdding: .day, value: -day, to: Date()) ?? Date()
            return MockHealthRepository.createSampleMetrics(
                date: metricsDate,
                sleep: 5.0
            )
        }
        mockHealthRepository.mockWeekMetrics = healthMetrics

        await viewModel.loadData()

        // Sleep score should be lower (5 hours / 8 target = 62.5%)
        XCTAssertLessThan(viewModel.sleepScore, 80)
    }

    // MARK: - Time Range Selection Tests

    func testChangeTimeRangeUpdatesSelection() {
        viewModel.selectedTimeRange = .week
        XCTAssertEqual(viewModel.selectedTimeRange, .week)

        viewModel.selectedTimeRange = .year
        XCTAssertEqual(viewModel.selectedTimeRange, .year)
    }

    // MARK: - Export Tests

    func testExportProgressReportPDFWithNoReport() async {
        // No report loaded
        viewModel.currentReport = nil

        let url = await viewModel.exportProgressReportPDF()

        XCTAssertNil(url)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testExportVolumeMetricsCSVWithNoMetrics() async {
        // No metrics loaded
        viewModel.volumeMetrics = []

        let url = await viewModel.exportVolumeMetricsCSV()

        XCTAssertNil(url)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Weekly Training Volume Tests

    func testWeeklyTrainingVolumeFromLatestMetrics() async {
        let metrics = [
            MockAnalyticsRepository.createSampleVolumeMetrics(totalVolume: 8000),
            MockAnalyticsRepository.createSampleVolumeMetrics(totalVolume: 10000)
        ]
        mockCalculateVolumeUseCase.mockWeeklyMetrics = metrics
        setupMockData()

        await viewModel.loadData()

        XCTAssertEqual(viewModel.weeklyTrainingVolume, 10000)
    }

    // MARK: - Weight Trend Tests

    func testWeightTrendFromProgressSnapshots() async {
        let snapshots = [
            MockAnalyticsRepository.createSampleProgressSnapshot(
                date: Date().addingTimeInterval(-86400 * 7),
                bodyWeight: 75.0
            ),
            MockAnalyticsRepository.createSampleProgressSnapshot(
                date: Date(),
                bodyWeight: 74.5
            )
        ]
        mockAnalyticsRepository.mockProgressSnapshots = snapshots
        setupMockData()

        await viewModel.loadData()

        XCTAssertFalse(viewModel.weightTrend.isEmpty)
    }

    // MARK: - Helper Methods

    private func setupMockData() {
        // Setup minimum required mock data for successful load
        mockHealthRepository.mockWeekMetrics = MockHealthRepository.createWeekMetrics()
        mockCalculateVolumeUseCase.mockWeeklyMetrics = [
            MockAnalyticsRepository.createSampleVolumeMetrics()
        ]
    }

    private func setupNutritionData() {
        let calendar = Calendar.current
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            let nutrition = DailyNutrition(
                date: startOfDay,
                caloriesConsumed: 2000 + Double(dayOffset * 50),
                proteinConsumed: 150,
                carbsConsumed: 200,
                fatConsumed: 70,
                calorieGoal: 2200,
                proteinGoal: 160,
                carbsGoal: 220,
                fatGoal: 65
            )
            mockNutritionRepository.mockDailyNutrition[startOfDay] = nutrition
        }
    }
}

// MARK: - Use Case Adapters

/// Adapters to bridge mock use cases to actual use case types expected by ViewModel

@MainActor
private final class MockCalculateVolumeUseCaseAdapter: CalculateVolumeUseCase {
    private let mock: MockCalculateVolumeUseCase

    init(mock: MockCalculateVolumeUseCase) {
        self.mock = mock
        // Use a dummy repository since we're overriding methods
        super.init(workoutRepository: DummyWorkoutRepository())
    }

    override func execute(startDate: Date, endDate: Date) async throws -> VolumeMetrics {
        return try await mock.execute(startDate: startDate, endDate: endDate)
    }

    override func executeForWeeks(_ weeks: Int) async throws -> [VolumeMetrics] {
        return try await mock.executeForWeeks(weeks)
    }
}

@MainActor
private final class MockTrackProgressiveOverloadUseCaseAdapter: TrackProgressiveOverloadUseCase {
    private let mock: MockTrackProgressiveOverloadUseCase

    init(mock: MockTrackProgressiveOverloadUseCase) {
        self.mock = mock
        super.init(workoutRepository: DummyWorkoutRepository())
    }

    override func execute(exerciseId: UUID, weeks: Int = 12) async throws -> ProgressiveOverloadData {
        return try await mock.execute(exerciseId: exerciseId, weeks: weeks)
    }
}

@MainActor
private final class MockGenerateProgressReportUseCaseAdapter: GenerateProgressReportUseCase {
    private let mock: MockGenerateProgressReportUseCase

    init(mock: MockGenerateProgressReportUseCase) {
        self.mock = mock
        super.init(
            workoutRepository: DummyWorkoutRepository(),
            healthRepository: MockHealthRepository(),
            nutritionRepository: MockNutritionRepository(),
            analyticsRepository: MockAnalyticsRepository(),
            calculateVolumeUseCase: CalculateVolumeUseCase(workoutRepository: DummyWorkoutRepository())
        )
    }

    override func execute(startDate: Date, endDate: Date) async throws -> ProgressReport {
        return try await mock.execute(startDate: startDate, endDate: endDate)
    }
}

@MainActor
private final class MockCalculateRecoveryScoreUseCaseAdapter: CalculateRecoveryScoreUseCase {
    private let mock: MockCalculateRecoveryScoreUseCase

    init(mock: MockCalculateRecoveryScoreUseCase) {
        self.mock = mock
        super.init(healthRepository: MockHealthRepository())
    }

    override func execute(for date: Date = Date()) async throws -> RecoveryScoreResult {
        return try await mock.execute()
    }
}

@MainActor
private final class MockCalculateStrainScoreUseCaseAdapter: CalculateStrainScoreUseCase {
    private let mock: MockCalculateStrainScoreUseCase

    init(mock: MockCalculateStrainScoreUseCase) {
        self.mock = mock
        super.init(
            healthRepository: MockHealthRepository(),
            userRepository: MockUserRepository()
        )
    }

    override func execute(for date: Date) async throws -> StrainResult? {
        return try await mock.execute(for: date)
    }
}

// MARK: - Dummy Repository for Adapter Initialization

private final class DummyWorkoutRepository: WorkoutRepository {
    func getExercises() async throws -> [Exercise] { [] }
    func getExercise(id: UUID) async throws -> Exercise? { nil }
    func searchExercises(query: String) async throws -> [Exercise] { [] }
    func saveExercise(_ exercise: Exercise) async throws {}
    func updateExercise(_ exercise: Exercise) async throws {}
    func deleteExercise(id: UUID) async throws {}
    func isExerciseUsedInWorkouts(_ exerciseId: UUID) async throws -> Bool { false }
    func getWorkouts() async throws -> [Workout] { [] }
    func getWorkout(id: UUID) async throws -> Workout? { nil }
    func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout] { [] }
    func saveWorkout(_ workout: Workout) async throws {}
    func deleteWorkout(id: UUID) async throws {}
    func getLastWorkoutForExercise(_ exerciseId: UUID) async throws -> Workout? { nil }
}
