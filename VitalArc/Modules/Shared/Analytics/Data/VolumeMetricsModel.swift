//
//  VolumeMetricsModel.swift
//  VitalArc
//
//  SwiftData model for volume metrics
//

import Foundation
import SwiftData

@Model
final class VolumeMetricsModel {
    @Attribute(.unique) var id: UUID
    var weekStartDate: Date
    var weekEndDate: Date
    var exerciseVolumesData: Data? // JSON encoded [ExerciseVolume]
    var totalVolume: Double
    var avgIntensity: Double
    var workoutCount: Int

    init(
        id: UUID,
        weekStartDate: Date,
        weekEndDate: Date,
        exerciseVolumesData: Data?,
        totalVolume: Double,
        avgIntensity: Double,
        workoutCount: Int
    ) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.exerciseVolumesData = exerciseVolumesData
        self.totalVolume = totalVolume
        self.avgIntensity = avgIntensity
        self.workoutCount = workoutCount
    }

    // MARK: - Domain Conversion

    func toDomain() -> VolumeMetrics {
        let exerciseVolumes = decodeExerciseVolumes()

        return VolumeMetrics(
            id: id,
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
            exerciseVolumes: exerciseVolumes,
            totalVolume: totalVolume,
            avgIntensity: avgIntensity,
            workoutCount: workoutCount
        )
    }

    static func fromDomain(_ metrics: VolumeMetrics) -> VolumeMetricsModel {
        let exerciseVolumesData = encodeExerciseVolumes(metrics.exerciseVolumes)

        return VolumeMetricsModel(
            id: metrics.id,
            weekStartDate: metrics.weekStartDate,
            weekEndDate: metrics.weekEndDate,
            exerciseVolumesData: exerciseVolumesData,
            totalVolume: metrics.totalVolume,
            avgIntensity: metrics.avgIntensity,
            workoutCount: metrics.workoutCount
        )
    }

    // MARK: - Helpers

    private func decodeExerciseVolumes() -> [ExerciseVolume] {
        guard let data = exerciseVolumesData else { return [] }
        return (try? JSONDecoder().decode([CodableExerciseVolume].self, from: data))?
            .map { $0.toDomain() } ?? []
    }

    private static func encodeExerciseVolumes(_ volumes: [ExerciseVolume]) -> Data? {
        let codableVolumes = volumes.map { CodableExerciseVolume.fromDomain($0) }
        return try? JSONEncoder().encode(codableVolumes)
    }
}

// MARK: - Codable Helper

private struct CodableExerciseVolume: Codable {
    let id: UUID
    let exerciseId: UUID
    let exerciseName: String
    let sets: Int
    let totalReps: Int
    let totalWeight: Double
    let avgWeight: Double
    let avgRIR: Double?

    func toDomain() -> ExerciseVolume {
        ExerciseVolume(
            id: id,
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            sets: sets,
            totalReps: totalReps,
            totalWeight: totalWeight,
            avgWeight: avgWeight,
            avgRIR: avgRIR
        )
    }

    static func fromDomain(_ volume: ExerciseVolume) -> CodableExerciseVolume {
        CodableExerciseVolume(
            id: volume.id,
            exerciseId: volume.exerciseId,
            exerciseName: volume.exerciseName,
            sets: volume.sets,
            totalReps: volume.totalReps,
            totalWeight: volume.totalWeight,
            avgWeight: volume.avgWeight,
            avgRIR: volume.avgRIR
        )
    }
}
