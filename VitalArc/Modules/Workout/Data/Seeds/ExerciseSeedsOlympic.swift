//
//  ExerciseSeedsOlympic.swift
//  VitalArc
//
//  Olympic Lifts & Variations (60+ exercises)
//

import Foundation

extension ExerciseSeeds {
    static let olympicExercises: [Exercise] = [
        // MARK: - Clean Variations (20)
        Exercise(
            name: "Power Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .glutes, .shoulders, .traps],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,
            muscleActivation: [.fullBody: 1.0, .quadriceps: 0.9, .shoulders: 0.8, .traps: 0.9],
            commonMistakes: ["Pulling with arms too early", "Not full hip extension", "Catching on toes", "Jumping forward"],
            cues: ["Triple extension", "Fast elbows", "Catch in quarter squat", "Aggressive pull"]
        ),
        Exercise(
            name: "Squat Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .glutes, .shoulders],
            equipment: .barbell,
            instructions: "Full depth catch in front squat position",
difficulty: .expert,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Hang Power Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .shoulders, .traps],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Hang Squat Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .glutes, .shoulders],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Clean Pull",
            category: .olympic,
            primaryMuscles: [.traps, .hamstrings],
            secondaryMuscles: [.glutes, .quadriceps],
            equipment: .barbell,
            instructions: "Pull portion only, no catch",
difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Clean High Pull",
            category: .olympic,
            primaryMuscles: [.traps, .shoulders],
            secondaryMuscles: [.hamstrings, .quadriceps],
            equipment: .barbell,
            instructions: "Explosive pull, elbows high",
difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Hang Clean Pull",
            category: .olympic,
            primaryMuscles: [.traps, .hamstrings],
            secondaryMuscles: [.glutes],
            equipment: .barbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Clean Deadlift",
            category: .olympic,
            primaryMuscles: [.hamstrings, .back],
            secondaryMuscles: [.glutes, .traps],
            equipment: .barbell,
            instructions: "Deadlift with clean grip and posture",
difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Muscle Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .triceps],
            equipment: .barbell,
            instructions: "Clean without rebending knees",
difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Clean from Blocks",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .shoulders],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Deficit Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .hamstrings],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Pause Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .shoulders],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Clean + Front Squat",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .shoulders],
            equipment: .barbell,
            instructions: "Complex: 1 clean + 1-3 front squats",
difficulty: .expert,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Clean + Jerk",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .shoulders, .triceps],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Power Clean + Power Jerk",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Power Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Dumbbell Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .obliques],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Clean Grip Shrug",
            category: .olympic,
            primaryMuscles: [.traps],
            secondaryMuscles: [],
            equipment: .barbell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Tall Clean",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.quadriceps],
            equipment: .barbell,
            instructions: "Clean from standing, practice speed under bar",
difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Clean Complex",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .shoulders],
            equipment: .barbell,
            instructions: "Multiple clean variations in sequence",
difficulty: .expert,
            forceType: .push,
            mechanic: .compound,

        ),

        // MARK: - Snatch Variations (20)
        Exercise(
            name: "Power Snatch",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps, .traps],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound,
            muscleActivation: [.fullBody: 1.0, .shoulders: 0.9, .quadriceps: 0.8, .traps: 0.9],
            cues: ["Wide grip", "Fast turnover", "Catch overhead", "Full extension"]
        ),
        Exercise(
            name: "Squat Snatch",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps, .abs],
            equipment: .barbell,
            instructions: "Full depth catch overhead",
difficulty: .expert,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Hang Power Snatch",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .traps],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Hang Squat Snatch",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Snatch Pull",
            category: .olympic,
            primaryMuscles: [.traps, .hamstrings],
            secondaryMuscles: [.glutes, .shoulders],
            equipment: .barbell,
            instructions: "Pull only, no catch overhead",
difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Snatch High Pull",
            category: .olympic,
            primaryMuscles: [.traps, .shoulders],
            secondaryMuscles: [.hamstrings],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Snatch Deadlift",
            category: .olympic,
            primaryMuscles: [.hamstrings, .back],
            secondaryMuscles: [.glutes, .traps],
            equipment: .barbell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Snatch Grip Romanian Deadlift",
            category: .olympic,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [.glutes, .lowerBack],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Snatch Balance",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.quadriceps, .abs],
            equipment: .barbell,
            instructions: "Drop under bar into overhead squat",
difficulty: .expert,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Muscle Snatch",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.traps, .triceps],
            equipment: .barbell,
            instructions: "Snatch without rebending knees",
difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Snatch from Blocks",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Deficit Snatch",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.hamstrings, .shoulders],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Pause Snatch",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Overhead Squat",
            category: .olympic,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.shoulders, .abs, .glutes],
            equipment: .barbell,
            instructions: "Squat with bar overhead in snatch grip",
difficulty: .expert,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Heaving Snatch Balance",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.quadriceps],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Drop Snatch",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.quadriceps],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Snatch Push Press",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Tall Snatch",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.quadriceps],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Snatch Complex",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Snatch",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .dumbbell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),

        // MARK: - Jerk Variations (15)
        Exercise(
            name: "Push Jerk",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .barbell,
            instructions: "Dip, drive, press to lockout",
difficulty: .advanced,
            forceType: .push,
            mechanic: .compound,
            muscleActivation: [.shoulders: 1.0, .triceps: 0.7, .quadriceps: 0.5],

        ),
        Exercise(
            name: "Split Jerk",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .barbell,
            instructions: "Dip, drive, split stance catch",
difficulty: .expert,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Power Jerk",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Squat Jerk",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .barbell,
            instructions: "Catch in full squat under bar",
difficulty: .expert,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Push Press",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .barbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Jerk Dip",
            category: .olympic,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.shoulders, .abs],
            equipment: .barbell,
            instructions: "Practice dip portion of jerk",
difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound,

        ),
        Exercise(
            name: "Jerk Drive",
            category: .olympic,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.shoulders],
            equipment: .barbell,
            instructions: "Dip and drive, no catch",
difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Jerk Balance",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.quadriceps],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Behind Neck Jerk",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Jerk from Blocks",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Pause Jerk",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Jerk Recovery",
            category: .olympic,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.shoulders],
            equipment: .barbell,
            instructions: "Practice recovering from split/squat position",
difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Tall Jerk",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dumbbell Push Press",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Dumbbell Push Press",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .obliques],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),

        // MARK: - Full Olympic Movements & Complexes (5)
        Exercise(
            name: "Clean and Jerk",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .shoulders, .traps],
            equipment: .barbell,
            instructions: "Full clean + full jerk",
difficulty: .expert,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Snatch",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps, .traps],
            equipment: .barbell,
            instructions: "Ground to overhead in one motion",
difficulty: .expert,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Thruster",
            category: .olympic,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.shoulders, .glutes],
            equipment: .barbell,
            instructions: "Front squat into push press",
difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Dumbbell Thruster",
            category: .olympic,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.shoulders, .glutes],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Complex (Clean + Front Squat + Jerk)",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .shoulders],
            equipment: .barbell,
            instructions: "1 clean + 2 front squats + 1 jerk",
difficulty: .expert,
            forceType: .push,
            mechanic: .compound,

        ),
    ]
}
