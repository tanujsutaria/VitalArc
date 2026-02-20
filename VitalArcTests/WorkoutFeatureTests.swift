//
//  WorkoutFeatureTests.swift
//  VitalArcTests
//
//  Tests for Session 23.1 workout features: supersets/circuits, rest timer, plate calculator
//

import XCTest
@testable import VitalArc

// MARK: - SetGroup Entity Tests

final class SetGroupTests: XCTestCase {
    func testSetGroupCreationWithDefaults() {
        let ids = [UUID(), UUID()]
        let group = SetGroup(groupType: .superset, exerciseIds: ids)

        XCTAssertEqual(group.groupType, .superset)
        XCTAssertEqual(group.exerciseIds.count, 2)
        XCTAssertEqual(group.restBetweenExercises, 30)
        XCTAssertEqual(group.restAfterGroup, 90)
        XCTAssertNil(group.name)
    }

    func testSetGroupCreationWithCustomRest() {
        let ids = [UUID(), UUID(), UUID()]
        let group = SetGroup(
            groupType: .circuit,
            exerciseIds: ids,
            restBetweenExercises: 15,
            restAfterGroup: 120
        )

        XCTAssertEqual(group.groupType, .circuit)
        XCTAssertEqual(group.exerciseIds.count, 3)
        XCTAssertEqual(group.restBetweenExercises, 15)
        XCTAssertEqual(group.restAfterGroup, 120)
    }

    func testSetGroupTypeEnum() {
        // All cases exist
        XCTAssertEqual(SetGroupType.allCases.count, 4)
        XCTAssertTrue(SetGroupType.allCases.contains(.superset))
        XCTAssertTrue(SetGroupType.allCases.contains(.circuit))
        XCTAssertTrue(SetGroupType.allCases.contains(.giantSet))
        XCTAssertTrue(SetGroupType.allCases.contains(.dropSet))
    }

    func testSetGroupTypeRawValues() {
        XCTAssertEqual(SetGroupType.superset.rawValue, "Superset")
        XCTAssertEqual(SetGroupType.circuit.rawValue, "Circuit")
        XCTAssertEqual(SetGroupType.giantSet.rawValue, "Giant Set")
        XCTAssertEqual(SetGroupType.dropSet.rawValue, "Drop Set")
    }

    func testSetGroupTypeIcons() {
        // Each type has a non-empty icon
        for type in SetGroupType.allCases {
            XCTAssertFalse(type.icon.isEmpty, "\(type) should have an icon")
        }
    }

    func testSetGroupDisplayNameWithCustomName() {
        let group = SetGroup(
            name: "Chest Superset",
            groupType: .superset,
            exerciseIds: [UUID(), UUID()]
        )
        XCTAssertEqual(group.displayName, "Chest Superset")
    }

    func testSetGroupDisplayNameDefault() {
        let group = SetGroup(
            groupType: .circuit,
            exerciseIds: [UUID(), UUID(), UUID()]
        )
        XCTAssertEqual(group.displayName, "Circuit (3 exercises)")
    }

    func testDropSetDisplayName() {
        let group = SetGroup(
            groupType: .dropSet,
            exerciseIds: [UUID(), UUID()]
        )
        XCTAssertEqual(group.displayName, "Drop Set (2 exercises)")
    }

    func testSetGroupEquality() {
        let id = UUID()
        let ids = [UUID(), UUID()]
        let group1 = SetGroup(id: id, groupType: .superset, exerciseIds: ids)
        let group2 = SetGroup(id: id, groupType: .superset, exerciseIds: ids)
        XCTAssertEqual(group1, group2)
    }

    func testSetGroupTypeCodable() throws {
        let type = SetGroupType.dropSet
        let data = try JSONEncoder().encode(type)
        let decoded = try JSONDecoder().decode(SetGroupType.self, from: data)
        XCTAssertEqual(decoded, type)
    }
}

// MARK: - SetGroupModel Tests

