//
//  SetGroup.swift
//  VitalArc
//
//  Domain entity for grouping exercises (supersets, circuits, giant sets)
//

import Foundation

struct SetGroup: Identifiable, Equatable {
    let id: UUID
    let name: String?
    let groupType: SetGroupType
    let exerciseIds: [UUID]

    init(
        id: UUID = UUID(),
        name: String? = nil,
        groupType: SetGroupType,
        exerciseIds: [UUID]
    ) {
        self.id = id
        self.name = name
        self.groupType = groupType
        self.exerciseIds = exerciseIds
    }

    var displayName: String {
        if let name = name {
            return name
        }
        return groupType.defaultName(count: exerciseIds.count)
    }
}

enum SetGroupType: String, CaseIterable, Codable {
    case superset = "Superset"
    case circuit = "Circuit"
    case giantSet = "Giant Set"

    var icon: String {
        switch self {
        case .superset: return "arrow.triangle.2.circlepath"
        case .circuit: return "arrow.3.trianglepath"
        case .giantSet: return "arrow.triangle.2.circlepath.circle.fill"
        }
    }

    func defaultName(count: Int) -> String {
        switch self {
        case .superset: return "Superset (\(count) exercises)"
        case .circuit: return "Circuit (\(count) exercises)"
        case .giantSet: return "Giant Set (\(count) exercises)"
        }
    }
}
