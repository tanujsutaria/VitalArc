//
//  ExerciseSeeds.swift
//  VitalArc
//
//  Exercise Database Seeding (200 exercises)
//

import Foundation

struct ExerciseSeeds {
    /// Seed exercises if database is empty
    static func seedIfNeeded(repository: WorkoutRepository) async throws {
        let existingExercises = try await repository.getExercises()
        guard existingExercises.isEmpty else {
            return // Already seeded
        }

        for exercise in allExercises {
            try await repository.saveExercise(exercise)
        }
    }

    // MARK: - Exercise Database (200 exercises: 50 per category)

    private static let allExercises: [Exercise] = pushExercises + pullExercises + legsExercises + coreExercises

    // MARK: - Push Exercises (50)
    private static let pushExercises: [Exercise] = [
        // Barbell Push (10)
        Exercise(name: "Barbell Bench Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.triceps, .shoulders], equipment: .barbell),
        Exercise(name: "Incline Barbell Bench Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.shoulders, .triceps], equipment: .barbell),
        Exercise(name: "Decline Barbell Bench Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.triceps], equipment: .barbell),
        Exercise(name: "Barbell Overhead Press", category: .push, primaryMuscles: [.shoulders], secondaryMuscles: [.triceps], equipment: .barbell),
        Exercise(name: "Barbell Push Press", category: .push, primaryMuscles: [.shoulders], secondaryMuscles: [.triceps], equipment: .barbell),
        Exercise(name: "Close Grip Barbell Bench Press", category: .push, primaryMuscles: [.triceps], secondaryMuscles: [.chest], equipment: .barbell),
        Exercise(name: "Barbell Floor Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.triceps], equipment: .barbell),
        Exercise(name: "Barbell Landmine Press", category: .push, primaryMuscles: [.shoulders], secondaryMuscles: [.chest], equipment: .barbell),
        Exercise(name: "Barbell Guillotine Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.shoulders], equipment: .barbell),
        Exercise(name: "Barbell JM Press", category: .push, primaryMuscles: [.triceps], equipment: .barbell),

        // Dumbbell Push (15)
        Exercise(name: "Dumbbell Bench Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.triceps, .shoulders], equipment: .dumbbell),
        Exercise(name: "Incline Dumbbell Bench Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.shoulders, .triceps], equipment: .dumbbell),
        Exercise(name: "Decline Dumbbell Bench Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.triceps], equipment: .dumbbell),
        Exercise(name: "Dumbbell Shoulder Press", category: .push, primaryMuscles: [.shoulders], secondaryMuscles: [.triceps], equipment: .dumbbell),
        Exercise(name: "Dumbbell Arnold Press", category: .push, primaryMuscles: [.shoulders], secondaryMuscles: [.triceps], equipment: .dumbbell),
        Exercise(name: "Dumbbell Lateral Raise", category: .push, primaryMuscles: [.shoulders], equipment: .dumbbell),
        Exercise(name: "Dumbbell Front Raise", category: .push, primaryMuscles: [.shoulders], equipment: .dumbbell),
        Exercise(name: "Dumbbell Fly", category: .push, primaryMuscles: [.chest], equipment: .dumbbell),
        Exercise(name: "Incline Dumbbell Fly", category: .push, primaryMuscles: [.chest], equipment: .dumbbell),
        Exercise(name: "Dumbbell Tricep Kickback", category: .push, primaryMuscles: [.triceps], equipment: .dumbbell),
        Exercise(name: "Dumbbell Overhead Tricep Extension", category: .push, primaryMuscles: [.triceps], equipment: .dumbbell),
        Exercise(name: "Dumbbell Hammer Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.triceps], equipment: .dumbbell),
        Exercise(name: "Dumbbell Reverse Fly", category: .push, primaryMuscles: [.shoulders], equipment: .dumbbell),
        Exercise(name: "Dumbbell Cuban Press", category: .push, primaryMuscles: [.shoulders], equipment: .dumbbell),
        Exercise(name: "Dumbbell Floor Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.triceps], equipment: .dumbbell),

        // Machine & Cable Push (15)
        Exercise(name: "Machine Chest Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.triceps], equipment: .machine),
        Exercise(name: "Machine Shoulder Press", category: .push, primaryMuscles: [.shoulders], secondaryMuscles: [.triceps], equipment: .machine),
        Exercise(name: "Cable Chest Fly", category: .push, primaryMuscles: [.chest], equipment: .cable),
        Exercise(name: "Cable Crossover", category: .push, primaryMuscles: [.chest], equipment: .cable),
        Exercise(name: "Cable Lateral Raise", category: .push, primaryMuscles: [.shoulders], equipment: .cable),
        Exercise(name: "Cable Tricep Pushdown", category: .push, primaryMuscles: [.triceps], equipment: .cable),
        Exercise(name: "Cable Overhead Tricep Extension", category: .push, primaryMuscles: [.triceps], equipment: .cable),
        Exercise(name: "Pec Deck Machine", category: .push, primaryMuscles: [.chest], equipment: .machine),
        Exercise(name: "Machine Tricep Dip", category: .push, primaryMuscles: [.triceps], equipment: .machine),
        Exercise(name: "Cable Front Raise", category: .push, primaryMuscles: [.shoulders], equipment: .cable),
        Exercise(name: "Cable Reverse Fly", category: .push, primaryMuscles: [.shoulders], equipment: .cable),
        Exercise(name: "Smith Machine Bench Press", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.triceps], equipment: .machine),
        Exercise(name: "Smith Machine Shoulder Press", category: .push, primaryMuscles: [.shoulders], secondaryMuscles: [.triceps], equipment: .machine),
        Exercise(name: "Cable Chest Press", category: .push, primaryMuscles: [.chest], equipment: .cable),
        Exercise(name: "Machine Lateral Raise", category: .push, primaryMuscles: [.shoulders], equipment: .machine),

        // Bodyweight Push (10)
        Exercise(name: "Push-ups", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.triceps, .shoulders], equipment: .bodyweight),
        Exercise(name: "Diamond Push-ups", category: .push, primaryMuscles: [.triceps], secondaryMuscles: [.chest], equipment: .bodyweight),
        Exercise(name: "Wide Push-ups", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.shoulders], equipment: .bodyweight),
        Exercise(name: "Decline Push-ups", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.shoulders], equipment: .bodyweight),
        Exercise(name: "Pike Push-ups", category: .push, primaryMuscles: [.shoulders], secondaryMuscles: [.triceps], equipment: .bodyweight),
        Exercise(name: "Handstand Push-ups", category: .push, primaryMuscles: [.shoulders], secondaryMuscles: [.triceps], equipment: .bodyweight),
        Exercise(name: "Tricep Dips", category: .push, primaryMuscles: [.triceps], secondaryMuscles: [.chest], equipment: .bodyweight),
        Exercise(name: "Bench Dips", category: .push, primaryMuscles: [.triceps], equipment: .bodyweight),
        Exercise(name: "Archer Push-ups", category: .push, primaryMuscles: [.chest], equipment: .bodyweight),
        Exercise(name: "Plyometric Push-ups", category: .push, primaryMuscles: [.chest], secondaryMuscles: [.triceps], equipment: .bodyweight),
    ]

    // MARK: - Pull Exercises (50)
    private static let pullExercises: [Exercise] = [
        // Barbell Pull (10)
        Exercise(name: "Barbell Deadlift", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.hamstrings, .glutes], equipment: .barbell),
        Exercise(name: "Barbell Row", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .barbell),
        Exercise(name: "Pendlay Row", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .barbell),
        Exercise(name: "Barbell Shrug", category: .pull, primaryMuscles: [.back], equipment: .barbell),
        Exercise(name: "Barbell Curl", category: .pull, primaryMuscles: [.biceps], equipment: .barbell),
        Exercise(name: "Barbell Reverse Curl", category: .pull, primaryMuscles: [.forearms], secondaryMuscles: [.biceps], equipment: .barbell),
        Exercise(name: "Romanian Deadlift", category: .pull, primaryMuscles: [.hamstrings], secondaryMuscles: [.back, .glutes], equipment: .barbell),
        Exercise(name: "Sumo Deadlift", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.hamstrings, .glutes], equipment: .barbell),
        Exercise(name: "Barbell T-Bar Row", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .barbell),
        Exercise(name: "EZ Bar Curl", category: .pull, primaryMuscles: [.biceps], equipment: .barbell),

        // Dumbbell Pull (15)
        Exercise(name: "Dumbbell Row", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .dumbbell),
        Exercise(name: "Single Arm Dumbbell Row", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .dumbbell),
        Exercise(name: "Dumbbell Shrug", category: .pull, primaryMuscles: [.back], equipment: .dumbbell),
        Exercise(name: "Dumbbell Curl", category: .pull, primaryMuscles: [.biceps], equipment: .dumbbell),
        Exercise(name: "Hammer Curl", category: .pull, primaryMuscles: [.biceps], secondaryMuscles: [.forearms], equipment: .dumbbell),
        Exercise(name: "Dumbbell Preacher Curl", category: .pull, primaryMuscles: [.biceps], equipment: .dumbbell),
        Exercise(name: "Dumbbell Concentration Curl", category: .pull, primaryMuscles: [.biceps], equipment: .dumbbell),
        Exercise(name: "Incline Dumbbell Curl", category: .pull, primaryMuscles: [.biceps], equipment: .dumbbell),
        Exercise(name: "Dumbbell Pullover", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.chest], equipment: .dumbbell),
        Exercise(name: "Dumbbell Reverse Fly", category: .pull, primaryMuscles: [.back], equipment: .dumbbell),
        Exercise(name: "Dumbbell Romanian Deadlift", category: .pull, primaryMuscles: [.hamstrings], secondaryMuscles: [.back], equipment: .dumbbell),
        Exercise(name: "Dumbbell Wrist Curl", category: .pull, primaryMuscles: [.forearms], equipment: .dumbbell),
        Exercise(name: "Dumbbell Reverse Wrist Curl", category: .pull, primaryMuscles: [.forearms], equipment: .dumbbell),
        Exercise(name: "Dumbbell Zottman Curl", category: .pull, primaryMuscles: [.biceps], secondaryMuscles: [.forearms], equipment: .dumbbell),
        Exercise(name: "Dumbbell Spider Curl", category: .pull, primaryMuscles: [.biceps], equipment: .dumbbell),

        // Machine & Cable Pull (15)
        Exercise(name: "Lat Pulldown", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .machine),
        Exercise(name: "Wide Grip Lat Pulldown", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .machine),
        Exercise(name: "Close Grip Lat Pulldown", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .machine),
        Exercise(name: "Cable Row", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .cable),
        Exercise(name: "Cable Face Pull", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.shoulders], equipment: .cable),
        Exercise(name: "Cable Bicep Curl", category: .pull, primaryMuscles: [.biceps], equipment: .cable),
        Exercise(name: "Cable Hammer Curl", category: .pull, primaryMuscles: [.biceps], secondaryMuscles: [.forearms], equipment: .cable),
        Exercise(name: "Machine Row", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .machine),
        Exercise(name: "T-Bar Row Machine", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .machine),
        Exercise(name: "Machine Shrug", category: .pull, primaryMuscles: [.back], equipment: .machine),
        Exercise(name: "Cable Pullover", category: .pull, primaryMuscles: [.back], equipment: .cable),
        Exercise(name: "Cable Reverse Curl", category: .pull, primaryMuscles: [.forearms], secondaryMuscles: [.biceps], equipment: .cable),
        Exercise(name: "Machine Preacher Curl", category: .pull, primaryMuscles: [.biceps], equipment: .machine),
        Exercise(name: "Cable Woodchop", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.obliques], equipment: .cable),
        Exercise(name: "Straight Arm Pulldown", category: .pull, primaryMuscles: [.back], equipment: .cable),

        // Bodyweight Pull (10)
        Exercise(name: "Pull-ups", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .bodyweight),
        Exercise(name: "Chin-ups", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .bodyweight),
        Exercise(name: "Wide Grip Pull-ups", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .bodyweight),
        Exercise(name: "Neutral Grip Pull-ups", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .bodyweight),
        Exercise(name: "Muscle-ups", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps, .triceps], equipment: .bodyweight),
        Exercise(name: "Australian Pull-ups", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .bodyweight),
        Exercise(name: "Inverted Row", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .bodyweight),
        Exercise(name: "Hanging Knee Raise", category: .pull, primaryMuscles: [.abs], secondaryMuscles: [.forearms], equipment: .bodyweight),
        Exercise(name: "Dead Hang", category: .pull, primaryMuscles: [.forearms], secondaryMuscles: [.back], equipment: .bodyweight),
        Exercise(name: "Archer Pull-ups", category: .pull, primaryMuscles: [.back], secondaryMuscles: [.biceps], equipment: .bodyweight),
    ]

    // MARK: - Legs Exercises (50)
    private static let legsExercises: [Exercise] = [
        // Barbell Legs (15)
        Exercise(name: "Barbell Back Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes, .hamstrings], equipment: .barbell),
        Exercise(name: "Barbell Front Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .barbell),
        Exercise(name: "Barbell Deadlift", category: .legs, primaryMuscles: [.hamstrings], secondaryMuscles: [.glutes, .back], equipment: .barbell),
        Exercise(name: "Barbell Romanian Deadlift", category: .legs, primaryMuscles: [.hamstrings], secondaryMuscles: [.glutes, .back], equipment: .barbell),
        Exercise(name: "Barbell Sumo Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .barbell),
        Exercise(name: "Barbell Lunge", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .barbell),
        Exercise(name: "Barbell Reverse Lunge", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .barbell),
        Exercise(name: "Barbell Bulgarian Split Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .barbell),
        Exercise(name: "Barbell Hip Thrust", category: .legs, primaryMuscles: [.glutes], secondaryMuscles: [.hamstrings], equipment: .barbell),
        Exercise(name: "Barbell Good Morning", category: .legs, primaryMuscles: [.hamstrings], secondaryMuscles: [.back], equipment: .barbell),
        Exercise(name: "Barbell Calf Raise", category: .legs, primaryMuscles: [.calves], equipment: .barbell),
        Exercise(name: "Barbell Step-up", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .barbell),
        Exercise(name: "Barbell Hack Squat", category: .legs, primaryMuscles: [.quadriceps], equipment: .barbell),
        Exercise(name: "Barbell Zercher Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .barbell),
        Exercise(name: "Barbell Box Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .barbell),

        // Dumbbell Legs (15)
        Exercise(name: "Dumbbell Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Dumbbell Goblet Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Dumbbell Lunge", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Dumbbell Reverse Lunge", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Dumbbell Bulgarian Split Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Dumbbell Romanian Deadlift", category: .legs, primaryMuscles: [.hamstrings], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Dumbbell Step-up", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Dumbbell Hip Thrust", category: .legs, primaryMuscles: [.glutes], secondaryMuscles: [.hamstrings], equipment: .dumbbell),
        Exercise(name: "Dumbbell Calf Raise", category: .legs, primaryMuscles: [.calves], equipment: .dumbbell),
        Exercise(name: "Dumbbell Lateral Lunge", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Dumbbell Sumo Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Single Leg Dumbbell Deadlift", category: .legs, primaryMuscles: [.hamstrings], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Dumbbell Walking Lunge", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Dumbbell Box Step-up", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .dumbbell),
        Exercise(name: "Dumbbell Curtsy Lunge", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .dumbbell),

        // Machine Legs (12)
        Exercise(name: "Leg Press", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .machine),
        Exercise(name: "Leg Extension", category: .legs, primaryMuscles: [.quadriceps], equipment: .machine),
        Exercise(name: "Leg Curl", category: .legs, primaryMuscles: [.hamstrings], equipment: .machine),
        Exercise(name: "Seated Leg Curl", category: .legs, primaryMuscles: [.hamstrings], equipment: .machine),
        Exercise(name: "Lying Leg Curl", category: .legs, primaryMuscles: [.hamstrings], equipment: .machine),
        Exercise(name: "Hack Squat Machine", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .machine),
        Exercise(name: "Smith Machine Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .machine),
        Exercise(name: "Hip Abduction Machine", category: .legs, primaryMuscles: [.glutes], equipment: .machine),
        Exercise(name: "Hip Adduction Machine", category: .legs, primaryMuscles: [.quadriceps], equipment: .machine),
        Exercise(name: "Calf Raise Machine", category: .legs, primaryMuscles: [.calves], equipment: .machine),
        Exercise(name: "Seated Calf Raise Machine", category: .legs, primaryMuscles: [.calves], equipment: .machine),
        Exercise(name: "Cable Kickback", category: .legs, primaryMuscles: [.glutes], equipment: .cable),

        // Bodyweight Legs (8)
        Exercise(name: "Bodyweight Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .bodyweight),
        Exercise(name: "Bodyweight Lunge", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .bodyweight),
        Exercise(name: "Jump Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .bodyweight),
        Exercise(name: "Pistol Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .bodyweight),
        Exercise(name: "Bulgarian Split Squat", category: .legs, primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes], equipment: .bodyweight),
        Exercise(name: "Bodyweight Calf Raise", category: .legs, primaryMuscles: [.calves], equipment: .bodyweight),
        Exercise(name: "Wall Sit", category: .legs, primaryMuscles: [.quadriceps], equipment: .bodyweight),
        Exercise(name: "Nordic Hamstring Curl", category: .legs, primaryMuscles: [.hamstrings], equipment: .bodyweight),
    ]

    // MARK: - Core Exercises (50)
    private static let coreExercises: [Exercise] = [
        // Abs - Bodyweight (15)
        Exercise(name: "Plank", category: .core, primaryMuscles: [.abs], secondaryMuscles: [.obliques], equipment: .bodyweight),
        Exercise(name: "Side Plank", category: .core, primaryMuscles: [.obliques], secondaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Crunches", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Bicycle Crunches", category: .core, primaryMuscles: [.abs], secondaryMuscles: [.obliques], equipment: .bodyweight),
        Exercise(name: "Reverse Crunches", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Leg Raises", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Hanging Leg Raises", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Mountain Climbers", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Russian Twist", category: .core, primaryMuscles: [.obliques], secondaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "V-ups", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Sit-ups", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Flutter Kicks", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Scissors", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Dead Bug", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Hollow Hold", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),

        // Abs - Weighted (15)
        Exercise(name: "Cable Crunch", category: .core, primaryMuscles: [.abs], equipment: .cable),
        Exercise(name: "Cable Woodchop", category: .core, primaryMuscles: [.obliques], secondaryMuscles: [.abs], equipment: .cable),
        Exercise(name: "Cable Twist", category: .core, primaryMuscles: [.obliques], equipment: .cable),
        Exercise(name: "Medicine Ball Slam", category: .core, primaryMuscles: [.abs], equipment: .dumbbell),
        Exercise(name: "Dumbbell Side Bend", category: .core, primaryMuscles: [.obliques], equipment: .dumbbell),
        Exercise(name: "Weighted Russian Twist", category: .core, primaryMuscles: [.obliques], secondaryMuscles: [.abs], equipment: .dumbbell),
        Exercise(name: "Dumbbell Pullover Crunch", category: .core, primaryMuscles: [.abs], equipment: .dumbbell),
        Exercise(name: "Ab Wheel Rollout", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Barbell Rollout", category: .core, primaryMuscles: [.abs], equipment: .barbell),
        Exercise(name: "Landmine Rotation", category: .core, primaryMuscles: [.obliques], secondaryMuscles: [.abs], equipment: .barbell),
        Exercise(name: "Cable Pallof Press", category: .core, primaryMuscles: [.abs], secondaryMuscles: [.obliques], equipment: .cable),
        Exercise(name: "Weighted Plank", category: .core, primaryMuscles: [.abs], equipment: .dumbbell),
        Exercise(name: "Weighted Leg Raise", category: .core, primaryMuscles: [.abs], equipment: .dumbbell),
        Exercise(name: "Cable Side Bend", category: .core, primaryMuscles: [.obliques], equipment: .cable),
        Exercise(name: "Decline Sit-up", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),

        // Core Stability & Dynamic (20)
        Exercise(name: "Bird Dog", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Bear Crawl", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Spiderman Plank", category: .core, primaryMuscles: [.abs], secondaryMuscles: [.obliques], equipment: .bodyweight),
        Exercise(name: "Plank to Downward Dog", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Plank Jacks", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Toe Touches", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Windshield Wipers", category: .core, primaryMuscles: [.obliques], secondaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "L-Sit", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Dragon Flag", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Toes to Bar", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Hanging Knee Raise", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Oblique Crunch", category: .core, primaryMuscles: [.obliques], equipment: .bodyweight),
        Exercise(name: "Cross Body Crunch", category: .core, primaryMuscles: [.obliques], secondaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Jackknife Sit-up", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Heel Touches", category: .core, primaryMuscles: [.obliques], equipment: .bodyweight),
        Exercise(name: "Superman Hold", category: .core, primaryMuscles: [.back], secondaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Glute Bridge", category: .core, primaryMuscles: [.glutes], secondaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Single Leg Bridge", category: .core, primaryMuscles: [.glutes], secondaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Stability Ball Crunch", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
        Exercise(name: "Stability Ball Rollout", category: .core, primaryMuscles: [.abs], equipment: .bodyweight),
    ]
}
