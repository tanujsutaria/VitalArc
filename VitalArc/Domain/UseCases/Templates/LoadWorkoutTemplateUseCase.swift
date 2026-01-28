//
//  LoadWorkoutTemplateUseCase.swift
//  VitalArc
//
//  Use case for loading workout templates
//

import Foundation

/// Loads workout templates from the repository
final class LoadWorkoutTemplateUseCase {
    private let templateRepository: TemplateRepository
    private let workoutRepository: WorkoutRepository

    init(templateRepository: TemplateRepository, workoutRepository: WorkoutRepository) {
        self.templateRepository = templateRepository
        self.workoutRepository = workoutRepository
    }

    /// Load all templates
    func execute() async throws -> [WorkoutTemplate] {
        return try await templateRepository.getTemplates()
    }

    /// Load templates for a specific category
    func execute(category: TemplateCategory) async throws -> [WorkoutTemplate] {
        return try await templateRepository.getTemplates(category: category)
    }

    /// Load a specific template by ID
    func execute(id: UUID) async throws -> WorkoutTemplate? {
        return try await templateRepository.getTemplate(id: id)
    }

    /// Create a workout from a template
    func createWorkoutFromTemplate(_ template: WorkoutTemplate) async throws -> Workout {
        // Fetch exercise details
        var workoutSets: [WorkoutSet] = []

        for templateExercise in template.exercises.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            // Create sets for this exercise
            for setNumber in 1...templateExercise.sets {
                let set = WorkoutSet(
                    exerciseId: templateExercise.exerciseId,
                    weight: 0, // User will fill this in
                    reps: templateExercise.repsMin, // Use min as target
                    rir: nil,
                    rpe: nil,
                    mesocycleId: nil,
                    setNumber: setNumber,
                    completed: false
                )
                workoutSets.append(set)
            }
        }

        // Create workout
        let workout = Workout(
            date: Date(),
            name: template.name,
            sets: workoutSets,
            notes: template.description,
            duration: TimeInterval(template.estimatedDuration * 60)
        )

        // Increment template usage
        try await templateRepository.incrementTemplateUsage(id: template.id)

        return workout
    }

    /// Get most used templates
    func getMostUsedTemplates(limit: Int = 5) async throws -> [WorkoutTemplate] {
        let templates = try await templateRepository.getTemplates()
        return Array(templates.sorted { $0.useCount > $1.useCount }.prefix(limit))
    }

    /// Get recently used templates
    func getRecentlyUsedTemplates(limit: Int = 5) async throws -> [WorkoutTemplate] {
        let templates = try await templateRepository.getTemplates()
        let withLastUsed = templates.filter { $0.lastUsed != nil }
        return Array(withLastUsed.sorted { ($0.lastUsed ?? .distantPast) > ($1.lastUsed ?? .distantPast) }.prefix(limit))
    }
}
