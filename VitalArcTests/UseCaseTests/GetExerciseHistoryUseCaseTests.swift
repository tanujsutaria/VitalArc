//
//  GetExerciseHistoryUseCaseTests.swift
//  VitalArcTests
//
//  Tests for GetExerciseHistoryUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class GetExerciseHistoryUseCaseTests: XCTestCase {
    var repository: MockWorkoutRepository!
    var useCase: GetExerciseHistoryUseCase!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
        useCase = GetExerciseHistoryUseCase(workoutRepository: repository)
    }

    override func tearDown() async throws {
        repository = nil
        useCase = nil
    }

    // MARK: - Happy Path

    func testExerciseHistoryReturnsPointsSortedByDate() async throws {
        let exerciseId = UUID()
        let date1 = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let date2 = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let date3 = Date()

        repository.mockWorkouts = [
            Workout(date: date2, sets: [
                WorkoutSet(exerciseId: exerciseId, weight: 80, reps: 8, setNumber: 1)
            ]),
            Workout(date: date1, sets: [
                WorkoutSet(exerciseId: exerciseId, weight: 70, reps: 10, setNumber: 1)
            ]),
            Workout(date: date3, sets: [
                WorkoutSet(exerciseId: exerciseId, weight: 90, reps: 6, setNumber: 1)
            ])
        ]

        let history = try await useCase.execute(exerciseId: exerciseId)

        XCTAssertEqual(history.count, 3)
        XCTAssertTrue(history[0].date < history[1].date)
        XCTAssertTrue(history[1].date < history[2].date)
    }

    func testExerciseHistoryFiltersCorrectExercise() async throws {
        let targetId = UUID()
        let otherId = UUID()

        repository.mockWorkouts = [
            Workout(date: Date(), sets: [
                WorkoutSet(exerciseId: targetId, weight: 100, reps: 5, setNumber: 1),
                WorkoutSet(exerciseId: otherId, weight: 50, reps: 12, setNumber: 2)
            ])
        ]

        let history = try await useCase.execute(exerciseId: targetId)

        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.maxWeight, 100)
    }

    func testExerciseHistoryCalculatesMaxWeight() async throws {
        let exerciseId = UUID()

        repository.mockWorkouts = [
            Workout(date: Date(), sets: [
                WorkoutSet(exerciseId: exerciseId, weight: 80, reps: 10, setNumber: 1),
                WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 5, setNumber: 2),
                WorkoutSet(exerciseId: exerciseId, weight: 90, reps: 8, setNumber: 3)
            ])
        ]

        let history = try await useCase.execute(exerciseId: exerciseId)

        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.maxWeight, 100)
    }

    func testExerciseHistoryCalculatesTotalVolume() async throws {
        let exerciseId = UUID()

        repository.mockWorkouts = [
            Workout(date: Date(), sets: [
                WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1), // 1000
                WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 8, setNumber: 2),  // 800
                WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 6, setNumber: 3)   // 600
            ])
        ]

        let history = try await useCase.execute(exerciseId: exerciseId)

        XCTAssertEqual(history.first?.totalVolume, 2400)
    }

    func testExerciseHistoryCalculatesEstimated1RM() async throws {
        let exerciseId = UUID()

        repository.mockWorkouts = [
            Workout(date: Date(), sets: [
                WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1)
            ])
        ]

        let history = try await useCase.execute(exerciseId: exerciseId)

        // Epley formula: 100 * (1 + 10/30) = 100 * 1.333... = 133.33...
        XCTAssertEqual(history.first?.estimated1RM ?? 0, 100 * (1 + 10.0 / 30.0), accuracy: 0.01)
    }

    func testEmptyHistoryForUnusedExercise() async throws {
        let exerciseId = UUID()
        let otherId = UUID()

        repository.mockWorkouts = [
            Workout(date: Date(), sets: [
                WorkoutSet(exerciseId: otherId, weight: 50, reps: 12, setNumber: 1)
            ])
        ]

        let history = try await useCase.execute(exerciseId: exerciseId)

        XCTAssertTrue(history.isEmpty)
    }

    func testEmptyHistoryWithNoWorkouts() async throws {
        let exerciseId = UUID()

        let history = try await useCase.execute(exerciseId: exerciseId)

        XCTAssertTrue(history.isEmpty)
    }

    func testOnlyCompletedSetsAreIncluded() async throws {
        let exerciseId = UUID()

        repository.mockWorkouts = [
            Workout(date: Date(), sets: [
                WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1, completed: true),
                WorkoutSet(exerciseId: exerciseId, weight: 120, reps: 5, setNumber: 2, completed: false)
            ])
        ]

        let history = try await useCase.execute(exerciseId: exerciseId)

        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.maxWeight, 100)
    }

    func testSingleRepSetEstimated1RMEqualsWeight() async throws {
        let exerciseId = UUID()

        repository.mockWorkouts = [
            Workout(date: Date(), sets: [
                WorkoutSet(exerciseId: exerciseId, weight: 150, reps: 1, setNumber: 1)
            ])
        ]

        let history = try await useCase.execute(exerciseId: exerciseId)

        XCTAssertEqual(history.first?.estimated1RM, 150)
    }
}