final class SetGroupModelTests: XCTestCase {
    func testFromDomainAndToDomain() {
        let exerciseIds = [UUID(), UUID()]
        let domain = SetGroup(
            name: "Test Group",
            groupType: .circuit,
            exerciseIds: exerciseIds,
            restBetweenExercises: 20,
            restAfterGroup: 60
        )

        let model = SetGroupModel.fromDomain(domain)
        let roundTripped = model.toDomain()

        XCTAssertEqual(roundTripped.id, domain.id)
        XCTAssertEqual(roundTripped.name, "Test Group")
        XCTAssertEqual(roundTripped.groupType, .circuit)
        XCTAssertEqual(roundTripped.exerciseIds, exerciseIds)
        XCTAssertEqual(roundTripped.restBetweenExercises, 20)
        XCTAssertEqual(roundTripped.restAfterGroup, 60)
    }

    func testFromDomainDropSet() {
        let domain = SetGroup(
            groupType: .dropSet,
            exerciseIds: [UUID()]
        )

        let model = SetGroupModel.fromDomain(domain)
        XCTAssertEqual(model.groupType, "Drop Set")

        let roundTripped = model.toDomain()
        XCTAssertEqual(roundTripped.groupType, .dropSet)
    }

    func testToDomainWithInvalidGroupType() {
        let model = SetGroupModel(
            groupType: "Invalid",
            exerciseIds: [UUID()]
        )
        // Should default to .superset
        let domain = model.toDomain()
        XCTAssertEqual(domain.groupType, .superset)
    }
}

// MARK: - Rest Timer Tests

@MainActor
final class RestTimerTests: XCTestCase {
    func testRestTimerViewModelDefaults() {
        let vm = RestTimerViewModel()
        XCTAssertEqual(vm.defaultRestDuration, 90)
        XCTAssertEqual(vm.progressiveRestIncrement, 0)
        XCTAssertTrue(vm.exerciseRestDurations.isEmpty)
        XCTAssertTrue(vm.completedSetCounts.isEmpty)
    }

    func testSetRestDurationForExercise() {
        let vm = RestTimerViewModel()
        let exerciseId = UUID()
        vm.setRestDuration(120, for: exerciseId)
        XCTAssertEqual(vm.exerciseRestDurations[exerciseId], 120)
    }

    func testEffectiveRestDurationWithoutProgressive() {
        let vm = RestTimerViewModel()
        let exerciseId = UUID()
        vm.setRestDuration(120, for: exerciseId)

        // No progressive increment
        XCTAssertEqual(vm.effectiveRestDuration(for: exerciseId), 120)
    }

    func testEffectiveRestDurationWithProgressive() {
        let vm = RestTimerViewModel()
        let exerciseId = UUID()
        vm.defaultRestDuration = 90
        vm.progressiveRestIncrement = 15

        // First set → base duration (no completed sets yet)
        XCTAssertEqual(vm.effectiveRestDuration(for: exerciseId), 90)

        // Record one completed set
        vm.recordCompletedSet(for: exerciseId)
        // After 1 completed set → 90 + 15*1 = 105
        XCTAssertEqual(vm.effectiveRestDuration(for: exerciseId), 105)

        // Record another completed set
        vm.recordCompletedSet(for: exerciseId)
        // After 2 completed sets → 90 + 15*2 = 120
        XCTAssertEqual(vm.effectiveRestDuration(for: exerciseId), 120)
    }

    func testEffectiveRestDurationUsesDefaultWhenNoOverride() {
        let vm = RestTimerViewModel()
        let exerciseId = UUID()
        vm.defaultRestDuration = 60

        XCTAssertEqual(vm.effectiveRestDuration(for: exerciseId), 60)
    }

    func testRecordCompletedSet() {
        let vm = RestTimerViewModel()
        let ex1 = UUID()
        let ex2 = UUID()

        vm.recordCompletedSet(for: ex1)
        vm.recordCompletedSet(for: ex1)
        vm.recordCompletedSet(for: ex2)

        XCTAssertEqual(vm.completedSetCounts[ex1], 2)
        XCTAssertEqual(vm.completedSetCounts[ex2], 1)
    }

