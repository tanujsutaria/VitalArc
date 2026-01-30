//
//  MacroDetailSheet.swift
//  VitalArc
//
//  Drill-down sheet for viewing detailed macro nutrient history and trends
//

import SwiftUI
import Charts

struct MacroDetailSheet: View {
    let macroType: MacroType
    let currentValue: Double
    let goalValue: Double?
    let nutritionRepository: NutritionRepository

    @State private var historyData: [MacroHistoryData] = []
    @State private var isLoading = true
    @State private var hasAppeared = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Current value card
                    currentValueCard

                    // Weekly chart
                    if !historyData.isEmpty {
                        weeklyChartSection
                    }

                    // Summary statistics
                    if !historyData.isEmpty {
                        summaryStatsCard
                    }

                    // Goal progress if available
                    if let goal = goalValue, goal > 0 {
                        goalProgressCard(goal: goal)
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.vitalAdaptiveBackground)
            .navigationTitle(macroType.chartTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.vitalIconMedium)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }
            }
        }
        .task {
            await loadHistory()
            withAnimation(.vitalSpring.delay(0.2)) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Current Value Card

    private var currentValueCard: some View {
        VitalGradientCard(
            gradient: LinearGradient(
                colors: [macroColor, macroColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Image(systemName: macroType.icon)
                        .font(.vitalIconLargeSemibold)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Today")
                        .font(.vitalBodySmall)
                        .foregroundStyle(.white.opacity(0.9))

                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        Text(formatValue(currentValue))
                            .font(.vitalNumberLarge)
                            .foregroundStyle(.white)

                        Text(macroType.unit)
                            .font(.vitalBody)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }

                Spacer()

                if let goal = goalValue, goal > 0 {
                    VStack(alignment: .trailing, spacing: Spacing.xxs) {
                        Text("of \(formatValue(goal))")
                            .font(.vitalLabelSmall)
                            .foregroundStyle(.white.opacity(0.9))

                        let progress = min(currentValue / goal * 100, 100)
                        Text(String(format: "%.0f%%", progress))
                            .font(.vitalLabel)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .transition(.vitalScale)
        .opacity(hasAppeared ? 1 : 0)
    }

    // MARK: - Weekly Chart Section

    private var weeklyChartSection: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("7 Day Trend")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Chart(historyData) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [macroColor, macroColor.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(Spacing.radiusSmall)

                    if let goal = goalValue, goal > 0 {
                        RuleMark(y: .value("Goal", goal))
                            .foregroundStyle(Color.vitalSuccess.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text(formatAxisValue(val))
                                    .font(.vitalCaptionSmall)
                            }
                        }
                        AxisGridLine()
                    }
                }
                .frame(height: Spacing.chartHeightLarge)

                // Legend
                if goalValue != nil {
                    HStack(spacing: Spacing.lg) {
                        HStack(spacing: Spacing.xs) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(macroColor)
                                .frame(width: 12, height: 12)
                            Text("Daily Intake")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }

                        HStack(spacing: Spacing.xs) {
                            Rectangle()
                                .fill(Color.vitalSuccess.opacity(0.5))
                                .frame(width: 12, height: 2)
                            Text("Goal")
                                .font(.vitalCaptionSmall)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }

                        Spacer()
                    }
                }
            }
        }
        .transition(.vitalSlideUp)
        .opacity(hasAppeared ? 1 : 0)
    }

    // MARK: - Summary Stats Card

    private var summaryStatsCard: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Weekly Statistics")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                let values = historyData.map { $0.value }
                let avg = values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
                let min = values.min() ?? 0
                let max = values.max() ?? 0

                HStack(spacing: Spacing.lg) {
                    statItem(title: "Average", value: formatValue(avg), color: macroColor)

                    Divider().frame(height: Spacing.xl)

                    statItem(title: "Minimum", value: formatValue(min), color: .vitalAdaptiveTextSecondary)

                    Divider().frame(height: Spacing.xl)

                    statItem(title: "Maximum", value: formatValue(max), color: .vitalAdaptiveTextSecondary)

                    Spacer()
                }
            }
        }
        .transition(.vitalSlideUp)
        .opacity(hasAppeared ? 1 : 0)
    }

    // MARK: - Goal Progress Card

    private func goalProgressCard(goal: Double) -> some View {
        let progress = min(currentValue / goal, 1.0)
        let remaining = max(goal - currentValue, 0)

        return VitalCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Goal Progress")
                    .font(.vitalH3)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                            .fill(macroColor.opacity(0.2))

                        RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                            .fill(
                                LinearGradient(
                                    colors: [macroColor, macroColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress)
                            .animation(.vitalSpring, value: progress)
                    }
                }
                .frame(height: 12)

                HStack {
                    if remaining > 0 {
                        Text("\(formatValue(remaining)) \(macroType.unit) remaining")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    } else {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.vitalSuccess)
                            Text("Goal reached!")
                                .font(.vitalBody)
                                .foregroundStyle(Color.vitalSuccess)
                        }
                    }

                    Spacer()

                    Text(String(format: "%.0f%%", progress * 100))
                        .font(.vitalLabel)
                        .foregroundStyle(macroColor)
                }
            }
        }
        .transition(.vitalSlideUp)
        .opacity(hasAppeared ? 1 : 0)
    }

    // MARK: - Stat Item

    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xxs) {
                Text(value)
                    .font(.vitalLabel)
                    .foregroundStyle(color)
                Text(macroType.unit)
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }
    }

    // MARK: - Data Loading

    @MainActor
    private func loadHistory() async {
        isLoading = true

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var data: [MacroHistoryData] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            do {
                let nutrition = try await CalculateNutritionUseCase(repository: nutritionRepository).execute(for: date)

                let value: Double
                switch macroType {
                case .calories:
                    value = nutrition.caloriesConsumed
                case .protein:
                    value = nutrition.proteinConsumed
                case .carbs:
                    value = nutrition.carbsConsumed
                case .fat:
                    value = nutrition.fatConsumed
                }

                data.append(MacroHistoryData(date: date, value: value))
            } catch {
                // If no data for this day, use 0
                data.append(MacroHistoryData(date: date, value: 0))
            }
        }

        historyData = data
        isLoading = false
    }

    // MARK: - Helpers

    private var macroColor: Color {
        switch macroType.colorName {
        case "warning": return .vitalWarning
        case "danger": return .vitalDanger
        case "info": return .vitalInfo
        default: return .vitalPrimary
        }
    }

    private func formatValue(_ value: Double) -> String {
        if macroType == .calories {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: Int(value))) ?? "\(Int(value))"
        }
        return String(format: "%.0f", value)
    }

    private func formatAxisValue(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.0fk", value / 1000)
        }
        return String(format: "%.0f", value)
    }
}

