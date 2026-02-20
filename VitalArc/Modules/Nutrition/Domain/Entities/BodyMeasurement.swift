//
//  BodyCompositionEntry.swift
//  VitalArc
//
//  Domain Entity for Body Measurement tracking
//

import Foundation

/// Domain entity representing a body composition measurement
struct BodyCompositionEntry: Identifiable, Equatable {
    let id: UUID
    let date: Date
    var weight: Double?              // kg (internal storage)
    var bodyFatPercentage: Double?
    var waistCircumference: Double?  // cm
    var hipCircumference: Double?    // cm
    var chestCircumference: Double?  // cm
    var armCircumference: Double?    // cm
    var thighCircumference: Double?  // cm
    var neckCircumference: Double?   // cm
    var notes: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        weight: Double? = nil,
        bodyFatPercentage: Double? = nil,
        waistCircumference: Double? = nil,
        hipCircumference: Double? = nil,
        chestCircumference: Double? = nil,
        armCircumference: Double? = nil,
        thighCircumference: Double? = nil,
        neckCircumference: Double? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.waistCircumference = waistCircumference
        self.hipCircumference = hipCircumference
        self.chestCircumference = chestCircumference
        self.armCircumference = armCircumference
        self.thighCircumference = thighCircumference
        self.neckCircumference = neckCircumference
        self.notes = notes
    }

    /// Waist-to-hip ratio (WHR) — key health indicator
    var waistToHipRatio: Double? {
        guard let waist = waistCircumference, let hip = hipCircumference, hip > 0 else {
            return nil
        }
        return waist / hip
    }

    /// Lean body mass in kg (if weight and body fat are available)
    var leanBodyMass: Double? {
        guard let weight = weight, let bf = bodyFatPercentage else { return nil }
        return weight * (1.0 - bf / 100.0)
    }

    /// Fat mass in kg (if weight and body fat are available)
    var fatMass: Double? {
        guard let weight = weight, let bf = bodyFatPercentage else { return nil }
        return weight * (bf / 100.0)
    }
}

// MARK: - Meal Time Configuration

/// User-configurable meal time boundaries
struct MealTimeConfiguration: Codable, Equatable {
    var breakfastStart: Int  // hour (24h format)
    var lunchStart: Int
    var dinnerStart: Int
    var snackStart: Int

    init(
        breakfastStart: Int = 5,
        lunchStart: Int = 11,
        dinnerStart: Int = 17,
        snackStart: Int = 21
    ) {
        self.breakfastStart = breakfastStart
        self.lunchStart = lunchStart
        self.dinnerStart = dinnerStart
        self.snackStart = snackStart
    }

    /// UserDefaults key for persistence
    static let userDefaultsKey = "com.vitalarc.mealTimeConfiguration"

    /// Load from UserDefaults, returning defaults if not saved
    static func load() -> MealTimeConfiguration {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let config = try? JSONDecoder().decode(MealTimeConfiguration.self, from: data) else {
            return MealTimeConfiguration()
        }
        return config
    }

    /// Save to UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        }
    }

    /// Human-readable time range for a meal type
    func timeRange(for meal: MealType) -> String {
        let formatter = { (hour: Int) -> String in
            let period = hour >= 12 ? "PM" : "AM"
            let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
            return "\(displayHour) \(period)"
        }

        switch meal {
        case .breakfast:
            return "\(formatter(breakfastStart)) - \(formatter(lunchStart))"
        case .lunch:
            return "\(formatter(lunchStart)) - \(formatter(dinnerStart))"
        case .dinner:
            return "\(formatter(dinnerStart)) - \(formatter(snackStart))"
        case .snack:
            return "\(formatter(snackStart)) - \(formatter(breakfastStart))"
        }
    }
}
