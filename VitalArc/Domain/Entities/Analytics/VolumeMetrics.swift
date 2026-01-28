//
//  VolumeMetrics.swift
//  VitalArc
//
//  Domain entity for tracking training volume metrics
//

import Foundation

/// Weekly training volume metrics
struct VolumeMetrics: Identifiable, Equatable {
    let id: UUID
    let weekStartDate: Date
    let weekEndDate: Date
    let exerciseVolumes: [ExerciseVolume]
    let totalVolume: Double
    let avgIntensity: Double
    let workoutCount: Int

    init(
        id: UUID = UUID(),
        weekStartDate: Date,
        weekEndDate: Date,
        exerciseVolumes: [ExerciseVolume],
        totalVolume: Double,
        avgIntensity: Double,
        workoutCount: Int
    ) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.exerciseVolumes = exerciseVolumes
        self.totalVolume = totalVolume
        self.avgIntensity = avgIntensity
        self.workoutCount = workoutCount
    }

    /// Get volume for a specific exercise
    func volume(for exerciseId: UUID) -> ExerciseVolume? {
        exerciseVolumes.first { $0.exerciseId == exerciseId }
    }

    /// Get top exercises by volume
    func topExercises(limit: Int = 5) -> [ExerciseVolume] {
        Array(exerciseVolumes.sorted { $0.totalWeight > $1.totalWeight }.prefix(limit))
    }
}

/// Volume metrics for a specific exercise
struct ExerciseVolume: Identifiable, Equatable {
    let id: UUID
    let exerciseId: UUID
    let exerciseName: String
    let sets: Int
    let totalReps: Int
    let totalWeight: Double // sets × reps × weight
    let avgWeight: Double
    let avgRIR: Double?

    init(
        id: UUID = UUID(),
        exerciseId: UUID,
        exerciseName: String,
        sets: Int,
        totalReps: Int,
        totalWeight: Double,
        avgWeight: Double,
        avgRIR: Double? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.sets = sets
        self.totalReps = totalReps
        self.totalWeight = totalWeight
        self.avgWeight = avgWeight
        self.avgRIR = avgRIR
    }

    /// Average reps per set
    var avgReps: Double {
        sets > 0 ? Double(totalReps) / Double(sets) : 0
    }

    /// Intensity as percentage (simplified - weight relative to average)
    var intensity: Double {
        avgWeight > 0 ? (avgWeight / (avgWeight * 1.2)) * 100 : 0
    }
}

/// Progressive overload analysis data
struct ProgressiveOverloadData: Equatable {
    let isProgressing: Bool
    let weeklyVolumeChange: Double // percentage change
    let recommendations: [String]
    let needsDeload: Bool
    let volumeHistory: [(Date, Double)]

    init(
        isProgressing: Bool,
        weeklyVolumeChange: Double,
        recommendations: [String],
        needsDeload: Bool,
        volumeHistory: [(Date, Double)]
    ) {
        self.isProgressing = isProgressing
        self.weeklyVolumeChange = weeklyVolumeChange
        self.recommendations = recommendations
        self.needsDeload = needsDeload
        self.volumeHistory = volumeHistory
    }

    /// Status description
    var statusDescription: String {
        if needsDeload {
            return "Deload Recommended"
        } else if isProgressing {
            return "Progressing Well"
        } else {
            return "Plateau Detected"
        }
    }

    /// Status color
    var statusColor: String {
        if needsDeload {
            return "orange"
        } else if isProgressing {
            return "green"
        } else {
            return "yellow"
        }
    }

    // Custom Equatable implementation to handle tuple array
    static func == (lhs: ProgressiveOverloadData, rhs: ProgressiveOverloadData) -> Bool {
        lhs.isProgressing == rhs.isProgressing &&
        lhs.weeklyVolumeChange == rhs.weeklyVolumeChange &&
        lhs.recommendations == rhs.recommendations &&
        lhs.needsDeload == rhs.needsDeload &&
        lhs.volumeHistory.count == rhs.volumeHistory.count &&
        zip(lhs.volumeHistory, rhs.volumeHistory).allSatisfy { $0.0 == $1.0 && $0.1 == $1.1 }
    }
}
