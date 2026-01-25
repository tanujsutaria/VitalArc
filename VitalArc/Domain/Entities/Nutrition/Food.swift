//
//  Food.swift
//  VitalArc
//
//  Domain Entity for Food
//

import Foundation

/// Domain entity representing a food item
struct Food: Identifiable, Equatable {
    let id: UUID
    let name: String
    let brand: String?
    let servingSize: Double // in grams
    let servingUnit: String // e.g., "g", "ml", "cup"
    let calories: Double
    let protein: Double // in grams
    let carbs: Double // in grams
    let fat: Double // in grams
    let fiber: Double? // in grams (optional)
    let sugar: Double? // in grams (optional)
    let source: FoodSource

    init(
        id: UUID = UUID(),
        name: String,
        brand: String? = nil,
        servingSize: Double,
        servingUnit: String = "g",
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double? = nil,
        sugar: Double? = nil,
        source: FoodSource = .manual
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.source = source
    }

    /// Calculate macros for a different serving size
    func scaled(to grams: Double) -> Food {
        let scale = grams / servingSize
        return Food(
            id: id,
            name: name,
            brand: brand,
            servingSize: grams,
            servingUnit: servingUnit,
            calories: calories * scale,
            protein: protein * scale,
            carbs: carbs * scale,
            fat: fat * scale,
            fiber: fiber.map { $0 * scale },
            sugar: sugar.map { $0 * scale },
            source: source
        )
    }
}

enum FoodSource: String, Codable {
    case usda = "USDA"
    case manual = "Manual"
    case custom = "Custom"
}
