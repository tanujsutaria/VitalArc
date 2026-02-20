//
//  BodyCompositionEntryModel.swift
//  VitalArc
//
//  SwiftData Model for Body Measurement
//

import Foundation
import SwiftData

@Model
final class BodyCompositionEntryModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var weight: Double?              // kg
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

    /// Convert to domain entity
    func toDomain() -> BodyCompositionEntry {
        BodyCompositionEntry(
            id: id,
            date: date,
            weight: weight,
            bodyFatPercentage: bodyFatPercentage,
            waistCircumference: waistCircumference,
            hipCircumference: hipCircumference,
            chestCircumference: chestCircumference,
            armCircumference: armCircumference,
            thighCircumference: thighCircumference,
            neckCircumference: neckCircumference,
            notes: notes
        )
    }

    /// Create from domain entity
    static func fromDomain(_ measurement: BodyCompositionEntry) -> BodyCompositionEntryModel {
        BodyCompositionEntryModel(
            id: measurement.id,
            date: measurement.date,
            weight: measurement.weight,
            bodyFatPercentage: measurement.bodyFatPercentage,
            waistCircumference: measurement.waistCircumference,
            hipCircumference: measurement.hipCircumference,
            chestCircumference: measurement.chestCircumference,
            armCircumference: measurement.armCircumference,
            thighCircumference: measurement.thighCircumference,
            neckCircumference: measurement.neckCircumference,
            notes: measurement.notes
        )
    }
}
