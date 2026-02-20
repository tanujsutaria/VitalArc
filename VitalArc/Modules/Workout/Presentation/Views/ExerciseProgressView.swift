//
//  ExerciseProgressView.swift
//  VitalArc
//
//  Per-exercise progressive overload chart showing weight/volume progression
//

import SwiftUI
import Charts

struct ExerciseProgressView: View {
    let exercise: Exercise
    let getExerciseHistoryUseCase: GetExerciseHistoryUseCase

    @State private var historyPoints: [ExerciseHistoryPoint] = []
    @State private var isLoading = true
    @State private var selectedMetric: ProgressMetric = .maxWeight
    @State private var selectedTimeRange: TimeRange = .all

    enum ProgressMetric: String, CaseIterable {
        case maxWeight = "Max Weight"
        case totalVolume = "Volume"
        case estimated1RM = "Est. 1RM"
    }

    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case month = "30D"
        case threeMonths = "90D"
        case all = "All"

        var cutoffDate: Date? {
            let calendar = Calendar.current
            switch self {
            case .week: return calendar.date(byAdding: .day, value: -7, to: Date())
            case .month: return calendar.date(byAdding: .day, value: -30, to: Date())
            case .threeMonths: return calendar.date(byAdding: .day, value: -90, to: Date())
            case .all: return nil
            }
        }
    }

    private var filteredPoints: [ExerciseHistoryPoint] {
        guard let cutoff = selectedTimeRange.cutoffDate else {
            return historyPoints
        }
        return historyPoints.filter { $0.date >= cutoff }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: Spacing.chartHeightLarge)
                } else if historyPoints.isEmpty {
                    emptyState
                } else {
                    timeRangePicker
                    metricPicker
                    chartView
                    statsSection
                }
            }
            .padding(.horizontal, Spacing.screenPadding)
            .padding(.vertical, Spacing.md)
        }
        .background(Color.vitalAdaptiveBackground)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadHistory()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.vitalIconHero)
                .foregroundStyle(Color.vitalAdaptiveTextTertiary)

            Text("No History Yet")
                .font(.vitalH2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            Text("Complete workouts with this exercise to see your progression chart.")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }

    // MARK: - Time Range Picker

    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Metric Picker

    private var metricPicker: some View {
        Picker("Metric", selection: $selectedMetric) {
            ForEach(ProgressMetric.allCases, id: \.self) { metric in
                Text(metric.rawValue).tag(metric)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Chart

    private var chartView: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(selectedMetric.rawValue)
                    .font(.vitalLabel)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                Chart(filteredPoints) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value(selectedMetric.rawValue, valueForMetric(point))
                    )
                    .foregroundStyle(Color.vitalPrimary)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value(selectedMetric.rawValue, valueForMetric(point))
                    )
                    .foregroundStyle(Color.vitalPrimary)
                    .symbolSize(30)

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value(selectedMetric.rawValue, valueForMetric(point))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.vitalPrimary.opacity(0.2), Color.vitalPrimary.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(formattedAxisValue(doubleValue))
                                    .font(.vitalCaptionSmall)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(.dateTime.month(.abbreviated).day()))
                                    .font(.vitalCaptionSmall)
                            }
                        }
                    }
                }
                .frame(height: Spacing.chartHeightLarge)
            }
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("STATS")
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextTertiary)

            VitalCard {
                VStack(spacing: Spacing.md) {
                    if let first = filteredPoints.first, let last = filteredPoints.last, filteredPoints.count > 1 {
                        statRow("Sessions", "\(filteredPoints.count)")
                        Divider()
                        statRow("First Recorded", first.date.formatted(date: .abbreviated, time: .omitted))
                        Divider()
                        statRow("Latest", last.date.formatted(date: .abbreviated, time: .omitted))
                        Divider()

                        let weightChange = last.maxWeight - first.maxWeight
                        let weightChangeFormatted = String(format: "%+.1f kg", weightChange)
                        statRow("Weight Change", weightChangeFormatted)
                        Divider()

                        let e1rmChange = last.estimated1RM - first.estimated1RM
                        let e1rmFormatted = String(format: "%+.1f kg", e1rmChange)
                        statRow("Est. 1RM Change", e1rmFormatted)
                    } else if let only = filteredPoints.first {
                        statRow("Sessions", "1")
                        Divider()
                        statRow("Max Weight", String(format: "%.1f kg", only.maxWeight))
                        Divider()
                        statRow("Est. 1RM", String(format: "%.1f kg", only.estimated1RM))
                    }
                }
            }
        }
    }

    private func statRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            Spacer()
            Text(value)
                .font(.vitalLabel)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
        }
    }

    // MARK: - Helpers

    private func valueForMetric(_ point: ExerciseHistoryPoint) -> Double {
        switch selectedMetric {
        case .maxWeight: return point.maxWeight
        case .totalVolume: return point.totalVolume
        case .estimated1RM: return point.estimated1RM
        }
    }

    private func formattedAxisValue(_ value: Double) -> String {
        if selectedMetric == .totalVolume && value >= 1000 {
            return String(format: "%.0fk", value / 1000)
        }
        return String(format: "%.0f", value)
    }

    private func loadHistory() async {
        do {
            historyPoints = try await getExerciseHistoryUseCase.execute(exerciseId: exercise.id)
        } catch {
            Log.error("Failed to load exercise history", error: error, category: .workout)
        }
        isLoading = false
    }
}
