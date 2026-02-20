//
//  WorkoutBugRegressionTests.swift
//  VitalArcTests
//
//  Regression tests for Session 23.0 workout domain bug fixes (7 bugs).
//  Each section maps to a specific bug fix to prevent regressions.
//

import XCTest
@testable import VitalArc

// MARK: - Bug 1: Bounds Safety (P0) — removeSet/updateSet out-of-bounds guard

@MainActor
final class BoundsSafetyRegressionTests: XCTestCase {
    var repository: MockWorkoutRepository!
    var viewModel: WorkoutLoggingViewModel!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
        let createUseCase = CreateWorkoutUseCase(repository: repository)
        let progressionUseCase = CalculateProgressionUseCase(repository: repository)
        viewModel = WorkoutLoggingViewModel(
            createWorkoutUseCase: createUseCase,
            calculateProgressionUseCase: progressionUseCase
        )
    }

    override func tearDown() async throws {
        repository = nil
        viewModel = nil
    }

    private func makeExercise(name: String = "Bench Press") -> Exercise {
        Exercise(name: name, category: .push, primaryMuscles: [.chest], equipment: .barbell)
    }

    // MARK: - removeSet bounds checks

    func testRemoveSetWithNegativeIndex() async {
        let exercise = makeExercise()
        await viewModel.addExercise(exercise)
        let countBefore = viewModel.exerciseSets[exercise.id]?.count ?? 0

        // Should not crash, should be a no-op
        viewModel.removeSet(for: exercise.id, at: -1)

        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.count, countBefore)
    }

    func testRemoveSetBeyondArraySize() async {
        let exercise = makeExercise()
        await viewModel.addExercise(exercise)
        let countBefore = viewModel.exerciseSets[exercise.id]?.count ?? 0

        // Index 5 is beyond the single-element array
        viewModel.removeSet(for: exercise.id, at: 5)

        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.count, countBefore)
    }

    func testRemoveSetFromEmptyArray() {
        let exerciseId = UUID()
        // Manually set an empty array
        viewModel.exerciseSets[exerciseId] = []

        // Should not crash
        viewModel.removeSet(for: exerciseId, at: 0)

        XCTAssertEqual(viewModel.exerciseSets[exerciseId]?.count, 0)
    }

    func testRemoveSetAtExactBoundary() async {
        let exercise = makeExercise()
        await viewModel.addExercise(exercise)
        // exerciseSets has 1 element at index 0; index 1 is out of bounds
        viewModel.removeSet(for: exercise.id, at: 1)

        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.count, 1)
    }

    // MARK: - updateSet bounds checks

    func testUpdateSetWithNegativeIndex() async {
        let exercise = makeExercise()
        await viewModel.addExercise(exercise)
        let originalWeight = viewModel.exerciseSets[exercise.id]?.first?.weight

        let fakeSet = WorkoutSetData(
            exerciseId: exercise.id, weight: 999, reps: 99, setNumber: 1, completed: false
        )

        // Should not crash, should be a no-op
        viewModel.updateSet(fakeSet, for: exercise.id, at: -1)

        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.first?.weight, originalWeight)
    }

    func testUpdateSetBeyondArraySize() async {
        let exercise = makeExercise()
        await viewModel.addExercise(exercise)

        let fakeSet = WorkoutSetData(
            exerciseId: exercise.id, weight: 999, reps: 99, setNumber: 1, completed: false
        )

        // Should not crash, should be a no-op
        viewModel.updateSet(fakeSet, for: exercise.id, at: 10)

        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.count, 1)
    }

    func testUpdateSetOnEmptyArray() {
        let exerciseId = UUID()
        viewModel.exerciseSets[exerciseId] = []

        let fakeSet = WorkoutSetData(
            exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1, completed: false
        )

        // Should not crash
        viewModel.updateSet(fakeSet, for: exerciseId, at: 0)

        XCTAssertEqual(viewModel.exerciseSets[exerciseId]?.count, 0)
    }
}

// MARK: - Bug 2: Negative Value Validation (P1) — weight/reps clamping

