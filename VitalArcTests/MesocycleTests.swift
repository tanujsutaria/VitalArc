//
//  MesocycleTests.swift
//  VitalArcTests
//
//  Unit tests for Mesocycle functionality
//

import XCTest
@testable import VitalArc

final class MesocycleTests: XCTestCase {

    // MARK: - Mesocycle Entity Tests

    func testMesocycleDurationWeeks() {
        let startDate = Date()
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .weekOfYear, value: 7, to: startDate)!

        let mesocycle = Mesocycle(
            name: "Test Program",
            startDate: startDate,
            endDate: endDate,
            goal: .hypertrophy
        )

        XCTAssertEqual(mesocycle.durationWeeks, 8)
    }

    func testMesocycleProgressPercentage() {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .weekOfYear, value: -4, to: Date())!
        let endDate = calendar.date(byAdding: .weekOfYear, value: 4, to: Date())!

        var mesocycle = Mesocycle(
            name: "Test Program",
            startDate: startDate,
            endDate: endDate,
            goal: .strength
        )
        mesocycle.status = .active

        // Should be approximately 50% complete (4 weeks in, 8 weeks total)
        XCTAssertGreaterThan(mesocycle.progressPercentage, 40)
        XCTAssertLessThan(mesocycle.progressPercentage, 60)
    }

    func testMesocycleCurrentWeek() {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .weekOfYear, value: -2, to: Date())!
        let endDate = calendar.date(byAdding: .weekOfYear, value: 6, to: Date())!

        var mesocycle = Mesocycle(
            name: "Test Program",
            startDate: startDate,
            endDate: endDate,
            goal: .hypertrophy
        )
        mesocycle.status = .active

        // Should be in week 3 (started 2 weeks ago)
        XCTAssertEqual(mesocycle.currentWeek, 3)
    }

    // MARK: - Phase Tests

    func testPhaseTypeDefaultMultipliers() {
        XCTAssertEqual(PhaseType.accumulation.defaultVolumeMultiplier, 1.2)
        XCTAssertEqual(PhaseType.accumulation.defaultIntensityMultiplier, 1.0)

        XCTAssertEqual(PhaseType.intensification.defaultVolumeMultiplier, 0.8)
        XCTAssertEqual(PhaseType.intensification.defaultIntensityMultiplier, 1.15)

        XCTAssertEqual(PhaseType.realization.defaultVolumeMultiplier, 0.6)
        XCTAssertEqual(PhaseType.realization.defaultIntensityMultiplier, 1.25)

        XCTAssertEqual(PhaseType.deload.defaultVolumeMultiplier, 0.5)
        XCTAssertEqual(PhaseType.deload.defaultIntensityMultiplier, 0.7)
    }

    func testMesocyclePhaseConvenienceInit() {
        let phase = MesocyclePhase(weekNumber: 1, phaseType: .accumulation)

        XCTAssertEqual(phase.weekNumber, 1)
        XCTAssertEqual(phase.phaseType, .accumulation)
        XCTAssertEqual(phase.name, "Accumulation")
        XCTAssertEqual(phase.volumeMultiplier, 1.2)
        XCTAssertEqual(phase.intensityMultiplier, 1.0)
    }

    // MARK: - Training Block Tests

    func testTrainingBlockEstimatedDuration() {
        let block = TrainingBlock(
            name: "Push Day",
            dayOfWeek: 2,
            exercises: [
                TrainingBlockExercise(
                    exerciseId: UUID(),
                    orderIndex: 0,
                    targetSets: 4,
                    targetRepsMin: 8,
                    targetRepsMax: 12
                ),
                TrainingBlockExercise(
                    exerciseId: UUID(),
                    orderIndex: 1,
                    targetSets: 3,
                    targetRepsMin: 10,
                    targetRepsMax: 15
                )
            ],
            mesocycleId: UUID()
        )

        XCTAssertEqual(block.totalSets, 7)
        XCTAssertEqual(block.estimatedDuration, 21) // 7 sets × 3 min
    }

    func testTrainingBlockExercisePrescription() {
        let exercise = TrainingBlockExercise(
            exerciseId: UUID(),
            orderIndex: 0,
            targetSets: 3,
            targetRepsMin: 8,
            targetRepsMax: 12,
            targetRIR: 2
        )

        XCTAssertEqual(exercise.repRange, "8-12")
        XCTAssertEqual(exercise.prescription, "3 sets x 8-12 reps @ 2 RIR")
    }

    // MARK: - Auto-Regulation Tests

    func testAutoRegulationAdviceEquality() {
        let advice1 = AutoRegulationAdvice(
            recommendation: .increaseWeight,
            reason: "Too easy",
            suggestedWeightChange: 2.5
        )

        let advice2 = AutoRegulationAdvice(
            recommendation: .increaseWeight,
            reason: "Too easy",
            suggestedWeightChange: 2.5
        )

        XCTAssertEqual(advice1, advice2)
    }

    // MARK: - CreateMesocycleUseCase Tests

    func testStandardPhaseGeneration() async throws {
        let repository = MockMesocycleRepository()
        let useCase = CreateMesocycleUseCase(repository: repository)

        let mesocycle = try await useCase.execute(
            name: "Test Program",
            startDate: Date(),
            durationWeeks: 8,
            goal: .hypertrophy,
            phaseTemplate: .standard
        )

        XCTAssertEqual(mesocycle.phases.count, 8)
        XCTAssertEqual(mesocycle.durationWeeks, 8)

        // Standard template: 2 accumulation, 1 intensification, 1 deload (repeat)
        XCTAssertEqual(mesocycle.phases[0].phaseType, .accumulation)
        XCTAssertEqual(mesocycle.phases[1].phaseType, .accumulation)
        XCTAssertEqual(mesocycle.phases[2].phaseType, .intensification)
        XCTAssertEqual(mesocycle.phases[3].phaseType, .deload)
        XCTAssertEqual(mesocycle.phases[4].phaseType, .accumulation)
    }

    func testBeginnerPhaseGeneration() async throws {
        let repository = MockMesocycleRepository()
        let useCase = CreateMesocycleUseCase(repository: repository)

        let mesocycle = try await useCase.execute(
            name: "Beginner Program",
            startDate: Date(),
            durationWeeks: 6,
            goal: .strength,
            phaseTemplate: .beginner
        )

        XCTAssertEqual(mesocycle.phases.count, 6)

        // Beginner template: 2 accumulation, 1 deload (repeat)
        XCTAssertEqual(mesocycle.phases[0].phaseType, .accumulation)
        XCTAssertEqual(mesocycle.phases[1].phaseType, .accumulation)
        XCTAssertEqual(mesocycle.phases[2].phaseType, .deload)
        XCTAssertEqual(mesocycle.phases[3].phaseType, .accumulation)
    }

    // MARK: - Progression Scheme Tests

    func testProgressionSchemeDescriptions() {
        XCTAssertFalse(ProgressionScheme.linear.description.isEmpty)
        XCTAssertFalse(ProgressionScheme.doubleProgression.description.isEmpty)
        XCTAssertFalse(ProgressionScheme.wave.description.isEmpty)
        XCTAssertFalse(ProgressionScheme.static.description.isEmpty)
    }

    // MARK: - Training Goal Tests

    func testTrainingGoalProperties() {
        XCTAssertFalse(TrainingGoal.strength.description.isEmpty)
        XCTAssertFalse(TrainingGoal.strength.icon.isEmpty)

        XCTAssertEqual(TrainingGoal.allCases.count, 4)
    }
}

// Note: MockMesocycleRepository is defined in VitalArcTests/Mocks/MockMesocycleRepository.swift
