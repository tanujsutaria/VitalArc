# Schema Changes Required

## New SwiftData Model: BodyMeasurementModel

The nutrition domain added `BodyMeasurementModel` for body composition tracking.

### Required Change in `App/VitalArcApp.swift`

Add `BodyMeasurementModel.self` to the SwiftData schema array:

```swift
let schema = Schema([
    // ... existing models ...

    // Nutrition Domain Models (add this)
    BodyMeasurementModel.self,

    // ... rest of models ...
])
```

### Location
- Model file: `VitalArc/Modules/Nutrition/Data/Models/BodyMeasurementModel.swift`
- Schema file: `VitalArc/App/VitalArcApp.swift` (needs `BodyMeasurementModel.self` added)

### Fields
- `id: UUID` (unique)
- `date: Date`
- `weight: Double?` (kg)
- `bodyFatPercentage: Double?`
- `waistCircumference: Double?` (cm)
- `hipCircumference: Double?` (cm)
- `chestCircumference: Double?` (cm)
- `armCircumference: Double?` (cm)
- `thighCircumference: Double?` (cm)
- `neckCircumference: Double?` (cm)
- `notes: String?`
