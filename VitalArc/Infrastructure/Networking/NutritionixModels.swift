//
//  NutritionixModels.swift
//  VitalArc
//
//  Codable models for Nutritionix API responses
//

import Foundation

// MARK: - Search Response

struct NutritionixSearchResponse: Codable {
    let common: [NutritionixCommonFood]?
    let branded: [NutritionixBrandedFood]?
}

// MARK: - Common Foods (Generic Foods)

struct NutritionixCommonFood: Codable {
    let foodName: String
    let servingUnit: String
    let servingQty: Double
    let photoURL: String?
    let tagId: String

    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case servingUnit = "serving_unit"
        case servingQty = "serving_qty"
        case photoURL = "photo"
        case tagId = "tag_id"
    }
}

// MARK: - Branded Foods

struct NutritionixBrandedFood: Codable {
    let foodName: String
    let brandName: String?
    let servingQty: Double
    let servingUnit: String
    let nfCalories: Double
    let nfProtein: Double?
    let nfTotalCarbohydrate: Double?
    let nfTotalFat: Double?
    let nfDietaryFiber: Double?
    let nfSugars: Double?
    let nixBrandId: String?
    let nixItemId: String?
    let upc: String?
    let photo: NutritionixPhoto?

    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case brandName = "brand_name"
        case servingQty = "serving_qty"
        case servingUnit = "serving_unit"
        case nfCalories = "nf_calories"
        case nfProtein = "nf_protein"
        case nfTotalCarbohydrate = "nf_total_carbohydrate"
        case nfTotalFat = "nf_total_fat"
        case nfDietaryFiber = "nf_dietary_fiber"
        case nfSugars = "nf_sugars"
        case nixBrandId = "nix_brand_id"
        case nixItemId = "nix_item_id"
        case upc
        case photo
    }

    /// Convert to domain Food entity
    func toDomain() -> Food? {
        // Validate required data
        guard nfCalories > 0 else { return nil }

        return Food(
            name: foodName,
            brand: brandName,
            servingSize: servingQty,
            servingUnit: servingUnit,
            calories: nfCalories,
            protein: nfProtein ?? 0,
            carbs: nfTotalCarbohydrate ?? 0,
            fat: nfTotalFat ?? 0,
            fiber: nfDietaryFiber,
            sugar: nfSugars,
            source: .nutritionix,
            barcode: upc,
            imageURL: photo?.thumb
        )
    }
}

struct NutritionixPhoto: Codable {
    let thumb: String?
    let highres: String?
}

// MARK: - Natural Language (Nutrients) Response

struct NutritionixNutrientsResponse: Codable {
    let foods: [NutritionixNutrientFood]
}

struct NutritionixNutrientFood: Codable {
    let foodName: String
    let brandName: String?
    let servingQty: Double
    let servingUnit: String
    let servingWeightGrams: Double?
    let nfCalories: Double
    let nfProtein: Double
    let nfTotalCarbohydrate: Double
    let nfTotalFat: Double
    let nfDietaryFiber: Double?
    let nfSugars: Double?
    let upc: String?
    let photo: NutritionixPhoto?

    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case brandName = "brand_name"
        case servingQty = "serving_qty"
        case servingUnit = "serving_unit"
        case servingWeightGrams = "serving_weight_grams"
        case nfCalories = "nf_calories"
        case nfProtein = "nf_protein"
        case nfTotalCarbohydrate = "nf_total_carbohydrate"
        case nfTotalFat = "nf_total_fat"
        case nfDietaryFiber = "nf_dietary_fiber"
        case nfSugars = "nf_sugars"
        case upc
        case photo
    }

    /// Convert to domain Food entity
    func toDomain() -> Food {
        let servingSize = servingWeightGrams ?? servingQty

        return Food(
            name: foodName,
            brand: brandName,
            servingSize: servingSize,
            servingUnit: servingWeightGrams != nil ? "g" : servingUnit,
            calories: nfCalories,
            protein: nfProtein,
            carbs: nfTotalCarbohydrate,
            fat: nfTotalFat,
            fiber: nfDietaryFiber,
            sugar: nfSugars,
            source: .nutritionix,
            barcode: upc,
            imageURL: photo?.thumb
        )
    }
}

// MARK: - UPC Lookup Response

struct NutritionixUPCResponse: Codable {
    let foods: [NutritionixNutrientFood]
}
