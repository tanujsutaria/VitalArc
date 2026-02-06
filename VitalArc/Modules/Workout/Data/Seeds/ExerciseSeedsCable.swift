//
//  ExerciseSeedsCable.swift
//  VitalArc
//
//  Cable Exercise Database (100+ exercises)
//

import Foundation

extension ExerciseSeeds {
    static let cableExercises: [Exercise] = [
        // MARK: - Cable Chest (15)
        Exercise(
            name: "Cable Chest Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Crossover",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Low to High Cable Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "High to Low Cable Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Arm Cable Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Standing Cable Chest Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .abs],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Incline Cable Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Decline Cable Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Squeeze Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Archer Cable Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Hex Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kneeling Cable Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Arm Cable Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .abs],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Alternating Cable Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .abs],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),

        // MARK: - Cable Back (20)
        Exercise(
            name: "Cable Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .biceps],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound,
            muscleActivation: [.upperBack: 1.0, .lats: 0.8, .biceps: 0.6]
        ),
        Exercise(
            name: "Wide Grip Cable Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Close Grip Cable Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Cable Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Face Pull",
            category: .pull,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.upperBack, .traps],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound,
            cues: ["Pull to face", "Externally rotate", "Squeeze shoulder blades"]
        ),
        Exercise(
            name: "Cable Pullover",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.chest],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Straight Arm Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Y Raise",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.shoulders],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Reverse Fly",
            category: .pull,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.upperBack],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Shrug",
            category: .pull,
            primaryMuscles: [.traps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable High Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.rearDelts],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Low Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Underhand Cable Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Pulldown to Waist",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Crossover Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Rope Face Pull",
            category: .pull,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.traps],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Pull-Through",
            category: .pull,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Standing Cable Pullover",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Kneeling Cable Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Cable Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),

        // MARK: - Cable Shoulders (15)
        Exercise(
            name: "Cable Lateral Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Front Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Arm Cable Lateral Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Upright Row",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.traps],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Shoulder Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Leaning Cable Lateral Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Y Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.upperBack],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable W Raise",
            category: .push,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.shoulders],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Internal Rotation",
            category: .mobility,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable External Rotation",
            category: .mobility,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Single Arm Front Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Crossbody Cable Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Scarecrow",
            category: .pull,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.shoulders],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Cuban Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.rearDelts],
            equipment: .cable,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Behind Back Cable Lateral Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),

        // MARK: - Cable Arms (20)
        Exercise(
            name: "Cable Tricep Pushdown",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Rope Tricep Pushdown",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Overhead Cable Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Arm Cable Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Tricep Kickback",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Bicep Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Hammer Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [.forearms],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "High Cable Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Arm Cable Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Preacher Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Reverse Curl",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [.biceps],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Concentration Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Overhead Cable Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Drag Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Wrist Curl",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Reverse Wrist Curl",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Behind Back Cable Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Lying Cable Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Spider Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Bayesian Cable Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .cable,
            instructions: "Behind body cable curl for maximum stretch",
difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation,

        ),

        // MARK: - Cable Core & Legs (30)
        Exercise(
            name: "Cable Crunch",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Woodchop",
            category: .core,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.abs],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Pallof Press",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [.obliques],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound,
            cues: ["Resist rotation", "Press straight out", "Keep hips square"]
        ),
        Exercise(
            name: "Cable Side Bend",
            category: .core,
            primaryMuscles: [.obliques],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .staticHold,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Twist",
            category: .core,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.abs],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Kneeling Cable Crunch",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Standing Cable Crunch",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Russian Twist",
            category: .core,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.abs],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Half Kneeling Cable Chop",
            category: .core,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.abs],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Oblique Crunch",
            category: .core,
            primaryMuscles: [.obliques],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Kickback",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Hip Abduction",
            category: .legs,
            primaryMuscles: [.abductors],
            secondaryMuscles: [.glutes],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Hip Adduction",
            category: .legs,
            primaryMuscles: [.adductors],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Standing Hip Extension",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Pull-Through",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Leg Cable Kickback",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Lunge",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Leg Curl",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Calf Raise",
            category: .legs,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Hip Flexion",
            category: .legs,
            primaryMuscles: [.hipFlexors],
            secondaryMuscles: [],
            equipment: .cable,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Good Morning",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [.glutes, .lowerBack],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Anti-Rotation Press",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [.obliques],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Overhead Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.shoulders, .abs],
            equipment: .cable,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Rainbow",
            category: .core,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.abs, .shoulders],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Glute Bridge",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Reverse Lunge",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Single Leg Deadlift",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [.glutes],
            equipment: .cable,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Step-up",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Cable Bulgarian Split Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .cable,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
    ]
}
