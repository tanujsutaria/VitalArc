//
//  WaterEntry.swift
//  VitalArc
//
//  Domain Entity for Water Entry
//

import Foundation

/// Domain entity representing a logged water intake entry
struct WaterEntry: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let amount: Double // in milliliters

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        amount: Double
    ) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}
