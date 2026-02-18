//
//  AnalyticsDashboardView.swift
//  VitalArc
//
//  Premium analytics dashboard rivaling Whoop, Oura, and Athlytic
//

import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @State private var viewModel: AnalyticsDashboardViewModel
    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    @State private var selectedSection: DashboardSection = .overview
    @State private var hasAppeared = false

    enum DashboardSection: String, CaseIterable {
        case overview = "Overview"
        case workout = "Workout"
        case nutrition = "Nutrition"
        case health = "Health"
        case body = "Body"
    }

    init(viewModel: AnalyticsDashboardViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Time range picker
                    timeRangePicker
                        .padding(.horizontal, Spacing.screenPadding)
                        .padding(.top, Spacing.sm)

                    // Section tabs
                    sectionTabs
                        .padding(.top, Spacing.md)

                    // Content
                    LazyVStack(spacing: Spacing.sectionSpacing) {
                        switch selectedSection {
                        case .overview:
                            overviewSection
                        case .workout:
                            workoutSection
                        case .nutrition:
                            nutritionSection
                        case .health:
                            healthSection
                        case .body:
                            bodySection
                        }
                    }
                    .padding(.horizontal, Spacing.screenPadding)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.xxxl)
                }
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color.vitalPrimary)
                    }
                    .accessibilityLabel("Export analytics data")
                }
            }
            .refreshable {
                await viewModel.loadData()
            }
            .task {
                await viewModel.loadData()
                withAnimation(.vitalSpring.delay(0.2)) {
                    hasAppeared = true
                }
            }
            .onChange(of: viewModel.selectedTimeRange) { _, _ in
                Task {
                    await viewModel.loadData()
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportSheet(viewModel: viewModel, exportURL: $exportURL)
            }
            .overlay {
                if viewModel.isLoading && !hasAppeared {
                    loadingOverlay
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    // MARK: - Time Range Picker

    private var timeRangePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(AnalyticsDashboardViewModel.TimeRange.allCases, id: \.self) { range in
                    Button {
                        withAnimation(.vitalSpring) {
                            viewModel.selectedTimeRange = range
                        }
                        HapticFeedback.light()
                    } label: {
                        Text(range.rawValue)
                            .font(.vitalLabelSmall)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(
                                viewModel.selectedTimeRange == range
                                    ? Color.vitalPrimary
                                    : Color.vitalAdaptiveSurface
                            )
                            .foregroundStyle(
                                viewModel.selectedTimeRange == range
                                    ? .white
                                    : Color.vitalAdaptiveTextSecondary
                            )
                            .cornerRadius(Spacing.radiusSmall)
                            .vitalCardShadow()
                    }
                    .vitalScaleButton()
                }
            }
        }
    }

    // MARK: - Section Tabs

    private var sectionTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(DashboardSection.allCases, id: \.self) { section in
                    Button {
                        withAnimation(.vitalSpring) {
                            selectedSection = section
                        }
                        HapticFeedback.selection()
                    } label: {
                        VStack(spacing: Spacing.xs) {
                            Text(section.rawValue)
                                .font(.vitalLabel)
                                .foregroundStyle(
                                    selectedSection == section
                                        ? Color.vitalPrimary
                                        : Color.vitalAdaptiveTextSecondary
                                )

                            Rectangle()
                                .fill(
                                    selectedSection == section
                                        ? Color.vitalPrimary
                                        : Color.clear
                                )
                                .frame(height: Spacing.borderThick)
                                .cornerRadius(Spacing.xxs)
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                }
            }
            .padding(.horizontal, Spacing.screenPadding)
        }
    }

    // MARK: - Overview Section

    private var overviewSection: some View {
        VStack(spacing: Spacing.sectionSpacing) {
            // Score rings row
            scoreRingsSection
                .transition(.vitalScale)

            // Weekly training volume card
            weeklyVolumeCard
                .transition(.vitalSlideUp)

            // Quick stats grid
            quickStatsGrid
                .transition(.vitalSlideUp)

            // Recent personal records
            if !viewModel.personalRecords.isEmpty {
                recentRecordsCard
                    .transition(.vitalSlideUp)
            }
        }
        .animation(.vitalSpring, value: hasAppeared)
    }

    private var scoreRingsSection: some View {
        HStack(spacing: Spacing.md) {
            ScoreRingView(
                score: viewModel.recoveryScore,
                title: "Recovery",
                subtitle: recoveryLabel(viewModel.recoveryScore),
                gradient: Color.vitalSuccessGradient,
                size: 90,
                lineWidth: 8
            )

            ScoreRingView(
                score: min(viewModel.strainScore / 21 * 100, 100),
                title: "Strain",
                subtitle: String(format: "%.1f / 21", viewModel.strainScore),
                gradient: Color.vitalPrimaryGradient,
                size: 90,
                lineWidth: 8
            )

            ScoreRingView(
                score: viewModel.sleepScore,
                title: "Sleep",
                subtitle: sleepLabel(viewModel.sleepScore),
                gradient: Color.vitalAccentGradient,
                size: 90,
                lineWidth: 8
            )
        }
        .padding(.vertical, Spacing.md)
    }

    private var weeklyVolumeCard: some View {
        LargeScoreCard(
            score: min(viewModel.weeklyTrainingVolume / 50000 * 100, 100),
            title: "Weekly Volume",
            subtitle: formatVolume(viewModel.weeklyTrainingVolume),
            icon: "dumbbell.fill",
            gradient: LinearGradient(
                colors: [Color.vitalInfo, Color.vitalInfo.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            trend: volumeTrend,
            trendValue: volumeTrendLabel
        )
    }

    private var quickStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
            if let report = viewModel.currentReport {
                MetricCard(
                    title: "Workout Consistency",
                    value: "\(Int(report.workoutConsistency))",
                    unit: "%",
                    icon: "figure.strengthtraining.traditional",
                    color: .vitalInfo,
                    trend: consistencyTrend(report.workoutConsistency)
                )

                MetricCard(
                    title: "Nutrition Adherence",
                    value: "\(Int(report.avgCalorieAdherence))",
                    unit: "%",
                    icon: "fork.knife",
                    color: .vitalSuccess,
                    trend: adherenceTrend(report.avgCalorieAdherence)
                )

                if let weightChange = report.bodyWeightChange {
                    MetricCard(
                        title: "Weight Change",
                        value: String(format: "%+.1f", weightChange),
                        unit: "kg",
                        icon: "scalemass",
                        color: .vitalWarning,
                        trend: weightChange > 0 ? .up : (weightChange < 0 ? .down : .stable)
                    )
                }

                MetricCard(
                    title: "Volume Change",
                    value: String(format: "%+.1f", report.volumeChange),
                    unit: "%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .vitalAccent,
                    trend: report.volumeChange > 0 ? .up : (report.volumeChange < 0 ? .down : .stable)
                )
            }
        }
    }

    private var recentRecordsCard: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    Text("Recent Personal Records")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    Spacer()
                }

                ForEach(viewModel.personalRecords.prefix(3)) { record in
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text(record.exerciseName)
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            Text(record.recordType.displayName)
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: Spacing.xxs) {
                            Text(record.displayValue)
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalPrimary)
                            Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                    }

                    if record.id != viewModel.personalRecords.prefix(3).last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    // MARK: - Workout Section

    private var workoutSection: some View {
        VStack(spacing: Spacing.sectionSpacing) {
            // Training heatmap
            TrainingHeatmapView(
                trainingDays: viewModel.trainingDays,
                weeks: 12,
                title: "Training Activity"
            )

            // Volume by muscle group
            MuscleVolumeChartView(
                weeklyData: viewModel.weeklyMuscleVolume,
                monthlyData: viewModel.monthlyMuscleVolume
            )

            // Strength progression
            if !viewModel.strengthProgression.isEmpty {
                StrengthProgressionChartView(
                    data: viewModel.strengthProgression,
                    title: "Strength Progression (Est. 1RM)"
                )
            }

            // Volume trend chart
            if !viewModel.volumeMetrics.isEmpty {
                volumeTrendChart
            }
        }
    }

    private var volumeTrendChart: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Weekly Volume Trend")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Chart {
                    ForEach(viewModel.volumeMetrics) { metric in
                        LineMark(
                            x: .value("Week", metric.weekStartDate),
                            y: .value("Volume", metric.totalVolume)
                        )
                        .foregroundStyle(Color.vitalPrimary)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3))

                        AreaMark(
                            x: .value("Week", metric.weekStartDate),
                            y: .value("Volume", metric.totalVolume)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.vitalPrimary.opacity(0.3), Color.vitalPrimary.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        AxisGridLine()
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let volume = value.as(Double.self) {
                                Text(formatVolume(volume))
                                    .font(.vitalCaptionSmall)
                            }
                        }
                        AxisGridLine()
                    }
                }
                .frame(height: Spacing.chartHeightExtraLarge)
            }
        }
    }

    // MARK: - Nutrition Section

    private var nutritionSection: some View {
        VStack(spacing: Spacing.sectionSpacing) {
            // Calorie adherence
            CalorieAdherenceChartView(
                data: viewModel.calorieAdherence,
                weeklyAverage: viewModel.weeklyCalorieAverage,
                targetCalories: viewModel.targetCalories
            )

            // Macro breakdown
            MacroBreakdownChartView(
                data: viewModel.macroBreakdown,
                proteinTarget: viewModel.proteinTarget,
                carbsTarget: viewModel.carbsTarget,
                fatsTarget: viewModel.fatsTarget
            )

            // Protein per body weight
            if !viewModel.proteinTrend.isEmpty {
                ProteinTrendChartView(
                    data: viewModel.proteinTrend,
                    targetPerKg: viewModel.proteinTargetPerKg,
                    currentWeight: viewModel.currentWeight
                )
            }
        }
    }

    // MARK: - Health Section

    private var healthSection: some View {
        VStack(spacing: Spacing.sectionSpacing) {
            // HRV trend
            HRVTrendChartView(
                sevenDayData: viewModel.hrvTrend7Day,
                thirtyDayData: viewModel.hrvTrend30Day,
                baseline: viewModel.hrvBaseline
            )

            // Resting heart rate
            if !viewModel.restingHRTrend.isEmpty {
                RestingHRChartView(data: viewModel.restingHRTrend)
            }

            // Sleep trends
            if !viewModel.sleepTrend.isEmpty {
                SleepTrendChartView(
                    data: viewModel.sleepTrend,
                    targetHours: viewModel.sleepTargetHours
                )
            }
        }
    }

    // MARK: - Body Section

    private var bodySection: some View {
        VStack(spacing: Spacing.sectionSpacing) {
            // Weight trend
            if !viewModel.weightTrend.isEmpty {
                weightTrendChart
            } else {
                emptyBodyMetricsView
            }

            // Progress snapshots
            if !viewModel.progressSnapshots.isEmpty {
                progressSnapshotsCard
            }
        }
    }

    private var weightTrendChart: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "scalemass.fill")
                            .foregroundStyle(Color.vitalSuccess)
                        Text("Weight Trend")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    }

                    Spacer()

                    if let latest = viewModel.weightTrend.last {
                        Text(String(format: "%.1f kg", latest.value))
                            .font(.vitalNumberSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    }
                }

                Chart {
                    ForEach(viewModel.weightTrend) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Weight", point.value)
                        )
                        .foregroundStyle(Color.vitalSuccess)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3))

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("Weight", point.value)
                        )
                        .foregroundStyle(Color.vitalSuccess)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let weight = value.as(Double.self) {
                                Text(String(format: "%.0f", weight))
                                    .font(.vitalCaptionSmall)
                            }
                        }
                    }
                }
                .frame(height: Spacing.chartHeightLarge)

                // Change summary
                if let first = viewModel.weightTrend.first,
                   let last = viewModel.weightTrend.last {
                    let change = last.value - first.value
                    HStack {
                        Text("Total Change:")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        Text(String(format: "%+.1f kg", change))
                            .font(.vitalLabel)
                            .foregroundStyle(change > 0 ? Color.vitalWarning : Color.vitalSuccess)
                    }
                }
            }
        }
    }

    private var progressSnapshotsCard: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Progress Snapshots")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Text("\(viewModel.progressSnapshots.count) snapshots recorded")
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                if let latest = viewModel.progressSnapshots.last {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Latest: \(latest.date.formatted(date: .long, time: .omitted))")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                        if !latest.measurements.isEmpty {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                                ForEach(latest.measurements.prefix(4)) { measurement in
                                    HStack {
                                        Text(measurement.bodyPart.displayName)
                                            .font(.vitalCaptionSmall)
                                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                        Spacer()
                                        Text(String(format: "%.1f cm", measurement.value))
                                            .font(.vitalLabel)
                                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, Spacing.sm)
                }
            }
        }
    }

    private var emptyBodyMetricsView: some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(Color.vitalSuccess.opacity(0.15))
                        .frame(width: Spacing.frameLarge, height: Spacing.frameLarge)

                    Image(systemName: "figure.stand")
                        .font(.vitalIcon2XLarge)
                        .foregroundStyle(Color.vitalSuccess)
                }

                VStack(spacing: Spacing.sm) {
                    Text("No Body Metrics")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Text("Track your weight and measurements to see trends here")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.vitalAdaptiveBackground.opacity(0.9)

            VStack(spacing: Spacing.lg) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color.vitalPrimary)

                Text("Loading analytics...")
                    .font(.vitalBody)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Helper Methods

    private func recoveryLabel(_ score: Double) -> String {
        switch score {
        case 0..<30: return "Poor"
        case 30..<50: return "Fair"
        case 50..<70: return "Good"
        case 70..<85: return "Great"
        default: return "Excellent"
        }
    }

    private func sleepLabel(_ score: Double) -> String {
        switch score {
        case 0..<50: return "Poor"
        case 50..<70: return "Fair"
        case 70..<85: return "Good"
        default: return "Excellent"
        }
    }

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk kg", volume / 1000)
        }
        return String(format: "%.0f kg", volume)
    }

    private var volumeTrend: TrendDirection? {
        guard viewModel.volumeMetrics.count >= 2 else { return nil }
        let recent = viewModel.volumeMetrics.suffix(2)
        guard let first = recent.first, let last = recent.last else { return nil }
        if last.totalVolume > first.totalVolume * 1.05 { return .up }
        if last.totalVolume < first.totalVolume * 0.95 { return .down }
        return .stable
    }

    private var volumeTrendLabel: String? {
        guard viewModel.volumeMetrics.count >= 2 else { return nil }
        let recent = viewModel.volumeMetrics.suffix(2)
        guard let first = recent.first, let last = recent.last, first.totalVolume > 0 else { return nil }
        let change = ((last.totalVolume - first.totalVolume) / first.totalVolume) * 100
        return String(format: "%+.1f%% vs last week", change)
    }

    private func consistencyTrend(_ value: Double) -> TrendDirection {
        if value >= 80 { return .up }
        if value >= 60 { return .stable }
        return .down
    }

    private func adherenceTrend(_ value: Double) -> TrendDirection {
        if value >= 90 { return .up }
        if value >= 70 { return .stable }
        return .down
    }
}

