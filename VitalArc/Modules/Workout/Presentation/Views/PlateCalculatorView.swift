//
//  PlateCalculatorView.swift
//  VitalArc
//
//  Plate calculator showing which plates to load on each side of a barbell
//

import SwiftUI

struct PlateCalculatorView: View {
    @State private var viewModel = PlateCalculatorViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Input Section
                inputSection

                // Barbell Diagram
                barbellDiagram

                // Plate Breakdown
                plateBreakdown

                // Quick Presets
                presetButtons
            }
            .padding(Spacing.screenPadding)
        }
        .background(Color.vitalAdaptiveBackground)
        .navigationTitle("Plate Calculator")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VitalCard {
            VStack(spacing: Spacing.md) {
                // Unit Toggle
                HStack {
                    Text("Units")
                        .font(.vitalLabel)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    Spacer()
                    Button {
                        viewModel.toggleUnits()
                    } label: {
                        Text(viewModel.useImperial ? "lbs" : "kg")
                            .font(.vitalLabel)
                            .fontWeight(.semibold)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.vitalPrimary.opacity(0.1))
                            .foregroundStyle(Color.vitalPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                    }
                    .buttonStyle(.plain)
                }

                Divider()

                // Target Weight
                HStack {
                    Text("Target Weight")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    Spacer()
                    TextField("0", value: $viewModel.targetWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: Spacing.illustrationSmall)
                        .multilineTextAlignment(.trailing)
                    Text(viewModel.weightUnit)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                // Bar Weight
                HStack {
                    Text("Bar Weight")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    Spacer()
                    TextField("0", value: $viewModel.barWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: Spacing.illustrationSmall)
                        .multilineTextAlignment(.trailing)
                    Text(viewModel.weightUnit)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
    }

    // MARK: - Barbell Diagram

    private var barbellDiagram: some View {
        VitalCard {
            VStack(spacing: Spacing.md) {
                Text("Per Side")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                if viewModel.platesPerSide.isEmpty {
                    Text("Bar only")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .padding(.vertical, Spacing.lg)
                } else {
                    // Visual plate stack
                    HStack(spacing: Spacing.xs) {
                        // Bar sleeve
                        RoundedRectangle(cornerRadius: Spacing.xxs)
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: Spacing.xl, height: Spacing.sm)

                        // Plates (largest to smallest, left to right = closest to collar)
                        ForEach(Array(viewModel.platesPerSide.enumerated()), id: \.offset) { _, plateKg in
                            let color = PlateCalculatorViewModel.plateColor(weightKg: plateKg)
                            plateView(weightKg: plateKg, color: color)
                        }

                        // Collar
                        RoundedRectangle(cornerRadius: Spacing.xxs)
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: Spacing.sm, height: Spacing.xl)
                    }
                    .padding(.vertical, Spacing.sm)
                }

                // Weight summary
                HStack(spacing: Spacing.lg) {
                    VStack(spacing: Spacing.xxs) {
                        Text("Per Side")
                            .font(.vitalCaptionSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        Text("\(viewModel.weightPerSide, specifier: "%.1f") \(viewModel.weightUnit)")
                            .font(.vitalH4)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    }

                    Divider()
                        .frame(height: Spacing.avatarSmall)

                    VStack(spacing: Spacing.xxs) {
                        Text("Total")
                            .font(.vitalCaptionSmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        Text("\(viewModel.actualWeight, specifier: "%.1f") \(viewModel.weightUnit)")
                            .font(.vitalH4)
                            .foregroundStyle(Color.vitalPrimary)
                    }
                }

                if !viewModel.isAchievable && viewModel.targetWeight > viewModel.barWeight {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.vitalCaption)
                        Text("Exact weight not achievable with standard plates")
                            .font(.vitalCaption)
                    }
                    .foregroundStyle(Color.vitalWarning)
                }
            }
        }
    }

    // MARK: - Plate View

    private func plateView(weightKg: Double, color: PlateCalculatorViewModel.PlateColor) -> some View {
        let height: CGFloat = plateHeight(for: weightKg)
        let swiftUIColor = swiftColor(for: color)

        return VStack(spacing: Spacing.xxs) {
            RoundedRectangle(cornerRadius: Spacing.xxs)
                .fill(swiftUIColor)
                .frame(width: Spacing.md, height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.xxs)
                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                )
            Text(formatPlateWeight(weightKg))
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
    }

    private func plateHeight(for weightKg: Double) -> CGFloat {
        switch weightKg {
        case 25: return 80
        case 20: return 72
        case 15: return 64
        case 10: return 56
        case 5: return 48
        case 2.5: return 40
        case 1.25: return 32
        default: return 40
        }
    }

    private func swiftColor(for plateColor: PlateCalculatorViewModel.PlateColor) -> Color {
        switch plateColor {
        case .red: return .red
        case .blue: return .blue
        case .yellow: return .yellow
        case .green: return .green
        case .white: return Color(.systemGray5)
        case .black: return Color(.systemGray2)
        case .silver: return Color(.systemGray4)
        case .gray: return .gray
        }
    }

    private func formatPlateWeight(_ kg: Double) -> String {
        if viewModel.useImperial {
            let lbs = UnitConversion.kgToLbs(kg)
            return String(format: "%.1f", lbs)
        }
        if kg == kg.rounded() {
            return "\(Int(kg))"
        }
        return String(format: "%.2g", kg)
    }

    // MARK: - Plate Breakdown

    private var plateBreakdown: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Plate Breakdown")
                    .font(.vitalLabel)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                if viewModel.platesPerSide.isEmpty {
                    Text("No plates needed")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                } else {
                    // Group plates by weight
                    let grouped = Dictionary(grouping: viewModel.platesPerSide) { $0 }
                    let sortedWeights = grouped.keys.sorted(by: >)

                    ForEach(sortedWeights, id: \.self) { weight in
                        let count = grouped[weight]?.count ?? 0
                        HStack {
                            Circle()
                                .fill(swiftColor(for: PlateCalculatorViewModel.plateColor(weightKg: weight)))
                                .frame(width: Spacing.iconSmall, height: Spacing.iconSmall)

                            Text(formatPlateWeight(weight))
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                            Text(viewModel.weightUnit)
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                            Spacer()

                            Text("\(count) \(count == 1 ? "plate" : "plates") per side")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                        .padding(.vertical, Spacing.xs)
                    }
                }
            }
        }
    }

    // MARK: - Preset Buttons

    private var presetButtons: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Quick Presets")
                .font(.vitalLabel)
                .fontWeight(.semibold)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            let presets: [(String, Double)] = [
                ("60 kg", 60),
                ("80 kg", 80),
                ("100 kg", 100),
                ("120 kg", 120),
                ("140 kg", 140),
                ("160 kg", 160),
            ]

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.sm) {
                ForEach(presets, id: \.1) { label, weight in
                    Button {
                        viewModel.setPreset(targetKg: weight)
                    } label: {
                        Text(label)
                            .font(.vitalCaption)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.vitalPrimary.opacity(0.1))
                            .foregroundStyle(Color.vitalPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlateCalculatorView()
    }
}
