//
//  NutritionTabContentView.swift
//  VitalArc
//
//  Main content view for the Nutrition tab - Unified log + summary view
//

import SwiftUI

struct NutritionTabContentView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var viewModel: NutritionTabViewModel?

    var body: some View {
        if let container = container {
            NavigationStack {
                Group {
                    if let viewModel = viewModel {
                        NutritionUnifiedView(viewModel: viewModel, container: container)
                    } else {
                        ProgressView()
                    }
                }
                .navigationTitle("Nutrition")
                .task {
                    // Guard against re-creating ViewModel on every view appearance
                    guard viewModel == nil else { return }

                    viewModel = NutritionTabViewModel(
                        nutritionRepository: container.nutritionRepository,
                        calculateTDEEUseCase: container.calculateTDEEUseCase,
                        userRepository: container.userRepository
                    )
                    await viewModel?.loadData()
                }
            }
        } else {
            ProgressView()
        }
    }
}

// MARK: - Unified Nutrition View

private struct NutritionUnifiedView: View {
    @Bindable var viewModel: NutritionTabViewModel
    let container: DependencyContainer
    @State private var showingFoodSearch = false
    @State private var selectedMeal: MealType = MealType.forCurrentTime()
    @State private var selectedFood: Food?
    @State private var showingQuantitySheet = false
    @State private var showingGoalEditSheet = false
    @State private var editingEntry: FoodEntry?
    @State private var bodyCompViewModel: BodyCompositionViewModel?

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Date Selector
                DateSelectorView(
                    selectedDate: $viewModel.selectedDate,
                    onPrevious: { viewModel.previousDay() },
                    onNext: { viewModel.nextDay() },
                    onToday: { viewModel.goToToday() }
                )

                // Always-visible Macro Summary
                if let nutrition = viewModel.dailyNutrition {
                    CompactMacroSummaryView(
                        nutrition: nutrition,
                        onEditGoals: { showingGoalEditSheet = true }
                    )
                } else if viewModel.isLoading {
                    MacroSummarySkeletonView()
                }

                // Water Tracking
                WaterTrackingCard(
                    logWaterUseCase: container.nutrition.logWaterUseCase,
                    getWaterEntriesUseCase: container.nutrition.getWaterEntriesUseCase,
                    deleteWaterEntryUseCase: container.nutrition.deleteWaterEntryUseCase,
                    date: viewModel.selectedDate,
                    dailyGoal: viewModel.dailyWaterGoal
                )

                // Body Composition & Settings
                NutritionQuickLinksRow(
                    bodyCompViewModel: $bodyCompViewModel,
                    container: container
                )

                // Meal Sections
                ForEach(MealType.allCases, id: \.self) { meal in
                    let entries = viewModel.foodEntries.filter { $0.meal == meal }
                    let totals = viewModel.mealTotals(for: meal)

                    MealSectionView(
                        meal: meal,
                        entries: entries,
                        totals: totals,
                        onAddFood: {
                            selectedMeal = meal
                            showingFoodSearch = true
                        },
                        onDeleteEntry: { entry in
                            Task {
                                await viewModel.deleteEntry(entry)
                            }
                        },
                        onEditEntry: { entry in
                            editingEntry = entry
                        },
                        onRelogEntry: { entry in
                            Task {
                                await viewModel.relogEntry(entry)
                            }
                        }
                    )
                }
            }
            .padding(Spacing.screenPadding)
        }
        .background(Color.vitalAdaptiveBackground)
        .onChange(of: viewModel.selectedDate) {
            Task {
                await viewModel.loadData()
            }
        }
        .sheet(isPresented: $showingFoodSearch) {
            FoodSearchView(
                searchFoodUseCase: SearchFoodUseCase(
                    repository: container.nutritionRepository,
                    api: USDAFoodAPI()
                ),
                repository: container.nutritionRepository,
                onFoodSelected: { food in
                    selectedFood = food
                    showingQuantitySheet = true
                }
            )
        }
        .onChange(of: showingFoodSearch) { _, isShowing in
            // Reset selected food when search sheet closes without selection
            if !isShowing && !showingQuantitySheet {
                selectedFood = nil
            }
        }
        .sheet(isPresented: $showingQuantitySheet) {
            if let food = selectedFood {
                QuantityInputView(
                    food: food,
                    meal: selectedMeal,
                    onLog: { quantity in
                        Task {
                            await viewModel.logFood(food, quantity: quantity, meal: selectedMeal)
                        }
                        showingQuantitySheet = false
                        selectedFood = nil
                    }
                )
            }
        }
        .onChange(of: showingQuantitySheet) { _, isShowing in
            // Reset selected food when quantity sheet closes and reload data
            if !isShowing {
                selectedFood = nil
                Task {
                    await viewModel.loadData()
                }
            }
        }
        .sheet(isPresented: $showingGoalEditSheet) {
            MacroGoalEditSheet(
                currentCalories: viewModel.dailyNutrition?.calorieGoal,
                currentProtein: viewModel.dailyNutrition?.proteinGoal,
                currentCarbs: viewModel.dailyNutrition?.carbsGoal,
                currentFat: viewModel.dailyNutrition?.fatGoal,
                tdeeResult: viewModel.tdeeResult,
                onSave: { calories, protein, carbs, fat in
                    await viewModel.updateGoals(
                        calories: calories,
                        protein: protein,
                        carbs: carbs,
                        fat: fat
                    )
                }
            )
        }
        .onChange(of: showingGoalEditSheet) { _, isShowing in
            // Reload data when goal edit sheet closes to reflect updated goals
            if !isShowing {
                Task {
                    await viewModel.loadData()
                }
            }
        }
        .sheet(item: $editingEntry) { entry in
            EditQuantitySheet(entry: entry) { newQuantity in
                Task {
                    await viewModel.updateEntry(entry, newQuantity: newQuantity)
                }
            }
        }
    }
}

