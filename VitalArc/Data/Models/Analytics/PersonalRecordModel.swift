//
//  PersonalRecordModel.swift
//  VitalArc
//
//  SwiftData model for personal records
//

import Foundation
import SwiftData

@Model
final class PersonalRecordModel {
    @Attribute(.unique) var id: UUID
    var exerciseId: UUID
    var exerciseName: String
    var recordType: String
    var value: Double
    var reps: Int?
    var date: Date
    var videoURL: String?
    var notes: String?

    init(
        id: UUID,
        exerciseId: UUID,
        exerciseName: String,
        recordType: String,
        value: Double,
        reps: Int?,
        date: Date,
        videoURL: String?,
        notes: String?
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.recordType = recordType
        self.value = value
        self.reps = reps
        self.date = date
        self.videoURL = videoURL
        self.notes = notes
    }

    // MARK: - Domain Conversion

    func toDomain() -> PersonalRecord {
        PersonalRecord(
            id: id,
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            recordType: RecordType(rawValue: recordType) ?? .oneRepMax,
            value: value,
            reps: reps,
            date: date,
            videoURL: videoURL,
            notes: notes
        )
    }

    static func fromDomain(_ record: PersonalRecord) -> PersonalRecordModel {
        PersonalRecordModel(
            id: record.id,
            exerciseId: record.exerciseId,
            exerciseName: record.exerciseName,
            recordType: record.recordType.rawValue,
            value: record.value,
            reps: record.reps,
            date: record.date,
            videoURL: record.videoURL,
            notes: record.notes
        )
    }
}
