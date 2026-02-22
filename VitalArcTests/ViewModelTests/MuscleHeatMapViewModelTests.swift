//
//  MuscleHeatMapViewModelTests.swift
//  VitalArcTests
//
//  Unit tests for MuscleHeatMapViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class MuscleHeatMapViewModelTests: XCTestCase {

    var mockRepository: MockWorkoutRepository!
    var viewModel: MuscleHeatMapViewModel!

    // MARK: - Test Data

    let benchPressId = UUID()
    let squatId = UUID()
    let curlId = UUID()
    let deadliftId = UUID()

    override func setUp() {
        super.setUp()
        mockRepository = MockWorkoutRepository()
        viewModel = MuscleHeatMapViewModel(workoutDataProvider: mockRepository)
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
                primaryMuscles: [.chest, .triceps],
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
                id: deadliftId,
                name: "Deadlift",
                category: .pull,
                primaryMuscles: [.hamstrings, .lowerBack, .glutes],
                equipment: .barbell
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

    // MARK: - Intensity Calculation Tests

    func testIntensityNone() {
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 0), .none)
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 0.5), .none)
    }

    func testIntensityVeryLow() {
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 1), .veryLow)
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 3), .veryLow)
    }

    func testIntensityLow() {
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 4), .low)
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 7), .low)
    }

    func testIntensityModerate() {
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 8), .moderate)
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 11), .moderate)
    }

    func testIntensityHigh() {
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 12), .high)
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 15), .high)
    }

    func testIntensityVeryHigh() {
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 16), .veryHigh)
        XCTAssertEqual(MuscleHeatMapViewModel.calculateIntensity(weeklySets: 30), .veryHigh)
    }

    // MARK: - Muscle Group Mapping Tests

    func testMuscleGroupMappingFromExercises() async throws {
        let today = Date()
        mockRepository.mockWorkouts = [
            makeWorkout(date: today, exerciseId: benchPressId, sets: 4)
        ]

        let data = try await viewModel.buildMuscleData(from: mockRepository.mockWorkouts, weeks: 1)

        // Bench press targets chest and triceps
        let muscleNames = Set(data.map { $0.muscleGroup })
        XCTAssertTrue(muscleNames.contains(.chest))
        XCTAssertTrue(muscleNames.contains(.triceps))
    }

    func testMultipleExercisesMappedToSameMuscle() async throws {
        // Both bench press (chest, triceps) and squat (quads, glutes) - no overlap
        let today = Date()
        mockRepository.mockWorkouts = [
            makeWorkout(date: today, exerciseId: benchPressId, sets: 3),
            makeWorkout(date: today, exerciseId: squatId, sets: 4)
        ]

        let data = try await viewModel.buildMuscleData(from: mockRepository.mockWorkouts, weeks: 1)

        let chestData = data.first { $0.muscleGroup == .chest }
        XCTAssertEqual(chestData?.totalSets, 3)

        let quadData = data.first { $0.muscleGroup == .quadriceps }
        XCTAssertEqual(quadData?.totalSets, 4)
    }

    // MARK: - Training Frequency Tests

    func testSessionCountPerMuscle() async throws {
        let calendar = Calendar.current
        let today = Date()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        // Two separate workouts training chest
        mockRepository.mockWorkouts = [
            makeWorkout(date: today, exerciseId: benchPressId, sets: 3),
            makeWorkout(date: twoDaysAgo, exerciseId: benchPressId, sets: 4)
        ]

        let data = try await viewModel.buildMuscleData(from: mockRepository.mockWorkouts, weeks: 1)

        let chestData = data.first { $0.muscleGroup == .chest }
        XCTAssertEqual(chestData?.sessionCount, 2)
        XCTAssertEqual(chestData?.totalSets, 7) // 3 + 4
    }

    // MARK: - Volume Calculation Tests

    func testTotalVolumeCalculation() async throws {
        let today = Date()
        // 3 sets × 60kg × 10 reps = 1800 volume per set? No - volume = weight * reps per set
        // Each set: 60 * 10 = 600. 3 sets = 1800 total volume
        mockRepository.mockWorkouts = [
            makeWorkout(date: today, exerciseId: benchPressId, sets: 3, weight: 60, reps: 10)
        ]

        let data = try await viewModel.buildMuscleData(from: mockRepository.mockWorkouts, weeks: 1)

        let chestData = data.first { $0.muscleGroup == .chest }
        XCTAssertEqual(chestData?.totalVolume ?? 0, 1800, accuracy: 0.01)
    }

    // MARK: - Last Trained Date Tests

    func testLastTrainedDate() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: today)!

        mockRepository.mockWorkouts = [
            makeWorkout(date: fiveDaysAgo, exerciseId: benchPressId, sets: 3),
            makeWorkout(date: today, exerciseId: benchPressId, sets: 3)
        ]

        let data = try await viewModel.buildMuscleData(from: mockRepository.mockWorkouts, weeks: 1)

        let chestData = data.first { $0.muscleGroup == .chest }
        XCTAssertNotNil(chestData?.lastTrainedDate)
        // Most recent should be today
        XCTAssertEqual(calendar.startOfDay(for: chestData!.lastTrainedDate!), today)
    }

    // MARK: - Edge Cases

    func testNoWorkoutsReturnsEmptyData() async throws {
        mockRepository.mockWorkouts = []

        let data = try await viewModel.buildMuscleData(from: [], weeks: 1)
        XCTAssertTrue(data.isEmpty)
    }

    func testSingleWorkoutSingleSet() async throws {
        let today = Date()
        mockRepository.mockWorkouts = [
            makeWorkout(date: today, exerciseId: curlId, sets: 1, weight: 10, reps: 12)
        ]

        let data = try await viewModel.buildMuscleData(from: mockRepository.mockWorkouts, weeks: 1)

        let bicepsData = data.first { $0.muscleGroup == .biceps }
        XCTAssertNotNil(bicepsData)
        XCTAssertEqual(bicepsData?.totalSets, 1)
        XCTAssertEqual(bicepsData?.totalVolume ?? 0, 120, accuracy: 0.01) // 10 * 12
        XCTAssertEqual(bicepsData?.sessionCount, 1)
    }

    func testExerciseWithUnknownId() async throws {
        let unknownId = UUID()
        let today = Date()
        let sets = [
            WorkoutSet(exerciseId: unknownId, weight: 50, reps: 10, setNumber: 1)
        ]
        mockRepository.mockWorkouts = [Workout(date: today, sets: sets)]

        let data = try await viewModel.buildMuscleData(from: mockRepository.mockWorkouts, weeks: 1)

        // Unknown exercise should be ignored
        XCTAssertTrue(data.isEmpty)
    }

    // MARK: - Complete Muscle Data Tests

    func testCompleteMuscleDataFillsZeros() async throws {
        // With no workouts, completeMuscleData should have entries for all trainable muscles
        mockRepository.mockWorkouts = []
        viewModel.muscleData = []

        let complete = viewModel.completeMuscleData
        XCTAssertEqual(complete.count, MuscleHeatMapViewModel.trainableMuscleGroups.count)

        // All should be .none intensity
        for data in complete {
            XCTAssertEqual(data.intensityLevel, .none)
            XCTAssertEqual(data.totalSets, 0)
        }
    }

    func testCompleteMuscleDataPreservesTrainedValues() async throws {
        let today = Date()
        mockRepository.mockWorkouts = [
            makeWorkout(date: today, exerciseId: benchPressId, sets: 5)
        ]

        let data = try await viewModel.buildMuscleData(from: mockRepository.mockWorkouts, weeks: 1)
        viewModel.muscleData = data

        let complete = viewModel.completeMuscleData
        let chestData = complete.first { $0.muscleGroup == .chest }
        XCTAssertEqual(chestData?.totalSets, 5)
    }

    // MARK: - Exercise Names Tracking

    func testExerciseNamesTracked() async throws {
        let today = Date()
        mockRepository.mockWorkouts = [
            makeWorkout(date: today, exerciseId: benchPressId, sets: 3),
            makeWorkout(date: today, exerciseId: curlId, sets: 3)
        ]

        // Both bench press and curl hit different muscles
        let data = try await viewModel.buildMuscleData(from: mockRepository.mockWorkouts, weeks: 1)

        let chestData = data.first { $0.muscleGroup == .chest }
        XCTAssertTrue(chestData?.exercises.contains("Bench Press") ?? false)

        let bicepsData = data.first { $0.muscleGroup == .biceps }
        XCTAssertTrue(bicepsData?.exercises.contains("Bicep Curl") ?? false)
    }

    // MARK: - Deadlift Multi-Muscle Test

    func testDeadliftMapsToMultipleMuscles() async throws {
        let today = Date()
        mockRepository.mockWorkouts = [
            makeWorkout(date: today, exerciseId: deadliftId, sets: 5)
        ]

        let data = try await viewModel.buildMuscleData(from: mockRepository.mockWorkouts, weeks: 1)

        let hamstringsData = data.first { $0.muscleGroup == .hamstrings }
        let lowerBackData = data.first { $0.muscleGroup == .lowerBack }
        let glutesData = data.first { $0.muscleGroup == .glutes }

        XCTAssertEqual(hamstringsData?.totalSets, 5)
        XCTAssertEqual(lowerBackData?.totalSets, 5)
        XCTAssertEqual(glutesData?.totalSets, 5)
    }

    // MARK: - Weekly Intensity Scaling

    func testIntensityScalesWithWeeks() async throws {
        let calendar = Calendar.current
        let today = Date()

        // 16 sets spread over 4 weeks = 4 sets/week = low
        var workouts: [Workout] = []
        for weekOffset in 0..<4 {
            let date = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today)!
            workouts.append(makeWorkout(date: date, exerciseId: benchPressId, sets: 4))
        }
        mockRepository.mockWorkouts = workouts

        let data = try await viewModel.buildMuscleData(from: workouts, weeks: 4)

        let chestData = data.first { $0.muscleGroup == .chest }
        // 16 total sets / 4 weeks = 4 sets/week = low
        XCTAssertEqual(chestData?.intensityLevel, .low)
    }
}
