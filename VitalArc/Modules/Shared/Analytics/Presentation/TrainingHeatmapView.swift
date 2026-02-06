//
//  TrainingHeatmapView.swift
//  VitalArc
//
//  GitHub-style contribution heatmap for training frequency
//

import SwiftUI

struct TrainingHeatmapView: View {
    let trainingDays: [Date: Int] // Date -> workout count/intensity
    let weeks: Int
    let title: String

    @State private var selectedDay: Date?
    @State private var hasAppeared = false

    init(trainingDays: [Date: Int], weeks: Int = 12, title: String = "Training Activity") {
        self.trainingDays = trainingDays
        self.weeks = weeks
        self.title = title
    }

    private let dayLabels = ["", "M", "", "W", "", "F", ""]
    private let cellSize: CGFloat = 14
    private let cellSpacing: CGFloat = 3

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                HStack {
                    Text(title)
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Spacer()

                    // Streak badge
                    if currentStreak > 0 {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "flame.fill")
                                .font(.vitalIconXSmall)
                            Text("\(currentStreak) day streak")
                                .font(.vitalCaptionSmall)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.vitalWarning)
                        .cornerRadius(Spacing.radiusSmall)
                    }
                }

                // Heatmap grid
                HStack(alignment: .top, spacing: cellSpacing) {
                    // Day labels
                    VStack(spacing: cellSpacing) {
                        ForEach(0..<7, id: \.self) { day in
                            Text(dayLabels[day])
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                .frame(width: 16, height: cellSize)
                        }
                    }

                    // Grid
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: cellSpacing) {
                            ForEach(0..<weeks, id: \.self) { weekIndex in
                                VStack(spacing: cellSpacing) {
                                    ForEach(0..<7, id: \.self) { dayIndex in
                                        let date = dateForCell(week: weekIndex, day: dayIndex)
                                        let intensity = trainingDays[Calendar.current.startOfDay(for: date)] ?? 0

                                        HeatmapCell(
                                            intensity: intensity,
                                            date: date,
                                            isSelected: selectedDay == date,
                                            hasAppeared: hasAppeared,
                                            delay: Double(weekIndex * 7 + dayIndex) * 0.01
                                        )
                                        .onTapGesture {
                                            withAnimation(.vitalSpring) {
                                                selectedDay = selectedDay == date ? nil : date
                                            }
                                            HapticFeedback.light()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Legend
                HStack(spacing: Spacing.sm) {
                    Text("Less")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    ForEach(0..<5, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(intensityColor(level))
                            .frame(width: 12, height: 12)
                    }

                    Text("More")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    Spacer()

                    // Summary
                    VStack(alignment: .trailing, spacing: Spacing.xxs) {
                        Text("\(totalWorkouts)")
                            .font(.vitalLabel)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        Text("workouts in \(weeks) weeks")
                            .font(.vitalCaptionSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }

                // Selected day info
                if let selected = selectedDay {
                    let count = trainingDays[Calendar.current.startOfDay(for: selected)] ?? 0
                    HStack {
                        Text(selected, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        Spacer()
                        Text(count > 0 ? "\(count) workout\(count > 1 ? "s" : "")" : "Rest day")
                            .font(.vitalLabel)
                            .foregroundStyle(count > 0 ? Color.vitalSuccess : Color.vitalAdaptiveTextSecondary)
                    }
                    .padding(Spacing.sm)
                    .background(Color.vitalAdaptiveBackground)
                    .cornerRadius(Spacing.radiusSmall)
                    .transition(.vitalSlideUp)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.vitalSpring) {
                    hasAppeared = true
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: Date())

        // Check if today has a workout
        if trainingDays[date] ?? 0 > 0 {
            streak = 1
        } else {
            // If not, start from yesterday
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }

        while true {
            if trainingDays[date] ?? 0 > 0 {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
            } else {
                break
            }
        }

        return streak
    }

    private var totalWorkouts: Int {
        trainingDays.values.reduce(0, +)
    }

    // MARK: - Helper Methods

    private func dateForCell(week: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let daysAgo = (weeks - 1 - week) * 7 + (6 - day)
        return calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
    }

    private func intensityColor(_ level: Int) -> Color {
        switch level {
        case 0: return Color.vitalAdaptiveBorder.opacity(0.5)
        case 1: return Color.vitalSuccess.opacity(0.3)
        case 2: return Color.vitalSuccess.opacity(0.5)
        case 3: return Color.vitalSuccess.opacity(0.7)
        default: return Color.vitalSuccess
        }
    }
}

// MARK: - Heatmap Cell

private struct HeatmapCell: View {
    let intensity: Int
    let date: Date
    let isSelected: Bool
    let hasAppeared: Bool
    let delay: Double

    private let cellSize: CGFloat = 14

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(cellColor)
            .frame(width: cellSize, height: cellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(isSelected ? Color.vitalPrimary : .clear, lineWidth: 2)
            )
            .scaleEffect(hasAppeared ? 1.0 : 0.0)
            .animation(.vitalSpringBouncy.delay(delay), value: hasAppeared)
    }

    private var cellColor: Color {
        if date > Date() {
            return Color.vitalAdaptiveBorder.opacity(0.2)
        }

        switch intensity {
        case 0: return Color.vitalAdaptiveBorder.opacity(0.3)
        case 1: return Color.vitalSuccess.opacity(0.4)
        case 2: return Color.vitalSuccess.opacity(0.6)
        case 3: return Color.vitalSuccess.opacity(0.8)
        default: return Color.vitalSuccess
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            TrainingHeatmapView(
                trainingDays: generateSampleData(),
                weeks: 12
            )
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}

private func generateSampleData() -> [Date: Int] {
    var data: [Date: Int] = [:]
    let calendar = Calendar.current

    for daysAgo in 0..<84 {
        if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
            let startOfDay = calendar.startOfDay(for: date)
            // Random workout count 0-4
            if Int.random(in: 0..<10) > 3 {
                data[startOfDay] = Int.random(in: 1...4)
            }
        }
    }

    return data
}
