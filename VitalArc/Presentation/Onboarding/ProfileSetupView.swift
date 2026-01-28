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
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create Your Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Help us personalize your experience")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)

                // Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.headline)
                    TextField("Enter your name", text: $viewModel.userName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                }

                // Birth Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Birth Date")
                        .font(.headline)
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Biological Sex")
                        .font(.headline)
                    Picker("Biological Sex", selection: $viewModel.selectedSex) {
                        ForEach(BiologicalSex.allCases, id: \.self) { sex in
                            Text(sex.rawValue).tag(sex)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Height
                VStack(alignment: .leading, spacing: 8) {
                    Text("Height")
                        .font(.headline)
                    HStack(spacing: 12) {
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight")
                        .font(.headline)
                    HStack {
                        TextField("Weight", value: $viewModel.weightLbs, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Text("lbs")
                            .foregroundStyle(.secondary)
                    }
                }

                // Activity Level
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity Level")
                        .font(.headline)
                    Picker("Activity Level", selection: $viewModel.selectedActivityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Weight Goal
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight Goal")
                        .font(.headline)
                    Picker("Weight Goal", selection: $viewModel.selectedWeightGoal) {
                        ForEach(WeightGoal.allCases, id: \.self) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Navigation Buttons
                HStack(spacing: 16) {
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
                            .font(.headline)
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
                .padding(.top, 8)
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
