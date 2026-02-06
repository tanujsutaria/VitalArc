//
//  WaterEntryModel.swift
//  VitalArc
//
//  SwiftData Model for Water Entry
//

import Foundation
import SwiftData

@Model
final class WaterEntryModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var amount: Double // in milliliters

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        amount: Double
    ) {
        self.id = id
        self.date = date
        self.amount = amount
    }

    /// Convert to domain entity
    func toDomain() -> WaterEntry {
        WaterEntry(
            id: id,
            date: date,
            amount: amount
        )
    }

    /// Create from domain entity
    static func fromDomain(_ entry: WaterEntry) -> WaterEntryModel {
        WaterEntryModel(
            id: entry.id,
            date: entry.date,
            amount: entry.amount
        )
    }
}
