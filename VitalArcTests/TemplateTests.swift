//
//  TemplateTests.swift
//  VitalArcTests
//
//  Test Suite for Workout Template functionality
//  Including exerciseName persistence (Session 9/10)
//

import XCTest
import SwiftData
@testable import VitalArc

@MainActor
final class TemplateTests: XCTestCase {
    var modelContext: ModelContext!
    var container: DependencyContainer!
    var workoutRepository: WorkoutRepository!
    var templateRepository: TemplateRepository!

    override func setUp() async throws {
        // Create in-memory model container for testing
        let schema = Schema([
            ExerciseModel.self,
            WorkoutModel.self,
            WorkoutSetModel.self,
            WorkoutTemplateModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)

        container = DependencyContainer(modelContext: modelContext)
        workoutRepository = container.workoutRepository
        templateRepository = container.templateRepository
    }

    override func tearDown() async throws {
        modelContext = nil
        container = nil
        workoutRepository = nil
        templateRepository = nil
    }

    // MARK: - TemplateExercise exerciseName Tests

    func testTemplateExerciseStoresExerciseName() {
        // Given: Creating a template exercise with a name
        let exerciseId = UUID()
        let exerciseName = "Barbell Bench Press"

        // When: Creating the TemplateExercise
        let templateExercise = TemplateExercise(
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            orderIndex: 0,
            sets: 4,
            repsMin: 8,
            repsMax: 12
        )

        // Then: Exercise name should be stored
        XCTAssertEqual(templateExercise.exerciseName, "Barbell Bench Press")
        XCTAssertEqual(templateExercise.exerciseId, exerciseId)
    }

    func testWorkoutTemplateContainsExerciseNames() {
        // Given: Template exercises with names
        let exercise1 = TemplateExercise(
            exerciseId: UUID(),
            exerciseName: "Squat",
            orderIndex: 0
        )
        let exercise2 = TemplateExercise(
            exerciseId: UUID(),
            exerciseName: "Romanian Deadlift",
            orderIndex: 1
        )

        // When: Creating a template
        let template = WorkoutTemplate(
            name: "Leg Day",
            exercises: [exercise1, exercise2]
        )

        // Then: Template should contain exercise names
        XCTAssertEqual(template.exercises.count, 2)
        XCTAssertEqual(template.exercises[0].exerciseName, "Squat")
        XCTAssertEqual(template.exercises[1].exerciseName, "Romanian Deadlift")
    }

    // MARK: - SaveWorkoutTemplateUseCase Tests

    func testSaveWorkoutTemplateUseCaseLooksUpExerciseNames() async throws {
        // Given: Seeded exercises and a workout
        try await ExerciseSeeds.seedIfNeeded(repository: workoutRepository)
        let exercises = try await workoutRepository.getExercises()
        let benchPress = exercises.first { $0.name.lowercased().contains("bench press") }!
        let shoulderPress = exercises.first { $0.name.lowercased().contains("shoulder") }!

        // Store exact names for reliable assertions
        let benchPressName = benchPress.name
        let shoulderPressName = shoulderPress.name

        // Create a workout with these exercises
        let sets = [
            WorkoutSet(exerciseId: benchPress.id, weight: 100, reps: 10, setNumber: 1),
            WorkoutSet(exerciseId: benchPress.id, weight: 100, reps: 8, setNumber: 2),
            WorkoutSet(exerciseId: shoulderPress.id, weight: 60, reps: 10, setNumber: 1)
        ]
        let workout = Workout(name: "Push Day", sets: sets)
        try await workoutRepository.saveWorkout(workout)

        // When: Creating template from workout
        let useCase = SaveWorkoutTemplateUseCase(
            templateRepository: templateRepository,
            workoutRepository: workoutRepository
        )
        let template = try await useCase.executeFromWorkout(
            workout,
            name: "Push Template",
            category: .custom
        )

        // Then: Template exercises should have correct names (match by exerciseId for reliability)
        XCTAssertEqual(template.exercises.count, 2)

        let templateBenchPress = template.exercises.first { $0.exerciseId == benchPress.id }
        let templateShoulderPress = template.exercises.first { $0.exerciseId == shoulderPress.id }

        XCTAssertNotNil(templateBenchPress, "Template should contain bench press exercise")
        XCTAssertNotNil(templateShoulderPress, "Template should contain shoulder press exercise")
        XCTAssertEqual(templateBenchPress?.exerciseName, benchPressName, "Exercise name should match exactly")
        XCTAssertEqual(templateShoulderPress?.exerciseName, shoulderPressName, "Exercise name should match exactly")
    }

    func testSaveWorkoutTemplateUseCaseFallsBackForUnknownExercise() async throws {
        // Given: A workout with an exercise ID that doesn't exist
        let unknownExerciseId = UUID()
        let sets = [
            WorkoutSet(exerciseId: unknownExerciseId, weight: 100, reps: 10, setNumber: 1)
        ]
        let workout = Workout(name: "Test Workout", sets: sets)
        try await workoutRepository.saveWorkout(workout)

        // When: Creating template from workout with unknown exercise
        let useCase = SaveWorkoutTemplateUseCase(
            repository: templateRepository,
            workoutRepository: workoutRepository
        )
        let template = try await useCase.executeFromWorkout(
            workout,
            name: "Test Template",
            category: .custom
        )

        // Then: Should use fallback name
        XCTAssertEqual(template.exercises.count, 1)
        XCTAssertEqual(
            template.exercises[0].exerciseName,
            Strings.Fallback.unknownExercise,
            "Should use localized fallback string for unknown exercise"
        )
    }

    // MARK: - Template Persistence Tests

    func testTemplateExerciseNamePersistsThroughSaveAndLoad() async throws {
        // Given: A template with exercise names
        let exercise = TemplateExercise(
            exerciseId: UUID(),
            exerciseName: "Incline Dumbbell Press",
            orderIndex: 0,
            sets: 3
        )
        let template = WorkoutTemplate(
            name: "Chest Day",
            exercises: [exercise]
        )

        // When: Saving and loading the template
        try await templateRepository.saveTemplate(template)
        let loadedTemplates = try await templateRepository.getTemplates()

        // Then: Exercise name should be preserved
        XCTAssertEqual(loadedTemplates.count, 1)
        XCTAssertEqual(loadedTemplates[0].exercises.count, 1)
        XCTAssertEqual(
            loadedTemplates[0].exercises[0].exerciseName,
            "Incline Dumbbell Press",
            "Exercise name should persist through save/load cycle"
        )
    }

    func testMultipleExerciseNamesPersist() async throws {
        // Given: Template with multiple exercises
        let exercises = [
            TemplateExercise(exerciseId: UUID(), exerciseName: "Squat", orderIndex: 0),
            TemplateExercise(exerciseId: UUID(), exerciseName: "Leg Press", orderIndex: 1),
            TemplateExercise(exerciseId: UUID(), exerciseName: "Leg Curl", orderIndex: 2),
            TemplateExercise(exerciseId: UUID(), exerciseName: "Calf Raise", orderIndex: 3)
        ]
        let template = WorkoutTemplate(name: "Leg Day", exercises: exercises)

        // When: Saving and loading
        try await templateRepository.saveTemplate(template)
        let loaded = try await templateRepository.getTemplates()

        // Then: All names should persist in order
        XCTAssertEqual(loaded[0].exercises.count, 4)
        XCTAssertEqual(loaded[0].exercises[0].exerciseName, "Squat")
        XCTAssertEqual(loaded[0].exercises[1].exerciseName, "Leg Press")
        XCTAssertEqual(loaded[0].exercises[2].exerciseName, "Leg Curl")
        XCTAssertEqual(loaded[0].exercises[3].exerciseName, "Calf Raise")
    }

    // MARK: - Edge Cases

    func testEmptyExerciseNameHandling() {
        // Given: Template exercise with empty name (edge case)
        let exercise = TemplateExercise(
            exerciseId: UUID(),
            exerciseName: "",
            orderIndex: 0
        )

        // Then: Empty string should be stored (not crash)
        XCTAssertEqual(exercise.exerciseName, "")
    }

    func testSpecialCharactersInExerciseName() async throws {
        // Given: Exercise name with special characters
        let exercise = TemplateExercise(
            exerciseId: UUID(),
            exerciseName: "21's - Bicep Curl (EZ-Bar)",
            orderIndex: 0
        )
        let template = WorkoutTemplate(name: "Arms", exercises: [exercise])

        // When: Saving and loading
        try await templateRepository.saveTemplate(template)
        let loaded = try await templateRepository.getTemplates()

        // Then: Special characters should be preserved
        XCTAssertEqual(
            loaded[0].exercises[0].exerciseName,
            "21's - Bicep Curl (EZ-Bar)"
        )
    }

    func testUnicodeExerciseName() async throws {
        // Given: Exercise name with unicode characters
        let exercise = TemplateExercise(
            exerciseId: UUID(),
            exerciseName: "懸垂 (Pull-up)",
            orderIndex: 0
        )
        let template = WorkoutTemplate(name: "Back", exercises: [exercise])

        // When: Saving and loading
        try await templateRepository.saveTemplate(template)
        let loaded = try await templateRepository.getTemplates()

        // Then: Unicode should be preserved
        XCTAssertEqual(
            loaded[0].exercises[0].exerciseName,
            "懸垂 (Pull-up)"
        )
    }
}
