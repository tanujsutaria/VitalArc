//
//  SettingsView.swift
//  VitalArc
//
//  Settings view for app preferences
//

import SwiftUI

// MARK: - Notification Names

extension Notification.Name {
    static let resetToOnboarding = Notification.Name("resetToOnboarding")
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let userRepository: UserRepository
    let healthRepository: HealthRepository?

    @AppStorage("useMetricUnits") private var useMetricUnits = false
    @AppStorage("enableNotifications") private var enableNotifications = true

    @State private var showingDeleteConfirmation = false
    @State private var showingFeedback = false
    @State private var isSyncing = false
    @State private var lastSyncDate: Date?
    @State private var syncError: String?
    @State private var deleteError: String?

    init(userRepository: UserRepository, healthRepository: HealthRepository? = nil) {
        self.userRepository = userRepository
        self.healthRepository = healthRepository
    }

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
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        HStack {
                            Label("Notification Settings", systemImage: "bell.fill")
                            Spacer()
                            if enableNotifications {
                                Text("On")
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                        }
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
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                    }

                    Button(action: {
                        syncHealthKitData()
                    }) {
                        HStack {
                            Text("Sync HealthKit Data")
                            Spacer()
                            if isSyncing {
                                ProgressView()
                                    .controlSize(.small)
                            } else if let lastSync = lastSyncDate {
                                Text(lastSync, style: .relative)
                                    .font(.vitalCaption)
                                    .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                            }
                        }
                    }
                    .disabled(isSyncing)

                    if let error = syncError {
                        Text(error)
                            .font(.vitalCaption)
                            .foregroundStyle(Color.vitalDanger)
                    }
                }

                // App Section
                Section("App") {
                    Button {
                        showingFeedback = true
                    } label: {
                        HStack {
                            Label("Send Feedback", systemImage: "envelope.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }

                // Danger Zone
                Section {
                    Button(role: .destructive, action: {
                        resetOnboarding()
                    }) {
                        Text("Reset Onboarding")
                    }

                    Button(role: .destructive, action: {
                        deleteAllData()
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
            .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        do {
                            try await userRepository.deleteUserProfile()
                            await userRepository.setOnboardingCompleted(false)
                            NotificationCenter.default.post(name: .resetToOnboarding, object: nil)
                        } catch {
                            Log.error("Failed to delete user profile", error: error, category: .data)
                            deleteError = "Failed to delete data. Please try again."
                        }
                    }
                }
            } message: {
                Text("This will permanently delete all your data. This cannot be undone.")
            }
            .alert("Delete Error", isPresented: .init(
                get: { deleteError != nil },
                set: { if !$0 { deleteError = nil } }
            )) {
                Button("OK") { deleteError = nil }
            } message: {
                if let error = deleteError {
                    Text(error)
                }
            }
            .sheet(isPresented: $showingFeedback) {
                FeedbackView()
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func resetOnboarding() {
        Task {
            await userRepository.setOnboardingCompleted(false)
            // Post notification to reset app state
            NotificationCenter.default.post(name: .resetToOnboarding, object: nil)
        }
    }

    private func deleteAllData() {
        showingDeleteConfirmation = true
    }

    private func syncHealthKitData() {
        isSyncing = true
        syncError = nil
        Task {
            do {
                if let healthRepo = healthRepository {
                    try await healthRepo.syncFromHealthKit()
                } else {
                    // No health repository available, simulate a brief sync
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                }
                lastSyncDate = Date()
            } catch {
                syncError = error.localizedDescription
            }
            isSyncing = false
        }
    }
}

private struct PreviewUserRepository: UserRepository {
    func getUserProfile() async throws -> UserProfile? { nil }
    func saveUserProfile(_ profile: UserProfile) async throws {}
    func updateUserProfile(_ profile: UserProfile) async throws {}
    func deleteUserProfile() async throws {}
    func hasCompletedOnboarding() async -> Bool { true }
    func setOnboardingCompleted(_ completed: Bool) async {}
}

@MainActor
private struct PreviewHealthRepository: HealthRepository {
    func getHealthMetrics(for date: Date) async throws -> HealthMetrics? { nil }
    func getHealthMetrics(from startDate: Date, to endDate: Date) async throws -> [HealthMetrics] { [] }
    func saveHealthMetrics(_ metrics: HealthMetrics) async throws {}
    func syncFromHealthKit() async throws {}
    func requestHealthKitAuthorization() async throws -> Bool { false }
}

#Preview {
    SettingsView(userRepository: PreviewUserRepository(), healthRepository: PreviewHealthRepository())
}
