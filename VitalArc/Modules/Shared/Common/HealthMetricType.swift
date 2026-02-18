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
    case bodyFat = "Body Fat"
    case leanBodyMass = "Lean Mass"
    case respiratoryRate = "Respiratory Rate"
    case spo2 = "SpO2"
    case vo2Max = "VO2 Max"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .hrv: return "heart.fill"
        case .restingHR: return "waveform.path.ecg"
        case .steps: return "figure.walk"
        case .activeEnergy: return "flame.fill"
        case .sleep: return "bed.double.fill"
        case .weight: return "scalemass.fill"
        case .bodyFat: return "figure.arms.open"
        case .leanBodyMass: return "figure.strengthtraining.traditional"
        case .respiratoryRate: return "lungs.fill"
        case .spo2: return "lungs.fill"
        case .vo2Max: return "figure.run"
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
        case .bodyFat: return "warning"
        case .leanBodyMass: return "info"
        case .respiratoryRate: return "accent"
        case .spo2: return "info"
        case .vo2Max: return "success"
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
        case .bodyFat: return "%"
        case .leanBodyMass: return "lbs"
        case .respiratoryRate: return "brpm"
        case .spo2: return "%"
        case .vo2Max: return "mL/kg/min"
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
        case .bodyFat: return "Body Fat Percentage"
        case .leanBodyMass: return "Lean Body Mass"
        case .respiratoryRate: return "Respiratory Rate"
        case .spo2: return "Blood Oxygen Saturation"
        case .vo2Max: return "VO2 Max"
        }
    }
}
