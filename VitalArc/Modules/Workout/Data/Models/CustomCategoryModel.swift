//
//  CustomCategoryModel.swift
//  VitalArc
//
//  SwiftData Model for Custom Exercise Category
//

import Foundation
import SwiftData

@Model
final class CustomCategoryModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var sortOrder: Int
    var createdAt: Date

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

    /// Convert to domain entity
    func toDomain() -> CustomCategory {
        CustomCategory(
            id: id,
            name: name,
            icon: icon,
            sortOrder: sortOrder,
            createdAt: createdAt
        )
    }

    /// Create from domain entity
    static func fromDomain(_ category: CustomCategory) -> CustomCategoryModel {
        CustomCategoryModel(
            id: category.id,
            name: category.name,
            icon: category.icon,
            sortOrder: category.sortOrder,
            createdAt: category.createdAt
        )
    }
}
