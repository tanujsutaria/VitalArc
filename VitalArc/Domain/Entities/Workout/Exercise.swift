//
//  Exercise.swift
//  VitalArc
//
//  Domain Entity for Exercise
//

import Foundation

/// Domain entity representing an exercise
struct Exercise: Identifiable, Equatable {
    let id: UUID
    let name: String
    let category: ExerciseCategory
    let primaryMuscles: [MuscleGroup]
    let secondaryMuscles: [MuscleGroup]
    let equipment: Equipment
    let instructions: String?

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory,
        primaryMuscles: [MuscleGroup],
        secondaryMuscles: [MuscleGroup] = [],
        equipment: Equipment,
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
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case core = "Core"
    case cardio = "Cardio"
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest = "Chest"
    case shoulders = "Shoulders"
    case triceps = "Triceps"
    case back = "Back"
    case biceps = "Biceps"
    case forearms = "Forearms"
    case quadriceps = "Quadriceps"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case calves = "Calves"
    case abs = "Abs"
    case obliques = "Obliques"
}

enum Equipment: String, Codable, CaseIterable {
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case machine = "Machine"
    case cable = "Cable"
    case bodyweight = "Bodyweight"
    case resistance = "Resistance Band"
    case kettlebell = "Kettlebell"
}
