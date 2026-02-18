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

    enum ProgressMetric: String, CaseIterable {
        case maxWeight = "Max Weight"
        case totalVolume = "Volume"
        case estimated1RM = "Est. 1RM"
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

                Chart(historyPoints) { point in
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
                    if let first = historyPoints.first, let last = historyPoints.last, historyPoints.count > 1 {
                        statRow("Sessions", "\(historyPoints.count)")
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
                    } else if let only = historyPoints.first {
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
