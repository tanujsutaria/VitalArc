//
//  HealthMetricType.swift
//  VitalArc
//
//  Enum representing different health metric types for drill-down analytics
//

import Foundation

enum HealthMetricType: String, Identifiable, CaseIterable {
    case hrv = "HRV"
    case restingHR = "Resting HR"
    case steps = "Steps"
    case activeEnergy = "Active Energy"
    case sleep = "Sleep"
    case weight = "Weight"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .hrv: return "heart.fill"
        case .restingHR: return "waveform.path.ecg"
        case .steps: return "figure.walk"
        case .activeEnergy: return "flame.fill"
        case .sleep: return "bed.double.fill"
        case .weight: return "scalemass.fill"
        }
    }

    var colorName: String {
        switch self {
        case .hrv: return "danger"
        case .restingHR: return "accent"
        case .steps: return "info"
        case .activeEnergy: return "warning"
        case .sleep: return "secondary"
        case .weight: return "success"
        }
    }

    var unit: String {
        switch self {
        case .hrv: return "ms"
        case .restingHR: return "BPM"
        case .steps: return "steps"
        case .activeEnergy: return "kcal"
        case .sleep: return "hours"
        case .weight: return "lbs"
        }
    }

    var chartTitle: String {
        switch self {
        case .hrv: return "Heart Rate Variability"
        case .restingHR: return "Resting Heart Rate"
        case .steps: return "Daily Steps"
        case .activeEnergy: return "Active Energy Burned"
        case .sleep: return "Sleep Duration"
        case .weight: return "Body Weight"
        }
    }
}
