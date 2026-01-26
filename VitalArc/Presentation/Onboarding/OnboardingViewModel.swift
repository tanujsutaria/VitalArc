//
//  OnboardingViewModel.swift
//  VitalArc
//
//  ViewModel for managing onboarding flow state
//

import Foundation
import SwiftUI

/// Steps in the onboarding flow
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case profileSetup = 1
    case healthKitPermission = 2
}

/// View model for managing onboarding state and user input
@Observable
final class OnboardingViewModel {
    private let userRepository: UserRepository
    private let createProfileUseCase: CreateUserProfileUseCase

    // MARK: - Onboarding State
    var currentStep: OnboardingStep = .welcome
    var isLoading = false
    var errorMessage: String?

    // MARK: - User Input
    var userName: String = ""
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    var selectedSex: BiologicalSex = .male
    var heightFeet: Int = 5       // American units for display
    var heightInches: Int = 10    // American units for display
    var weightLbs: Double = 154.0 // American units for display (lbs)
    var selectedActivityLevel: ActivityLevel = .moderate
    var selectedWeightGoal: WeightGoal = .maintain

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
        self.createProfileUseCase = CreateUserProfileUseCase(repository: userRepository)
    }

    // MARK: - Navigation

    func nextStep() {
        let nextStepRaw = currentStep.rawValue + 1
        guard nextStepRaw < OnboardingStep.allCases.count,
              let nextStep = OnboardingStep(rawValue: nextStepRaw) else {
            return
        }
        currentStep = nextStep
    }

    func previousStep() {
        let prevStepRaw = currentStep.rawValue - 1
        guard prevStepRaw >= 0,
              let prevStep = OnboardingStep(rawValue: prevStepRaw) else {
            return
        }
        currentStep = prevStep
    }

    // MARK: - Validation

    var canProceedFromProfileSetup: Bool {
        !userName.trimmingCharacters(in: .whitespaces).isEmpty &&
        heightFeet > 0 &&
        weightLbs > 0
    }

    // MARK: - Completion

    @MainActor
    func completeOnboarding() async throws {
        guard canProceedFromProfileSetup else {
            throw OnboardingError.invalidProfileData
        }

        isLoading = true
        errorMessage = nil

        do {
            // Convert American units to metric for internal storage (HealthKit compatibility)
            let heightCm = UnitConversion.feetInchesToCm(feet: heightFeet, inches: heightInches)
            let weightKg = UnitConversion.lbsToKg(weightLbs)

            // Create user profile
            let profile = UserProfile(
                name: userName.trimmingCharacters(in: .whitespaces),
                birthDate: birthDate,
                biologicalSex: selectedSex,
                height: heightCm,
                weight: weightKg,
                activityLevel: selectedActivityLevel,
                weightGoal: selectedWeightGoal
            )

            try await createProfileUseCase.execute(profile: profile)

            // Mark onboarding as completed
            await userRepository.setOnboardingCompleted(true)

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }

    @MainActor
    func skipHealthKitSetup() async {
        // Just complete onboarding without HealthKit
        do {
            try await completeOnboarding()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Errors

enum OnboardingError: LocalizedError {
    case invalidProfileData

    var errorDescription: String? {
        switch self {
        case .invalidProfileData:
            return "Please fill in all required fields with valid data."
        }
    }
}
