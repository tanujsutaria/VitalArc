//
//  ExerciseSeedsStrongman.swift
//  VitalArc
//
//  Strongman Exercise Database (50+ exercises)
//

import Foundation

extension ExerciseSeeds {
    static let strongmanExercises: [Exercise] = [
        // MARK: - Carries (15)
        Exercise(
            name: "Farmer's Walk",
            category: .strongman,
            primaryMuscles: [.forearms],
            secondaryMuscles: [.traps, .abs, .quadriceps],
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound,
            muscleActivation: [.forearms: 1.0, .traps: 0.9, .abs: 0.7],
            commonMistakes: ["Rounding shoulders", "Looking down", "Short steps"],
            cues: ["Shoulders back", "Chest up", "Walk controlled", "Grip tight"]
        ),
        Exercise(
            name: "Yoke Walk",
            category: .strongman,
            primaryMuscles: [.traps],
            secondaryMuscles: [.quadriceps, .abs, .glutes],
            equipment: .yoke,
            difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Frame Carry",
            category: .strongman,
            primaryMuscles: [.forearms],
            secondaryMuscles: [.traps, .quadriceps],
            equipment: .yoke,
            difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Sandbag Carry",
            category: .strongman,
            primaryMuscles: [.forearms],
            secondaryMuscles: [.abs, .quadriceps],
            equipment: .medicineBall,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Atlas Stone Carry",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.biceps, .abs],
            equipment: .medicineBall,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Keg Carry",
            category: .strongman,
            primaryMuscles: [.abs],
            secondaryMuscles: [.forearms, .quadriceps],
            equipment: .medicineBall,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Duck Walk",
            category: .strongman,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .abs],
            equipment: .medicineBall,
            instructions: "Walk with weight racked on shoulders",
difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .compound,

        ),
        Exercise(
            name: "Zercher Carry",
            category: .strongman,
            primaryMuscles: [.abs],
            secondaryMuscles: [.biceps, .quadriceps],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Overhead Carry",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs, .triceps],
            equipment: .barbell,
            difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Overhead Carry",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.obliques, .abs],
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
            equipment: .dumbbell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Cross Body Carry",
            category: .strongman,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.shoulders, .abs],
            equipment: .medicineBall,
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
            name: "Rack Walk",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs, .quadriceps],
            equipment: .kettlebell,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Conan's Wheel",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.traps, .quadriceps],
            equipment: .yoke,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),

        // MARK: - Pressing (10)
        Exercise(
            name: "Log Press",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .logPress,
            instructions: "Clean log to chest, press overhead",
difficulty: .advanced,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Axle Press",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .forearms],
            equipment: .barbell,
            instructions: "Thick bar overhead press",
difficulty: .advanced,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Viking Press",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .barbell,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Circus Dumbbell Press",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .dumbbell,
            instructions: "Very heavy single dumbbell overhead",
difficulty: .expert,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Log Clean and Press",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .logPress,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Keg Press",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .medicineBall,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Sandbag Press",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .medicineBall,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Stone Press",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .medicineBall,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Axle Continental Press",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .barbell,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "One Arm Overhead Press for Reps",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .obliques],
            equipment: .kettlebell,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),

        // MARK: - Dragging & Pulling (10)
        Exercise(
            name: "Sled Push",
            category: .strongman,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .calves],
            equipment: .sled,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Sled Drag",
            category: .strongman,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .hamstrings],
            equipment: .sled,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Prowler Push",
            category: .strongman,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .shoulders],
            equipment: .sled,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Backward Sled Drag",
            category: .strongman,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .sled,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Truck Pull",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.quadriceps, .lats],
            equipment: .sled,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Rope Pull",
            category: .strongman,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .forearms],
            equipment: .cable,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Harness Drag",
            category: .strongman,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .hamstrings],
            equipment: .sled,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Chain Drag",
            category: .strongman,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .sled,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Sled Row",
            category: .strongman,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .quadriceps],
            equipment: .sled,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Reverse Sled Drag",
            category: .strongman,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [.glutes],
            equipment: .sled,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),

        // MARK: - Lifting & Loading (15)
        Exercise(
            name: "Tire Flip",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.hamstrings, .glutes, .shoulders],
            equipment: .tireFlip,
            instructions: "Deadlift tire, then push/press to flip",
difficulty: .advanced,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Atlas Stone Lift",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.biceps, .lowerBack],
            equipment: .medicineBall,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Atlas Stone to Shoulder",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .biceps],
            equipment: .medicineBall,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Sandbag Load",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.abs, .shoulders],
            equipment: .medicineBall,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Sandbag to Shoulder",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .abs],
            equipment: .medicineBall,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Keg Toss",
            category: .strongman,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .medicineBall,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Sandbag Over Bar",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .abs],
            equipment: .medicineBall,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Barrel Load",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .abs],
            equipment: .medicineBall,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Platform Deadlift",
            category: .strongman,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [.back, .glutes],
            equipment: .barbell,
            instructions: "Deadlift onto elevated platform",
difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Car Deadlift",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.hamstrings, .back],
            equipment: .yoke,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Fingal Fingers",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .yoke,
            instructions: "Flip heavy poles end over end",
difficulty: .expert,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Husafell Stone",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.abs, .forearms],
            equipment: .medicineBall,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Sandbag Clean",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .quadriceps],
            equipment: .medicineBall,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Sandbag Shouldering",
            category: .strongman,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.shoulders, .abs],
            equipment: .medicineBall,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Duck Walk (Loaded)",
            category: .strongman,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .abs],
            equipment: .medicineBall,
            difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .compound
        ),
    ]
}
