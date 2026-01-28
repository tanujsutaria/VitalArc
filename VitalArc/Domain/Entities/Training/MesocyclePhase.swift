//
//  MesocyclePhase.swift
//  VitalArc
//
//  Domain Entity for Mesocycle Phase
//

import Foundation

/// Domain entity representing a phase within a mesocycle
struct MesocyclePhase: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    var name: String
    var weekNumber: Int
    var phaseType: PhaseType
    var volumeMultiplier: Double // 1.0 = baseline
    var intensityMultiplier: Double // 1.0 = baseline
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        weekNumber: Int,
        phaseType: PhaseType,
        volumeMultiplier: Double = 1.0,
        intensityMultiplier: Double = 1.0,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.weekNumber = weekNumber
        self.phaseType = phaseType
        self.volumeMultiplier = volumeMultiplier
        self.intensityMultiplier = intensityMultiplier
        self.notes = notes
    }

    /// Convenience initializer for standard phase types
    init(weekNumber: Int, phaseType: PhaseType) {
        self.id = UUID()
        self.weekNumber = weekNumber
        self.phaseType = phaseType
        self.name = phaseType.rawValue
        self.volumeMultiplier = phaseType.defaultVolumeMultiplier
        self.intensityMultiplier = phaseType.defaultIntensityMultiplier
        self.notes = nil
    }
}

/// Type of training phase
enum PhaseType: String, CaseIterable, Codable {
    case accumulation = "Accumulation"
    case intensification = "Intensification"
    case realization = "Realization"
    case deload = "Deload"

    var description: String {
        switch self {
        case .accumulation:
            return "High volume, moderate intensity - build work capacity"
        case .intensification:
            return "Lower volume, higher intensity - increase strength"
        case .realization:
            return "Peak performance - test strength gains"
        case .deload:
            return "Recovery week - reduced volume and intensity"
        }
    }

    var icon: String {
        switch self {
        case .accumulation:
            return "chart.bar.fill"
        case .intensification:
            return "flame.fill"
        case .realization:
            return "star.fill"
        case .deload:
            return "moon.zzz.fill"
        }
    }

    var color: String {
        switch self {
        case .accumulation:
            return "blue"
        case .intensification:
            return "orange"
        case .realization:
            return "purple"
        case .deload:
            return "green"
        }
    }

    var defaultVolumeMultiplier: Double {
        switch self {
        case .accumulation:
            return 1.2 // 20% more volume
        case .intensification:
            return 0.8 // 20% less volume
        case .realization:
            return 0.6 // 40% less volume
        case .deload:
            return 0.5 // 50% less volume
        }
    }

    var defaultIntensityMultiplier: Double {
        switch self {
        case .accumulation:
            return 1.0 // Baseline intensity
        case .intensification:
            return 1.15 // 15% more intensity
        case .realization:
            return 1.25 // 25% more intensity
        case .deload:
            return 0.7 // 30% less intensity
        }
    }
}
