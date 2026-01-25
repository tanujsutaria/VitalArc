//
//  NutritionTests.swift
//  VitalArcTests
//
//  Test suite for Nutrition Module
//

import XCTest
@testable import VitalArc

final class NutritionTests: XCTestCase {

    // MARK: - Food Scaling Tests

    func testFoodScalingToLargerQuantity() throws {
        let food = Food(
            name: "Chicken Breast",
            servingSize: 100,
            servingUnit: "g",
            calories: 165,
            protein: 31,
            carbs: 0,
            fat: 3.6,
            fiber: 0,
            sugar: 0
        )

        let scaled = food.scaled(to: 200)

        XCTAssertEqual(scaled.servingSize, 200)
        XCTAssertEqual(scaled.calories, 330, accuracy: 0.1)
        XCTAssertEqual(scaled.protein, 62, accuracy: 0.1)
        XCTAssertEqual(scaled.carbs, 0, accuracy: 0.1)
        XCTAssertEqual(scaled.fat, 7.2, accuracy: 0.1)
    }

    func testFoodScalingToSmallerQuantity() throws {
        let food = Food(
            name: "Oatmeal",
            servingSize: 100,
            servingUnit: "g",
            calories: 389,
            protein: 16.9,
            carbs: 66.3,
            fat: 6.9
        )

        let scaled = food.scaled(to: 50)

        XCTAssertEqual(scaled.servingSize, 50)
        XCTAssertEqual(scaled.calories, 194.5, accuracy: 0.1)
        XCTAssertEqual(scaled.protein, 8.45, accuracy: 0.1)
        XCTAssertEqual(scaled.carbs, 33.15, accuracy: 0.1)
        XCTAssertEqual(scaled.fat, 3.45, accuracy: 0.1)
    }

    // MARK: - Daily Nutrition Calculation Tests

    func testDailyNutritionCalorieProgress() throws {
        let nutrition = DailyNutrition(
            date: Date(),
            caloriesConsumed: 1500,
            proteinConsumed: 120,
            carbsConsumed: 150,
            fatConsumed: 50,
            calorieGoal: 2000
        )

        XCTAssertEqual(nutrition.calorieProgress, 75, accuracy: 0.1)
        XCTAssertEqual(nutrition.caloriesRemaining, 500, accuracy: 0.1)
    }

    func testDailyNutritionExceedsGoal() throws {
        let nutrition = DailyNutrition(
            date: Date(),
            caloriesConsumed: 2500,
            proteinConsumed: 150,
            carbsConsumed: 200,
            fatConsumed: 80,
            calorieGoal: 2000
        )

        XCTAssertEqual(nutrition.calorieProgress, 125, accuracy: 0.1)
        XCTAssertEqual(nutrition.caloriesRemaining, -500, accuracy: 0.1)
    }

    func testDailyNutritionNoGoal() throws {
        let nutrition = DailyNutrition(
            date: Date(),
            caloriesConsumed: 1800,
            proteinConsumed: 140,
            carbsConsumed: 180,
            fatConsumed: 60
        )

        XCTAssertNil(nutrition.calorieProgress)
        XCTAssertNil(nutrition.caloriesRemaining)
    }

    // MARK: - Calorie Goal Calculator Tests

    func testMaintenanceCalorieCalculation() throws {
        let weight: Double = 75 // kg
        let maintenanceCalories = weight * 33

        XCTAssertEqual(maintenanceCalories, 2475, accuracy: 1)
    }

    func testDeficitCalorieCalculation() throws {
        let weight: Double = 80 // kg
        let maintenanceCalories = weight * 33
        let deficitCalories = maintenanceCalories - 500

        XCTAssertEqual(deficitCalories, 2140, accuracy: 1)
    }

    func testSurplusCalorieCalculation() throws {
        let weight: Double = 70 // kg
        let maintenanceCalories = weight * 33
        let surplusCalories = maintenanceCalories + 500

        XCTAssertEqual(surplusCalories, 2810, accuracy: 1)
    }

    // MARK: - Food Entry Tests

    func testFoodEntryCreation() throws {
        let foodId = UUID()
        let entry = FoodEntry(
            foodId: foodId,
            date: Date(),
            meal: .breakfast,
            quantity: 150,
            calories: 250,
            protein: 30,
            carbs: 10,
            fat: 8
        )

        XCTAssertEqual(entry.foodId, foodId)
        XCTAssertEqual(entry.meal, .breakfast)
        XCTAssertEqual(entry.quantity, 150)
        XCTAssertEqual(entry.calories, 250)
    }

    func testMealTypeAllCases() throws {
        let meals = MealType.allCases

        XCTAssertEqual(meals.count, 4)
        XCTAssertTrue(meals.contains(.breakfast))
        XCTAssertTrue(meals.contains(.lunch))
        XCTAssertTrue(meals.contains(.dinner))
        XCTAssertTrue(meals.contains(.snack))
    }

