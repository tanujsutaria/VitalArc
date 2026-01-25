# TASK-008: Workout Logging

## Metadata
- **Phase**: 2 - Workout Engine
- **Priority**: P0 (Critical)
- **Estimated Hours**: 12
- **Dependencies**: TASK-006 (Exercise Library), TASK-002 (HealthKit)
- **Blocked By**: TASK-006

## Objective
Build the complete workout logging experience including the active workout screen, set logging with weight/reps/RIR, rest timer, exercise swapping, and workout completion with HealthKit sync.

## Context
This is the core daily interaction users will have with VitalArc. The workout logging experience must be fast, intuitive, and reliable. Users should be able to log sets quickly during rest periods without friction.

## Requirements

### Functional Requirements
- [ ] Display today's scheduled workout from mesocycle
- [ ] Show exercise list with target sets, reps, and weight
- [ ] Log individual sets with weight, reps, and RIR
- [ ] Display suggested weight based on previous performance
- [ ] Rest timer with haptic feedback and configurable duration
- [ ] Swap exercises mid-workout
- [ ] Add/remove sets dynamically
- [ ] Support supersets (grouped exercises)
- [ ] Add notes to workout and individual exercises
- [ ] Save completed workout to local database
- [ ] Sync completed workout to Apple Health
- [ ] Show workout duration and total volume

### Non-Functional Requirements
- Set logging response time < 100ms
- Timer accuracy within 1 second
- Offline support (sync when online)
- Haptic feedback for timer and set completion
- Accessible with VoiceOver

## Technical Specification

### Files to Create

```
Presentation/
└── Workout/
    ├── Views/
    │   ├── ActiveWorkoutView.swift
    │   ├── ExerciseCardView.swift
    │   ├── SetRowView.swift
    │   ├── SetInputView.swift
    │   ├── RestTimerView.swift
    │   ├── ExerciseSwapSheet.swift
    │   └── WorkoutSummaryView.swift
    └── ViewModels/
        └── ActiveWorkoutViewModel.swift

Domain/
└── UseCases/
    └── Workout/
        ├── LogWorkoutSetUseCase.swift
        ├── CompleteWorkoutUseCase.swift
        └── GetSuggestedWeightUseCase.swift
```

### ActiveWorkoutViewModel.swift

