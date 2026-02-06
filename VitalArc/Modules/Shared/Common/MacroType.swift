//
//  MacroType.swift
//  VitalArc
//
//  Enum representing different macro nutrient types for drill-down analytics
//

import Foundation

enum MacroType: String, Identifiable, CaseIterable {
    case calories = "Calories"
    case protein = "Protein"
    case carbs = "Carbs"
    case fat = "Fat"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .calories: return "flame.fill"
        case .protein: return "figure.strengthtraining.traditional"
        case .carbs: return "leaf.fill"
        case .fat: return "drop.fill"
        }
    }

    var colorName: String {
        switch self {
        case .calories: return "warning"
        case .protein: return "danger"
        case .carbs: return "info"
        case .fat: return "warning"
        }
    }

    var unit: String {
        switch self {
        case .calories: return "kcal"
        case .protein, .carbs, .fat: return "g"
        }
    }

    var chartTitle: String {
        switch self {
        case .calories: return "Calorie Intake"
        case .protein: return "Protein Intake"
        case .carbs: return "Carbohydrate Intake"
        case .fat: return "Fat Intake"
        }
    }
}
