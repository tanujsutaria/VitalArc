//
//  WorkoutTests.swift
//  VitalArcTests
//
//  Test Suite for Workout Module (Stream 3)
//

import XCTest
import SwiftData
@testable import VitalArc

@MainActor
final class WorkoutTests: XCTestCase {
    var modelContext: ModelContext!
    var container: DependencyContainer!
    var repository: WorkoutRepository!

    override func setUp() async throws {
        // Create in-memory model container for testing
        let schema = Schema([
            ExerciseModel.self,
            WorkoutModel.self,
            WorkoutSetModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)

        container = DependencyContainer(modelContext: modelContext)
        repository = container.workoutRepository
    }

    override func tearDown() async throws {
        modelContext = nil
        container = nil
        repository = nil
    }

    // MARK: - Exercise Seeding Tests

    func testExerciseSeedingCreates200Exercises() async throws {
        // Given: Empty database
        let initialExercises = try await repository.getExercises()
        XCTAssertEqual(initialExercises.count, 0, "Database should be empty initially")

        // When: Seeding exercises
        try await ExerciseSeeds.seedIfNeeded(repository: repository)

        // Then: 200 exercises should be created
        let exercises = try await repository.getExercises()
        XCTAssertEqual(exercises.count, 200, "Should have exactly 200 exercises after seeding")
    }

    func testExerciseSeedingHasCorrectCategoryDistribution() async throws {
        // When: Seeding exercises
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let exercises = try await repository.getExercises()

        // Then: Each category should have 50 exercises
        let pushExercises = exercises.filter { $0.category == .push }
        let pullExercises = exercises.filter { $0.category == .pull }
        let legsExercises = exercises.filter { $0.category == .legs }
        let coreExercises = exercises.filter { $0.category == .core }

        XCTAssertEqual(pushExercises.count, 50, "Should have 50 push exercises")
        XCTAssertEqual(pullExercises.count, 50, "Should have 50 pull exercises")
        XCTAssertEqual(legsExercises.count, 50, "Should have 50 legs exercises")
        XCTAssertEqual(coreExercises.count, 50, "Should have 50 core exercises")
    }

    func testExerciseSeedingIncludesKeyExercises() async throws {
        // When: Seeding exercises
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let exercises = try await repository.getExercises()

        // Then: Should include key exercises
        let exerciseNames = exercises.map { $0.name.lowercased() }
        XCTAssertTrue(exerciseNames.contains { $0.contains("bench press") }, "Should include Bench Press")
        XCTAssertTrue(exerciseNames.contains { $0.contains("squat") }, "Should include Squat")
        XCTAssertTrue(exerciseNames.contains { $0.contains("deadlift") }, "Should include Deadlift")
        XCTAssertTrue(exerciseNames.contains { $0.contains("pull") && $0.contains("up") }, "Should include Pull-ups")
    }

    func testExerciseSeedingOnlyHappensOnce() async throws {
        // Given: First seeding
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let firstCount = try await repository.getExercises().count

        // When: Attempting to seed again
        try await ExerciseSeeds.seedIfNeeded(repository: repository)

        // Then: Count should remain the same
        let secondCount = try await repository.getExercises().count
        XCTAssertEqual(firstCount, secondCount, "Should not duplicate exercises on second seed")
    }

    // MARK: - Exercise Search and Filter Tests

    func testSearchExercisesByName() async throws {
        // Given: Seeded exercises
        try await ExerciseSeeds.seedIfNeeded(repository: repository)

        // When: Searching for "bench"
        let results = try await repository.searchExercises(query: "bench")

        // Then: Should return exercises with "bench" in name
        XCTAssertGreaterThan(results.count, 0, "Should find exercises with 'bench'")
        XCTAssertTrue(results.allSatisfy { $0.name.lowercased().contains("bench") },
                     "All results should contain 'bench'")
    }

    func testSearchExercisesIsCaseInsensitive() async throws {
        // Given: Seeded exercises
        try await ExerciseSeeds.seedIfNeeded(repository: repository)

        // When: Searching with different cases
        let lowerResults = try await repository.searchExercises(query: "squat")
        let upperResults = try await repository.searchExercises(query: "SQUAT")
        let mixedResults = try await repository.searchExercises(query: "SqUaT")

        // Then: Should return same results
        XCTAssertEqual(lowerResults.count, upperResults.count, "Search should be case-insensitive")
        XCTAssertEqual(lowerResults.count, mixedResults.count, "Search should be case-insensitive")
    }

    func testGetExercisesUseCase() async throws {
        // Given: Seeded exercises and use case
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let useCase = GetExercisesUseCase(repository: repository)

        // When: Getting exercises with filter
        let pushExercises = try await useCase.execute(category: .push)

        // Then: Should return only push exercises
        XCTAssertEqual(pushExercises.count, 50, "Should return 50 push exercises")
        XCTAssertTrue(pushExercises.allSatisfy { $0.category == .push }, "All exercises should be push")
    }

    func testGetExercisesUseCaseWithSearch() async throws {
        // Given: Seeded exercises and use case
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let useCase = GetExercisesUseCase(repository: repository)

        // When: Searching within a category
        let results = try await useCase.execute(category: .push, searchQuery: "press")

        // Then: Should return push exercises with "press" in name
        XCTAssertGreaterThan(results.count, 0, "Should find press exercises")
        XCTAssertTrue(results.allSatisfy { $0.category == .push }, "All should be push exercises")
        XCTAssertTrue(results.allSatisfy { $0.name.lowercased().contains("press") },
                     "All should contain 'press'")
    }

    // MARK: - Workout Creation Tests

    func testCreateWorkoutUseCase() async throws {
        // Given: Seeded exercises and use case
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let exercises = try await repository.getExercises()
        let benchPress = exercises.first { $0.name.lowercased().contains("bench press") }!

        let useCase = CreateWorkoutUseCase(repository: repository)

        // When: Creating a workout
        let sets = [
            WorkoutSet(exerciseId: benchPress.id, weight: 100, reps: 10, setNumber: 1),
            WorkoutSet(exerciseId: benchPress.id, weight: 100, reps: 10, setNumber: 2),
            WorkoutSet(exerciseId: benchPress.id, weight: 100, reps: 8, setNumber: 3)
        ]

        let workout = try await useCase.execute(
            name: "Chest Day",
            sets: sets,
            notes: "Good session"
        )

        // Then: Workout should be created and saved
        XCTAssertNotNil(workout.id, "Workout should have an ID")
        XCTAssertEqual(workout.name, "Chest Day")
        XCTAssertEqual(workout.sets.count, 3)
        XCTAssertEqual(workout.notes, "Good session")

        // Verify it's in the repository
        let savedWorkout = try await repository.getWorkout(id: workout.id)
        XCTAssertNotNil(savedWorkout, "Workout should be saved in repository")
    }

    func testCreateWorkoutCalculatesTotalVolume() async throws {
        // Given: Exercise and use case
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let exercises = try await repository.getExercises()
        let exercise = exercises.first!

        let useCase = CreateWorkoutUseCase(repository: repository)

        // When: Creating workout with specific weights
        let sets = [
            WorkoutSet(exerciseId: exercise.id, weight: 100, reps: 10, setNumber: 1), // 1000
            WorkoutSet(exerciseId: exercise.id, weight: 100, reps: 8, setNumber: 2),  // 800
            WorkoutSet(exerciseId: exercise.id, weight: 100, reps: 6, setNumber: 3)   // 600
        ]

        let workout = try await useCase.execute(name: "Test", sets: sets)

        // Then: Total volume should be correct
        XCTAssertEqual(workout.totalVolume, 2400.0, accuracy: 0.01, "Total volume should be 2400")
    }

    // MARK: - Progression Calculation Tests

    func testCalculateProgressionUseCase() async throws {
        // Given: Exercise and previous workout
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let exercises = try await repository.getExercises()
        let benchPress = exercises.first { $0.name.lowercased().contains("bench press") }!

        // Create previous workout with 100kg
        let previousSets = [
            WorkoutSet(exerciseId: benchPress.id, weight: 100, reps: 10, setNumber: 1)
        ]
        let previousWorkout = Workout(name: "Previous", sets: previousSets)
        try await repository.saveWorkout(previousWorkout)

        // When: Calculating progression
        let useCase = CalculateProgressionUseCase(repository: repository)
        let suggestedWeight = try await useCase.execute(exerciseId: benchPress.id)

        // Then: Should suggest 5% more (105kg)
        XCTAssertEqual(suggestedWeight, 105.0, accuracy: 0.01,
                      "Should suggest 5% progression (100 * 1.05 = 105)")
    }

    func testCalculateProgressionWithNoHistory() async throws {
        // Given: Exercise with no workout history
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let exercises = try await repository.getExercises()
        let exercise = exercises.first!

        // When: Calculating progression
        let useCase = CalculateProgressionUseCase(repository: repository)
        let suggestedWeight = try await useCase.execute(exerciseId: exercise.id)

        // Then: Should suggest starting weight (20kg)
        XCTAssertEqual(suggestedWeight, 20.0, accuracy: 0.01,
                      "Should suggest starting weight when no history")
    }

    func testCalculateProgressionWithMultipleSets() async throws {
        // Given: Exercise and previous workout with varying weights
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let exercises = try await repository.getExercises()
        let exercise = exercises.first!

        // Create previous workout with multiple sets
        let previousSets = [
            WorkoutSet(exerciseId: exercise.id, weight: 100, reps: 10, setNumber: 1),
            WorkoutSet(exerciseId: exercise.id, weight: 110, reps: 8, setNumber: 2),
            WorkoutSet(exerciseId: exercise.id, weight: 120, reps: 6, setNumber: 3)
        ]
        let previousWorkout = Workout(name: "Previous", sets: previousSets)
        try await repository.saveWorkout(previousWorkout)

        // When: Calculating progression
        let useCase = CalculateProgressionUseCase(repository: repository)
        let suggestedWeight = try await useCase.execute(exerciseId: exercise.id)

        // Then: Should use highest weight and add 5% (120 * 1.05 = 126)
        XCTAssertEqual(suggestedWeight, 126.0, accuracy: 0.01,
                      "Should use highest weight for progression")
    }

    // MARK: - Workout History Tests

    func testGetWorkoutHistory() async throws {
        // Given: Multiple workouts
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let exercises = try await repository.getExercises()
        let exercise = exercises.first!

        let workout1 = Workout(
            date: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            name: "Workout 1",
            sets: [WorkoutSet(exerciseId: exercise.id, weight: 100, reps: 10, setNumber: 1)]
        )
        let workout2 = Workout(
            date: Date().addingTimeInterval(-86400), // 1 day ago
            name: "Workout 2",
            sets: [WorkoutSet(exerciseId: exercise.id, weight: 105, reps: 10, setNumber: 1)]
        )
        let workout3 = Workout(
            date: Date(),
            name: "Workout 3",
            sets: [WorkoutSet(exerciseId: exercise.id, weight: 110, reps: 10, setNumber: 1)]
        )

        try await repository.saveWorkout(workout1)
        try await repository.saveWorkout(workout2)
        try await repository.saveWorkout(workout3)

        // When: Getting all workouts
        let allWorkouts = try await repository.getWorkouts()

        // Then: Should return all 3 workouts
        XCTAssertEqual(allWorkouts.count, 3, "Should have 3 workouts")
    }

    func testGetWorkoutsByDateRange() async throws {
        // Given: Workouts on different dates
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let exercises = try await repository.getExercises()
        let exercise = exercises.first!

        let oldWorkout = Workout(
            date: Date().addingTimeInterval(-86400 * 10), // 10 days ago
            sets: [WorkoutSet(exerciseId: exercise.id, weight: 100, reps: 10, setNumber: 1)]
        )
        let recentWorkout = Workout(
            date: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            sets: [WorkoutSet(exerciseId: exercise.id, weight: 105, reps: 10, setNumber: 1)]
        )

        try await repository.saveWorkout(oldWorkout)
        try await repository.saveWorkout(recentWorkout)

        // When: Getting workouts from last 7 days
        let startDate = Date().addingTimeInterval(-86400 * 7)
        let endDate = Date()
        let workouts = try await repository.getWorkouts(from: startDate, to: endDate)

        // Then: Should only return recent workout
        XCTAssertEqual(workouts.count, 1, "Should only return workouts in date range")
        XCTAssertEqual(workouts.first?.id, recentWorkout.id)
    }

    func testDeleteWorkout() async throws {
        // Given: Saved workout
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let exercises = try await repository.getExercises()
        let exercise = exercises.first!

        let workout = Workout(
            sets: [WorkoutSet(exerciseId: exercise.id, weight: 100, reps: 10, setNumber: 1)]
        )
        try await repository.saveWorkout(workout)

        // Verify it exists
        let savedWorkout = try await repository.getWorkout(id: workout.id)
        XCTAssertNotNil(savedWorkout)

        // When: Deleting workout
        try await repository.deleteWorkout(id: workout.id)

        // Then: Should no longer exist
        let deletedWorkout = try await repository.getWorkout(id: workout.id)
        XCTAssertNil(deletedWorkout, "Workout should be deleted")
    }

    // MARK: - Repository Implementation Tests

    func testSaveAndRetrieveExercise() async throws {
        // Given: New exercise
        let exercise = Exercise(
            name: "Test Exercise",
            category: .push,
            primaryMuscles: [.chest],
            equipment: .barbell
        )

        // When: Saving exercise
        try await repository.saveExercise(exercise)

        // Then: Should be retrievable
        let retrieved = try await repository.getExercise(id: exercise.id)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.name, "Test Exercise")
        XCTAssertEqual(retrieved?.category, .push)
    }

