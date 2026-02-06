//
//  ExerciseSeedsCalisthenics.swift
//  VitalArc
//
//  Calisthenics & Bodyweight Exercise Database (100+ exercises)
//

import Foundation

extension ExerciseSeeds {
    static let calisthenicsExercises: [Exercise] = [
        // MARK: - Pull-up Variations (25)
        Exercise(
            name: "Pull-ups",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .upperBack],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound,
            muscleActivation: [.lats: 1.0, .biceps: 0.7, .upperBack: 0.8],
            commonMistakes: ["Not full range", "Kipping unnecessarily", "No scapular retraction"],
            cues: ["Dead hang start", "Pull chest to bar", "Squeeze shoulder blades", "Control descent"]
        ),
        Exercise(
            name: "Chin-ups",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Wide Grip Pull-ups",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.upperBack],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Close Grip Pull-ups",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Neutral Grip Pull-ups",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Archer Pull-ups",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .bodyweight,
            instructions: "Pull to one side, extend other arm",
difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Typewriter Pull-ups",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .upperBack],
            equipment: .bodyweight,
            instructions: "Pull up, shift side to side at top",
difficulty: .expert,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Muscle-up",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.triceps, .chest, .abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "L-Sit Pull-up",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.abs, .biceps],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Weighted Pull-ups",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .upperBack],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "One Arm Pull-up",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Commando Pull-up",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .obliques],
            equipment: .bodyweight,
            instructions: "Alternate sides passing head around bar",
difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Behind Neck Pull-up",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.upperBack],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Clapping Pull-up",
            category: .plyometrics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Australian Pull-up",
            category: .calisthenics,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .biceps],
            equipment: .bodyweight,
            instructions: "Horizontal pull-up, feet on ground",
difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound,

        ),
        Exercise(
            name: "Inverted Row",
            category: .calisthenics,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.lats, .biceps],
            equipment: .bodyweight,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Scapular Pull-up",
            category: .calisthenics,
            primaryMuscles: [.upperBack],
            secondaryMuscles: [.traps],
            equipment: .bodyweight,
            instructions: "Retract shoulder blades without bending arms",
difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation,

        ),
        Exercise(
            name: "Dead Hang",
            category: .calisthenics,
            primaryMuscles: [.forearms],
            secondaryMuscles: [.lats, .shoulders],
            equipment: .bodyweight,
            difficulty: .beginner,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Flex Hang",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .bodyweight,
            instructions: "Hold at top of pull-up position",
difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound,

        ),
        Exercise(
            name: "Mixed Grip Pull-up",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Around the World Pull-up",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps, .abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Explosive Pull-up",
            category: .plyometrics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.biceps],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Kipping Pull-up",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.abs, .shoulders],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Butterfly Pull-up",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.shoulders, .abs],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Bar Muscle-up",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.triceps, .chest],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),

        // MARK: - Push-up Variations (25)
        Exercise(
            name: "Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders, .abs],
            equipment: .bodyweight,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound,
            muscleActivation: [.chest: 1.0, .triceps: 0.7, .shoulders: 0.5],
            cues: ["Plank position", "Lower chest to ground", "Full lockout", "Core tight"]
        ),
        Exercise(
            name: "Diamond Push-ups",
            category: .calisthenics,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Wide Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders],
            equipment: .bodyweight,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Decline Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders, .triceps],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Pike Push-ups",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Handstand Push-ups",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps, .abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Wall Handstand Push-ups",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.triceps],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Archer Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Plyometric Push-ups",
            category: .plyometrics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Clapping Push-ups",
            category: .plyometrics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Pseudo Planche Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders, .abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "One Arm Push-up",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Spiderman Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .obliques],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Staggered Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Superman Push-ups",
            category: .plyometrics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "T Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .abs, .obliques],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Hindu Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders, .triceps],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Dive Bomber Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders, .triceps],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Knuckle Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .forearms],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Fingertip Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .forearms],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Typewriter Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Lalanne Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Ring Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .abs],
            equipment: .suspensionTrainer,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Ring Muscle-up",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.chest, .triceps],
            equipment: .suspensionTrainer,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Deficit Push-ups",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),

        // MARK: - Dip Variations (12)
        Exercise(
            name: "Tricep Dips",
            category: .calisthenics,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest, .shoulders],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Chest Dips",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps, .shoulders],
            equipment: .bodyweight,
            instructions: "Lean forward for chest emphasis",
difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "Bench Dips",
            category: .calisthenics,
            primaryMuscles: [.triceps],
            secondaryMuscles: [],
            equipment: .bodyweight,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Ring Dips",
            category: .calisthenics,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest, .shoulders, .abs],
            equipment: .suspensionTrainer,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Weighted Dips",
            category: .calisthenics,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest, .shoulders],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Korean Dips",
            category: .calisthenics,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.shoulders],
            equipment: .bodyweight,
            instructions: "Behind body dips",
difficulty: .expert,
            forceType: .push,
            mechanic: .compound,

        ),
        Exercise(
            name: "L-Sit Dips",
            category: .calisthenics,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest, .abs],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Straight Bar Dips",
            category: .calisthenics,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Russian Dips",
            category: .calisthenics,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.shoulders, .chest],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Archer Dips",
            category: .calisthenics,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Explosive Dips",
            category: .plyometrics,
            primaryMuscles: [.triceps],
            secondaryMuscles: [.chest],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Gironda Dips",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.triceps],
            equipment: .bodyweight,
            instructions: "Extreme forward lean",
