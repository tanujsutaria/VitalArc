//
//  ProfileViewModel.swift
//  VitalArc
//
//  ViewModel for Profile screen
//

import Foundation
import SwiftUI

@Observable
final class ProfileViewModel {
    private let userRepository: UserRepository
    private let updatePreferencesUseCase: UpdateUserPreferencesUseCase

    // MARK: - State
    var profile: UserProfile?
    var isLoading = false
    var errorMessage: String?
    var isEditMode = false

    // MARK: - Edit State
    var editName: String = ""
    var editBirthDate: Date = Date()
    var editSex: BiologicalSex = .male
    var editHeight: Double = 170.0
    var editWeight: Double = 70.0
    var editActivityLevel: ActivityLevel = .moderate
    var editWeightGoal: WeightGoal = .maintain

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
        self.updatePreferencesUseCase = UpdateUserPreferencesUseCase(repository: userRepository)
    }

    // MARK: - Profile Operations

    @MainActor
    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            profile = try await userRepository.getUserProfile()
            if let profile = profile {
                populateEditFields(from: profile)
            }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func startEditing() {
        guard let profile = profile else { return }
        populateEditFields(from: profile)
        isEditMode = true
    }

    func cancelEditing() {
        isEditMode = false
        errorMessage = nil
    }

    @MainActor
    func saveProfile() async {
        guard let currentProfile = profile else { return }

        isLoading = true
        errorMessage = nil

        do {
            let updatedProfile = UserProfile(
                id: currentProfile.id,
                name: editName.trimmingCharacters(in: .whitespaces),
                birthDate: editBirthDate,
                biologicalSex: editSex,
                height: editHeight,
                weight: editWeight,
                activityLevel: editActivityLevel,
                weightGoal: editWeightGoal,
                createdAt: currentProfile.createdAt,
                updatedAt: Date()
            )

            try await updatePreferencesUseCase.execute(profile: updatedProfile)
            profile = updatedProfile
            isEditMode = false
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers

    private func populateEditFields(from profile: UserProfile) {
        editName = profile.name
        editBirthDate = profile.birthDate
        editSex = profile.biologicalSex
        editHeight = profile.height
        editWeight = profile.weight
        editActivityLevel = profile.activityLevel
        editWeightGoal = profile.weightGoal
    }

    var canSave: Bool {
        !editName.trimmingCharacters(in: .whitespaces).isEmpty &&
        editHeight > 0 &&
        editWeight > 0
    }
}
