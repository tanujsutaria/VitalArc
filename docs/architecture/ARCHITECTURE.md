# VitalArc - Technical Architecture

## Overview

VitalArc follows Clean Architecture principles with MVVM presentation pattern, optimized for iOS development with SwiftUI and SwiftData.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Views     │  │ ViewModels  │  │   Router    │             │
│  │  (SwiftUI)  │◄─┤  (Observable)│  │ (Navigation)│             │
│  └─────────────┘  └──────┬──────┘  └─────────────┘             │
└──────────────────────────┼──────────────────────────────────────┘
                           │
┌──────────────────────────┼──────────────────────────────────────┐
│                        DOMAIN                                    │
│  ┌─────────────┐  ┌──────┴──────┐  ┌─────────────┐             │
│  │   Entities  │  │  Use Cases  │  │ Repository  │             │
│  │   (Models)  │  │  (Interactors)│ │ (Protocols) │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────┼──────────────────────────────────────┐
│                         DATA                                     │
│  ┌─────────────┐  ┌──────┴──────┐  ┌─────────────┐             │
│  │  SwiftData  │  │ Repository  │  │   Remote    │             │
│  │   (Local)   │  │   (Impl)    │  │  (CloudKit) │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────┼──────────────────────────────────────┐
│                    INFRASTRUCTURE                                │
│  ┌─────────────┐  ┌──────┴──────┐  ┌─────────────┐             │
│  │  HealthKit  │  │   CoreML    │  │  Networking │             │
│  │  Service    │  │   Service   │  │   Service   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### Presentation Layer
- **Views**: SwiftUI views, stateless UI components
- **ViewModels**: @Observable classes managing view state
- **Router**: Navigation logic using NavigationStack

### Domain Layer
- **Entities**: Core business objects (Workout, Mesocycle, Food, etc.)
- **Use Cases**: Single-responsibility business logic operations
- **Repository Protocols**: Abstract data access interfaces

### Data Layer
- **SwiftData Models**: Persistent data models with @Model
- **Repository Implementations**: Concrete data access
- **Mappers**: Convert between domain entities and data models

### Infrastructure Layer
- **HealthKit Service**: Apple Health read/write operations
- **CoreML Service**: On-device ML model inference
- **CloudKit Service**: Cloud sync and backup
- **Networking**: API calls for food database, etc.

---

## Project Structure

