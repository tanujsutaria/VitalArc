//
//  WorkoutDetailView.swift
//  VitalArc
//
//  Detailed view for a completed workout
//

import SwiftUI

struct WorkoutDetailView: View {
    @State private var viewModel: WorkoutDetailViewModel

    init(workout: Workout, repository: WorkoutRepository) {
        self.viewModel = WorkoutDetailViewModel(
            workout: workout,
            repository: repository
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Header
                headerSection

                // Stats Row
                statsRow

                // Notes
                if let notes = viewModel.notes, !notes.isEmpty {
                    notesCard(notes)
                }

                // Exercise Breakdown
                exerciseBreakdown
            }
            .padding(Spacing.screenPadding)
        }
        .background(Color.vitalAdaptiveBackground)
        .navigationTitle(viewModel.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: viewModel.shareText()) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .task {
            await viewModel.loadExerciseDetails()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(viewModel.name)
                    .font(.vitalH2)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Text(formatDate(viewModel.date))
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: Spacing.md) {
            statItem(
                title: "Sets",
                value: "\(viewModel.totalSets)",
                icon: "list.bullet"
            )

            statItem(
                title: "Volume",
                value: String(format: "%.0f lbs", UnitConversion.kgToLbs(viewModel.totalVolume)),
                icon: "scalemass"
            )

            if let duration = viewModel.duration {
                statItem(
                    title: "Duration",
                    value: formatDuration(duration),
                    icon: "timer"
                )
            }
        }
    }

    private func statItem(title: String, value: String, icon: String) -> some View {
        VitalCard {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalPrimary)

                Text(value)
                    .font(.vitalH3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Text(title)
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Notes Card

    private func notesCard(_ notes: String) -> some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Label("Notes", systemImage: "note.text")
                    .font(.vitalLabel)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Text(notes)
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Exercise Breakdown

    private var exerciseBreakdown: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Exercises")
                .font(.vitalH3)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.xl)
            } else {
                ForEach(viewModel.orderedExerciseIds, id: \.self) { exerciseId in
                    exerciseCard(exerciseId: exerciseId)
                }
            }
        }
    }

    private func exerciseCard(exerciseId: UUID) -> some View {
        let sets = viewModel.sets(for: exerciseId)

        return VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Exercise name header
                HStack {
                    Text(viewModel.exerciseName(for: exerciseId))
                        .font(.vitalH4)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Spacer()

                    Text("\(sets.count) sets")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                // Set table header
                HStack {
                    Text("Set")
                        .frame(width: Spacing.xl, alignment: .leading)
                    Text("Weight")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text("Reps")
                        .frame(width: Spacing.xxl, alignment: .trailing)
                    Text("RIR")
                        .frame(width: 36, alignment: .trailing)
                    Text("Volume")
                        .frame(width: 72, alignment: .trailing)
                }
                .font(.vitalCaption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                // Set rows
                ForEach(sets) { workoutSet in
                    setRow(workoutSet)
                }

                Divider()

                // Per-exercise totals
                HStack {
                    Text("Total")
                        .font(.vitalLabel)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Spacer()

                    Text(String(format: "%.0f lbs", UnitConversion.kgToLbs(viewModel.exerciseVolume(for: exerciseId))))
                        .font(.vitalLabel)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.vitalPrimary)
                }
            }
        }
    }

    private func setRow(_ workoutSet: WorkoutSet) -> some View {
        let isBest = viewModel.bestSet(for: workoutSet.exerciseId)?.id == workoutSet.id

        return VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text("\(workoutSet.setNumber)")
                    .frame(width: Spacing.xl, alignment: .leading)
                Text(String(format: "%.1f lbs", UnitConversion.kgToLbs(workoutSet.weight)))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text("\(workoutSet.reps)")
                    .frame(width: Spacing.xxl, alignment: .trailing)
                Text(workoutSet.rir.map { "\($0)" } ?? "-")
                    .frame(width: 36, alignment: .trailing)
                Text(String(format: "%.0f", workoutSet.volume))
                    .frame(width: 72, alignment: .trailing)
            }
            .font(.vitalBody)
            .foregroundStyle(isBest ? Color.vitalPrimary : Color.vitalAdaptiveTextPrimary)

            if let notes = workoutSet.notes, !notes.isEmpty {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "note.text")
                        .font(.vitalCaptionSmall)
                    Text(notes)
                        .font(.vitalCaption)
                }
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .padding(.leading, Spacing.xl)
            }
        }
    }

    // MARK: - Formatters

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(
            workout: Workout(
                name: "Push Day",
                sets: [
                    WorkoutSet(exerciseId: UUID(), weight: 80, reps: 10, rir: 2, setNumber: 1),
                    WorkoutSet(exerciseId: UUID(), weight: 85, reps: 8, rir: 1, setNumber: 2),
                    WorkoutSet(exerciseId: UUID(), weight: 90, reps: 6, rir: 0, setNumber: 3)
                ],
                notes: "Felt strong today. Good session overall.",
                duration: 3600
            ),
            repository: PreviewWorkoutRepository()
        )
    }
}
