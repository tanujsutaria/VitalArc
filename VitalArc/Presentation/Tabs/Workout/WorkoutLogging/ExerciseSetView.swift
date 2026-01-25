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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)

                    HStack(spacing: 8) {
                        Label(exercise.equipment.rawValue, systemImage: "dumbbell.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let muscle = exercise.primaryMuscles.first {
                            Text(muscle.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Button(role: .destructive, action: onRemoveExercise) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Sets List
            VStack(spacing: 8) {
                ForEach(sets.indices, id: \.self) { index in
                    SetRowView(
                        setData: Binding(
                            get: { sets[index] },
                            set: { onUpdateSet($0, index) }
                        ),
                        onDelete: { onRemoveSet(index) }
                    )
                    .id(sets[index].id)
                }
            }

            // Add Set Button
            Button {
                onAddSet()
            } label: {
                Label("Add Set", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundStyle(.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            // Set Summary
            HStack {
                Text("\(sets.count) sets")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Volume: \(totalVolume, specifier: "%.0f") kg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
}
