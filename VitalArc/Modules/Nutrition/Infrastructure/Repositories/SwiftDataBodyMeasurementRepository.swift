//
//  SwiftDataBodyCompositionEntryRepository.swift
//  VitalArc
//
//  SwiftData implementation of BodyCompositionEntryRepository
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataBodyCompositionEntryRepository: BodyCompositionEntryRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveMeasurement(_ measurement: BodyCompositionEntry) async throws {
        // Check for existing measurement with same ID (update case)
        let id = measurement.id
        let descriptor = FetchDescriptor<BodyCompositionEntryModel>(
            predicate: #Predicate { $0.id == id }
        )

        if let existing = try modelContext.fetch(descriptor).first {
            // Update existing
            existing.date = measurement.date
            existing.weight = measurement.weight
            existing.bodyFatPercentage = measurement.bodyFatPercentage
            existing.waistCircumference = measurement.waistCircumference
            existing.hipCircumference = measurement.hipCircumference
            existing.chestCircumference = measurement.chestCircumference
            existing.armCircumference = measurement.armCircumference
            existing.thighCircumference = measurement.thighCircumference
            existing.neckCircumference = measurement.neckCircumference
            existing.notes = measurement.notes
        } else {
            let model = BodyCompositionEntryModel.fromDomain(measurement)
            modelContext.insert(model)
        }

        try modelContext.save()
    }

    func getMeasurements(from startDate: Date, to endDate: Date) async throws -> [BodyCompositionEntry] {
        let descriptor = FetchDescriptor<BodyCompositionEntryModel>(
            predicate: #Predicate { $0.date >= startDate && $0.date <= endDate },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func getLatestMeasurement() async throws -> BodyCompositionEntry? {
        var descriptor = FetchDescriptor<BodyCompositionEntryModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1

        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    func deleteMeasurement(_ id: UUID) async throws {
        let descriptor = FetchDescriptor<BodyCompositionEntryModel>(
            predicate: #Predicate { $0.id == id }
        )

        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }
}
