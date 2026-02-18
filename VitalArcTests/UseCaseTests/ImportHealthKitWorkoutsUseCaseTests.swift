//
//  ImportHealthKitWorkoutsUseCaseTests.swift
//  VitalArcTests
//
//  Tests for ImportHealthKitWorkoutsUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class ImportHealthKitWorkoutsUseCaseTests: XCTestCase {
    var repository: MockWorkoutRepository!
    var importSource: MockWorkoutImportSource!
    var useCase: ImportHealthKitWorkoutsUseCase!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
        importSource = MockWorkoutImportSource()
        useCase = ImportHealthKitWorkoutsUseCase(repository: repository, importSource: importSource)
    }

    override func tearDown() async throws {
        repository = nil
        importSource = nil
        useCase = nil
    }

    // MARK: - Test Helpers

    private func makeImportedWorkout(
        healthKitId: String = UUID().uuidString,
        startDate: Date = Date(),
        activityName: String = "Running",
        duration: TimeInterval = 3600
    ) -> ImportedWorkoutData {
        ImportedWorkoutData(
            healthKitId: healthKitId,
            startDate: startDate,
            activityName: activityName,
            duration: duration
        )
    }

    // MARK: - Happy Path Tests

    func testImportNewWorkoutsSuccessfully() async throws {
        // Given
        importSource.mockWorkouts = [
            makeImportedWorkout(activityName: "Running"),
            makeImportedWorkout(activityName: "Cycling")
        ]

        // When
        let count = try await useCase.execute(
            from: Date().addingTimeInterval(-86400),
            to: Date()
        )

        // Then
        XCTAssertEqual(count, 2)
        XCTAssertEqual(repository.savedWorkouts.count, 2)
    }

    func testSkipsDuplicateWorkouts() async throws {
        // Given - One already imported workout
        let existingId = "existing-hk-id"
        let existingWorkout = Workout(
            healthKitId: existingId
        )
        repository.mockWorkouts = [existingWorkout]

        importSource.mockWorkouts = [
            makeImportedWorkout(healthKitId: existingId),
            makeImportedWorkout(healthKitId: "new-id-1"),
            makeImportedWorkout(healthKitId: "new-id-2")
        ]

        // When
        let count = try await useCase.execute(
            from: Date().addingTimeInterval(-86400),
            to: Date()
        )

        // Then - Only 2 new ones imported
        XCTAssertEqual(count, 2)
    }

    func testAllDuplicatesReturnsZero() async throws {
        // Given - All already imported
        let id1 = "existing-1"
        let id2 = "existing-2"
        repository.mockWorkouts = [
            Workout(healthKitId: id1),
            Workout(healthKitId: id2)
        ]

        importSource.mockWorkouts = [
            makeImportedWorkout(healthKitId: id1),
            makeImportedWorkout(healthKitId: id2)
        ]

        // When
        let count = try await useCase.execute(
            from: Date().addingTimeInterval(-86400),
            to: Date()
        )

        // Then
        XCTAssertEqual(count, 0)
    }

    func testEmptyHealthKitResults() async throws {
        // Given - No workouts from source
        importSource.mockWorkouts = []

        // When
        let count = try await useCase.execute(
            from: Date().addingTimeInterval(-86400),
            to: Date()
        )

        // Then
        XCTAssertEqual(count, 0)
        XCTAssertEqual(repository.savedWorkouts.count, 0)
    }

    // MARK: - Error Tests

    func testThrowsOnFetchError() async throws {
        // Given
        importSource.shouldThrow = true

        // When/Then
        do {
            _ = try await useCase.execute(
                from: Date().addingTimeInterval(-86400),
                to: Date()
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockWorkoutImportSource.MockError)
        }
    }

    func testThrowsOnRepositorySaveError() async throws {
        // Given
        importSource.mockWorkouts = [makeImportedWorkout()]
        repository.shouldThrowOnSave = true

        // When/Then
        do {
            _ = try await useCase.execute(
                from: Date().addingTimeInterval(-86400),
                to: Date()
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockWorkoutRepository.MockError)
        }
    }

    // MARK: - Parameter Tests

    func testPassesCorrectDateRangeToSource() async throws {
        // Given
        let startDate = Date().addingTimeInterval(-172800) // 2 days ago
        let endDate = Date()
        importSource.mockWorkouts = []

        // When
        _ = try await useCase.execute(from: startDate, to: endDate)

        // Then
        XCTAssertEqual(importSource.fetchCallCount, 1)
        XCTAssertEqual(importSource.lastStartDate, startDate)
        XCTAssertEqual(importSource.lastEndDate, endDate)
    }

    func testImportedWorkoutHasCorrectProperties() async throws {
        // Given
        let startDate = Date().addingTimeInterval(-3600)
        importSource.mockWorkouts = [
            ImportedWorkoutData(
                healthKitId: "test-hk-id",
                startDate: startDate,
                activityName: "Weight Training",
                duration: 3600
            )
        ]

        // When
        _ = try await useCase.execute(
            from: Date().addingTimeInterval(-86400),
            to: Date()
        )

        // Then
        let savedWorkout = repository.savedWorkouts.first
        XCTAssertNotNil(savedWorkout)
        XCTAssertEqual(savedWorkout?.healthKitId, "test-hk-id")
        XCTAssertEqual(savedWorkout?.source, .healthKit)
        XCTAssertEqual(savedWorkout?.name, "Weight Training")
        XCTAssertEqual(savedWorkout?.duration, 3600)
        XCTAssertEqual(savedWorkout?.date, startDate)
        XCTAssertEqual(savedWorkout?.sets.count, 0)
    }
}
