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
    let barcode: String? // UPC/EAN barcode
    let imageURL: String? // Product image URL
    var isFavorite: Bool // User favorite flag
    var isCustom: Bool // User-created custom food
    var recentlyUsed: Date? // Last time food was logged
    var usageCount: Int // How many times food was logged

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
        source: FoodSource = .manual,
        barcode: String? = nil,
        imageURL: String? = nil,
        isFavorite: Bool = false,
        isCustom: Bool = false,
        recentlyUsed: Date? = nil,
        usageCount: Int = 0
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
        self.barcode = barcode
        self.imageURL = imageURL
        self.isFavorite = isFavorite
        self.isCustom = isCustom
        self.recentlyUsed = recentlyUsed
        self.usageCount = usageCount
    }

    /// Calculate macros for a different serving size
    func scaled(to grams: Double) -> Food {
        // Guard against division by zero
        guard servingSize > 0 else { return self }
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
            source: source,
            barcode: barcode,
            imageURL: imageURL,
            isFavorite: isFavorite,
            isCustom: isCustom,
            recentlyUsed: recentlyUsed,
            usageCount: usageCount
        )
    }
}

enum FoodSource: String, Codable, CaseIterable {
    case usda = "USDA"
    case nutritionix = "Nutritionix"
    case openFoodFacts = "OpenFoodFacts"
    case manual = "Manual"
    case custom = "Custom"

    var displayName: String {
        switch self {
        case .usda: return "USDA"
        case .nutritionix: return "Nutritionix"
        case .openFoodFacts: return "Open Food Facts"
        case .manual: return "Manual"
        case .custom: return "Custom"
        }
    }

    var iconName: String {
        switch self {
        case .usda: return "leaf.fill"
        case .nutritionix: return "fork.knife"
        case .openFoodFacts: return "globe"
        case .manual: return "pencil"
        case .custom: return "person.fill"
        }
    }
}
