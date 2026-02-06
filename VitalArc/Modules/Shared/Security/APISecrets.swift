//
//  APISecrets.swift
//  VitalArc
//
//  API key management - loads from Secrets.swift (gitignored) or environment
//
//  SETUP INSTRUCTIONS:
//  1. Copy Secrets.template.swift to Secrets.swift
//  2. Replace placeholder values with your actual API keys
//  3. Secrets.swift is gitignored and will not be committed
//

import Foundation

/// Manages API secrets securely
/// Keys are loaded from Secrets.swift (gitignored) with fallback to environment variables
enum APISecrets {

    // MARK: - Nutritionix API

    static var nutritionixAppId: String {
        // First try the Secrets file (compile-time)
        #if canImport(VitalArc)
        if let key = SecretsConfig.nutritionixAppId, !key.isEmpty, key != "YOUR_APP_ID" {
            return key
        }
        #endif

        // Fallback to environment variable
        if let key = ProcessInfo.processInfo.environment["NUTRITIONIX_APP_ID"], !key.isEmpty {
            return key
        }

        return ""
    }

    static var nutritionixAppKey: String {
        #if canImport(VitalArc)
        if let key = SecretsConfig.nutritionixAppKey, !key.isEmpty, key != "YOUR_APP_KEY" {
            return key
        }
        #endif

        if let key = ProcessInfo.processInfo.environment["NUTRITIONIX_APP_KEY"], !key.isEmpty {
            return key
        }

        return ""
    }

    static var isNutritionixConfigured: Bool {
        !nutritionixAppId.isEmpty && !nutritionixAppKey.isEmpty
    }

    // MARK: - USDA API

    static var usdaApiKey: String {
        #if canImport(VitalArc)
        if let key = SecretsConfig.usdaApiKey, !key.isEmpty, key != "DEMO_KEY" {
            return key
        }
        #endif

        if let key = ProcessInfo.processInfo.environment["USDA_API_KEY"], !key.isEmpty {
            return key
        }

        // USDA allows DEMO_KEY for limited testing
        return "DEMO_KEY"
    }

    static var isUSDAConfigured: Bool {
        usdaApiKey != "DEMO_KEY" && !usdaApiKey.isEmpty
    }
}
