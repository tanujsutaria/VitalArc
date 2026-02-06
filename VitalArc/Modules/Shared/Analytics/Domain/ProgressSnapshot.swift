//
//  ProgressSnapshot.swift
//  VitalArc
//
//  Domain entity for tracking body composition and progress over time
//

import Foundation

/// A snapshot of user progress at a specific point in time
struct ProgressSnapshot: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let bodyWeight: Double?
    let bodyFatPercentage: Double?
    let measurements: [BodyMeasurement]
    let photos: [String] // File paths to progress photos
    let notes: String?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date,
        bodyWeight: Double? = nil,
        bodyFatPercentage: Double? = nil,
        measurements: [BodyMeasurement] = [],
        photos: [String] = [],
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.bodyWeight = bodyWeight
        self.bodyFatPercentage = bodyFatPercentage
        self.measurements = measurements
        self.photos = photos
        self.notes = notes
        self.createdAt = createdAt
    }
}

/// A measurement of a specific body part
struct BodyMeasurement: Identifiable, Equatable, Codable {
    let id: UUID
    let bodyPart: BodyPart
    let value: Double // in centimeters

    init(id: UUID = UUID(), bodyPart: BodyPart, value: Double) {
        self.id = id
        self.bodyPart = bodyPart
        self.value = value
    }
}

/// Body parts that can be measured
enum BodyPart: String, CaseIterable, Codable {
    case neck = "Neck"
    case chest = "Chest"
    case waist = "Waist"
    case hips = "Hips"
    case bicepsLeft = "Left Bicep"
    case bicepsRight = "Right Bicep"
    case thighLeft = "Left Thigh"
    case thighRight = "Right Thigh"
    case calfLeft = "Left Calf"
    case calfRight = "Right Calf"

    var displayName: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .neck: return "person.circle"
        case .chest: return "figure.arms.open"
        case .waist: return "circle.dashed"
        case .hips: return "circle.grid.cross"
        case .bicepsLeft, .bicepsRight: return "figure.strengthtraining.traditional"
        case .thighLeft, .thighRight: return "figure.walk"
        case .calfLeft, .calfRight: return "figure.run"
        }
    }
}
