//
//  SetGroupModel.swift
//  VitalArc
//
//  SwiftData Model for Set Group (supersets, circuits, drop sets)
//

import Foundation
import SwiftData

@Model
final class SetGroupModel {
    @Attribute(.unique) var id: UUID
    var name: String?
    var groupType: String
    var exerciseIds: [UUID]
    var restBetweenExercises: TimeInterval
    var restAfterGroup: TimeInterval

    init(
        id: UUID = UUID(),
        name: String? = nil,
        groupType: String,
        exerciseIds: [UUID],
        restBetweenExercises: TimeInterval = 30,
        restAfterGroup: TimeInterval = 90
    ) {
        self.id = id
        self.name = name
        self.groupType = groupType
        self.exerciseIds = exerciseIds
        self.restBetweenExercises = restBetweenExercises
        self.restAfterGroup = restAfterGroup
    }

    /// Convert to domain entity
    func toDomain() -> SetGroup {
        SetGroup(
            id: id,
            name: name,
            groupType: SetGroupType(rawValue: groupType) ?? .superset,
            exerciseIds: exerciseIds,
            restBetweenExercises: restBetweenExercises,
            restAfterGroup: restAfterGroup
        )
    }

    /// Create from domain entity
    static func fromDomain(_ group: SetGroup) -> SetGroupModel {
        SetGroupModel(
            id: group.id,
            name: group.name,
            groupType: group.groupType.rawValue,
            exerciseIds: group.exerciseIds,
            restBetweenExercises: group.restBetweenExercises,
            restAfterGroup: group.restAfterGroup
        )
    }
}
