//
//  MesocycleModel.swift
//  VitalArc
//
//  SwiftData Model for Mesocycle
//

import Foundation
import SwiftData

@Model
final class MesocycleModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var phasesData: Data? // Encoded [MesocyclePhase]
    var trainingBlocksData: Data? // Encoded [TrainingBlock]
    var goal: String // TrainingGoal.rawValue
    var status: String // MesocycleStatus.rawValue
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date,
        endDate: Date,
        phasesData: Data? = nil,
        trainingBlocksData: Data? = nil,
        goal: String,
        status: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.phasesData = phasesData
        self.trainingBlocksData = trainingBlocksData
        self.goal = goal
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Convert to domain entity
    func toDomain() -> Mesocycle {
        let decoder = JSONDecoder()

        let phases: [MesocyclePhase]
        if let phasesData = phasesData {
            phases = (try? decoder.decode([MesocyclePhase].self, from: phasesData)) ?? []
        } else {
            phases = []
        }

        let trainingBlocks: [TrainingBlock]
        if let trainingBlocksData = trainingBlocksData {
            trainingBlocks = (try? decoder.decode([TrainingBlock].self, from: trainingBlocksData)) ?? []
        } else {
            trainingBlocks = []
        }

        return Mesocycle(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
            phases: phases,
            trainingBlocks: trainingBlocks,
            goal: TrainingGoal(rawValue: goal) ?? .hypertrophy,
            status: MesocycleStatus(rawValue: status) ?? .planned,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    /// Create from domain entity
    static func fromDomain(_ mesocycle: Mesocycle) -> MesocycleModel {
        let encoder = JSONEncoder()

        let phasesData = try? encoder.encode(mesocycle.phases)
        let trainingBlocksData = try? encoder.encode(mesocycle.trainingBlocks)

        return MesocycleModel(
            id: mesocycle.id,
            name: mesocycle.name,
            startDate: mesocycle.startDate,
            endDate: mesocycle.endDate,
            phasesData: phasesData,
            trainingBlocksData: trainingBlocksData,
            goal: mesocycle.goal.rawValue,
            status: mesocycle.status.rawValue,
            createdAt: mesocycle.createdAt,
            updatedAt: mesocycle.updatedAt
        )
    }
}
