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

    // Enhanced metadata
    var videoURL: String?
    var imageURL: String?
    var difficulty: String?
    var forceType: String?
    var mechanic: String?
    var muscleActivationData: Data?
    var commonMistakes: [String]?
    var cues: [String]?
    var variationIDs: [UUID]?
    var prerequisiteIDs: [UUID]?

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        primaryMuscles: [String],
        secondaryMuscles: [String] = [],
        equipment: String,
        instructions: String? = nil,
        videoURL: String? = nil,
        imageURL: String? = nil,
        difficulty: String? = nil,
        forceType: String? = nil,
        mechanic: String? = nil,
        muscleActivationData: Data? = nil,
        commonMistakes: [String]? = nil,
        cues: [String]? = nil,
        variationIDs: [UUID]? = nil,
        prerequisiteIDs: [UUID]? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.equipment = equipment
        self.instructions = instructions
        self.videoURL = videoURL
        self.imageURL = imageURL
        self.difficulty = difficulty
        self.forceType = forceType
        self.mechanic = mechanic
        self.muscleActivationData = muscleActivationData
        self.commonMistakes = commonMistakes
        self.cues = cues
        self.variationIDs = variationIDs
        self.prerequisiteIDs = prerequisiteIDs
    }

    /// Convert to domain entity
    func toDomain() -> Exercise {
        // Decode muscle activation
        var activationMap: [MuscleGroup: Double]? = nil
        if let data = muscleActivationData {
            activationMap = try? JSONDecoder().decode([String: Double].self, from: data)
                .reduce(into: [MuscleGroup: Double]()) { result, pair in
                    if let muscle = MuscleGroup(rawValue: pair.key) {
                        result[muscle] = pair.value
                    }
                }
        }

        return Exercise(
            id: id,
            name: name,
            category: ExerciseCategory(rawValue: category) ?? .push,
            primaryMuscles: primaryMuscles.compactMap { MuscleGroup(rawValue: $0) },
            secondaryMuscles: secondaryMuscles.compactMap { MuscleGroup(rawValue: $0) },
            equipment: Equipment(rawValue: equipment) ?? .bodyweight,
            instructions: instructions,
            videoURL: videoURL,
            imageURL: imageURL,
            difficulty: difficulty.flatMap { ExerciseDifficulty(rawValue: $0) },
            forceType: forceType.flatMap { ForceType(rawValue: $0) },
            mechanic: mechanic.flatMap { MechanicType(rawValue: $0) },
            muscleActivation: activationMap,
            commonMistakes: commonMistakes,
            cues: cues,
            variations: variationIDs,
            prerequisites: prerequisiteIDs
        )
    }

    /// Create from domain entity
    static func fromDomain(_ exercise: Exercise) -> ExerciseModel {
        // Encode muscle activation
        var activationData: Data? = nil
        if let activation = exercise.muscleActivation {
            let stringDict = activation.reduce(into: [String: Double]()) { result, pair in
                result[pair.key.rawValue] = pair.value
            }
            activationData = try? JSONEncoder().encode(stringDict)
        }

        return ExerciseModel(
            id: exercise.id,
            name: exercise.name,
            category: exercise.category.rawValue,
            primaryMuscles: exercise.primaryMuscles.map { $0.rawValue },
            secondaryMuscles: exercise.secondaryMuscles.map { $0.rawValue },
            equipment: exercise.equipment.rawValue,
            instructions: exercise.instructions,
            videoURL: exercise.videoURL,
            imageURL: exercise.imageURL,
            difficulty: exercise.difficulty?.rawValue,
            forceType: exercise.forceType?.rawValue,
            mechanic: exercise.mechanic?.rawValue,
            muscleActivationData: activationData,
            commonMistakes: exercise.commonMistakes,
            cues: exercise.cues,
            variationIDs: exercise.variations,
            prerequisiteIDs: exercise.prerequisites
        )
    }
}