    func testGetExerciseById() async throws {
        // Given: Seeded exercises
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let allExercises = try await repository.getExercises()
        let firstExercise = allExercises.first!

        // When: Getting exercise by ID
        let exercise = try await repository.getExercise(id: firstExercise.id)

        // Then: Should return correct exercise
        XCTAssertNotNil(exercise)
        XCTAssertEqual(exercise?.id, firstExercise.id)
        XCTAssertEqual(exercise?.name, firstExercise.name)
    }

    func testGetLastWorkoutForExercise() async throws {
        // Given: Multiple workouts for same exercise
        try await ExerciseSeeds.seedIfNeeded(repository: repository)
        let exercises = try await repository.getExercises()
        let exercise = exercises.first!

        let oldWorkout = Workout(
            date: Date().addingTimeInterval(-86400 * 7),
            sets: [WorkoutSet(exerciseId: exercise.id, weight: 100, reps: 10, setNumber: 1)]
        )
        let recentWorkout = Workout(
            date: Date().addingTimeInterval(-86400),
            sets: [WorkoutSet(exerciseId: exercise.id, weight: 110, reps: 10, setNumber: 1)]
        )

        try await repository.saveWorkout(oldWorkout)
        try await repository.saveWorkout(recentWorkout)

        // When: Getting last workout for exercise
        let lastWorkout = try await repository.getLastWorkoutForExercise(exercise.id)

        // Then: Should return most recent workout
        XCTAssertNotNil(lastWorkout)
        XCTAssertEqual(lastWorkout?.id, recentWorkout.id)
    }
}