    func testResetCounts() {
        let vm = RestTimerViewModel()
        let exerciseId = UUID()
        vm.recordCompletedSet(for: exerciseId)
        XCTAssertFalse(vm.completedSetCounts.isEmpty)

        vm.resetCounts()
        XCTAssertTrue(vm.completedSetCounts.isEmpty)
    }

    func testProgressiveRestDurationStaticMethod() {
        // No increment
        XCTAssertEqual(RestTimerViewModel.progressiveRestDuration(baseDuration: 90, increment: 0, setNumber: 3), 90)

        // First set always gets base
        XCTAssertEqual(RestTimerViewModel.progressiveRestDuration(baseDuration: 90, increment: 15, setNumber: 1), 90)

        // Second set: 90 + 15*(2-1) = 105
        XCTAssertEqual(RestTimerViewModel.progressiveRestDuration(baseDuration: 90, increment: 15, setNumber: 2), 105)

        // Fifth set: 90 + 15*(5-1) = 150
        XCTAssertEqual(RestTimerViewModel.progressiveRestDuration(baseDuration: 90, increment: 15, setNumber: 5), 150)
    }

    func testFormatDuration() {
        XCTAssertEqual(RestTimerViewModel.formatDuration(30), "30s")
        XCTAssertEqual(RestTimerViewModel.formatDuration(60), "1m")
        XCTAssertEqual(RestTimerViewModel.formatDuration(90), "1m 30s")
        XCTAssertEqual(RestTimerViewModel.formatDuration(120), "2m")
        XCTAssertEqual(RestTimerViewModel.formatDuration(300), "5m")
    }

    func testRestPresets() {
        XCTAssertEqual(RestTimerViewModel.restPresets, [30, 60, 90, 120, 180, 300])
    }

    func testProgressivePresets() {
        XCTAssertEqual(RestTimerViewModel.progressivePresets, [0, 10, 15, 30])
    }
}

// MARK: - Rest Timer Integration with WorkoutLoggingViewModel

@MainActor
final class RestTimerIntegrationTests: XCTestCase {
    var repository: MockWorkoutRepository!
    var viewModel: WorkoutLoggingViewModel!

    override func setUp() async throws {
        repository = MockWorkoutRepository()
        let createUseCase = CreateWorkoutUseCase(repository: repository)
        let progressionUseCase = CalculateProgressionUseCase(repository: repository)
        viewModel = WorkoutLoggingViewModel(
            createWorkoutUseCase: createUseCase,
            calculateProgressionUseCase: progressionUseCase
        )
    }

    func testStartRestTimerSetsState() {
        let exerciseId = UUID()
        viewModel.startRestTimer(duration: 90, for: exerciseId)

        XCTAssertTrue(viewModel.restTimerActive)
        XCTAssertNotNil(viewModel.restTimerEndDate)
        XCTAssertEqual(viewModel.restTimerExerciseId, exerciseId)
    }

    func testCancelRestTimerClearsState() {
        let exerciseId = UUID()
        viewModel.startRestTimer(duration: 90, for: exerciseId)
        viewModel.cancelRestTimer()

        XCTAssertFalse(viewModel.restTimerActive)
        XCTAssertNil(viewModel.restTimerEndDate)
        XCTAssertNil(viewModel.restTimerExerciseId)
    }

    func testRestTimerFinishedClearsState() {
        let exerciseId = UUID()
        viewModel.startRestTimer(duration: 90, for: exerciseId)
        viewModel.restTimerFinished()

        XCTAssertFalse(viewModel.restTimerActive)
        XCTAssertNil(viewModel.restTimerEndDate)
    }

