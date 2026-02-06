//
//  ExerciseSeedsMachine.swift
//  VitalArc
//
//  Machine Exercise Database (150+ exercises)
//

import Foundation

extension ExerciseSeeds {
    static let machineExercises: [Exercise] = [
        // MARK: - Leg Press & Squat Machines (20)
        Exercise(
            name: "Leg Press",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .hamstrings],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound,
            muscleActivation: [.quadriceps: 1.0, .glutes: 0.8, .hamstrings: 0.5],
            commonMistakes: ["Rounding lower back", "Not full range of motion", "Bouncing weight"],
            cues: ["Full range", "Press through heels", "Keep lower back flat", "Control the negative"]
        ),
        Exercise(
            name: "Hack Squat Machine",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "High Foot Leg Press",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings, .quadriceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Low Foot Leg Press",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Wide Stance Leg Press",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .adductors],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Narrow Stance Leg Press",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Leg Press",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Horizontal Leg Press",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "45 Degree Leg Press",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Vertical Leg Press",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Pendulum Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Belt Squat Machine",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Smith Machine Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .smithMachine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Smith Machine Front Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .smithMachine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Smith Machine Bulgarian Split Squat",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .smithMachine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Smith Machine Reverse Lunge",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .smithMachine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "V-Squat Machine",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Sissy Squat Machine",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Nautilus Squat Machine",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Cybex Squat Press",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),

        // MARK: - Leg Extension & Curl Machines (15)
        Exercise(
            name: "Leg Extension",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation,
            muscleActivation: [.quadriceps: 1.0]
        ),
        Exercise(
            name: "Single Leg Extension",
            category: .legs,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Leg Curl",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation,
            muscleActivation: [.hamstrings: 1.0]
        ),
        Exercise(
            name: "Lying Leg Curl",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Seated Leg Curl",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Standing Leg Curl",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Leg Curl",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Kneeling Leg Curl",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Nordic Curl Machine",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Glute Ham Raise",
            category: .legs,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [.glutes, .lowerBack],
            equipment: .machine,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Reverse Hyperextension",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings, .lowerBack],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Back Extension Machine",
            category: .pull,
            primaryMuscles: [.lowerBack],
            secondaryMuscles: [.glutes, .hamstrings],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "45 Degree Back Extension",
            category: .pull,
            primaryMuscles: [.lowerBack],
            secondaryMuscles: [.glutes, .hamstrings],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Roman Chair Back Extension",
            category: .pull,
            primaryMuscles: [.lowerBack],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Hyperextension Hold",
            category: .pull,
            primaryMuscles: [.lowerBack],
            secondaryMuscles: [.glutes, .hamstrings],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),

        // MARK: - Hip & Glute Machines (12)
        Exercise(
            name: "Hip Abduction Machine",
            category: .legs,
            primaryMuscles: [.abductors],
            secondaryMuscles: [.glutes],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Hip Adduction Machine",
            category: .legs,
            primaryMuscles: [.adductors],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Glute Kickback Machine",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Kneeling Glute Kickback Machine",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Standing Glute Machine",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Glute Bridge Machine",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Hip Thrust Machine",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Multi-Hip Machine",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hipFlexors],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Standing Hip Extension",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Standing Hip Flexion",
            category: .legs,
            primaryMuscles: [.hipFlexors],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Smith Machine Hip Thrust",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .smithMachine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Smith Machine Glute Bridge",
            category: .legs,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .smithMachine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),

        // MARK: - Calf Machines (8)
        Exercise(
            name: "Standing Calf Raise Machine",
            category: .legs,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Seated Calf Raise Machine",
            category: .legs,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Donkey Calf Raise Machine",
            category: .legs,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Leg Press Calf Raise",
            category: .legs,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Leg Calf Raise Machine",
            category: .legs,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Smith Machine Calf Raise",
            category: .legs,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .smithMachine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Hack Squat Calf Raise",
            category: .legs,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Tibialis Raise Machine",
            category: .legs,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),

        // MARK: - Chest Press Machines (15)
        Exercise(
            name: "Chest Press Machine",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound,
            muscleActivation: [.chest: 1.0, .triceps: 0.6, .shoulders: 0.4]
        ),
        Exercise(
            name: "Incline Chest Press Machine",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders, .triceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Decline Chest Press Machine",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Hammer Strength Chest Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Plate Loaded Chest Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Converging Chest Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Pec Deck Machine",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Machine Chest Fly",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Smith Machine Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .smithMachine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Smith Machine Incline Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders, .triceps],
            equipment: .smithMachine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Smith Machine Decline Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .smithMachine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Smith Machine Close Grip Press",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest],
            equipment: .smithMachine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Chest Press Machine",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Lever Chest Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Nautilus Chest Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),

        // MARK: - Shoulder Press Machines (12)
        Exercise(
            name: "Shoulder Press Machine",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Hammer Strength Shoulder Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Plate Loaded Shoulder Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Smith Machine Shoulder Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .smithMachine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Smith Machine Behind Neck Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .traps],
            equipment: .smithMachine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Lateral Raise Machine",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Rear Delt Fly Machine",
            category: .push,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.upperBack],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Pec Deck Reverse Fly",
            category: .push,
            primaryMuscles: [.rearDelts],
            secondaryMuscles: [.upperBack],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Machine Upright Row",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.traps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Shoulder Press Machine",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Converging Shoulder Press",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Front Raise Machine",
            category: .push,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),

        // MARK: - Back & Lat Machines (20)
        Exercise(
            name: "Lat Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .upperBack],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound,
            muscleActivation: [.lats: 1.0, .biceps: 0.6, .upperBack: 0.7]
        ),
        Exercise(
            name: "Wide Grip Lat Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Close Grip Lat Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Neutral Grip Lat Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Reverse Grip Lat Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Behind Neck Lat Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.upperBack],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound,
            commonMistakes: ["Poor shoulder mobility"]
        ),
        Exercise(
            name: "V-Bar Lat Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Lat Pulldown",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Seated Cable Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Machine Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "T-Bar Row Machine",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.upperBack, .biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Hammer Strength Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .upperBack],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Single Arm Machine Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Chest Supported Row Machine",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Lever Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Plate Loaded Row",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .upperBack],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Low Row Machine",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "High Row Machine",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .rearDelts],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Smith Machine Inverted Row",
            category: .pull,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .biceps],
            equipment: .smithMachine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Machine Shrug",
            category: .pull,
            primaryMuscles: [.traps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),

        // MARK: - Tricep Machines (8)
        Exercise(
            name: "Tricep Pushdown Machine",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Tricep Extension Machine",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Overhead Tricep Extension Machine",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Tricep Dip Machine",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Assisted Tricep Dip",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest, .shoulders],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Plate Loaded Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Nautilus Tricep Extension",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Arm Tricep Extension Machine",
            category: .push,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),

        // MARK: - Bicep Machines (8)
        Exercise(
            name: "Bicep Curl Machine",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Preacher Curl Machine",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Arm Preacher Curl Machine",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Plate Loaded Bicep Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Assisted Pull-up Machine",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .upperBack],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Assisted Chin-up Machine",
            category: .pull,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Nautilus Curl Machine",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cybex Bicep Curl",
            category: .pull,
            primaryMuscles: [.biceps],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),

        // MARK: - Ab & Core Machines (10)
        Exercise(
            name: "Ab Crunch Machine",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Rotary Torso Machine",
            category: .core,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.abs],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Ab Coaster",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Kneeling Ab Wheel",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [.lowerBack],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Captain's Chair Leg Raise",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [.hipFlexors],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Roman Chair Side Bend",
            category: .core,
            primaryMuscles: [.obliques],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .isolation
        ),
        Exercise(
            name: "Decline Sit-up Machine",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Cable Crunch Machine",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Torso Rotation Machine",
            category: .core,
            primaryMuscles: [.obliques],
            secondaryMuscles: [],
            equipment: .machine,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Vertical Knee Raise",
            category: .core,
            primaryMuscles: [.abs],
            secondaryMuscles: [.hipFlexors],
            equipment: .machine,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
    ]
}
