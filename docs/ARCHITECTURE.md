# VitalArc Architecture

Deep-dive into the app's architecture for developers.

---

## Overview

VitalArc uses **Clean Architecture** with **MVVM** for the presentation layer.

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation                         │
│  ┌─────────┐    ┌───────────┐    ┌─────────────────┐   │
│  │  Views  │───▶│ ViewModels │───▶│    Use Cases    │   │
│  └─────────┘    └───────────┘    └────────┬────────┘   │
├──────────────────────────────────────────┼─────────────┤
│                      Domain               │             │
│  ┌──────────┐    ┌─────────────┐    ┌────▼────────┐   │
│  │ Entities │    │  Protocols  │◀───│ Repository  │   │
│  └──────────┘    └─────────────┘    │  Protocols  │   │
├──────────────────────────────────────┴─────────────────┤
│                       Data                              │
│  ┌────────────────┐    ┌──────────────────────────┐   │
│  │ SwiftData Models│    │ Repository Implementations│   │
│  └────────────────┘    └──────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│                   Infrastructure                        │
│  ┌───────────┐  ┌────────────┐  ┌─────────┐  ┌─────┐  │
│  │ HealthKit │  │ Networking │  │  Cache  │  │Export│  │
│  └───────────┘  └────────────┘  └─────────┘  └─────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Layers

### Domain (Pure Swift)
No framework dependencies. Contains:

- **Entities**: `UserProfile`, `Workout`, `Food`, `HealthMetrics`, `Mesocycle`
- **Repository Protocols**: Define data access contracts
- **Use Cases**: Single-responsibility business operations

```swift
// Domain/UseCases/CreateWorkoutUseCase.swift
struct CreateWorkoutUseCase {
    let repository: WorkoutRepository

    func execute(sets: [WorkoutSet]) async throws -> Workout {
        // Business logic here
    }
}
```

### Data (Persistence)
SwiftData models that persist Domain entities:

```swift
// Data/Models/WorkoutModel.swift
@Model
class WorkoutModel {
    var id: UUID
    var date: Date
    var sets: [WorkoutSetModel]

    static func fromDomain(_ workout: Workout) -> WorkoutModel { }
    func toDomain() -> Workout { }
}
```

### Infrastructure (External Services)
- **HealthKit**: `HealthKitManager` for Apple Health integration
- **Networking**: Food API clients (Nutritionix, USDA, OpenFoodFacts)
- **Cache**: `FoodCache` for API response caching
- **Export**: PDF/CSV generation

### Presentation (UI)
- **Views**: SwiftUI views, stateless where possible
- **ViewModels**: `@Observable` classes holding view state
- **Common**: Design system, shared components

---

## Dependency Injection

All dependencies flow through `DependencyContainer`:

```swift
// Infrastructure/DependencyContainer.swift
@Observable
final class DependencyContainer {
    let workoutRepository: WorkoutRepository
    let nutritionRepository: NutritionRepository
    let healthKitManager: HealthKitManager
    // ...

    init(modelContext: ModelContext) {
        self.workoutRepository = SwiftDataWorkoutRepository(context: modelContext)
        // ...
    }
}
```

Injected via SwiftUI environment:

```swift
// In views
@Environment(\.dependencyContainer) private var container

// Usage
let useCase = CreateWorkoutUseCase(repository: container.workoutRepository)
```

---

## Data Flow

```
User Action
    │
    ▼
┌─────────┐
│  View   │ ──calls──▶ ViewModel.doSomething()
└─────────┘
    │
    ▼
┌───────────┐
│ ViewModel │ ──calls──▶ UseCase.execute()
└───────────┘
    │
    ▼
┌──────────┐
│ Use Case │ ──calls──▶ Repository.save()
└──────────┘
    │
    ▼
┌────────────┐
│ Repository │ ──persists──▶ SwiftData
└────────────┘
    │
    ▼
Domain Entity returned up the chain
```

---

## Thread Safety

All repositories and ViewModels use `@MainActor`:

```swift
@MainActor
final class WorkoutViewModel: ObservableObject {
    // All properties and methods run on main thread
}
```

SwiftData `ModelContext` is not thread-safe, so `@MainActor` ensures all access happens on the main thread.

---

## Key Patterns

### Repository Pattern
Domain defines the contract, Data implements it:

