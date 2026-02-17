//
//  WorkoutHistoryView.swift
//  VitalArc
//
//  View for browsing workout history
//

import SwiftUI

struct WorkoutHistoryView: View {
    @State private var viewModel: WorkoutHistoryViewModel

    init(repository: WorkoutRepository) {
        self.viewModel = WorkoutHistoryViewModel(repository: repository)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Statistics Card
                statisticsCard
                    .padding()

                // Date Range Filter
                dateRangeFilter
                    .padding(.horizontal)

                // Workouts List
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if viewModel.workouts.isEmpty {
                    emptyState
                } else {
                    workoutsList
                }
            }
            .navigationTitle("Workout History")
            .task {
                await viewModel.loadWorkouts()
            }
        }
    }

    // MARK: - Statistics Card

    private var statisticsCard: some View {
        HStack(spacing: Spacing.screenPadding) {
            StatisticView(
                title: "Workouts",
                value: "\(viewModel.totalWorkouts)",
                icon: "figure.strengthtraining.traditional"
            )

            Divider()
                .frame(height: 50)

            StatisticView(
                title: "Total Sets",
                value: "\(viewModel.totalSets)",
                icon: "list.bullet"
            )

            Divider()
                .frame(height: 50)

            StatisticView(
                title: "Volume",
                value: String(format: "%.0f kg", viewModel.totalVolume),
                icon: "scalemass"
            )
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
    }

    // MARK: - Date Range Filter

    private var dateRangeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    Button {
                        Task {
                            await viewModel.selectDateRange(range)
                        }
                    } label: {
                        Text(range.rawValue)
                            .font(.vitalBody)
                            .fontWeight(.medium)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.sm)
                            .background(
                                viewModel.selectedDateRange == range
                                    ? Color.vitalPrimary
                                    : Color.vitalAdaptiveSurface
                            )
                            .foregroundStyle(
                                viewModel.selectedDateRange == range
                                    ? .white
                                    : Color.vitalAdaptiveTextPrimary
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Workouts List

    private var workoutsList: some View {
        List {
            ForEach(groupedWorkouts.keys.sorted(by: >), id: \.self) { date in
                Section {
                    ForEach(groupedWorkouts[date] ?? []) { workout in
                        NavigationLink {
                            WorkoutDetailView(
                                workout: workout,
                                repository: viewModel.repository
                            )
                        } label: {
                            WorkoutRowView(workout: workout)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteWorkout(workout)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text(formatDate(date))
                        .font(.vitalH3)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "No Workouts",
            systemImage: "figure.strengthtraining.traditional",
            description: Text("Start logging workouts to see your history")
        )
    }

    // MARK: - Helpers

    private var groupedWorkouts: [Date: [Workout]] {
        let calendar = Calendar.current
        return Dictionary(grouping: viewModel.workouts) { workout in
            calendar.startOfDay(for: workout.date)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Statistic View

struct StatisticView: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.vitalH2)
                .foregroundStyle(Color.vitalPrimary)

            Text(value)
                .font(.vitalH3)
                .fontWeight(.bold)

            Text(title)
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Workout Row View

struct WorkoutRowView: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(workout.name ?? "Workout")
                    .font(.vitalH3)

                Spacer()

                Text(formatTime(workout.date))
                    .font(.vitalCaption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: Spacing.md) {
                Label("\(workout.totalSets) sets", systemImage: "list.bullet")
                    .font(.vitalCaption)
                    .foregroundStyle(.secondary)

                Label(String(format: "%.0f kg", workout.totalVolume), systemImage: "scalemass")
                    .font(.vitalCaption)
                    .foregroundStyle(.secondary)

                if let duration = workout.duration {
                    Label(formatDuration(duration), systemImage: "timer")
                        .font(.vitalCaption)
                        .foregroundStyle(.secondary)
                }
            }

            if let notes = workout.notes {
                Text(notes)
                    .font(.vitalCaption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}
