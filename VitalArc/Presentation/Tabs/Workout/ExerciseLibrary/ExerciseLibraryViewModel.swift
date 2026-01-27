//
//  ExerciseLibraryViewModel.swift
//  VitalArc
//
//  ViewModel for Exercise Library
//

import Foundation
import Observation

@MainActor
@Observable
final class ExerciseLibraryViewModel {
    private let getExercisesUseCase: GetExercisesUseCase

    var exercises: [Exercise] = []
    var searchText: String = ""
    var selectedCategory: ExerciseCategory? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    init(getExercisesUseCase: GetExercisesUseCase) {
        self.getExercisesUseCase = getExercisesUseCase
    }

    func loadExercises() async {
        isLoading = true
        errorMessage = nil

        do {
            exercises = try await getExercisesUseCase.execute(
                category: selectedCategory,
                searchQuery: searchText.isEmpty ? nil : searchText
            )
        } catch {
            errorMessage = "Failed to load exercises: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func selectCategory(_ category: ExerciseCategory?) async {
        selectedCategory = category
        await loadExercises()
    }

    func updateSearch(_ text: String) async {
        searchText = text
        await loadExercises()
    }
}