@MainActor
final class NegativeValueValidationRegressionTests: XCTestCase {
    var repository: MockWorkoutRepository!
    var viewModel: WorkoutLoggingViewModel!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
        let createUseCase = CreateWorkoutUseCase(repository: repository)
        let progressionUseCase = CalculateProgressionUseCase(repository: repository)
        viewModel = WorkoutLoggingViewModel(
            createWorkoutUseCase: createUseCase,
            calculateProgressionUseCase: progressionUseCase
        )
    }

    override func tearDown() async throws {
        repository = nil
        viewModel = nil
    }

    private func makeExercise() -> Exercise {
        Exercise(name: "Squat", category: .legs, primaryMuscles: [.quadriceps], equipment: .barbell)
    }

    func testUpdateSetClampsNegativeWeight() async {
        let exercise = makeExercise()
        await viewModel.addExercise(exercise)

        var setData = viewModel.exerciseSets[exercise.id]![0]
        setData.weight = -5.0
        viewModel.updateSet(setData, for: exercise.id, at: 0)

        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.first?.weight, 0)
    }

    func testUpdateSetClampsNegativeReps() async {
        let exercise = makeExercise()
        await viewModel.addExercise(exercise)

        var setData = viewModel.exerciseSets[exercise.id]![0]
        setData.reps = -1
        viewModel.updateSet(setData, for: exercise.id, at: 0)

        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.first?.reps, 0)
    }

    func testUpdateSetAllowsZeroWeight() async {
        let exercise = makeExercise()
        await viewModel.addExercise(exercise)

        var setData = viewModel.exerciseSets[exercise.id]![0]
        setData.weight = 0
        viewModel.updateSet(setData, for: exercise.id, at: 0)

        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.first?.weight, 0)
    }

    func testUpdateSetAllowsZeroReps() async {
        let exercise = makeExercise()
        await viewModel.addExercise(exercise)

        var setData = viewModel.exerciseSets[exercise.id]![0]
        setData.reps = 0
        viewModel.updateSet(setData, for: exercise.id, at: 0)

        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.first?.reps, 0)
    }

    func testUpdateSetPreservesPositiveValues() async {
        let exercise = makeExercise()
        await viewModel.addExercise(exercise)

        var setData = viewModel.exerciseSets[exercise.id]![0]
        setData.weight = 100
        setData.reps = 12
        viewModel.updateSet(setData, for: exercise.id, at: 0)

        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.first?.weight, 100)
        XCTAssertEqual(viewModel.exerciseSets[exercise.id]?.first?.reps, 12)
    }

    func testSaveWorkoutClampsNegativeValuesAtPersistenceBoundary() async {
        let exercise = makeExercise()
        await viewModel.addExercise(exercise)

        // Directly inject a set with negative values (bypassing updateSet)
        viewModel.exerciseSets[exercise.id] = [
            WorkoutSetData(
                exerciseId: exercise.id,
                weight: -10,
                reps: -3,
                setNumber: 1,
                completed: true
            )
        ]

        await viewModel.saveWorkout()

        // The saved workout should have clamped values
        let savedWorkout = repository.savedWorkouts.first
        XCTAssertNotNil(savedWorkout)
        if let set = savedWorkout?.sets.first {
            XCTAssertGreaterThanOrEqual(set.weight, 0, "Weight should be clamped to >= 0 at save")
            XCTAssertGreaterThanOrEqual(set.reps, 0, "Reps should be clamped to >= 0 at save")
        }
    }
}

// MARK: - Bug 3: Progression Calculation (P1) — zero weight and rounding

