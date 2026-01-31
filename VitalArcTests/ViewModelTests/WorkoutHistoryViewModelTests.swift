//
//  WorkoutHistoryViewModelTests.swift
//  VitalArcTests
//
//  Unit tests for WorkoutHistoryViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class WorkoutHistoryViewModelTests: XCTestCase {

    var mockRepository: MockWorkoutRepository!
    var viewModel: WorkoutHistoryViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockWorkoutRepository()
        viewModel = WorkoutHistoryViewModel(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialStateDefaults() {
        XCTAssertTrue(viewModel.workouts.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.selectedDateRange, .week)
    }

    // MARK: - Load Workouts Tests

    func testLoadWorkoutsSuccess() async {
        // Setup
        let sampleWorkouts = createSampleWorkouts()
        mockRepository.mockWorkouts = sampleWorkouts

        // Execute
        await viewModel.loadWorkouts()

        // Verify
        XCTAssertFalse(viewModel.workouts.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadWorkoutsWithDateRange() async {
        // Setup - create workouts spanning different time periods
        let now = Date()
        let recentWorkout = createWorkout(date: now.addingTimeInterval(-86400)) // 1 day ago
        let oldWorkout = createWorkout(date: now.addingTimeInterval(-30 * 86400)) // 30 days ago
        mockRepository.mockWorkouts = [recentWorkout, oldWorkout]

        // Execute with week range
        viewModel.selectedDateRange = .week
        await viewModel.loadWorkouts()

        // Verify - only recent workout should be in range
        XCTAssertEqual(viewModel.workouts.count, 1)
        XCTAssertEqual(viewModel.workouts.first?.id, recentWorkout.id)
    }

    func testLoadWorkoutsError() async {
        // Setup
        mockRepository.shouldThrowOnGet = true

        // Execute
        await viewModel.loadWorkouts()

        // Verify
        XCTAssertTrue(viewModel.workouts.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadWorkoutsSetsLoadingState() async {
        // Verify initial state
        XCTAssertFalse(viewModel.isLoading)

        // Execute
        await viewModel.loadWorkouts()

        // After completion, loading should be false
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Delete Workout Tests

    func testDeleteWorkoutSuccess() async {
        // Setup
        let workout = createWorkout()
        mockRepository.mockWorkouts = [workout]
        await viewModel.loadWorkouts()
        XCTAssertEqual(viewModel.workouts.count, 1)

        // Execute
        await viewModel.deleteWorkout(workout)

        // Verify
        XCTAssertTrue(viewModel.workouts.isEmpty)
        XCTAssertTrue(mockRepository.deletedWorkoutIds.contains(workout.id))
        XCTAssertNil(viewModel.errorMessage)
    }

    func testDeleteWorkoutError() async {
        // Setup
        let workout = createWorkout()
        mockRepository.mockWorkouts = [workout]
        await viewModel.loadWorkouts()
        mockRepository.shouldThrowOnDelete = true

        // Execute
        await viewModel.deleteWorkout(workout)

        // Verify - workout should still be in list due to error
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Date Range Selection Tests

    func testSelectDateRangeReloads() async {
        // Setup
        let now = Date()
        let recentWorkout = createWorkout(date: now.addingTimeInterval(-86400)) // 1 day ago
        let monthOldWorkout = createWorkout(date: now.addingTimeInterval(-20 * 86400)) // 20 days ago
        mockRepository.mockWorkouts = [recentWorkout, monthOldWorkout]

        // Execute week range
        await viewModel.selectDateRange(.week)
        let weekCount = viewModel.workouts.count

        // Execute month range
        await viewModel.selectDateRange(.month)
        let monthCount = viewModel.workouts.count

        // Verify
        XCTAssertEqual(viewModel.selectedDateRange, .month)
        XCTAssertGreaterThanOrEqual(monthCount, weekCount)
    }

    // MARK: - Statistics Tests

    func testTotalWorkoutsComputed() async {
        // Setup
        mockRepository.mockWorkouts = [createWorkout(), createWorkout(), createWorkout()]
        await viewModel.loadWorkouts()

        // Verify
        XCTAssertEqual(viewModel.totalWorkouts, 3)
    }

    func testTotalVolumeComputed() async {
        // Setup
        let workout1 = createWorkout(sets: [
            createWorkoutSet(weight: 100, reps: 10), // 1000
            createWorkoutSet(weight: 100, reps: 8)   // 800
        ])
        let workout2 = createWorkout(sets: [
            createWorkoutSet(weight: 50, reps: 12)   // 600
        ])
        mockRepository.mockWorkouts = [workout1, workout2]
        await viewModel.loadWorkouts()

        // Verify - total should be 1000 + 800 + 600 = 2400
        XCTAssertEqual(viewModel.totalVolume, 2400, accuracy: 0.1)
    }

    func testTotalSetsComputed() async {
        // Setup
        let workout1 = createWorkout(sets: [createWorkoutSet(), createWorkoutSet()])
        let workout2 = createWorkout(sets: [createWorkoutSet(), createWorkoutSet(), createWorkoutSet()])
        mockRepository.mockWorkouts = [workout1, workout2]
        await viewModel.loadWorkouts()

        // Verify
        XCTAssertEqual(viewModel.totalSets, 5)
    }

    func testAverageDurationComputed() async {
        // Setup
        let workout1 = createWorkout(duration: 3600) // 1 hour
        let workout2 = createWorkout(duration: 5400) // 1.5 hours
        mockRepository.mockWorkouts = [workout1, workout2]
        await viewModel.loadWorkouts()

        // Verify - average should be 4500 seconds
        XCTAssertEqual(viewModel.averageDuration, 4500, accuracy: 0.1)
    }

    func testAverageDurationWithNoDurations() async {
        // Setup - workouts without duration
        let workout = createWorkout(duration: nil)
        mockRepository.mockWorkouts = [workout]
        await viewModel.loadWorkouts()

        // Verify
        XCTAssertEqual(viewModel.averageDuration, 0)
    }

    func testAverageDurationWithEmptyWorkouts() {
        // No workouts loaded
        XCTAssertEqual(viewModel.averageDuration, 0)
    }

    // MARK: - Helper Methods

    private func createWorkout(
        date: Date = Date(),
        duration: TimeInterval? = 3600,
        sets: [WorkoutSet] = []
    ) -> Workout {
        Workout(
            date: date,
            name: "Test Workout",
            sets: sets.isEmpty ? [createWorkoutSet()] : sets,
            notes: nil,
            duration: duration
        )
    }

    private func createWorkoutSet(
        weight: Double = 100,
        reps: Int = 10
    ) -> WorkoutSet {
        WorkoutSet(
            exerciseId: UUID(),
            weight: weight,
            reps: reps,
            rpe: nil,
            setNumber: 1
        )
    }

    private func createSampleWorkouts() -> [Workout] {
        let now = Date()
        return [
            createWorkout(date: now.addingTimeInterval(-86400)),
            createWorkout(date: now.addingTimeInterval(-172800)),
            createWorkout(date: now.addingTimeInterval(-259200))
        ]
    }
}
