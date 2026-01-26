//
//  CreateTemplateView.swift
//  VitalArc
//
//  View for creating new workout templates
//

import SwiftUI

struct CreateTemplateView: View {
    @State private var templateName = ""
    @State private var templateDescription = ""
    @State private var selectedCategory: TemplateCategory = .custom
    @State private var estimatedDuration = 60
    @State private var templateExercises: [TemplateExerciseBuilder] = []
    @State private var showingExercisePicker = false

    @Environment(\.dismiss) private var dismiss
    let viewModel: WorkoutTemplatesViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Template Details") {
                    TextField("Name", text: $templateName)
                    TextField("Description (optional)", text: $templateDescription, axis: .vertical)
                        .lineLimit(3...6)

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TemplateCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }

                    Stepper("Duration: \(estimatedDuration) min", value: $estimatedDuration, in: 15...180, step: 5)
                }

                Section {
                    ForEach(templateExercises) { exercise in
                        TemplateExerciseRow(exercise: exercise) {
                            if let index = templateExercises.firstIndex(where: { $0.id == exercise.id }) {
                                templateExercises.remove(at: index)
                            }
                        }
                    }
                    .onMove { from, to in
                        templateExercises.move(fromOffsets: from, toOffset: to)
                        updateOrderIndices()
                    }

                    Button {
                        showingExercisePicker = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Exercises")
                } footer: {
                    if !templateExercises.isEmpty {
                        Text("Drag to reorder exercises")
                    }
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .disabled(!isValid)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                // Exercise picker would go here
                // For now, just add a placeholder
                ExercisePickerPlaceholder { exerciseId, exerciseName in
                    addExercise(id: exerciseId, name: exerciseName)
                }
            }
        }
    }

    private var isValid: Bool {
        !templateName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !templateExercises.isEmpty
    }

    private func addExercise(id: UUID, name: String) {
        let exercise = TemplateExerciseBuilder(
            exerciseId: id,
            exerciseName: name,
            orderIndex: templateExercises.count,
            sets: 3,
            repsMin: 8,
            repsMax: 12,
            restSeconds: 90
        )
        templateExercises.append(exercise)
    }

    private func updateOrderIndices() {
        for (index, _) in templateExercises.enumerated() {
            templateExercises[index].orderIndex = index
        }
    }

    private func saveTemplate() {
        let exercises = templateExercises.map { builder in
            TemplateExercise(
                exerciseId: builder.exerciseId,
                orderIndex: builder.orderIndex,
                sets: builder.sets,
                repsMin: builder.repsMin,
                repsMax: builder.repsMax,
                restSeconds: builder.restSeconds,
                notes: builder.notes
            )
        }

        let template = WorkoutTemplate(
            name: templateName,
            description: templateDescription.isEmpty ? nil : templateDescription,
            exercises: exercises,
            category: selectedCategory,
            estimatedDuration: estimatedDuration
        )

        Task {
            do {
                try await viewModel.saveTemplateUseCase.execute(template)
                await viewModel.loadTemplates()
                dismiss()
            } catch {
                // Handle error
            }
        }
    }
}

struct TemplateExerciseRow: View {
    @State var exercise: TemplateExerciseBuilder
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(exercise.exerciseName)
                    .font(.vitalH4)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.vitalDanger)
                }
            }

            HStack(spacing: Spacing.lg) {
                Stepper("Sets: \(exercise.sets)", value: $exercise.sets, in: 1...10)
                    .frame(maxWidth: .infinity)
            }

            HStack(spacing: Spacing.lg) {
                Stepper("Min: \(exercise.repsMin)", value: $exercise.repsMin, in: 1...50)
                    .frame(maxWidth: .infinity)
                Stepper("Max: \(exercise.repsMax)", value: $exercise.repsMax, in: 1...50)
                    .frame(maxWidth: .infinity)
            }

            Stepper("Rest: \(exercise.restSeconds)s", value: $exercise.restSeconds, in: 30...300, step: 15)
        }
        .padding(.vertical, Spacing.xs)
    }
}

struct ExercisePickerPlaceholder: View {
    let onSelect: (UUID, String) -> Void
    @Environment(\.dismiss) private var dismiss

    // Sample exercises for demonstration
    let sampleExercises = [
        (UUID(), "Bench Press"),
        (UUID(), "Squat"),
        (UUID(), "Deadlift"),
        (UUID(), "Overhead Press"),
        (UUID(), "Barbell Row"),
        (UUID(), "Pull-ups"),
        (UUID(), "Dips"),
        (UUID(), "Lunges")
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(sampleExercises, id: \.0) { exercise in
                    Button {
                        onSelect(exercise.0, exercise.1)
                        dismiss()
                    } label: {
                        Text(exercise.1)
                    }
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Builder Model

@Observable
final class TemplateExerciseBuilder: Identifiable {
    let id = UUID()
    let exerciseId: UUID
    let exerciseName: String
    var orderIndex: Int
    var sets: Int
    var repsMin: Int
    var repsMax: Int
    var restSeconds: Int
    var notes: String?

    init(
        exerciseId: UUID,
        exerciseName: String,
        orderIndex: Int,
        sets: Int,
        repsMin: Int,
        repsMax: Int,
        restSeconds: Int,
        notes: String? = nil
    ) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.orderIndex = orderIndex
        self.sets = sets
        self.repsMin = repsMin
        self.repsMax = repsMax
        self.restSeconds = restSeconds
        self.notes = notes
    }
}
