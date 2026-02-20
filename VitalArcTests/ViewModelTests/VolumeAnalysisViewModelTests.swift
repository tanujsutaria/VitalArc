//
//  VolumeAnalysisViewModelTests.swift
//  VitalArcTests
//
//  Unit tests for VolumeAnalysisViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class VolumeAnalysisViewModelTests: XCTestCase {

    var mockRepository: MockWorkoutRepository!
    var viewModel: VolumeAnalysisViewModel!

    // MARK: - Test Data

    let benchPressId = UUID()
    let squatId = UUID()
    let curlId = UUID()
    let lateralRaiseId = UUID()

    override func setUp() {
        super.setUp()
        mockRepository = MockWorkoutRepository()
        viewModel = VolumeAnalysisViewModel(workoutRepository: mockRepository)
        setupExercises()
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    private func setupExercises() {
        mockRepository.mockExercises = [
            Exercise(
                id: benchPressId,
                name: "Bench Press",
                category: .push,
                primaryMuscles: [.chest],
                equipment: .barbell
            ),
            Exercise(
                id: squatId,
                name: "Barbell Squat",
                category: .legs,
                primaryMuscles: [.quadriceps, .glutes],
                equipment: .barbell
            ),
            Exercise(
                id: curlId,
                name: "Bicep Curl",
                category: .pull,
                primaryMuscles: [.biceps],
                equipment: .dumbbell
            ),
            Exercise(
                id: lateralRaiseId,
                name: "Lateral Raise",
                category: .push,
                primaryMuscles: [.shoulders],
                equipment: .dumbbell
            )
        ]
    }

    private func makeWorkout(date: Date, exerciseId: UUID, sets: Int, weight: Double = 60, reps: Int = 10) -> Workout {
        let workoutSets = (0..<sets).map { i in
            WorkoutSet(
                exerciseId: exerciseId,
                weight: weight,
                reps: reps,
                setNumber: i + 1
            )
        }
        return Workout(date: date, sets: workoutSets)
    }

    // MARK: - Muscle Size Classification Tests

    func testSmallMuscleClassification() {
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .biceps), .small)
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .triceps), .small)
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .calves), .small)
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .forearms), .small)
    }

    func testMediumMuscleClassification() {
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .shoulders), .medium)
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .chest), .medium)
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .back), .medium)
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .abs), .medium)
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .lats), .medium)
    }

    func testLargeMuscleClassification() {
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .quadriceps), .large)
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .hamstrings), .large)
        XCTAssertEqual(VolumeAnalysisViewModel.muscleSizeCategory(for: .glutes), .large)
    }

    // MARK: - Recommended Range Tests

    func testSmallMuscleRecommendedRange() {
        let range = MuscleSizeCategory.small.recommendedSetsRange
        XCTAssertEqual(range.lowerBound, 10)
        XCTAssertEqual(range.upperBound, 14)
    }

    func testMediumMuscleRecommendedRange() {
        let range = MuscleSizeCategory.medium.recommendedSetsRange
        XCTAssertEqual(range.lowerBound, 12)
        XCTAssertEqual(range.upperBound, 18)
    }

    func testLargeMuscleRecommendedRange() {
        let range = MuscleSizeCategory.large.recommendedSetsRange
        XCTAssertEqual(range.lowerBound, 14)
        XCTAssertEqual(range.upperBound, 20)
    }

    // MARK: - Volume Status Tests

    func testUnderVolumeStatus() {
        let analysis = MuscleVolumeAnalysis(
            muscleGroup: .chest,
            weeklySets: 5,
            weeklyVolume: 3000,
            recommendedRange: 12...18,
            sizeCategory: .medium,
            frequency: 1,
            daysSinceLastTrained: 3,
            weeklyTrend: []
        )
        XCTAssertEqual(analysis.volumeStatus, .underVolume)
    }

    func testOptimalVolumeStatus() {
        let analysis = MuscleVolumeAnalysis(
            muscleGroup: .chest,
            weeklySets: 15,
            weeklyVolume: 9000,
            recommendedRange: 12...18,
            sizeCategory: .medium,
            frequency: 2,
            daysSinceLastTrained: 1,
            weeklyTrend: []
        )
        XCTAssertEqual(analysis.volumeStatus, .optimal)
    }

    func testOverVolumeStatus() {
        let analysis = MuscleVolumeAnalysis(
            muscleGroup: .chest,
            weeklySets: 25,
            weeklyVolume: 15000,
            recommendedRange: 12...18,
            sizeCategory: .medium,
            frequency: 4,
            daysSinceLastTrained: 0,
            weeklyTrend: []
        )
        XCTAssertEqual(analysis.volumeStatus, .overVolume)
    }

    func testBoundaryVolumeStatus() {
        // Exactly at lower bound = optimal
        let atLower = MuscleVolumeAnalysis(
            muscleGroup: .biceps,
            weeklySets: 10,
            weeklyVolume: 2000,
            recommendedRange: 10...14,
            sizeCategory: .small,
            frequency: 2,
            daysSinceLastTrained: 2,
            weeklyTrend: []
        )
        XCTAssertEqual(atLower.volumeStatus, .optimal)

        // Exactly at upper bound = optimal
        let atUpper = MuscleVolumeAnalysis(
            muscleGroup: .biceps,
            weeklySets: 14,
            weeklyVolume: 2800,
            recommendedRange: 10...14,
            sizeCategory: .small,
            frequency: 3,
            daysSinceLastTrained: 1,
            weeklyTrend: []
        )
        XCTAssertEqual(atUpper.volumeStatus, .optimal)
    }

    // MARK: - Recovery Status Tests

    func testRecoveryStatusRecovering() {
        let analysis = MuscleVolumeAnalysis(
            muscleGroup: .chest,
            weeklySets: 12,
            weeklyVolume: 7200,
            recommendedRange: 12...18,
            sizeCategory: .medium,
            frequency: 2,
            daysSinceLastTrained: 0,
            weeklyTrend: []
        )
        XCTAssertEqual(analysis.recoveryStatus, .recovering)

        let analysis2 = MuscleVolumeAnalysis(
            muscleGroup: .chest,
            weeklySets: 12,
            weeklyVolume: 7200,
            recommendedRange: 12...18,
            sizeCategory: .medium,
            frequency: 2,
            daysSinceLastTrained: 1,
            weeklyTrend: []
        )
        XCTAssertEqual(analysis2.recoveryStatus, .recovering)
    }

    func testRecoveryStatusReady() {
        let analysis = MuscleVolumeAnalysis(
            muscleGroup: .chest,
            weeklySets: 12,
            weeklyVolume: 7200,
            recommendedRange: 12...18,
            sizeCategory: .medium,
            frequency: 2,
            daysSinceLastTrained: 2,
            weeklyTrend: []
        )
        XCTAssertEqual(analysis.recoveryStatus, .ready)
    }

    func testRecoveryStatusRested() {
        let analysis = MuscleVolumeAnalysis(
            muscleGroup: .chest,
            weeklySets: 12,
            weeklyVolume: 7200,
            recommendedRange: 12...18,
            sizeCategory: .medium,
            frequency: 2,
            daysSinceLastTrained: 4,
            weeklyTrend: []
        )
        XCTAssertEqual(analysis.recoveryStatus, .rested)
    }

    func testRecoveryStatusOverdue() {
        let analysis = MuscleVolumeAnalysis(
            muscleGroup: .chest,
            weeklySets: 12,
            weeklyVolume: 7200,
            recommendedRange: 12...18,
            sizeCategory: .medium,
            frequency: 2,
            daysSinceLastTrained: 7,
            weeklyTrend: []
        )
        XCTAssertEqual(analysis.recoveryStatus, .overdue)
    }

    func testRecoveryStatusUnknown() {
        let analysis = MuscleVolumeAnalysis(
            muscleGroup: .chest,
            weeklySets: 12,
            weeklyVolume: 7200,
            recommendedRange: 12...18,
            sizeCategory: .medium,
            frequency: 2,
            daysSinceLastTrained: nil,
            weeklyTrend: []
        )
        XCTAssertEqual(analysis.recoveryStatus, .unknown)
    }

    // MARK: - Volume Calculation Tests

    func testWeeklyVolumeCalculation() async throws {
        let calendar = Calendar.current
        let today = Date()
        let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)!.start

        // 4 sets of bench in current week
        mockRepository.mockWorkouts = [
            makeWorkout(date: thisWeekStart, exerciseId: benchPressId, sets: 4, weight: 80, reps: 10)
        ]

        let startDate = calendar.date(byAdding: .weekOfYear, value: -8, to: today)!
        let analyses = try await viewModel.buildAnalyses(from: mockRepository.mockWorkouts, startDate: startDate, endDate: today, weeks: 8)

        let chestAnalysis = analyses.first { $0.muscleGroup == .chest }
        XCTAssertNotNil(chestAnalysis)
        XCTAssertEqual(chestAnalysis?.weeklySets, 4)
        XCTAssertEqual(chestAnalysis?.weeklyVolume ?? 0, 3200, accuracy: 0.01) // 4 * 80 * 10
    }

    // MARK: - Volume Trend Tests

    func testVolumeTrendOverMultipleWeeks() async throws {
        let calendar = Calendar.current
        let today = Date()

        // Create workouts across 4 different weeks
        var workouts: [Workout] = []
        for weekOffset in 0..<4 {
            let date = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today)!
            workouts.append(makeWorkout(date: date, exerciseId: benchPressId, sets: 3 + weekOffset))
        }
        mockRepository.mockWorkouts = workouts

        let startDate = calendar.date(byAdding: .weekOfYear, value: -8, to: today)!
        let analyses = try await viewModel.buildAnalyses(from: workouts, startDate: startDate, endDate: today, weeks: 8)

        let chestAnalysis = analyses.first { $0.muscleGroup == .chest }
        XCTAssertNotNil(chestAnalysis)

        // Should have weekly trend entries
        let trend = chestAnalysis?.weeklyTrend ?? []
        XCTAssertGreaterThan(trend.count, 0)
    }

    // MARK: - Frequency Calculation Tests

    func testFrequencyCalculation() async throws {
        let calendar = Calendar.current
        let today = Date()

        // 4 sessions over 4 weeks = 1 session/week
        var workouts: [Workout] = []
        for weekOffset in 0..<4 {
            let date = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today)!
            workouts.append(makeWorkout(date: date, exerciseId: benchPressId, sets: 3))
        }
        mockRepository.mockWorkouts = workouts

        let startDate = calendar.date(byAdding: .weekOfYear, value: -4, to: today)!
        let analyses = try await viewModel.buildAnalyses(from: workouts, startDate: startDate, endDate: today, weeks: 4)

        let chestAnalysis = analyses.first { $0.muscleGroup == .chest }
        XCTAssertEqual(chestAnalysis?.frequency ?? 0, 1.0, accuracy: 0.01)
    }

    func testHigherFrequencyWith2xPerWeek() async throws {
        let calendar = Calendar.current
        let today = Date()

        // 8 sessions over 4 weeks = 2 sessions/week
        var workouts: [Workout] = []
        for weekOffset in 0..<4 {
            let mondayDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today)!
            let thursdayDate = calendar.date(byAdding: .day, value: 3, to: mondayDate)!
            workouts.append(makeWorkout(date: mondayDate, exerciseId: benchPressId, sets: 3))
            workouts.append(makeWorkout(date: thursdayDate, exerciseId: benchPressId, sets: 3))
        }
        mockRepository.mockWorkouts = workouts

        let startDate = calendar.date(byAdding: .weekOfYear, value: -4, to: today)!
        let analyses = try await viewModel.buildAnalyses(from: workouts, startDate: startDate, endDate: today, weeks: 4)

        let chestAnalysis = analyses.first { $0.muscleGroup == .chest }
        XCTAssertEqual(chestAnalysis?.frequency ?? 0, 2.0, accuracy: 0.01)
    }

    // MARK: - Days Since Last Trained Tests

    func testDaysSinceLastTrained() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!

        mockRepository.mockWorkouts = [
            makeWorkout(date: threeDaysAgo, exerciseId: benchPressId, sets: 3)
        ]

        let startDate = calendar.date(byAdding: .weekOfYear, value: -4, to: today)!
        let analyses = try await viewModel.buildAnalyses(from: mockRepository.mockWorkouts, startDate: startDate, endDate: today, weeks: 4)

        let chestAnalysis = analyses.first { $0.muscleGroup == .chest }
        XCTAssertEqual(chestAnalysis?.daysSinceLastTrained, 3)
    }

    // MARK: - Edge Cases

    func testNoWorkoutsReturnsEmptyAnalyses() async throws {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .weekOfYear, value: -8, to: today)!

        let analyses = try await viewModel.buildAnalyses(from: [], startDate: startDate, endDate: today, weeks: 8)
        XCTAssertTrue(analyses.isEmpty)
    }

    func testSingleSetSingleWorkout() async throws {
        let calendar = Calendar.current
        let today = Date()
        let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)!.start

        // Single workout with 1 set
        mockRepository.mockWorkouts = [
            makeWorkout(date: thisWeekStart, exerciseId: curlId, sets: 1, weight: 10, reps: 12)
        ]

        let startDate = calendar.date(byAdding: .weekOfYear, value: -8, to: today)!
        let analyses = try await viewModel.buildAnalyses(from: mockRepository.mockWorkouts, startDate: startDate, endDate: today, weeks: 8)

        let bicepsAnalysis = analyses.first { $0.muscleGroup == .biceps }
        XCTAssertNotNil(bicepsAnalysis)
        XCTAssertEqual(bicepsAnalysis?.weeklySets, 1)
        XCTAssertEqual(bicepsAnalysis?.volumeStatus, .underVolume) // 1 set < 10 (small muscle min)
    }

    // MARK: - Summary Tests

    func testSummaryComputedProperty() async throws {
        let calendar = Calendar.current
        let today = Date()
        let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)!.start

        mockRepository.mockWorkouts = [
            makeWorkout(date: thisWeekStart, exerciseId: benchPressId, sets: 15), // chest: optimal (12-18)
            makeWorkout(date: thisWeekStart, exerciseId: curlId, sets: 3),        // biceps: under (10-14)
            makeWorkout(date: thisWeekStart, exerciseId: squatId, sets: 25)        // quads+glutes: over (14-20)
        ]

        let startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: today)!
        viewModel.analyses = try await viewModel.buildAnalyses(from: mockRepository.mockWorkouts, startDate: startDate, endDate: today, weeks: 1)

        let summary = viewModel.summary
        XCTAssertNotNil(summary.mostTrainedMuscle)
        XCTAssertFalse(summary.musclesUnderVolume.isEmpty)
    }

    // MARK: - Selected Analysis Tests

    func testSelectedAnalysisReturnsCorrectMuscle() async throws {
        let calendar = Calendar.current
        let today = Date()
        let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)!.start

        mockRepository.mockWorkouts = [
            makeWorkout(date: thisWeekStart, exerciseId: benchPressId, sets: 10),
            makeWorkout(date: thisWeekStart, exerciseId: curlId, sets: 5)
        ]

        let startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: today)!
        viewModel.analyses = try await viewModel.buildAnalyses(from: mockRepository.mockWorkouts, startDate: startDate, endDate: today, weeks: 1)

        viewModel.selectedMuscle = .chest
        let selected = viewModel.selectedAnalysis
        XCTAssertNotNil(selected)
        XCTAssertEqual(selected?.muscleGroup, .chest)
    }

    func testSelectedAnalysisNilWhenNoSelection() {
        viewModel.selectedMuscle = nil
        XCTAssertNil(viewModel.selectedAnalysis)
    }
}
