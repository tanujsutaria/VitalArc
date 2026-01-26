//
//  MesocycleListView.swift
//  VitalArc
//
//  View for listing all mesocycles
//

import SwiftUI

struct MesocycleListView: View {
    @State private var viewModel: MesocycleViewModel
    @State private var showingCreateSheet = false
    @State private var selectedStatus: MesocycleStatus = .active

    init(mesocycleRepository: MesocycleRepository, workoutRepository: WorkoutRepository) {
        _viewModel = State(initialValue: MesocycleViewModel(
            mesocycleRepository: mesocycleRepository,
            workoutRepository: workoutRepository
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Status Filter
                Picker("Status", selection: $selectedStatus) {
                    ForEach(MesocycleStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .padding(Spacing.md)

                // Mesocycle List
                if viewModel.isLoading {
                    VitalLoadingState(message: "Loading programs...")
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.itemSpacing) {
                            let filteredMesocycles = viewModel.getMesocyclesByStatus(selectedStatus)

                            if filteredMesocycles.isEmpty {
                                emptyStateView
                            } else {
                                ForEach(filteredMesocycles) { mesocycle in
                                    NavigationLink(destination: MesocycleDetailView(
                                        mesocycle: mesocycle,
                                        viewModel: viewModel
                                    )) {
                                        MesocycleCardView(mesocycle: mesocycle, viewModel: viewModel)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(Spacing.md)
                    }
                    .background(Color.vitalAdaptiveBackground)
                }
            }
            .navigationTitle("Training Programs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.vitalH2)
                            .foregroundStyle(Color.vitalPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateMesocycleView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadMesocycles()
            }
        }
    }

    private var emptyStateView: some View {
        VitalEmptyState(
            icon: selectedStatus == .active ? "calendar.badge.exclamationmark" : "calendar",
            title: "No \(selectedStatus.rawValue) Programs",
            message: emptyStateMessage,
            actionTitle: (selectedStatus == .planned || selectedStatus == .active) ? "Create Program" : nil,
            action: (selectedStatus == .planned || selectedStatus == .active) ? {
                showingCreateSheet = true
            } : nil
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateMessage: String {
        switch selectedStatus {
        case .planned:
            return "Create a new training program to get started"
        case .active:
            return "No active training program. Activate a planned program or create a new one."
        case .completed:
            return "No completed programs yet. Complete your first mesocycle to see it here."
        }
    }
}

struct MesocycleCardView: View {
    let mesocycle: Mesocycle
    let viewModel: MesocycleViewModel

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: Spacing.itemSpacing) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(mesocycle.name)
                            .font(.vitalH3)
                            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

                        HStack(spacing: Spacing.sm) {
                            Label(mesocycle.goal.rawValue, systemImage: mesocycle.goal.icon)
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                            Text("•")
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                            Text("\(mesocycle.durationWeeks) weeks")
                                .font(.vitalCaption)
                                .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                        }
                    }

                    Spacer()

                    statusBadge
                }

                // Progress (Active only)
                if mesocycle.status == .active, let currentWeek = mesocycle.currentWeek {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Text("Week \(currentWeek) of \(mesocycle.durationWeeks)")
                                .font(.vitalBody)
                                .fontWeight(.medium)

                            Spacer()

                            Text("\(Int(mesocycle.progressPercentage))%")
                                .font(.vitalBody)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.vitalPrimary)
                        }

                        ProgressView(value: mesocycle.progressPercentage / 100)
                            .tint(Color.vitalPrimary)

                        if let phase = mesocycle.currentPhase {
                            Label(phase.phaseType.rawValue, systemImage: phase.phaseType.icon)
                                .font(.vitalCaption)
                                .foregroundStyle(Color(phase.phaseType.color))
                        }
                    }
                }

                // Dates
                HStack {
                    Label(formatDate(mesocycle.startDate), systemImage: "calendar")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    Image(systemName: "arrow.right")
                        .font(.vitalCaptionSmall)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)

                    Label(formatDate(mesocycle.endDate), systemImage: "calendar")
                        .font(.vitalCaption)
                        .foregroundStyle(Color.vitalAdaptiveTextSecondary)
                }

                // Quick Actions
                if mesocycle.status == .planned || mesocycle.status == .active {
                    Divider()
                        .background(Color.vitalAdaptiveBorder)

                    HStack(spacing: Spacing.md) {
                        if mesocycle.status == .planned {
                            VitalButton(
                                title: "Activate",
                                style: .outline,
                                size: .small,
                                icon: "play.fill"
                            ) {
                                Task {
                                    await viewModel.activateMesocycle(mesocycle)
                                }
                            }
                        }

                        if mesocycle.status == .active {
                            VitalButton(
                                title: "Complete",
                                style: .outline,
                                size: .small,
                                icon: "checkmark.circle.fill"
                            ) {
                                Task {
                                    await viewModel.completeMesocycle(mesocycle)
                                }
                            }
                        }

                        Spacer()

                        NavigationLink(destination: MesocycleDetailView(
                            mesocycle: mesocycle,
                            viewModel: viewModel
                        )) {
                            HStack(spacing: Spacing.xs) {
                                Text("Details")
                                    .font(.vitalLabelSmall)
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right.circle")
                                    .font(.vitalLabelSmall)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, Spacing.itemSpacing)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.vitalPrimary)
                            .cornerRadius(Spacing.radiusMedium)
                        }
                        .vitalScaleButton()
                    }
                }
            }
        }
    }

    private var statusBadge: some View {
        Text(mesocycle.status.rawValue)
            .font(.vitalCaption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.itemSpacing)
            .padding(.vertical, Spacing.xs + Spacing.xxs)
            .background(Color(mesocycle.status.color))
            .cornerRadius(Spacing.radiusSmall)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    MesocycleListView(
        mesocycleRepository: PreviewMesocycleRepository(),
        workoutRepository: PreviewWorkoutRepository()
    )
}

// Preview Repository
class PreviewMesocycleRepository: MesocycleRepository {
    func getMesocycles() async throws -> [Mesocycle] { [] }
    func getMesocycle(id: UUID) async throws -> Mesocycle? { nil }
    func getActiveMesocycle() async throws -> Mesocycle? { nil }
    func saveMesocycle(_ mesocycle: Mesocycle) async throws {}
    func updateMesocycle(_ mesocycle: Mesocycle) async throws {}
    func deleteMesocycle(id: UUID) async throws {}
    func activateMesocycle(id: UUID) async throws {}
    func completeMesocycle(id: UUID) async throws {}
    func getMesocyclesByStatus(_ status: MesocycleStatus) async throws -> [Mesocycle] { [] }
    func getMesocycleForDate(_ date: Date) async throws -> Mesocycle? { nil }
}

class PreviewWorkoutRepository: WorkoutRepository {
    func getExercises() async throws -> [Exercise] { [] }
    func getExercise(id: UUID) async throws -> Exercise? { nil }
    func searchExercises(query: String) async throws -> [Exercise] { [] }
    func saveExercise(_ exercise: Exercise) async throws {}
    func getWorkouts() async throws -> [Workout] { [] }
    func getWorkout(id: UUID) async throws -> Workout? { nil }
    func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout] { [] }
    func saveWorkout(_ workout: Workout) async throws {}
    func deleteWorkout(id: UUID) async throws {}
    func getLastWorkoutForExercise(_ exerciseId: UUID) async throws -> Workout? { nil }
}
