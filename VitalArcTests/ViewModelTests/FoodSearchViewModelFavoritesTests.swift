//
//  FoodSearchViewModelFavoritesTests.swift
//  VitalArcTests
//
//  Tests for FoodSearchViewModel favorites and suggestions functionality
//

import XCTest
@testable import VitalArc

@MainActor
final class FoodSearchViewModelFavoritesTests: XCTestCase {

    var searchFoodUseCase: MockSearchFoodUseCase!
    var multiSourceUseCase: MockSearchMultiSourceFoodUseCase!
    var repository: MockNutritionRepository!
    var viewModel: FoodSearchViewModel!

    override func setUp() {
        super.setUp()
        searchFoodUseCase = MockSearchFoodUseCase()
        multiSourceUseCase = MockSearchMultiSourceFoodUseCase()
        repository = MockNutritionRepository()
        viewModel = FoodSearchViewModel(
            searchFoodUseCase: searchFoodUseCase,
            multiSourceUseCase: multiSourceUseCase,
            repository: repository
        )
    }

    override func tearDown() {
        searchFoodUseCase = nil
        multiSourceUseCase = nil
        repository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Test Helpers

    private func makeFavoriteFood(name: String, usageCount: Int = 0) -> Food {
        Food(
            name: name,
            servingSize: 100,
            servingUnit: "g",
            calories: 100,
            protein: 10,
            carbs: 15,
            fat: 5,
            isFavorite: true,
            usageCount: usageCount
        )
    }

    private func makeRecentFood(name: String, recentlyUsed: Date) -> Food {
        Food(
            name: name,
            servingSize: 100,
            servingUnit: "g",
            calories: 100,
            protein: 10,
            carbs: 15,
            fat: 5,
            recentlyUsed: recentlyUsed
        )
    }

    // MARK: - Load Suggestions Tests

    func testLoadSuggestionsPopulatesFavorites() async {
        let banana = makeFavoriteFood(name: "Banana")
        let apple = makeFavoriteFood(name: "Apple")
        repository.mockFoods = [banana, apple]

        await viewModel.loadSuggestions()

        XCTAssertEqual(viewModel.favoriteFoods.count, 2)
    }

    func testLoadSuggestionsPopulatesRecents() async {
        let now = Date()
        let food1 = makeRecentFood(name: "Rice", recentlyUsed: now)
        let food2 = makeRecentFood(name: "Pasta", recentlyUsed: now.addingTimeInterval(-3600))
        repository.mockFoods = [food1, food2]

        await viewModel.loadSuggestions()

        XCTAssertEqual(viewModel.recentFoods.count, 2)
    }

    func testLoadSuggestionsWithNoRepositoryIsNoOp() async {
        let vmNoRepo = FoodSearchViewModel(
            searchFoodUseCase: searchFoodUseCase,
            multiSourceUseCase: multiSourceUseCase,
            repository: nil
        )

        await vmNoRepo.loadSuggestions()

        XCTAssertTrue(vmNoRepo.favoriteFoods.isEmpty)
        XCTAssertTrue(vmNoRepo.recentFoods.isEmpty)
    }

    func testLoadSuggestionsHandlesErrorGracefully() async {
        repository.shouldThrowOnGet = true

        await viewModel.loadSuggestions()

        XCTAssertTrue(viewModel.favoriteFoods.isEmpty)
        XCTAssertTrue(viewModel.recentFoods.isEmpty)
    }

    // MARK: - Toggle Favorite Tests

    func testToggleFavoriteCallsRepository() async {
        let food = makeFavoriteFood(name: "Chicken")
        repository.mockFoods = [food]

        await viewModel.toggleFavorite(for: food)

        XCTAssertEqual(repository.toggleFavoriteCalled.count, 1)
        XCTAssertEqual(repository.toggleFavoriteCalled.first, food.id)
    }

    func testToggleFavoriteReloadsSuggestions() async {
        let food = makeFavoriteFood(name: "Chicken")
        repository.mockFoods = [food]

        // Load initial suggestions
        await viewModel.loadSuggestions()
        XCTAssertEqual(viewModel.favoriteFoods.count, 1)

        // Toggle favorite (this will toggle isFavorite to false in mock)
        await viewModel.toggleFavorite(for: food)

        // After toggle, the food is no longer a favorite, so favorites should be empty
        XCTAssertTrue(viewModel.favoriteFoods.isEmpty)
    }

    func testToggleFavoriteWithNoRepositoryDoesNothing() async {
        let vmNoRepo = FoodSearchViewModel(
            searchFoodUseCase: searchFoodUseCase,
            multiSourceUseCase: multiSourceUseCase,
            repository: nil
        )
        let food = makeFavoriteFood(name: "Test")

        await vmNoRepo.toggleFavorite(for: food)

        // Should not crash, no-op
        XCTAssertTrue(vmNoRepo.favoriteFoods.isEmpty)
    }

    // MARK: - Save Custom Food Tests

    func testSaveCustomFoodCallsRepository() async {
        let food = Food(
            name: "My Custom Shake",
            servingSize: 300,
            servingUnit: "ml",
            calories: 350,
            protein: 30,
            carbs: 40,
            fat: 8,
            isCustom: true
        )

        await viewModel.saveCustomFood(food)

        XCTAssertEqual(repository.savedFoods.count, 1)
        XCTAssertEqual(repository.savedFoods.first?.name, "My Custom Shake")
    }

    // MARK: - Recent Foods Sorting

    func testRecentFoodsAreSortedByRecency() async {
        let now = Date()
        let older = makeRecentFood(name: "Older Food", recentlyUsed: now.addingTimeInterval(-7200))
        let newer = makeRecentFood(name: "Newer Food", recentlyUsed: now)
        repository.mockFoods = [older, newer]

        await viewModel.loadSuggestions()

        XCTAssertEqual(viewModel.recentFoods.count, 2)
        XCTAssertEqual(viewModel.recentFoods.first?.name, "Newer Food")
        XCTAssertEqual(viewModel.recentFoods.last?.name, "Older Food")
    }

    // MARK: - Favorites Filtering

    func testFavoriteFoodsOnlyContainFlaggedFoods() async {
        let favorite = makeFavoriteFood(name: "Favorite Chicken")
        let nonFavorite = Food(
            name: "Plain Rice",
            servingSize: 100,
            servingUnit: "g",
            calories: 130,
            protein: 3,
            carbs: 28,
            fat: 0.3,
            isFavorite: false
        )
        repository.mockFoods = [favorite, nonFavorite]

        await viewModel.loadSuggestions()

        XCTAssertEqual(viewModel.favoriteFoods.count, 1)
        XCTAssertEqual(viewModel.favoriteFoods.first?.name, "Favorite Chicken")
    }

    // MARK: - Sort Order Tests

    func testFavoriteSortOrderAlphabetical() async {
        let banana = makeFavoriteFood(name: "Banana", usageCount: 10)
        let apple = makeFavoriteFood(name: "Apple", usageCount: 5)
        let cherry = makeFavoriteFood(name: "Cherry", usageCount: 1)
        repository.mockFoods = [banana, apple, cherry]

        viewModel.favoriteSortOrder = .alphabetical
        await viewModel.loadSuggestions()

        XCTAssertEqual(viewModel.favoriteFoods.count, 3)
        XCTAssertEqual(viewModel.favoriteFoods[0].name, "Apple")
        XCTAssertEqual(viewModel.favoriteFoods[1].name, "Banana")
        XCTAssertEqual(viewModel.favoriteFoods[2].name, "Cherry")
    }

    func testFavoriteSortOrderMostUsed() async {
        let banana = makeFavoriteFood(name: "Banana", usageCount: 10)
        let apple = makeFavoriteFood(name: "Apple", usageCount: 5)
        let cherry = makeFavoriteFood(name: "Cherry", usageCount: 20)
        repository.mockFoods = [banana, apple, cherry]

        viewModel.favoriteSortOrder = .mostUsed
        await viewModel.loadSuggestions()

        XCTAssertEqual(viewModel.favoriteFoods.count, 3)
        XCTAssertEqual(viewModel.favoriteFoods[0].name, "Cherry")
        XCTAssertEqual(viewModel.favoriteFoods[1].name, "Banana")
        XCTAssertEqual(viewModel.favoriteFoods[2].name, "Apple")
    }
}
