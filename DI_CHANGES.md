# DI Changes Required — Wellness Domain (Sprint 24.2)

## SwiftDataHealthRepository.saveHealthMetrics() — DependencyContainer.swift

The existing model update path (lines ~629-643) needs `waterIntake` added to preserve
hydration data during HealthKit re-syncs.

### Change needed in `DependencyContainer.swift` → `SwiftDataHealthRepository.saveHealthMetrics()`:

After this line:
```swift
existingModel.vo2Max = metrics.vo2Max
```

Add:
```swift
existingModel.waterIntake = metrics.waterIntake
```

### Also update the empty-data detection in `syncFromHealthKit()` (~line 672-675):

The `hasAnyData` check should include `m.waterIntake != nil` so that hydration-only days
don't falsely trigger the revoked-access heuristic:

```swift
let hasAnyData = metrics.contains { m in
    m.heartRateVariability != nil || m.restingHeartRate != nil ||
    m.activeEnergy != nil || m.steps != nil || m.sleepHours != nil ||
    m.waterIntake != nil
}
```
