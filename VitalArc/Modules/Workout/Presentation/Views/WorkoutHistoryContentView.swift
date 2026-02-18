//
//  WorkoutHistoryContentView.swift
//  VitalArc
//
//  Embeddable workout history content with analytics heatmap and volume chart
//

import SwiftUI

struct WorkoutHistoryContentView: View {
    let container: DependencyContainer
    @State private var viewModel: WorkoutHistoryViewModel?
    @State private var trainingDays: [Date: Int] = [:]
    @State private var muscleVolume: [MuscleVolumeData] = []
    @State private var isLoadingAnalytics = true

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Training Heatmap
                if !trainingDays.isEmpty {
                    TrainingHeatmapView(
                        trainingDays: trainingDays,
                        weeks: 12,
                        title: "Training Activity"
                    )
                    .transition(.vitalSlideUp)
                }

                // Volume by Muscle Group (if we have data)
                if !muscleVolume.isEmpty {
                    MuscleVolumeChartView(
                        weeklyData: muscleVolume,
                        monthlyData: muscleVolume
                    )
                    .transition(.vitalSlideUp)
                }

                // Loading indicator
                if isLoadingAnalytics && trainingDays.isEmpty {
                    VitalCard {
                        VStack(spacing: Spacing.md) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading analytics...")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.xl)
                    }
                }

                // Recent Workouts
                if let viewModel = viewModel {
                    recentWorkoutsSection(viewModel: viewModel)
                }
            }
            .padding(Spacing.screenPadding)
        }
        .background(Color.vitalAdaptiveBackground)
        .task {
            await loadData()
        }
    }

    // MARK: - Recent Workouts Section

    @ViewBuilder
    private func recentWorkoutsSection(viewModel: WorkoutHistoryViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Recent Workouts")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Spacer()

                if viewModel.workouts.count > 5 {
                    NavigationLink {
                        WorkoutHistoryView(repository: container.workoutRepository, importUseCase: container.importHealthKitWorkoutsUseCase)
                    } label: {
                        Text("See All")
                            .font(.vitalLabelSmall)
                            .foregroundStyle(Color.vitalPrimary)
                    }
                }
            }

            if viewModel.isLoading {
                VStack(spacing: Spacing.md) {
                    ProgressView()
                    Text("Loading workouts...")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.xl)
            } else if viewModel.workouts.isEmpty {
                VitalCard {
                    VStack(spacing: Spacing.lg) {
                        ZStack {
                            Circle()
                                .fill(Color.vitalInfo.opacity(0.15))
                                .frame(width: Spacing.illustrationSmall, height: Spacing.illustrationSmall)

                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.vitalIcon2XLarge)
                                .foregroundStyle(Color.vitalInfo)
                        }

                        VStack(spacing: Spacing.sm) {
                            Text("No Workouts Yet")
                                .font(.vitalH3)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                            Text("Start logging workouts to see your history and analytics here.")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(Spacing.lg)
                }
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(viewModel.workouts.prefix(5)) { workout in
                        NavigationLink {
                            WorkoutDetailView(
                                workout: workout,
                                repository: container.workoutRepository
                            )
                        } label: {
                            workoutCard(workout)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .transition(.vitalSlideUp)
    }

    private func workoutCard(_ workout: Workout) -> some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text(workout.name ?? "Workout")
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Spacer()

                    Text(formatWorkoutDate(workout.date))
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                HStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "list.bullet")
                            .font(.vitalCaptionSmall)
                        Text("\(workout.totalSets) sets")
                            .font(.vitalCaption)
                    }
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "scalemass")
                            .font(.vitalCaptionSmall)
                        Text(String(format: "%.0f kg", workout.totalVolume))
                            .font(.vitalCaption)
                    }
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    if let duration = workout.duration {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "timer")
                                .font(.vitalCaptionSmall)
                            Text(formatDuration(duration))
                                .font(.vitalCaption)
                        }
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Data Loading

    @MainActor
    private func loadData() async {
        // Load workout history
        viewModel = WorkoutHistoryViewModel(repository: container.workoutRepository)
        await viewModel?.loadWorkouts()

        // Build training days for heatmap
        if let workouts = viewModel?.workouts {
            let calendar = Calendar.current
            var days: [Date: Int] = [:]
            for workout in workouts {
                let day = calendar.startOfDay(for: workout.date)
                days[day, default: 0] += 1
            }
            trainingDays = days
        }

        // Build muscle volume from workout sets
        await loadMuscleVolume()

        isLoadingAnalytics = false
    }

    @MainActor
    private func loadMuscleVolume() async {
        guard let workouts = viewModel?.workouts else { return }

        // Aggregate volume by muscle group category
        var volumeByCategory: [String: Double] = [:]

        let muscleColors: [String: Color] = [
            "Push": .vitalDanger,
            "Pull": .vitalInfo,
            "Legs": .vitalSuccess,
            "Core": .vitalWarning,
            "Cardio": .vitalAccent,
            "Other": .vitalSecondary
        ]

        for workout in workouts.prefix(30) { // Last 30 workouts
            for workoutSet in workout.sets {
                // Get exercise info to determine muscle group
                if let exercise = try? await container.workoutRepository.getExercise(id: workoutSet.exerciseId) {
                    let category = exercise.category.rawValue
                    let mappedCategory: String

                    switch exercise.category {
                    case .push:
                        mappedCategory = "Push"
                    case .pull:
                        mappedCategory = "Pull"
                    case .legs:
                        mappedCategory = "Legs"
                    case .core:
                        mappedCategory = "Core"
                    case .cardio:
                        mappedCategory = "Cardio"
                    default:
                        mappedCategory = "Other"
                    }

                    let volume = Double(workoutSet.reps) * workoutSet.weight
                    volumeByCategory[mappedCategory, default: 0] += volume
                }
            }
        }

        // Convert to MuscleVolumeData array
        muscleVolume = volumeByCategory.map { category, volume in
            MuscleVolumeData(
                muscleGroup: category,
                volume: volume,
                color: muscleColors[category] ?? .vitalPrimary
            )
        }.sorted { $0.volume > $1.volume }
    }

    // MARK: - Helpers

    private func formatWorkoutDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

// MARK: - Preview

#Preview {
    Text("WorkoutHistoryContentView Preview")
        .padding()
}
