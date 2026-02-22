//
//  CalculateVolumeUseCaseTests.swift
//  VitalArcTests
//
//  Tests for CalculateVolumeUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class CalculateVolumeUseCaseTests: XCTestCase {
    var repository: MockWorkoutRepository!
    var useCase: CalculateVolumeUseCase!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
        useCase = CalculateVolumeUseCase(workoutDataProvider: repository)
    }

    override func tearDown() async throws {
        repository = nil
        useCase = nil
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

    private func makeTestWorkout(
        exerciseId: UUID,
        sets: [(weight: Double, reps: Int, rir: Int?)],
        date: Date = Date()
    ) -> Workout {
        let workoutSets = sets.enumerated().map { index, set in
            WorkoutSet(
                exerciseId: exerciseId,
                weight: set.weight,
                reps: set.reps,
                rir: set.rir,
                setNumber: index + 1
            )
        }
        return Workout(date: date, sets: workoutSets)
    }

    // MARK: - Happy Path Tests

    func testExecuteWithSingleWorkout() async throws {
        // Given
        let exercise = makeTestExercise()
        repository.mockExercises = [exercise]

        let workout = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [
                (weight: 100, reps: 10, rir: 2), // 1000
                (weight: 100, reps: 8, rir: 2),  // 800
                (weight: 100, reps: 6, rir: 1)   // 600
            ]
        )
        repository.mockWorkouts = [workout]

        let startDate = Date().addingTimeInterval(-86400)
        let endDate = Date().addingTimeInterval(86400)

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then
        XCTAssertEqual(metrics.totalVolume, 2400, accuracy: 0.1)
        XCTAssertEqual(metrics.workoutCount, 1)
        XCTAssertEqual(metrics.exerciseVolumes.count, 1)
    }

    func testExecuteWithMultipleExercises() async throws {
        // Given
        let benchPress = makeTestExercise(name: "Bench Press")
        let squat = makeTestExercise(name: "Squat")
        repository.mockExercises = [benchPress, squat]

        let benchSets: [WorkoutSet] = [
            WorkoutSet(exerciseId: benchPress.id, weight: 100, reps: 10, setNumber: 1), // 1000
            WorkoutSet(exerciseId: benchPress.id, weight: 100, reps: 8, setNumber: 2)   // 800
        ]
        let squatSets: [WorkoutSet] = [
            WorkoutSet(exerciseId: squat.id, weight: 150, reps: 8, setNumber: 1), // 1200
            WorkoutSet(exerciseId: squat.id, weight: 150, reps: 6, setNumber: 2)  // 900
        ]

        let workout = Workout(date: Date(), sets: benchSets + squatSets)
        repository.mockWorkouts = [workout]

        let startDate = Date().addingTimeInterval(-86400)
        let endDate = Date().addingTimeInterval(86400)

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then
        XCTAssertEqual(metrics.totalVolume, 3900, accuracy: 0.1) // 1800 + 2100
        XCTAssertEqual(metrics.exerciseVolumes.count, 2)
    }

    func testExecuteWithMultipleWorkouts() async throws {
        // Given
        let exercise = makeTestExercise()
        repository.mockExercises = [exercise]

        let workout1 = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [(weight: 100, reps: 10, rir: nil)], // 1000
            date: Date().addingTimeInterval(-86400)
        )
        let workout2 = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [(weight: 105, reps: 10, rir: nil)], // 1050
            date: Date()
        )
        repository.mockWorkouts = [workout1, workout2]

        let startDate = Date().addingTimeInterval(-86400 * 2)
        let endDate = Date().addingTimeInterval(86400)

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then
        XCTAssertEqual(metrics.totalVolume, 2050, accuracy: 0.1)
        XCTAssertEqual(metrics.workoutCount, 2)
    }

    // MARK: - Exercise Volume Breakdown Tests

    func testExerciseVolumeCalculations() async throws {
        // Given
        let exercise = makeTestExercise(name: "Bench Press")
        repository.mockExercises = [exercise]

        let workout = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [
                (weight: 100, reps: 10, rir: 3),
                (weight: 100, reps: 8, rir: 2),
                (weight: 100, reps: 6, rir: 1)
            ]
        )
        repository.mockWorkouts = [workout]

        let startDate = Date().addingTimeInterval(-86400)
        let endDate = Date().addingTimeInterval(86400)

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then
        XCTAssertEqual(metrics.exerciseVolumes.count, 1)
        let exerciseVolume = metrics.exerciseVolumes.first!

        XCTAssertEqual(exerciseVolume.exerciseId, exercise.id)
        XCTAssertEqual(exerciseVolume.exerciseName, "Bench Press")
        XCTAssertEqual(exerciseVolume.sets, 3)
        XCTAssertEqual(exerciseVolume.totalReps, 24)
        XCTAssertEqual(exerciseVolume.totalWeight, 2400, accuracy: 0.1)
        XCTAssertEqual(exerciseVolume.avgWeight, 100, accuracy: 0.1)
    }

    func testExerciseVolumeWithRIR() async throws {
        // Given
        let exercise = makeTestExercise()
        repository.mockExercises = [exercise]

        let workout = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [
                (weight: 100, reps: 10, rir: 3),
                (weight: 100, reps: 8, rir: 2),
                (weight: 100, reps: 6, rir: 1)
            ]
        )
        repository.mockWorkouts = [workout]

        let startDate = Date().addingTimeInterval(-86400)
        let endDate = Date().addingTimeInterval(86400)

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then
        let exerciseVolume = metrics.exerciseVolumes.first!
        XCTAssertNotNil(exerciseVolume.avgRIR)
        XCTAssertEqual(exerciseVolume.avgRIR!, 2.0, accuracy: 0.1) // (3+2+1)/3
    }

    // MARK: - Week-Based Tests

    func testExecuteForWeek() async throws {
        // Given
        let exercise = makeTestExercise()
        repository.mockExercises = [exercise]

        let workout = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [(weight: 100, reps: 10, rir: nil)],
            date: Date()
        )
        repository.mockWorkouts = [workout]

        // When
        let metrics = try await useCase.executeForWeek(date: Date())

        // Then
        XCTAssertNotNil(metrics)
        XCTAssertEqual(metrics.workoutCount, 1)
    }

    func testExecuteForWeeksReturnsChronological() async throws {
        // Given
        let exercise = makeTestExercise()
        repository.mockExercises = [exercise]

        // Create workouts for different weeks
        let calendar = Calendar.current
        let today = Date()
        let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: today)!

        let workout1 = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [(weight: 100, reps: 10, rir: nil)],
            date: lastWeek
        )
        let workout2 = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [(weight: 105, reps: 10, rir: nil)],
            date: today
        )
        repository.mockWorkouts = [workout1, workout2]

        // When
        let metricsArray = try await useCase.executeForWeeks(2)

        // Then - Should be in chronological order (oldest first)
        XCTAssertEqual(metricsArray.count, 2)
        XCTAssertTrue(metricsArray.first!.weekStartDate < metricsArray.last!.weekStartDate)
    }

    // MARK: - Edge Cases

    func testExecuteWithNoWorkouts() async throws {
        // Given
        repository.mockWorkouts = []

        let startDate = Date().addingTimeInterval(-86400 * 7)
        let endDate = Date()

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then
        XCTAssertEqual(metrics.totalVolume, 0)
        XCTAssertEqual(metrics.workoutCount, 0)
        XCTAssertEqual(metrics.exerciseVolumes.count, 0)
    }

    func testExecuteWithEmptyWorkout() async throws {
        // Given
        let workout = Workout(date: Date(), sets: [])
        repository.mockWorkouts = [workout]

        let startDate = Date().addingTimeInterval(-86400)
        let endDate = Date().addingTimeInterval(86400)

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then
        XCTAssertEqual(metrics.totalVolume, 0)
        XCTAssertEqual(metrics.workoutCount, 1)
        XCTAssertEqual(metrics.exerciseVolumes.count, 0)
    }

    func testExecuteWithZeroWeight() async throws {
        // Given - Bodyweight exercise
        let exercise = makeTestExercise(name: "Push-ups")
        repository.mockExercises = [exercise]

        let workout = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [
                (weight: 0, reps: 20, rir: nil),
                (weight: 0, reps: 15, rir: nil)
            ]
        )
        repository.mockWorkouts = [workout]

        let startDate = Date().addingTimeInterval(-86400)
        let endDate = Date().addingTimeInterval(86400)

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then
        XCTAssertEqual(metrics.totalVolume, 0)
        XCTAssertEqual(metrics.exerciseVolumes.first?.sets, 2)
        XCTAssertEqual(metrics.exerciseVolumes.first?.totalReps, 35)
    }

    func testExecuteFiltersWorkoutsOutsideDateRange() async throws {
        // Given
        let exercise = makeTestExercise()
        repository.mockExercises = [exercise]

        let oldWorkout = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [(weight: 100, reps: 10, rir: nil)],
            date: Date().addingTimeInterval(-86400 * 10) // 10 days ago
        )
        let recentWorkout = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [(weight: 105, reps: 10, rir: nil)],
            date: Date().addingTimeInterval(-86400) // 1 day ago
        )
        repository.mockWorkouts = [oldWorkout, recentWorkout]

        // Query last 7 days
        let startDate = Date().addingTimeInterval(-86400 * 7)
        let endDate = Date()

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then - Only recent workout should be included
        XCTAssertEqual(metrics.workoutCount, 1)
        XCTAssertEqual(metrics.totalVolume, 1050, accuracy: 0.1)
    }

    func testExerciseVolumesSortedByTotalWeight() async throws {
        // Given
        let lightExercise = makeTestExercise(name: "Lateral Raise")
        let heavyExercise = makeTestExercise(name: "Squat")
        repository.mockExercises = [lightExercise, heavyExercise]

        let lightSets = [WorkoutSet(exerciseId: lightExercise.id, weight: 10, reps: 15, setNumber: 1)]
        let heavySets = [WorkoutSet(exerciseId: heavyExercise.id, weight: 150, reps: 8, setNumber: 1)]

        let workout = Workout(date: Date(), sets: lightSets + heavySets)
        repository.mockWorkouts = [workout]

        let startDate = Date().addingTimeInterval(-86400)
        let endDate = Date().addingTimeInterval(86400)

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then - Heavy exercise should come first (sorted by volume)
        XCTAssertEqual(metrics.exerciseVolumes.first?.exerciseName, "Squat")
        XCTAssertEqual(metrics.exerciseVolumes.last?.exerciseName, "Lateral Raise")
    }

    // MARK: - Average Intensity Tests

    func testAverageIntensityCalculation() async throws {
        // Given
        let exercise = makeTestExercise()
        repository.mockExercises = [exercise]

        let workout = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [
                (weight: 100, reps: 10, rir: nil),
                (weight: 100, reps: 8, rir: nil)
            ]
        )
        repository.mockWorkouts = [workout]

        let startDate = Date().addingTimeInterval(-86400)
        let endDate = Date().addingTimeInterval(86400)

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then - avgIntensity should be calculated
        XCTAssertGreaterThan(metrics.avgIntensity, 0)
    }

    // MARK: - Unknown Exercise Handling

    func testHandlesUnknownExercise() async throws {
        // Given - Exercise not in repository
        let unknownExerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: unknownExerciseId, weight: 100, reps: 10, setNumber: 1)
        ]
        let workout = Workout(date: Date(), sets: sets)
        repository.mockWorkouts = [workout]

        let startDate = Date().addingTimeInterval(-86400)
        let endDate = Date().addingTimeInterval(86400)

        // When
        let metrics = try await useCase.execute(startDate: startDate, endDate: endDate)

        // Then - Should still calculate volume with fallback name
        XCTAssertEqual(metrics.totalVolume, 1000, accuracy: 0.1)
        XCTAssertEqual(metrics.exerciseVolumes.count, 1)
    }

    // MARK: - Week Boundary Tests

    func testExecuteForWeekHandlesWeekBoundaries() async throws {
        // Given
        let exercise = makeTestExercise()
        repository.mockExercises = [exercise]

        // Workout at the start of the week
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else {
            XCTFail("Could not determine week start")
            return
        }

        let workout = makeTestWorkout(
            exerciseId: exercise.id,
            sets: [(weight: 100, reps: 10, rir: nil)],
            date: weekStart
        )
        repository.mockWorkouts = [workout]

        // When
        let metrics = try await useCase.executeForWeek(date: Date())

        // Then
        XCTAssertEqual(metrics.weekStartDate, weekStart)
        XCTAssertEqual(metrics.workoutCount, 1)
    }
}
