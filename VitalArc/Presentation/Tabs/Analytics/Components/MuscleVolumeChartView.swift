//
//  MuscleVolumeChartView.swift
//  VitalArc
//
//  Bar chart showing volume by muscle group with weekly/monthly toggle
//

import SwiftUI
import Charts

struct MuscleVolumeData: Identifiable {
    let id = UUID()
    let muscleGroup: String
    let volume: Double
    let color: Color
}

struct MuscleVolumeChartView: View {
    let weeklyData: [MuscleVolumeData]
    let monthlyData: [MuscleVolumeData]

    @State private var selectedPeriod: Period = .weekly
    @State private var selectedBar: MuscleVolumeData?
    @State private var hasAppeared = false

    enum Period: String, CaseIterable {
        case weekly = "Week"
        case monthly = "Month"
    }

    var currentData: [MuscleVolumeData] {
        selectedPeriod == .weekly ? weeklyData : monthlyData
    }

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header with period toggle
                HStack {
                    Text("Volume by Muscle Group")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                    Spacer()

                    // Period picker
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(Period.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 140)
                }

                // Chart
                if currentData.isEmpty {
                    emptyState
                } else {
                    Chart {
                        ForEach(currentData) { item in
                            BarMark(
                                x: .value("Volume", hasAppeared ? item.volume : 0),
                                y: .value("Muscle", item.muscleGroup)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [item.color, item.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(6)
                            .annotation(position: .trailing, alignment: .leading, spacing: 4) {
                                if hasAppeared {
                                    Text(formatVolume(item.volume))
                                        .font(.vitalCaptionSmall)
                                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                }
                            }
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .font(.vitalBodySmall)
                        }
                    }
                    .frame(height: CGFloat(currentData.count * 44))
                    .animation(.vitalSpringBouncy, value: hasAppeared)
                    .animation(.vitalSpring, value: selectedPeriod)

                    // Summary
                    HStack(spacing: Spacing.lg) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Total Volume")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(formatVolume(totalVolume))
                                .font(.vitalNumberSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }

                        Divider()
                            .frame(height: 30)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Top Muscle")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            Text(topMuscle?.muscleGroup ?? "-")
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }

                        Spacer()
                    }
                    .padding(.top, Spacing.sm)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Computed Properties

    private var totalVolume: Double {
        currentData.reduce(0) { $0 + $1.volume }
    }

    private var topMuscle: MuscleVolumeData? {
        currentData.max { $0.volume < $1.volume }
    }

    // MARK: - Helper Methods

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk kg", volume / 1000)
        }
        return String(format: "%.0f kg", volume)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: Spacing.icon2XLarge))
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Text("No volume data yet")
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            Text("Complete workouts to see your volume breakdown")
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    let muscleColors: [String: Color] = [
        "Chest": .vitalDanger,
        "Back": .vitalInfo,
        "Shoulders": .vitalWarning,
        "Arms": .vitalAccent,
        "Legs": .vitalSuccess,
        "Core": .vitalSecondary
    ]

    let weeklyData: [MuscleVolumeData] = [
        MuscleVolumeData(muscleGroup: "Chest", volume: 8500, color: muscleColors["Chest"]!),
        MuscleVolumeData(muscleGroup: "Back", volume: 12000, color: muscleColors["Back"]!),
        MuscleVolumeData(muscleGroup: "Shoulders", volume: 4500, color: muscleColors["Shoulders"]!),
        MuscleVolumeData(muscleGroup: "Arms", volume: 6000, color: muscleColors["Arms"]!),
        MuscleVolumeData(muscleGroup: "Legs", volume: 15000, color: muscleColors["Legs"]!),
        MuscleVolumeData(muscleGroup: "Core", volume: 2000, color: muscleColors["Core"]!)
    ]

    let monthlyData: [MuscleVolumeData] = [
        MuscleVolumeData(muscleGroup: "Chest", volume: 34000, color: muscleColors["Chest"]!),
        MuscleVolumeData(muscleGroup: "Back", volume: 48000, color: muscleColors["Back"]!),
        MuscleVolumeData(muscleGroup: "Shoulders", volume: 18000, color: muscleColors["Shoulders"]!),
        MuscleVolumeData(muscleGroup: "Arms", volume: 24000, color: muscleColors["Arms"]!),
        MuscleVolumeData(muscleGroup: "Legs", volume: 60000, color: muscleColors["Legs"]!),
        MuscleVolumeData(muscleGroup: "Core", volume: 8000, color: muscleColors["Core"]!)
    ]

    return ScrollView {
        VStack(spacing: Spacing.lg) {
            MuscleVolumeChartView(weeklyData: weeklyData, monthlyData: monthlyData)
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
