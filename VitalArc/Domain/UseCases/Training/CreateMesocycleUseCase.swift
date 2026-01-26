//
//  CreateMesocycleUseCase.swift
//  VitalArc
//
//  Use Case: Create a new mesocycle
//

import Foundation

final class CreateMesocycleUseCase {
    private let repository: MesocycleRepository

    init(repository: MesocycleRepository) {
        self.repository = repository
    }

    /// Create and save a new mesocycle
    func execute(
        name: String,
        startDate: Date,
        durationWeeks: Int,
        goal: TrainingGoal,
        phaseTemplate: PhaseTemplate = .standard,
        trainingBlocks: [TrainingBlock] = []
    ) async throws -> Mesocycle {
        // Calculate end date
        let calendar = Calendar.current
        guard let endDate = calendar.date(byAdding: .weekOfYear, value: durationWeeks - 1, to: startDate) else {
            throw MesocycleError.invalidDuration
        }

        // Generate phases based on template
        let phases = generatePhases(
            durationWeeks: durationWeeks,
            template: phaseTemplate,
            goal: goal
        )

        // Create mesocycle
        let mesocycle = Mesocycle(
            name: name,
            startDate: startDate,
            endDate: endDate,
            phases: phases,
            trainingBlocks: trainingBlocks,
            goal: goal,
            status: .planned
        )

        // Save to repository
        try await repository.saveMesocycle(mesocycle)

        return mesocycle
    }

    /// Generate phases based on template
    private func generatePhases(
        durationWeeks: Int,
        template: PhaseTemplate,
        goal: TrainingGoal
    ) -> [MesocyclePhase] {
        switch template {
        case .standard:
            return generateStandardPhases(durationWeeks: durationWeeks)
        case .beginner:
            return generateBeginnerPhases(durationWeeks: durationWeeks)
        case .advanced:
            return generateAdvancedPhases(durationWeeks: durationWeeks)
        case .custom(let phases):
            return phases
        }
    }

    /// Standard phase progression: Accumulation -> Intensification -> Deload (repeat)
    private func generateStandardPhases(durationWeeks: Int) -> [MesocyclePhase] {
        var phases: [MesocyclePhase] = []

        for week in 1...durationWeeks {
            let phaseType: PhaseType
            let weekInCycle = (week - 1) % 4

            switch weekInCycle {
            case 0, 1:
                phaseType = .accumulation
            case 2:
                phaseType = .intensification
            case 3:
                phaseType = .deload
            default:
                phaseType = .accumulation
            }

            phases.append(MesocyclePhase(weekNumber: week, phaseType: phaseType))
        }

        return phases
    }

    /// Beginner phase progression: Gradual progression with more recovery
    private func generateBeginnerPhases(durationWeeks: Int) -> [MesocyclePhase] {
        var phases: [MesocyclePhase] = []

        for week in 1...durationWeeks {
            let phaseType: PhaseType
            let weekInCycle = (week - 1) % 3

            switch weekInCycle {
            case 0, 1:
                phaseType = .accumulation
            case 2:
                phaseType = .deload
            default:
                phaseType = .accumulation
            }

            phases.append(MesocyclePhase(weekNumber: week, phaseType: phaseType))
        }

        return phases
    }

    /// Advanced phase progression: Block periodization
    private func generateAdvancedPhases(durationWeeks: Int) -> [MesocyclePhase] {
        var phases: [MesocyclePhase] = []

        // First third: Accumulation
        let firstBlockEnd = durationWeeks / 3
        for week in 1...firstBlockEnd {
            phases.append(MesocyclePhase(weekNumber: week, phaseType: .accumulation))
        }

        // Second third: Intensification
        let secondBlockEnd = (durationWeeks * 2) / 3
        for week in (firstBlockEnd + 1)...secondBlockEnd {
            phases.append(MesocyclePhase(weekNumber: week, phaseType: .intensification))
        }

        // Final third: Realization + Deload
        for week in (secondBlockEnd + 1)...durationWeeks {
            let phaseType: PhaseType = week == durationWeeks ? .deload : .realization
            phases.append(MesocyclePhase(weekNumber: week, phaseType: phaseType))
        }

        return phases
    }
}

/// Phase template options
enum PhaseTemplate: Hashable {
    case standard
    case beginner
    case advanced
    case custom([MesocyclePhase])
}

/// Mesocycle-specific errors
enum MesocycleError: Error, LocalizedError {
    case invalidDuration
    case mesocycleNotFound
    case multipleActiveMesocycles
    case cannotActivate

    var errorDescription: String? {
        switch self {
        case .invalidDuration:
            return "Invalid mesocycle duration"
        case .mesocycleNotFound:
            return "Mesocycle not found"
        case .multipleActiveMesocycles:
            return "Cannot have multiple active mesocycles"
        case .cannotActivate:
            return "Cannot activate mesocycle"
        }
    }
}
