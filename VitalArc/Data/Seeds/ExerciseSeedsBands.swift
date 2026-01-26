//
//  ExerciseSeedsBands.swift
//  VitalArc
//
//  Resistance Band Exercise Database (50+ exercises)
//

import Foundation

extension ExerciseSeeds {
    static let bandsExercises: [Exercise] = [
        // MARK: - Band Chest (8)
        Exercise(
            name: "Band Chest Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Chest Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Incline Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders, .triceps],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Crossover",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Push-up",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .resistance,
            instructions: "Push-up with band around back",
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Band Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .abs],
            equipment: .resistance,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Decline Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Svend Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),

        // MARK: - Band Back (12)
        Exercise(
            name: "Band Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .biceps],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Face Pull",
            category: .pull,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.upperBack, .traps],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Pull Apart",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.rearDelts],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation,
            cues: ["Keep arms straight", "Pull band to chest", "Squeeze shoulder blades"]
        ),
        Exercise(
            name: "Band Single Arm Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Straight Arm Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Reverse Fly",
            category: .pull,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.upperBack],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Shrug",
            category: .pull,
            primaryMuscles: [.traps],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Y Raise",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.shoulders],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band W Raise",
            category: .pull,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.upperBack],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Assisted Pull-up",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .resistance,
            instructions: "Band assists at bottom of pull-up",
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Band High Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.rearDelts],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),

        // MARK: - Band Shoulders (10)
        Exercise(
            name: "Band Shoulder Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Lateral Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Front Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Upright Row",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.traps],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Arnold Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .resistance,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Band External Rotation",
            category: .mobility,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .resistance,
            instructions: "Shoulder rehab/prehab exercise",
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Internal Rotation",
            category: .mobility,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Cuban Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.rearDelts],
            equipment: .resistance,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Around the World",
            category: .mobility,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.chest],
            equipment: .resistance,
            instructions: "Shoulder mobility drill",
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Overhead Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),

        // MARK: - Band Arms (8)
        Exercise(
            name: "Band Bicep Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Hammer Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [.forearms],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Tricep Pushdown",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Overhead Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Concentration Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Reverse Curl",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [.biceps],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Kickback",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),

        // MARK: - Band Legs (12)
        Exercise(
            name: "Band Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Leg Press",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Glute Bridge",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Hip Abduction",
            category: .legs,
            primaryMuscles: [.abductors],
            secondaryMuscles: [.glutes],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Hip Adduction",
            category: .legs,
            primaryMuscles: [.adductors],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Kickback",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Leg Curl",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Good Morning",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [.glutes, .lowerBack],
            equipment: .resistance,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Lunge",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Pull-Through",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .resistance,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Band Clamshell",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.abductors],
            equipment: .resistance,
            instructions: "Hip external rotation exercise",
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Band Fire Hydrant",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.abductors],
            equipment: .resistance,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
    ]
}
