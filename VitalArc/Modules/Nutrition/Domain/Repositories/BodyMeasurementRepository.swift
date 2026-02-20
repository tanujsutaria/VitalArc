//
//  BodyCompositionEntryRepository.swift
//  VitalArc
//
//  Repository Protocol for Body Measurement Domain
//

import Foundation

protocol BodyCompositionEntryRepository {
    func saveMeasurement(_ measurement: BodyCompositionEntry) async throws
    func getMeasurements(from startDate: Date, to endDate: Date) async throws -> [BodyCompositionEntry]
    func getLatestMeasurement() async throws -> BodyCompositionEntry?
    func deleteMeasurement(_ id: UUID) async throws
}
