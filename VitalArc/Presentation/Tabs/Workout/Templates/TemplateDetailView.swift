//
//  TemplateDetailView.swift
//  VitalArc
//
//  Detailed view of a workout template
//

import SwiftUI

struct TemplateDetailView: View {
    let template: WorkoutTemplate
    let onUseTemplate: (WorkoutTemplate) -> Void
    let onDeleteTemplate: (WorkoutTemplate) -> Void

    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: template.category.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                    Text(template.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    if let description = template.description {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // Category badge
                    HStack {
                        Label(template.category.displayName, systemImage: template.category.icon)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()

                // Stats
                HStack(spacing: 40) {
                    StatColumn(
                        value: "\(template.exerciseCount)",
                        label: "Exercises",
                        icon: "figure.strengthtraining.traditional"
                    )

                    StatColumn(
                        value: "\(template.totalSets)",
                        label: "Total Sets",
                        icon: "list.number"
                    )

                    StatColumn(
                        value: "\(template.estimatedDuration)",
                        label: "Minutes",
                        icon: "clock"
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                // Usage stats
                if template.useCount > 0 {
                    HStack(spacing: 40) {
                        VStack(spacing: 4) {
                            Text("\(template.useCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Times Used")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let lastUsed = template.lastUsed {
                            VStack(spacing: 4) {
                                Text(lastUsed, style: .relative)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("Last Used")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Exercise list
                VStack(alignment: .leading, spacing: 12) {
                    Text("Exercises")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(template.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { exercise in
                        ExerciseDetailRow(exercise: exercise, index: exercise.orderIndex)
                    }
                }
                .padding(.bottom)

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        onUseTemplate(template)
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Workout")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Template")
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Template?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDeleteTemplate(template)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

struct StatColumn: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ExerciseDetailRow: View {
    let exercise: TemplateExercise
    let index: Int

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Order number
            Text("\(index + 1)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            // Exercise details
            VStack(alignment: .leading, spacing: 8) {
                Text("Exercise \(index + 1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "number")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text("\(exercise.sets) sets × \(exercise.repsDisplay) reps")
                    }
                    .font(.subheadline)

                    HStack {
                        Image(systemName: "timer")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text("Rest: \(exercise.restDisplay)")
                    }
                    .font(.subheadline)
                }

                if let notes = exercise.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