    func testProgressiveRestIncrements() {
        let exerciseId = UUID()
        viewModel.progressiveRestIncrement = 15

        // First set: base 90 + 0 progressive (set count 0 → 1, then (1-1)*15 = 0)
        viewModel.startRestTimer(duration: 90, for: exerciseId)
        XCTAssertEqual(viewModel.restTimerDuration, 90)

        // Second set: base 90 + 15 progressive (set count 1 → 2, then (2-1)*15 = 15)
        viewModel.startRestTimer(duration: 90, for: exerciseId)
        XCTAssertEqual(viewModel.restTimerDuration, 105)

        // Third set: base 90 + 30 progressive
        viewModel.startRestTimer(duration: 90, for: exerciseId)
        XCTAssertEqual(viewModel.restTimerDuration, 120)
    }

    func testRestDurationForGroupedExercise() async {
        let ex1 = Exercise(name: "Bench Press", category: .push, primaryMuscles: [.chest], equipment: .barbell)
        let ex2 = Exercise(name: "Bent Row", category: .pull, primaryMuscles: [.back], equipment: .barbell)
        await viewModel.addExercise(ex1)
        await viewModel.addExercise(ex2)

        // Create group with custom rest intervals
        let group = SetGroup(
            groupType: .superset,
            exerciseIds: [ex1.id, ex2.id],
            restBetweenExercises: 20,
            restAfterGroup: 120
        )
        viewModel.setGroups = [group]

        // First exercise in group → between-exercise rest
        XCTAssertEqual(viewModel.restDurationForExercise(ex1.id), 20)

        // Last exercise in group → after-group rest
        XCTAssertEqual(viewModel.restDurationForExercise(ex2.id), 120)
    }
}

// MARK: - Plate Calculator Tests

