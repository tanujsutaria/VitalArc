//
//  HealthRepository.swift
//  VitalArc
//
//  Repository Protocol for Health Domain
//

import Foundation

/// Repository protocol for accessing and syncing health metrics.
///
/// ## Thread Safety
/// This protocol is `@MainActor`-isolated because the primary implementation
/// (`SwiftDataHealthRepository`) uses SwiftData's `ModelContext`, which requires
/// main-actor access. This is safe for HealthKit-heavy methods like `syncFromHealthKit()`
/// because `HealthKitManager` is intentionally **not** `@MainActor`-isolated — so
/// `await` calls to it naturally hop off the main actor via Swift structured concurrency,
/// performing all HealthKit I/O on background cooperative threads. Only the final
/// SwiftData save hops back to the main actor.
@MainActor
protocol HealthRepository {
    // Health metrics operations (SwiftData reads/writes — require main actor)
    func getHealthMetrics(for date: Date) async throws -> HealthMetrics?
    func getHealthMetrics(from startDate: Date, to endDate: Date) async throws -> [HealthMetrics]
    func saveHealthMetrics(_ metrics: HealthMetrics) async throws

    // HealthKit sync (HealthKit I/O runs off main actor; SwiftData saves hop back)
    func syncFromHealthKit() async throws
    func requestHealthKitAuthorization() async throws -> Bool
}
