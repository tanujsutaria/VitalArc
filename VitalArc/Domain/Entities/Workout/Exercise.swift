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

    // Enhanced metadata
    let videoURL: String?
    let imageURL: String?
    let difficulty: ExerciseDifficulty?
    let forceType: ForceType?
    let mechanic: MechanicType?
    let muscleActivation: [MuscleGroup: Double]?
    let commonMistakes: [String]?
    let cues: [String]?
    let variations: [UUID]?
    let prerequisites: [UUID]?

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory,
        primaryMuscles: [MuscleGroup],
        secondaryMuscles: [MuscleGroup] = [],
        equipment: Equipment,
        instructions: String? = nil,
        videoURL: String? = nil,
        imageURL: String? = nil,
        difficulty: ExerciseDifficulty? = nil,
        forceType: ForceType? = nil,
        mechanic: MechanicType? = nil,
        muscleActivation: [MuscleGroup: Double]? = nil,
        commonMistakes: [String]? = nil,
        cues: [String]? = nil,
        variations: [UUID]? = nil,
        prerequisites: [UUID]? = nil
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
        self.muscleActivation = muscleActivation
        self.commonMistakes = commonMistakes
        self.cues = cues
        self.variations = variations
        self.prerequisites = prerequisites
    }
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case core = "Core"
    case cardio = "Cardio"
    case olympic = "Olympic Lifts"
    case strongman = "Strongman"
    case calisthenics = "Calisthenics"
    case plyometrics = "Plyometrics"
    case mobility = "Mobility"
}

enum MuscleGroup: String, Codable, CaseIterable {
    // Upper Body
    case chest = "Chest"
    case shoulders = "Shoulders"
    case triceps = "Triceps"
    case biceps = "Biceps"
    case forearms = "Forearms"
    case upperBack = "Upper Back"
    case lowerBack = "Lower Back"
    case lats = "Lats"
    case traps = "Traps"
    case rearDelts = "Rear Delts"
    case back = "Back"

    // Lower Body
    case quadriceps = "Quadriceps"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case calves = "Calves"
    case hipFlexors = "Hip Flexors"
    case adductors = "Adductors"
    case abductors = "Abductors"

    // Core
    case abs = "Abs"
    case obliques = "Obliques"
    case serratus = "Serratus"

    // Full Body
    case fullBody = "Full Body"
}

enum Equipment: String, Codable, CaseIterable {
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case machine = "Machine"
    case cable = "Cable"
    case bodyweight = "Bodyweight"
    case resistance = "Resistance Band"
    case kettlebell = "Kettlebell"
    case ezBar = "EZ Bar"
    case trapBar = "Trap Bar"
    case medicineBall = "Medicine Ball"
    case suspensionTrainer = "TRX/Suspension"
    case sled = "Sled"
    case tireFlip = "Tire"
    case yoke = "Yoke"
    case logPress = "Log Press"
    case smithMachine = "Smith Machine"
    case safetyBar = "Safety Squat Bar"
}

enum ExerciseDifficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
}

enum ForceType: String, Codable, CaseIterable {
    case push = "Push"
    case pull = "Pull"
    case staticHold = "Static"
}

enum MechanicType: String, Codable, CaseIterable {
    case compound = "Compound"
    case isolation = "Isolation"
}
