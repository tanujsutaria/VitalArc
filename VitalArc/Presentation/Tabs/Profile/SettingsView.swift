//
//  SettingsView.swift
//  VitalArc
//
//  Settings view for app preferences
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let userRepository: UserRepository

    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("enableWorkoutReminders") private var enableWorkoutReminders = false
    @AppStorage("enableMealReminders") private var enableMealReminders = false

    var body: some View {
        NavigationStack {
            Form {
                // Units Section
                Section {
                    Toggle("Use Metric Units", isOn: $useMetricUnits)
                } header: {
                    Text("Units")
                } footer: {
                    Text(useMetricUnits ? "Height in cm, weight in kg" : "Height in feet/inches, weight in lbs")
                }

                // Notifications Section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $enableNotifications)

                    if enableNotifications {
                        Toggle("Workout Reminders", isOn: $enableWorkoutReminders)
                        Toggle("Meal Reminders", isOn: $enableMealReminders)
                    }
                }

                // Data & Privacy Section
                Section("Data & Privacy") {
                    Button(action: {
                        // Open system settings
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("HealthKit Permissions")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button(action: {
                        Task {
                            await syncHealthKitData()
                        }
                    }) {
                        Text("Sync HealthKit Data")
                    }
                }

                // App Section
                Section("App") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                    }
                }

                // Danger Zone
                Section {
                    Button(role: .destructive, action: {
                        // TODO: Implement reset onboarding
                    }) {
                        Text("Reset Onboarding")
                    }

                    Button(role: .destructive, action: {
                        // TODO: Implement delete all data
                    }) {
                        Text("Delete All Data")
                    }
                } header: {
                    Text("Danger Zone")
                } footer: {
                    Text("These actions cannot be undone")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func syncHealthKitData() async {
        // Note: HealthKit sync will be implemented by Stream 2
        // Placeholder for now
    }
}

#Preview {
    // Preview with mock conforming to UserRepository protocol
    struct PreviewUserRepository: UserRepository {
        func getUserProfile() async throws -> UserProfile? { nil }
        func saveUserProfile(_ profile: UserProfile) async throws {}
        func updateUserProfile(_ profile: UserProfile) async throws {}
        func deleteUserProfile() async throws {}
        func hasCompletedOnboarding() async -> Bool { true }
        func setOnboardingCompleted(_ completed: Bool) async {}
    }

    SettingsView(userRepository: PreviewUserRepository())
}