```swift
import SwiftUI
import Observation

@Observable
@MainActor
final class ActiveWorkoutViewModel {
    // MARK: - State

    var workout: Workout?
    var currentExerciseIndex: Int = 0
    var isRestTimerActive: Bool = false
    var restTimeRemaining: Int = 0
    var isLoading: Bool = false
    var error: Error?
    var showExerciseSwap: Bool = false
    var showWorkoutSummary: Bool = false

    // Set input state
    var inputWeight: String = ""
    var inputReps: String = ""
    var inputRIR: Int = 2

    // Computed
    var currentExercise: WorkoutExercise? {
        guard let workout = workout,
              currentExerciseIndex < workout.exercises.count else {
            return nil
        }
        return workout.exercises[currentExerciseIndex]
    }

    var totalVolume: Double {
        workout?.totalVolume ?? 0
    }

    var completedSets: Int {
        workout?.exercises.flatMap(\.sets).count ?? 0
    }

    var totalTargetSets: Int {
        workout?.exercises.reduce(0) { $0 + $1.targetSets } ?? 0
    }

    var workoutDuration: TimeInterval {
        guard let start = workout?.startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    // MARK: - Dependencies

    private let logSetUseCase: LogWorkoutSetUseCase
    private let completeWorkoutUseCase: CompleteWorkoutUseCase
    private let getSuggestedWeightUseCase: GetSuggestedWeightUseCase
    private let workoutRepository: WorkoutRepositoryProtocol

    private var restTimer: Timer?

    // MARK: - Initialization

    init(
        logSetUseCase: LogWorkoutSetUseCase,
        completeWorkoutUseCase: CompleteWorkoutUseCase,
        getSuggestedWeightUseCase: GetSuggestedWeightUseCase,
        workoutRepository: WorkoutRepositoryProtocol
    ) {
        self.logSetUseCase = logSetUseCase
        self.completeWorkoutUseCase = completeWorkoutUseCase
        self.getSuggestedWeightUseCase = getSuggestedWeightUseCase
        self.workoutRepository = workoutRepository
    }

    // MARK: - Workout Lifecycle

    func startWorkout(_ workout: Workout) {
        var mutableWorkout = workout
        mutableWorkout.startTime = Date()
        self.workout = mutableWorkout

        // Load suggested weight for first exercise
        Task {
            await loadSuggestedWeight()
        }
    }

    func loadTodaysWorkout() async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let scheduledWorkout = try await workoutRepository.getTodaysWorkout() {
                startWorkout(scheduledWorkout)
            }
        } catch {
            self.error = error
        }
    }

    // MARK: - Set Logging

    func logSet() async {
        guard let exercise = currentExercise,
              let weight = Double(inputWeight),
              let reps = Int(inputReps) else {
            return
        }

        let set = WorkoutSet(
            id: UUID(),
            exerciseId: exercise.exerciseId,
            weight: weight,
            reps: reps,
            rir: inputRIR,
            timestamp: Date(),
            notes: nil
        )

        do {
            try await logSetUseCase.execute(set, for: workout!.id)

            // Update local state
            workout?.exercises[currentExerciseIndex].sets.append(set)

            // Clear inputs and start rest timer
            clearInputs()
            startRestTimer()

            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

        } catch {
            self.error = error
        }
    }

    func deleteSet(_ set: WorkoutSet) async {
        guard let exerciseIndex = workout?.exercises.firstIndex(where: { $0.exerciseId == set.exerciseId }),
              let setIndex = workout?.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) else {
            return
        }

        workout?.exercises[exerciseIndex].sets.remove(at: setIndex)

        // Persist deletion
        // In a real app, you'd call the repository here
    }

    private func clearInputs() {
        inputWeight = ""
        inputReps = ""
        inputRIR = 2
    }

    // MARK: - Suggested Weight

    func loadSuggestedWeight() async {
        guard let exercise = currentExercise else { return }

        do {
            let suggestion = try await getSuggestedWeightUseCase.execute(
                exerciseId: exercise.exerciseId,
                targetReps: exercise.targetReps.lowerBound,
                targetRIR: exercise.targetRIR
            )

            inputWeight = String(format: "%.1f", suggestion.weight)
            inputReps = String(exercise.targetReps.lowerBound)
            inputRIR = exercise.targetRIR

        } catch {
            // Use last logged weight as fallback
            if let lastSet = exercise.sets.last {
                inputWeight = String(format: "%.1f", lastSet.weight)
            }
        }
    }

    // MARK: - Rest Timer

    func startRestTimer() {
        guard let exercise = currentExercise else { return }

        restTimeRemaining = exercise.restSeconds
        isRestTimerActive = true

        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.timerTick()
            }
        }
    }

    private func timerTick() {
        if restTimeRemaining > 0 {
            restTimeRemaining -= 1

            // Haptic at 10, 5, 3, 2, 1 seconds
            if [10, 5, 3, 2, 1].contains(restTimeRemaining) {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        } else {
            // Timer complete
            restTimer?.invalidate()
            isRestTimerActive = false

            // Strong haptic for timer end
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    func skipRestTimer() {
        restTimer?.invalidate()
        isRestTimerActive = false
        restTimeRemaining = 0
    }

    func addRestTime(_ seconds: Int) {
        restTimeRemaining += seconds
    }

    // MARK: - Exercise Navigation

    func moveToNextExercise() {
        guard let workout = workout,
              currentExerciseIndex < workout.exercises.count - 1 else {
            return
        }

        currentExerciseIndex += 1
        clearInputs()
        Task {
            await loadSuggestedWeight()
        }
    }

    func moveToPreviousExercise() {
        guard currentExerciseIndex > 0 else { return }

        currentExerciseIndex -= 1
        clearInputs()
        Task {
            await loadSuggestedWeight()
        }
    }

    func moveToExercise(at index: Int) {
        guard let workout = workout,
              index >= 0,
              index < workout.exercises.count else {
            return
        }

        currentExerciseIndex = index
        clearInputs()
        Task {
            await loadSuggestedWeight()
        }
    }

    // MARK: - Exercise Swapping

    func swapExercise(with newExercise: Exercise) {
        guard currentExerciseIndex < (workout?.exercises.count ?? 0) else { return }

        // Create new workout exercise from the selected exercise
        let newWorkoutExercise = WorkoutExercise(
            id: UUID(),
            exerciseId: newExercise.id,
            exerciseName: newExercise.name,
            targetSets: workout!.exercises[currentExerciseIndex].targetSets,
            targetReps: workout!.exercises[currentExerciseIndex].targetReps,
            targetRIR: workout!.exercises[currentExerciseIndex].targetRIR,
            suggestedWeight: nil,
            sets: [],
            restSeconds: workout!.exercises[currentExerciseIndex].restSeconds,
            supersetGroup: workout!.exercises[currentExerciseIndex].supersetGroup
        )

        workout?.exercises[currentExerciseIndex] = newWorkoutExercise
        showExerciseSwap = false

        Task {
            await loadSuggestedWeight()
        }
    }

    // MARK: - Set Management

    func addExtraSet() {
        guard currentExerciseIndex < (workout?.exercises.count ?? 0) else { return }
        workout?.exercises[currentExerciseIndex].targetSets += 1
    }

    func removeLastSet() {
        guard currentExerciseIndex < (workout?.exercises.count ?? 0),
              !workout!.exercises[currentExerciseIndex].sets.isEmpty else {
            return
        }
        workout?.exercises[currentExerciseIndex].sets.removeLast()
    }

    // MARK: - Workout Completion

    func finishWorkout() async {
        guard var workout = workout else { return }

        workout.endTime = Date()

        do {
            try await completeWorkoutUseCase.execute(workout)
            showWorkoutSummary = true
        } catch {
            self.error = error
        }
    }

    func cancelWorkout() {
        restTimer?.invalidate()
        workout = nil
    }
}
```

