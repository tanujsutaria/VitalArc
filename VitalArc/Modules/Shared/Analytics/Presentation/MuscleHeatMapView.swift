//
//  MuscleHeatMapView.swift
//  VitalArc
//
//  Visual heat map showing training frequency and volume per muscle group
//

import SwiftUI

struct MuscleHeatMapView: View {
    @State private var viewModel: MuscleHeatMapViewModel

    init(viewModel: MuscleHeatMapViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                header
                timeRangeSelector
                muscleGrid
                legend
            }
        }
        .task(id: viewModel.selectedTimeRange) {
            await viewModel.loadData()
        }
        .sheet(item: $viewModel.selectedMuscle) { muscle in
            MuscleDetailSheet(data: muscle)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(Color.vitalPrimary)
                Text("Muscle Heat Map")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
            }
            Spacer()
        }
    }

    // MARK: - Time Range

    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $viewModel.selectedTimeRange) {
            ForEach(HeatMapTimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Muscle Grid

    private var muscleGrid: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: Spacing.chartHeightLarge)
            } else {
                let columns = [
                    GridItem(.flexible(), spacing: Spacing.sm),
                    GridItem(.flexible(), spacing: Spacing.sm),
                    GridItem(.flexible(), spacing: Spacing.sm)
                ]

                // Group muscles by body region
                VStack(alignment: .leading, spacing: Spacing.md) {
                    muscleSection(title: "Upper Body - Push", muscles: [.chest, .shoulders, .triceps])
                    muscleSection(title: "Upper Body - Pull", muscles: [.back, .lats, .biceps, .forearms])
                    muscleSection(title: "Core", muscles: [.abs, .obliques])
                    muscleSection(title: "Lower Body", muscles: [.quadriceps, .hamstrings, .glutes, .calves])
                }
            }
        }
    }

    private func muscleSection(title: String, muscles: [MuscleGroup]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                .textCase(.uppercase)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.sm),
                GridItem(.flexible(), spacing: Spacing.sm),
                GridItem(.flexible(), spacing: Spacing.sm)
            ], spacing: Spacing.sm) {
                ForEach(muscles, id: \.self) { muscle in
                    muscleCell(for: muscle)
                }
            }
        }
    }

    private func muscleCell(for muscle: MuscleGroup) -> some View {
        let data = viewModel.completeMuscleData.first { $0.muscleGroup == muscle }
        let intensity = data?.intensityLevel ?? .none

        return Button {
            if let data = data, data.totalSets > 0 {
                viewModel.selectedMuscle = data
                HapticFeedback.light()
            }
        } label: {
            VStack(spacing: Spacing.xs) {
                Text(muscle.rawValue)
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(
                        intensity == .none
                            ? Color.vitalAdaptiveTextSecondary
                            : Color.vitalAdaptiveTextPrimary
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(data.map { "\($0.totalSets) sets" } ?? "0 sets")
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.xs)
            .background(intensity.color)
            .cornerRadius(Spacing.radiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                    .stroke(Color.vitalAdaptiveBorder, lineWidth: Spacing.borderThin)
            )
        }
        .vitalScaleButton()
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: Spacing.sm) {
            Text("Intensity:")
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            ForEach([HeatMapIntensity.none, .low, .moderate, .high, .veryHigh], id: \.rawValue) { level in
                RoundedRectangle(cornerRadius: Spacing.xxs)
                    .fill(level.color)
                    .frame(width: Spacing.md, height: Spacing.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: Spacing.xxs)
                            .stroke(Color.vitalAdaptiveBorder, lineWidth: 0.5)
                    )
            }

            Spacer()
        }
    }
}

// MARK: - Muscle Detail Sheet

private struct MuscleDetailSheet: View {
    let data: MuscleHeatMapData
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Intensity badge
                    HStack {
                        Text(data.intensityLevel.label)
                            .font(.vitalLabel)
                            .foregroundStyle(Color.vitalTextOnPrimary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(data.intensityLevel.color)
                            .cornerRadius(Spacing.radiusSmall)

                        Spacer()

                        if let lastDate = data.lastTrainedDate {
                            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                                Text("Last Trained")
                                    .font(.vitalCaptionSmall)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                Text(lastDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.vitalLabel)
                                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            }
                        }
                    }

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                        statItem(title: "Total Sets", value: "\(data.totalSets)")
                        statItem(title: "Sessions", value: "\(data.sessionCount)")
                        statItem(title: "Total Volume", value: formatVolume(data.totalVolume))
                        statItem(title: "Intensity", value: data.intensityLevel.label)
                    }

                    // Exercises list
                    if !data.exercises.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Exercises")
                                .font(.vitalH3)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                            ForEach(data.exercises, id: \.self) { exercise in
                                HStack {
                                    Image(systemName: "dumbbell.fill")
                                        .font(.system(size: Spacing.iconSmall))
                                        .foregroundStyle(Color.vitalPrimary)
                                    Text(exercise)
                                        .font(.vitalBody)
                                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                                    Spacer()
                                }
                                .padding(.vertical, Spacing.xs)
                            }
                        }
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle(data.muscleGroup.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            Text(value)
                .font(.vitalNumberSmall)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusMedium)
    }

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk kg", volume / 1000)
        }
        return String(format: "%.0f kg", volume)
    }
}

// MARK: - Identifiable Conformance

extension MuscleHeatMapData: @retroactive Equatable {
    static func == (lhs: MuscleHeatMapData, rhs: MuscleHeatMapData) -> Bool {
        lhs.muscleGroup == rhs.muscleGroup && lhs.totalSets == rhs.totalSets
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        MuscleHeatMapView(
            viewModel: MuscleHeatMapViewModel(
                workoutDataProvider: PreviewWorkoutRepository()
            )
        )
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
