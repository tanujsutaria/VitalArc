//
//  HealthKitPermissionView.swift
//  VitalArc
//
//  HealthKit permission request for onboarding
//

import SwiftUI

struct HealthKitPermissionView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onComplete: () async -> Void
    let onBack: () -> Void

    @State private var isRequesting = false
    @State private var healthKitManager = HealthKitManager()

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "heart.text.square.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Spacing.illustrationMedium, height: Spacing.illustrationMedium)
                .foregroundStyle(.pink.gradient)

            // Title
            Text("Connect to Health")
                .font(.vitalDisplayLarge)
                .multilineTextAlignment(.center)

            // Description
            VStack(alignment: .leading, spacing: 16) {
                PermissionRow(
                    icon: "figure.walk",
                    title: "Activity Data",
                    description: "Track steps, distance, and active calories"
                )

                PermissionRow(
                    icon: "heart.fill",
                    title: "Heart Rate",
                    description: "Monitor your heart rate during workouts"
                )

                PermissionRow(
                    icon: "flame.fill",
                    title: "Calories Burned",
                    description: "Sync calories burned from your workouts"
                )

                PermissionRow(
                    icon: "bed.double.fill",
                    title: "Sleep Data",
                    description: "Track your sleep for better recovery"
                )
            }
            .padding(.horizontal)

            Text("VitalArc will request access to your Health data. You can change this anytime in Settings.")
                .font(.vitalCaption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        isRequesting = true
                        await requestHealthKitPermission()
                        isRequesting = false
                    }
                }) {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Enable Health Sync")
                        }
                    }
                    .font(.vitalH3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.lg)
                    .background(Color.vitalPrimary)
                    .cornerRadius(Spacing.radiusMedium)
                }
                .disabled(isRequesting)

                Button(action: {
                    Task {
                        await viewModel.skipHealthKitSetup()
                        await onComplete()
                    }
                }) {
                    Text("Skip for Now")
                        .font(.vitalBodySmall)
                        .foregroundColor(.secondary)
                }

                Button(action: onBack) {
                    Text("Back")
                        .font(.vitalBody)
                        .foregroundColor(Color.vitalPrimary)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private func requestHealthKitPermission() async {
        // Request HealthKit authorization
        do {
            if healthKitManager.isHealthKitAvailable() {
                _ = try await healthKitManager.requestAuthorization()
            }
            // Complete onboarding regardless of HealthKit permission result
            try await viewModel.completeOnboarding()
            await onComplete()
        } catch {
            viewModel.errorMessage = UserFacingError.message(for: error, context: .saving)
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: Spacing.itemSpacing) {
            Image(systemName: icon)
                .font(.vitalH2)
                .foregroundStyle(.pink)
                .frame(width: Spacing.iconXLarge)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.vitalH3)
                Text(description)
                    .font(.vitalBodySmall)
                    .foregroundStyle(.secondary)
            }
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
    HealthKitPermissionView(
        viewModel: OnboardingViewModel(userRepository: PreviewUserRepository()),
        onComplete: {},
        onBack: {}
    )
}