// MARK: - Macro History Data

struct MacroHistoryData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Preview

#Preview {
    struct PreviewContainer: View {
        var body: some View {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    MacroDetailSheet(
                        macroType: .protein,
                        currentValue: 120,
                        goalValue: 150,
                        nutritionRepository: PreviewNutritionRepository()
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
        }
    }

    return PreviewContainer()
}

private struct PreviewNutritionRepository: NutritionRepository {
    func searchFoods(query: String) async throws -> [Food] { [] }
    func getFood(id: UUID) async throws -> Food? { nil }
    func saveFood(_ food: Food) async throws {}
    func getFoodEntries(for date: Date) async throws -> [FoodEntry] { [] }
    func getFoodEntries(from startDate: Date, to endDate: Date) async throws -> [FoodEntry] { [] }
    func saveFoodEntry(_ entry: FoodEntry) async throws {}
    func deleteFoodEntry(id: UUID) async throws {}
    func getDailyNutrition(for date: Date) async throws -> DailyNutrition? {
        DailyNutrition(
            date: date,
            caloriesConsumed: Double.random(in: 1800...2200),
            proteinConsumed: Double.random(in: 100...150),
            carbsConsumed: Double.random(in: 150...250),
            fatConsumed: Double.random(in: 50...80),
            calorieGoal: 2000,
            proteinGoal: 150,
            carbsGoal: 200,
            fatGoal: 70
        )
    }
    func saveDailyNutrition(_ nutrition: DailyNutrition) async throws {}
}