@MainActor
final class PlateCalculatorTests: XCTestCase {
    func testCalculatePlatesStandard60kg() {
        // 60kg total, 20kg bar = 20kg per side = 1x20kg plate
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: 60, barWeight: 20)
        XCTAssertEqual(plates, [20])
    }

    func testCalculatePlatesStandard100kg() {
        // 100kg total, 20kg bar = 40kg per side = 1x25kg + 1x15kg
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: 100, barWeight: 20)
        XCTAssertEqual(plates, [25, 15])
    }

    func testCalculatePlates140kg() {
        // 140kg total, 20kg bar = 60kg per side = 2x25kg + 1x10kg (greedy)
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: 140, barWeight: 20)
        XCTAssertEqual(plates, [25, 25, 10])
    }

    func testCalculatePlatesBarWeightOnly() {
        // Target equals bar weight → no plates
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: 20, barWeight: 20)
        XCTAssertTrue(plates.isEmpty)
    }

    func testCalculatePlatesZeroTarget() {
        // Zero target (less than bar) → no plates
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: 0, barWeight: 20)
        XCTAssertTrue(plates.isEmpty)
    }

    func testCalculatePlatesBelowBarWeight() {
        // Target below bar weight → no plates
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: 10, barWeight: 20)
        XCTAssertTrue(plates.isEmpty)
    }

    func testCalculatePlatesSmallWeight() {
        // 22.5kg total, 20kg bar = 1.25kg per side = 1x1.25kg
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: 22.5, barWeight: 20)
        XCTAssertEqual(plates, [1.25])
    }

    func testCalculatePlatesMixedSizes() {
        // 67.5kg total, 20kg bar = 23.75kg per side = 20 + 2.5 + 1.25
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: 67.5, barWeight: 20)
        XCTAssertEqual(plates, [20, 2.5, 1.25])
    }

    func testCalculatePlatesMultipleSamePlate() {
        // 120kg total, 20kg bar = 50kg per side = 2x25kg
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: 120, barWeight: 20)
        XCTAssertEqual(plates, [25, 25])
    }

    func testPlateColorMapping() {
        XCTAssertEqual(PlateCalculatorViewModel.plateColor(weightKg: 25), .red)
        XCTAssertEqual(PlateCalculatorViewModel.plateColor(weightKg: 20), .blue)
        XCTAssertEqual(PlateCalculatorViewModel.plateColor(weightKg: 15), .yellow)
        XCTAssertEqual(PlateCalculatorViewModel.plateColor(weightKg: 10), .green)
        XCTAssertEqual(PlateCalculatorViewModel.plateColor(weightKg: 5), .white)
        XCTAssertEqual(PlateCalculatorViewModel.plateColor(weightKg: 2.5), .black)
        XCTAssertEqual(PlateCalculatorViewModel.plateColor(weightKg: 1.25), .silver)
        XCTAssertEqual(PlateCalculatorViewModel.plateColor(weightKg: 99), .gray)
    }

    func testViewModelDefaults() {
        let vm = PlateCalculatorViewModel()
        XCTAssertEqual(vm.targetWeight, 60)
        XCTAssertEqual(vm.barWeight, 20)
        XCTAssertFalse(vm.useImperial)
    }

    func testViewModelPlatesPerSide() {
        let vm = PlateCalculatorViewModel()
        vm.targetWeight = 100
        vm.barWeight = 20

        XCTAssertEqual(vm.platesPerSide, [25, 15])
    }

    func testViewModelActualWeight() {
        let vm = PlateCalculatorViewModel()
        vm.targetWeight = 100
        vm.barWeight = 20

        // 20 bar + 2*(25+15) = 20 + 80 = 100
        XCTAssertEqual(vm.actualWeight, 100, accuracy: 0.01)
    }

    func testViewModelWeightPerSide() {
        let vm = PlateCalculatorViewModel()
        vm.targetWeight = 100
        vm.barWeight = 20

        // 25 + 15 = 40
        XCTAssertEqual(vm.weightPerSide, 40, accuracy: 0.01)
    }

    func testViewModelIsAchievable() {
        let vm = PlateCalculatorViewModel()

        // 100kg is achievable (25+15 per side)
        vm.targetWeight = 100
        XCTAssertTrue(vm.isAchievable)

        // 20kg (bar only) is achievable
        vm.targetWeight = 20
        XCTAssertTrue(vm.isAchievable)
    }

    func testViewModelUnachievableWeight() {
        let vm = PlateCalculatorViewModel()
        // 21kg: (21-20)/2 = 0.5kg per side, not achievable with standard plates
        vm.targetWeight = 21
        XCTAssertFalse(vm.isAchievable)
    }

    func testViewModelToggleUnits() {
        let vm = PlateCalculatorViewModel()
        vm.targetWeight = 100 // kg
        vm.barWeight = 20 // kg

        vm.toggleUnits()

        XCTAssertTrue(vm.useImperial)
        XCTAssertEqual(vm.targetWeight, UnitConversion.kgToLbs(100), accuracy: 0.01)
        XCTAssertEqual(vm.barWeight, UnitConversion.kgToLbs(20), accuracy: 0.01)
        XCTAssertEqual(vm.weightUnit, "lbs")

        vm.toggleUnits()

        XCTAssertFalse(vm.useImperial)
        XCTAssertEqual(vm.weightUnit, "kg")
    }

    func testViewModelSetPreset() {
        let vm = PlateCalculatorViewModel()
        vm.useImperial = true
        vm.targetWeight = 200

        vm.setPreset(targetKg: 140)

        XCTAssertFalse(vm.useImperial)
        XCTAssertEqual(vm.targetWeight, 140)
        XCTAssertEqual(vm.barWeight, 20)
    }

    func testCalculatePlatesWithCustomBarWeight() {
        // 45kg total, 15kg bar (e.g., women's bar) = 15kg per side = 1x15kg
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: 45, barWeight: 15)
        XCTAssertEqual(plates, [15])
    }

    func testCalculatePlatesVeryHeavy() {
        // 220kg total, 20kg bar = 100kg per side = 4x25kg
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: 220, barWeight: 20)
        XCTAssertEqual(plates, [25, 25, 25, 25])
    }

    func testCalculatePlatesSumMatchesTarget() {
        // Verify the sum property: plates*2 + bar == target
        let target = 107.5
        let bar = 20.0
        let plates = PlateCalculatorViewModel.calculatePlatesPerSide(targetWeight: target, barWeight: bar)
        let totalPlateWeight = plates.reduce(0, +) * 2
        XCTAssertEqual(totalPlateWeight + bar, target, accuracy: 0.01)
    }
}
