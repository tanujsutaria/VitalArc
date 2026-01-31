//
//  NotificationSettingsView.swift
//  VitalArc
//
//  Notification settings view for managing push notifications
//

import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var viewModel: NotificationSettingsViewModel?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if let viewModel = viewModel {
                NotificationSettingsFormView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            if let container = container {
                viewModel = NotificationSettingsViewModel(
                    scheduler: container.notificationScheduler,
                    repository: container.notificationPreferencesRepository,
                    requestPermissionUseCase: container.requestNotificationPermissionUseCase,
                    scheduleNotificationsUseCase: container.scheduleNotificationsUseCase,
                    checkRecoveryUseCase: container.checkRecoveryAndNotifyUseCase
                )
            } else {
                viewModel = NotificationSettingsViewModel()
            }
        }
    }
}

// MARK: - Form View (with Bindable ViewModel)

private struct NotificationSettingsFormView: View {
    @Bindable var viewModel: NotificationSettingsViewModel

    var body: some View {
        Form {
            // Master Toggle Section
            Section {
                Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                    .tint(Color.vitalPrimary)
                    .onChange(of: viewModel.notificationsEnabled) { _, newValue in
                        HapticFeedback.selection()
                        if newValue {
                            Task {
                                await viewModel.requestNotificationPermissions()
                            }
                        } else {
                            Task {
                                await viewModel.cancelAllNotifications()
                            }
                        }
                    }
            } footer: {
                Text("Receive reminders and alerts to stay on track with your fitness goals.")
                    .font(.vitalCaption)
            }

            // Notification Types Section
            if viewModel.notificationsEnabled {
                Section {
                    // Workout Reminders Toggle
                    Toggle("Workout Reminders", isOn: $viewModel.workoutRemindersEnabled)
                        .tint(Color.vitalPrimary)
                        .onChange(of: viewModel.workoutRemindersEnabled) { _, newValue in
                            HapticFeedback.selection()
                            Task {
                                if newValue {
                                    await viewModel.scheduleWorkoutReminder()
                                } else {
                                    await viewModel.cancelWorkoutReminder()
                                }
                            }
                        }

                    // Time Picker (only if workout reminders enabled)
                    if viewModel.workoutRemindersEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $viewModel.workoutReminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .tint(Color.vitalPrimary)
                        .onChange(of: viewModel.workoutReminderTime) { _, _ in
                            Task {
                                await viewModel.scheduleWorkoutReminder()
                            }
                        }
                    }

                    // Recovery Alerts Toggle
                    Toggle("Recovery Alerts", isOn: $viewModel.recoveryAlertsEnabled)
                        .tint(Color.vitalPrimary)
                        .onChange(of: viewModel.recoveryAlertsEnabled) { _, newValue in
                            HapticFeedback.selection()
                            Task {
                                if newValue {
                                    await viewModel.scheduleRecoveryAlerts()
                                } else {
                                    await viewModel.cancelRecoveryAlerts()
                                }
                            }
                        }

                    // Nutrition Reminders Toggle
                    Toggle("Nutrition Reminders", isOn: $viewModel.nutritionRemindersEnabled)
                        .tint(Color.vitalPrimary)
                        .onChange(of: viewModel.nutritionRemindersEnabled) { _, _ in
                            HapticFeedback.selection()
                        }
                } header: {
                    Text("Notification Types")
                } footer: {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Workout Reminders: Daily reminder at your chosen time")
                        Text("Recovery Alerts: Suggestions when you may need rest")
                        Text("Nutrition Reminders: Reminders to log your meals")
                    }
                    .font(.vitalCaption)
                }

                // Preview Section
                Section {
                    Text("Here's what your notifications will look like:")
                        .font(.vitalBodySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .listRowBackground(Color.clear)

                    NotificationPreviewCard(
                        title: "Time to Train!",
                        message: "Your scheduled workout is ready. Let's crush those goals!",
                        icon: "figure.walk",
                        color: .vitalPrimary
                    )
                    .listRowInsets(EdgeInsets(top: Spacing.sm, leading: 0, bottom: Spacing.sm, trailing: 0))
                    .listRowBackground(Color.clear)

                    NotificationPreviewCard(
                        title: "Recovery Day",
                        message: "Your body needs rest. Consider a lighter workout today.",
                        icon: "bed.double.fill",
                        color: .vitalWarning
                    )
                    .listRowInsets(EdgeInsets(top: Spacing.sm, leading: 0, bottom: Spacing.sm, trailing: 0))
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Preview")
                }
            }

            // Authorization Status Section (if denied)
            if viewModel.authorizationStatus == .denied {
                Section {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.vitalWarning)
                            Text("Notifications Disabled")
                                .font(.vitalLabel)
                                .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        }

                        Text("Notifications are disabled in system settings. Enable them in Settings to receive reminders.")
                            .font(.vitalBodySmall)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text("Open Settings")
                                .font(.vitalLabel)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Spacing.sm)
                                .background(Color.vitalPrimary)
                                .cornerRadius(Spacing.radiusSmall)
                        }
                    }
                    .padding(.vertical, Spacing.sm)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