@MainActor
final class ProgressionCalculationRegressionTests: XCTestCase {
    var repository: MockWorkoutRepository!
    var useCase: CalculateProgressionUseCase!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
        useCase = CalculateProgressionUseCase(repository: repository)
    }

    override func tearDown() async throws {
        repository = nil
        useCase = nil
    }

    func testZeroMaxWeightReturnsStartingWeight() async throws {
        // Bug: 0 * 1.05 = 0, creating an infinite loop of zero progression
        let exerciseId = UUID()
        let workout = Workout(
            sets: [WorkoutSet(exerciseId: exerciseId, weight: 0, reps: 10, setNumber: 1)]
        )
        repository.mockWorkouts = [workout]

        let suggested = try await useCase.execute(exerciseId: exerciseId)

        // Should return starting weight (20.0), NOT 0
        XCTAssertEqual(suggested, 20.0, "Zero max weight should fall back to starting weight")
    }

    func testNormalProgressionFrom100kg() async throws {
        let exerciseId = UUID()
        let workout = Workout(
            sets: [WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1)]
        )
        repository.mockWorkouts = [workout]

        let suggested = try await useCase.execute(exerciseId: exerciseId)

        // 100 * 1.05 = 105, rounded to nearest 0.5 = 105.0
        XCTAssertEqual(suggested, 105.0, accuracy: 0.01)
    }

    func testProgressionRoundsToNearestHalfKg() async throws {
        // 73kg * 1.05 = 76.65 → round to nearest 0.5 = 76.5
        let exerciseId = UUID()
        let workout = Workout(
            sets: [WorkoutSet(exerciseId: exerciseId, weight: 73, reps: 10, setNumber: 1)]
        )
        repository.mockWorkouts = [workout]

        let suggested = try await useCase.execute(exerciseId: exerciseId)

        // 73 * 1.05 = 76.65 → (76.65 * 2).rounded() / 2 = 153.3.rounded() / 2 = 153 / 2 = 76.5
        XCTAssertEqual(suggested, 76.5, accuracy: 0.01)
    }

    func testProgressionWithSmallWeight() async throws {
        // 5kg * 1.05 = 5.25 → round to nearest 0.5 = 5.5
        let exerciseId = UUID()
        let workout = Workout(
            sets: [WorkoutSet(exerciseId: exerciseId, weight: 5, reps: 15, setNumber: 1)]
        )
        repository.mockWorkouts = [workout]

        let suggested = try await useCase.execute(exerciseId: exerciseId)

        // 5 * 1.05 = 5.25 → (5.25 * 2).rounded() / 2 = 10.5.rounded() / 2 = 11/2 = 5.5
        XCTAssertEqual(suggested, 5.5, accuracy: 0.01)
    }

    func testNoHistoryReturnsDefaultStartingWeight() async throws {
        let exerciseId = UUID()
        // No workouts in repository

        let suggested = try await useCase.execute(exerciseId: exerciseId)

        XCTAssertEqual(suggested, 20.0, "No history should return 20kg starting weight")
    }

    func testProgressionUsesMaxWeightFromMultipleSets() async throws {
        let exerciseId = UUID()
        let workout = Workout(
            sets: [
                WorkoutSet(exerciseId: exerciseId, weight: 80, reps: 10, setNumber: 1),
                WorkoutSet(exerciseId: exerciseId, weight: 90, reps: 8, setNumber: 2),
                WorkoutSet(exerciseId: exerciseId, weight: 85, reps: 6, setNumber: 3)
            ]
        )
        repository.mockWorkouts = [workout]

        let suggested = try await useCase.execute(exerciseId: exerciseId)

        // Max weight is 90, 90 * 1.05 = 94.5
        XCTAssertEqual(suggested, 94.5, accuracy: 0.01)
    }
}

// MARK: - Bug 4: Duplicate Exercise Name Detection (P1) — case-insensitive matching

@MainActor
final class DuplicateExerciseNameRegressionTests: XCTestCase {
    var repository: MockWorkoutRepository!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
    }

    override func tearDown() async throws {
        repository = nil
    }

    /// Tests the duplicate detection logic that AddCustomExerciseView uses:
    /// `existingExercises.contains { $0.name.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame }`
    private func isDuplicate(_ newName: String, existingExercises: [Exercise]) -> Bool {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        return existingExercises.contains { existing in
            existing.name.localizedCaseInsensitiveCompare(trimmed) == .orderedSame
        }
    }

    func testExactDuplicateDetected() async throws {
        let existing = Exercise(name: "Bench Press", category: .push, primaryMuscles: [.chest], equipment: .barbell)
        repository.mockExercises = [existing]

        let exercises = try await repository.getExercises()
        XCTAssertTrue(isDuplicate("Bench Press", existingExercises: exercises))
    }

    func testCaseInsensitiveDuplicateDetected() async throws {
        let existing = Exercise(name: "Bench Press", category: .push, primaryMuscles: [.chest], equipment: .barbell)
        repository.mockExercises = [existing]

        let exercises = try await repository.getExercises()
        XCTAssertTrue(isDuplicate("bench press", existingExercises: exercises))
        XCTAssertTrue(isDuplicate("BENCH PRESS", existingExercises: exercises))
        XCTAssertTrue(isDuplicate("Bench press", existingExercises: exercises))
    }

    func testUniqueNameNotFlaggedAsDuplicate() async throws {
        let existing = Exercise(name: "Bench Press", category: .push, primaryMuscles: [.chest], equipment: .barbell)
        repository.mockExercises = [existing]

        let exercises = try await repository.getExercises()
        XCTAssertFalse(isDuplicate("Incline Bench Press", existingExercises: exercises))
        XCTAssertFalse(isDuplicate("Squat", existingExercises: exercises))
    }

    func testWhitespaceTrimmingBeforeComparison() async throws {
        let existing = Exercise(name: "Bench Press", category: .push, primaryMuscles: [.chest], equipment: .barbell)
        repository.mockExercises = [existing]

        let exercises = try await repository.getExercises()
        XCTAssertTrue(isDuplicate("  Bench Press  ", existingExercises: exercises))
    }
}

