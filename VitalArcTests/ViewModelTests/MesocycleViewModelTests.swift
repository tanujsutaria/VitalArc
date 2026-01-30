//
//  MesocycleViewModelTests.swift
//  VitalArcTests
//
//  Unit tests for MesocycleViewModel
//

import XCTest
@testable import VitalArc

@MainActor
final class MesocycleViewModelTests: XCTestCase {

    var mockMesocycleRepository: MockMesocycleRepository!
    var mockWorkoutRepository: MockWorkoutRepository!
    var viewModel: MesocycleViewModel!

    override func setUp() {
        super.setUp()
        mockMesocycleRepository = MockMesocycleRepository()
        mockWorkoutRepository = MockWorkoutRepository()
        viewModel = MesocycleViewModel(
            mesocycleRepository: mockMesocycleRepository,
            workoutRepository: mockWorkoutRepository
        )
    }

    override func tearDown() {
        mockMesocycleRepository = nil
        mockWorkoutRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertTrue(viewModel.mesocycles.isEmpty)
        XCTAssertNil(viewModel.activeMesocycle)
        XCTAssertNil(viewModel.selectedMesocycle)
        XCTAssertNil(viewModel.progressSummary)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    // MARK: - Load Mesocycles Tests

    func testLoadMesocyclesSuccess() async {
        // Setup
        let mesocycle1 = MockMesocycleRepository.createSampleMesocycle(name: "Hypertrophy Block")
        let mesocycle2 = MockMesocycleRepository.createSampleMesocycle(name: "Strength Block")
        mockMesocycleRepository.mockMesocycles = [mesocycle1, mesocycle2]

        // Execute
        await viewModel.loadMesocycles()

        // Verify
        XCTAssertEqual(viewModel.mesocycles.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testLoadMesocyclesSetsActiveMesocycle() async {
        // Setup
        let activeMesocycle = MockMesocycleRepository.createSampleMesocycle(
            name: "Active Block",
            status: .active
        )
        mockMesocycleRepository.mockMesocycles = [activeMesocycle]
        mockMesocycleRepository.mockActiveMesocycle = activeMesocycle

        // Execute
        await viewModel.loadMesocycles()

        // Verify
        XCTAssertNotNil(viewModel.activeMesocycle)
        XCTAssertEqual(viewModel.activeMesocycle?.name, "Active Block")
    }

    func testLoadMesocyclesError() async {
        // Setup
        mockMesocycleRepository.shouldThrowOnGet = true

        // Execute
        await viewModel.loadMesocycles()

        // Verify
        XCTAssertTrue(viewModel.mesocycles.isEmpty)
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadMesocyclesSetsLoadingState() async {
        // Verify initial state
        XCTAssertFalse(viewModel.isLoading)

        // Execute
        await viewModel.loadMesocycles()

        // After completion
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Create Mesocycle Tests

    func testCreateMesocycleSuccess() async {
        // Execute
        await viewModel.createMesocycle(
            name: "New Mesocycle",
            startDate: Date(),
            durationWeeks: 4,
            goal: .hypertrophy,
            phaseTemplate: .linear,
            trainingBlocks: []
        )

        // Verify - use case should save and reload
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testCreateMesocycleError() async {
        // Setup
        mockMesocycleRepository.shouldThrowOnSave = true

        // Execute
        await viewModel.createMesocycle(
            name: "New Mesocycle",
            startDate: Date(),
            durationWeeks: 4,
            goal: .hypertrophy,
            phaseTemplate: .linear,
            trainingBlocks: []
        )

        // Verify
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Activate Mesocycle Tests

    func testActivateMesocycleSuccess() async {
        // Setup
        let mesocycle = MockMesocycleRepository.createSampleMesocycle(status: .planned)
        mockMesocycleRepository.mockMesocycles = [mesocycle]

        // Execute
        await viewModel.activateMesocycle(mesocycle)

        // Verify
        XCTAssertTrue(mockMesocycleRepository.activatedMesocycleIds.contains(mesocycle.id))
        XCTAssertNil(viewModel.error)
    }

    func testActivateMesocycleError() async {
        // Setup
        let mesocycle = MockMesocycleRepository.createSampleMesocycle()
        mockMesocycleRepository.shouldThrowOnActivate = true

        // Execute
        await viewModel.activateMesocycle(mesocycle)

        // Verify
        XCTAssertNotNil(viewModel.error)
    }

    // MARK: - Complete Mesocycle Tests

    func testCompleteMesocycleSuccess() async {
        // Setup
        let mesocycle = MockMesocycleRepository.createSampleMesocycle(status: .active)
        mockMesocycleRepository.mockMesocycles = [mesocycle]

        // Execute
        await viewModel.completeMesocycle(mesocycle)

        // Verify
        XCTAssertTrue(mockMesocycleRepository.completedMesocycleIds.contains(mesocycle.id))
        XCTAssertNil(viewModel.error)
    }

    func testCompleteMesocycleError() async {
        // Setup
        let mesocycle = MockMesocycleRepository.createSampleMesocycle()
        mockMesocycleRepository.shouldThrowOnComplete = true

        // Execute
        await viewModel.completeMesocycle(mesocycle)

        // Verify
        XCTAssertNotNil(viewModel.error)
    }

    // MARK: - Delete Mesocycle Tests

    func testDeleteMesocycleSuccess() async {
        // Setup
        let mesocycle = MockMesocycleRepository.createSampleMesocycle()
        mockMesocycleRepository.mockMesocycles = [mesocycle]
        await viewModel.loadMesocycles()
        XCTAssertEqual(viewModel.mesocycles.count, 1)

        // Execute
        await viewModel.deleteMesocycle(mesocycle)

        // Verify
        XCTAssertTrue(mockMesocycleRepository.deletedMesocycleIds.contains(mesocycle.id))
        XCTAssertNil(viewModel.error)
    }

    func testDeleteMesocycleError() async {
        // Setup
        let mesocycle = MockMesocycleRepository.createSampleMesocycle()
        mockMesocycleRepository.shouldThrowOnDelete = true

        // Execute
        await viewModel.deleteMesocycle(mesocycle)

        // Verify
        XCTAssertNotNil(viewModel.error)
    }

    // MARK: - Update Mesocycle Tests

    func testUpdateMesocycleSuccess() async {
        // Setup
        let mesocycle = MockMesocycleRepository.createSampleMesocycle()
        mockMesocycleRepository.mockMesocycles = [mesocycle]

        // Execute
        await viewModel.updateMesocycle(mesocycle)

        // Verify
        XCTAssertTrue(mockMesocycleRepository.updatedMesocycles.contains { $0.id == mesocycle.id })
        XCTAssertNil(viewModel.error)
    }

    func testUpdateMesocycleError() async {
        // Setup
        let mesocycle = MockMesocycleRepository.createSampleMesocycle()
        mockMesocycleRepository.shouldThrowOnUpdate = true

        // Execute
        await viewModel.updateMesocycle(mesocycle)

        // Verify
        XCTAssertNotNil(viewModel.error)
    }

    // MARK: - Get Mesocycles By Status Tests

    func testGetMesocyclesByStatusFiltersCorrectly() async {
        // Setup
        let planned = MockMesocycleRepository.createSampleMesocycle(name: "Planned", status: .planned)
        let active = MockMesocycleRepository.createSampleMesocycle(name: "Active", status: .active)
        let completed = MockMesocycleRepository.createSampleMesocycle(name: "Completed", status: .completed)
        mockMesocycleRepository.mockMesocycles = [planned, active, completed]
        await viewModel.loadMesocycles()

        // Execute & Verify
        let plannedResults = viewModel.getMesocyclesByStatus(.planned)
        XCTAssertEqual(plannedResults.count, 1)
        XCTAssertEqual(plannedResults.first?.name, "Planned")

        let activeResults = viewModel.getMesocyclesByStatus(.active)
        XCTAssertEqual(activeResults.count, 1)
        XCTAssertEqual(activeResults.first?.name, "Active")

        let completedResults = viewModel.getMesocyclesByStatus(.completed)
        XCTAssertEqual(completedResults.count, 1)
        XCTAssertEqual(completedResults.first?.name, "Completed")
    }

    func testGetMesocyclesByStatusReturnsEmptyForNoMatches() async {
        // Setup
        let planned = MockMesocycleRepository.createSampleMesocycle(status: .planned)
        mockMesocycleRepository.mockMesocycles = [planned]
        await viewModel.loadMesocycles()

        // Execute
        let results = viewModel.getMesocyclesByStatus(.active)

        // Verify
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Clear Error Tests

    func testClearErrorResetsError() async {
        // Setup - create an error state
        mockMesocycleRepository.shouldThrowOnGet = true
        await viewModel.loadMesocycles()
        XCTAssertNotNil(viewModel.error)

        // Execute
        viewModel.clearError()

        // Verify
        XCTAssertNil(viewModel.error)
    }

    // MARK: - Multiple Operations Tests

    func testMultipleOperationsInSequence() async {
        // Setup
        let mesocycle1 = MockMesocycleRepository.createSampleMesocycle(name: "Block 1", status: .planned)
        mockMesocycleRepository.mockMesocycles = [mesocycle1]

        // Load
        await viewModel.loadMesocycles()
        XCTAssertEqual(viewModel.mesocycles.count, 1)

        // Activate
        await viewModel.activateMesocycle(mesocycle1)
        XCTAssertTrue(mockMesocycleRepository.activatedMesocycleIds.contains(mesocycle1.id))

        // Complete
        await viewModel.completeMesocycle(mesocycle1)
        XCTAssertTrue(mockMesocycleRepository.completedMesocycleIds.contains(mesocycle1.id))

        // Delete
        await viewModel.deleteMesocycle(mesocycle1)
        XCTAssertTrue(mockMesocycleRepository.deletedMesocycleIds.contains(mesocycle1.id))
    }
}