difficulty: .advanced,
            forceType: .push,
            mechanic: .compound,

        ),

        // MARK: - Advanced Calisthenics Skills (20)
        Exercise(
            name: "Handstand Hold",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs, .triceps],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Freestanding Handstand",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs, .triceps],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Wall Handstand Hold",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Handstand Walk",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.abs, .triceps],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Planche Lean",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.chest, .abs],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Tuck Planche",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.chest, .abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Advanced Tuck Planche",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.chest, .abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Straddle Planche",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.chest, .abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Full Planche",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.chest, .abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Front Lever Tuck",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.abs, .shoulders],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Front Lever",
            category: .calisthenics,
            primaryMuscles: [.lats],
            secondaryMuscles: [.abs, .shoulders],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Back Lever",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.chest, .lats],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Human Flag",
            category: .calisthenics,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.shoulders, .lats],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Iron Cross",
            category: .calisthenics,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders, .biceps],
            equipment: .suspensionTrainer,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Maltese",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.chest, .triceps],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Victorian",
            category: .calisthenics,
            primaryMuscles: [.shoulders],
            secondaryMuscles: [.chest, .abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Pistol Squat",
            category: .calisthenics,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Shrimp Squat",
            category: .calisthenics,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Nordic Hamstring Curl",
            category: .calisthenics,
            primaryMuscles: [.hamstrings],
            secondaryMuscles: [.glutes],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Dragon Flag",
            category: .calisthenics,
            primaryMuscles: [.abs],
            secondaryMuscles: [.lats, .shoulders],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),

        // MARK: - Core & Leg Bodyweight (18)
        Exercise(
            name: "L-Sit",
            category: .calisthenics,
            primaryMuscles: [.abs],
            secondaryMuscles: [.hipFlexors, .shoulders],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "V-Sit",
            category: .calisthenics,
            primaryMuscles: [.abs],
            secondaryMuscles: [.hipFlexors],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .staticHold,
            mechanic: .isolation
        ),
        Exercise(
            name: "Hollow Body Hold",
            category: .calisthenics,
            primaryMuscles: [.abs],
            secondaryMuscles: [],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .staticHold,
            mechanic: .isolation
        ),
        Exercise(
            name: "Arch Hold",
            category: .calisthenics,
            primaryMuscles: [.lowerBack],
            secondaryMuscles: [.glutes],
            equipment: .bodyweight,
            difficulty: .beginner,
            forceType: .staticHold,
            mechanic: .isolation
        ),
        Exercise(
            name: "Toes to Bar",
            category: .calisthenics,
            primaryMuscles: [.abs],
            secondaryMuscles: [.hipFlexors, .lats],
            equipment: .bodyweight,
            difficulty: .advanced,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Hanging Leg Raise",
            category: .calisthenics,
            primaryMuscles: [.abs],
            secondaryMuscles: [.hipFlexors],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Hanging Knee Raise",
            category: .calisthenics,
            primaryMuscles: [.abs],
            secondaryMuscles: [.hipFlexors],
            equipment: .bodyweight,
            difficulty: .beginner,
            forceType: .pull,
            mechanic: .isolation
        ),
        Exercise(
            name: "Windshield Wipers",
            category: .calisthenics,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.abs],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .pull,
            mechanic: .compound
        ),
        Exercise(
            name: "Human Flag Progression",
            category: .calisthenics,
            primaryMuscles: [.obliques],
            secondaryMuscles: [.lats, .shoulders],
            equipment: .bodyweight,
            difficulty: .expert,
            forceType: .staticHold,
            mechanic: .compound
        ),
        Exercise(
            name: "Bodyweight Squat",
            category: .calisthenics,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .bodyweight,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Jump Squat",
            category: .plyometrics,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .calves],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Box Jump",
            category: .plyometrics,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .calves],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Broad Jump",
            category: .plyometrics,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes, .calves],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Burpee",
            category: .cardio,
            primaryMuscles: [.fullBody],
            secondaryMuscles: [.chest, .quadriceps],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Wall Sit",
            category: .calisthenics,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [],
            equipment: .bodyweight,
            difficulty: .beginner,
            forceType: .staticHold,
            mechanic: .isolation
        ),
        Exercise(
            name: "Single Leg Glute Bridge",
            category: .calisthenics,
            primaryMuscles: [.glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .bodyweight,
            difficulty: .intermediate,
            forceType: .push,
            mechanic: .isolation
        ),
        Exercise(
            name: "Bodyweight Lunge",
            category: .calisthenics,
            primaryMuscles: [.quadriceps],
            secondaryMuscles: [.glutes],
            equipment: .bodyweight,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .compound
        ),
        Exercise(
            name: "Calf Raise",
            category: .calisthenics,
            primaryMuscles: [.calves],
            secondaryMuscles: [],
            equipment: .bodyweight,
            difficulty: .beginner,
            forceType: .push,
            mechanic: .isolation
        ),
    ]
}
