//
//  FoodModel.swift
//  VitalArc
//
//  SwiftData Model for Food
//

import Foundation
import SwiftData

@Model
final class FoodModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var brand: String?
    var servingSize: Double
    var servingUnit: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double?
    var sugar: Double?
    var source: String
    var barcode: String?
    var imageURL: String?
    var isFavorite: Bool
    var isCustom: Bool
    var recentlyUsed: Date?
    var usageCount: Int

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
        source: String = "Manual",
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

    /// Convert to domain entity
    func toDomain() -> Food {
        Food(
            id: id,
            name: name,
            brand: brand,
            servingSize: servingSize,
            servingUnit: servingUnit,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            source: FoodSource(rawValue: source) ?? .manual,
            barcode: barcode,
            imageURL: imageURL,
            isFavorite: isFavorite,
            isCustom: isCustom,
            recentlyUsed: recentlyUsed,
            usageCount: usageCount
        )
    }

    /// Create from domain entity
    static func fromDomain(_ food: Food) -> FoodModel {
        FoodModel(
            id: food.id,
            name: food.name,
            brand: food.brand,
            servingSize: food.servingSize,
            servingUnit: food.servingUnit,
            calories: food.calories,
            protein: food.protein,
            carbs: food.carbs,
            fat: food.fat,
            fiber: food.fiber,
            sugar: food.sugar,
            source: food.source.rawValue,
            barcode: food.barcode,
            imageURL: food.imageURL,
            isFavorite: food.isFavorite,
            isCustom: food.isCustom,
            recentlyUsed: food.recentlyUsed,
            usageCount: food.usageCount
        )
    }
}
