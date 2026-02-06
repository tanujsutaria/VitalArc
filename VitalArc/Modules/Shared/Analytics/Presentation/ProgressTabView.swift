//
//  ProgressTabView.swift
//  VitalArc
//
//  Progress tab wrapper for analytics dashboard
//

import SwiftUI

struct ProgressTabView: View {
    @Environment(\.dependencyContainer) private var container

    var body: some View {
        if let container = container {
            ProgressTabContentView(container: container)
        } else {
            ProgressView("Loading...")
        }
    }
}

struct ProgressTabContentView: View {
    let container: DependencyContainer
    @State private var viewModel: AnalyticsDashboardViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    AnalyticsDashboardView(viewModel: viewModel)
                } else {
                    VStack(spacing: Spacing.lg) {
                        ProgressView()
                        Text("Loading Progress...")
                            .font(.vitalBody)
                            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                    }
                }
            }
            .navigationTitle("Progress")
        }
        .task {
            await initializeViewModel()
        }
    }

    @MainActor
    private func initializeViewModel() async {
        // Guard against re-initialization if already loaded
        guard viewModel == nil else { return }

        let calculateVolumeUseCase = CalculateVolumeUseCase(
            workoutRepository: container.workoutRepository
        )

        let vm = AnalyticsDashboardViewModel(
            calculateVolumeUseCase: calculateVolumeUseCase,
            trackProgressiveOverloadUseCase: TrackProgressiveOverloadUseCase(
                workoutRepository: container.workoutRepository
            ),
            generateProgressReportUseCase: GenerateProgressReportUseCase(
                workoutRepository: container.workoutRepository,
                healthRepository: container.healthRepository,
                nutritionRepository: container.nutritionRepository,
                analyticsRepository: container.analyticsRepository,
                calculateVolumeUseCase: calculateVolumeUseCase
            ),
            calculateRecoveryScoreUseCase: CalculateRecoveryScoreUseCase(
                healthRepository: container.healthRepository
            ),
            calculateStrainScoreUseCase: CalculateStrainScoreUseCase(
                healthRepository: container.healthRepository,
                userRepository: container.userRepository
            ),
            analyticsRepository: container.analyticsRepository,
            healthRepository: container.healthRepository,
            nutritionRepository: container.nutritionRepository
        )

        viewModel = vm
        await vm.loadData()
    }
}

#Preview {
    ProgressTabView()
}
