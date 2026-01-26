//
//  AnalyticsDashboardView.swift
//  VitalArc
//
//  Main analytics dashboard view
//

import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @State private var viewModel: AnalyticsDashboardViewModel
    @State private var selectedTab = 0
    @State private var showingExportSheet = false
    @State private var exportURL: URL?

    init(viewModel: AnalyticsDashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Time range picker
                Picker("Time Range", selection: $viewModel.selectedTimeRange) {
                    ForEach(AnalyticsDashboardViewModel.TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Tab view
                TabView(selection: $selectedTab) {
                    OverviewTab(viewModel: viewModel)
                        .tag(0)

                    VolumeChartView(metrics: viewModel.volumeMetrics)
                        .tag(1)

                    ProgressChartView(snapshots: viewModel.progressSnapshots)
                        .tag(2)

                    PersonalRecordsView(records: viewModel.personalRecords)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .task {
                await viewModel.loadData()
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
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
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
}

// MARK: - Overview Tab

struct OverviewTab: View {
    let viewModel: AnalyticsDashboardViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let report = viewModel.currentReport {
                    // Progress Score
                    ProgressScoreCard(report: report)

                    // Key Metrics Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        AnalyticsMetricCard(
                            title: "Workout Consistency",
                            value: "\(Int(report.workoutConsistency))%",
                            icon: "figure.strengthtraining.traditional",
                            color: .blue
                        )

                        AnalyticsMetricCard(
                            title: "Nutrition Adherence",
                            value: "\(Int(report.avgCalorieAdherence))%",
                            icon: "fork.knife",
                            color: .green
                        )

                        if let weightChange = report.bodyWeightChange {
                            AnalyticsMetricCard(
                                title: "Weight Change",
                                value: String(format: "%+.1f kg", weightChange),
                                icon: "scalemass",
                                color: .orange
                            )
                        }

                        AnalyticsMetricCard(
                            title: "Volume Change",
                            value: String(format: "%+.1f%%", report.volumeChange),
                            icon: "chart.line.uptrend.xyaxis",
                            color: .purple
                        )
                    }

                    // Records Broken
                    if !report.recordsBroken.isEmpty {
                        RecordsSummaryCard(records: report.recordsBroken)
                    }

                    // Recovery Metrics
                    if report.avgSleepHours != nil || report.avgHRV != nil {
                        RecoveryMetricsCard(report: report)
                    }
                } else {
                    ContentUnavailableView(
                        "No Data Available",
                        systemImage: "chart.xyaxis.line",
                        description: Text("Start tracking workouts to see analytics")
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views

struct ProgressScoreCard: View {
    let report: ProgressReport

    var body: some View {
        VStack(spacing: 12) {
            Text("Progress Score")
                .font(.headline)
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: report.progressScore / 100)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(Int(report.progressScore))")
                        .font(.system(size: 36, weight: .bold))
                    Text("%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(report.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AnalyticsMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecordsSummaryCard: View {
    let records: [PersonalRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                Text("Personal Records Broken")
                    .font(.headline)
            }

            ForEach(records.prefix(3)) { record in
                HStack {
                    Text(record.exerciseName)
                        .font(.subheadline)
                    Spacer()
                    Text(record.displayValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if records.count > 3 {
                Text("+\(records.count - 3) more")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecoveryMetricsCard: View {
    let report: ProgressReport

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bed.double.fill")
                    .foregroundStyle(.indigo)
                Text("Recovery Metrics")
                    .font(.headline)
            }

            if let sleepHours = report.avgSleepHours {
                HStack {
                    Text("Average Sleep")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.1f hours", sleepHours))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let hrv = report.avgHRV {
                HStack {
                    Text("Average HRV")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(hrv)) ms")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

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
