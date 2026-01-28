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
        getExercisesUseCase: GetExercisesUseCase
    ) {
        self.viewModel = WorkoutLoggingViewModel(
            createWorkoutUseCase: createWorkoutUseCase,
            calculateProgressionUseCase: calculateProgressionUseCase
        )
        self.getExercisesUseCase = getExercisesUseCase
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
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
                    Button("Save") {
                        Task {
                            await viewModel.saveWorkout()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave || viewModel.isLoading)
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
        }
    }

    // MARK: - Workout Info Card

    private var workoutInfoCard: some View {
        VStack(spacing: 12) {
            TextField("Workout Name (optional)", text: $viewModel.workoutName)
                .font(.headline)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(durationString)
                        .font(.headline)
                }

                Divider()
                    .frame(height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Sets")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.totalSets)")
                        .font(.headline)
                }

                Divider()
                    .frame(height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Volume")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.totalVolume, specifier: "%.0f") kg")
                        .font(.headline)
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
        VStack(spacing: 16) {
            ForEach(viewModel.selectedExercises) { exercise in
                let sets = Binding(
                    get: { viewModel.exerciseSets[exercise.id] ?? [] },
                    set: { viewModel.exerciseSets[exercise.id] = $0 }
                )
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
                        }
                    )
            }

            addExerciseButton
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Exercises Added")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Add exercises to start logging your workout")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            addExerciseButton
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
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

    // MARK: - Helpers

    private var durationString: String {
        let duration = viewModel.duration
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
