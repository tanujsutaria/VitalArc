//
//  ProfileView.swift
//  VitalArc
//
//  User profile view displaying profile information and settings
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var viewModel: ProfileViewModel?
    @State private var showSettings = false
    @State private var showAbout = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    if viewModel.isEditMode {
                        editProfileView(viewModel: viewModel)
                    } else {
                        profileContentView(viewModel: viewModel)
                    }
                } else {
                    ProgressView("Loading profile...")
                        .onAppear {
                            setupViewModel()
                        }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                if let viewModel = viewModel, !viewModel.isEditMode {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { viewModel.startEditing() }) {
                            Text("Edit")
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                if let container = container {
                    SettingsView(
                        userRepository: container.userRepository,
                        healthRepository: container.healthRepository
                    )
                }
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }

    @ViewBuilder
    private func profileContentView(viewModel: ProfileViewModel) -> some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                if let profile = viewModel.profile {
                    // Profile Header
                    VStack(spacing: Spacing.md) {
                        // Avatar with gradient border
                        ZStack {
                            Circle()
                                .fill(Color.vitalPrimaryGradient)
                                .frame(width: Spacing.avatarXLargeOuter, height: Spacing.avatarXLargeOuter)

                            Circle()
                                .fill(Color.vitalAdaptiveSurface)
                                .frame(width: Spacing.avatarXLargeBorder, height: Spacing.avatarXLargeBorder)

                            Circle()
                                .fill(Color.vitalPrimaryGradient)
                                .frame(width: Spacing.avatarXLarge, height: Spacing.avatarXLarge)
                                .overlay {
                                    Text(profile.name.prefix(1).uppercased())
                                        .font(.vitalDisplayLarge)
                                        .foregroundColor(.vitalTextOnPrimary)
                                }
                        }
                        .vitalElevatedShadow()

                        Text(profile.name)
                            .font(.vitalDisplayMedium)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        Text("\(profile.age) years old")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                    .padding(.top, Spacing.lg)

                    // Stats Section
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Health Stats")
                            .font(.vitalH2)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            .padding(.horizontal, Spacing.screenPadding)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: Spacing.md) {
                            StatCard(
                                title: "Height",
                                value: viewModel.displayHeight,
                                icon: "ruler",
                                color: .vitalInfo
                            )

                            StatCardWithSource(
                                title: "Weight",
                                value: viewModel.displayWeight,
                                icon: "scalemass",
                                color: .vitalSuccess,
                                source: viewModel.weightSource
                            )

                            StatCard(
                                title: "BMI",
                                value: String(format: "%.1f", profile.bmi),
                                icon: "chart.bar",
                                color: .vitalWarning
                            )

                            StatCard(
                                title: "Calorie Goal",
                                value: String(format: "%.0f", viewModel.tdeeResult?.adjustedCalories ?? profile.estimatedCalorieGoal),
                                icon: "flame",
                                color: .vitalDanger
                            )
                        }
                        .padding(.horizontal, Spacing.screenPadding)

                        // TDEE Breakdown
                        if let tdee = viewModel.tdeeResult {
                            VitalCard {
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    Text("TDEE Breakdown")
                                        .font(.vitalLabel)
                                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                                    HStack(spacing: Spacing.lg) {
                                        VStack(spacing: Spacing.xs) {
                                            Text(String(format: "%.0f", tdee.bmr))
                                                .font(.vitalNumberSmall)
                                                .foregroundStyle(Color.vitalInfo)
                                            Text("BMR")
                                                .font(.vitalCaptionSmall)
                                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                        }

                                        Image(systemName: "multiply")
                                            .font(.vitalCaption)
                                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                                        VStack(spacing: Spacing.xs) {
                                            Text(String(format: "%.2f", tdee.activityMultiplier))
                                                .font(.vitalNumberSmall)
                                                .foregroundStyle(Color.vitalWarning)
                                            Text("Activity")
                                                .font(.vitalCaptionSmall)
                                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                        }

                                        Image(systemName: "equal")
                                            .font(.vitalCaption)
                                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                                        VStack(spacing: Spacing.xs) {
                                            Text(String(format: "%.0f", tdee.adjustedCalories))
                                                .font(.vitalNumberSmall)
                                                .foregroundStyle(Color.vitalSuccess)
                                            Text("Goal")
                                                .font(.vitalCaptionSmall)
                                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                        }
                                    }

                                    Divider()

                                    // Macro goals
                                    HStack(spacing: Spacing.lg) {
                                        MacroGoalItem(label: "Protein", value: tdee.proteinGoal, unit: "g", color: .vitalDanger)
                                        MacroGoalItem(label: "Carbs", value: tdee.carbGoal, unit: "g", color: .vitalInfo)
                                        MacroGoalItem(label: "Fat", value: tdee.fatGoal, unit: "g", color: .vitalWarning)
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.screenPadding)
                        }

                        // HealthKit Sync Status
                        if viewModel.isHealthKitAvailable {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(Color.vitalDanger)
                                    .font(.caption)
                                Text("Synced with Apple Health")
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                Spacer()
                                Button {
                                    Task { await viewModel.syncFromHealthKit() }
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.caption)
                                        .foregroundStyle(Color.vitalPrimary)
                                }
                            }
                            .padding(.horizontal, Spacing.screenPadding)
                        }
                    }

                    // Heart Rate Settings Section
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Heart Rate")
                            .font(.vitalH2)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            .padding(.horizontal, Spacing.screenPadding)

                        VitalCard {
                            VStack(spacing: Spacing.sm) {
                                InfoRow(label: "Max HR", value: viewModel.displayHRMax)
                                Divider()
                                InfoRow(label: "Resting HR", value: viewModel.displayHRResting)
                            }
                        }
                        .padding(.horizontal, Spacing.screenPadding)

                        Text("Custom values improve strain calculation accuracy")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextTertiary)
                            .padding(.horizontal, Spacing.screenPadding)
                    }

                    // Goals Section
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Goals")
                            .font(.vitalH2)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            .padding(.horizontal, Spacing.screenPadding)

                        VitalCard {
                            VStack(spacing: Spacing.sm) {
                                InfoRow(label: "Activity Level", value: profile.activityLevel.rawValue)
                                Divider()
                                InfoRow(label: "Weight Goal", value: profile.weightGoal.rawValue)
                                Divider()
                                InfoRow(label: "Biological Sex", value: profile.biologicalSex.rawValue)
                            }
                        }
                        .padding(.horizontal, Spacing.screenPadding)
                    }

                    // Settings Section
                    VStack(spacing: Spacing.md) {
                        Button(action: {
                            HapticFeedback.light()
                            showSettings = true
                        }) {
                            HStack(spacing: Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(Color.vitalPrimary.opacity(0.15))
                                        .frame(width: Spacing.avatarSmall, height: Spacing.avatarSmall)

                                    Image(systemName: "gear")
                                        .font(.vitalIconMediumSemibold)
                                        .foregroundStyle(Color.vitalPrimary)
                                }

                                Text("Settings")
                                    .font(.vitalLabel)
                                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.vitalIconXSmallSemibold)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                            .padding(Spacing.md)
                            .background(Color.vitalAdaptiveSurface)
                            .cornerRadius(Spacing.radiusMedium)
                            .vitalCardShadow()
                        }
                        .vitalScaleButton()

                        Button(action: {
                            HapticFeedback.light()
                            showAbout = true
                        }) {
                            HStack(spacing: Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(Color.vitalInfo.opacity(0.15))
                                        .frame(width: Spacing.avatarSmall, height: Spacing.avatarSmall)

                                    Image(systemName: "info.circle")
                                        .font(.vitalIconMediumSemibold)
                                        .foregroundStyle(Color.vitalInfo)
                                }

                                Text("About")
                                    .font(.vitalLabel)
                                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.vitalIconXSmallSemibold)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                            .padding(Spacing.md)
                            .background(Color.vitalAdaptiveSurface)
                            .cornerRadius(Spacing.radiusMedium)
                            .vitalCardShadow()
                        }
                        .vitalScaleButton()
                    }
                    .padding(.horizontal, Spacing.screenPadding)
                } else {
                    ContentUnavailableView(
                        "No Profile Found",
                        systemImage: "person.crop.circle.badge.exclamationmark",
                        description: Text("Please complete onboarding to create your profile.")
                    )
                }
            }
            .padding(.bottom)
        }
        .refreshable {
            await viewModel.loadProfile()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    @ViewBuilder
    private func editProfileView(viewModel: ProfileViewModel) -> some View {
        @Bindable var vm = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text("Edit Profile")
                    .font(.vitalH2)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Name
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Name")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        TextField("Name", text: $vm.editName)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Birth Date
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Birth Date")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        DatePicker(
                            "Birth Date",
                            selection: $vm.editBirthDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }

                    // Biological Sex
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Biological Sex")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        Picker("Sex", selection: $vm.editSex) {
                            ForEach(BiologicalSex.allCases, id: \.self) { sex in
                                Text(sex.rawValue).tag(sex)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Height (American units)
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Height")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        HStack(spacing: Spacing.md) {
                            HStack {
                                Picker("Feet", selection: $vm.editHeightFeet) {
                                    ForEach(4...7, id: \.self) { feet in
                                        Text("\(feet)").tag(feet)
                                    }
                                }
                                .pickerStyle(.menu)
                                Text("ft")
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }

                            HStack {
                                Picker("Inches", selection: $vm.editHeightInches) {
                                    ForEach(0...11, id: \.self) { inches in
                                        Text("\(inches)").tag(inches)
                                    }
                                }
                                .pickerStyle(.menu)
                                Text("in")
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                        }
                    }

                    // Weight (American units with HealthKit indicator)
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Text("Weight")
                                .font(.vitalH3)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                            Spacer()
                            if vm.healthKitWeight != nil {
                                Toggle("Manual override", isOn: $vm.useManualWeight)
                                    .labelsHidden()
                                    .scaleEffect(0.8)
                            }
                        }

                        if vm.healthKitWeight != nil && !vm.useManualWeight {
                            // Show HealthKit weight (read-only)
                            HStack {
                                Text(String(format: "%.1f lbs", UnitConversion.kgToLbs(vm.healthKitWeight!)))
                                    .font(.vitalH2)
                                Spacer()
                                HStack(spacing: Spacing.xs) {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(Color.vitalDanger)
                                        .font(.vitalCaption)
                                    Text("from Apple Health")
                                        .font(.vitalCaption)
                                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                }
                            }
                            .padding(Spacing.lg)
                            .background(Color.vitalAdaptiveSurface)
                            .cornerRadius(Spacing.radiusSmall)
                        } else {
                            // Manual weight entry
                            HStack {
                                TextField("Weight", value: $vm.editWeightLbs, format: .number)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                Text("lbs")
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                        }
                    }

                    // Activity Level
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Activity Level")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        Picker("Activity Level", selection: $vm.editActivityLevel) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    // Weight Goal
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Weight Goal")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        Picker("Weight Goal", selection: $vm.editWeightGoal) {
                            ForEach(WeightGoal.allCases, id: \.self) { goal in
                                Text(goal.rawValue).tag(goal)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Custom Heart Rate Settings
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Heart Rate (Optional)")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        Text("Leave blank to use estimated values")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                        HStack(spacing: Spacing.lg) {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Max HR")
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                HStack {
                                    TextField("Auto", text: $vm.editCustomHRMax)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 80)
                                    Text("bpm")
                                        .font(.vitalCaption)
                                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                }
                            }

                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Resting HR")
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                HStack {
                                    TextField("Auto", text: $vm.editCustomHRResting)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 80)
                                    Text("bpm")
                                        .font(.vitalCaption)
                                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Action Buttons
                HStack(spacing: Spacing.lg) {
                    Button(action: { viewModel.cancelEditing() }) {
                        Text("Cancel")
                            .font(.vitalH3)
                            .foregroundColor(Color.vitalDanger)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.lg)
                            .background(Color.vitalAdaptiveSurface)
                            .cornerRadius(Spacing.radiusMedium)
                    }

                    Button(action: {
                        Task {
                            await viewModel.saveProfile()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Save")
                            }
                        }
                        .font(.vitalH3)
                        .foregroundColor(.vitalTextOnPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.lg)
                        .background(viewModel.canSave ? Color.vitalPrimary : Color.vitalAdaptiveTextSecondary)
                        .cornerRadius(Spacing.radiusMedium)
                    }
                    .disabled(!viewModel.canSave || viewModel.isLoading)
                }
                .padding(.horizontal)
                .padding(.top, Spacing.sm)
            }
            .padding(.vertical)
        }
    }

    private func setupViewModel() {
        guard let container = container else { return }
        let vm = ProfileViewModel(
            userRepository: container.userRepository,
            healthRepository: container.healthRepository,
            calculateTDEEUseCase: container.calculateTDEEUseCase
        )
        viewModel = vm
        Task {
            await vm.loadProfile()
        }
    }
}

