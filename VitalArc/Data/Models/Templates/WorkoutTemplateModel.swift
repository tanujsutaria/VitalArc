//
//  WorkoutTemplateModel.swift
//  VitalArc
//
//  SwiftData model for workout templates
//

import Foundation
import SwiftData

@Model
final class WorkoutTemplateModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var templateDescription: String?
    var exercisesData: Data? // JSON encoded [TemplateExercise]
    var category: String
    var estimatedDuration: Int
    var createdAt: Date
    var lastUsed: Date?
    var useCount: Int

    init(
        id: UUID,
        name: String,
        templateDescription: String?,
        exercisesData: Data?,
        category: String,
        estimatedDuration: Int,
        createdAt: Date,
        lastUsed: Date?,
        useCount: Int
    ) {
        self.id = id
        self.name = name
        self.templateDescription = templateDescription
        self.exercisesData = exercisesData
        self.category = category
        self.estimatedDuration = estimatedDuration
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.useCount = useCount
    }

    // MARK: - Domain Conversion

    func toDomain() -> WorkoutTemplate {
        let exercises = decodeExercises()

        return WorkoutTemplate(
            id: id,
            name: name,
            description: templateDescription,
            exercises: exercises,
            category: TemplateCategory(rawValue: category) ?? .custom,
            estimatedDuration: estimatedDuration,
            createdAt: createdAt,
            lastUsed: lastUsed,
            useCount: useCount
        )
    }

    static func fromDomain(_ template: WorkoutTemplate) -> WorkoutTemplateModel {
        let exercisesData = encodeExercises(template.exercises)

        return WorkoutTemplateModel(
            id: template.id,
            name: template.name,
            templateDescription: template.description,
            exercisesData: exercisesData,
            category: template.category.rawValue,
            estimatedDuration: template.estimatedDuration,
            createdAt: template.createdAt,
            lastUsed: template.lastUsed,
            useCount: template.useCount
        )
    }

    // MARK: - Helpers

    private func decodeExercises() -> [TemplateExercise] {
        guard let data = exercisesData else { return [] }
        return (try? JSONDecoder().decode([CodableTemplateExercise].self, from: data))?
            .map { $0.toDomain() } ?? []
    }

    static func encodeExercises(_ exercises: [TemplateExercise]) -> Data? {
        let codableExercises = exercises.map { CodableTemplateExercise.fromDomain($0) }
        return try? JSONEncoder().encode(codableExercises)
    }
}

// MARK: - Codable Helper

private struct CodableTemplateExercise: Codable {
    let id: UUID
    let exerciseId: UUID
    let orderIndex: Int
    let sets: Int
    let repsMin: Int
    let repsMax: Int
    let restSeconds: Int
    let notes: String?

    func toDomain() -> TemplateExercise {
        TemplateExercise(
            id: id,
            exerciseId: exerciseId,
            orderIndex: orderIndex,
            sets: sets,
            repsMin: repsMin,
            repsMax: repsMax,
            restSeconds: restSeconds,
            notes: notes
        )
    }

    static func fromDomain(_ exercise: TemplateExercise) -> CodableTemplateExercise {
        CodableTemplateExercise(
            id: exercise.id,
            exerciseId: exercise.exerciseId,
            orderIndex: exercise.orderIndex,
            sets: exercise.sets,
            repsMin: exercise.repsMin,
            repsMax: exercise.repsMax,
            restSeconds: exercise.restSeconds,
            notes: exercise.notes
        )
    }
}
