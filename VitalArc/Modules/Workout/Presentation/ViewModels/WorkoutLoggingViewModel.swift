//
//  WorkoutLoggingViewModel.swift
//  VitalArc
//
//  ViewModel for Workout Logging
//

import Foundation
import Observation

@MainActor
@Observable
final class WorkoutLoggingViewModel {
    private let createWorkoutUseCase: CreateWorkoutUseCase
    private let calculateProgressionUseCase: CalculateProgressionUseCase
    private let detectPersonalRecordUseCase: DetectPersonalRecordUseCase?
    private let calculateOneRepMaxUseCase: CalculateOneRepMaxUseCase?

    var workoutName: String = ""
    var notes: String = ""
    var selectedExercises: [Exercise] = []
    var exerciseSets: [UUID: [WorkoutSetData]] = [:] // exerciseId -> sets
    var startTime: Date = Date()
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showingExerciseLibrary: Bool = false

    // MARK: - Rest Timer State
    var restTimerActive: Bool = false
    var restTimerEndDate: Date? = nil
    var restTimerDuration: Int = 90 // default rest seconds
    var restTimerExerciseId: UUID? = nil
    var exerciseRestDurations: [UUID: Int] = [:]  // per-exercise overrides

    // MARK: - Superset/Circuit State
    var setGroups: [SetGroup] = []
    var selectedExerciseIdsForGrouping: Set<UUID> = []
    var isGroupingMode: Bool = false

    // MARK: - Personal Records State
    var newPersonalRecords: [PersonalRecord] = []
    var showingPersonalRecords: Bool = false

    // MARK: - 1RM State
    var historicalBest1RM: [UUID: Double] = [:]

    init(
        createWorkoutUseCase: CreateWorkoutUseCase,
        calculateProgressionUseCase: CalculateProgressionUseCase,
        detectPersonalRecordUseCase: DetectPersonalRecordUseCase? = nil,
        calculateOneRepMaxUseCase: CalculateOneRepMaxUseCase? = nil
    ) {
        self.createWorkoutUseCase = createWorkoutUseCase
        self.calculateProgressionUseCase = calculateProgressionUseCase
        self.detectPersonalRecordUseCase = detectPersonalRecordUseCase
        self.calculateOneRepMaxUseCase = calculateOneRepMaxUseCase
    }

    // MARK: - Rest Timer

    func startRestTimer(duration: Int, for exerciseId: UUID) {
        restTimerDuration = duration
        restTimerExerciseId = exerciseId
        restTimerEndDate = Date().addingTimeInterval(TimeInterval(duration))
        restTimerActive = true
    }

    func cancelRestTimer() {
        restTimerActive = false
        restTimerEndDate = nil
        restTimerExerciseId = nil
    }

    func restTimerFinished() {
        restTimerActive = false
        restTimerEndDate = nil
        restTimerExerciseId = nil
    }

    func restDurationForExercise(_ exerciseId: UUID) -> Int {
        // Per-exercise override
        if let custom = exerciseRestDurations[exerciseId] { return custom }
        // Superset-aware: short rest between exercises in same group, full rest after last
        if let _ = groupForExercise(exerciseId), !isLastInGroup(exerciseId) {
            return 30
        }
        return restTimerDuration  // global default (90s)
    }

    // MARK: - Superset/Circuit Management

    func toggleGroupingMode() {
        isGroupingMode.toggle()
        if !isGroupingMode {
            selectedExerciseIdsForGrouping.removeAll()
        }
    }

    func toggleExerciseForGrouping(_ exerciseId: UUID) {
        if selectedExerciseIdsForGrouping.contains(exerciseId) {
            selectedExerciseIdsForGrouping.remove(exerciseId)
        } else {
            selectedExerciseIdsForGrouping.insert(exerciseId)
        }
    }

    func createGroup(type: SetGroupType) {
        guard selectedExerciseIdsForGrouping.count >= 2 else { return }

        // Remove these exercises from any existing groups
        setGroups.removeAll { group in
            group.exerciseIds.contains(where: { selectedExerciseIdsForGrouping.contains($0) })
        }

        // Preserve the order from selectedExercises
        let orderedIds = selectedExercises
            .filter { selectedExerciseIdsForGrouping.contains($0.id) }
            .map { $0.id }

        let group = SetGroup(groupType: type, exerciseIds: orderedIds)
        setGroups.append(group)

        selectedExerciseIdsForGrouping.removeAll()
        isGroupingMode = false
    }

    func removeGroup(_ groupId: UUID) {
        setGroups.removeAll { $0.id == groupId }
    }

