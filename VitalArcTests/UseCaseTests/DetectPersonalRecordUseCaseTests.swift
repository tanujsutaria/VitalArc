//
//  DetectPersonalRecordUseCaseTests.swift
//  VitalArcTests
//
//  Tests for DetectPersonalRecordUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class DetectPersonalRecordUseCaseTests: XCTestCase {
    var workoutRepository: MockWorkoutRepository!
    var analyticsRepository: MockAnalyticsRepository!
    var useCase: DetectPersonalRecordUseCase!

    override func setUp() async throws {
        workoutRepository = MockWorkoutRepository()
        analyticsRepository = MockAnalyticsRepository()
        useCase = DetectPersonalRecordUseCase(
            workoutRepository: workoutRepository,
            analyticsRepository: analyticsRepository
        )
    }

    override func tearDown() async throws {
        workoutRepository = nil
        analyticsRepository = nil
        useCase = nil
    }

    // MARK: - Test Helpers

    private let benchId = UUID()
    private let squatId = UUID()

    private func makeSet(
        exerciseId: UUID? = nil,
        weight: Double,
        reps: Int,
        setNumber: Int = 1,
        completed: Bool = true
    ) -> WorkoutSet {
        WorkoutSet(
            exerciseId: exerciseId ?? benchId,
            weight: weight,
            reps: reps,
            setNumber: setNumber,
            completed: completed
        )
    }

    private func seedExercise(id: UUID, name: String) {
        let exercise = Exercise(
            id: id,
            name: name,
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .barbell,
            isCustom: false
        )
        workoutRepository.mockExercises.append(exercise)
    }

    // MARK: - One Rep Max Tests

    func testDetectsNewOneRepMax() async throws {
        // Given - Bench press: 100kg x 10 reps → Epley 1RM = 100 * (1 + 10/30) = 133.33
        seedExercise(id: benchId, name: "Bench Press")
        let sets = [makeSet(weight: 100, reps: 10)]

        // When
        let records = try await useCase.execute(sets: sets)

        // Then
        let oneRMRecord = records.first { $0.recordType == .oneRepMax }
        XCTAssertNotNil(oneRMRecord)
        XCTAssertEqual(oneRMRecord?.value ?? 0, 133.33, accuracy: 0.1)
        XCTAssertEqual(oneRMRecord?.exerciseName, "Bench Press")
    }

    func testDoesNotDetect1RMBelowExisting() async throws {
        // Given - Existing PR of 150
        seedExercise(id: benchId, name: "Bench Press")
        analyticsRepository.mockPersonalRecords = [
            PersonalRecord(
                exerciseId: benchId,
                exerciseName: "Bench Press",
                recordType: .oneRepMax,
                value: 150,
                date: Date().addingTimeInterval(-86400)
            )
        ]

        // 100kg x 5 → Epley = 100 * (1 + 5/30) = 116.67 (below 150)
        let sets = [makeSet(weight: 100, reps: 5)]

        // When
        let records = try await useCase.execute(sets: sets)

        // Then - No 1RM PR detected
        let oneRMRecords = records.filter { $0.recordType == .oneRepMax }
        XCTAssertTrue(oneRMRecords.isEmpty)
    }

    // MARK: - Max Volume Tests

    func testDetectsNewMaxVolume() async throws {
        // Given - 3 sets: 100kg x 10, 100kg x 8, 100kg x 6 = total volume 2400
        seedExercise(id: benchId, name: "Bench Press")
        let sets = [
            makeSet(weight: 100, reps: 10, setNumber: 1),
            makeSet(weight: 100, reps: 8, setNumber: 2),
            makeSet(weight: 100, reps: 6, setNumber: 3)
        ]

        // When
        let records = try await useCase.execute(sets: sets)

        // Then
        let volumeRecord = records.first { $0.recordType == .maxVolume }
        XCTAssertNotNil(volumeRecord)
        XCTAssertEqual(volumeRecord?.value ?? 0, 2400, accuracy: 0.1)
    }

    // MARK: - Max Reps Tests

    func testDetectsNewMaxReps() async throws {
        // Given
        seedExercise(id: benchId, name: "Bench Press")
        let sets = [
            makeSet(weight: 60, reps: 15, setNumber: 1),
            makeSet(weight: 60, reps: 12, setNumber: 2)
        ]

        // When
        let records = try await useCase.execute(sets: sets)

        // Then
        let repsRecord = records.first { $0.recordType == .maxReps }
        XCTAssertNotNil(repsRecord)
        XCTAssertEqual(repsRecord?.reps, 15)
    }

    // MARK: - Multiple PR Types

    func testDetectsMultiplePRTypesSimultaneously() async throws {
        // Given - New exercise, no existing PRs → all 3 types should fire
        seedExercise(id: benchId, name: "Bench Press")
        let sets = [
            makeSet(weight: 100, reps: 10, setNumber: 1),
            makeSet(weight: 80, reps: 12, setNumber: 2)
        ]

        // When
        let records = try await useCase.execute(sets: sets)

        // Then
        let types = Set(records.map { $0.recordType })
        XCTAssertTrue(types.contains(.oneRepMax))
        XCTAssertTrue(types.contains(.maxVolume))
        XCTAssertTrue(types.contains(.maxReps))
    }

    func testDetectsPRsAcrossMultipleExercises() async throws {
        // Given
        seedExercise(id: benchId, name: "Bench Press")
        seedExercise(id: squatId, name: "Squat")

        let sets = [
            makeSet(exerciseId: benchId, weight: 100, reps: 10, setNumber: 1),
            makeSet(exerciseId: squatId, weight: 140, reps: 5, setNumber: 1)
        ]

        // When
        let records = try await useCase.execute(sets: sets)

        // Then - Should have PRs for both exercises
        let benchRecords = records.filter { $0.exerciseId == benchId }
        let squatRecords = records.filter { $0.exerciseId == squatId }
        XCTAssertFalse(benchRecords.isEmpty)
        XCTAssertFalse(squatRecords.isEmpty)
    }

    // MARK: - Edge Cases

    func testEmptySetsReturnsNoPRs() async throws {
        // When
        let records = try await useCase.execute(sets: [])

        // Then
        XCTAssertTrue(records.isEmpty)
    }

    func testZeroWeightSetsAreSkipped() async throws {
        // Given
        seedExercise(id: benchId, name: "Bench Press")
        let sets = [makeSet(weight: 0, reps: 10)]

        // When
        let records = try await useCase.execute(sets: sets)

        // Then - Zero weight should be filtered out
        XCTAssertTrue(records.isEmpty)
    }

    func testZeroRepsSetsAreSkipped() async throws {
        // Given
        seedExercise(id: benchId, name: "Bench Press")
        let sets = [makeSet(weight: 100, reps: 0)]

        // When
        let records = try await useCase.execute(sets: sets)

        // Then - Zero reps should be filtered out
        XCTAssertTrue(records.isEmpty)
    }

    func testPRsAreSavedToAnalyticsRepository() async throws {
        // Given
        seedExercise(id: benchId, name: "Bench Press")
        let sets = [makeSet(weight: 100, reps: 10)]

        // When
        let records = try await useCase.execute(sets: sets)

        // Then
        XCTAssertFalse(records.isEmpty)
        XCTAssertEqual(analyticsRepository.savedPersonalRecords.count, records.count)
    }

    func testUnknownExerciseUsesDefaultName() async throws {
        // Given - Exercise NOT in repository
        let unknownId = UUID()
        let sets = [makeSet(exerciseId: unknownId, weight: 100, reps: 5)]

        // When
        let records = try await useCase.execute(sets: sets)

        // Then
        let record = records.first
        XCTAssertNotNil(record)
        XCTAssertEqual(record?.exerciseName, "Unknown Exercise")
    }

    func testIncompleteSetIsSkipped() async throws {
        // Given
        seedExercise(id: benchId, name: "Bench Press")
        let sets = [makeSet(weight: 100, reps: 10, completed: false)]

        // When
        let records = try await useCase.execute(sets: sets)

        // Then
        XCTAssertTrue(records.isEmpty)
    }
}