// MARK: - Bug 5: Chart Time Range (P2) — TimeRange enum and filtering

final class ChartTimeRangeRegressionTests: XCTestCase {

    func testTimeRangeEnumHasAllExpectedCases() {
        let allCases = ExerciseProgressView.TimeRange.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.week))
        XCTAssertTrue(allCases.contains(.month))
        XCTAssertTrue(allCases.contains(.threeMonths))
        XCTAssertTrue(allCases.contains(.all))
    }

    func testTimeRangeRawValues() {
        XCTAssertEqual(ExerciseProgressView.TimeRange.week.rawValue, "7D")
        XCTAssertEqual(ExerciseProgressView.TimeRange.month.rawValue, "30D")
        XCTAssertEqual(ExerciseProgressView.TimeRange.threeMonths.rawValue, "90D")
        XCTAssertEqual(ExerciseProgressView.TimeRange.all.rawValue, "All")
    }

    func testWeekCutoffIsApproximately7DaysAgo() {
        let cutoff = ExerciseProgressView.TimeRange.week.cutoffDate
        XCTAssertNotNil(cutoff)

        let expectedCutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let difference = abs(cutoff!.timeIntervalSince(expectedCutoff))
        XCTAssertLessThan(difference, 1.0, "Week cutoff should be ~7 days ago")
    }

    func testMonthCutoffIsApproximately30DaysAgo() {
        let cutoff = ExerciseProgressView.TimeRange.month.cutoffDate
        XCTAssertNotNil(cutoff)

        let expectedCutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let difference = abs(cutoff!.timeIntervalSince(expectedCutoff))
        XCTAssertLessThan(difference, 1.0, "Month cutoff should be ~30 days ago")
    }

    func testThreeMonthsCutoffIsApproximately90DaysAgo() {
        let cutoff = ExerciseProgressView.TimeRange.threeMonths.cutoffDate
        XCTAssertNotNil(cutoff)

        let expectedCutoff = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
        let difference = abs(cutoff!.timeIntervalSince(expectedCutoff))
        XCTAssertLessThan(difference, 1.0, "3-month cutoff should be ~90 days ago")
    }

    func testAllTimeRangeHasNilCutoff() {
        XCTAssertNil(ExerciseProgressView.TimeRange.all.cutoffDate,
                     "All time range should have nil cutoff (show everything)")
    }

    func testFilteredPointsWithWeekRange() {
        // Simulate the filteredPoints logic from ExerciseProgressView
        let now = Date()
        let points = [
            ExerciseHistoryPoint(date: now.addingTimeInterval(-86400 * 3), maxWeight: 100, totalVolume: 1000, estimated1RM: 120),   // 3 days ago
            ExerciseHistoryPoint(date: now.addingTimeInterval(-86400 * 10), maxWeight: 90, totalVolume: 900, estimated1RM: 110),    // 10 days ago
            ExerciseHistoryPoint(date: now.addingTimeInterval(-86400 * 60), maxWeight: 80, totalVolume: 800, estimated1RM: 100),    // 60 days ago
        ]

        let cutoff = ExerciseProgressView.TimeRange.week.cutoffDate!
        let filtered = points.filter { $0.date >= cutoff }

        XCTAssertEqual(filtered.count, 1, "Week filter should only include the 3-day-old point")
    }

    func testFilteredPointsWithAllRange() {
        let now = Date()
        let points = [
            ExerciseHistoryPoint(date: now.addingTimeInterval(-86400 * 3), maxWeight: 100, totalVolume: 1000, estimated1RM: 120),
            ExerciseHistoryPoint(date: now.addingTimeInterval(-86400 * 365), maxWeight: 50, totalVolume: 500, estimated1RM: 60),
        ]

        // "All" has nil cutoff, so no filtering
        let cutoff = ExerciseProgressView.TimeRange.all.cutoffDate
        let filtered: [ExerciseHistoryPoint]
        if let cutoff = cutoff {
            filtered = points.filter { $0.date >= cutoff }
        } else {
            filtered = points
        }

        XCTAssertEqual(filtered.count, 2, "All filter should show all data points")
    }
}