### ActiveWorkoutView.swift

```swift
import SwiftUI

struct ActiveWorkoutView: View {
    @State var viewModel: ActiveWorkoutViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading workout...")
                } else if let workout = viewModel.workout {
                    workoutContent(workout)
                } else {
                    noWorkoutView
                }
            }
            .navigationTitle(viewModel.workout?.name ?? "Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.cancelWorkout()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Finish") {
                        Task {
                            await viewModel.finishWorkout()
                        }
                    }
                    .bold()
                }
            }
            .sheet(isPresented: $viewModel.showExerciseSwap) {
                ExerciseSwapSheet(onSelect: viewModel.swapExercise)
            }
            .sheet(isPresented: $viewModel.showWorkoutSummary) {
                WorkoutSummaryView(workout: viewModel.workout!)
            }
        }
        .task {
            await viewModel.loadTodaysWorkout()
        }
    }

    @ViewBuilder
    private func workoutContent(_ workout: Workout) -> some View {
        VStack(spacing: 0) {
            // Progress header
            workoutProgressHeader

            // Exercise pager
            TabView(selection: $viewModel.currentExerciseIndex) {
                ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                    ExerciseCardView(
                        exercise: exercise,
                        inputWeight: $viewModel.inputWeight,
                        inputReps: $viewModel.inputReps,
                        inputRIR: $viewModel.inputRIR,
                        onLogSet: {
                            Task { await viewModel.logSet() }
                        },
                        onSwap: {
                            viewModel.showExerciseSwap = true
                        },
                        onDeleteSet: { set in
                            Task { await viewModel.deleteSet(set) }
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))

            // Rest timer
            if viewModel.isRestTimerActive {
                RestTimerView(
                    timeRemaining: viewModel.restTimeRemaining,
                    onSkip: viewModel.skipRestTimer,
                    onAdd30: { viewModel.addRestTime(30) }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: viewModel.isRestTimerActive)
    }

    private var workoutProgressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.workoutDuration.formatted())
                        .font(.headline)
                }

                Spacer()

                VStack(alignment: .center) {
                    Text("Sets")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.completedSets)/\(viewModel.totalTargetSets)")
                        .font(.headline)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Volume")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(viewModel.totalVolume)) lbs")
                        .font(.headline)
                }
            }
            .padding(.horizontal)

            ProgressView(value: Double(viewModel.completedSets), total: Double(viewModel.totalTargetSets))
                .tint(.blue)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(.ultraThinMaterial)
    }

    private var noWorkoutView: some View {
        ContentUnavailableView {
            Label("No Workout Scheduled", systemImage: "calendar.badge.exclamationmark")
        } description: {
            Text("There's no workout scheduled for today. Create a mesocycle or start a quick workout.")
        } actions: {
            Button("Start Quick Workout") {
                // TODO: Implement quick workout
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

### ExerciseCardView.swift

```swift
import SwiftUI

