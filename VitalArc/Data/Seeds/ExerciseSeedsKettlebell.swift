//
//  ExerciseSeedsKettlebell.swift
//  VitalArc
//
//  Kettlebell Exercise Database (60+ exercises)
//

import Foundation

extension ExerciseSeeds {
    static let kettlebellExercises: [Exercise] = [
        // MARK: - Kettlebell Ballistic (15)
        Exercise(
            name: "Kettlebell Swing",
            category: .olympic,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings, .lowerBack, .shoulders],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound,
            muscleActivation: [.glutes: 1.0, .hamstrings: 0.9, .lowerBack: 0.7],
            commonMistakes: ["Squatting instead of hinging", "Using arms to lift", "Not full hip extension"],
            cues: ["Hip hinge", "Explosive hip thrust", "Float the weight", "Keep arms straight"]
        ),
        Exercise(
            name: "Russian Kettlebell Swing",
            category: .olympic,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings, .lowerBack],
            equipment: .kettlebell,
            instructions: "Swing to eye level",
difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "American Kettlebell Swing",
            category: .olympic,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings, .shoulders],
            equipment: .kettlebell,
            instructions: "Swing overhead",
difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Single Arm Kettlebell Swing",
            category: .olympic,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings, .obliques],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Snatch",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.glutes, .hamstrings],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Double Kettlebell Swing",
            category: .olympic,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings, .lowerBack],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Double Kettlebell Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Double Kettlebell Snatch",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.glutes, .hamstrings],
            equipment: .kettlebell,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Alternating Kettlebell Swing",
            category: .olympic,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings, .abs],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell High Pull",
            category: .olympic,
            primaryMuscles: [.traps],
            secondaryMuscles: [.shoulders, .glutes],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Hang Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Dead Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .hamstrings],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Double Arm Swing",
            category: .olympic,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Hand Swing to Clean",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .glutes],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),

        // MARK: - Kettlebell Press (15)
        Exercise(
            name: "Kettlebell Shoulder Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Double Kettlebell Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Push Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Jerk",
            category: .olympic,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .quadriceps],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "See-Saw Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .kettlebell,
            instructions: "Alternating double KB press",
difficulty: .advanced,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Kettlebell Floor Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Bottoms Up Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .forearms],
            equipment: .kettlebell,
            instructions: "Press with KB upside down",
difficulty: .advanced,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Kettlebell Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Alternating Kettlebell Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Z Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Thruster",
            category: .olympic,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.shoulders, .glutes],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Double Kettlebell Thruster",
            category: .olympic,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.shoulders, .glutes],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Floor Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .abs],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Military Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Clean and Press",
            category: .olympic,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),

        // MARK: - Kettlebell Squat & Lunge (12)
        Exercise(
            name: "Kettlebell Goblet Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .abs],
            equipment: .kettlebell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Double Kettlebell Front Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .abs],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Pistol Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Lunge",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .kettlebell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Reverse Lunge",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .kettlebell,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Bulgarian Split Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Overhead Kettlebell Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.shoulders, .abs],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Suitcase Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.obliques, .abs],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Cossack Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.adductors, .glutes],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Curtsy Lunge",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.quadriceps],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Rack Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .abs],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Double Racked Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .abs],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),

        // MARK: - Kettlebell Row & Pull (10)
        Exercise(
            name: "Kettlebell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .upperBack],
            equipment: .kettlebell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Renegade Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.abs, .biceps],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Gorilla Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .abs],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Double Kettlebell Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .lowerBack],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Plank Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.abs, .biceps],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Pullover",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.chest],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dead Stop Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Upright Row",
            category: .pull,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.traps],
            equipment: .kettlebell,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Suitcase Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.obliques, .biceps],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Alternating Renegade Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.abs, .biceps],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),

        // MARK: - Kettlebell Core & Carries (8)
        Exercise(
            name: "Turkish Get-Up",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [.shoulders, .quadriceps, .fullBody],
            equipment: .kettlebell,
            instructions: "Ground to standing with KB overhead",
difficulty: .advanced,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Kettlebell Windmill",
            category: .core,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.shoulders, .hamstrings],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Farmer's Walk",
            category: .strongman,
            primaryMuscles: [.forearms],
            secondaryMuscles: [.traps, .abs],
            equipment: .kettlebell,
            difficulty: .beginner,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Overhead Carry",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs, .triceps],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Rack Walk",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Waiter's Walk",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs, .obliques],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Suitcase Carry",
            category: .strongman,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.forearms, .abs],
            equipment: .kettlebell,
            difficulty: .beginner,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Kettlebell Halo",
            category: .mobility,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs],
            equipment: .kettlebell,
            instructions: "Circle KB around head",
difficulty: .beginner,
            forceType: .push,
            mechanic: .compound,

        ),
    ]
}
