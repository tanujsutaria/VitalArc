//
//  GetExercisesUseCaseTests.swift
//  VitalArcTests
//
//  Unit tests for GetExercisesUseCase
//

import XCTest
@testable import VitalArc

@MainActor
final class GetExercisesUseCaseTests: XCTestCase {

    var mockRepository: MockWorkoutRepository!
    var useCase: GetExercisesUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockWorkoutRepository()
        useCase = GetExercisesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: - Test Data

    private func createSampleExercises() -> [Exercise] {
        [
            Exercise(
                name: "Bench Press",
                category: .push,
                primaryMuscles: [.chest],
                secondaryMuscles: [.triceps, .shoulders],
                equipment: .barbell
            ),
            Exercise(
                name: "Overhead Press",
                category: .push,
                primaryMuscles: [.shoulders],
                secondaryMuscles: [.triceps],
                equipment: .barbell
            ),
            Exercise(
                name: "Squat",
                category: .legs,
                primaryMuscles: [.quadriceps],
                secondaryMuscles: [.glutes, .hamstrings],
                equipment: .barbell
            ),
            Exercise(
                name: "Deadlift",
                category: .pull,
                primaryMuscles: [.back, .hamstrings],
                secondaryMuscles: [.glutes, .forearms],
                equipment: .barbell
            ),
            Exercise(
                name: "Pull Up",
                category: .pull,
                primaryMuscles: [.lats],
                secondaryMuscles: [.biceps],
                equipment: .bodyweight
            ),
            Exercise(
                name: "Plank",
                category: .core,
                primaryMuscles: [.abs],
                secondaryMuscles: [.obliques, .shoulders],
                equipment: .bodyweight
            )
        ]
    }

    // MARK: - No Filters

    func testReturnsAllExercisesWhenNoFilters() async throws {
        let exercises = createSampleExercises()
        mockRepository.mockExercises = exercises

        let result = try await useCase.execute()

        XCTAssertEqual(result.count, exercises.count)
    }

    // MARK: - Category Filter

    func testFiltersByCategoryOnly() async throws {
        mockRepository.mockExercises = createSampleExercises()

        let result = try await useCase.execute(category: .push)

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.category == .push })
    }

    func testCategoryFilterReturnsEmptyWhenNoMatch() async throws {
        mockRepository.mockExercises = createSampleExercises()

        let result = try await useCase.execute(category: .cardio)

        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Muscle Group Filter

    func testFiltersByMuscleGroupPrimaryMatch() async throws {
        mockRepository.mockExercises = createSampleExercises()

        let result = try await useCase.execute(muscleGroup: .chest)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Bench Press")
    }

    func testFiltersByMuscleGroupSecondaryMatch() async throws {
        mockRepository.mockExercises = createSampleExercises()

        let result = try await useCase.execute(muscleGroup: .biceps)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Pull Up")
    }

    func testFiltersByMuscleGroupMatchesBothPrimaryAndSecondary() async throws {
        mockRepository.mockExercises = createSampleExercises()

        // shoulders is primary for Overhead Press, secondary for Bench Press and Plank
        let result = try await useCase.execute(muscleGroup: .shoulders)

        XCTAssertEqual(result.count, 3)
        let names = Set(result.map { $0.name })
        XCTAssertTrue(names.contains("Overhead Press"))
        XCTAssertTrue(names.contains("Bench Press"))
        XCTAssertTrue(names.contains("Plank"))
    }

    func testMuscleGroupFilterReturnsEmptyWhenNoMatch() async throws {
        mockRepository.mockExercises = createSampleExercises()

        let result = try await useCase.execute(muscleGroup: .calves)

        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Search Query

    func testSearchQueryUsesSearchExercises() async throws {
        mockRepository.mockExercises = createSampleExercises()

        _ = try await useCase.execute(searchQuery: "Bench")

        XCTAssertEqual(mockRepository.searchQueries.count, 1)
        XCTAssertEqual(mockRepository.searchQueries.first, "Bench")
    }

    func testEmptySearchQueryUsesGetExercises() async throws {
        mockRepository.mockExercises = createSampleExercises()

        let result = try await useCase.execute(searchQuery: "")

        XCTAssertTrue(mockRepository.searchQueries.isEmpty)
        XCTAssertEqual(result.count, createSampleExercises().count)
    }

    // MARK: - Combined Filters

    func testCombinedCategoryAndMuscleGroupFilter() async throws {
        mockRepository.mockExercises = createSampleExercises()

        let result = try await useCase.execute(category: .pull, muscleGroup: .hamstrings)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Deadlift")
    }

    func testCombinedSearchAndCategoryFilter() async throws {
        mockRepository.mockExercises = createSampleExercises()

        let result = try await useCase.execute(category: .push, searchQuery: "Press")

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.category == .push })
    }

    func testAllThreeFiltersCombined() async throws {
        mockRepository.mockExercises = createSampleExercises()

        let result = try await useCase.execute(
            category: .push,
            muscleGroup: .chest,
            searchQuery: "Press"
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Bench Press")
    }

    // MARK: - Error Handling

    func testThrowsWhenRepositoryGetFails() async {
        mockRepository.shouldThrowOnGet = true

        do {
            _ = try await useCase.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockWorkoutRepository.MockError)
        }
    }

    func testThrowsWhenRepositorySearchFails() async {
        mockRepository.shouldThrowOnSearch = true

        do {
            _ = try await useCase.execute(searchQuery: "Bench")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is MockWorkoutRepository.MockError)
        }
    }
}
