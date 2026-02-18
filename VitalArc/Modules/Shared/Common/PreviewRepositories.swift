//
//  PreviewRepositories.swift
//  VitalArc
//
//  Preview-only stub implementations of repository protocols for SwiftUI previews.
//

import Foundation

// MARK: - Preview Workout Repository

final class PreviewWorkoutRepository: WorkoutRepository {
    func getExercises() async throws -> [Exercise] {
        Exercise.previewExercises
    }

    func getExercise(id: UUID) async throws -> Exercise? {
        Exercise.previewExercises.first { $0.id == id }
    }

    func searchExercises(query: String) async throws -> [Exercise] {
        Exercise.previewExercises.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    func saveExercise(_ exercise: Exercise) async throws {
        // No-op for preview
    }

    func updateExercise(_ exercise: Exercise) async throws {
        // No-op for preview
    }

    func deleteExercise(id: UUID) async throws {
        // No-op for preview
    }

    func isExerciseUsedInWorkouts(_ exerciseId: UUID) async throws -> Bool {
        false
    }

    func getWorkouts() async throws -> [Workout] {
        []
    }

    func getWorkout(id: UUID) async throws -> Workout? {
        nil
    }

    func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout] {
        []
    }

    func saveWorkout(_ workout: Workout) async throws {
        // No-op for preview
    }

    func deleteWorkout(id: UUID) async throws {
        // No-op for preview
    }

    func getWorkoutByHealthKitId(_ healthKitId: String) async throws -> Workout? {
        nil
    }

    func getLastWorkoutForExercise(_ exerciseId: UUID) async throws -> Workout? {
        nil
    }
}

// MARK: - Preview Mesocycle Repository

final class PreviewMesocycleRepository: MesocycleRepository {
    func getMesocycles() async throws -> [Mesocycle] {
        []
    }

    func getMesocycle(id: UUID) async throws -> Mesocycle? {
        nil
    }

    func getActiveMesocycle() async throws -> Mesocycle? {
        nil
    }

    func saveMesocycle(_ mesocycle: Mesocycle) async throws {
        // No-op for preview
    }

    func updateMesocycle(_ mesocycle: Mesocycle) async throws {
        // No-op for preview
    }

    func deleteMesocycle(id: UUID) async throws {
        // No-op for preview
    }

    func activateMesocycle(id: UUID) async throws {
        // No-op for preview
    }

    func completeMesocycle(id: UUID) async throws {
        // No-op for preview
    }

    func getMesocyclesByStatus(_ status: MesocycleStatus) async throws -> [Mesocycle] {
        []
    }

    func getMesocycleForDate(_ date: Date) async throws -> Mesocycle? {
        nil
    }
}

// MARK: - Preview Exercise Data

extension Exercise {
    static let previewExercises: [Exercise] = [
        Exercise(
            id: UUID(),
            name: "Bench Press",
            category: .push,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders, .triceps],
            equipment: .barbell,
            instructions: "Lie on bench, lower bar to chest, press up.",
            isCustom: false
        ),
        Exercise(
            id: UUID(),
            name: "Squat",
            category: .legs,
            primaryMuscles: [.quadriceps, .glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .barbell,
            instructions: "Bar on back, squat down, stand up.",
            isCustom: false
        ),
        Exercise(
            id: UUID(),
            name: "Deadlift",
            category: .pull,
            primaryMuscles: [.back, .glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .barbell,
            instructions: "Grip bar, stand up with hips and knees.",
            isCustom: false
        )
    ]
}