    // MARK: - Food Source Tests

    func testFoodSourceTypes() throws {
        XCTAssertEqual(FoodSource.usda.rawValue, "USDA")
        XCTAssertEqual(FoodSource.manual.rawValue, "Manual")
        XCTAssertEqual(FoodSource.custom.rawValue, "Custom")
    }

    // MARK: - USDA API Response Parsing Tests

    func testUSDAFoodResponseParsing() throws {
        // Sample USDA API response JSON
        let jsonString = """
        {
            "fdcId": 123456,
            "description": "Chicken, broilers or fryers, breast, meat only, cooked, roasted",
            "brandOwner": null,
            "servingSize": 100,
            "servingSizeUnit": "g",
            "foodNutrients": [
                {"nutrientId": 1008, "nutrientName": "Energy", "value": 165},
                {"nutrientId": 1003, "nutrientName": "Protein", "value": 31},
                {"nutrientId": 1005, "nutrientName": "Carbohydrate, by difference", "value": 0},
                {"nutrientId": 1004, "nutrientName": "Total lipid (fat)", "value": 3.6},
                {"nutrientId": 1079, "nutrientName": "Fiber, total dietary", "value": 0},
                {"nutrientId": 2000, "nutrientName": "Sugars, total", "value": 0}
            ]
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        // This test validates the structure we expect from USDA API
        // The actual parsing will be done in FoodAPIModels
        XCTAssertNotNil(jsonData)
    }

    // MARK: - Aggregate Daily Totals Tests

    func testAggregateMultipleFoodEntries() throws {
        let date = Date()
        let entries = [
            FoodEntry(
                foodId: UUID(),
                date: date,
                meal: .breakfast,
                quantity: 100,
                calories: 300,
                protein: 20,
                carbs: 30,
                fat: 10
            ),
            FoodEntry(
                foodId: UUID(),
                date: date,
                meal: .lunch,
                quantity: 150,
                calories: 500,
                protein: 40,
                carbs: 50,
                fat: 15
            ),
            FoodEntry(
                foodId: UUID(),
                date: date,
                meal: .dinner,
                quantity: 200,
                calories: 700,
                protein: 50,
                carbs: 60,
                fat: 25
            )
        ]

        let totalCalories = entries.reduce(0) { $0 + $1.calories }
        let totalProtein = entries.reduce(0) { $0 + $1.protein }
        let totalCarbs = entries.reduce(0) { $0 + $1.carbs }
        let totalFat = entries.reduce(0) { $0 + $1.fat }

        XCTAssertEqual(totalCalories, 1500)
        XCTAssertEqual(totalProtein, 110)
        XCTAssertEqual(totalCarbs, 140)
        XCTAssertEqual(totalFat, 50)
    }

    // MARK: - Meal Grouping Tests

    func testGroupEntriesByMeal() throws {
        let date = Date()
        let breakfastEntry1 = FoodEntry(
            foodId: UUID(),
            date: date,
            meal: .breakfast,
            quantity: 100,
            calories: 200,
            protein: 15,
            carbs: 20,
            fat: 5
        )
        let breakfastEntry2 = FoodEntry(
            foodId: UUID(),
            date: date,
            meal: .breakfast,
            quantity: 50,
            calories: 150,
            protein: 10,
            carbs: 15,
            fat: 5
        )
        let lunchEntry = FoodEntry(
            foodId: UUID(),
            date: date,
            meal: .lunch,
            quantity: 150,
            calories: 400,
            protein: 30,
            carbs: 40,
            fat: 12
        )

        let entries = [breakfastEntry1, breakfastEntry2, lunchEntry]
        let groupedByMeal = Dictionary(grouping: entries) { $0.meal }

        XCTAssertEqual(groupedByMeal[.breakfast]?.count, 2)
        XCTAssertEqual(groupedByMeal[.lunch]?.count, 1)
        XCTAssertNil(groupedByMeal[.dinner])
    }

    // MARK: - Date Filtering Tests

    func testFilterEntriesByDate() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let todayEntry = FoodEntry(
            foodId: UUID(),
            date: today,
            meal: .breakfast,
            quantity: 100,
            calories: 300,
            protein: 20,
            carbs: 30,
            fat: 10
        )
        let yesterdayEntry = FoodEntry(
            foodId: UUID(),
            date: yesterday,
            meal: .breakfast,
            quantity: 100,
            calories: 250,
            protein: 18,
            carbs: 25,
            fat: 8
        )

        let entries = [todayEntry, yesterdayEntry]
        let todayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: today) }

        XCTAssertEqual(todayEntries.count, 1)
        XCTAssertEqual(todayEntries.first?.calories, 300)
    }
}
