//
//  ExerciseModel.swift
//  VitalArc
//
//  SwiftData Model for Exercise
//

import Foundation
import SwiftData

@Model
final class ExerciseModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var primaryMuscles: [String]
    var secondaryMuscles: [String]
    var equipment: String
    var instructions: String?

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        primaryMuscles: [String],
        secondaryMuscles: [String] = [],
        equipment: String,
        instructions: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.equipment = equipment
        self.instructions = instructions
    }

    /// Convert to domain entity
    func toDomain() -> Exercise {
        Exercise(
            id: id,
            name: name,
            category: ExerciseCategory(rawValue: category) ?? .push,
            primaryMuscles: primaryMuscles.compactMap { MuscleGroup(rawValue: $0) },
            secondaryMuscles: secondaryMuscles.compactMap { MuscleGroup(rawValue: $0) },
            equipment: Equipment(rawValue: equipment) ?? .bodyweight,
            instructions: instructions
        )
    }

    /// Create from domain entity
    static func fromDomain(_ exercise: Exercise) -> ExerciseModel {
        ExerciseModel(
            id: exercise.id,
            name: exercise.name,
            category: exercise.category.rawValue,
            primaryMuscles: exercise.primaryMuscles.map { $0.rawValue },
            secondaryMuscles: exercise.secondaryMuscles.map { $0.rawValue },
            equipment: exercise.equipment.rawValue,
            instructions: exercise.instructions
        )
    }
}
