//
//  OnboardingViewModelTests.swift
//  VitalArcTests
//
//  Unit tests for OnboardingViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class OnboardingViewModelTests: XCTestCase {

    var repository: MockUserRepository!
    var viewModel: OnboardingViewModel!

    override func setUp() {
        super.setUp()
        repository = MockUserRepository()
        viewModel = OnboardingViewModel(userRepository: repository)
    }

    override func tearDown() {
        repository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialStepIsWelcome() {
        XCTAssertEqual(viewModel.currentStep, .welcome)
    }

    func testInitialLoadingIsFalse() {
        XCTAssertFalse(viewModel.isLoading)
    }

    func testInitialErrorMessageIsNil() {
        XCTAssertNil(viewModel.errorMessage)
    }

    func testDefaultUserNameIsEmpty() {
        XCTAssertEqual(viewModel.userName, "")
    }

    func testDefaultBirthDateIs25YearsAgo() {
        let calendar = Calendar.current
        let expectedYear = calendar.component(.year, from: Date()) - 25

        let birthYear = calendar.component(.year, from: viewModel.birthDate)

        XCTAssertEqual(birthYear, expectedYear)
    }

    // MARK: - Navigation Tests

    func testNextStepFromWelcome() {
        XCTAssertEqual(viewModel.currentStep, .welcome)

        viewModel.nextStep()

        XCTAssertEqual(viewModel.currentStep, .profileSetup)
    }

    func testNextStepFromProfileSetup() {
        viewModel.currentStep = .profileSetup

        viewModel.nextStep()

        XCTAssertEqual(viewModel.currentStep, .goalSetup)
    }

    func testNextStepFromGoalSetup() {
        viewModel.currentStep = .goalSetup

        viewModel.nextStep()

        XCTAssertEqual(viewModel.currentStep, .healthKitPermission)
    }

    func testNextStepFromLastStepDoesNothing() {
        viewModel.currentStep = .healthKitPermission

        viewModel.nextStep()

        XCTAssertEqual(viewModel.currentStep, .healthKitPermission)
    }

    func testPreviousStepFromProfileSetup() {
        viewModel.currentStep = .profileSetup

        viewModel.previousStep()

        XCTAssertEqual(viewModel.currentStep, .welcome)
    }

    func testPreviousStepFromGoalSetup() {
        viewModel.currentStep = .goalSetup

        viewModel.previousStep()

        XCTAssertEqual(viewModel.currentStep, .profileSetup)
    }

    func testPreviousStepFromHealthKit() {
        viewModel.currentStep = .healthKitPermission

        viewModel.previousStep()

        XCTAssertEqual(viewModel.currentStep, .goalSetup)
    }

    func testPreviousStepFromFirstStepDoesNothing() {
        viewModel.currentStep = .welcome

        viewModel.previousStep()

        XCTAssertEqual(viewModel.currentStep, .welcome)
    }

    // MARK: - Validation Tests

    func testCanProceedWithValidData() {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0

        XCTAssertTrue(viewModel.canProceedFromProfileSetup)
    }

    func testCannotProceedWithEmptyName() {
        viewModel.userName = ""
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0

        XCTAssertFalse(viewModel.canProceedFromProfileSetup)
    }

    func testCannotProceedWithWhitespaceOnlyName() {
        viewModel.userName = "   "
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0

        XCTAssertFalse(viewModel.canProceedFromProfileSetup)
    }

    func testCannotProceedWithZeroHeight() {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 0
        viewModel.heightInches = 0
        viewModel.weightLbs = 165.0

        XCTAssertFalse(viewModel.canProceedFromProfileSetup)
    }

    func testCannotProceedWithZeroWeight() {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 0

        XCTAssertFalse(viewModel.canProceedFromProfileSetup)
    }

    // MARK: - Complete Onboarding Tests

    func testCompleteOnboardingSuccess() async throws {
        viewModel.userName = "Test User"
        viewModel.birthDate = Date()
        viewModel.selectedSex = .male
        viewModel.heightFeet = 5
        viewModel.heightInches = 11
        viewModel.weightLbs = 165.0
        viewModel.selectedActivityLevel = .moderate
        viewModel.selectedWeightGoal = .maintain

        try await viewModel.completeOnboarding()

        XCTAssertNotNil(repository.savedProfile)
        XCTAssertTrue(repository.onboardingCompleted)
    }

    func testCompleteOnboardingCreatesProfile() async throws {
        viewModel.userName = "John Doe"
        viewModel.birthDate = Date()
        viewModel.selectedSex = .female
        viewModel.heightFeet = 5
        viewModel.heightInches = 6
        viewModel.weightLbs = 140.0
        viewModel.selectedActivityLevel = .light
        viewModel.selectedWeightGoal = .lose

        try await viewModel.completeOnboarding()

        XCTAssertEqual(repository.savedProfile?.name, "John Doe")
        XCTAssertEqual(repository.savedProfile?.biologicalSex, .female)
        XCTAssertEqual(repository.savedProfile?.activityLevel, .light)
        XCTAssertEqual(repository.savedProfile?.weightGoal, .lose)
    }

    func testCompleteOnboardingConvertsUnitsToMetric() async throws {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 6
        viewModel.heightInches = 0
        viewModel.weightLbs = 220.0

        try await viewModel.completeOnboarding()

        // 6'0" = ~183 cm, 220 lbs = ~100 kg
        let savedHeight = repository.savedProfile?.height ?? 0
        let savedWeight = repository.savedProfile?.weight ?? 0

        XCTAssertEqual(savedHeight, 182.88, accuracy: 0.1) // 6 feet in cm
        XCTAssertEqual(savedWeight, 99.79, accuracy: 0.1)  // 220 lbs in kg
    }

    func testCompleteOnboardingMarksOnboardingComplete() async throws {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0

        try await viewModel.completeOnboarding()

        XCTAssertEqual(repository.setOnboardingCompletedCallCount, 1)
        XCTAssertTrue(repository.onboardingCompleted)
    }

    func testCompleteOnboardingWithInvalidDataThrows() async {
        viewModel.userName = ""
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0

        do {
            try await viewModel.completeOnboarding()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is OnboardingError)
        }
    }

    func testCompleteOnboardingHandlesRepositoryError() async {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0
        repository.shouldThrowOnSave = true

        do {
            try await viewModel.completeOnboarding()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(viewModel.errorMessage)
            XCTAssertFalse(viewModel.isLoading)
        }
    }

    // MARK: - Skip HealthKit Tests

    func testSkipHealthKitCallsCompleteOnboarding() async {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0

        await viewModel.skipHealthKitSetup()

        XCTAssertNotNil(repository.savedProfile)
        XCTAssertTrue(repository.onboardingCompleted)
    }

    func testSkipHealthKitHandlesError() async {
        viewModel.userName = ""
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0

        await viewModel.skipHealthKitSetup()

        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - TDEE Computation Tests

    func testComputeTDEEResultReturnsValidResult() {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0
        viewModel.selectedSex = .male
        viewModel.selectedActivityLevel = .moderate
        viewModel.selectedWeightGoal = .maintain

        let result = viewModel.computeTDEEResult()

        XCTAssertGreaterThan(result.bmr, 0)
        XCTAssertGreaterThan(result.tdee, 0)
        XCTAssertEqual(result.adjustedCalories, result.tdee) // maintain = no adjustment
        XCTAssertEqual(result.deficit, 0)
        XCTAssertGreaterThan(result.proteinGoal, 0)
        XCTAssertGreaterThan(result.fatGoal, 0)
        XCTAssertGreaterThan(result.carbGoal, 0)
    }

    func testComputeTDEEResultWithWeightLossGoal() {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0
        viewModel.selectedSex = .male
        viewModel.selectedActivityLevel = .moderate
        viewModel.selectedWeightGoal = .lose

        let result = viewModel.computeTDEEResult()

        XCTAssertLessThan(result.adjustedCalories, result.tdee)
        XCTAssertLessThan(result.deficit, 0)
    }

    func testComputeTDEEResultWithWeightGainGoal() {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0
        viewModel.selectedSex = .male
        viewModel.selectedActivityLevel = .moderate
        viewModel.selectedWeightGoal = .gain

        let result = viewModel.computeTDEEResult()

        XCTAssertGreaterThan(result.adjustedCalories, result.tdee)
        XCTAssertGreaterThan(result.deficit, 0)
    }

    // MARK: - Loading State Tests

    func testCompleteOnboardingSetsLoading() async throws {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0

        // Capture loading state during execution
        let expectation = XCTestExpectation(description: "Loading should be set")

        Task {
            // Start completion
            try await viewModel.completeOnboarding()
            expectation.fulfill()
        }

        // After completion, loading should be false
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testCompleteOnboardingClearsLoadingOnError() async {
        viewModel.userName = "Test User"
        viewModel.heightFeet = 5
        viewModel.heightInches = 10
        viewModel.weightLbs = 165.0
        repository.shouldThrowOnSave = true

        do {
            try await viewModel.completeOnboarding()
        } catch {
            // Expected
        }

        XCTAssertFalse(viewModel.isLoading)
    }
}