// MARK: - Bug 6: Template Schedule Conflict Detection (P2)

@MainActor
final class TemplateConflictDetectionRegressionTests: XCTestCase {
    var workoutRepository: MockWorkoutRepository!
    var templateRepository: MockTemplateRepository!
    var viewModel: WorkoutTemplatesViewModel!

    override func setUp() async throws {
        workoutRepository = MockWorkoutRepository()
        templateRepository = MockTemplateRepository()

        let loadUseCase = LoadWorkoutTemplateUseCase(
            templateRepository: templateRepository,
            workoutRepository: workoutRepository
        )
        let saveUseCase = SaveWorkoutTemplateUseCase(
            templateRepository: templateRepository,
            workoutRepository: workoutRepository
        )

        viewModel = WorkoutTemplatesViewModel(
            loadTemplateUseCase: loadUseCase,
            saveTemplateUseCase: saveUseCase,
            templateRepository: templateRepository
        )
    }

    override func tearDown() async throws {
        workoutRepository = nil
        templateRepository = nil
        viewModel = nil
    }

    private func makeTemplate(name: String = "Push Day") -> WorkoutTemplate {
        WorkoutTemplate(
            name: name,
            exercises: [
                TemplateExercise(
                    exerciseId: UUID(),
                    exerciseName: "Bench Press",
                    orderIndex: 0,
                    sets: 3
                )
            ]
        )
    }

    func testNoConflictWhenNoWorkoutsToday() async {
        // No workouts in repository
        let template = makeTemplate()
        templateRepository.mockTemplates = [template]

        await viewModel.checkConflictsAndStart(from: template)

        // Should proceed directly without showing conflict alert
        XCTAssertNil(viewModel.scheduleConflictMessage,
                     "No conflict message should appear when no workouts today")
        XCTAssertNil(viewModel.pendingConflictTemplate)
    }

    func testConflictDetectedWhenWorkoutExistsToday() async {
        // Add a workout from today
        let todayWorkout = Workout(
            date: Date(),
            name: "Morning Workout",
            sets: [WorkoutSet(exerciseId: UUID(), weight: 100, reps: 10, setNumber: 1)]
        )
        workoutRepository.mockWorkouts = [todayWorkout]

        let template = makeTemplate()
        templateRepository.mockTemplates = [template]

        await viewModel.checkConflictsAndStart(from: template)

        // Should show conflict
        XCTAssertNotNil(viewModel.scheduleConflictMessage,
                        "Should show conflict when workout exists today")
        XCTAssertNotNil(viewModel.pendingConflictTemplate)
    }

    func testConflictMessageIncludesWorkoutName() async {
        let todayWorkout = Workout(
            date: Date(),
            name: "Leg Day",
            sets: [WorkoutSet(exerciseId: UUID(), weight: 100, reps: 10, setNumber: 1)]
        )
        workoutRepository.mockWorkouts = [todayWorkout]

        let template = makeTemplate()
        await viewModel.checkConflictsAndStart(from: template)

        XCTAssertNotNil(viewModel.scheduleConflictMessage)
        XCTAssertTrue(viewModel.scheduleConflictMessage?.contains("Leg Day") == true,
                      "Conflict message should include the workout name")
    }

    func testConflictMessageShowsCorrectCount() async {
        let workout1 = Workout(
            date: Date(),
            name: "Push",
            sets: [WorkoutSet(exerciseId: UUID(), weight: 100, reps: 10, setNumber: 1)]
        )
        let workout2 = Workout(
            date: Date(),
            name: "Pull",
            sets: [WorkoutSet(exerciseId: UUID(), weight: 80, reps: 12, setNumber: 1)]
        )
        workoutRepository.mockWorkouts = [workout1, workout2]

        let template = makeTemplate()
        await viewModel.checkConflictsAndStart(from: template)

        XCTAssertNotNil(viewModel.scheduleConflictMessage)
        XCTAssertTrue(viewModel.scheduleConflictMessage?.contains("2 workouts") == true,
                      "Should show plural count for multiple workouts")
    }

