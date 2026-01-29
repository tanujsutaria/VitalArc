//
//  StrengthProgressionChartView.swift
//  VitalArc
//
//  Line chart showing estimated 1RM trends over time
//

import SwiftUI
import Charts

struct StrengthDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let estimatedOneRM: Double
    let exerciseName: String
}

struct StrengthProgressionChartView: View {
    let data: [String: [StrengthDataPoint]] // Exercise name -> data points
    let title: String

    @State private var selectedExercise: String?
    @State private var selectedPoint: StrengthDataPoint?
    @State private var hasAppeared = false

    private let exerciseColors: [Color] = [
        .vitalPrimary, .vitalDanger, .vitalSuccess, .vitalWarning, .vitalInfo, .vitalAccent
    ]

    init(data: [String: [StrengthDataPoint]], title: String = "Strength Progression") {
        self.data = data
        self.title = title
    }

    var exercises: [String] {
        Array(data.keys).sorted()
    }

    var displayedExercises: [String] {
        if let selected = selectedExercise {
            return [selected]
        }
        return Array(exercises.prefix(3))
    }

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                HStack {
                    Text(title)
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Spacer()

                    Text("Est. 1RM")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.vitalAdaptiveBackground)
                        .cornerRadius(Spacing.radiusSmall)
                }

                // Exercise filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(Array(exercises.enumerated()), id: \.element) { index, exercise in
                            ExerciseFilterPill(
                                name: exercise,
                                color: exerciseColors[index % exerciseColors.count],
                                isSelected: selectedExercise == exercise,
                                action: {
                                    withAnimation(.vitalSpring) {
                                        if selectedExercise == exercise {
                                            selectedExercise = nil
                                        } else {
                                            selectedExercise = exercise
                                        }
                                    }
                                    HapticFeedback.light()
                                }
                            )
                        }
                    }
                }

                // Chart
                if !data.isEmpty {
                    Chart {
                        ForEach(displayedExercises, id: \.self) { exercise in
                            if let points = data[exercise] {
                                ForEach(points) { point in
                                    LineMark(
                                        x: .value("Date", point.date),
                                        y: .value("1RM", hasAppeared ? point.estimatedOneRM : 0)
                                    )
                                    .foregroundStyle(by: .value("Exercise", exercise))
                                    .interpolationMethod(.catmullRom)
                                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))

                                    PointMark(
                                        x: .value("Date", point.date),
                                        y: .value("1RM", hasAppeared ? point.estimatedOneRM : 0)
                                    )
                                    .foregroundStyle(by: .value("Exercise", exercise))
                                    .symbolSize(40)
                                }

                                // Area gradient
                                ForEach(points) { point in
                                    AreaMark(
                                        x: .value("Date", point.date),
                                        y: .value("1RM", hasAppeared ? point.estimatedOneRM : 0)
                                    )
                                    .foregroundStyle(by: .value("Exercise", exercise))
                                    .interpolationMethod(.catmullRom)
                                    .opacity(0.1)
                                }
                            }
                        }
                    }
                    .chartForegroundStyleScale(
                        domain: exercises,
                        range: exerciseColors.prefix(exercises.count).map { $0 }
                    )
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let weight = value.as(Double.self) {
                                    Text("\(Int(weight)) kg")
                                        .font(.vitalCaptionSmall)
                                }
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        }
                    }
                    .chartLegend(position: .bottom, alignment: .leading)
                    .frame(height: 220)
                    .animation(.vitalSpringBouncy, value: hasAppeared)
                    .animation(.vitalSpring, value: selectedExercise)

                    // Progress summary
                    if let selected = selectedExercise,
                       let points = data[selected],
                       let first = points.first,
                       let last = points.last {
                        progressSummary(first: first, last: last)
                    }
                } else {
                    emptyState
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Progress Summary

    private func progressSummary(first: StrengthDataPoint, last: StrengthDataPoint) -> some View {
        let change = last.estimatedOneRM - first.estimatedOneRM
        let percentChange = (change / first.estimatedOneRM) * 100

        return HStack(spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Starting 1RM")
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                Text("\(Int(first.estimatedOneRM)) kg")
                    .font(.vitalLabel)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
            }

            Image(systemName: "arrow.right")
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Current 1RM")
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                Text("\(Int(last.estimatedOneRM)) kg")
                    .font(.vitalLabel)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Progress")
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                HStack(spacing: 4) {
                    Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.vitalCaptionSmall)
                    Text(String(format: "%+.1f%%", percentChange))
                        .font(.vitalLabel)
                }
                .foregroundStyle(change >= 0 ? Color.vitalSuccess : Color.vitalDanger)
            }
        }
        .padding(Spacing.sm)
        .background(Color.vitalAdaptiveBackground)
        .cornerRadius(Spacing.radiusSmall)
        .transition(.vitalSlideUp)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: Spacing.icon2XLarge))
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Text("No strength data yet")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Text("Track your workouts to see strength progression")
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Exercise Filter Pill

private struct ExerciseFilterPill: View {
    let name: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Circle()
                    .fill(color)
                    .frame(width: Spacing.sm, height: Spacing.sm)

                Text(name)
                    .font(.vitalCaptionSmall)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(isSelected ? color.opacity(0.15) : Color.vitalAdaptiveBackground)
            .foregroundStyle(isSelected ? color : Color.vitalAdaptiveTextSecondary)
            .cornerRadius(Spacing.radiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                    .stroke(isSelected ? color : Color.vitalAdaptiveBorder, lineWidth: 1)
            )
        }
        .vitalScaleButton()
    }
}

// MARK: - Preview

#Preview {
    let sampleData: [String: [StrengthDataPoint]] = [
        "Bench Press": (0..<8).map { weekOffset in
            StrengthDataPoint(
                date: Calendar.current.date(byAdding: .weekOfYear, value: -7 + weekOffset, to: Date())!,
                estimatedOneRM: 100 + Double(weekOffset) * 2.5 + Double.random(in: -2...2),
                exerciseName: "Bench Press"
            )
        },
        "Squat": (0..<8).map { weekOffset in
            StrengthDataPoint(
                date: Calendar.current.date(byAdding: .weekOfYear, value: -7 + weekOffset, to: Date())!,
                estimatedOneRM: 140 + Double(weekOffset) * 3.0 + Double.random(in: -3...3),
                exerciseName: "Squat"
            )
        },
        "Deadlift": (0..<8).map { weekOffset in
            StrengthDataPoint(
                date: Calendar.current.date(byAdding: .weekOfYear, value: -7 + weekOffset, to: Date())!,
                estimatedOneRM: 160 + Double(weekOffset) * 3.5 + Double.random(in: -4...4),
                exerciseName: "Deadlift"
            )
        }
    ]

    return ScrollView {
        VStack(spacing: Spacing.lg) {
            StrengthProgressionChartView(data: sampleData)
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
