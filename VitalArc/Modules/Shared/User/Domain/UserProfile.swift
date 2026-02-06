//
//  UserProfile.swift
//  VitalArc
//
//  Domain Entity for User Profile
//

import Foundation

/// Domain entity representing user profile information
struct UserProfile: Identifiable, Equatable {
    let id: UUID
    let name: String
    let birthDate: Date
    let biologicalSex: BiologicalSex
    let height: Double // in cm
    let weight: Double // in kg
    let activityLevel: ActivityLevel
    let weightGoal: WeightGoal
    let customHRMax: Int? // User-specified max heart rate (overrides age-based estimate)
    let customHRResting: Int? // User-specified resting heart rate (overrides HealthKit)
    let createdAt: Date
    let updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        biologicalSex: BiologicalSex,
        height: Double,
        weight: Double,
        activityLevel: ActivityLevel,
        weightGoal: WeightGoal = .maintain,
        customHRMax: Int? = nil,
        customHRResting: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.biologicalSex = biologicalSex
        self.height = height
        self.weight = weight
        self.activityLevel = activityLevel
        self.weightGoal = weightGoal
        self.customHRMax = customHRMax
        self.customHRResting = customHRResting
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Calculate age from birth date
    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year ?? 0
    }

    /// Calculate BMI (Body Mass Index)
    var bmi: Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }

    /// Simple calorie goal based on weight and goal
    var estimatedCalorieGoal: Double {
        // Maintenance = weight(kg) × 33
        // Deficit = maintenance - 500
        // Surplus = maintenance + 500
        let maintenance = weight * 33

        switch weightGoal {
        case .lose:
            return maintenance - 500
        case .maintain:
            return maintenance
        case .gain:
            return maintenance + 500
        }
    }

    /// Estimated max heart rate using age-based formula (220 - age)
    var estimatedHRMax: Int {
        220 - age
    }

    /// Effective max heart rate (custom if set, otherwise estimated)
    var effectiveHRMax: Int {
        customHRMax ?? estimatedHRMax
    }

    /// Default resting heart rate estimate
    var estimatedHRResting: Int {
        60
    }

    /// Effective resting heart rate (custom if set, otherwise default)
    var effectiveHRResting: Int {
        customHRResting ?? estimatedHRResting
    }
}

enum BiologicalSex: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case light = "Lightly Active"
    case moderate = "Moderately Active"
    case very = "Very Active"
    case extreme = "Extremely Active"
}

enum WeightGoal: String, Codable, CaseIterable {
    case lose = "Lose Weight"
    case maintain = "Maintain Weight"
    case gain = "Gain Weight"
}
