//
//  ExerciseSeedsDumbbell.swift
//  VitalArc
//
//  Dumbbell Exercise Database (200+ exercises)
//

import Foundation

extension ExerciseSeeds {
    static let dumbbellExercises: [Exercise] = [
        // MARK: - Chest Press Variations (25)
        Exercise(
            name: "Dumbbell Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound,
            muscleActivation: [.chest: 1.0, .triceps: 0.6, .shoulders: 0.4],
            commonMistakes: ["Going too heavy", "Not full range of motion", "Bouncing dumbbells"],
            cues: ["Retract scapula", "Lower deep", "Press and squeeze", "Control the weight"]
        ),
        Exercise(
            name: "Incline Dumbbell Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders, .triceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound,
            muscleActivation: [.chest: 1.0, .shoulders: 0.7, .triceps: 0.5]
        ),
        Exercise(
            name: "Decline Dumbbell Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Flat Dumbbell Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation,
            cues: ["Slight elbow bend", "Feel chest stretch", "Arc motion", "Squeeze at top"]
        ),
        Exercise(
            name: "Incline Dumbbell Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Decline Dumbbell Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Hex Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            instructions: "Press dumbbells together, squeeze chest",
difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Dumbbell Floor Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Dumbbell Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Alternating Dumbbell Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Pause Dumbbell Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Tempo Dumbbell Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Neutral Grip Dumbbell Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Close Grip Dumbbell Press",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Pullover",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.lats, .triceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Decline Dumbbell Pullover",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.lats],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cross Body Dumbbell Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Reverse Grip Dumbbell Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Dumbbell Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Squeeze Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Swiss Ball Dumbbell Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "1.5 Rep Dumbbell Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Alternating Dumbbell Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Incline Neutral Grip Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Crush Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            instructions: "Press two dumbbells together throughout movement",
difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound,

        ),

        // MARK: - Shoulder Press Variations (30)
        Exercise(
            name: "Dumbbell Shoulder Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound,
            muscleActivation: [.shoulders: 1.0, .triceps: 0.6]
        ),
        Exercise(
            name: "Seated Dumbbell Shoulder Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Standing Dumbbell Shoulder Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Arnold Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            instructions: "Rotate palms from facing you to facing forward",
difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Single Arm Dumbbell Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .obliques],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Alternating Dumbbell Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Neutral Grip Dumbbell Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Push Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Lateral Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation,
            muscleActivation: [.shoulders: 1.0],
            cues: ["Slight elbow bend", "Lead with elbows", "Control descent", "Don't swing"]
        ),
        Exercise(
            name: "Seated Lateral Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Arm Lateral Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Leaning Lateral Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .dumbbell,
            instructions: "Hold onto stable object, lean away",
difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation,

        ),
        Exercise(
            name: "Dumbbell Front Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Alternating Front Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Rear Delt Fly",
            category: .push,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.upperBack],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Bent Over Rear Delt Fly",
            category: .push,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.upperBack],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Seated Rear Delt Fly",
            category: .push,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Incline Rear Delt Fly",
            category: .push,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Upright Row",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.traps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Cuban Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.rearDelts],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell High Pull",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.traps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Scott Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Clean and Press",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.quadriceps, .glutes],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Lu Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.traps],
            equipment: .dumbbell,
            instructions: "Front raise above head, then out to sides",
difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation,

        ),
        Exercise(
            name: "Y Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.upperBack],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "W Raise",
            category: .push,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.shoulders],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Prone Lateral Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "6-Way Shoulder Raise",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Scarecrow",
            category: .push,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.shoulders],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Bradford Press (Dumbbell)",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),

        // MARK: - Back Row Variations (30)
        Exercise(
            name: "Dumbbell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .upperBack],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound,
            muscleActivation: [.lats: 1.0, .biceps: 0.6, .upperBack: 0.7]
        ),
        Exercise(
            name: "Single Arm Dumbbell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .upperBack],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound,
            cues: ["Support on bench", "Pull to hip", "Squeeze back", "Control descent"]
        ),
        Exercise(
            name: "Bent Over Dumbbell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .lowerBack],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Chest Supported Dumbbell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .upperBack],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Incline Dumbbell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Seal Row (Dumbbell)",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .biceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Gorilla Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .abs],
            equipment: .dumbbell,
            instructions: "Alternating rows in plank position",
difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Renegade Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .abs],
            equipment: .dumbbell,
            instructions: "Row from plank position on dumbbells",
difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Plank Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.abs, .biceps],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Kroc Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .traps],
            equipment: .dumbbell,
            instructions: "Heavy single arm row with body english",
difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Meadows Row (Dumbbell)",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Yates Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Elbow Out Dumbbell Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.rearDelts, .biceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Pause Dumbbell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Tempo Dumbbell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Standing Two Arm Dumbbell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .lowerBack],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Neutral Grip Dumbbell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Wide Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.rearDelts],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Kneeling Single Arm Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Three Point Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Dead Stop Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Pendlay Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .biceps],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Swiss Ball Dumbbell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Incline Single Arm Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Batwing Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats],
            equipment: .dumbbell,
            instructions: "Row and hold at top, isometric contraction",
difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound,

        ),
        Exercise(
            name: "Inverted Row Hold",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .biceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Bird Dog Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.abs, .glutes],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Alternating Dumbbell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Eccentric Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            instructions: "Emphasize 5+ second negative",
difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Dumbbell Shrug",
            category: .pull,
            primaryMuscles: [.traps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),

        // MARK: - Bicep Exercises (25)
        Exercise(
            name: "Dumbbell Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [.forearms],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation,
            muscleActivation: [.biceps: 1.0, .forearms: 0.4]
        ),
        Exercise(
            name: "Alternating Dumbbell Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Hammer Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [.forearms],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation,
            cues: ["Neutral grip", "Elbows stable", "No swinging", "Squeeze at top"]
        ),
        Exercise(
            name: "Cross Body Hammer Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [.forearms],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Incline Dumbbell Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            instructions: "Increases stretch on biceps",
difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation,

        ),
        Exercise(
            name: "Preacher Curl (Dumbbell)",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Concentration Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Spider Curl (Dumbbell)",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Zottman Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [.forearms],
            equipment: .dumbbell,
            instructions: "Curl supinated, lower pronated",
difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation,

        ),
        Exercise(
            name: "Waiter Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            instructions: "Hold one dumbbell underneath top plate",
difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation,

        ),
        Exercise(
            name: "Prone Incline Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Decline Dumbbell Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Standing Hammer Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [.forearms],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Seated Dumbbell Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "21s (Dumbbell)",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Reverse Curl (Dumbbell)",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [.biceps],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Drag Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Close Grip Dumbbell Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Wide Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Offset Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [.forearms],
            equipment: .dumbbell,
            instructions: "Hold dumbbell at one end for extra forearm work",
difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation,

        ),
        Exercise(
            name: "Twisting Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Pause Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Pinwheel Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [.forearms],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Lying Dumbbell Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Arm Preacher Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),

        // MARK: - Tricep Exercises (20)
        Exercise(
            name: "Dumbbell Overhead Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Arm Overhead Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Tricep Kickback",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Lying Tricep Extension (Dumbbell)",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Tate Press",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Floor Press (Close Grip)",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Incline Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Decline Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Neutral Grip Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Seated Overhead Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Alternating Overhead Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Swiss Ball Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cross Face Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Arm Kickback",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Two Arm Kickback",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Rolling Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Crush Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            instructions: "Press dumbbells together during extension",
difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation,

        ),
        Exercise(
            name: "Prone Dumbbell Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "JM Press (Dumbbell)",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kneeling Overhead Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),

        // MARK: - Leg Exercises (30)
        Exercise(
            name: "Dumbbell Goblet Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Lunge",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Reverse Lunge",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Walking Lunge",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Bulgarian Split Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Romanian Deadlift",
            category: .pull,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [.glutes, .lowerBack],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Leg Dumbbell Deadlift",
            category: .pull,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Step-up",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Sumo Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .adductors],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Lateral Lunge",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .adductors],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Curtsy Lunge",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.quadriceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Hip Thrust",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Calf Raise",
            category: .legs,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Leg Calf Raise (Dumbbell)",
            category: .legs,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "B-Stance Romanian Deadlift",
            category: .pull,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Box Step-up",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Deficit Reverse Lunge (Dumbbell)",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Swing",
            category: .olympic,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings, .shoulders],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Snatch",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.quadriceps, .glutes],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Clean",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.quadriceps, .glutes],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Farmer Walk",
            category: .strongman,
            primaryMuscles: [.forearms],
            secondaryMuscles: [.traps, .abs],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Farmer Walk",
            category: .strongman,
            primaryMuscles: [.forearms],
            secondaryMuscles: [.obliques, .abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Overhead Dumbbell Carry",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Rack Position Carry",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Suitcase Carry",
            category: .strongman,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.forearms, .abs],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Thrusters",
            category: .olympic,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.shoulders, .glutes],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Devil Press",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.chest, .quadriceps],
            equipment: .dumbbell,
            instructions: "Burpee + dumbbell snatch",
difficulty: .advanced,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Turkish Get-Up",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Deficit Goblet Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Pause Goblet Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),

        // MARK: - Forearm & Grip (10)
        Exercise(
            name: "Dumbbell Wrist Curl",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Reverse Wrist Curl",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Radial Deviation",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Ulnar Deviation",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Wrist Rotation",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Plate Pinch Grip",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dumbbell Hold",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .staticHold,
            mechanic: .isolation
        ),
        Exercise(
            name: "Fat Grip Dumbbell Hold",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .isolation
        ),
        Exercise(
            name: "Reverse Wrist Curl Over Bench",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Behind Back Wrist Curl",
            category: .pull,
            primaryMuscles: [.forearms],
            secondaryMuscles: [],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
    ]
}
