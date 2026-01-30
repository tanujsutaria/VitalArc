//
//  CreateWorkoutUseCaseTests.swift
//  VitalArcTests
//
//  Tests for CreateWorkoutUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class CreateWorkoutUseCaseTests: XCTestCase {
    var repository: MockWorkoutRepository!
    var useCase: CreateWorkoutUseCase!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
        useCase = CreateWorkoutUseCase(repository: repository)
    }

    override func tearDown() async throws {
        repository = nil
        useCase = nil
    }

    // MARK: - Happy Path Tests

    func testCreateWorkoutWithValidSets() async throws {
        // Given
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1),
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 8, setNumber: 2),
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 6, setNumber: 3)
        ]

        // When
        let workout = try await useCase.execute(
            name: "Chest Day",
            sets: sets,
            notes: "Good session"
        )

        // Then
        XCTAssertEqual(workout.name, "Chest Day")
        XCTAssertEqual(workout.sets.count, 3)
        XCTAssertEqual(workout.notes, "Good session")
        XCTAssertEqual(repository.savedWorkouts.count, 1)
        XCTAssertEqual(repository.savedWorkouts.first?.id, workout.id)
    }

    func testCreateWorkoutWithEmptySets() async throws {
        // Given
        let sets: [WorkoutSet] = []

        // When
        let workout = try await useCase.execute(
            name: "Empty Workout",
            sets: sets
        )

        // Then - The use case allows empty sets (validation is typically in ViewModel)
        XCTAssertEqual(workout.sets.count, 0)
        XCTAssertEqual(workout.name, "Empty Workout")
        XCTAssertEqual(repository.savedWorkouts.count, 1)
    }

    func testCreateWorkoutWithoutName() async throws {
        // Given
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 50, reps: 12, setNumber: 1)
        ]

        // When
        let workout = try await useCase.execute(sets: sets)

        // Then
        XCTAssertNil(workout.name)
        XCTAssertEqual(workout.sets.count, 1)
    }

    func testCreateWorkoutWithCustomDate() async throws {
        // Given
        let exerciseId = UUID()
        let customDate = Date().addingTimeInterval(-86400) // Yesterday
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 80, reps: 10, setNumber: 1)
        ]

        // When
        let workout = try await useCase.execute(
            sets: sets,
            date: customDate
        )

        // Then
        XCTAssertEqual(workout.date.timeIntervalSince1970, customDate.timeIntervalSince1970, accuracy: 1)
    }

    func testCreateWorkoutWithDuration() async throws {
        // Given
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 60, reps: 15, setNumber: 1)
        ]
        let duration: TimeInterval = 3600 // 1 hour

        // When
        let workout = try await useCase.execute(
            sets: sets,
            duration: duration
        )

        // Then
        XCTAssertEqual(workout.duration, 3600)
    }

    // MARK: - Volume Calculation Tests

    func testWorkoutTotalVolumeCalculation() async throws {
        // Given
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1), // 1000
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 8, setNumber: 2),  // 800
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 6, setNumber: 3)   // 600
        ]

        // When
        let workout = try await useCase.execute(sets: sets)

        // Then
        XCTAssertEqual(workout.totalVolume, 2400.0, accuracy: 0.01)
    }

    func testWorkoutVolumeWithMultipleExercises() async throws {
        // Given
        let exerciseId1 = UUID()
        let exerciseId2 = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 1), // 1000
            WorkoutSet(exerciseId: exerciseId1, weight: 100, reps: 10, setNumber: 2), // 1000
            WorkoutSet(exerciseId: exerciseId2, weight: 50, reps: 12, setNumber: 1),  // 600
            WorkoutSet(exerciseId: exerciseId2, weight: 50, reps: 12, setNumber: 2)   // 600
        ]

        // When
        let workout = try await useCase.execute(sets: sets)

        // Then
        XCTAssertEqual(workout.totalVolume, 3200.0, accuracy: 0.01)
    }

    func testWorkoutVolumeWithZeroWeight() async throws {
        // Given - bodyweight exercise scenario
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 0, reps: 10, setNumber: 1),
            WorkoutSet(exerciseId: exerciseId, weight: 0, reps: 8, setNumber: 2)
        ]

        // When
        let workout = try await useCase.execute(sets: sets)

        // Then
        XCTAssertEqual(workout.totalVolume, 0.0)
    }

    // MARK: - Persistence Tests

    func testWorkoutIsSavedToRepository() async throws {
        // Given
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 75, reps: 10, setNumber: 1)
        ]

        // When
        let workout = try await useCase.execute(
            name: "Test Workout",
            sets: sets
        )

        // Then
        XCTAssertEqual(repository.savedWorkouts.count, 1)
        let savedWorkout = repository.savedWorkouts.first
        XCTAssertEqual(savedWorkout?.id, workout.id)
        XCTAssertEqual(savedWorkout?.name, "Test Workout")
        XCTAssertEqual(savedWorkout?.sets.count, 1)
    }

    func testWorkoutCanBeRetrievedAfterSave() async throws {
        // Given
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 90, reps: 8, setNumber: 1)
        ]

        // When
        let workout = try await useCase.execute(sets: sets)

        // Then - Verify it's retrievable
        let retrieved = try await repository.getWorkout(id: workout.id)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, workout.id)
    }

    // MARK: - Error Handling Tests

    func testCreateWorkoutThrowsOnRepositoryError() async throws {
        // Given
        repository.shouldThrowOnSave = true
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1)
        ]

        // When/Then
        do {
            _ = try await useCase.execute(sets: sets)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockWorkoutRepository.MockError)
        }
    }

    // MARK: - Edge Cases

    func testCreateWorkoutWithRIRValues() async throws {
        // Given
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, rir: 3, setNumber: 1),
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 8, rir: 2, setNumber: 2),
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 6, rir: 1, setNumber: 3)
        ]

        // When
        let workout = try await useCase.execute(sets: sets)

        // Then
        XCTAssertEqual(workout.sets[0].rir, 3)
        XCTAssertEqual(workout.sets[1].rir, 2)
        XCTAssertEqual(workout.sets[2].rir, 1)
    }

    func testCreateWorkoutWithHighVolume() async throws {
        // Given - Very heavy workout
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 200, reps: 5, setNumber: 1),
            WorkoutSet(exerciseId: exerciseId, weight: 220, reps: 3, setNumber: 2),
            WorkoutSet(exerciseId: exerciseId, weight: 240, reps: 1, setNumber: 3)
        ]

        // When
        let workout = try await useCase.execute(name: "Heavy Day", sets: sets)

        // Then
        // Volume: (200*5) + (220*3) + (240*1) = 1000 + 660 + 240 = 1900
        XCTAssertEqual(workout.totalVolume, 1900.0, accuracy: 0.01)
    }

    func testCreateWorkoutPreservesSetOrder() async throws {
        // Given
        let exerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1),
            WorkoutSet(exerciseId: exerciseId, weight: 105, reps: 8, setNumber: 2),
            WorkoutSet(exerciseId: exerciseId, weight: 110, reps: 6, setNumber: 3)
        ]

        // When
        let workout = try await useCase.execute(sets: sets)

        // Then
        XCTAssertEqual(workout.sets[0].weight, 100)
        XCTAssertEqual(workout.sets[1].weight, 105)
        XCTAssertEqual(workout.sets[2].weight, 110)
    }
}
