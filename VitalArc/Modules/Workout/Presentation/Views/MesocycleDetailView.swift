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
            .padding(Spacing.lg)

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
            .background(Color.vitalAdaptiveBackground)
        }
        .navigationTitle(mesocycle.name)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadProgressSummary(for: mesocycle.id)
        }
    }

    // MARK: - Overview Tab

    private var overviewContent: some View {
        VStack(spacing: Spacing.lg) {
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
        .padding(Spacing.lg)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("Status", systemImage: "info.circle")
                .font(.vitalH3)

            HStack {
                Text(mesocycle.status.rawValue)
                    .font(.vitalH2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(mesocycle.status.color))

                Spacer()

                if mesocycle.status == .active {
                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        Text("Week \(mesocycle.currentWeek ?? 0)")
                            .font(.vitalH3)
                        Text("of \(mesocycle.durationWeeks)")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }
            }

            if mesocycle.status == .active {
                ProgressView(value: mesocycle.progressPercentage / 100)
                    .tint(Color.vitalPrimary)

                Text("\(Int(mesocycle.progressPercentage))% Complete")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("Training Goal", systemImage: mesocycle.goal.icon)
                .font(.vitalH3)

            HStack(spacing: Spacing.md) {
                Image(systemName: mesocycle.goal.icon)
                    .font(.vitalIconXLarge)
                    .foregroundStyle(Color.vitalPrimary)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(mesocycle.goal.rawValue)
                        .font(.vitalH3)
                        .fontWeight(.semibold)

                    Text(mesocycle.goal.description)
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }

    private var timelineCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("Timeline", systemImage: "calendar")
                .font(.vitalH3)

            VStack(spacing: Spacing.sm) {
                HStack {
                    Text("Start")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    Spacer()
                    Text(formatDate(mesocycle.startDate))
                        .font(.vitalBody)
                        .fontWeight(.medium)
                }

                Divider()

                HStack {
                    Text("End")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    Spacer()
                    Text(formatDate(mesocycle.endDate))
                        .font(.vitalBody)
                        .fontWeight(.medium)
                }

                Divider()

                HStack {
                    Text("Duration")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    Spacer()
                    Text("\(mesocycle.durationWeeks) weeks")
                        .font(.vitalBody)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }

    private var phaseTimelineCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("Phase Timeline", systemImage: "chart.line.uptrend.xyaxis")
                .font(.vitalH3)

            if mesocycle.phases.isEmpty {
                Text("No phases defined")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(phaseGroups, id: \.phaseType) { group in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: group.phaseType.icon)
                                .foregroundStyle(Color(group.phaseType.color))
                                .frame(width: Spacing.iconLarge)

                            Text(group.phaseType.rawValue)
                                .font(.vitalBody)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("Weeks \(formatWeekRange(group.weeks))")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                        .padding(.vertical, Spacing.xs)

                        if group.phaseType != phaseGroups.last?.phaseType {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }

    private var quickStatsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("Quick Stats", systemImage: "chart.bar")
                .font(.vitalH3)

            if let summary = viewModel.progressSummary {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Spacing.lg) {
                    StatItem(title: "Total Sets", value: "\(summary.totalSets)")
                    StatItem(title: "Completed", value: "\(summary.completedSets)")
                    StatItem(title: "Total Volume", value: String(format: "%.0f lbs", summary.totalVolume))
                    if let avgRIR = summary.averageRIR {
                        StatItem(title: "Avg RIR", value: String(format: "%.1f", avgRIR))
                    }
                }
            } else {
                Text("No workout data yet")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }

    // MARK: - Schedule Tab

    private var scheduleContent: some View {
        VStack(spacing: Spacing.lg) {
            if mesocycle.trainingBlocks.isEmpty {
                emptyScheduleView
            } else {
                ForEach(sortedTrainingBlocks) { block in
                    TrainingBlockCard(block: block)
                }
            }
        }
        .padding(Spacing.lg)
    }

    private var emptyScheduleView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "calendar.badge.plus")
                .font(.vitalIconGiant)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Text("No Training Schedule")
                .font(.vitalH2)
                .fontWeight(.semibold)

            Text("Add training blocks to define your weekly workout schedule")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
    }

    private var sortedTrainingBlocks: [TrainingBlock] {
        mesocycle.trainingBlocks.sorted { $0.dayOfWeek < $1.dayOfWeek }
    }

    // MARK: - Progress Tab

    private var progressContent: some View {
        VStack(spacing: Spacing.lg) {
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
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    .padding(Spacing.lg)
            }
        }
        .padding(Spacing.lg)
    }

    private func weekProgressCard(summary: MesocycleProgressSummary) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("Week Progress", systemImage: "calendar.badge.clock")
                .font(.vitalH3)

            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Week \(summary.currentWeek)")
                        .font(.vitalH1)
                        .fontWeight(.bold)

                    if let phase = summary.currentPhase {
                        Label(phase.phaseType.rawValue, systemImage: phase.phaseType.icon)
                            .font(.vitalCaption)
                            .foregroundStyle(Color(phase.phaseType.color))
                    }
                }

                Spacer()

                CircularProgressView(progress: summary.progressPercentage / 100)
                    .frame(width: Spacing.illustrationSmall, height: Spacing.illustrationSmall)
            }
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }

    private func volumeChartCard(summary: MesocycleProgressSummary) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("Volume Trend", systemImage: "chart.bar.fill")
                .font(.vitalH3)

            if summary.weeklyProgress.isEmpty {
                Text("Complete workouts to see volume trends")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            } else {
                Chart(summary.weeklyProgress) { week in
                    BarMark(
                        x: .value("Week", "W\(week.weekNumber)"),
                        y: .value("Volume", week.totalVolume)
                    )
                    .foregroundStyle(Color.vitalPrimary.gradient)
                    .cornerRadius(Spacing.xs)
                }
                .frame(height: Spacing.chartHeightLarge)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let vol = value.as(Double.self) {
                            AxisValueLabel {
                                Text("\(Int(vol / 1000))k")
                                    .font(.vitalCaptionSmall)
                            }
                        }
                    }
                }

                // Volume summary
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Volume")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        Text("\(Int(summary.totalVolume)) lbs")
                            .font(.vitalH3)
                    }
                    Spacer()
                    if summary.weeklyProgress.count >= 2 {
                        let change = calculateVolumeChange(summary.weeklyProgress)
                        VStack(alignment: .trailing) {
                            Text("Week-over-Week")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            HStack(spacing: Spacing.xxs) {
                                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.vitalCaption)
                                Text("\(abs(Int(change)))%")
                                    .font(.vitalH3)
                            }
                            .foregroundStyle(change >= 0 ? Color.vitalSuccess : Color.vitalDanger)
                        }
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }

    private func rirTrendCard(summary: MesocycleProgressSummary) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("RIR Trend", systemImage: "chart.line.uptrend.xyaxis")
                .font(.vitalH3)

            let weeksWithRIR = summary.weeklyProgress.filter { $0.averageRIR != nil }

            if weeksWithRIR.isEmpty {
                Text("Log RIR values to see trends")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            } else {
                Chart(weeksWithRIR) { week in
                    LineMark(
                        x: .value("Week", "W\(week.weekNumber)"),
                        y: .value("RIR", week.averageRIR ?? 0)
                    )
                    .foregroundStyle(Color.vitalWarning)
                    .symbol(Circle().strokeBorder(lineWidth: 2))

                    PointMark(
                        x: .value("Week", "W\(week.weekNumber)"),
                        y: .value("RIR", week.averageRIR ?? 0)
                    )
                    .foregroundStyle(Color.vitalWarning)
                }
                .frame(height: Spacing.chartHeightCompact)
                .chartYScale(domain: 0...5)
                .chartYAxis {
                    AxisMarks(values: [0, 1, 2, 3, 4, 5])
                }

                HStack {
                    Text("Average RIR:")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    Text(String(format: "%.1f", summary.averageRIR ?? 0))
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalWarning)
                    Text("reps in reserve")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }

    private func exerciseProgressSection(summary: MesocycleProgressSummary) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("Exercise Progress", systemImage: "figure.strengthtraining.traditional")
                .font(.vitalH3)

            ForEach(summary.exerciseProgress.prefix(5)) { exercise in
                exerciseProgressRow(exercise)
            }

            if summary.exerciseProgress.count > 5 {
                Text("+ \(summary.exerciseProgress.count - 5) more exercises")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }

    private func exerciseProgressRow(_ exercise: ExerciseWeeklyProgress) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(exercise.exerciseName)
                .font(.vitalBody)
                .fontWeight(.medium)

            if exercise.weeklyData.count >= 2 {
                // Show progression chart
                Chart(exercise.weeklyData) { data in
                    LineMark(
                        x: .value("Week", "W\(data.weekNumber)"),
                        y: .value("Weight", data.maxWeight)
                    )
                    .foregroundStyle(Color.vitalPrimary)

                    PointMark(
                        x: .value("Week", "W\(data.weekNumber)"),
                        y: .value("Weight", data.maxWeight)
                    )
                    .foregroundStyle(Color.vitalPrimary)
                    .annotation(position: .top) {
                        Text("\(Int(data.maxWeight))")
                            .font(.vitalCaptionSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }
                .frame(height: Spacing.iconGiant)
                .chartYAxis(.hidden)

                // Progress indicator
                let firstWeight = exercise.weeklyData.first?.maxWeight ?? 0
                let lastWeight = exercise.weeklyData.last?.maxWeight ?? 0
                let change = firstWeight > 0 ? ((lastWeight - firstWeight) / firstWeight) * 100 : 0

                HStack {
                    Text("Best: \(exercise.weeklyData.last?.bestSet ?? "-")")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    Spacer()
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: change >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .font(.vitalCaption)
                        Text("\(abs(Int(change)))% from start")
                            .font(.vitalCaption)
                    }
                    .foregroundStyle(change >= 0 ? Color.vitalSuccess : Color.vitalDanger)
                }
            } else if let latest = exercise.weeklyData.last {
                Text("Best: \(latest.bestSet)")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
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
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(block.name)
                        .font(.vitalH3)

                    Text(block.dayName)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("\(block.exercises.count)")
                        .font(.vitalH2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.vitalPrimary)

                    Text("exercises")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }

            if !block.exercises.isEmpty {
                Divider()

                VStack(spacing: Spacing.sm) {
                    ForEach(block.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { exercise in
                        HStack {
                            Text("\(exercise.orderIndex + 1).")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                .frame(width: Spacing.iconLarge)

                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text(exercise.prescription)
                                    .font(.vitalBody)

                                if let notes = exercise.notes {
                                    Text(notes)
                                        .font(.vitalCaption)
                                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                }
                            }

                            Spacer()

                            Label(exercise.progressionScheme.rawValue, systemImage: exercise.progressionScheme.icon)
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                    }
                }
            }

            Divider()

            HStack {
                Label("\(block.totalSets) sets", systemImage: "number")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                Spacer()

                Label("\(block.estimatedDuration) min", systemImage: "clock")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }
}

private struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.vitalH2)
                .fontWeight(.bold)
                .foregroundStyle(Color.vitalPrimary)

            Text(title)
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.vitalAdaptiveTextSecondary.opacity(0.2), lineWidth: 8)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.vitalPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            Text("\(Int(progress * 100))%")
                .font(.vitalH3)
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