    func editGroupType(_ groupId: UUID, newType: SetGroupType) {
        guard let idx = setGroups.firstIndex(where: { $0.id == groupId }) else { return }
        let old = setGroups[idx]
        setGroups[idx] = SetGroup(id: old.id, name: old.name, groupType: newType, exerciseIds: old.exerciseIds)
    }

    func groupForExercise(_ exerciseId: UUID) -> SetGroup? {
        setGroups.first { $0.exerciseIds.contains(exerciseId) }
    }

    func isFirstInGroup(_ exerciseId: UUID) -> Bool {
        guard let group = groupForExercise(exerciseId) else { return false }
        return group.exerciseIds.first == exerciseId
    }

    func isLastInGroup(_ exerciseId: UUID) -> Bool {
        guard let group = groupForExercise(exerciseId) else { return false }
        return group.exerciseIds.last == exerciseId
    }

    // MARK: - Exercise Management

    func addExercise(_ exercise: Exercise) async {
        guard !selectedExercises.contains(where: { $0.id == exercise.id }) else {
            return
        }

        selectedExercises.append(exercise)

        // Calculate suggested weight from progression, with fallback to default
        var suggestedWeight: Double = 20.0
        do {
            suggestedWeight = try await calculateProgressionUseCase.execute(exerciseId: exercise.id)
        } catch {
            Log.warning("Failed to calculate progression for exercise '\(exercise.name)', using default 20.0 kg: \(error.localizedDescription)", category: .workout)
        }

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

        // Load historical best 1RM for this exercise
        if let oneRMUseCase = calculateOneRepMaxUseCase {
            if let best = await oneRMUseCase.getHistoricalBest(for: exercise.id) {
                historicalBest1RM[exercise.id] = best
            }
        }

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
        guard var sets = exerciseSets[exerciseId],
              sets.indices.contains(index) else { return }
        sets.remove(at: index)

        // Renumber remaining sets
        for (idx, var set) in sets.enumerated() {
            set.setNumber = idx + 1
            sets[idx] = set
        }

        exerciseSets[exerciseId] = sets
    }

    func updateSet(_ updatedSet: WorkoutSetData, for exerciseId: UUID, at index: Int) {
        guard var sets = exerciseSets[exerciseId],
              sets.indices.contains(index) else { return }
        // Clamp weight and reps to non-negative values
        var sanitized = updatedSet
        sanitized.weight = max(0, sanitized.weight)
        sanitized.reps = max(0, sanitized.reps)
        sets[index] = sanitized
        exerciseSets[exerciseId] = sets
    }

    // MARK: - Workout Completion

    func saveWorkout() async {
        isLoading = true
        errorMessage = nil

        do {
            // Convert all sets to WorkoutSet entities, clamping negative values
            var allSets: [WorkoutSet] = []
            for (exerciseId, setDataArray) in exerciseSets {
                let workoutSets = setDataArray.map { setData in
                    WorkoutSet(
                        exerciseId: exerciseId,
                        weight: max(0, setData.weight),
                        reps: max(0, setData.reps),
                        rir: setData.rir,
                        setNumber: setData.setNumber,
                        completed: setData.completed,
                        notes: setData.notes
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

            // Detect personal records
            if let detectPR = detectPersonalRecordUseCase {
                do {
                    let prs = try await detectPR.execute(sets: allSets)
                    if !prs.isEmpty {
                        newPersonalRecords = prs
                        showingPersonalRecords = true
                    }
                } catch {
                    Log.warning("Failed to detect personal records: \(error.localizedDescription)", category: .workout)
                }
            }

            // Reset for new workout (if no PRs to show)
            if !showingPersonalRecords {
                resetWorkout()
            }
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .saving)
        }

        isLoading = false
    }

    // MARK: - 1RM Calculations

    /// Returns the current estimated 1RM for an exercise based on the best set logged so far
    func currentEstimated1RM(for exerciseId: UUID) -> Double? {
        guard let sets = exerciseSets[exerciseId] else { return nil }
        return sets.compactMap { set in
            CalculateOneRepMaxUseCase.estimate(weight: set.weight, reps: set.reps)
        }.max()
    }

    /// Returns the historical best 1RM for an exercise
    func historicalBest(for exerciseId: UUID) -> Double? {
        historicalBest1RM[exerciseId]
    }

    func resetWorkout() {
        workoutName = ""
        notes = ""
        selectedExercises = []
        exerciseSets = [:]
        startTime = Date()
        cancelRestTimer()
        setGroups = []
        selectedExerciseIdsForGrouping = []
        isGroupingMode = false
        historicalBest1RM = [:]
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
    var notes: String?
}
