//
//  ProgressSnapshotModel.swift
//  VitalArc
//
//  SwiftData model for progress snapshots
//

import Foundation
import SwiftData

@Model
final class ProgressSnapshotModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var bodyWeight: Double?
    var bodyFatPercentage: Double?
    var measurementsData: Data? // JSON encoded [BodyMeasurement]
    var photosData: Data? // JSON encoded [String]
    var notes: String?
    var createdAt: Date

    init(
        id: UUID,
        date: Date,
        bodyWeight: Double?,
        bodyFatPercentage: Double?,
        measurementsData: Data?,
        photosData: Data?,
        notes: String?,
        createdAt: Date
    ) {
        self.id = id
        self.date = date
        self.bodyWeight = bodyWeight
        self.bodyFatPercentage = bodyFatPercentage
        self.measurementsData = measurementsData
        self.photosData = photosData
        self.notes = notes
        self.createdAt = createdAt
    }

    // MARK: - Domain Conversion

    func toDomain() -> ProgressSnapshot {
        let measurements = decodeMeasurements()
        let photos = decodePhotos()

        return ProgressSnapshot(
            id: id,
            date: date,
            bodyWeight: bodyWeight,
            bodyFatPercentage: bodyFatPercentage,
            measurements: measurements,
            photos: photos,
            notes: notes,
            createdAt: createdAt
        )
    }

    static func fromDomain(_ snapshot: ProgressSnapshot) -> ProgressSnapshotModel {
        let measurementsData = encodeMeasurements(snapshot.measurements)
        let photosData = encodePhotos(snapshot.photos)

        return ProgressSnapshotModel(
            id: snapshot.id,
            date: snapshot.date,
            bodyWeight: snapshot.bodyWeight,
            bodyFatPercentage: snapshot.bodyFatPercentage,
            measurementsData: measurementsData,
            photosData: photosData,
            notes: snapshot.notes,
            createdAt: snapshot.createdAt
        )
    }

    // MARK: - Helpers

    private func decodeMeasurements() -> [BodyMeasurement] {
        guard let data = measurementsData else { return [] }
        return (try? JSONDecoder().decode([BodyMeasurement].self, from: data)) ?? []
    }

    private func decodePhotos() -> [String] {
        guard let data = photosData else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    private static func encodeMeasurements(_ measurements: [BodyMeasurement]) -> Data? {
        try? JSONEncoder().encode(measurements)
    }

    private static func encodePhotos(_ photos: [String]) -> Data? {
        try? JSONEncoder().encode(photos)
    }
}
