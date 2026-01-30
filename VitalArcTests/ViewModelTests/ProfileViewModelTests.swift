//
//  ProfileViewModelTests.swift
//  VitalArcTests
//
//  Unit tests for ProfileViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class ProfileViewModelTests: XCTestCase {

    var userRepository: MockUserRepository!
    var healthRepository: MockHealthRepository!
    var viewModel: ProfileViewModel!

    override func setUp() {
        super.setUp()
        userRepository = MockUserRepository()
        healthRepository = MockHealthRepository()
        viewModel = ProfileViewModel(
            userRepository: userRepository,
            healthRepository: healthRepository
        )
    }

    override func tearDown() {
        userRepository = nil
        healthRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func createSampleProfile(
        name: String = "Test User",
        height: Double = 180.0,  // cm
        weight: Double = 75.0,   // kg
        activityLevel: ActivityLevel = .moderate,
        weightGoal: WeightGoal = .maintain,
        customHRMax: Int? = nil,
        customHRResting: Int? = nil
    ) -> UserProfile {
        return UserProfile(
            name: name,
            birthDate: Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date(),
            biologicalSex: .male,
            height: height,
            weight: weight,
            activityLevel: activityLevel,
            weightGoal: weightGoal,
            customHRMax: customHRMax,
            customHRResting: customHRResting
        )
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertNil(viewModel.profile)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isEditMode)
    }

    func testInitialStateWithNoHealthRepository() {
        let vmNoHealth = ProfileViewModel(userRepository: userRepository)

        XCTAssertNil(vmNoHealth.profile)
        XCTAssertFalse(vmNoHealth.isLoading)
    }

    // MARK: - Load Profile Tests

    func testLoadProfileSuccess() async {
        let profile = createSampleProfile()
        userRepository.savedProfile = profile
        healthRepository.mockAuthorizationSuccess = true

        await viewModel.loadProfile()

        XCTAssertNotNil(viewModel.profile)
        XCTAssertEqual(viewModel.profile?.name, "Test User")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadProfilePopulatesEditFields() async {
        let profile = createSampleProfile(name: "John Doe", height: 182.88, weight: 90.0)
        userRepository.savedProfile = profile
        healthRepository.mockAuthorizationSuccess = true

        await viewModel.loadProfile()

        XCTAssertEqual(viewModel.editName, "John Doe")
        // 182.88 cm = 6'0"
        XCTAssertEqual(viewModel.editHeightFeet, 6)
        XCTAssertEqual(viewModel.editHeightInches, 0)
        // 90 kg = ~198 lbs
        XCTAssertEqual(viewModel.editWeightLbs, UnitConversion.kgToLbs(90.0), accuracy: 0.1)
    }

    func testLoadProfileWithNoProfile() async {
        userRepository.savedProfile = nil
        healthRepository.mockAuthorizationSuccess = true

        await viewModel.loadProfile()

        XCTAssertNil(viewModel.profile)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadProfileHandlesError() async {
        userRepository.shouldThrowOnSave = true
        // Using a fresh repository that will throw on getUserProfile
        let throwingRepo = ThrowingMockUserRepository()
        let vm = ProfileViewModel(userRepository: throwingRepo)

        await vm.loadProfile()

        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Edit Mode Tests

    func testStartEditingPopulatesFields() {
        let profile = createSampleProfile(name: "Jane Smith")
        viewModel.profile = profile

        viewModel.startEditing()

        XCTAssertTrue(viewModel.isEditMode)
        XCTAssertEqual(viewModel.editName, "Jane Smith")
    }

    func testStartEditingConvertsUnitsToAmerican() {
        let profile = createSampleProfile(height: 175.26, weight: 68.0)  // 5'9", 150 lbs
        viewModel.profile = profile

        viewModel.startEditing()

        XCTAssertEqual(viewModel.editHeightFeet, 5)
        XCTAssertEqual(viewModel.editHeightInches, 9)
        XCTAssertEqual(viewModel.editWeightLbs, UnitConversion.kgToLbs(68.0), accuracy: 0.1)
    }

    func testCancelEditingClearsError() {
        viewModel.isEditMode = true
        viewModel.errorMessage = "Some error"

        viewModel.cancelEditing()

        XCTAssertNil(viewModel.errorMessage)
    }

    func testCancelEditingExitsEditMode() {
        viewModel.isEditMode = true

        viewModel.cancelEditing()

        XCTAssertFalse(viewModel.isEditMode)
    }

    // MARK: - Save Profile Tests

    func testSaveProfileSuccess() async {
        let profile = createSampleProfile()
        viewModel.profile = profile
        viewModel.editName = "Updated Name"
        viewModel.editHeightFeet = 6
        viewModel.editHeightInches = 2
        viewModel.editWeightLbs = 200.0
        viewModel.editActivityLevel = .very
        viewModel.editWeightGoal = .gain
        viewModel.isEditMode = true

        await viewModel.saveProfile()

        XCTAssertEqual(viewModel.profile?.name, "Updated Name")
        XCTAssertEqual(viewModel.profile?.activityLevel, .very)
        XCTAssertEqual(viewModel.profile?.weightGoal, .gain)
        XCTAssertFalse(viewModel.isEditMode)
    }

    func testSaveProfileConvertsUnitsToMetric() async {
        let profile = createSampleProfile()
        viewModel.profile = profile
        viewModel.editName = "Test"
        viewModel.editHeightFeet = 6
        viewModel.editHeightInches = 0  // 6'0" = 182.88 cm
        viewModel.editWeightLbs = 220.0  // ~99.79 kg

        await viewModel.saveProfile()

        // Verify metric storage
        XCTAssertEqual(viewModel.profile?.height ?? 0, 182.88, accuracy: 0.1)
        XCTAssertEqual(viewModel.profile?.weight ?? 0, 99.79, accuracy: 0.1)
    }

    func testSaveProfileHandlesError() async {
        let profile = createSampleProfile()
        viewModel.profile = profile
        viewModel.editName = "Test"
        viewModel.editHeightFeet = 5
        viewModel.editHeightInches = 10
        viewModel.editWeightLbs = 165.0
        userRepository.shouldThrowOnUpdate = true

        await viewModel.saveProfile()

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSaveProfileExitsEditMode() async {
        let profile = createSampleProfile()
        viewModel.profile = profile
        viewModel.editName = "Test"
        viewModel.editHeightFeet = 5
        viewModel.editHeightInches = 10
        viewModel.editWeightLbs = 165.0
        viewModel.isEditMode = true

        await viewModel.saveProfile()

        XCTAssertFalse(viewModel.isEditMode)
    }

    func testSaveProfileWithCustomHRSettings() async {
        let profile = createSampleProfile()
        viewModel.profile = profile
        viewModel.editName = "Test"
        viewModel.editHeightFeet = 5
        viewModel.editHeightInches = 10
        viewModel.editWeightLbs = 165.0
        viewModel.editCustomHRMax = "185"
        viewModel.editCustomHRResting = "55"

        await viewModel.saveProfile()

        XCTAssertEqual(viewModel.profile?.customHRMax, 185)
        XCTAssertEqual(viewModel.profile?.customHRResting, 55)
    }

    // MARK: - Validation Tests

    func testCanSaveWithValidData() {
        viewModel.editName = "Test User"
        viewModel.editHeightFeet = 5
        viewModel.editHeightInches = 10
        viewModel.editWeightLbs = 165.0

        XCTAssertTrue(viewModel.canSave)
    }

    func testCanSaveWithEmptyName() {
        viewModel.editName = ""
        viewModel.editHeightFeet = 5
        viewModel.editHeightInches = 10
        viewModel.editWeightLbs = 165.0

        XCTAssertFalse(viewModel.canSave)
    }

    func testCanSaveWithZeroHeight() {
        viewModel.editName = "Test User"
        viewModel.editHeightFeet = 0
        viewModel.editHeightInches = 0
        viewModel.editWeightLbs = 165.0

        XCTAssertFalse(viewModel.canSave)
    }

    func testCanSaveWithZeroWeight() {
        viewModel.editName = "Test User"
        viewModel.editHeightFeet = 5
        viewModel.editHeightInches = 10
        viewModel.editWeightLbs = 0

        XCTAssertFalse(viewModel.canSave)
    }

    // MARK: - Unit Conversion Tests

    func testDisplayWeightFormatsCorrectly() {
        let profile = createSampleProfile(weight: 75.0)  // 75 kg = ~165.3 lbs
        viewModel.profile = profile

        let display = viewModel.displayWeight

        XCTAssertTrue(display.contains("lbs"))
        XCTAssertTrue(display.contains("165"))
    }

    func testDisplayHeightFormatsCorrectly() {
        let profile = createSampleProfile(height: 180.0)  // ~5'11"
        viewModel.profile = profile

        let display = viewModel.displayHeight

        XCTAssertTrue(display.contains("5'"))
        XCTAssertTrue(display.contains("11\""))
    }

    func testDisplayWeightWithNoProfile() {
        viewModel.profile = nil

        XCTAssertEqual(viewModel.displayWeight, "-")
    }

    func testDisplayHeightWithNoProfile() {
        viewModel.profile = nil

        XCTAssertEqual(viewModel.displayHeight, "-")
    }

    // MARK: - HealthKit Sync Tests

    func testSyncFromHealthKitSuccess() async {
        let profile = createSampleProfile(weight: 75.0)
        userRepository.savedProfile = profile
        viewModel.profile = profile
        healthRepository.mockAuthorizationSuccess = true
        healthRepository.mockTodayMetrics = MockHealthRepository.createSampleMetrics(weight: 76.0)

        await viewModel.syncFromHealthKit()

        XCTAssertTrue(viewModel.isHealthKitAvailable)
        XCTAssertEqual(viewModel.healthKitWeight, 76.0)
    }

    func testSyncFromHealthKitUpdatesWeight() async {
        let profile = createSampleProfile(weight: 75.0)
        userRepository.savedProfile = profile
        viewModel.profile = profile
        viewModel.useManualWeight = false
        healthRepository.mockAuthorizationSuccess = true
        healthRepository.mockTodayMetrics = MockHealthRepository.createSampleMetrics(weight: 77.5)

        await viewModel.syncFromHealthKit()

        // Weight should be updated from HealthKit
        XCTAssertEqual(viewModel.profile?.weight ?? 0, 77.5, accuracy: 0.1)
    }

    func testSyncFromHealthKitAuthorizationDenied() async {
        let profile = createSampleProfile()
        viewModel.profile = profile
        healthRepository.mockAuthorizationSuccess = false

        await viewModel.syncFromHealthKit()

        XCTAssertFalse(viewModel.isHealthKitAvailable)
    }

    func testSyncFromHealthKitNoHealthRepository() async {
        let vmNoHealth = ProfileViewModel(userRepository: userRepository)

        await vmNoHealth.syncFromHealthKit()

        // Should complete without error
        XCTAssertNil(vmNoHealth.healthKitWeight)
    }

    // MARK: - TDEE Tests

    func testLoadTDEEWithNoUseCase() {
        let vmNoTDEE = ProfileViewModel(userRepository: userRepository)
        let profile = createSampleProfile()

        vmNoTDEE.loadTDEE(for: profile)

        XCTAssertNil(vmNoTDEE.tdeeResult)
    }

    // MARK: - Heart Rate Display Tests

    func testDisplayHRMaxWithCustomValue() {
        let profile = createSampleProfile(customHRMax: 190)
        viewModel.profile = profile

        let display = viewModel.displayHRMax

        XCTAssertTrue(display.contains("190"))
        XCTAssertTrue(display.contains("custom"))
    }

    func testDisplayHRMaxWithEstimated() {
        let profile = createSampleProfile(customHRMax: nil)
        viewModel.profile = profile

        let display = viewModel.displayHRMax

        XCTAssertTrue(display.contains("estimated"))
    }

    func testDisplayHRRestingWithCustomValue() {
        let profile = createSampleProfile(customHRResting: 55)
        viewModel.profile = profile

        let display = viewModel.displayHRResting

        XCTAssertTrue(display.contains("55"))
        XCTAssertTrue(display.contains("custom"))
    }

    func testDisplayHRRestingWithDefault() {
        let profile = createSampleProfile(customHRResting: nil)
        viewModel.profile = profile

        let display = viewModel.displayHRResting

        XCTAssertTrue(display.contains("default"))
    }

    // MARK: - Weight Source Tests

    func testWeightSourceFromHealthKit() {
        viewModel.healthKitWeight = 75.0
        viewModel.useManualWeight = false

        XCTAssertEqual(viewModel.weightSource, "from Apple Health")
    }

    func testWeightSourceManualEntry() {
        viewModel.healthKitWeight = nil
        viewModel.useManualWeight = false

        XCTAssertEqual(viewModel.weightSource, "manual entry")
    }

    func testWeightSourceManualOverride() {
        viewModel.healthKitWeight = 75.0
        viewModel.useManualWeight = true

        XCTAssertEqual(viewModel.weightSource, "manual entry")
    }
}

// MARK: - Throwing Mock Repository

private class ThrowingMockUserRepository: UserRepository {
    func getUserProfile() async throws -> UserProfile? {
        throw MockRepositoryError.notFound
    }

    func saveUserProfile(_ profile: UserProfile) async throws {
        throw MockRepositoryError.saveFailed
    }

    func updateUserProfile(_ profile: UserProfile) async throws {
        throw MockRepositoryError.updateFailed
    }

    func deleteUserProfile() async throws {
        throw MockRepositoryError.deleteFailed
    }

    func hasCompletedOnboarding() async -> Bool {
        return false
    }

    func setOnboardingCompleted(_ completed: Bool) async {}
}
