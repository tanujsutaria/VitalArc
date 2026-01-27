//
//  SaveWorkoutTemplateUseCase.swift
//  VitalArc
//
//  Use case for saving workout templates
//

import Foundation

/// Saves a workout template to the repository
final class SaveWorkoutTemplateUseCase {
    private let templateRepository: TemplateRepository
    private let workoutRepository: WorkoutRepository?

    init(templateRepository: TemplateRepository, workoutRepository: WorkoutRepository? = nil) {
        self.templateRepository = templateRepository
        self.workoutRepository = workoutRepository
    }

    /// Save a new or updated template
    func execute(_ template: WorkoutTemplate) async throws {
        // Validate template name
        let trimmedName = template.name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw TemplateError.emptyName
        }

        // Validate name length (prevent excessively long names)
        guard trimmedName.count <= 100 else {
            throw TemplateError.nameTooLong
        }

        guard !template.exercises.isEmpty else {
            throw TemplateError.noExercises
        }

        // Check if template already exists
        if let _ = try? await templateRepository.getTemplate(id: template.id) {
            // Update existing template
            try await templateRepository.updateTemplate(template)
        } else {
            // Save new template
            try await templateRepository.saveTemplate(template)
        }
    }

    /// Create template from a completed workout
    func executeFromWorkout(
        _ workout: Workout,
        name: String,
        category: TemplateCategory
    ) async throws -> WorkoutTemplate {
        // Group sets by exercise
        var exerciseGroups: [UUID: [WorkoutSet]] = [:]

        for set in workout.sets {
            if exerciseGroups[set.exerciseId] == nil {
                exerciseGroups[set.exerciseId] = []
            }
            exerciseGroups[set.exerciseId]?.append(set)
        }

        // Look up exercise names with proper error handling
        var exerciseNames: [UUID: String] = [:]
        if let workoutRepo = workoutRepository {
            for exerciseId in exerciseGroups.keys {
                do {
                    if let exercise = try await workoutRepo.getExercise(id: exerciseId) {
                        exerciseNames[exerciseId] = exercise.name
                    } else {
                        // Exercise not found in database - use fallback
                        exerciseNames[exerciseId] = Strings.Fallback.unknownExercise
                    }
                } catch {
                    // Log error but continue with fallback name
                    // In production, consider proper logging framework
                    print("Warning: Failed to fetch exercise \(exerciseId): \(error.localizedDescription)")
                    exerciseNames[exerciseId] = Strings.Fallback.unknownExercise
                }
            }
        }

        // Create template exercises - sort by exerciseId for consistent ordering
        // Dictionary enumeration order is not guaranteed, so we sort explicitly
        let sortedExerciseGroups = exerciseGroups.sorted { $0.key.uuidString < $1.key.uuidString }

        var templateExercises: [TemplateExercise] = []
        for (index, element) in sortedExerciseGroups.enumerated() {
            let (exerciseId, sets) = element

            let totalSets = sets.count
            // Explicit empty check for safety, even though reduce on empty array returns 0
            let avgReps = sets.isEmpty ? 8 : sets.map { $0.reps }.reduce(0, +) / sets.count
            let exerciseName = exerciseNames[exerciseId] ?? Strings.Fallback.unknownExercise

            let templateExercise = TemplateExercise(
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                orderIndex: index,
                sets: totalSets,
                repsMin: max(avgReps - 2, 1),
                repsMax: avgReps + 2,
                restSeconds: 90,
                notes: nil
            )
            templateExercises.append(templateExercise)
        }

        let durationMinutes = workout.duration.map { Int($0 / 60) } ?? 60

        let template = WorkoutTemplate(
            name: name,
            description: "Created from workout on \(workout.date.formatted(date: .abbreviated, time: .omitted))",
            exercises: templateExercises.sorted { $0.orderIndex < $1.orderIndex },
            category: category,
            estimatedDuration: durationMinutes
        )

        try await execute(template)
        return template
    }
}

enum TemplateError: Error, LocalizedError {
    case emptyName
    case nameTooLong
    case noExercises
    case invalidExercise

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Template name cannot be empty"
        case .nameTooLong:
            return "Template name cannot exceed 100 characters"
        case .noExercises:
            return "Template must have at least one exercise"
        case .invalidExercise:
            return "One or more exercises are invalid"
        }
    }
}