// MARK: - Compact Macro Summary

private struct CompactMacroSummaryView: View {
    let nutrition: DailyNutrition
    let onEditGoals: () -> Void

    var body: some View {
        VitalCard {
            VStack(spacing: Spacing.md) {
                // Calorie Progress with Edit Button
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Calories")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                            Text("\(Int(nutrition.caloriesConsumed))")
                                .font(.vitalH2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            if let goal = nutrition.calorieGoal {
                                Text("/ \(Int(goal))")
                                    .font(.vitalBody)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                        }
                    }

                    Spacer()

                    // Edit goals button
                    Button {
                        onEditGoals()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.vitalIconMedium)
                            .foregroundStyle(Color.vitalPrimary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Edit nutrition goals")
                    .accessibilityHint("Double tap to adjust calorie and macro targets")

                    if let goal = nutrition.calorieGoal, goal > 0 {
                        let progress = min(nutrition.caloriesConsumed / goal, 1.0)
                        CalorieCircleView(
                            progress: progress,
                            color: progress > 1.0 ? Color.vitalDanger : Color.vitalPrimary,
                            lineWidth: 6
                        )
                        .frame(width: Spacing.frameMedium, height: Spacing.frameMedium)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Calorie progress")
                        .accessibilityValue("\(Int(progress * 100)) percent of goal")
                    }
                }

                Divider()
                    .background(Color.vitalAdaptiveBorder)

                // Macro bars
                HStack(spacing: Spacing.lg) {
                    MacroBarView(
                        name: "Protein",
                        consumed: nutrition.proteinConsumed,
                        goal: nutrition.proteinGoal,
                        color: .vitalDanger,
                        unit: "g"
                    )

                    MacroBarView(
                        name: "Carbs",
                        consumed: nutrition.carbsConsumed,
                        goal: nutrition.carbsGoal,
                        color: .vitalInfo,
                        unit: "g"
                    )

                    MacroBarView(
                        name: "Fat",
                        consumed: nutrition.fatConsumed,
                        goal: nutrition.fatGoal,
                        color: .vitalWarning,
                        unit: "g"
                    )
                }

                // Micronutrient bars (fiber/sugar)
                if nutrition.fiberConsumed > 0 || nutrition.sugarConsumed > 0 {
                    HStack(spacing: Spacing.lg) {
                        MacroBarView(
                            name: "Fiber",
                            consumed: nutrition.fiberConsumed,
                            goal: nutrition.fiberGoal,
                            color: .vitalSuccess,
                            unit: "g"
                        )

                        MacroBarView(
                            name: "Sugar",
                            consumed: nutrition.sugarConsumed,
                            goal: nutrition.sugarGoal,
                            color: .vitalPrimary,
                            unit: "g"
                        )

                        // Spacer to balance 2 items against 3 above
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Macro Bar View

private struct MacroBarView: View {
    let name: String
    let consumed: Double
    let goal: Double?
    let color: Color
    let unit: String

    private var progress: Double {
        guard let goal = goal, goal > 0 else { return 0 }
        return min(consumed / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(name)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.vitalAdaptiveBorder)
                        .cornerRadius(Spacing.radiusSmall)

                    Rectangle()
                        .fill(color)
                        .cornerRadius(Spacing.radiusSmall)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: Spacing.progressBarHeight)

            HStack(spacing: 2) {
                Text("\(Int(consumed))")
                    .font(.vitalCaptionSmall)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                if let goal = goal {
                    Text("/\(Int(goal))\(unit)")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(name)
        .accessibilityValue("\(Int(consumed))\(goal.map { " of \(Int($0))" } ?? "") \(unit)")
    }
}

// MARK: - Calorie Circle View

private struct CalorieCircleView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.vitalAdaptiveBorder, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.vitalCaptionSmall)
                .fontWeight(.semibold)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
        }
    }
}

// MARK: - Macro Summary Skeleton

private struct MacroSummarySkeletonView: View {
    var body: some View {
        VitalCard {
            VStack(spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Rectangle()
                            .fill(Color.vitalAdaptiveBorder)
                            .frame(width: Spacing.iconGiant, height: Spacing.iconXSmall)
                            .cornerRadius(Spacing.radiusSmall)
                        Rectangle()
                            .fill(Color.vitalAdaptiveBorder)
                            .frame(width: Spacing.illustrationMedium, height: Spacing.lg)
                            .cornerRadius(Spacing.radiusSmall)
                    }
                    Spacer()
                    Circle()
                        .fill(Color.vitalAdaptiveBorder)
                        .frame(width: Spacing.frameMedium, height: Spacing.frameMedium)
                }

                Divider()
                    .background(Color.vitalAdaptiveBorder)

                HStack(spacing: Spacing.lg) {
                    ForEach(0..<3, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Rectangle()
                                .fill(Color.vitalAdaptiveBorder)
                                .frame(width: Spacing.avatarSmall, height: Spacing.iconTiny)
                                .cornerRadius(Spacing.radiusSmall)
                            Rectangle()
                                .fill(Color.vitalAdaptiveBorder)
                                .frame(height: Spacing.progressBarHeight)
                                .cornerRadius(Spacing.radiusSmall)
                            Rectangle()
                                .fill(Color.vitalAdaptiveBorder)
                                .frame(width: 50, height: 10)
                                .cornerRadius(Spacing.radiusSmall)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .shimmer()
    }
}

// MARK: - View Model

@MainActor
@Observable
final class NutritionTabViewModel {
    private let nutritionRepository: NutritionRepository
    private let getFoodEntriesUseCase: GetFoodEntriesUseCase
    private let deleteFoodEntryUseCase: DeleteFoodEntryUseCase
    private let calculateTDEEUseCase: CalculateTDEEUseCase?
    private let userRepository: UserRepository?

    var selectedDate: Date = Date()
    var foodEntries: [FoodEntry] = []
    var dailyNutrition: DailyNutrition?
    var tdeeResult: TDEEResult?
    var dailyWaterGoal: Double = 2500
    var isLoading = false
    var error: Error?

    /// Tracks whether TDEE-based goals have been loaded to avoid overwriting on date changes
    private var hasLoadedTDEEGoals = false

    /// Task handle for cancelling in-flight loadData calls
    private var loadTask: Task<Void, Never>?

    init(
        nutritionRepository: NutritionRepository,
        calculateTDEEUseCase: CalculateTDEEUseCase? = nil,
        userRepository: UserRepository? = nil
    ) {
        self.nutritionRepository = nutritionRepository
        self.getFoodEntriesUseCase = GetFoodEntriesUseCase(repository: nutritionRepository)
        self.deleteFoodEntryUseCase = DeleteFoodEntryUseCase(repository: nutritionRepository)
        self.calculateTDEEUseCase = calculateTDEEUseCase
        self.userRepository = userRepository
    }

    func loadData() async {
        // Cancel any in-flight load to prevent race conditions from rapid date changes
        loadTask?.cancel()

        loadTask = Task {
            isLoading = true
            defer { isLoading = false }

            do {
                // Load user profile for water goal
                if let profile = try? await userRepository?.getUserProfile() {
                    dailyWaterGoal = profile.effectiveWaterGoal
                }

                // Load food entries for selected date using use case
                let entries = try await getFoodEntriesUseCase.execute(for: selectedDate)

                // Check for cancellation before updating state
                guard !Task.isCancelled else { return }
                foodEntries = entries

                // Calculate daily nutrition
                let calculateUseCase = CalculateNutritionUseCase(repository: nutritionRepository)
                var nutrition = try await calculateUseCase.execute(for: selectedDate)

                // Check for cancellation before updating state
                guard !Task.isCancelled else { return }

                // If TDEE use case is available, calculate TDEE-based goals
                // Only apply TDEE goals on initial load to avoid overwriting user's manual settings on date change
                if let tdeeUseCase = calculateTDEEUseCase, !hasLoadedTDEEGoals {
                    if let result = try await tdeeUseCase.execute() {
                        guard !Task.isCancelled else { return }
                        tdeeResult = result
                        hasLoadedTDEEGoals = true

                        // If nutrition goals are not set, use TDEE-derived goals
                        if nutrition.calorieGoal == nil || nutrition.proteinGoal == nil {
                            nutrition = DailyNutrition(
                                id: nutrition.id,
                                date: nutrition.date,
                                caloriesConsumed: nutrition.caloriesConsumed,
                                proteinConsumed: nutrition.proteinConsumed,
                                carbsConsumed: nutrition.carbsConsumed,
                                fatConsumed: nutrition.fatConsumed,
                                fiberConsumed: nutrition.fiberConsumed,
                                sugarConsumed: nutrition.sugarConsumed,
                                calorieGoal: nutrition.calorieGoal ?? result.adjustedCalories,
                                proteinGoal: nutrition.proteinGoal ?? result.proteinGoal,
                                carbsGoal: nutrition.carbsGoal ?? result.carbGoal,
                                fatGoal: nutrition.fatGoal ?? result.fatGoal,
                                fiberGoal: nutrition.fiberGoal,
                                sugarGoal: nutrition.sugarGoal
                            )
                        }
                    }
                }

                guard !Task.isCancelled else { return }
                dailyNutrition = nutrition
            } catch {
                guard !Task.isCancelled else { return }
                self.error = error
                Log.error("Failed to load nutrition data", error: error, category: .nutrition)
            }
        }

        // Wait for task to complete
        await loadTask?.value
    }

    func logFood(_ food: Food, quantity: Double, meal: MealType) async {
        do {
            let logUseCase = LogFoodUseCase(repository: nutritionRepository)
            try await logUseCase.execute(food: food, quantity: quantity, meal: meal, date: selectedDate)
            await loadData()
        } catch {
            self.error = error
            Log.error("Failed to log food", error: error, category: .nutrition)
        }
    }

    func deleteEntry(_ entry: FoodEntry) async {
        do {
            try await deleteFoodEntryUseCase.execute(id: entry.id)
            await loadData()
        } catch {
            self.error = error
            Log.error("Failed to delete entry", error: error, category: .nutrition)
        }
    }

    func updateEntry(_ entry: FoodEntry, newQuantity: Double) async {
        do {
            let updateUseCase = UpdateFoodEntryUseCase(repository: nutritionRepository)
            let updatedEntry = try await updateUseCase.execute(entry: entry, newQuantity: newQuantity)

            // Immediately update the local entry for instant UI feedback
            if let index = foodEntries.firstIndex(where: { $0.id == entry.id }) {
                foodEntries[index] = updatedEntry
            }

            // Recalculate daily nutrition totals immediately
            let calculateUseCase = CalculateNutritionUseCase(repository: nutritionRepository)
            dailyNutrition = try await calculateUseCase.execute(for: selectedDate)
        } catch {
            self.error = error
            Log.error("Failed to update entry", error: error, category: .nutrition)
        }
    }

    func relogEntry(_ entry: FoodEntry) async {
        do {
            // Look up the food to get current nutritional data, preserving original quantity
            if let food = try await nutritionRepository.getFood(id: entry.foodId) {
                // Use LogFoodUseCase to properly scale macros from current food data,
                // update daily nutrition totals, and track food usage
                let logUseCase = LogFoodUseCase(repository: nutritionRepository)
                _ = try await logUseCase.execute(
                    food: food,
                    quantity: entry.quantity,
                    meal: entry.meal,
                    date: selectedDate
                )
            } else {
                // Food no longer in DB; fall back to stored macro data
                let newEntry = FoodEntry(
                    foodId: entry.foodId,
                    date: selectedDate,
                    meal: entry.meal,
                    quantity: entry.quantity,
                    calories: entry.calories,
                    protein: entry.protein,
                    carbs: entry.carbs,
                    fat: entry.fat,
                    fiber: entry.fiber,
                    sugar: entry.sugar
                )
                try await nutritionRepository.saveFoodEntry(newEntry)
            }
            await loadData()
        } catch {
            self.error = error
            Log.error("Failed to re-log entry", error: error, category: .nutrition)
        }
    }

    func mealTotals(for meal: MealType) -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        let entries = foodEntries.filter { $0.meal == meal }
        return (
            calories: entries.reduce(0) { $0 + $1.calories },
            protein: entries.reduce(0) { $0 + $1.protein },
            carbs: entries.reduce(0) { $0 + $1.carbs },
            fat: entries.reduce(0) { $0 + $1.fat }
        )
    }

    func previousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }

    func nextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }

    func goToToday() {
        selectedDate = Date()
    }

    /// Update macro goals for the current date
    func updateGoals(calories: Double?, protein: Double?, carbs: Double?, fat: Double?) async {
        guard let currentNutrition = dailyNutrition else { return }

        let updatedNutrition = DailyNutrition(
            id: currentNutrition.id,
            date: currentNutrition.date,
            caloriesConsumed: currentNutrition.caloriesConsumed,
            proteinConsumed: currentNutrition.proteinConsumed,
            carbsConsumed: currentNutrition.carbsConsumed,
            fatConsumed: currentNutrition.fatConsumed,
            fiberConsumed: currentNutrition.fiberConsumed,
            sugarConsumed: currentNutrition.sugarConsumed,
            calorieGoal: calories ?? currentNutrition.calorieGoal,
            proteinGoal: protein ?? currentNutrition.proteinGoal,
            carbsGoal: carbs ?? currentNutrition.carbsGoal,
            fatGoal: fat ?? currentNutrition.fatGoal,
            fiberGoal: currentNutrition.fiberGoal,
            sugarGoal: currentNutrition.sugarGoal
        )

        do {
            // Save the updated nutrition with new goals
            let calculateUseCase = CalculateNutritionUseCase(repository: nutritionRepository)
            try await calculateUseCase.updateGoals(
                for: selectedDate,
                calorieGoal: calories,
                proteinGoal: protein,
                carbsGoal: carbs,
                fatGoal: fat
            )

            dailyNutrition = updatedNutrition
        } catch {
            self.error = error
            Log.error("Failed to update goals", error: error, category: .nutrition)
        }
    }
}

// MARK: - Nutrition Quick Links Row

private struct NutritionQuickLinksRow: View {
    @Binding var bodyCompViewModel: BodyCompositionViewModel?
    let container: DependencyContainer

    var body: some View {
        HStack(spacing: Spacing.md) {
            NavigationLink {
                if let vm = bodyCompViewModel {
                    BodyCompositionView(viewModel: vm)
                } else {
                    ProgressView()
                }
            } label: {
                QuickLinkCard(
                    icon: "figure.arms.open",
                    title: "Body Comp",
                    color: .vitalPrimary
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                MealTimeSettingsView()
            } label: {
                QuickLinkCard(
                    icon: "clock.fill",
                    title: "Meal Times",
                    color: .vitalInfo
                )
            }
            .buttonStyle(.plain)
        }
        .task {
            if bodyCompViewModel == nil {
                bodyCompViewModel = BodyCompositionViewModel(
                    saveUseCase: container.nutrition.saveBodyCompositionEntryUseCase,
                    getUseCase: container.nutrition.getBodyCompositionEntriesUseCase,
                    repository: container.nutrition.bodyMeasurementRepository
                )
            }
        }
    }
}

// MARK: - Quick Link Card

private struct QuickLinkCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VitalCard {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: Spacing.iconMedium))
                    .foregroundStyle(color)
                Text(title)
                    .font(.vitalBody)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: Spacing.iconXSmall))
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
        }
    }
}

#Preview {
    NutritionTabContentView()
}
