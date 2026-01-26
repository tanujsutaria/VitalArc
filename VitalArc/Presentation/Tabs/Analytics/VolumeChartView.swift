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
            VStack(spacing: 24) {
                if !metrics.isEmpty {
                    // Weekly Volume Trend
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Volume Trend")
                            .font(.headline)

                        Chart {
                            ForEach(metrics) { metric in
                                LineMark(
                                    x: .value("Week", metric.weekStartDate),
                                    y: .value("Volume", metric.totalVolume)
                                )
                                .foregroundStyle(.blue)
                                .interpolationMethod(.catmullRom)

                                AreaMark(
                                    x: .value("Week", metric.weekStartDate),
                                    y: .value("Volume", metric.totalVolume)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .interpolationMethod(.catmullRom)
                            }
                        }
                        .frame(height: 200)
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
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Workout Count
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Workout Frequency")
                            .font(.headline)

                        Chart {
                            ForEach(metrics) { metric in
                                BarMark(
                                    x: .value("Week", metric.weekStartDate),
                                    y: .value("Workouts", metric.workoutCount)
                                )
                                .foregroundStyle(.green)
                            }
                        }
                        .frame(height: 180)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Top Exercises by Volume
                    if let latestMetric = metrics.last {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Exercises This Week")
                                .font(.headline)

                            ForEach(latestMetric.topExercises(limit: 5)) { exercise in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exercise.exerciseName)
                                            .font(.subheadline)
                                        Text("\(exercise.sets) sets × \(Int(exercise.avgReps)) reps")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("\(Int(exercise.totalWeight)) kg")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text("total volume")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)

                                if exercise.id != latestMetric.topExercises(limit: 5).last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Volume Distribution (if data available)
                    if let latestMetric = metrics.last, !latestMetric.exerciseVolumes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Volume Distribution")
                                .font(.headline)

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
                            .frame(height: 250)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                } else {
                    ContentUnavailableView(
                        "No Volume Data",
                        systemImage: "chart.bar",
                        description: Text("Complete workouts to see volume analytics")
                    )
                }
            }
            .padding()
        }
    }
}
