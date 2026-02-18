//
//  CustomCategory.swift
//  VitalArc
//
//  Domain Entity for Custom Exercise Category
//

import Foundation

/// Domain entity representing a user-created exercise category
struct CustomCategory: Identifiable, Equatable {
    let id: UUID
    let name: String
    let icon: String // SF Symbol name
    let sortOrder: Int
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "star.fill",
        sortOrder: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}
