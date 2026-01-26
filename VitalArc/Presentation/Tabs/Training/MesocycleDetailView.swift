//
//  MesocycleDetailView.swift
//  VitalArc
//
//  Detail view for a mesocycle
//

import SwiftUI
import Charts

struct MesocycleDetailView: View {
    let mesocycle: Mesocycle
    let viewModel: MesocycleViewModel

    @State private var selectedTab: DetailTab = .overview

    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case schedule = "Schedule"
        case progress = "Progress"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("View", selection: $selectedTab) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Content
            ScrollView {
                switch selectedTab {
                case .overview:
                    overviewContent
                case .schedule:
                    scheduleContent
                case .progress:
                    progressContent
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle(mesocycle.name)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadProgressSummary(for: mesocycle.id)
        }
    }

    // MARK: - Overview Tab

    private var overviewContent: some View {
        VStack(spacing: 16) {
            // Status Card
            statusCard

            // Goal Card
            goalCard

            // Timeline Card
            timelineCard

            // Phase Timeline
            phaseTimelineCard

            // Quick Stats
            quickStatsCard
        }
        .padding()
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Status", systemImage: "info.circle")
                .font(.headline)

            HStack {
                Text(mesocycle.status.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(mesocycle.status.color))

                Spacer()

                if mesocycle.status == .active {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Week \(mesocycle.currentWeek ?? 0)")
                            .font(.headline)
                        Text("of \(mesocycle.durationWeeks)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if mesocycle.status == .active {
                ProgressView(value: mesocycle.progressPercentage / 100)
                    .tint(.blue)

                Text("\(Int(mesocycle.progressPercentage))% Complete")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Training Goal", systemImage: mesocycle.goal.icon)
                .font(.headline)

            HStack(spacing: 12) {
                Image(systemName: mesocycle.goal.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(mesocycle.goal.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(mesocycle.goal.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var timelineCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Timeline", systemImage: "calendar")
                .font(.headline)

            VStack(spacing: 8) {
                HStack {
                    Text("Start")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(formatDate(mesocycle.startDate))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Divider()

                HStack {
                    Text("End")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(formatDate(mesocycle.endDate))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Divider()

                HStack {
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(mesocycle.durationWeeks) weeks")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var phaseTimelineCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Phase Timeline", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)

            if mesocycle.phases.isEmpty {
                Text("No phases defined")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(phaseGroups, id: \.phaseType) { group in
                        HStack(spacing: 8) {
                            Image(systemName: group.phaseType.icon)
                                .foregroundStyle(Color(group.phaseType.color))
                                .frame(width: 24)

                            Text(group.phaseType.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("Weeks \(formatWeekRange(group.weeks))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)

                        if group.phaseType != phaseGroups.last?.phaseType {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var quickStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Quick Stats", systemImage: "chart.bar")
                .font(.headline)

            if let summary = viewModel.progressSummary {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatItem(title: "Total Sets", value: "\(summary.totalSets)")
                    StatItem(title: "Completed", value: "\(summary.completedSets)")
                    StatItem(title: "Total Volume", value: String(format: "%.0f lbs", summary.totalVolume))
                    if let avgRIR = summary.averageRIR {
                        StatItem(title: "Avg RIR", value: String(format: "%.1f", avgRIR))
                    }
                }
            } else {
                Text("No workout data yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Schedule Tab

    private var scheduleContent: some View {
        VStack(spacing: 16) {
            if mesocycle.trainingBlocks.isEmpty {
                emptyScheduleView
            } else {
                ForEach(sortedTrainingBlocks) { block in
                    TrainingBlockCard(block: block)
                }
            }
        }
        .padding()
    }

    private var emptyScheduleView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Training Schedule")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add training blocks to define your weekly workout schedule")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    private var sortedTrainingBlocks: [TrainingBlock] {
        mesocycle.trainingBlocks.sorted { $0.dayOfWeek < $1.dayOfWeek }
    }

    // MARK: - Progress Tab

    private var progressContent: some View {
        VStack(spacing: 16) {
            if let summary = viewModel.progressSummary {
                // Week Progress Card
                weekProgressCard(summary: summary)

                // Volume Chart (week-by-week)
                volumeChartCard(summary: summary)

                // RIR Trend Chart
                if summary.averageRIR != nil {
                    rirTrendCard(summary: summary)
                }

                // Exercise Progress (per-exercise tracking)
                if !summary.exerciseProgress.isEmpty {
                    exerciseProgressSection(summary: summary)
                }
            } else {
                Text("No progress data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .padding()
    }

    private func weekProgressCard(summary: MesocycleProgressSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Week Progress", systemImage: "calendar.badge.clock")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Week \(summary.currentWeek)")
                        .font(.title)
                        .fontWeight(.bold)

                    if let phase = summary.currentPhase {
                        Label(phase.phaseType.rawValue, systemImage: phase.phaseType.icon)
                            .font(.caption)
                            .foregroundStyle(Color(phase.phaseType.color))
                    }
                }

                Spacer()

                CircularProgressView(progress: summary.progressPercentage / 100)
                    .frame(width: 80, height: 80)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func volumeChartCard(summary: MesocycleProgressSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Volume Trend", systemImage: "chart.bar.fill")
                .font(.headline)

            if summary.weeklyProgress.isEmpty {
                Text("Complete workouts to see volume trends")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Chart(summary.weeklyProgress) { week in
                    BarMark(
                        x: .value("Week", "W\(week.weekNumber)"),
                        y: .value("Volume", week.totalVolume)
                    )
                    .foregroundStyle(.blue.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let vol = value.as(Double.self) {
                            AxisValueLabel {
                                Text("\(Int(vol / 1000))k")
                                    .font(.caption2)
                            }
                        }
                    }
                }

                // Volume summary
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Volume")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(Int(summary.totalVolume)) lbs")
                            .font(.headline)
                    }
                    Spacer()
                    if summary.weeklyProgress.count >= 2 {
                        let change = calculateVolumeChange(summary.weeklyProgress)
                        VStack(alignment: .trailing) {
                            Text("Week-over-Week")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 2) {
                                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.caption)
                                Text("\(abs(Int(change)))%")
                                    .font(.headline)
                            }
                            .foregroundStyle(change >= 0 ? .green : .red)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func rirTrendCard(summary: MesocycleProgressSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("RIR Trend", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)

            let weeksWithRIR = summary.weeklyProgress.filter { $0.averageRIR != nil }

            if weeksWithRIR.isEmpty {
                Text("Log RIR values to see trends")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Chart(weeksWithRIR) { week in
                    LineMark(
                        x: .value("Week", "W\(week.weekNumber)"),
                        y: .value("RIR", week.averageRIR ?? 0)
                    )
                    .foregroundStyle(.orange)
                    .symbol(Circle().strokeBorder(lineWidth: 2))

                    PointMark(
                        x: .value("Week", "W\(week.weekNumber)"),
                        y: .value("RIR", week.averageRIR ?? 0)
                    )
                    .foregroundStyle(.orange)
                }
                .frame(height: 120)
                .chartYScale(domain: 0...5)
                .chartYAxis {
                    AxisMarks(values: [0, 1, 2, 3, 4, 5])
                }

                HStack {
                    Text("Average RIR:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", summary.averageRIR ?? 0))
                        .font(.headline)
                        .foregroundStyle(.orange)
                    Text("reps in reserve")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func exerciseProgressSection(summary: MesocycleProgressSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Exercise Progress", systemImage: "figure.strengthtraining.traditional")
                .font(.headline)

            ForEach(summary.exerciseProgress.prefix(5)) { exercise in
                exerciseProgressRow(exercise)
            }

            if summary.exerciseProgress.count > 5 {
                Text("+ \(summary.exerciseProgress.count - 5) more exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func exerciseProgressRow(_ exercise: ExerciseWeeklyProgress) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.exerciseName)
                .font(.subheadline)
                .fontWeight(.medium)

            if exercise.weeklyData.count >= 2 {
                // Show progression chart
                Chart(exercise.weeklyData) { data in
                    LineMark(
                        x: .value("Week", "W\(data.weekNumber)"),
                        y: .value("Weight", data.maxWeight)
                    )
                    .foregroundStyle(.blue)

                    PointMark(
                        x: .value("Week", "W\(data.weekNumber)"),
                        y: .value("Weight", data.maxWeight)
                    )
                    .foregroundStyle(.blue)
                    .annotation(position: .top) {
                        Text("\(Int(data.maxWeight))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 60)
                .chartYAxis(.hidden)

                // Progress indicator
                let firstWeight = exercise.weeklyData.first?.maxWeight ?? 0
                let lastWeight = exercise.weeklyData.last?.maxWeight ?? 0
                let change = firstWeight > 0 ? ((lastWeight - firstWeight) / firstWeight) * 100 : 0

                HStack {
                    Text("Best: \(exercise.weeklyData.last?.bestSet ?? "-")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 2) {
                        Image(systemName: change >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .font(.caption)
                        Text("\(abs(Int(change)))% from start")
                            .font(.caption)
                    }
                    .foregroundStyle(change >= 0 ? .green : .red)
                }
            } else if let latest = exercise.weeklyData.last {
                Text("Best: \(latest.bestSet)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()
        }
    }

    private func calculateVolumeChange(_ weeks: [WeeklyProgress]) -> Double {
        guard weeks.count >= 2 else { return 0 }
        let lastWeek = weeks[weeks.count - 1].totalVolume
        let prevWeek = weeks[weeks.count - 2].totalVolume
        guard prevWeek > 0 else { return 0 }
        return ((lastWeek - prevWeek) / prevWeek) * 100
    }

    // MARK: - Helper Views

    private var phaseGroups: [(phaseType: PhaseType, weeks: [Int])] {
        var groups: [(PhaseType, [Int])] = []
        var currentPhase: PhaseType?
        var currentWeeks: [Int] = []

        for phase in mesocycle.phases.sorted(by: { $0.weekNumber < $1.weekNumber }) {
            if phase.phaseType != currentPhase {
                if let current = currentPhase {
                    groups.append((current, currentWeeks))
                }
                currentPhase = phase.phaseType
                currentWeeks = [phase.weekNumber]
            } else {
                currentWeeks.append(phase.weekNumber)
            }
        }

        if let current = currentPhase {
            groups.append((current, currentWeeks))
        }

        return groups
    }

    private func formatWeekRange(_ weeks: [Int]) -> String {
        guard let first = weeks.first, let last = weeks.last else { return "" }
        return first == last ? "\(first)" : "\(first)-\(last)"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TrainingBlockCard: View {
    let block: TrainingBlock

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(block.name)
                        .font(.headline)

                    Text(block.dayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(block.exercises.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)

                    Text("exercises")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !block.exercises.isEmpty {
                Divider()

                VStack(spacing: 8) {
                    ForEach(block.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { exercise in
                        HStack {
                            Text("\(exercise.orderIndex + 1).")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.prescription)
                                    .font(.subheadline)

                                if let notes = exercise.notes {
                                    Text(notes)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Label(exercise.progressionScheme.rawValue, systemImage: exercise.progressionScheme.icon)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Divider()

            HStack {
                Label("\(block.totalSets) sets", systemImage: "number")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Label("\(block.estimatedDuration) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

private struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.blue)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            Text("\(Int(progress * 100))%")
                .font(.headline)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    NavigationStack {
        MesocycleDetailView(
            mesocycle: Mesocycle(
                name: "Hypertrophy Block 1",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .weekOfYear, value: 8, to: Date())!,
                goal: .hypertrophy,
                status: .active
            ),
            viewModel: MesocycleViewModel(
                mesocycleRepository: PreviewMesocycleRepository(),
                workoutRepository: PreviewWorkoutRepository()
            )
        )
    }
}
