//
//  ExerciseSetView.swift
//  VitalArc
//
//  View for logging sets for an exercise
//

import SwiftUI

struct ExerciseSetView: View {
    let exercise: Exercise
    @Binding var sets: [WorkoutSetData]
    let onAddSet: () -> Void
    let onRemoveSet: (Int) -> Void
    let onUpdateSet: (WorkoutSetData, Int) -> Void
    let onRemoveExercise: () -> Void
    var onSetCompleted: (() -> Void)? = nil
    var estimated1RM: Double? = nil
    var historicalBest1RM: Double? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Exercise Header
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(exercise.name)
                        .font(.vitalH4)

                    HStack(spacing: Spacing.sm) {
                        Label(exercise.equipment.rawValue, systemImage: "dumbbell.fill")
                            .font(.vitalCaption)
                            .foregroundStyle(.secondary)

                        if let muscle = exercise.primaryMuscles.first {
                            Text(muscle.rawValue)
                                .font(.vitalCaption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Button(role: .destructive, action: onRemoveExercise) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.vitalH3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Sets List
            VStack(spacing: Spacing.sm) {
                ForEach(sets.indices, id: \.self) { index in
                    SetRowView(
                        setData: Binding(
                            get: { sets[index] },
                            set: { onUpdateSet($0, index) }
                        ),
                        onDelete: { onRemoveSet(index) },
                        onComplete: onSetCompleted
                    )
                    .id(sets[index].id)
                }
            }

            // Add Set Button
            Button {
                onAddSet()
            } label: {
                Label("Add Set", systemImage: "plus.circle.fill")
                    .font(.vitalBody)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Color.vitalPrimary.opacity(0.1))
                    .foregroundStyle(Color.vitalPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
            }
            .buttonStyle(.plain)

            // Set Summary
            HStack {
                Text("\(sets.count) sets")
                    .font(.vitalCaption)
                    .foregroundStyle(.secondary)

                Spacer()

                OneRepMaxIndicatorView(
                    estimated1RM: estimated1RM,
                    historicalBest: historicalBest1RM
                )

                Text("Volume: \(totalVolume, specifier: "%.0f") kg")
                    .font(.vitalCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
    }

    private var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
}

private struct ExerciseSetPreview: View {
    static let exerciseId = UUID()

    @State private var sets: [WorkoutSetData] = [
        WorkoutSetData(exerciseId: exerciseId, weight: 60, reps: 10, setNumber: 1, completed: true),
        WorkoutSetData(exerciseId: exerciseId, weight: 70, reps: 8, setNumber: 2, completed: true),
        WorkoutSetData(exerciseId: exerciseId, weight: 80, reps: 6, setNumber: 3, completed: false)
    ]

    var body: some View {
        ExerciseSetView(
            exercise: Exercise(
                name: "Bench Press",
                category: .push,
                primaryMuscles: [.chest],
                secondaryMuscles: [.triceps, .shoulders],
                equipment: .barbell
            ),
            sets: $sets,
            onAddSet: { sets.append(WorkoutSetData(exerciseId: Self.exerciseId, weight: 80, reps: 6, setNumber: sets.count + 1, completed: false)) },
            onRemoveSet: { sets.remove(at: $0) },
            onUpdateSet: { sets[$1] = $0 },
            onRemoveExercise: {}
        )
        .padding()
    }
}

#Preview {
    ExerciseSetPreview()
}
