//
//  GoalSetupView.swift
//  VitalArc
//
//  TDEE and macro goal review step during onboarding
//

import SwiftUI

struct GoalSetupView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    let onBack: () -> Void

    private var tdeeResult: TDEEResult {
        viewModel.computeTDEEResult()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Your Daily Targets")
                        .font(.vitalDisplayLarge)
                    Text("Based on your profile, here's your estimated daily nutrition plan")
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }
                .padding(.bottom, Spacing.sm)

                // Calorie Summary Card
                VitalCard {
                    VStack(spacing: Spacing.md) {
                        Text("Daily Calories")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        Text("\(Int(tdeeResult.adjustedCalories))")
                            .font(.vitalDisplayLarge)
                            .foregroundStyle(Color.vitalPrimary)

                        Text("kcal / day")
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                        if tdeeResult.deficit != 0 {
                            let label = tdeeResult.deficit > 0 ? "surplus" : "deficit"
                            Text("\(Int(abs(tdeeResult.deficit))) cal \(label) for \(viewModel.selectedWeightGoal.rawValue.lowercased())")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                // Macro Breakdown Card
                VitalCard {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Macro Targets")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        HStack(spacing: Spacing.lg) {
                            macroItem(
                                label: "Protein",
                                grams: tdeeResult.proteinGoal,
                                color: .vitalPrimary
                            )

                            macroItem(
                                label: "Carbs",
                                grams: tdeeResult.carbGoal,
                                color: .vitalSuccess
                            )

                            macroItem(
                                label: "Fat",
                                grams: tdeeResult.fatGoal,
                                color: .vitalWarning
                            )
                        }
                    }
                }

                // Details Card
                VitalCard {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Calculation Details")
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        detailRow(label: "Basal Metabolic Rate", value: "\(Int(tdeeResult.bmr)) kcal")
                        detailRow(label: "Activity Multiplier", value: String(format: "%.2f×", tdeeResult.activityMultiplier))
                        detailRow(label: "Maintenance TDEE", value: "\(Int(tdeeResult.tdee)) kcal")
                        detailRow(label: "Formula", value: tdeeResult.formula.rawValue)
                    }
                }

                // Adjust Prompt
                Text("You can adjust your activity level and weight goal anytime in Settings.")
                    .font(.vitalCaption)
                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

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
                            .background(Color.vitalPrimary)
                            .cornerRadius(Spacing.radiusMedium)
                    }
                }
                .padding(.top, Spacing.sm)
            }
            .padding()
        }
    }

    // MARK: - Subviews

    private func macroItem(label: String, grams: Double, color: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            Text("\(Int(grams))g")
                .font(.vitalH2)
                .foregroundStyle(color)
            Text(label)
                .font(.vitalCaptionSmall)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func detailRow(label: String, value: String) -> some View {
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

// MARK: - Preview

private struct PreviewUserRepository: UserRepository {
    func getUserProfile() async throws -> UserProfile? { nil }
    func saveUserProfile(_ profile: UserProfile) async throws {}
    func updateUserProfile(_ profile: UserProfile) async throws {}
    func deleteUserProfile() async throws {}
    func hasCompletedOnboarding() async -> Bool { false }
    func setOnboardingCompleted(_ completed: Bool) async {}
}

#Preview {
    GoalSetupView(
        viewModel: OnboardingViewModel(userRepository: PreviewUserRepository()),
        onContinue: {},
        onBack: {}
    )
}