```
VitalArc/
├── App/
│   ├── VitalArcApp.swift              # App entry point
│   ├── AppDelegate.swift              # App lifecycle
│   ├── DependencyContainer.swift      # DI container
│   └── Configuration/
│       ├── AppConfiguration.swift     # Environment config
│       └── FeatureFlags.swift         # Feature toggles
│
├── Core/
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── Array+Extensions.swift
│   │   └── Double+Extensions.swift
│   ├── Utilities/
│   │   ├── Logger.swift
│   │   ├── Debouncer.swift
│   │   └── Cache.swift
│   └── Constants/
│       ├── AppConstants.swift
│       └── HealthKitConstants.swift
│
├── Domain/
│   ├── Entities/
│   │   ├── Workout/
│   │   │   ├── Exercise.swift
│   │   │   ├── WorkoutSet.swift
│   │   │   ├── Workout.swift
│   │   │   └── Mesocycle.swift
│   │   ├── Nutrition/
│   │   │   ├── Food.swift
│   │   │   ├── Meal.swift
│   │   │   ├── DailyNutrition.swift
│   │   │   └── NutritionGoal.swift
│   │   └── Health/
│   │       ├── RecoveryScore.swift
│   │       ├── StrainScore.swift
│   │       ├── SleepData.swift
│   │       └── HealthMetrics.swift
│   │
│   ├── UseCases/
│   │   ├── Workout/
│   │   │   ├── CreateMesocycleUseCase.swift
│   │   │   ├── LogWorkoutSetUseCase.swift
│   │   │   ├── CalculateProgressionUseCase.swift
│   │   │   └── ProcessFeedbackUseCase.swift
│   │   ├── Nutrition/
│   │   │   ├── LogFoodUseCase.swift
│   │   │   ├── CalculateExpenditureUseCase.swift
│   │   │   ├── AdjustMacrosUseCase.swift
│   │   │   └── SearchFoodUseCase.swift
│   │   └── Health/
│   │       ├── CalculateRecoveryUseCase.swift
│   │       ├── CalculateStrainUseCase.swift
│   │       ├── AnalyzeSleepUseCase.swift
│   │       └── GenerateInsightsUseCase.swift
│   │
│   └── Repositories/
│       ├── WorkoutRepositoryProtocol.swift
│       ├── NutritionRepositoryProtocol.swift
│       ├── HealthRepositoryProtocol.swift
│       └── UserRepositoryProtocol.swift
│
├── Data/
│   ├── Models/
│   │   ├── WorkoutModels.swift        # @Model classes
│   │   ├── NutritionModels.swift
│   │   └── HealthModels.swift
│   │
│   ├── Repositories/
│   │   ├── WorkoutRepository.swift
│   │   ├── NutritionRepository.swift
│   │   ├── HealthRepository.swift
│   │   └── UserRepository.swift
│   │
│   ├── DataSources/
│   │   ├── Local/
│   │   │   ├── SwiftDataManager.swift
│   │   │   └── UserDefaultsManager.swift
│   │   └── Remote/
│   │       ├── CloudKitManager.swift
│   │       └── FoodAPIClient.swift
│   │
│   └── Mappers/
│       ├── WorkoutMapper.swift
│       ├── NutritionMapper.swift
│       └── HealthMapper.swift
│
├── Presentation/
│   ├── Common/
│   │   ├── Components/
│   │   │   ├── LoadingView.swift
│   │   │   ├── ErrorView.swift
│   │   │   ├── EmptyStateView.swift
│   │   │   └── Charts/
│   │   │       ├── LineChartView.swift
│   │   │       └── BarChartView.swift
│   │   └── Modifiers/
│   │       ├── CardModifier.swift
│   │       └── ShimmerModifier.swift
│   │
│   ├── Workout/
│   │   ├── Views/
│   │   │   ├── WorkoutDashboardView.swift
│   │   │   ├── MesocycleListView.swift
│   │   │   ├── MesocycleDetailView.swift
│   │   │   ├── WorkoutLogView.swift
│   │   │   ├── ExerciseLibraryView.swift
│   │   │   └── FeedbackView.swift
│   │   └── ViewModels/
│   │       ├── WorkoutDashboardViewModel.swift
│   │       ├── MesocycleViewModel.swift
│   │       ├── WorkoutLogViewModel.swift
│   │       └── ExerciseLibraryViewModel.swift
│   │
│   ├── Nutrition/
│   │   ├── Views/
│   │   │   ├── NutritionDashboardView.swift
│   │   │   ├── FoodLogView.swift
│   │   │   ├── FoodSearchView.swift
│   │   │   ├── MacroSummaryView.swift
│   │   │   └── WeeklyCheckInView.swift
│   │   └── ViewModels/
│   │       ├── NutritionDashboardViewModel.swift
│   │       ├── FoodLogViewModel.swift
│   │       └── MacroAdjustmentViewModel.swift
│   │
│   ├── Health/
│   │   ├── Views/
│   │   │   ├── HealthDashboardView.swift
│   │   │   ├── RecoveryDetailView.swift
│   │   │   ├── StrainDetailView.swift
│   │   │   ├── SleepDetailView.swift
│   │   │   └── InsightsView.swift
│   │   └── ViewModels/
│   │       ├── HealthDashboardViewModel.swift
│   │       ├── RecoveryViewModel.swift
│   │       └── StrainViewModel.swift
│   │
│   └── Settings/
│       ├── Views/
│       │   ├── SettingsView.swift
│       │   ├── ProfileView.swift
│       │   └── PreferencesView.swift
│       └── ViewModels/
│           └── SettingsViewModel.swift
│
├── Infrastructure/
│   ├── HealthKit/
│   │   ├── HealthKitManager.swift
│   │   ├── HRVAnalyzer.swift
│   │   ├── SleepAnalyzer.swift
│   │   └── WorkoutWriter.swift
│   │
│   ├── ML/
│   │   ├── CoreMLManager.swift
│   │   ├── FoodRecognitionService.swift
│   │   ├── InsightGenerationService.swift
│   │   └── Models/
│   │       └── FoodClassifier.mlmodel
│   │
│   ├── Networking/
│   │   ├── NetworkManager.swift
│   │   ├── APIEndpoints.swift
│   │   └── NetworkError.swift
│   │
│   └── Notifications/
│       ├── NotificationManager.swift
│       └── NotificationScheduler.swift
│
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.strings
    ├── ExerciseDatabase.json
    └── Info.plist
```

