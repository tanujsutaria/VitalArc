//
//  ExerciseLibraryViewModel.swift
//  VitalArc
//
//  ViewModel for Exercise Library with debounced search
//

import Foundation
import Observation

@MainActor
@Observable
final class ExerciseLibraryViewModel {
    private let getExercisesUseCase: GetExercisesUseCase
    private var searchTask: Task<Void, Never>?

    var exercises: [Exercise] = []
    var searchText: String = ""
    var selectedCategory: ExerciseCategory? = nil
    var selectedMuscleGroup: MuscleGroup? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // Custom exercise management
    var exerciseToEdit: Exercise? = nil
    var showingEditExercise: Bool = false
    var deleteError: String? = nil

    init(getExercisesUseCase: GetExercisesUseCase) {
        self.getExercisesUseCase = getExercisesUseCase
    }

    func loadExercises() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await getExercisesUseCase.execute(
                category: selectedCategory,
                muscleGroup: selectedMuscleGroup,
                searchQuery: searchText.isEmpty ? nil : searchText
            )

            // Don't overwrite if this task was cancelled (stale results)
            guard !Task.isCancelled else {
                isLoading = false
                return
            }

            exercises = result
        } catch is CancellationError {
            isLoading = false
            return
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .loading)
        }

        isLoading = false
    }

    func selectCategory(_ category: ExerciseCategory?) async {
        selectedCategory = category
        // Cancel any pending search and load immediately for category changes
        searchTask?.cancel()
        await loadExercises()
    }

    func selectMuscleGroup(_ muscleGroup: MuscleGroup?) async {
        selectedMuscleGroup = muscleGroup
        searchTask?.cancel()
        await loadExercises()
    }

    func updateSearch(_ text: String) async {
        searchText = text

        // Cancel previous search task
        searchTask?.cancel()

        // Debounce: wait 300ms before searching
        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(300))

                // Check if task was cancelled
                guard !Task.isCancelled else { return }

                await loadExercises()
            } catch {
                // Task was cancelled, ignore
            }
        }

        // Wait for the debounced task to complete
        await searchTask?.value
    }

    func clearSearch() {
        searchText = ""
        searchTask?.cancel()
        searchTask = Task {
            await loadExercises()
        }
    }
}
