//
//  WorkoutLoggingViewModel.swift
//  VitalArc
//
//  ViewModel for Workout Logging
//

import Foundation
import Observation

@Observable
final class WorkoutLoggingViewModel {
    private let createWorkoutUseCase: CreateWorkoutUseCase
    private let calculateProgressionUseCase: CalculateProgressionUseCase

    var workoutName: String = ""
    var notes: String = ""
    var selectedExercises: [Exercise] = []
    var exerciseSets: [UUID: [WorkoutSetData]] = [:] // exerciseId -> sets
    var startTime: Date = Date()
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showingExerciseLibrary: Bool = false

    init(
        createWorkoutUseCase: CreateWorkoutUseCase,
        calculateProgressionUseCase: CalculateProgressionUseCase
    ) {
        self.createWorkoutUseCase = createWorkoutUseCase
        self.calculateProgressionUseCase = calculateProgressionUseCase
    }

    // MARK: - Exercise Management

    @MainActor
    func addExercise(_ exercise: Exercise) async {
        guard !selectedExercises.contains(where: { $0.id == exercise.id }) else {
            return
        }

        selectedExercises.append(exercise)

        // Get suggested weight from progression
        let suggestedWeight = (try? await calculateProgressionUseCase.execute(exerciseId: exercise.id)) ?? 20.0

        // Initialize with one empty set
        exerciseSets[exercise.id] = [
            WorkoutSetData(
                exerciseId: exercise.id,
                weight: suggestedWeight,
                reps: 10,
                rir: nil,
                setNumber: 1,
                completed: false
            )
        ]

        showingExerciseLibrary = false
    }

    func removeExercise(_ exercise: Exercise) {
        selectedExercises.removeAll { $0.id == exercise.id }
        exerciseSets.removeValue(forKey: exercise.id)
    }

    // MARK: - Set Management

    func addSet(for exerciseId: UUID) {
        guard var sets = exerciseSets[exerciseId] else { return }

        let setNumber = sets.count + 1
        let lastSet = sets.last

        let newSet = WorkoutSetData(
            exerciseId: exerciseId,
            weight: lastSet?.weight ?? 20.0,
            reps: lastSet?.reps ?? 10,
            rir: lastSet?.rir,
            setNumber: setNumber,
            completed: false
        )

        sets.append(newSet)
        exerciseSets[exerciseId] = sets
    }

    func removeSet(for exerciseId: UUID, at index: Int) {
        guard var sets = exerciseSets[exerciseId] else { return }
        sets.remove(at: index)

        // Renumber remaining sets
        for (idx, var set) in sets.enumerated() {
            set.setNumber = idx + 1
            sets[idx] = set
        }

        exerciseSets[exerciseId] = sets
    }

    func updateSet(_ updatedSet: WorkoutSetData, for exerciseId: UUID, at index: Int) {
        guard var sets = exerciseSets[exerciseId] else { return }
        sets[index] = updatedSet
        exerciseSets[exerciseId] = sets
    }

    // MARK: - Workout Completion

    @MainActor
    func saveWorkout() async {
        isLoading = true
        errorMessage = nil

        do {
            // Convert all sets to WorkoutSet entities
            var allSets: [WorkoutSet] = []
            for (exerciseId, setDataArray) in exerciseSets {
                let workoutSets = setDataArray.map { setData in
                    WorkoutSet(
                        exerciseId: exerciseId,
                        weight: setData.weight,
                        reps: setData.reps,
                        rir: setData.rir,
                        setNumber: setData.setNumber,
                        completed: setData.completed
                    )
                }
                allSets.append(contentsOf: workoutSets)
            }

            // Calculate duration
            let duration = Date().timeIntervalSince(startTime)

            // Save workout
            _ = try await createWorkoutUseCase.execute(
                name: workoutName.isEmpty ? nil : workoutName,
                sets: allSets,
                notes: notes.isEmpty ? nil : notes,
                date: startTime,
                duration: duration
            )

            // Reset for new workout
            resetWorkout()
        } catch {
            errorMessage = "Failed to save workout: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func resetWorkout() {
        workoutName = ""
        notes = ""
        selectedExercises = []
        exerciseSets = [:]
        startTime = Date()
    }

    // MARK: - Computed Properties

    var totalSets: Int {
        exerciseSets.values.reduce(0) { $0 + $1.count }
    }

    var totalVolume: Double {
        exerciseSets.values.flatMap { $0 }.reduce(0) { total, set in
            total + (set.weight * Double(set.reps))
        }
    }

    var duration: TimeInterval {
        Date().timeIntervalSince(startTime)
    }

    var canSave: Bool {
        !selectedExercises.isEmpty && exerciseSets.values.contains { !$0.isEmpty }
    }
}

// MARK: - Workout Set Data

struct WorkoutSetData: Identifiable {
    let id: UUID = UUID()
    let exerciseId: UUID
    var weight: Double
    var reps: Int
    var rir: Int?
    var setNumber: Int
    var completed: Bool
}
