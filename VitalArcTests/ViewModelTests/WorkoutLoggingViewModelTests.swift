//
//  WorkoutLoggingViewModelTests.swift
//  VitalArcTests
//
//  Tests for WorkoutLoggingViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class WorkoutLoggingViewModelTests: XCTestCase {
    var repository: MockWorkoutRepository!
    var createWorkoutUseCase: CreateWorkoutUseCase!
    var calculateProgressionUseCase: CalculateProgressionUseCase!
    var viewModel: WorkoutLoggingViewModel!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
        createWorkoutUseCase = CreateWorkoutUseCase(repository: repository)
        calculateProgressionUseCase = CalculateProgressionUseCase(repository: repository)
        viewModel = WorkoutLoggingViewModel(
            createWorkoutUseCase: createWorkoutUseCase,
            calculateProgressionUseCase: calculateProgressionUseCase
        )
    }

    override func tearDown() async throws {
        repository = nil
        createWorkoutUseCase = nil
        calculateProgressionUseCase = nil
        viewModel = nil
    }

    // MARK: - Test Helpers

    private func makeTestExercise(name: String = "Bench Press") -> Exercise {
        Exercise(
            name: name,
            category: .push,
            primaryMuscles: [.chest],
            equipment: .barbell
        )
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertEqual(viewModel.workoutName, "")
        XCTAssertEqual(viewModel.notes, "")
        XCTAssertTrue(viewModel.selectedExercises.isEmpty)
        XCTAssertTrue(viewModel.exerciseSets.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showingExerciseLibrary)
    }

    // MARK: - Exercise Management Tests

    func testAddExercise() async {
        // Given
        let exercise = makeTestExercise()

        // When
        await viewModel.addExercise(exercise)

        // Then
        XCTAssertEqual(viewModel.selectedExercises.count, 1)
        XCTAssertEqual(viewModel.selectedExercises.first?.id, exercise.id)
        XCTAssertNotNil(viewModel.exerciseSets[exercise.id])
        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.count, 1)
    }

    func testAddExerciseInitializesWithSuggestedWeight() async {
        // Given - Previous workout with 100kg
        let exercise = makeTestExercise()
        let previousWorkout = Workout(
            sets: [WorkoutSet(exerciseId: exercise.id, weight: 100, reps: 10, setNumber: 1)]
        )
        repository.mockWorkouts = [previousWorkout]

        // When
        await viewModel.addExercise(exercise)

        // Then - Should suggest 105kg (5% progression)
        let initialSet = viewModel.exerciseSets[exercise.id]?.first
        XCTAssertEqual(initialSet?.weight ?? 0, 105, accuracy: 0.1)
    }

    func testAddExerciseWithNoHistoryUsesDefaultWeight() async {
        // Given - No previous workouts
        let exercise = makeTestExercise()

        // When
        await viewModel.addExercise(exercise)

        // Then - Should use default 20kg
        let initialSet = viewModel.exerciseSets[exercise.id]?.first
        XCTAssertEqual(initialSet?.weight, 20)
    }

    func testAddDuplicateExerciseIsIgnored() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)

        // When - Try to add same exercise again
        await viewModel.addExercise(exercise)

        // Then - Should still have only one
        XCTAssertEqual(viewModel.selectedExercises.count, 1)
    }

    func testRemoveExercise() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)

        // When
        viewModel.removeExercise(exercise)

        // Then
        XCTAssertTrue(viewModel.selectedExercises.isEmpty)
        XCTAssertNil(viewModel.exerciseSets[exercise.id])
    }

    func testAddMultipleExercises() async {
        // Given
        let exercise1 = makeTestExercise(name: "Bench Press")
        let exercise2 = makeTestExercise(name: "Squat")

        // When
        await viewModel.addExercise(exercise1)
        await viewModel.addExercise(exercise2)

        // Then
        XCTAssertEqual(viewModel.selectedExercises.count, 2)
        XCTAssertNotNil(viewModel.exerciseSets[exercise1.id])
        XCTAssertNotNil(viewModel.exerciseSets[exercise2.id])
    }

    // MARK: - Set Management Tests

    func testAddSet() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)

        // When
        viewModel.addSet(for: exercise.id)

        // Then
        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.count, 2)
    }

    func testAddSetCopiesLastSetValues() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)

        // Modify the first set
        var firstSet = viewModel.exerciseSets[exercise.id]![0]
        firstSet.weight = 80
        firstSet.reps = 12
        firstSet.rir = 2
        viewModel.updateSet(firstSet, for: exercise.id, at: 0)

        // When
        viewModel.addSet(for: exercise.id)

        // Then - New set should copy values from last set
        let newSet = viewModel.exerciseSets[exercise.id]?.last
        XCTAssertEqual(newSet?.weight, 80)
        XCTAssertEqual(newSet?.reps, 12)
        XCTAssertEqual(newSet?.rir, 2)
        XCTAssertEqual(newSet?.setNumber, 2)
    }

    func testRemoveSet() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)
        viewModel.addSet(for: exercise.id)
        viewModel.addSet(for: exercise.id)
        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.count, 3)

        // When
        viewModel.removeSet(for: exercise.id, at: 1)

        // Then
        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.count, 2)
    }

    func testRemoveSetRenumbersSets() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)
        viewModel.addSet(for: exercise.id)
        viewModel.addSet(for: exercise.id)

        // When - Remove middle set
        viewModel.removeSet(for: exercise.id, at: 1)

        // Then - Remaining sets should be renumbered
        let sets = viewModel.exerciseSets[exercise.id]!
        XCTAssertEqual(sets[0].setNumber, 1)
        XCTAssertEqual(sets[1].setNumber, 2)
    }

    func testUpdateSet() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)
        var updatedSet = viewModel.exerciseSets[exercise.id]![0]
        updatedSet.weight = 120
        updatedSet.reps = 8
        updatedSet.rir = 1

        // When
        viewModel.updateSet(updatedSet, for: exercise.id, at: 0)

        // Then
        let set = viewModel.exerciseSets[exercise.id]?.first
        XCTAssertEqual(set?.weight, 120)
        XCTAssertEqual(set?.reps, 8)
        XCTAssertEqual(set?.rir, 1)
    }

    // MARK: - Computed Properties Tests

    func testTotalSets() async {
        // Given
        let exercise1 = makeTestExercise(name: "Bench Press")
        let exercise2 = makeTestExercise(name: "Squat")
        await viewModel.addExercise(exercise1)
        await viewModel.addExercise(exercise2)
        viewModel.addSet(for: exercise1.id)
        viewModel.addSet(for: exercise2.id)
        viewModel.addSet(for: exercise2.id)

        // Then
        XCTAssertEqual(viewModel.totalSets, 5) // 2 + 3
    }

    func testTotalVolume() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)

        // Update set values
        var set1 = viewModel.exerciseSets[exercise.id]![0]
        set1.weight = 100
        set1.reps = 10
        viewModel.updateSet(set1, for: exercise.id, at: 0)

        viewModel.addSet(for: exercise.id)
        var set2 = viewModel.exerciseSets[exercise.id]![1]
        set2.weight = 100
        set2.reps = 8
        viewModel.updateSet(set2, for: exercise.id, at: 1)

        // Then
        XCTAssertEqual(viewModel.totalVolume, 1800, accuracy: 0.1) // 1000 + 800
    }

    func testCanSaveWithExercisesAndSets() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)

        // Then
        XCTAssertTrue(viewModel.canSave)
    }

    func testCanSaveWithNoExercises() {
        // Then
        XCTAssertFalse(viewModel.canSave)
    }

    func testDuration() async {
        // Given - Start time is set on init
        // Wait a small amount
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        XCTAssertGreaterThan(viewModel.duration, 0)
    }

    // MARK: - Save Workout Tests

    func testSaveWorkout() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)
        viewModel.workoutName = "Test Workout"
        viewModel.notes = "Test notes"

        // When
        await viewModel.saveWorkout()

        // Then
        XCTAssertEqual(repository.savedWorkouts.count, 1)
        let savedWorkout = repository.savedWorkouts.first
        XCTAssertEqual(savedWorkout?.name, "Test Workout")
        XCTAssertEqual(savedWorkout?.notes, "Test notes")
    }

    func testSaveWorkoutResetsState() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)
        viewModel.workoutName = "Test Workout"

        // When
        await viewModel.saveWorkout()

        // Then
        XCTAssertEqual(viewModel.workoutName, "")
        XCTAssertTrue(viewModel.selectedExercises.isEmpty)
        XCTAssertTrue(viewModel.exerciseSets.isEmpty)
    }

    func testSaveWorkoutWithEmptyName() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)
        viewModel.workoutName = ""

        // When
        await viewModel.saveWorkout()

        // Then - Should save with nil name
        let savedWorkout = repository.savedWorkouts.first
        XCTAssertNil(savedWorkout?.name)
    }

    func testSaveWorkoutHandlesError() async {
        // Given
        repository.shouldThrowOnSave = true
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)

        // When
        await viewModel.saveWorkout()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSaveWorkoutSetsLoadingState() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)

        // Verify loading state before and after
        XCTAssertFalse(viewModel.isLoading)

        // When
        await viewModel.saveWorkout()

        // Then - Loading should be false after completion
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Reset Tests

    func testResetWorkout() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)
        viewModel.workoutName = "Test"
        viewModel.notes = "Notes"

        // When
        viewModel.resetWorkout()

        // Then
        XCTAssertEqual(viewModel.workoutName, "")
        XCTAssertEqual(viewModel.notes, "")
        XCTAssertTrue(viewModel.selectedExercises.isEmpty)
        XCTAssertTrue(viewModel.exerciseSets.isEmpty)
    }

    // MARK: - Exercise Library State Tests

    func testAddExerciseClosesLibrary() async {
        // Given
        viewModel.showingExerciseLibrary = true
        let exercise = makeTestExercise()

        // When
        await viewModel.addExercise(exercise)

        // Then
        XCTAssertFalse(viewModel.showingExerciseLibrary)
    }

    // MARK: - Edge Cases

    func testAddSetToNonExistentExercise() {
        // Given - No exercises added
        let fakeExerciseId = UUID()

        // When
        viewModel.addSet(for: fakeExerciseId)

        // Then - Should do nothing
        XCTAssertNil(viewModel.exerciseSets[fakeExerciseId])
    }

    func testRemoveSetFromNonExistentExercise() {
        // Given
        let fakeExerciseId = UUID()

        // When/Then - Should not crash
        viewModel.removeSet(for: fakeExerciseId, at: 0)
    }

    func testUpdateSetForNonExistentExercise() {
        // Given
        let fakeExerciseId = UUID()
        let fakeSet = WorkoutSetData(
            exerciseId: fakeExerciseId,
            weight: 100,
            reps: 10,
            rir: nil,
            setNumber: 1,
            completed: false
        )

        // When/Then - Should not crash
        viewModel.updateSet(fakeSet, for: fakeExerciseId, at: 0)
    }

    func testSaveWorkoutCalculatesDuration() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)

        // Wait a bit to accumulate duration
        try? await Task.sleep(nanoseconds: 100_000_000)

        // When
        await viewModel.saveWorkout()

        // Then
        let savedWorkout = repository.savedWorkouts.first
        XCTAssertNotNil(savedWorkout?.duration)
        XCTAssertGreaterThan(savedWorkout?.duration ?? 0, 0)
    }

    // MARK: - Rest Duration Tests

    func testRestDurationDefault() {
        let exercise = makeTestExercise()
        // No override, no group → should return global default (90)
        XCTAssertEqual(viewModel.restDurationForExercise(exercise.id), 90)
    }

    func testRestDurationPerExerciseOverride() {
        let exercise = makeTestExercise()
        viewModel.exerciseRestDurations[exercise.id] = 120
        XCTAssertEqual(viewModel.restDurationForExercise(exercise.id), 120)
    }

    func testRestDurationSupersetMiddle() async {
        let ex1 = makeTestExercise(name: "Bench Press")
        let ex2 = makeTestExercise(name: "Bent Over Row")
        await viewModel.addExercise(ex1)
        await viewModel.addExercise(ex2)
        // Create superset group
        viewModel.toggleGroupingMode()
        viewModel.toggleExerciseForGrouping(ex1.id)
        viewModel.toggleExerciseForGrouping(ex2.id)
        viewModel.createGroup(type: .superset)
        // Middle exercise (not last) → 30s
        XCTAssertEqual(viewModel.restDurationForExercise(ex1.id), 30)
    }

    func testRestDurationSupersetLast() async {
        let ex1 = makeTestExercise(name: "Bench Press")
        let ex2 = makeTestExercise(name: "Bent Over Row")
        await viewModel.addExercise(ex1)
        await viewModel.addExercise(ex2)
        viewModel.toggleGroupingMode()
        viewModel.toggleExerciseForGrouping(ex1.id)
        viewModel.toggleExerciseForGrouping(ex2.id)
        viewModel.createGroup(type: .superset)
        // Last exercise → full rest (90s)
        XCTAssertEqual(viewModel.restDurationForExercise(ex2.id), 90)
    }

    func testEditGroupType() async {
        let ex1 = makeTestExercise(name: "Bench Press")
        let ex2 = makeTestExercise(name: "Bent Over Row")
        await viewModel.addExercise(ex1)
        await viewModel.addExercise(ex2)
        viewModel.toggleGroupingMode()
        viewModel.toggleExerciseForGrouping(ex1.id)
        viewModel.toggleExerciseForGrouping(ex2.id)
        viewModel.createGroup(type: .superset)
        let groupId = viewModel.setGroups.first!.id
        viewModel.editGroupType(groupId, newType: .circuit)
        XCTAssertEqual(viewModel.setGroups.first?.groupType, .circuit)
    }

    func testToggleGroupingModeClearsSelection() {
        let exerciseId = UUID()
        viewModel.isGroupingMode = true
        viewModel.selectedExerciseIdsForGrouping.insert(exerciseId)
        viewModel.toggleGroupingMode()
        XCTAssertFalse(viewModel.isGroupingMode)
        XCTAssertTrue(viewModel.selectedExerciseIdsForGrouping.isEmpty)
    }

    // MARK: - 1RM Integration Tests

    func testCurrentEstimated1RMWithSets() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)

        // Update set: 100kg x 10 reps → e1RM = 100 * (1 + 10/30) = 133.33
        var set = viewModel.exerciseSets[exercise.id]![0]
        set.weight = 100
        set.reps = 10
        viewModel.updateSet(set, for: exercise.id, at: 0)

        // Then
        let e1rm = viewModel.currentEstimated1RM(for: exercise.id)
        XCTAssertNotNil(e1rm)
        XCTAssertEqual(e1rm!, 133.33, accuracy: 0.01)
    }

    func testCurrentEstimated1RMPicksHighest() async {
        // Given
        let exercise = makeTestExercise()
        await viewModel.addExercise(exercise)

        // Set 1: 100kg x 10 → e1RM = 133.33
        var set1 = viewModel.exerciseSets[exercise.id]![0]
        set1.weight = 100
        set1.reps = 10
        viewModel.updateSet(set1, for: exercise.id, at: 0)

        // Add set 2: 120kg x 5 → e1RM = 120 * (1 + 5/30) = 140
        viewModel.addSet(for: exercise.id)
        var set2 = viewModel.exerciseSets[exercise.id]![1]
        set2.weight = 120
        set2.reps = 5
        viewModel.updateSet(set2, for: exercise.id, at: 1)

        // Then - Should pick the higher of 133.33 and 140
        let e1rm = viewModel.currentEstimated1RM(for: exercise.id)
        XCTAssertNotNil(e1rm)
        XCTAssertEqual(e1rm!, 140, accuracy: 0.01)
    }

    func testCurrentEstimated1RMForNonExistentExercise() {
        // Given - No exercise added
        let fakeId = UUID()

        // Then
        XCTAssertNil(viewModel.currentEstimated1RM(for: fakeId))
    }

    func testHistoricalBestLoadedOnAddExercise() async {
        // Given - ViewModel with 1RM use case
        let analyticsRepo = MockAnalyticsRepository()
        let oneRMUseCase = CalculateOneRepMaxUseCase(analyticsRepository: analyticsRepo)
        let vmWith1RM = WorkoutLoggingViewModel(
            createWorkoutUseCase: createWorkoutUseCase,
            calculateProgressionUseCase: calculateProgressionUseCase,
            calculateOneRepMaxUseCase: oneRMUseCase
        )

        let exercise = makeTestExercise()
        analyticsRepo.mockPersonalRecords = [
            PersonalRecord(exerciseId: exercise.id, exerciseName: "Bench Press", recordType: .oneRepMax, value: 130, date: Date())
        ]

        // When
        await vmWith1RM.addExercise(exercise)

        // Then
        XCTAssertEqual(vmWith1RM.historicalBest(for: exercise.id), 130)
    }

    func testResetWorkoutClears1RMState() async {
        // Given - ViewModel with 1RM use case
        let analyticsRepo = MockAnalyticsRepository()
        let oneRMUseCase = CalculateOneRepMaxUseCase(analyticsRepository: analyticsRepo)
        let vmWith1RM = WorkoutLoggingViewModel(
            createWorkoutUseCase: createWorkoutUseCase,
            calculateProgressionUseCase: calculateProgressionUseCase,
            calculateOneRepMaxUseCase: oneRMUseCase
        )

        let exercise = makeTestExercise()
        analyticsRepo.mockPersonalRecords = [
            PersonalRecord(exerciseId: exercise.id, exerciseName: "Bench Press", recordType: .oneRepMax, value: 130, date: Date())
        ]
        await vmWith1RM.addExercise(exercise)
        XCTAssertNotNil(vmWith1RM.historicalBest(for: exercise.id))

        // When
        vmWith1RM.resetWorkout()

        // Then
        XCTAssertTrue(vmWith1RM.historicalBest1RM.isEmpty)
    }
}
