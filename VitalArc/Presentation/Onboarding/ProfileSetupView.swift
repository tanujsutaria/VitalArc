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
                    HStack {
                        TextField("Height", value: $viewModel.height, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Text("cm")
                            .foregroundStyle(.secondary)
                    }
                }

                // Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight")
                        .font(.headline)
                    HStack {
                        TextField("Weight", value: $viewModel.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Text("kg")
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
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }

                    Button(action: onContinue) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.canProceedFromProfileSetup ?
                                Color.accentColor : Color.gray
                            )
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.canProceedFromProfileSetup)
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

#Preview {
    struct PreviewUserRepository: UserRepository {
        func getUserProfile() async throws -> UserProfile? { nil }
        func saveUserProfile(_ profile: UserProfile) async throws {}
        func updateUserProfile(_ profile: UserProfile) async throws {}
        func deleteUserProfile() async throws {}
        func hasCompletedOnboarding() async -> Bool { false }
        func setOnboardingCompleted(_ completed: Bool) async {}
    }

    ProfileSetupView(
        viewModel: OnboardingViewModel(userRepository: PreviewUserRepository()),
        onContinue: {},
        onBack: {}
    )
}