// MARK: - Macro Goal Item

struct MacroGoalItem: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack(spacing: 2) {
                Text(String(format: "%.0f", value))
                    .font(.vitalLabel)
                    .foregroundStyle(color)
                Text(unit)
                    .font(.vitalCaptionSmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
            Text(label)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VitalCard {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: Spacing.avatarMedium, height: Spacing.avatarMedium)

                    Image(systemName: icon)
                        .font(.vitalIconMediumSemibold)
                        .foregroundStyle(color)
                }

                Text(value)
                    .font(.vitalNumberMedium)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Text(title)
                    .font(.vitalBodySmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct StatCardWithSource: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let source: String

    var body: some View {
        VitalCard {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: Spacing.avatarMedium, height: Spacing.avatarMedium)

                    Image(systemName: icon)
                        .font(.vitalIconMediumSemibold)
                        .foregroundStyle(color)
                }

                Text(value)
                    .font(.vitalNumberMedium)
                    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                Text(title)
                    .font(.vitalBodySmall)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                // Source indicator
                HStack(spacing: 2) {
                    if source.contains("Apple Health") {
                        Image(systemName: "heart.fill")
                            .font(.vitalIconTiny)
                            .foregroundStyle(Color.vitalDanger)
                    }
                    Text(source)
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextTertiary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
            Spacer()
            Text(value)
                .font(.vitalLabel)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
        }
    }
}

#Preview {
    ProfileView()
}
