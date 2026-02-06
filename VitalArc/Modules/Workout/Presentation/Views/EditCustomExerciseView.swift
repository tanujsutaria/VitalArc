//
//  EditCustomExerciseView.swift
//  VitalArc
//
//  View for editing a custom exercise
//

import SwiftUI

struct EditCustomExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencyContainer) private var container

    let exercise: Exercise
    let onSave: () -> Void

    @State private var name: String
    @State private var selectedBodyPart: BodyPartCategory
    @State private var notes: String
    @State private var isSaving = false
    @State private var saveError: String?

    init(exercise: Exercise, onSave: @escaping () -> Void) {
        self.exercise = exercise
        self.onSave = onSave
        self._name = State(initialValue: exercise.name)
        self._notes = State(initialValue: exercise.instructions ?? "")

        // Map primary muscle to body part
        if let primary = exercise.primaryMuscles.first {
            self._selectedBodyPart = State(initialValue: BodyPartCategory.from(muscleGroup: primary))
        } else {
            self._selectedBodyPart = State(initialValue: .custom)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Details") {
                    TextField("Exercise Name", text: $name)

                    Picker("Body Part", selection: $selectedBodyPart) {
                        ForEach(BodyPartCategory.allCases.filter { $0 != .custom }) { bodyPart in
                            HStack {
                                Image(systemName: bodyPart.icon)
                                    .foregroundStyle(bodyPart.color)
                                Text(bodyPart.rawValue)
                            }
                            .tag(bodyPart)
                        }
                    }
                }

                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .alert("Error Saving Exercise", isPresented: .init(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK") { saveError = nil }
            } message: {
                if let error = saveError {
                    Text(error)
                }
            }
        }
    }

    private func saveChanges() {
        isSaving = true

        let muscleGroup = muscleGroupFor(bodyPart: selectedBodyPart)

        let updatedExercise = Exercise(
            id: exercise.id,
            name: name.trimmingCharacters(in: .whitespaces),
            category: exercise.category,
            primaryMuscles: [muscleGroup],
            secondaryMuscles: exercise.secondaryMuscles,
            equipment: exercise.equipment,
            instructions: notes.isEmpty ? nil : notes,
            isCustom: true
        )

        Task {
            do {
                if let container = container {
                    try await container.workoutRepository.updateExercise(updatedExercise)
                }
                onSave()
                dismiss()
            } catch {
                Log.error("Failed to update exercise", error: error, category: .workout)
                saveError = "Failed to save changes. Please try again."
                isSaving = false
            }
        }
    }

    private func muscleGroupFor(bodyPart: BodyPartCategory) -> MuscleGroup {
        switch bodyPart {
        case .chest: return .chest
        case .back: return .back
        case .shoulders: return .shoulders
        case .biceps: return .biceps
        case .triceps: return .triceps
        case .quads: return .quadriceps
        case .hamstrings: return .hamstrings
        case .glutes: return .glutes
        case .calves: return .calves
        case .core: return .abs
        case .forearms: return .forearms
        case .custom: return .fullBody
        }
    }
}

#Preview {
    EditCustomExerciseView(
        exercise: Exercise(
            name: "My Custom Exercise",
            category: .custom,
            primaryMuscles: [.chest],
            equipment: .bodyweight,
            isCustom: true
        ),
        onSave: {}
    )
}
