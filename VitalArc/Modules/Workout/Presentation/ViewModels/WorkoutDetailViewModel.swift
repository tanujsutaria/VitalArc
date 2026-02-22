//
//  WorkoutDetailViewModel.swift
//  VitalArc
//
//  ViewModel for Workout Detail View
//

import Foundation
import Observation

@MainActor
@Observable
final class WorkoutDetailViewModel {
    private let workout: Workout
    private let repository: WorkoutRepository

    var exerciseNames: [UUID: String] = [:]
    var isLoading: Bool = false

    init(workout: Workout, repository: WorkoutRepository) {
        self.workout = workout
        self.repository = repository
    }

    // MARK: - Data Loading

    func loadExerciseDetails() async {
        isLoading = true
        defer { isLoading = false }

        let exerciseIds = Set(workout.sets.map { $0.exerciseId })
        for exerciseId in exerciseIds {
            do {
                if let exercise = try await repository.getExercise(id: exerciseId) {
                    exerciseNames[exerciseId] = exercise.name
                } else {
                    exerciseNames[exerciseId] = "Unknown Exercise"
                }
            } catch {
                exerciseNames[exerciseId] = "Unknown Exercise"
            }
        }
    }

    // MARK: - Workout Data

    var name: String {
        workout.name ?? "Workout"
    }

    var date: Date {
        workout.date
    }

    var notes: String? {
        workout.notes
    }

    var duration: TimeInterval? {
        workout.duration
    }

    var totalSets: Int {
        workout.totalSets
    }

    var totalVolume: Double {
        workout.totalVolume
    }

    // MARK: - Exercise Grouping

    /// Returns exercise IDs in the order they first appear in the sets
    var orderedExerciseIds: [UUID] {
        var seen = Set<UUID>()
        var ordered: [UUID] = []
        for set in workout.sets {
            if !seen.contains(set.exerciseId) {
                seen.insert(set.exerciseId)
                ordered.append(set.exerciseId)
            }
        }
        return ordered
    }

    /// Groups sets by exercise ID, preserving set order
    func sets(for exerciseId: UUID) -> [WorkoutSet] {
        workout.sets
            .filter { $0.exerciseId == exerciseId }
            .sorted { $0.setNumber < $1.setNumber }
    }

    func exerciseName(for exerciseId: UUID) -> String {
        exerciseNames[exerciseId] ?? "Unknown Exercise"
    }

    func exerciseVolume(for exerciseId: UUID) -> Double {
        sets(for: exerciseId).reduce(0) { $0 + $1.volume }
    }

    func bestSet(for exerciseId: UUID) -> WorkoutSet? {
        sets(for: exerciseId).max { $0.volume < $1.volume }
    }

    // MARK: - Sharing

    /// Generates a shareable text summary of the workout
    func shareText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        var text = "\(name)\n"
        text += "\(dateFormatter.string(from: date))\n\n"

        // Stats
        let volumeLbs = UnitConversion.kgToLbs(totalVolume)
        text += "\(totalSets) sets | \(String(format: "%.0f", volumeLbs)) lbs total volume"
        if let duration = duration {
            let minutes = Int(duration) / 60
            text += " | \(minutes) min"
        }
        text += "\n\n"

        // Exercises
        for exerciseId in orderedExerciseIds {
            let exerciseName = exerciseName(for: exerciseId)
            let exerciseSets = sets(for: exerciseId)

            text += "\(exerciseName)\n"
            for set in exerciseSets {
                let weightLbs = UnitConversion.kgToLbs(set.weight)
                var setLine = "  Set \(set.setNumber): \(String(format: "%.1f", weightLbs)) lbs x \(set.reps)"
                if let rir = set.rir { setLine += " @\(rir) RIR" }
                if let rpe = set.rpe { setLine += " RPE \(String(format: "%.0f", rpe))" }
                text += setLine + "\n"
            }
            text += "\n"
        }

        text += "Logged with VitalArc"
        return text
    }
}
