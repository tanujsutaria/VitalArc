//
//  VolumeAnalysisView.swift
//  VitalArc
//
//  Per-muscle-group volume breakdown with charts
//

import SwiftUI
import Charts

struct VolumeAnalysisView: View {
    @State private var viewModel: VolumeAnalysisViewModel

    init(viewModel: VolumeAnalysisViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: Spacing.sectionSpacing) {
            volumeVsRecommendedCard
            summaryCard
            if let selected = viewModel.selectedAnalysis {
                volumeTrendCard(for: selected)
                recoveryCard(for: selected)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Volume vs Recommended Chart

    private var volumeVsRecommendedCard: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(Color.vitalPrimary)
                        Text("Weekly Sets vs Recommended")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    }
                    Spacer()
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: Spacing.chartHeightExtraLarge)
                } else if viewModel.analyses.isEmpty {
                    emptyState
                } else {
                    volumeBarChart
                    musclePicker
                }
            }
        }
    }

    private var volumeBarChart: some View {
        Chart {
            ForEach(viewModel.analyses) { analysis in
                // Current sets bar
                BarMark(
                    x: .value("Sets", analysis.weeklySets),
                    y: .value("Muscle", analysis.muscleGroup.rawValue)
                )
                .foregroundStyle(analysis.volumeStatus.color.gradient)
                .cornerRadius(Spacing.xs)

                // Recommended range as rule marks
                RectangleMark(
                    xStart: .value("Min", analysis.recommendedRange.lowerBound),
                    xEnd: .value("Max", analysis.recommendedRange.upperBound),
                    y: .value("Muscle", analysis.muscleGroup.rawValue)
                )
                .foregroundStyle(Color.vitalPrimary.opacity(0.1))
                .cornerRadius(Spacing.xxs)
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let sets = value.as(Int.self) {
                        Text("\(sets)")
                            .font(.vitalCaptionSmall)
                    }
                }
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.vitalCaptionSmall)
            }
        }
        .frame(height: CGFloat(max(viewModel.analyses.count, 1) * 40))
        .chartLegend(.hidden)
    }

    private var musclePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(viewModel.analyses) { analysis in
                    Button {
                        withAnimation(.vitalSpring) {
                            viewModel.selectedMuscle = analysis.muscleGroup
                        }
                        HapticFeedback.selection()
                    } label: {
                        Text(analysis.muscleGroup.rawValue)
                            .font(.vitalCaptionSmall)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                viewModel.selectedMuscle == analysis.muscleGroup
                                    ? Color.vitalPrimary
                                    : Color.vitalAdaptiveSurface
                            )
                            .foregroundStyle(
                                viewModel.selectedMuscle == analysis.muscleGroup
                                    ? .white
                                    : Color.vitalAdaptiveTextSecondary
                            )
                            .cornerRadius(Spacing.radiusSmall)
                    }
                    .vitalScaleButton()
                }
            }
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        let summary = viewModel.summary
        return VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Volume Summary")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                    summaryItem(
                        icon: "arrow.up.circle.fill",
                        title: "Most Trained",
                        value: summary.mostTrainedMuscle?.rawValue ?? "-",
                        color: .vitalSuccess
                    )
                    summaryItem(
                        icon: "arrow.down.circle.fill",
                        title: "Least Trained",
                        value: summary.leastTrainedMuscle?.rawValue ?? "-",
                        color: .vitalWarning
                    )
                    summaryItem(
                        icon: "checkmark.circle.fill",
                        title: "Optimal",
                        value: "\(summary.musclesOptimal.count) muscles",
                        color: .vitalSuccess
                    )
                    summaryItem(
                        icon: "exclamationmark.triangle.fill",
                        title: "Needs Attention",
                        value: "\(summary.musclesUnderVolume.count + summary.musclesOverVolume.count) muscles",
                        color: .vitalDanger
                    )
                }
            }
        }
    }

    private func summaryItem(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: Spacing.iconMedium))

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                Text(value)
                    .font(.vitalLabel)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Volume Trend Chart

    private func volumeTrendCard(for analysis: MuscleVolumeAnalysis) -> some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("\(analysis.muscleGroup.rawValue) - Weekly Trend")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    Spacer()

                    VStack(alignment: .trailing, spacing: Spacing.xxs) {
                        Text("This Week")
                            .font(.vitalCaptionSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        Text("\(analysis.weeklySets) sets")
                            .font(.vitalLabel)
                            .foregroundStyle(analysis.volumeStatus.color)
                    }
                }

                if analysis.weeklyTrend.count >= 2 {
                    Chart {
                        // Recommended range area
                        RectangleMark(
                            yStart: .value("Min", analysis.recommendedRange.lowerBound),
                            yEnd: .value("Max", analysis.recommendedRange.upperBound)
                        )
                        .foregroundStyle(Color.vitalSuccess.opacity(0.1))

                        ForEach(analysis.weeklyTrend) { week in
                            LineMark(
                                x: .value("Week", week.weekStart),
                                y: .value("Sets", week.sets)
                            )
                            .foregroundStyle(Color.vitalPrimary)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3))

                            PointMark(
                                x: .value("Week", week.weekStart),
                                y: .value("Sets", week.sets)
                            )
                            .foregroundStyle(Color.vitalPrimary)
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                .font(.vitalCaptionSmall)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let sets = value.as(Int.self) {
                                    Text("\(sets)")
                                        .font(.vitalCaptionSmall)
                                }
                            }
                            AxisGridLine()
                        }
                    }
                    .frame(height: Spacing.chartHeightLarge)
                } else {
                    Text("Need at least 2 weeks of data for trend")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: Spacing.chartHeightCompact)
                }

                // Volume status
                HStack(spacing: Spacing.sm) {
                    Circle()
                        .fill(analysis.volumeStatus.color)
                        .frame(width: Spacing.sm, height: Spacing.sm)
                    Text(analysis.volumeStatus.rawValue)
                        .font(.vitalLabel)
                        .foregroundStyle(analysis.volumeStatus.color)

                    Text("(\(analysis.recommendedRange.lowerBound)-\(analysis.recommendedRange.upperBound) sets/week recommended)")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    Spacer()
                }
            }
        }
    }

    // MARK: - Recovery Card

    private func recoveryCard(for analysis: MuscleVolumeAnalysis) -> some View {
        VitalCard {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Recovery Status")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    HStack(spacing: Spacing.sm) {
                        Circle()
                            .fill(analysis.recoveryStatus.color)
                            .frame(width: Spacing.sm, height: Spacing.sm)
                        Text(analysis.recoveryStatus.rawValue)
                            .font(.vitalLabel)
                            .foregroundStyle(analysis.recoveryStatus.color)
                    }

                    if let days = analysis.daysSinceLastTrained {
                        Text("\(days) day\(days == 1 ? "" : "s") since last trained")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: Spacing.sm) {
                    Text("Frequency")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    Text(String(format: "%.1f×/wk", analysis.frequency))
                        .font(.vitalNumberSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "chart.bar.xaxis")
                .font(.vitalIcon2XLarge)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Text("No volume data yet")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Text("Complete workouts to see your volume analysis")
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: Spacing.chartHeightExtraLarge)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VolumeAnalysisView(
            viewModel: VolumeAnalysisViewModel(
                workoutRepository: PreviewWorkoutRepository()
            )
        )
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
