//
//  ExerciseLibraryViewModelTests.swift
//  VitalArcTests
//
//  Unit tests for ExerciseLibraryViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class ExerciseLibraryViewModelTests: XCTestCase {

    var mockRepository: MockWorkoutRepository!
    var getExercisesUseCase: GetExercisesUseCase!
    var viewModel: ExerciseLibraryViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockWorkoutRepository()
        getExercisesUseCase = GetExercisesUseCase(repository: mockRepository)
        viewModel = ExerciseLibraryViewModel(getExercisesUseCase: getExercisesUseCase)
    }

    override func tearDown() {
        mockRepository = nil
        getExercisesUseCase = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialStateIsEmpty() {
        XCTAssertTrue(viewModel.exercises.isEmpty)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedCategory)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Load Exercises Tests

    func testLoadExercisesSuccess() async {
        // Setup
        let sampleExercises = createSampleExercises()
        mockRepository.mockExercises = sampleExercises

        // Execute
        await viewModel.loadExercises()

        // Verify
        XCTAssertEqual(viewModel.exercises.count, sampleExercises.count)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadExercisesSetsLoadingState() async {
        mockRepository.mockExercises = createSampleExercises()

        // Verify initial state
        XCTAssertFalse(viewModel.isLoading)

        // Execute
        await viewModel.loadExercises()

        // After completion, loading should be false
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadExercisesError() async {
        // Setup
        mockRepository.shouldThrowOnGet = true

        // Execute
        await viewModel.loadExercises()

        // Verify
        XCTAssertTrue(viewModel.exercises.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Category Selection Tests

    func testSelectCategoryFiltersExercises() async {
        // Setup
        mockRepository.mockExercises = createSampleExercises()

        // Execute
        await viewModel.selectCategory(.push)

        // Verify
        XCTAssertEqual(viewModel.selectedCategory, .push)
        XCTAssertTrue(viewModel.exercises.allSatisfy { $0.category == .push })
    }

    func testSelectNilCategoryClearsFilter() async {
        // Setup
        mockRepository.mockExercises = createSampleExercises()
        viewModel.selectedCategory = .push

        // Execute
        await viewModel.selectCategory(nil)

        // Verify
        XCTAssertNil(viewModel.selectedCategory)
        XCTAssertEqual(viewModel.exercises.count, mockRepository.mockExercises.count)
    }

    func testSelectCategoryTriggersReload() async {
        // Setup
        mockRepository.mockExercises = createSampleExercises()

        // Execute multiple category changes
        await viewModel.selectCategory(.pull)
        let pullExercises = viewModel.exercises

        await viewModel.selectCategory(.legs)
        let legExercises = viewModel.exercises

        // Verify different results
        XCTAssertNotEqual(pullExercises.map { $0.id }, legExercises.map { $0.id })
    }

    // MARK: - Search Tests

    func testUpdateSearchWithText() async {
        // Setup
        mockRepository.mockExercises = createSampleExercises()

        // Execute
        await viewModel.updateSearch("Bench")

        // Verify
        XCTAssertEqual(viewModel.searchText, "Bench")
        XCTAssertTrue(viewModel.exercises.allSatisfy { $0.name.lowercased().contains("bench") })
    }

    func testUpdateSearchWithEmptyText() async {
        // Setup
        mockRepository.mockExercises = createSampleExercises()
        viewModel.searchText = "Bench"

        // Execute
        await viewModel.updateSearch("")

        // Verify
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.exercises.count, mockRepository.mockExercises.count)
    }

    func testSearchAndCategoryTogether() async {
        // Setup
        mockRepository.mockExercises = createSampleExercises()

        // Execute
        await viewModel.selectCategory(.pull)
        await viewModel.updateSearch("Pull")

        // Verify - should find "Pull Up" which is in pull category
        XCTAssertEqual(viewModel.selectedCategory, .pull)
        XCTAssertEqual(viewModel.searchText, "Pull")
        XCTAssertTrue(viewModel.exercises.allSatisfy {
            $0.category == .pull && $0.name.lowercased().contains("pull")
        })
    }

    // MARK: - Helper Methods

    private func createSampleExercises() -> [Exercise] {
        [
            Exercise(
                name: "Bench Press",
                category: .push,
                primaryMuscles: [.chest],
                secondaryMuscles: [.triceps],
                equipment: .barbell,
                instructions: "Press"
            ),
            Exercise(
                name: "Squat",
                category: .legs,
                primaryMuscles: [.quadriceps],
                secondaryMuscles: [.glutes],
                equipment: .barbell,
                instructions: "Squat"
            ),
            Exercise(
                name: "Deadlift",
                category: .pull,
                primaryMuscles: [.back],
                secondaryMuscles: [.hamstrings],
                equipment: .barbell,
                instructions: "Lift"
            ),
            Exercise(
                name: "Pull Up",
                category: .pull,
                primaryMuscles: [.back],
                secondaryMuscles: [.biceps],
                equipment: .bodyweight,
                instructions: "Pull"
            )
        ]
    }
}
