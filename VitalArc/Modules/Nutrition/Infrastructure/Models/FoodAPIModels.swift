//
//  FoodAPIModels.swift
//  VitalArc
//
//  Codable models for USDA FoodData Central API responses
//

import Foundation

// MARK: - Search Response

struct USDASearchResponse: Codable {
    let foods: [USDAFood]
    let totalHits: Int
}

struct USDAFood: Codable {
    let fdcId: Int
    let description: String
    let brandOwner: String?
    let servingSize: Double?
    let servingSizeUnit: String?
    let foodNutrients: [USDANutrient]

    /// Convert USDA food to domain Food entity
    func toDomain() -> Food? {
        // Extract nutrients
        let nutrients = Dictionary(uniqueKeysWithValues: foodNutrients.map { ($0.nutrientId, $0.value) })

        // USDA Nutrient IDs
        let caloriesId = 1008
        let proteinId = 1003
        let carbsId = 1005
        let fatId = 1004
        let fiberId = 1079
        let sugarId = 2000

        // Get nutritional values per 100g
        let servingSizeValue = servingSize ?? 100
        let scale = 100.0 / servingSizeValue

        guard let calories = nutrients[caloriesId] else {
            return nil
        }

        let protein = nutrients[proteinId] ?? 0
        let carbs = nutrients[carbsId] ?? 0
        let fat = nutrients[fatId] ?? 0
        let fiber = nutrients[fiberId]
        let sugar = nutrients[sugarId]

        return Food(
            name: description,
            brand: brandOwner,
            servingSize: 100, // Normalize to 100g
            servingUnit: "g",
            calories: calories * scale,
            protein: protein * scale,
            carbs: carbs * scale,
            fat: fat * scale,
            fiber: fiber.map { $0 * scale },
            sugar: sugar.map { $0 * scale },
            source: .usda
        )
    }
}

struct USDANutrient: Codable {
    let nutrientId: Int
    let nutrientName: String
    let value: Double
}

// MARK: - Detailed Food Response

struct USDAFoodDetail: Codable {
    let fdcId: Int
    let description: String
    let brandOwner: String?
    let servingSize: Double?
    let servingSizeUnit: String?
    let foodNutrients: [USDANutrientDetail]

    /// Convert USDA food detail to domain Food entity
    func toDomain() -> Food? {
        // Extract nutrients
        let nutrients = Dictionary(uniqueKeysWithValues: foodNutrients.compactMap { nutrient -> (Int, Double)? in
            guard let amount = nutrient.amount else { return nil }
            return (nutrient.nutrient.id, amount)
        })

        // USDA Nutrient IDs
        let caloriesId = 1008
        let proteinId = 1003
        let carbsId = 1005
        let fatId = 1004
        let fiberId = 1079
        let sugarId = 2000

        // Get nutritional values per 100g
        let servingSizeValue = servingSize ?? 100
        let scale = 100.0 / servingSizeValue

        guard let calories = nutrients[caloriesId] else {
            return nil
        }

        let protein = nutrients[proteinId] ?? 0
        let carbs = nutrients[carbsId] ?? 0
        let fat = nutrients[fatId] ?? 0
        let fiber = nutrients[fiberId]
        let sugar = nutrients[sugarId]

        return Food(
            name: description,
            brand: brandOwner,
            servingSize: 100, // Normalize to 100g
            servingUnit: "g",
            calories: calories * scale,
            protein: protein * scale,
            carbs: carbs * scale,
            fat: fat * scale,
            fiber: fiber.map { $0 * scale },
            sugar: sugar.map { $0 * scale },
            source: .usda
        )
    }
}

struct USDANutrientDetail: Codable {
    let nutrient: USDANutrientInfo
    let amount: Double?
}

struct USDANutrientInfo: Codable {
    let id: Int
    let name: String
    let unitName: String
}
