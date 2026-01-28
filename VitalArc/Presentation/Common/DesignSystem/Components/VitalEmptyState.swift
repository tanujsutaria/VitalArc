//
//  VitalEmptyState.swift
//  VitalArc
//
//  Empty state component for when there's no data
//

import SwiftUI

struct VitalEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.vitalPrimary.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: icon)
                        .font(.system(size: Spacing.iconHuge))
                        .foregroundStyle(Color.vitalPrimary)
                }

                // Text
                VStack(spacing: Spacing.sm) {
                    Text(title)
                        .font(.vitalDisplaySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }

                // Action button
                if let actionTitle = actionTitle, let action = action {
                    VitalButton(
                        title: actionTitle,
                        style: .primary,
                        fullWidth: true,
                        action: action
                    )
                    .padding(.top, Spacing.sm)
                }
            }
        }
        .transition(.vitalScale)
    }
}

// MARK: - Loading State

struct VitalLoadingState: View {
    let message: String

    init(message: String = "Loading...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.vitalPrimary)

            Text(message)
                .font(.vitalBody)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xxl)
    }
}

// MARK: - Error State

struct VitalErrorState: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VitalCard(padding: Spacing.xl) {
            VStack(spacing: Spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.vitalDanger.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: Spacing.iconHuge))
                        .foregroundStyle(Color.vitalDanger)
                }

                // Text
                VStack(spacing: Spacing.sm) {
                    Text("Something Went Wrong")
                        .font(.vitalDisplaySmall)
                        .foregroundStyle(Color.vitalAdaptiveTextPrimary)
                        .multilineTextAlignment(.center)

                    Text(error.localizedDescription)
                        .font(.vitalBody)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }

                // Retry button
                VitalButton(
                    title: "Try Again",
                    style: .primary,
                    icon: "arrow.clockwise",
                    fullWidth: true,
                    action: retryAction
                )
                .padding(.top, Spacing.sm)
            }
        }
        .transition(.vitalScale)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.xl) {
            VitalEmptyState(
                icon: "figure.walk",
                title: "No Workouts Yet",
                message: "Start logging your workouts to track your progress and reach your goals.",
                actionTitle: "Log First Workout"
            ) {
                print("Action tapped")
            }

            VitalLoadingState(message: "Loading workouts...")

            VitalErrorState(
                error: NSError(domain: "", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Failed to load data from server"
                ])
            ) {
                print("Retry tapped")
            }
        }
        .padding()
    }
    .background(Color.vitalAdaptiveBackground)
}
