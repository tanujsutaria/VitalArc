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
            workoutDataProvider: container.workoutRepository
        )

        let vm = AnalyticsDashboardViewModel(
            calculateVolumeUseCase: calculateVolumeUseCase,
            trackProgressiveOverloadUseCase: TrackProgressiveOverloadUseCase(
                workoutDataProvider: container.workoutRepository
            ),
            generateProgressReportUseCase: GenerateProgressReportUseCase(
                workoutDataProvider: container.workoutRepository,
                healthDataProvider: container.healthRepository,
                analyticsRepository: container.analyticsRepository,
                calculateVolumeUseCase: calculateVolumeUseCase
            ),
            calculateRecoveryScoreUseCase: CalculateRecoveryScoreUseCase(
                healthDataProvider: container.healthRepository
            ),
            calculateStrainScoreUseCase: CalculateStrainScoreUseCase(
                userProfileProvider: container.userRepository
            ),
            analyticsRepository: container.analyticsRepository,
            healthDataProvider: container.healthRepository
        )

        // Wire sub-ViewModels for muscle heat map and volume analysis
        vm.muscleHeatMapViewModel = MuscleHeatMapViewModel(
            workoutDataProvider: container.workoutRepository
        )
        vm.volumeAnalysisViewModel = VolumeAnalysisViewModel(
            workoutDataProvider: container.workoutRepository
        )

        viewModel = vm
        await vm.loadData()
    }
}

#Preview {
    ProgressTabView()
}