---

## Key Design Patterns

### 1. Dependency Injection

```swift
// DependencyContainer.swift
@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()

    // Infrastructure
    lazy var healthKitManager = HealthKitManager()
    lazy var swiftDataManager = SwiftDataManager()
    lazy var cloudKitManager = CloudKitManager()

    // Repositories
    lazy var workoutRepository: WorkoutRepositoryProtocol =
        WorkoutRepository(local: swiftDataManager, remote: cloudKitManager)
    lazy var nutritionRepository: NutritionRepositoryProtocol =
        NutritionRepository(local: swiftDataManager, remote: cloudKitManager)
    lazy var healthRepository: HealthRepositoryProtocol =
        HealthRepository(healthKit: healthKitManager, local: swiftDataManager)

    // Use Cases
    func makeCalculateRecoveryUseCase() -> CalculateRecoveryUseCase {
        CalculateRecoveryUseCase(healthRepository: healthRepository)
    }

    func makeLogWorkoutSetUseCase() -> LogWorkoutSetUseCase {
        LogWorkoutSetUseCase(workoutRepository: workoutRepository)
    }
}
```

### 2. Repository Pattern

```swift
// Protocol in Domain layer
protocol WorkoutRepositoryProtocol {
    func getWorkouts(from: Date, to: Date) async throws -> [Workout]
    func saveWorkout(_ workout: Workout) async throws
    func getMesocycle(id: UUID) async throws -> Mesocycle?
    func saveMesocycle(_ mesocycle: Mesocycle) async throws
}

// Implementation in Data layer
final class WorkoutRepository: WorkoutRepositoryProtocol {
    private let local: SwiftDataManager
    private let remote: CloudKitManager

    init(local: SwiftDataManager, remote: CloudKitManager) {
        self.local = local
        self.remote = remote
    }

    func saveWorkout(_ workout: Workout) async throws {
        let model = WorkoutMapper.toModel(workout)
        try await local.save(model)
        try await remote.sync(model)
    }
}
```

### 3. Use Case Pattern

```swift
// Single responsibility use case
final class CalculateRecoveryUseCase {
    private let healthRepository: HealthRepositoryProtocol

    init(healthRepository: HealthRepositoryProtocol) {
        self.healthRepository = healthRepository
    }

    func execute(for date: Date) async throws -> RecoveryScore {
        // Get HRV data
        let hrv = try await healthRepository.getHRV(for: date)
        let hrvBaseline = try await healthRepository.getHRVBaseline(days: 60)

        // Get RHR data
        let rhr = try await healthRepository.getRHR(for: date)
        let rhrBaseline = try await healthRepository.getRHRBaseline(days: 60)

        // Calculate recovery score
        let hrvScore = calculateHRVScore(current: hrv, baseline: hrvBaseline)
        let rhrScore = calculateRHRScore(current: rhr, baseline: rhrBaseline)

        // HRV weighted higher (70/30 split)
        let totalScore = (hrvScore * 0.7) + (rhrScore * 0.3)

        return RecoveryScore(
            value: totalScore,
            date: date,
            hrvContribution: hrvScore,
            rhrContribution: rhrScore
        )
    }
}
```

### 4. Observable ViewModels

```swift
@Observable
final class WorkoutLogViewModel {
    // State
    var currentWorkout: Workout?
    var currentExercise: Exercise?
    var sets: [WorkoutSet] = []
    var isLoading = false
    var error: Error?

    // Dependencies
    private let logSetUseCase: LogWorkoutSetUseCase
    private let progressionUseCase: CalculateProgressionUseCase

    init(logSetUseCase: LogWorkoutSetUseCase,
         progressionUseCase: CalculateProgressionUseCase) {
        self.logSetUseCase = logSetUseCase
        self.progressionUseCase = progressionUseCase
    }

    func logSet(weight: Double, reps: Int, rir: Int) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let set = WorkoutSet(
                exerciseId: currentExercise!.id,
                weight: weight,
                reps: reps,
                rir: rir,
                timestamp: Date()
            )
            try await logSetUseCase.execute(set)
            sets.append(set)

            // Calculate next set suggestion
            let suggestion = try await progressionUseCase.execute(for: currentExercise!)
            // Update UI with suggestion
        } catch {
            self.error = error
        }
    }
}
```