struct ExerciseCardView: View {
    let exercise: WorkoutExercise
    @Binding var inputWeight: String
    @Binding var inputReps: String
    @Binding var inputRIR: Int
    let onLogSet: () -> Void
    let onSwap: () -> Void
    let onDeleteSet: (WorkoutSet) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Exercise header
                exerciseHeader

                // Previous sets
                if !exercise.sets.isEmpty {
                    previousSetsSection
                }

                // Input section
                setInputSection

                // Target info
                targetInfoSection
            }
            .padding()
        }
    }

    private var exerciseHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exerciseName)
                    .font(.title2)
                    .bold()

                Text("Set \(exercise.sets.count + 1) of \(exercise.targetSets)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onSwap) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.title3)
            }
            .buttonStyle(.bordered)
        }
    }

    private var previousSetsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Previous Sets")
                .font(.headline)
                .foregroundStyle(.secondary)

            ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                SetRowView(
                    setNumber: index + 1,
                    set: set,
                    onDelete: { onDeleteSet(set) }
                )
            }
        }
    }

    private var setInputSection: some View {
        VStack(spacing: 16) {
            Text("Log Set \(exercise.sets.count + 1)")
                .font(.headline)

            HStack(spacing: 16) {
                // Weight input
                VStack(spacing: 4) {
                    Text("Weight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", text: $inputWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        .multilineTextAlignment(.center)
                    Text("lbs")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Reps input
                VStack(spacing: 4) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", text: $inputReps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .multilineTextAlignment(.center)
                }

                // RIR picker
                VStack(spacing: 4) {
                    Text("RIR")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("RIR", selection: $inputRIR) {
                        ForEach(0...5, id: \.self) { rir in
                            Text("\(rir)").tag(rir)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 80)
                    .clipped()
                }
            }

            Button(action: onLogSet) {
                Label("Log Set", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(inputWeight.isEmpty || inputReps.isEmpty)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var targetInfoSection: some View {
        HStack {
            Label("\(exercise.targetReps.lowerBound)-\(exercise.targetReps.upperBound) reps", systemImage: "repeat")
            Spacer()
            Label("RIR \(exercise.targetRIR)", systemImage: "flame")
            Spacer()
            Label("\(exercise.restSeconds)s rest", systemImage: "timer")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}
```

### RestTimerView.swift

```swift
import SwiftUI

struct RestTimerView: View {
    let timeRemaining: Int
    let onSkip: () -> Void
    let onAdd30: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Rest")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(timeString)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(timerColor)

            HStack(spacing: 24) {
                Button(action: onSkip) {
                    Label("Skip", systemImage: "forward.fill")
                }
                .buttonStyle(.bordered)

                Button(action: onAdd30) {
                    Label("+30s", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThickMaterial)
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var timerColor: Color {
        if timeRemaining <= 5 {
            return .red
        } else if timeRemaining <= 15 {
            return .orange
        } else {
            return .primary
        }
    }
}
```

### LogWorkoutSetUseCase.swift

```swift
import Foundation

final class LogWorkoutSetUseCase {
    private let workoutRepository: WorkoutRepositoryProtocol

    init(workoutRepository: WorkoutRepositoryProtocol) {
        self.workoutRepository = workoutRepository
    }

    func execute(_ set: WorkoutSet, for workoutId: UUID) async throws {
        try await workoutRepository.saveSet(set, workoutId: workoutId)

        Logger.workout.info("Logged set: \(set.weight)x\(set.reps) @ RIR \(set.rir)")
    }
}
```

### CompleteWorkoutUseCase.swift

```swift
import Foundation
import HealthKit

final class CompleteWorkoutUseCase {
    private let workoutRepository: WorkoutRepositoryProtocol
    private let healthKitManager: HealthKitManager

    init(
        workoutRepository: WorkoutRepositoryProtocol,
        healthKitManager: HealthKitManager
    ) {
        self.workoutRepository = workoutRepository
        self.healthKitManager = healthKitManager
    }

    func execute(_ workout: Workout) async throws {
        // Save to local database
        try await workoutRepository.saveWorkout(workout)

        // Sync to HealthKit
        if let start = workout.startTime, let end = workout.endTime {
            try await healthKitManager.saveWorkout(
                activityType: .traditionalStrengthTraining,
                start: start,
                end: end,
                energyBurned: estimateCaloriesBurned(workout),
                metadata: [
                    "VitalArc_WorkoutId": workout.id.uuidString,
                    "VitalArc_MesocycleId": workout.mesocycleId?.uuidString ?? ""
                ]
            )
        }

        Logger.workout.info("Completed workout: \(workout.name)")
    }

    private func estimateCaloriesBurned(_ workout: Workout) -> Double {
        // Simple estimation: ~5 calories per set
        let setCount = workout.exercises.flatMap(\.sets).count
        return Double(setCount) * 5.0
    }
}
```

### GetSuggestedWeightUseCase.swift

```swift
import Foundation

struct WeightSuggestion {
    let weight: Double
    let confidence: SuggestionConfidence
    let reason: String
}

enum SuggestionConfidence {
    case high      // Based on recent performance
    case medium    // Based on older data
    case low       // No history, using defaults
}

final class GetSuggestedWeightUseCase {
    private let workoutRepository: WorkoutRepositoryProtocol

    init(workoutRepository: WorkoutRepositoryProtocol) {
        self.workoutRepository = workoutRepository
    }

    func execute(
        exerciseId: UUID,
        targetReps: Int,
        targetRIR: Int
    ) async throws -> WeightSuggestion {
        // Get recent sets for this exercise
        let recentSets = try await workoutRepository.getRecentSets(
            exerciseId: exerciseId,
            limit: 10
        )

        guard !recentSets.isEmpty else {
            return WeightSuggestion(
                weight: 0,
                confidence: .low,
                reason: "No previous data. Enter your starting weight."
            )
        }

        // Find most recent set at similar rep range
        let similarSets = recentSets.filter { set in
            abs(set.reps - targetReps) <= 2
        }

        if let lastSimilar = similarSets.first {
            // Adjust based on RIR difference
            let rirDiff = lastSimilar.rir - targetRIR
            let adjustment = Double(rirDiff) * 0.025  // 2.5% per RIR

            let suggestedWeight = lastSimilar.weight * (1 + adjustment)

            return WeightSuggestion(
                weight: roundToNearest(suggestedWeight, increment: 2.5),
                confidence: .high,
                reason: "Based on your last set of \(Int(lastSimilar.weight))×\(lastSimilar.reps)"
            )
        }

        // Fallback to most recent set
        let lastSet = recentSets[0]
        return WeightSuggestion(
            weight: lastSet.weight,
            confidence: .medium,
            reason: "Based on your last session"
        )
    }

    private func roundToNearest(_ value: Double, increment: Double) -> Double {
        round(value / increment) * increment
    }
}
```

## Implementation Guide

### Step 1: Create Domain Layer
1. Create use case files
2. Add repository protocol methods for sets

### Step 2: Create View Models
1. Create ActiveWorkoutViewModel
2. Wire up dependencies in DependencyContainer

### Step 3: Create Views
1. Build from bottom up: SetRowView → ExerciseCardView → ActiveWorkoutView
2. Add RestTimerView with animations

### Step 4: Integrate with Navigation
1. Add workout tab to main navigation
2. Handle workout start/end states

### Step 5: Test Thoroughly
1. Test set logging
2. Test timer accuracy
3. Test HealthKit sync
4. Test offline behavior

## Acceptance Criteria

- [ ] Can view scheduled workout for today
- [ ] Can log sets with weight, reps, and RIR
- [ ] Suggested weight appears based on history
- [ ] Rest timer starts after logging set
- [ ] Timer has haptic feedback at key moments
- [ ] Can skip or extend rest timer
- [ ] Can navigate between exercises
- [ ] Can swap exercise mid-workout
- [ ] Can add/remove extra sets
- [ ] Workout saves to local database on completion
- [ ] Workout syncs to Apple Health
- [ ] Total volume and duration displayed correctly
- [ ] Works offline (syncs when online)
- [ ] VoiceOver accessible

## Testing Requirements

### Unit Tests
- WeightSuggestion algorithm with various histories
- Calorie estimation
- Timer logic

### UI Tests
- Complete workout flow
- Set logging
- Timer skip/extend

### Integration Tests
- HealthKit sync
- Database persistence

## References

- [Data Models](../../architecture/DATA_MODELS.md)
- [Algorithms](../../specs/ALGORITHMS.md) - Weight progression section
- [HealthKit Integration](../../architecture/HEALTHKIT.md)

## Notes for AI Agent

- Focus on making set logging FAST - this is used during rest periods
- Haptics are important for the timer experience
- Handle keyboard appearance gracefully
- Consider one-handed use during workouts
- Test with Apple Watch for future integration
