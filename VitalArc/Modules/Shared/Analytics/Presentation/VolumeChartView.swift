//
//  VolumeChartView.swift
//  VitalArc
//
//  Charts for training volume visualization
//

import SwiftUI
import Charts

struct VolumeChartView: View {
    let metrics: [VolumeMetrics]
    @State private var selectedMetric: VolumeMetrics?

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                if !metrics.isEmpty {
                    // Weekly Volume Trend
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Weekly Volume Trend")
                            .font(.vitalH3)

                        Chart {
                            ForEach(metrics) { metric in
                                LineMark(
                                    x: .value("Week", metric.weekStartDate),
                                    y: .value("Volume", metric.totalVolume)
                                )
                                .foregroundStyle(Color.vitalPrimary)
                                .interpolationMethod(.catmullRom)

                                AreaMark(
                                    x: .value("Week", metric.weekStartDate),
                                    y: .value("Volume", metric.totalVolume)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.vitalPrimary.opacity(0.3), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .interpolationMethod(.catmullRom)
                            }
                        }
                        .frame(height: Spacing.chartHeightExtraLarge)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let volume = value.as(Double.self) {
                                        Text("\(Int(volume / 1000))k")
                                    }
                                }
                            }
                        }
                    }
                    .padding(Spacing.lg)
                    .background(Color.vitalAdaptiveSurface)
                    .cornerRadius(Spacing.radiusMedium)

                    // Workout Count
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Workout Frequency")
                            .font(.vitalH3)

                        Chart {
                            ForEach(metrics) { metric in
                                BarMark(
                                    x: .value("Week", metric.weekStartDate),
                                    y: .value("Workouts", metric.workoutCount)
                                )
                                .foregroundStyle(Color.vitalSuccess)
                            }
                        }
                        .frame(height: Spacing.chartHeightLarge)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            }
                        }
                    }
                    .padding(Spacing.lg)
                    .background(Color.vitalAdaptiveSurface)
                    .cornerRadius(Spacing.radiusMedium)

                    // Top Exercises by Volume
                    if let latestMetric = metrics.last {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Top Exercises This Week")
                                .font(.vitalH3)

                            ForEach(latestMetric.topExercises(limit: 5)) { exercise in
                                HStack {
                                    VStack(alignment: .leading, spacing: Spacing.xs) {
                                        Text(exercise.exerciseName)
                                            .font(.vitalBody)
                                        Text("\(exercise.sets) sets x \(Int(exercise.avgReps)) reps")
                                            .font(.vitalCaption)
                                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                                        Text("\(Int(exercise.totalWeight)) kg")
                                            .font(.vitalLabel)
                                        Text("total volume")
                                            .font(.vitalCaption)
                                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                    }
                                }
                                .padding(.vertical, Spacing.sm)

                                if exercise.id != latestMetric.topExercises(limit: 5).last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding(Spacing.lg)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                    }

                    // Volume Distribution (if data available)
                    if let latestMetric = metrics.last, !latestMetric.exerciseVolumes.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Volume Distribution")
                                .font(.vitalH3)

                            Chart {
                                ForEach(latestMetric.topExercises(limit: 8)) { exercise in
                                    SectorMark(
                                        angle: .value("Volume", exercise.totalWeight),
                                        innerRadius: .ratio(0.5),
                                        angularInset: 1.5
                                    )
                                    .foregroundStyle(by: .value("Exercise", exercise.exerciseName))
                                }
                            }
                            .frame(height: Spacing.chartHeightXL)
                        }
                        .padding(Spacing.lg)
                        .background(Color.vitalAdaptiveSurface)
                        .cornerRadius(Spacing.radiusMedium)
                    }
                } else {
                    ContentUnavailableView(
                        "No Volume Data",
                        systemImage: "chart.bar",
                        description: Text("Complete workouts to see volume analytics")
                    )
                }
            }
            .padding(Spacing.lg)
        }
    }
}

#Preview("Empty State") {
    VolumeChartView(metrics: [])
}