---

## Data Flow

### Workout Logging Flow

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│   View   │───▶│ViewModel │───▶│ Use Case │───▶│Repository│
│          │    │          │    │          │    │          │
│ User taps│    │ logSet() │    │execute() │    │saveSet() │
│  "Save"  │    │  async   │    │          │    │          │
└──────────┘    └──────────┘    └──────────┘    └────┬─────┘
                     ▲                               │
                     │                               ▼
                     │              ┌──────────┐ ┌──────────┐
                     └──────────────│  Mapper  │ │SwiftData │
                      sets.append() │          │ │          │
                                    └──────────┘ └────┬─────┘
                                                      │
                                                      ▼
                                                 ┌──────────┐
                                                 │ CloudKit │
                                                 │  (sync)  │
                                                 └──────────┘
```

### Health Data Flow

```
┌──────────┐         ┌──────────┐         ┌──────────┐
│HealthKit │────────▶│HealthKit │────────▶│Repository│
│ (Apple)  │ observe │ Manager  │ process │          │
└──────────┘         └──────────┘         └────┬─────┘
                                               │
                          ┌────────────────────┼────────────────────┐
                          ▼                    ▼                    ▼
                    ┌──────────┐        ┌──────────┐        ┌──────────┐
                    │ Recovery │        │  Strain  │        │  Sleep   │
                    │ Use Case │        │ Use Case │        │ Use Case │
                    └────┬─────┘        └────┬─────┘        └────┬─────┘
                         │                   │                   │
                         └───────────────────┼───────────────────┘
                                             ▼
                                       ┌──────────┐
                                       │ Insights │
                                       │ Use Case │
                                       └────┬─────┘
                                             │
                                             ▼
                                       ┌──────────┐
                                       │ViewModel │
                                       │  Update  │
                                       └──────────┘
```

---

## Technology Decisions

### Why SwiftData over Core Data?
- Native Swift concurrency support
- Simpler API with @Model macro
- Automatic CloudKit sync
- Better integration with SwiftUI
- Future-proof (Apple's direction)

### Why MVVM over MVC/VIPER?
- Natural fit with SwiftUI's declarative paradigm
- @Observable provides reactive updates
- Simpler than VIPER for this scope
- Good testability with protocol-based dependencies

### Why Clean Architecture?
- Clear separation of concerns
- Domain logic independent of frameworks
- Easy to test each layer
- Flexible to change implementations
- Scales well with feature growth

### Why On-Device ML?
- Privacy-preserving (no data leaves device)
- Works offline
- Lower latency
- No server costs for inference
- Apple's Create ML makes it accessible

---

## Security Considerations

### Data at Rest
- SwiftData encryption enabled by default
- Keychain for sensitive preferences
- No plaintext storage of health data

### Data in Transit
- CloudKit handles encryption
- Certificate pinning for external APIs
- No analytics with PII

### Authentication
- Sign in with Apple (required)
- Biometric unlock option
- No password storage

---

## Performance Targets

| Operation | Target | Measurement |
|-----------|--------|-------------|
| App cold start | < 2s | Time to interactive |
| Screen transition | < 300ms | Animation completion |
| Set logging | < 100ms | UI update |
| Food search | < 500ms | Results displayed |
| Health sync | < 5s | Background refresh |
| Recovery calculation | < 1s | Score displayed |

---

## Testing Strategy

### Unit Tests
- All use cases
- All mappers
- Algorithm calculations
- Utility functions

### Integration Tests
- Repository + SwiftData
- HealthKit reading/writing
- CloudKit sync

### UI Tests
- Critical user flows
- Workout logging
- Food logging
- Navigation

### Coverage Target
- Domain layer: 90%+
- Data layer: 80%+
- Presentation layer: 60%+
