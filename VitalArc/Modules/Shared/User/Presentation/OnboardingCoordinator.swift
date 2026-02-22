//
//  OnboardingCoordinator.swift
//  VitalArc
//
//  Coordinator for managing onboarding flow
//

import SwiftUI

struct OnboardingCoordinator: View {
    @Environment(\.dependencyContainer) private var container
    @State private var viewModel: OnboardingViewModel?
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        Group {
            if let viewModel = viewModel {
                ZStack {
                    // Background gradient
                    LinearGradient(
                        colors: [.pink.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    // Content
                    VStack {
                        switch viewModel.currentStep {
                        case .welcome:
                            WelcomeView(onContinue: {
                                viewModel.nextStep()
                            })
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))

                        case .profileSetup:
                            ProfileSetupView(
                                viewModel: viewModel,
                                onContinue: {
                                    viewModel.nextStep()
                                },
                                onBack: {
                                    viewModel.previousStep()
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))

                        case .goalSetup:
                            GoalSetupView(
                                viewModel: viewModel,
                                onContinue: {
                                    viewModel.nextStep()
                                },
                                onBack: {
                                    viewModel.previousStep()
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))

                        case .healthKitPermission:
                            HealthKitPermissionView(
                                viewModel: viewModel,
                                onComplete: {
                                    isOnboardingComplete = true
                                },
                                onBack: {
                                    viewModel.previousStep()
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                        }
                    }
                }
                .animation(.easeInOut, value: viewModel.currentStep)
                .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                    Button("OK") {
                        viewModel.errorMessage = nil
                    }
                } message: {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                    }
                }
            } else {
                ProgressView("Loading...")
                    .onAppear {
                        setupViewModel()
                    }
            }
        }
    }

    private func setupViewModel() {
        guard let container = container else { return }
        viewModel = OnboardingViewModel(userRepository: container.userRepository)
    }
}

#Preview {
    @Previewable @State var isComplete = false
    OnboardingCoordinator(isOnboardingComplete: $isComplete)
}
