//
//  CalculateOneRepMaxUseCaseTests.swift
//  VitalArcTests
//
//  Tests for CalculateOneRepMaxUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class CalculateOneRepMaxUseCaseTests: XCTestCase {
    var analyticsRepository: MockAnalyticsRepository!
    var useCase: CalculateOneRepMaxUseCase!

    override func setUp() async throws {
        analyticsRepository = MockAnalyticsRepository()
        useCase = CalculateOneRepMaxUseCase(analyticsRepository: analyticsRepository)
    }

    override func tearDown() async throws {
        analyticsRepository = nil
        useCase = nil
    }

    // MARK: - Epley Formula Tests

    func testEpleyStandard() {
        // 100kg x 10 reps = 100 * (1 + 10/30) = 100 * 1.333 = 133.33
        let result = CalculateOneRepMaxUseCase.estimate(weight: 100, reps: 10)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 133.33, accuracy: 0.01)
    }

    func testOneRepReturnsWeight() {
        // 1 rep = actual weight (no estimation needed)
        let result = CalculateOneRepMaxUseCase.estimate(weight: 150, reps: 1)
        XCTAssertEqual(result, 150)
    }

    func testZeroWeightReturnsNil() {
        let result = CalculateOneRepMaxUseCase.estimate(weight: 0, reps: 10)
        XCTAssertNil(result)
    }

    func testNegativeWeightReturnsNil() {
        let result = CalculateOneRepMaxUseCase.estimate(weight: -50, reps: 10)
        XCTAssertNil(result)
    }

    func testZeroRepsReturnsNil() {
        let result = CalculateOneRepMaxUseCase.estimate(weight: 100, reps: 0)
        XCTAssertNil(result)
    }

    func testNegativeRepsReturnsNil() {
        let result = CalculateOneRepMaxUseCase.estimate(weight: 100, reps: -5)
        XCTAssertNil(result)
    }

    func testHighReps() {
        // 60kg x 20 reps = 60 * (1 + 20/30) = 60 * 1.667 = 100.0
        let result = CalculateOneRepMaxUseCase.estimate(weight: 60, reps: 20)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 100.0, accuracy: 0.01)
    }

    func testDecimalWeight() {
        // 82.5kg x 5 reps = 82.5 * (1 + 5/30) = 82.5 * 1.1667 = 96.25
        let result = CalculateOneRepMaxUseCase.estimate(weight: 82.5, reps: 5)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 96.25, accuracy: 0.01)
    }

    func testTwoReps() {
        // 140kg x 2 reps = 140 * (1 + 2/30) = 140 * 1.0667 = 149.33
        let result = CalculateOneRepMaxUseCase.estimate(weight: 140, reps: 2)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 149.33, accuracy: 0.01)
    }

    func testThreeReps() {
        // 120kg x 3 reps = 120 * (1 + 3/30) = 120 * 1.1 = 132.0
        let result = CalculateOneRepMaxUseCase.estimate(weight: 120, reps: 3)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 132.0, accuracy: 0.01)
    }

    // MARK: - Historical Best Tests

    func testGetHistoricalBestWithRecords() async {
        // Given
        let exerciseId = UUID()
        analyticsRepository.mockPersonalRecords = [
            PersonalRecord(exerciseId: exerciseId, exerciseName: "Bench Press", recordType: .oneRepMax, value: 120, date: Date()),
            PersonalRecord(exerciseId: exerciseId, exerciseName: "Bench Press", recordType: .oneRepMax, value: 130, date: Date()),
            PersonalRecord(exerciseId: exerciseId, exerciseName: "Bench Press", recordType: .fiveRepMax, value: 110, date: Date()),
        ]

        // When
        let best = await useCase.getHistoricalBest(for: exerciseId)

        // Then - Should return highest oneRepMax (130), not the fiveRepMax
        XCTAssertEqual(best, 130)
    }

    func testGetHistoricalBestWithNoRecords() async {
        // Given - Empty repository
        let exerciseId = UUID()

        // When
        let best = await useCase.getHistoricalBest(for: exerciseId)

        // Then
        XCTAssertNil(best)
    }

    func testGetHistoricalBestWithOnlyNonOneRMRecords() async {
        // Given - Only non-1RM records exist
        let exerciseId = UUID()
        analyticsRepository.mockPersonalRecords = [
            PersonalRecord(exerciseId: exerciseId, exerciseName: "Squat", recordType: .fiveRepMax, value: 150, date: Date()),
            PersonalRecord(exerciseId: exerciseId, exerciseName: "Squat", recordType: .maxVolume, value: 5000, date: Date()),
        ]

        // When
        let best = await useCase.getHistoricalBest(for: exerciseId)

        // Then - No oneRepMax records exist
        XCTAssertNil(best)
    }

    func testGetHistoricalBestWithRepositoryError() async {
        // Given
        analyticsRepository.shouldThrowOnGet = true
        let exerciseId = UUID()

        // When
        let best = await useCase.getHistoricalBest(for: exerciseId)

        // Then - Should return nil on error
        XCTAssertNil(best)
    }
}