// MARK: - Export Sheet

struct ExportSheet: View {
    let viewModel: AnalyticsDashboardViewModel
    @Binding var exportURL: URL?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Export Formats") {
                    Button {
                        Task {
                            exportURL = await viewModel.exportProgressReportPDF()
                            if exportURL != nil {
                                dismiss()
                            }
                        }
                    } label: {
                        Label("Progress Report (PDF)", systemImage: "doc.richtext")
                    }

                    Button {
                        Task {
                            exportURL = await viewModel.exportVolumeMetricsCSV()
                            if exportURL != nil {
                                dismiss()
                            }
                        }
                    } label: {
                        Label("Volume Metrics (CSV)", systemImage: "tablecells")
                    }
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    // Create a mock preview
    PreviewAnalyticsDashboard()
}

private struct PreviewAnalyticsDashboard: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Score rings
                HStack(spacing: Spacing.md) {
                    ScoreRingView(
                        score: 85,
                        title: "Recovery",
                        subtitle: "Excellent",
                        gradient: Color.vitalSuccessGradient,
                        size: 90,
                        lineWidth: 8
                    )

                    ScoreRingView(
                        score: 68,
                        title: "Strain",
                        subtitle: "14.3 / 21",
                        gradient: Color.vitalPrimaryGradient,
                        size: 90,
                        lineWidth: 8
                    )

                    ScoreRingView(
                        score: 78,
                        title: "Sleep",
                        subtitle: "Good",
                        gradient: Color.vitalAccentGradient,
                        size: 90,
                        lineWidth: 8
                    )
                }

                LargeScoreCard(
                    score: 75,
                    title: "Weekly Volume",
                    subtitle: "42.5k kg",
                    icon: "dumbbell.fill",
                    gradient: LinearGradient(
                        colors: [Color.vitalInfo, Color.vitalInfo.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    trend: .up,
                    trendValue: "+8.2% vs last week"
                )

                TrainingHeatmapView(
                    trainingDays: generatePreviewTrainingData(),
                    weeks: 12
                )

                MuscleVolumeChartView(
                    weeklyData: generatePreviewMuscleData(),
                    monthlyData: generatePreviewMuscleData().map { data in
                        MuscleVolumeData(muscleGroup: data.muscleGroup, volume: data.volume * 4, color: data.color)
                    }
                )
            }
            .padding()
        }
        .background(Color.vitalAdaptiveBackground)
    }
}

private func generatePreviewTrainingData() -> [Date: Int] {
    var data: [Date: Int] = [:]
    let calendar = Calendar.current

    for daysAgo in 0..<84 {
        if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
            let startOfDay = calendar.startOfDay(for: date)
            if Int.random(in: 0..<10) > 3 {
                data[startOfDay] = Int.random(in: 1...4)
            }
        }
    }

    return data
}

private func generatePreviewMuscleData() -> [MuscleVolumeData] {
    [
        MuscleVolumeData(muscleGroup: "Legs", volume: 15000, color: .vitalSuccess),
        MuscleVolumeData(muscleGroup: "Back", volume: 12000, color: .vitalInfo),
        MuscleVolumeData(muscleGroup: "Chest", volume: 8500, color: .vitalDanger),
        MuscleVolumeData(muscleGroup: "Arms", volume: 6000, color: .vitalAccent),
        MuscleVolumeData(muscleGroup: "Shoulders", volume: 4500, color: .vitalWarning),
        MuscleVolumeData(muscleGroup: "Core", volume: 2000, color: .vitalSecondary)
    ]
}
