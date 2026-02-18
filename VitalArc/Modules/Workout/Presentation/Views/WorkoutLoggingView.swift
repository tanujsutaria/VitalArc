//
//  WorkoutLoggingView.swift
//  VitalArc
//
//  Main view for logging a workout
//

import SwiftUI

struct WorkoutLoggingView: View {
    @State private var viewModel: WorkoutLoggingViewModel
    @Environment(\.dismiss) private var dismiss

    private let getExercisesUseCase: GetExercisesUseCase

    init(
        createWorkoutUseCase: CreateWorkoutUseCase,
        calculateProgressionUseCase: CalculateProgressionUseCase,
        getExercisesUseCase: GetExercisesUseCase,
        detectPersonalRecordUseCase: DetectPersonalRecordUseCase? = nil,
        calculateOneRepMaxUseCase: CalculateOneRepMaxUseCase? = nil
    ) {
        self.viewModel = WorkoutLoggingViewModel(
            createWorkoutUseCase: createWorkoutUseCase,
            calculateProgressionUseCase: calculateProgressionUseCase,
            detectPersonalRecordUseCase: detectPersonalRecordUseCase,
            calculateOneRepMaxUseCase: calculateOneRepMaxUseCase
        )
        self.getExercisesUseCase = getExercisesUseCase
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.screenPadding) {
                    // Rest Timer
                    if viewModel.restTimerActive, let endDate = viewModel.restTimerEndDate {
                        RestTimerView(
                            endDate: endDate,
                            totalDuration: viewModel.restTimerDuration,
                            onCancel: { viewModel.cancelRestTimer() },
                            onFinished: { viewModel.restTimerFinished() }
                        )
                    }

                    // Workout Info Card
                    workoutInfoCard

                    // Exercises
                    if viewModel.selectedExercises.isEmpty {
                        emptyState
                    } else {
                        exercisesList
                    }
                }
                .padding()
            }
            .navigationTitle("Log Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    HStack(spacing: Spacing.sm) {
                        if !viewModel.selectedExercises.isEmpty {
                            Button {
                                viewModel.toggleGroupingMode()
                            } label: {
                                Image(systemName: viewModel.isGroupingMode ? "link.circle.fill" : "link.circle")
                            }
                        }

                        Button("Save") {
                            Task {
                                await viewModel.saveWorkout()
                                dismiss()
                            }
                        }
                        .disabled(!viewModel.canSave || viewModel.isLoading)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingExerciseLibrary) {
                ExerciseLibraryView(
                    getExercisesUseCase: getExercisesUseCase
                ) { exercise in
                    Task {
                        await viewModel.addExercise(exercise)
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .sheet(isPresented: $viewModel.showingPersonalRecords) {
                PersonalRecordBadgeView(
                    records: viewModel.newPersonalRecords,
                    onDismiss: {
                        viewModel.showingPersonalRecords = false
                        viewModel.resetWorkout()
                        dismiss()
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Workout Info Card

    private var workoutInfoCard: some View {
        VStack(spacing: Spacing.itemSpacing) {
            TextField("Workout Name (optional)", text: $viewModel.workoutName)
                .font(.vitalH3)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: Spacing.screenPadding) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Duration")
                        .font(.vitalCaption)
                        .foregroundStyle(.secondary)
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        let elapsed = context.date.timeIntervalSince(viewModel.startTime)
                        let minutes = Int(elapsed) / 60
                        let seconds = Int(elapsed) % 60
                        Text(String(format: "%02d:%02d", minutes, seconds))
                            .font(.vitalH3)
                            .monospacedDigit()
                    }
                }

                Divider()
                    .frame(height: Spacing.avatarSmall)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Sets")
                        .font(.vitalCaption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.totalSets)")
                        .font(.vitalH3)
                }

                Divider()
                    .frame(height: Spacing.avatarSmall)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Volume")
                        .font(.vitalCaption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.totalVolume, specifier: "%.0f") kg")
                        .font(.vitalH3)
                }

                Spacer()
            }

            TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
        }
        .padding(Spacing.lg)
        .background(Color.vitalAdaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
    }

    // MARK: - Exercises List

    private var exercisesList: some View {
        VStack(spacing: Spacing.lg) {
            // Grouping mode controls
            if viewModel.isGroupingMode {
                groupingControls
            }

            ForEach(viewModel.selectedExercises) { exercise in
                let sets = Binding(
                    get: { viewModel.exerciseSets[exercise.id] ?? [] },
                    set: { viewModel.exerciseSets[exercise.id] = $0 }
                )

                VStack(spacing: 0) {
                    // Group header for first exercise in group
                    if viewModel.isFirstInGroup(exercise.id),
                       let group = viewModel.groupForExercise(exercise.id) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: group.groupType.icon)
                                .font(.vitalCaption)
                            Text(group.displayName)
                                .font(.vitalCaption)
                                .fontWeight(.semibold)
                            Spacer()
                            Button {
                                viewModel.removeGroup(group.id)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.vitalCaption)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .foregroundStyle(Color.vitalPrimary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.vitalPrimary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                    }

                    HStack(spacing: 0) {
                        // Grouping selection
                        if viewModel.isGroupingMode {
                            Button {
                                viewModel.toggleExerciseForGrouping(exercise.id)
                            } label: {
                                Image(systemName: viewModel.selectedExerciseIdsForGrouping.contains(exercise.id)
                                      ? "checkmark.circle.fill" : "circle")
                                    .font(.vitalH3)
                                    .foregroundStyle(viewModel.selectedExerciseIdsForGrouping.contains(exercise.id)
                                                     ? Color.vitalPrimary : .secondary)
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, Spacing.sm)
                        }

                        // Group bracket indicator
                        if viewModel.groupForExercise(exercise.id) != nil {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.vitalPrimary)
                                .frame(width: Spacing.borderThick)
                                .padding(.vertical, Spacing.xs)
                                .padding(.trailing, Spacing.sm)
                        }

                        ExerciseSetView(
                            exercise: exercise,
                            sets: sets,
                            onAddSet: {
                                viewModel.addSet(for: exercise.id)
                            },
                            onRemoveSet: { index in
                                viewModel.removeSet(for: exercise.id, at: index)
                            },
                            onUpdateSet: { updatedSet, index in
                                viewModel.updateSet(updatedSet, for: exercise.id, at: index)
                            },
                            onRemoveExercise: {
                                viewModel.removeExercise(exercise)
                            },
                            onSetCompleted: {
                                viewModel.startRestTimer(duration: 90, for: exercise.id)
                            },
                            estimated1RM: viewModel.currentEstimated1RM(for: exercise.id),
                            historicalBest1RM: viewModel.historicalBest(for: exercise.id)
                        )
                    }
                }
            }

            addExerciseButton
        }
    }

    // MARK: - Grouping Controls

    private var groupingControls: some View {
        VStack(spacing: Spacing.sm) {
            Text("Select 2+ exercises to group")
                .font(.vitalCaption)
                .foregroundStyle(Color.vitalAdaptiveTextSecondary)

            if viewModel.selectedExerciseIdsForGrouping.count >= 2 {
                HStack(spacing: Spacing.sm) {
                    ForEach(SetGroupType.allCases, id: \.self) { type in
                        Button {
                            viewModel.createGroup(type: type)
                        } label: {
                            Label(type.rawValue, systemImage: type.icon)
                                .font(.vitalCaption)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(Color.vitalPrimary.opacity(0.1))
                                .foregroundStyle(Color.vitalPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.vitalAdaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.vitalIconGiant)
                .foregroundStyle(.secondary)

            Text("No Exercises Added")
                .font(.vitalH3)
                .foregroundStyle(.secondary)

            Text("Add exercises to start logging your workout")
                .font(.vitalBodySmall)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            addExerciseButton
                .padding(.top, Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.iconGiant)
    }

    // MARK: - Add Exercise Button

    private var addExerciseButton: some View {
        Button {
            viewModel.showingExerciseLibrary = true
        } label: {
            Label("Add Exercise", systemImage: "plus.circle.fill")
                .font(.vitalH3)
                .frame(maxWidth: .infinity)
                .padding(Spacing.lg)
                .background(Color.vitalPrimary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
        }
    }

}