```swift
// Domain/Repositories/WorkoutRepository.swift
protocol WorkoutRepository {
    func save(_ workout: Workout) async throws
    func fetchAll() async throws -> [Workout]
    func delete(_ workout: Workout) async throws
}

// Data/Repositories/SwiftDataWorkoutRepository.swift
@MainActor
final class SwiftDataWorkoutRepository: WorkoutRepository {
    private let context: ModelContext

    func save(_ workout: Workout) async throws {
        let model = WorkoutModel.fromDomain(workout)
        context.insert(model)
        try context.save()
    }
}
```

### Use Case Pattern
Single-purpose operations encapsulating business logic:

```swift
struct CalculateRecoveryScoreUseCase {
    let healthKitManager: HealthKitManager
    let repository: HealthMetricsRepository

    func execute() async throws -> RecoveryScore {
        let hrv = try await healthKitManager.fetchHRV()
        let sleep = try await healthKitManager.fetchSleep()
        let baseline = try await repository.fetchBaseline()

        return RecoveryScore.calculate(hrv: hrv, sleep: sleep, baseline: baseline)
    }
}
```

### ViewModel Pattern
`@Observable` for SwiftUI integration:

```swift
@Observable
@MainActor
final class ProfileViewModel {
    var profile: UserProfile?
    var isLoading = false
    var error: Error?

    private let loadProfileUseCase: LoadProfileUseCase

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }

        do {
            profile = try await loadProfileUseCase.execute()
        } catch {
            self.error = error
        }
    }
}
```

---

## HealthKit Integration

```swift
// Infrastructure/HealthKit/HealthKitManager.swift
@MainActor
final class HealthKitManager {
    private let healthStore = HKHealthStore()

    func requestAuthorization() async throws { }
    func fetchWeight() async throws -> Double { }
    func fetchHeartRate() async throws -> [HeartRateSample] { }
    func fetchSleep() async throws -> SleepAnalysis { }
    func fetchHRV() async throws -> Double { }
}
```

**Note**: HealthKit requires:
- Physical device (not simulator)
- HealthKit entitlement in Xcode
- Apple Developer account

---

## Food API Integration

Three APIs with fallback chain:

```
Nutritionix (primary) → OpenFoodFacts → USDA (fallback)
```

```swift
// Infrastructure/Networking/FoodSearchService.swift
final class FoodSearchService {
    func search(_ query: String) async throws -> [Food] {
        // Try Nutritionix first
        if let results = try? await nutritionixAPI.search(query), !results.isEmpty {
            return results
        }
        // Fallback to OpenFoodFacts
        if let results = try? await openFoodFactsAPI.search(query), !results.isEmpty {
            return results
        }
        // Final fallback to USDA
        return try await usdaAPI.search(query)
    }
}
```

---

## File Structure

```
VitalArc/
├── Domain/
│   ├── Entities/
│   │   ├── UserProfile.swift
│   │   ├── Workout.swift
│   │   ├── Food.swift
│   │   ├── HealthMetrics.swift
│   │   └── Mesocycle.swift
│   ├── Repositories/
│   │   ├── WorkoutRepository.swift
│   │   ├── NutritionRepository.swift
│   │   └── HealthMetricsRepository.swift
│   └── UseCases/
│       ├── CreateWorkoutUseCase.swift
│       ├── CalculateRecoveryScoreUseCase.swift
│       └── ...
├── Data/
│   ├── Models/
│   │   ├── WorkoutModel.swift
│   │   ├── FoodModel.swift
│   │   └── ...
│   └── Seeds/
│       └── ExerciseSeeds.swift (200+ exercises)
├── Infrastructure/
│   ├── DependencyContainer.swift
│   ├── HealthKit/
│   │   └── HealthKitManager.swift
│   ├── Networking/
│   │   ├── NutritionixAPI.swift
│   │   ├── OpenFoodFactsAPI.swift
│   │   └── USDAFoodAPI.swift
│   ├── Cache/
│   │   └── FoodCache.swift
│   └── Export/
│       ├── PDFExporter.swift
│       └── CSVExporter.swift
└── Presentation/
    ├── Common/
    │   └── DesignSystem/
    ├── Onboarding/
    └── Tabs/
        ├── Health/
        ├── Workout/
        ├── Nutrition/
        ├── Analytics/
        └── Profile/
```
