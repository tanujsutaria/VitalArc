//
//  MealTimeSettingsView.swift
//  VitalArc
//
//  View for configuring custom meal time boundaries
//

import SwiftUI

struct MealTimeSettingsView: View {
    @State private var config: MealTimeConfiguration = MealTimeConfiguration.load()
    @State private var hasChanges = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Info header
                VitalCard {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .font(.system(size: Spacing.iconMedium))
                                .foregroundStyle(Color.vitalPrimary)
                            Text("Meal Time Boundaries")
                                .font(.vitalH2)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }
                        Text("Customize when each meal period starts. The app uses these times to auto-select the meal type when logging food.")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }

                // Meal time pickers
                VitalCard {
                    VStack(spacing: Spacing.lg) {
                        MealTimePicker(
                            meal: .breakfast,
                            hour: $config.breakfastStart,
                            timeRange: config.timeRange(for: .breakfast),
                            color: .vitalWarning,
                            icon: "sunrise.fill",
                            onChange: { hasChanges = true }
                        )

                        Divider()
                            .background(Color.vitalAdaptiveBorder)

                        MealTimePicker(
                            meal: .lunch,
                            hour: $config.lunchStart,
                            timeRange: config.timeRange(for: .lunch),
                            color: .vitalSuccess,
                            icon: "sun.max.fill",
                            onChange: { hasChanges = true }
                        )

                        Divider()
                            .background(Color.vitalAdaptiveBorder)

                        MealTimePicker(
                            meal: .dinner,
                            hour: $config.dinnerStart,
                            timeRange: config.timeRange(for: .dinner),
                            color: .vitalInfo,
                            icon: "sunset.fill",
                            onChange: { hasChanges = true }
                        )

                        Divider()
                            .background(Color.vitalAdaptiveBorder)

                        MealTimePicker(
                            meal: .snack,
                            hour: $config.snackStart,
                            timeRange: config.timeRange(for: .snack),
                            color: .vitalPrimary,
                            icon: "moon.fill",
                            onChange: { hasChanges = true }
                        )
                    }
                }

                // Visual Timeline
                VitalCard {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Daily Timeline")
                            .font(.vitalH2)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        MealTimeline(config: config)
                    }
                }

                // Reset button
                if hasChanges {
                    Button {
                        config = MealTimeConfiguration()
                        hasChanges = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Defaults")
                        }
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalDanger)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Spacing.screenPadding)
        }
        .background(Color.vitalAdaptiveBackground)
        .navigationTitle("Meal Times")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if hasChanges {
                    Button("Save") {
                        config.save()
                        hasChanges = false
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.vitalPrimary)
                }
            }
        }
    }
}

// MARK: - Meal Time Picker

private struct MealTimePicker: View {
    let meal: MealType
    @Binding var hour: Int
    let timeRange: String
    let color: Color
    let icon: String
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: Spacing.iconSmall))
                    .foregroundStyle(color)

                Text(meal.displayName)
                    .font(.vitalBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Spacer()

                Text(timeRange)
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }

            HStack {
                Text("Starts at")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                Picker("Start hour", selection: $hour) {
                    ForEach(0..<24, id: \.self) { h in
                        Text(formatHour(h)).tag(h)
                    }
                }
                .pickerStyle(.menu)
                .tint(color)
                .onChange(of: hour) { _, _ in
                    onChange()
                }
            }
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour):00 \(period)"
    }
}

// MARK: - Meal Timeline

private struct MealTimeline: View {
    let config: MealTimeConfiguration

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let segments: [(MealType, Int, Int, Color)] = [
                (.breakfast, config.breakfastStart, config.lunchStart, .vitalWarning),
                (.lunch, config.lunchStart, config.dinnerStart, .vitalSuccess),
                (.dinner, config.dinnerStart, config.snackStart, .vitalInfo),
                (.snack, config.snackStart, config.breakfastStart + 24, .vitalPrimary)
            ]

            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                    .fill(Color.vitalAdaptiveBorder)
                    .frame(height: Spacing.xl)

                // Segments
                HStack(spacing: 0) {
                    ForEach(segments, id: \.0) { meal, start, end, color in
                        let duration = end > start ? end - start : (24 - start + end)
                        let fraction = CGFloat(duration) / 24.0

                        color.opacity(0.6)
                            .frame(width: width * fraction, height: Spacing.xl)
                            .overlay {
                                if width * fraction > 40 {
                                    Text(meal.displayName.prefix(1))
                                        .font(.vitalCaptionSmall)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                }
                .cornerRadius(Spacing.radiusSmall)
            }
        }
        .frame(height: Spacing.xl)

        // Legend
        HStack(spacing: Spacing.md) {
            TimelineLegendItem(label: "B", color: .vitalWarning)
            TimelineLegendItem(label: "L", color: .vitalSuccess)
            TimelineLegendItem(label: "D", color: .vitalInfo)
            TimelineLegendItem(label: "S", color: .vitalPrimary)

            Spacer()

            Text("24h")
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
    }
}

private struct TimelineLegendItem: View {
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(color.opacity(0.6))
                .frame(width: Spacing.sm, height: Spacing.sm)
            Text(label)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
    }
}
