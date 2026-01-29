//
//  ProfileSetupView.swift
//  VitalArc
//
//  Profile setup form for onboarding
//

import SwiftUI

struct ProfileSetupView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Create Your Profile")
                        .font(.vitalDisplayLarge)
                    Text("Help us personalize your experience")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
                .padding(.bottom, Spacing.sm)

                // Name
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Name")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    TextField("Enter your name", text: $viewModel.userName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                }

                // Birth Date
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Birth Date")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    DatePicker(
                        "Birth Date",
                        selection: $viewModel.birthDate,
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
                    Picker("Biological Sex", selection: $viewModel.selectedSex) {
                        ForEach(BiologicalSex.allCases, id: \.self) { sex in
                            Text(sex.rawValue).tag(sex)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Height
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Height")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    HStack(spacing: Spacing.md) {
                        Picker("Feet", selection: $viewModel.heightFeet) {
                            ForEach(4...7, id: \.self) { feet in
                                Text("\(feet) ft").tag(feet)
                            }
                        }
                        .pickerStyle(.menu)

                        Picker("Inches", selection: $viewModel.heightInches) {
                            ForEach(0...11, id: \.self) { inches in
                                Text("\(inches) in").tag(inches)
                            }
                        }
                        .pickerStyle(.menu)

                        Spacer()
                    }
                }

                // Weight
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Weight")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    HStack {
                        TextField("Weight", value: $viewModel.weightLbs, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Text("lbs")
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }

                // Activity Level
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Activity Level")
                        .font(.vitalH3)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                    Picker("Activity Level", selection: $viewModel.selectedActivityLevel) {
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
                    Picker("Weight Goal", selection: $viewModel.selectedWeightGoal) {
                        ForEach(WeightGoal.allCases, id: \.self) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Navigation Buttons
                HStack(spacing: Spacing.lg) {
                    Button(action: onBack) {
                        Text("Back")
                            .font(.vitalH3)
                            .foregroundColor(Color.vitalPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.lg)
                            .background(Color.vitalAdaptiveSurface)
                            .cornerRadius(Spacing.radiusMedium)
                    }

                    Button(action: onContinue) {
                        Text("Continue")
                            .font(.vitalH3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.lg)
                            .background(
                                viewModel.canProceedFromProfileSetup ?
                                Color.vitalPrimary : Color.vitalAdaptiveTextSecondary
                            )
                            .cornerRadius(Spacing.radiusMedium)
                    }
                    .disabled(!viewModel.canProceedFromProfileSetup)
                }
                .padding(.top, Spacing.sm)
            }
            .padding()
        }
    }
}

private struct PreviewUserRepository: UserRepository {
    func getUserProfile() async throws -> UserProfile? { nil }
    func saveUserProfile(_ profile: UserProfile) async throws {}
    func updateUserProfile(_ profile: UserProfile) async throws {}
    func deleteUserProfile() async throws {}
    func hasCompletedOnboarding() async -> Bool { false }
    func setOnboardingCompleted(_ completed: Bool) async {}
}

#Preview {
    ProfileSetupView(
        viewModel: OnboardingViewModel(userRepository: PreviewUserRepository()),
        onContinue: {},
        onBack: {}
    )
}
