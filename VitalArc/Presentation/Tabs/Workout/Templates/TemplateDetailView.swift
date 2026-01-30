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
            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.md) {
                    Image(systemName: template.category.icon)
                        .font(.vitalIconGiant)
                        .foregroundStyle(Color.vitalPrimary)

                    Text(template.name)
                        .font(.vitalDisplayMedium)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    if let description = template.description {
                        Text(description)
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Category badge
                    HStack {
                        Label(template.category.displayName, systemImage: template.category.icon)
                            .font(.vitalCaption)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.vitalPrimary.opacity(0.1))
                            .foregroundStyle(Color.vitalPrimary)
                            .cornerRadius(Spacing.radiusSmall)
                    }
                }
                .padding(Spacing.lg)

                // Stats
                HStack(spacing: Spacing.xl) {
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
                .padding(Spacing.lg)
                .background(Color.vitalAdaptiveSurface)
                .cornerRadius(Spacing.radiusMedium)
                .padding(.horizontal, Spacing.screenPadding)

                // Usage stats
                if template.useCount > 0 {
                    HStack(spacing: Spacing.xl) {
                        VStack(spacing: Spacing.xs) {
                            Text("\(template.useCount)")
                                .font(.vitalH2)
                                .fontWeight(.bold)
                            Text("Times Used")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }

                        if let lastUsed = template.lastUsed {
                            VStack(spacing: Spacing.xs) {
                                Text(lastUsed, style: .relative)
                                    .font(.vitalH3)
                                    .fontWeight(.semibold)
                                Text("Last Used")
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                        }
                    }
                    .padding(Spacing.lg)
                    .background(Color.vitalAdaptiveSurface)
                    .cornerRadius(Spacing.radiusMedium)
                    .padding(.horizontal, Spacing.screenPadding)
                }

                // Exercise list
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Exercises")
                        .font(.vitalH3)
                        .padding(.horizontal, Spacing.screenPadding)

                    ForEach(template.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { exercise in
                        ExerciseDetailRow(exercise: exercise, index: exercise.orderIndex)
                    }
                }
                .padding(.bottom, Spacing.lg)

                // Action buttons
                VStack(spacing: Spacing.md) {
                    Button {
                        onUseTemplate(template)
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Workout")
                        }
                        .font(.vitalH3)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.lg)
                        .background(Color.vitalPrimary)
                        .cornerRadius(Spacing.radiusMedium)
                    }

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Template")
                        }
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalDanger)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.lg)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                    }
                }
                .padding(Spacing.screenPadding)
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
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.vitalH3)
                .foregroundStyle(Color.vitalPrimary)

            Text(value)
                .font(.vitalH2)
                .fontWeight(.bold)

            Text(label)
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
    }
}

struct ExerciseDetailRow: View {
    let exercise: TemplateExercise
    let index: Int

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.lg) {
            // Order number
            Text("\(index + 1)")
                .font(.vitalH2)
                .fontWeight(.bold)
                .foregroundStyle(Color.vitalPrimary)
                .frame(width: 40, height: 40)
                .background(Color.vitalPrimary.opacity(0.1))
                .clipShape(Circle())

            // Exercise details
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(exercise.exerciseName)
                    .font(.vitalH4)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Image(systemName: "number")
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            .frame(width: 20)
                        Text("\(exercise.sets) sets × \(exercise.repsDisplay) reps")
                    }
                    .font(.vitalBody)

                    HStack {
                        Image(systemName: "timer")
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            .frame(width: 20)
                        Text("Rest: \(exercise.restDisplay)")
                    }
                    .font(.vitalBody)
                }

                if let notes = exercise.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .padding(.top, Spacing.xs)
                }
            }

            Spacer()
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
        .padding(.horizontal, Spacing.screenPadding)
    }
}

#Preview {
    NavigationStack {
        TemplateDetailView(
            template: WorkoutTemplate(
                name: "Push Day",
                description: "Chest, shoulders, and triceps focus",
                exercises: [
                    TemplateExercise(exerciseId: UUID(), exerciseName: "Barbell Bench Press", orderIndex: 0, sets: 4, repsMin: 8, repsMax: 12, restSeconds: 90),
                    TemplateExercise(exerciseId: UUID(), exerciseName: "Incline Dumbbell Press", orderIndex: 1, sets: 3, repsMin: 10, repsMax: 15, restSeconds: 60),
                    TemplateExercise(exerciseId: UUID(), exerciseName: "Cable Fly", orderIndex: 2, sets: 3, repsMin: 12, repsMax: 15, restSeconds: 60)
                ],
                category: .pushPullLegs,
                estimatedDuration: 60
            ),
            onUseTemplate: { _ in },
            onDeleteTemplate: { _ in }
        )
    }
}
