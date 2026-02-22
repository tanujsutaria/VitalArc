//
//  ProfileTests.swift
//  VitalArcTests
//
//  Tests for User Profile & Settings Module
//

import XCTest
@testable import VitalArc

final class ProfileTests: XCTestCase {

    // MARK: - UserProfile Entity Tests

    func testUserProfileAgeCalculation() {
        // Given
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -25, to: Date())!

        let profile = UserProfile(
            name: "Test User",
            birthDate: birthDate,
            biologicalSex: .male,
            height: 180.0,
            weight: 75.0,
            activityLevel: .moderate
        )

        // Then
        XCTAssertEqual(profile.age, 25)
    }

    func testUserProfileBMICalculation() {
        // Given
        let profile = UserProfile(
            name: "Test User",
            birthDate: Date(),
            biologicalSex: .male,
            height: 180.0, // 1.8m
            weight: 75.0,  // 75kg
            activityLevel: .moderate
        )

        // BMI = 75 / (1.8^2) = 75 / 3.24 = 23.15
        // Then
        XCTAssertEqual(profile.bmi, 23.15, accuracy: 0.01)
    }

    func testUserProfileCalorieGoalForWeightLoss() {
        // Given
        let profile = UserProfile(
            name: "Test User",
            birthDate: Date(),
            biologicalSex: .male,
            height: 180.0,
            weight: 75.0,
            activityLevel: .moderate,
            weightGoal: .lose
        )

        // Maintenance = 75 * 33 = 2475
        // Deficit = 2475 - 500 = 1975
        // Then
        XCTAssertEqual(profile.estimatedCalorieGoal, 1975.0)
    }

    func testUserProfileCalorieGoalForMaintenance() {
        // Given
        let profile = UserProfile(
            name: "Test User",
            birthDate: Date(),
            biologicalSex: .male,
            height: 180.0,
            weight: 75.0,
            activityLevel: .moderate,
            weightGoal: .maintain
        )

        // Maintenance = 75 * 33 = 2475
        // Then
        XCTAssertEqual(profile.estimatedCalorieGoal, 2475.0)
    }

    func testUserProfileCalorieGoalForWeightGain() {
        // Given
        let profile = UserProfile(
            name: "Test User",
            birthDate: Date(),
            biologicalSex: .male,
            height: 180.0,
            weight: 75.0,
            activityLevel: .moderate,
            weightGoal: .gain
        )

        // Maintenance = 75 * 33 = 2475
        // Surplus = 2475 + 500 = 2975
        // Then
        XCTAssertEqual(profile.estimatedCalorieGoal, 2975.0)
    }

    // MARK: - CreateUserProfileUseCase Tests

    func testCreateUserProfile() async throws {
        // Given
        let repository = MockUserRepository()
        let useCase = CreateUserProfileUseCase(repository: repository)

        let profile = UserProfile(
            name: "John Doe",
            birthDate: Date(),
            biologicalSex: .male,
            height: 180.0,
            weight: 75.0,
            activityLevel: .moderate
        )

        // When
        try await useCase.execute(profile: profile)

        // Then
        XCTAssertNotNil(repository.savedProfile)
        XCTAssertEqual(repository.savedProfile?.name, "John Doe")
        XCTAssertEqual(repository.savedProfile?.height, 180.0)
    }

    // MARK: - UpdateUserPreferencesUseCase Tests

    func testUpdateUserPreferences() async throws {
        // Given
        let repository = MockUserRepository()
        let existingProfile = UserProfile(
            name: "John Doe",
            birthDate: Date(),
            biologicalSex: .male,
            height: 180.0,
            weight: 75.0,
            activityLevel: .moderate
        )
        repository.savedProfile = existingProfile

        let useCase = UpdateUserPreferencesUseCase(repository: repository)

        let updatedProfile = UserProfile(
            id: existingProfile.id,
            name: "John Doe Updated",
            birthDate: existingProfile.birthDate,
            biologicalSex: existingProfile.biologicalSex,
            height: existingProfile.height,
            weight: 80.0, // Updated weight
            activityLevel: .very, // Updated activity level
            weightGoal: .lose, // Updated goal
            createdAt: existingProfile.createdAt,
            updatedAt: Date()
        )

        // When
        try await useCase.execute(profile: updatedProfile)

        // Then
        XCTAssertEqual(repository.savedProfile?.weight, 80.0)
        XCTAssertEqual(repository.savedProfile?.activityLevel, .very)
        XCTAssertEqual(repository.savedProfile?.weightGoal, .lose)
    }

    // MARK: - OnboardingViewModel Tests

    @MainActor
    func testOnboardingCompletionFlow() async throws {
        // Given
        let repository = MockUserRepository()
        repository.onboardingCompleted = false

        let viewModel = OnboardingViewModel(userRepository: repository)

        // When - Complete onboarding steps
        viewModel.userName = "Test User"
        viewModel.birthDate = Date()
        viewModel.selectedSex = .male
        viewModel.heightFeet = 5      // ~180cm = 5'11"
        viewModel.heightInches = 11
        viewModel.weightLbs = 165.0   // ~75kg = 165lbs
        viewModel.selectedActivityLevel = .moderate
        viewModel.selectedWeightGoal = .maintain

        try await viewModel.completeOnboarding()

        // Then
        XCTAssertTrue(repository.onboardingCompleted)
        XCTAssertNotNil(repository.savedProfile)
        XCTAssertEqual(repository.savedProfile?.name, "Test User")
    }

    @MainActor
    func testOnboardingNavigationSteps() {
        // Given
        let repository = MockUserRepository()
        let viewModel = OnboardingViewModel(userRepository: repository)

        // When/Then - Test step progression
        XCTAssertEqual(viewModel.currentStep, .welcome)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .profileSetup)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .goalSetup)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .healthKitPermission)

        // Test going back
        viewModel.previousStep()
        XCTAssertEqual(viewModel.currentStep, .goalSetup)
    }

    @MainActor
    func testOnboardingValidation() {
        // Given
        let repository = MockUserRepository()
        let viewModel = OnboardingViewModel(userRepository: repository)

        // When - Empty name
        viewModel.userName = ""

        // Then
        XCTAssertFalse(viewModel.canProceedFromProfileSetup)

        // When - Valid data
        viewModel.userName = "Test User"
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0

        // Then
        XCTAssertTrue(viewModel.canProceedFromProfileSetup)
    }
}

// Note: MockUserRepository is defined in VitalArcTests/Mocks/MockUserRepository.swift
