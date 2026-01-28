//
//  NutritionixAPI.swift
//  VitalArc
//
//  Nutritionix API integration for branded and common foods
//

import Foundation

protocol NutritionixAPIProtocol {
    func search(query: String) async throws -> [Food]
    func getByUPC(barcode: String) async throws -> Food
    func getNutrients(query: String) async throws -> [Food]
}

/// Nutritionix API client
/// Free tier: 10,000 requests/month
/// Best for: Restaurant chains, branded foods, common foods
final class NutritionixAPI: NutritionixAPIProtocol {
    private let networkService: NetworkServiceProtocol
    private let appId: String
    private let appKey: String
    private let baseURL: String

    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        appId: String? = nil,
        appKey: String? = nil,
        baseURL: String = "https://trackapi.nutritionix.com/v2"
    ) {
        self.networkService = networkService
        self.appId = appId ?? APISecrets.nutritionixAppId
        self.appKey = appKey ?? APISecrets.nutritionixAppKey
        self.baseURL = baseURL
    }

    /// Search for foods (instant search for autocomplete)
    /// Returns both common and branded foods
    func search(query: String) async throws -> [Food] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        // Build URL
        guard var urlComponents = URLComponents(string: "\(baseURL)/search/instant") else {
            throw NetworkError.invalidURL
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: trimmedQuery)
        ]

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }

        // Make request with headers
        var request = URLRequest(url: url)
        request.addValue(appId, forHTTPHeaderField: "x-app-id")
        request.addValue(appKey, forHTTPHeaderField: "x-app-key")

        let response: NutritionixSearchResponse = try await networkService.request(request: request)

        var foods: [Food] = []

        // Add branded foods (already have full nutrition data)
        if let branded = response.branded {
            foods.append(contentsOf: branded.compactMap { $0.toDomain() })
        }

        // For common foods, we need to make additional requests to get full nutrition
        // For now, we'll skip common foods to avoid too many API calls
        // In production, you might want to cache common foods or fetch them on-demand

        return foods
    }

    /// Get detailed nutrition information using natural language
    /// This is useful for getting full details of common foods
    func getNutrients(query: String) async throws -> [Food] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        guard let url = URL(string: "\(baseURL)/natural/nutrients") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(appId, forHTTPHeaderField: "x-app-id")
        request.addValue(appKey, forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["query": trimmedQuery]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let response: NutritionixNutrientsResponse = try await networkService.request(request: request)

        return response.foods.map { $0.toDomain() }
    }

    /// Get food by UPC barcode
    func getByUPC(barcode: String) async throws -> Food {
        let trimmedBarcode = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBarcode.isEmpty else {
            throw NetworkError.invalidResponse
        }

        guard let url = URL(string: "\(baseURL)/search/item") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(appId, forHTTPHeaderField: "x-app-id")
        request.addValue(appKey, forHTTPHeaderField: "x-app-key")

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "upc", value: trimmedBarcode)
        ]

        guard let finalURL = urlComponents?.url else {
            throw NetworkError.invalidURL
        }

        request.url = finalURL

        let response: NutritionixUPCResponse = try await networkService.request(request: request)

        guard let food = response.foods.first else {
            throw NetworkError.invalidResponse
        }

        return food.toDomain()
    }

    /// Check if API is configured (has valid credentials)
    var isConfigured: Bool {
        !appId.isEmpty && !appKey.isEmpty
    }
}
