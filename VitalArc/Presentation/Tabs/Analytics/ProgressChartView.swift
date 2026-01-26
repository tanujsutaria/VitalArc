//
//  ProgressChartView.swift
//  VitalArc
//
//  Charts for body composition and progress tracking
//

import SwiftUI
import Charts

struct ProgressChartView: View {
    let snapshots: [ProgressSnapshot]
    @State private var selectedMeasurement: BodyPart?

    var sortedSnapshots: [ProgressSnapshot] {
        snapshots.sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !snapshots.isEmpty {
                    // Body Weight Chart
                    if snapshots.contains(where: { $0.bodyWeight != nil }) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Body Weight")
                                .font(.headline)

                            Chart {
                                ForEach(sortedSnapshots.filter { $0.bodyWeight != nil }) { snapshot in
                                    LineMark(
                                        x: .value("Date", snapshot.date),
                                        y: .value("Weight", snapshot.bodyWeight ?? 0)
                                    )
                                    .foregroundStyle(.blue)
                                    .interpolationMethod(.catmullRom)

                                    PointMark(
                                        x: .value("Date", snapshot.date),
                                        y: .value("Weight", snapshot.bodyWeight ?? 0)
                                    )
                                    .foregroundStyle(.blue)
                                }
                            }
                            .frame(height: 200)
                            .chartXAxis {
                                AxisMarks { _ in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.month().day())
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisGridLine()
                                    AxisValueLabel()
                                }
                            }

                            // Weight change summary
                            if let firstWeight = sortedSnapshots.first(where: { $0.bodyWeight != nil })?.bodyWeight,
                               let lastWeight = sortedSnapshots.last(where: { $0.bodyWeight != nil })?.bodyWeight {
                                let change = lastWeight - firstWeight
                                let changePercent = (change / firstWeight) * 100

                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Total Change")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(String(format: "%+.1f kg", change))
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Percentage")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(String(format: "%+.1f%%", changePercent))
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Body Fat Percentage
                    if snapshots.contains(where: { $0.bodyFatPercentage != nil }) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Body Fat Percentage")
                                .font(.headline)

                            Chart {
                                ForEach(sortedSnapshots.filter { $0.bodyFatPercentage != nil }) { snapshot in
                                    LineMark(
                                        x: .value("Date", snapshot.date),
                                        y: .value("Body Fat", snapshot.bodyFatPercentage ?? 0)
                                    )
                                    .foregroundStyle(.orange)
                                    .interpolationMethod(.catmullRom)

                                    PointMark(
                                        x: .value("Date", snapshot.date),
                                        y: .value("Body Fat", snapshot.bodyFatPercentage ?? 0)
                                    )
                                    .foregroundStyle(.orange)
                                }
                            }
                            .frame(height: 180)
                            .chartXAxis {
                                AxisMarks { _ in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.month().day())
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Body Measurements
                    if !sortedSnapshots.flatMap({ $0.measurements }).isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Body Measurements")
                                .font(.headline)

                            // Measurement selector
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(BodyPart.allCases, id: \.self) { bodyPart in
                                        if hasMeasurements(for: bodyPart) {
                                            Button {
                                                selectedMeasurement = selectedMeasurement == bodyPart ? nil : bodyPart
                                            } label: {
                                                Text(bodyPart.displayName)
                                                    .font(.caption)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(
                                                        selectedMeasurement == bodyPart ?
                                                        Color.blue : Color(.systemGray5)
                                                    )
                                                    .foregroundStyle(
                                                        selectedMeasurement == bodyPart ?
                                                        .white : .primary
                                                    )
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }

                            // Chart for selected measurement
                            if let selectedMeasurement = selectedMeasurement {
                                Chart {
                                    ForEach(sortedSnapshots) { snapshot in
                                        if let measurement = snapshot.measurements.first(where: { $0.bodyPart == selectedMeasurement }) {
                                            LineMark(
                                                x: .value("Date", snapshot.date),
                                                y: .value("Measurement", measurement.value)
                                            )
                                            .foregroundStyle(.purple)
                                            .interpolationMethod(.catmullRom)

                                            PointMark(
                                                x: .value("Date", snapshot.date),
                                                y: .value("Measurement", measurement.value)
                                            )
                                            .foregroundStyle(.purple)
                                        }
                                    }
                                }
                                .frame(height: 180)
                                .chartXAxis {
                                    AxisMarks { _ in
                                        AxisGridLine()
                                        AxisValueLabel(format: .dateTime.month().day())
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { value in
                                        AxisGridLine()
                                        AxisValueLabel {
                                            if let cm = value.as(Double.self) {
                                                Text("\(Int(cm)) cm")
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("Select a measurement to view chart")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Latest Snapshot Details
                    if let latestSnapshot = sortedSnapshots.last {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Latest Snapshot")
                                .font(.headline)

                            Text(latestSnapshot.date.formatted(date: .long, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if let notes = latestSnapshot.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.body)
                                    .padding(.top, 4)
                            }

                            if !latestSnapshot.measurements.isEmpty {
                                Divider()
                                    .padding(.vertical, 4)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(latestSnapshot.measurements) { measurement in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(measurement.bodyPart.displayName)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text("\(String(format: "%.1f", measurement.value)) cm")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                } else {
                    ContentUnavailableView(
                        "No Progress Data",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Add progress snapshots to track changes")
                    )
                }
            }
            .padding()
        }
    }

    private func hasMeasurements(for bodyPart: BodyPart) -> Bool {
        sortedSnapshots.contains { snapshot in
            snapshot.measurements.contains { $0.bodyPart == bodyPart }
        }
    }
}
