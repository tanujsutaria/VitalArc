//
//  OpenFoodFactsModels.swift
//  VitalArc
//
//  Codable models for OpenFoodFacts API responses
//

import Foundation

// MARK: - Search Response

struct OFFSearchResponse: Codable {
    let count: Int
    let page: Int
    let pageSize: Int
    let products: [OFFProduct]

    enum CodingKeys: String, CodingKey {
        case count
        case page
        case pageSize = "page_size"
        case products
    }
}

// MARK: - Product Response (Barcode Lookup)

struct OFFProductResponse: Codable {
    let status: Int
    let product: OFFProduct?
}

// MARK: - Product

struct OFFProduct: Codable {
    let productName: String?
    let productNameEn: String?
    let brands: String?
    let quantity: String?
    let servingSize: String?
    let nutriments: OFFNutriments?
    let code: String  // Barcode
    let imageURL: String?
    let imageFrontURL: String?
    let imageFrontThumbURL: String?
    let categories: String?
    let categoriesTags: [String]?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case productNameEn = "product_name_en"
        case brands
        case quantity
        case servingSize = "serving_size"
        case nutriments
        case code
        case imageURL = "image_url"
        case imageFrontURL = "image_front_url"
        case imageFrontThumbURL = "image_front_thumb_url"
        case categories
        case categoriesTags = "categories_tags"
    }

    /// Convert to domain Food entity
    func toDomain() -> Food? {
        // Get product name (prefer English, fallback to generic)
        guard let name = productNameEn ?? productName, !name.isEmpty else {
            return nil
        }

        guard let nutriments = nutriments else {
            return nil
        }

        // Validate we have at least calories
        guard let calories = nutriments.energyKcal100g, calories > 0 else {
            return nil
        }

        // Parse serving size (try to extract grams)
        let servingSize = parseServingSize(servingSize ?? quantity ?? "100g")

        // Get thumbnail image
        let imageURL = imageFrontThumbURL ?? imageFrontURL ?? self.imageURL

        return Food(
            name: name,
            brand: brands,
            servingSize: servingSize,
            servingUnit: "g",
            calories: calories,
            protein: nutriments.proteins100g ?? 0,
            carbs: nutriments.carbohydrates100g ?? 0,
            fat: nutriments.fat100g ?? 0,
            fiber: nutriments.fiber100g,
            sugar: nutriments.sugars100g,
            source: .openFoodFacts,
            barcode: code,
            imageURL: imageURL
        )
    }

    /// Parse serving size from string (e.g., "100g", "250ml", "1 cup (100g)")
    private func parseServingSize(_ sizeString: String) -> Double {
        // Try to extract number followed by 'g' or 'ml'
        let pattern = #"(\d+(?:\.\d+)?)\s*(?:g|ml)"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: sizeString, range: NSRange(sizeString.startIndex..., in: sizeString)),
           let range = Range(match.range(at: 1), in: sizeString) {
            if let value = Double(sizeString[range]) {
                return value
            }
        }

        // Default to 100g
        return 100
    }
}

// MARK: - Nutriments

struct OFFNutriments: Codable {
    // Per 100g values (most reliable)
    let energyKcal100g: Double?
    let proteins100g: Double?
    let carbohydrates100g: Double?
    let fat100g: Double?
    let fiber100g: Double?
    let sugars100g: Double?
    let salt100g: Double?
    let sodium100g: Double?

    // Per serving values (optional)
    let energyKcalServing: Double?
    let proteinsServing: Double?
    let carbohydratesServing: Double?
    let fatServing: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
        case fiber100g = "fiber_100g"
        case sugars100g = "sugars_100g"
        case salt100g = "salt_100g"
        case sodium100g = "sodium_100g"
        case energyKcalServing = "energy-kcal_serving"
        case proteinsServing = "proteins_serving"
        case carbohydratesServing = "carbohydrates_serving"
        case fatServing = "fat_serving"
    }
}
