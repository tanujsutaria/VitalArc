//
//  UserProfileModel.swift
//  VitalArc
//
//  SwiftData Model for User Profile
//

import Foundation
import SwiftData

@Model
final class UserProfileModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthDate: Date
    var biologicalSex: String
    var height: Double
    var weight: Double
    var activityLevel: String
    var weightGoal: String
    var customHRMax: Int?
    var customHRResting: Int?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        biologicalSex: String,
        height: Double,
        weight: Double,
        activityLevel: String,
        weightGoal: String = "Maintain Weight",
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

    /// Convert to domain entity
    func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            name: name,
            birthDate: birthDate,
            biologicalSex: BiologicalSex(rawValue: biologicalSex) ?? .other,
            height: height,
            weight: weight,
            activityLevel: ActivityLevel(rawValue: activityLevel) ?? .moderate,
            weightGoal: WeightGoal(rawValue: weightGoal) ?? .maintain,
            customHRMax: customHRMax,
            customHRResting: customHRResting,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    /// Create from domain entity
    static func fromDomain(_ profile: UserProfile) -> UserProfileModel {
        UserProfileModel(
            id: profile.id,
            name: profile.name,
            birthDate: profile.birthDate,
            biologicalSex: profile.biologicalSex.rawValue,
            height: profile.height,
            weight: profile.weight,
            activityLevel: profile.activityLevel.rawValue,
            weightGoal: profile.weightGoal.rawValue,
            customHRMax: profile.customHRMax,
            customHRResting: profile.customHRResting,
            createdAt: profile.createdAt,
            updatedAt: profile.updatedAt
        )
    }
}