    func testConfirmConflictStartProceedsWithWorkout() async {
        let todayWorkout = Workout(
            date: Date(),
            name: "Morning",
            sets: [WorkoutSet(exerciseId: UUID(), weight: 100, reps: 10, setNumber: 1)]
        )
        workoutRepository.mockWorkouts = [todayWorkout]

        let template = makeTemplate()
        templateRepository.mockTemplates = [template]
        await viewModel.checkConflictsAndStart(from: template)

        // Confirm the conflict
        await viewModel.confirmConflictStart()

        // Should clear conflict state
        XCTAssertNil(viewModel.scheduleConflictMessage)
        XCTAssertNil(viewModel.pendingConflictTemplate)
    }

    func testCancelConflictClearsState() async {
        let todayWorkout = Workout(
            date: Date(),
            name: "Morning",
            sets: [WorkoutSet(exerciseId: UUID(), weight: 100, reps: 10, setNumber: 1)]
        )
        workoutRepository.mockWorkouts = [todayWorkout]

        let template = makeTemplate()
        await viewModel.checkConflictsAndStart(from: template)

        // Cancel
        viewModel.cancelConflictStart()

        XCTAssertNil(viewModel.scheduleConflictMessage)
        XCTAssertNil(viewModel.pendingConflictTemplate)
    }

    func testYesterdayWorkoutDoesNotTriggerConflict() async {
        // Workout from yesterday should NOT trigger conflict
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayWorkout = Workout(
            date: yesterday,
            name: "Yesterday Push",
            sets: [WorkoutSet(exerciseId: UUID(), weight: 100, reps: 10, setNumber: 1)]
        )
        workoutRepository.mockWorkouts = [yesterdayWorkout]

        let template = makeTemplate()
        await viewModel.checkConflictsAndStart(from: template)

        XCTAssertNil(viewModel.scheduleConflictMessage,
                     "Yesterday's workout should not trigger a conflict")
    }
}

// MARK: - Bug 7: Per-Set Notes in History (P2) — notes data flows through ViewModel

@MainActor
final class PerSetNotesDisplayRegressionTests: XCTestCase {
    var repository: MockWorkoutRepository!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
    }

    override func tearDown() async throws {
        repository = nil
    }

    func testWorkoutSetWithNotesIsAccessibleInViewModel() async {
        let exerciseId = UUID()
        let workout = Workout(
            name: "Test Workout",
            sets: [
                WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1, notes: "Felt heavy"),
                WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 8, setNumber: 2, notes: nil),
                WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 6, setNumber: 3, notes: "Back tight")
            ]
        )

        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)
        let sets = viewModel.sets(for: exerciseId)

        XCTAssertEqual(sets.count, 3)
        XCTAssertEqual(sets[0].notes, "Felt heavy")
        XCTAssertNil(sets[1].notes)
        XCTAssertEqual(sets[2].notes, "Back tight")
    }

    func testWorkoutSetWithEmptyNotesIsDistinguishedFromNil() async {
        let exerciseId = UUID()
        let workout = Workout(
            name: "Test",
            sets: [
                WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 10, setNumber: 1, notes: ""),
                WorkoutSet(exerciseId: exerciseId, weight: 100, reps: 8, setNumber: 2, notes: nil)
            ]
        )

        let viewModel = WorkoutDetailViewModel(workout: workout, repository: repository)
        let sets = viewModel.sets(for: exerciseId)

        // Empty string vs nil — both are valid states
        XCTAssertEqual(sets[0].notes, "")
        XCTAssertNil(sets[1].notes)
    }

    func testWorkoutSetNotesPreservedThroughSave() async {
        // Verify that when saving a workout via the ViewModel, notes are persisted
        let createUseCase = CreateWorkoutUseCase(repository: repository)
        let progressionUseCase = CalculateProgressionUseCase(repository: repository)
        let loggingVM = WorkoutLoggingViewModel(
            createWorkoutUseCase: createUseCase,
            calculateProgressionUseCase: progressionUseCase
        )

        let exercise = Exercise(name: "Deadlift", category: .pull, primaryMuscles: [.back], equipment: .barbell)
        await loggingVM.addExercise(exercise)

        // Set notes on the set
        var setData = loggingVM.exerciseSets[exercise.id]![0]
        setData.notes = "Mixed grip"
        setData.weight = 180
        setData.reps = 5
        loggingVM.updateSet(setData, for: exercise.id, at: 0)

        await loggingVM.saveWorkout()

        // Verify notes were saved
        let savedWorkout = repository.savedWorkouts.first
        XCTAssertNotNil(savedWorkout)
        XCTAssertEqual(savedWorkout?.sets.first?.notes, "Mixed grip")
    }
}
