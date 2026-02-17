//
//  WorkoutDetailViewModelTests.swift
//  VitalArcTests
//
//  Tests for WorkoutDetailViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class WorkoutDetailViewModelTests: XCTestCase {
    var repository: MockWorkoutRepository!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
    }

    override func tearDown() async throws {
        repository = nil
    }

    // MARK: - Test Helpers

    private let exerciseId1 = UUID()
    private let exerciseId2 = UUID()

    private func makeExercise(id: UUID, name: String) -> Exercise {
        Exercise(
            id: id,
            name: name,
            category: .push,
            primaryMuscles: [.chest],
            equipment: .barbell
        )
    }

    private func makeWorkout(
        name: String? = "Test Workout",
        sets: [WorkoutSet] = [],
        notes: String? = nil,
        duration: TimeInterval? = 3600
    ) -> Workout {
        Workout(
            name: name,
            sets: sets,
            notes: notes,
            duration: duration
        )
    }

    // MARK: - Load Exercise Names

    func testLoadExerciseNames() async {
        // Given
        let exercise = makeExercise(id: exerciseId1, name: "Bench Press")
        repository.mockExercises = [exercise]

        let workout = makeWorkout(sets: [
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 1)
        ])
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // When
        await viewModel.loadExerciseDetails()

        // Then
        XCTAssertEqual(viewModel.exerciseNames[exerciseId1], "Bench Press")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testMissingExerciseFallback() async {
        // Given - Exercise not in repository
        let workout = makeWorkout(sets: [
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 1)
        ])
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // When
        await viewModel.loadExerciseDetails()

        // Then
        XCTAssertEqual(viewModel.exerciseName(for: exerciseId1), "Unknown Exercise")
    }

    func testLoadExerciseNamesWithError() async {
        // Given
        repository.shouldThrowOnGet = true
        let workout = makeWorkout(sets: [
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 1)
        ])
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // When
        await viewModel.loadExerciseDetails()

        // Then - Should fallback to "Unknown Exercise"
        XCTAssertEqual(viewModel.exerciseName(for: exerciseId1), "Unknown Exercise")
    }

    // MARK: - Grouping & Ordering

    func testSetsGroupedByExerciseId() async {
        // Given
        let workout = makeWorkout(sets: [
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 1),
            WorkoutSet(exerciseId: exerciseId2, weight: 50, reps: 12, setNumber: 1),
            WorkoutSet(exerciseId: exerciseId1, weight: 105, reps: 8, setNumber: 2),
        ])
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // Then
        let setsForEx1 = viewModel.sets(for: exerciseId1)
        let setsForEx2 = viewModel.sets(for: exerciseId2)
        XCTAssertEqual(setsForEx1.count, 2)
        XCTAssertEqual(setsForEx2.count, 1)
    }

    func testOrderedExerciseIdsPreservesFirstAppearance() async {
        // Given
        let workout = makeWorkout(sets: [
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 1),
            WorkoutSet(exerciseId: exerciseId2, weight: 50, reps: 12, setNumber: 1),
            WorkoutSet(exerciseId: exerciseId1, weight: 105, reps: 8, setNumber: 2),
        ])
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // Then
        let ordered = viewModel.orderedExerciseIds
        XCTAssertEqual(ordered.count, 2)
        XCTAssertEqual(ordered[0], exerciseId1)
        XCTAssertEqual(ordered[1], exerciseId2)
    }

    func testSetsSortedBySetNumber() async {
        // Given - Sets added out of order
        let workout = makeWorkout(sets: [
            WorkoutSet(exerciseId: exerciseId1, weight: 110, reps: 6, setNumber: 3),
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 1),
            WorkoutSet(exerciseId: exerciseId1, weight: 105, reps: 8, setNumber: 2),
        ])
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // Then
        let sets = viewModel.sets(for: exerciseId1)
        XCTAssertEqual(sets[0].setNumber, 1)
        XCTAssertEqual(sets[1].setNumber, 2)
        XCTAssertEqual(sets[2].setNumber, 3)
    }

    // MARK: - Volume Calculation

    func testExerciseVolume() async {
        // Given
        let workout = makeWorkout(sets: [
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 1), // 1000
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 8, setNumber: 2),  // 800
        ])
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // Then
        XCTAssertEqual(viewModel.exerciseVolume(for: exerciseId1), 1800, accuracy: 0.1)
    }

    func testTotalVolume() async {
        // Given
        let workout = makeWorkout(sets: [
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 1), // 1000
            WorkoutSet(exerciseId: exerciseId2, weight: 50, reps: 12, setNumber: 1),  // 600
        ])
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // Then
        XCTAssertEqual(viewModel.totalVolume, 1600, accuracy: 0.1)
    }

    // MARK: - Best Set

    func testBestSetByVolume() async {
        // Given
        let workout = makeWorkout(sets: [
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 1), // vol=1000
            WorkoutSet(exerciseId: exerciseId1, weight: 110, reps: 8, setNumber: 2),  // vol=880
            WorkoutSet(exerciseId: exerciseId1, weight: 120, reps: 6, setNumber: 3),  // vol=720
        ])
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // Then - Set 1 has highest volume (1000)
        let best = viewModel.bestSet(for: exerciseId1)
        XCTAssertEqual(best?.setNumber, 1)
        XCTAssertEqual(best?.volume ?? 0, 1000, accuracy: 0.1)
    }

    // MARK: - Empty Workout

    func testEmptyWorkout() async {
        // Given
        let workout = makeWorkout(sets: [])
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // Then
        XCTAssertTrue(viewModel.orderedExerciseIds.isEmpty)
        XCTAssertEqual(viewModel.totalSets, 0)
        XCTAssertEqual(viewModel.totalVolume, 0)
    }

    // MARK: - Workout Metadata

    func testWorkoutNameFallback() async {
        // Given
        let workout = Workout(name: nil, sets: [])
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // Then
        XCTAssertEqual(viewModel.name, "Workout")
    }

    func testWorkoutMetadata() async {
        // Given
        let date = Date()
        let workout = Workout(
            date: date,
            name: "Push Day",
            sets: [
                WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 1)
            ],
            notes: "Great session",
            duration: 3600
        )
        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)

        // Then
        XCTAssertEqual(viewModel.name, "Push Day")
        XCTAssertEqual(viewModel.date, date)
        XCTAssertEqual(viewModel.notes, "Great session")
        XCTAssertEqual(viewModel.duration, 3600)
        XCTAssertEqual(viewModel.totalSets, 1)
    }
}
