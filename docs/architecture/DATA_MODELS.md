# VitalArc - Data Models

## Overview

This document defines all data models used in VitalArc, organized by domain. Models are defined as Swift structs (domain entities) with corresponding SwiftData @Model classes for persistence.

---

## Workout Domain

### Exercise

```swift
/// Represents a single exercise in the library
struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var muscleGroups: [MuscleGroup]
    var primaryMuscle: MuscleGroup
    var equipment: Equipment
    var instructions: String?
    var videoURL: URL?
    var isCustom: Bool
    var createdAt: Date

    // For progression tracking
    var minimumWeightIncrement: Double  // e.g., 2.5 lbs
    var defaultRepRange: ClosedRange<Int>  // e.g., 8...12
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case forearms
    case quads
    case hamstrings
    case glutes
    case calves
    case abs
    case obliques
    case lowerBack
    case traps
    case neck
}

enum Equipment: String, Codable, CaseIterable {
    case barbell
    case dumbbell
    case cable
    case machine
    case bodyweight
    case kettlebell
    case resistanceBand
    case other
}
```

### WorkoutSet

```swift
/// A single set performed during a workout
struct WorkoutSet: Identifiable, Codable {
    let id: UUID
    let exerciseId: UUID
    var weight: Double  // in user's preferred unit
    var reps: Int
    var rir: Int  // Reps in Reserve (0-5)
    var timestamp: Date
    var notes: String?

    // Computed properties
    var estimatedOneRepMax: Double {
        // Epley formula: 1RM = weight × (1 + reps/30)
        weight * (1 + Double(reps) / 30.0)
    }

    var relativeIntensity: Double {
        // Percentage of 1RM based on reps + RIR
        let effectiveReps = reps + rir
        return 1.0 / (1.0 + Double(effectiveReps) / 30.0)
    }
}
```

### Workout

```swift
/// A complete workout session
struct Workout: Identifiable, Codable {
    let id: UUID
    let mesocycleId: UUID?
    var name: String
    var scheduledDate: Date
    var startTime: Date?
    var endTime: Date?
    var exercises: [WorkoutExercise]  // Exercises with their sets
    var feedback: WorkoutFeedback?
    var notes: String?

    // Computed
    var duration: TimeInterval? {
        guard let start = startTime, let end = endTime else { return nil }
        return end.timeIntervalSince(start)
    }

    var totalVolume: Double {
        exercises.flatMap { $0.sets }.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }

    var isCompleted: Bool {
        endTime != nil
    }
}

struct WorkoutExercise: Identifiable, Codable {
    let id: UUID
    let exerciseId: UUID
    var exerciseName: String  // Denormalized for display
    var targetSets: Int
    var targetReps: ClosedRange<Int>
    var targetRIR: Int
    var suggestedWeight: Double?
    var sets: [WorkoutSet]
    var restSeconds: Int
    var supersetGroup: Int?  // nil if not in superset
}
```

### WorkoutFeedback

```swift
/// Post-workout feedback for autoregulation
struct WorkoutFeedback: Codable {
    var pumpQuality: FeedbackRating  // How well muscles filled
    var muscleSoreness: FeedbackRating  // Expected next-day soreness
    var workloadPerception: FeedbackRating  // Overall difficulty
    var performanceRating: FeedbackRating  // Strength/energy level
    var notes: String?
    var timestamp: Date
}

enum FeedbackRating: Int, Codable, CaseIterable {
    case veryLow = 1
    case low = 2
    case moderate = 3
    case high = 4
    case veryHigh = 5

    var description: String {
        switch self {
        case .veryLow: return "Very Low"
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .veryHigh: return "Very High"
        }
    }
}
```

### Mesocycle

```swift
/// A training block (typically 4-6 weeks)
struct Mesocycle: Identifiable, Codable {
    let id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var weeks: Int  // 4-6 typically
    var deloadWeek: Int  // Which week is deload (usually last)
    var splitType: SplitType
    var workouts: [Workout]
    var muscleTargets: [MuscleTarget]
    var status: MesocycleStatus
    var notes: String?

    // Configuration
    var startingRIR: Int  // Usually 4
    var weeklyRIRDecrease: Int  // Usually 1
    var volumeProgressionRate: Double  // % increase per week
}

enum SplitType: String, Codable, CaseIterable {
    case pushPullLegs = "Push/Pull/Legs"
    case upperLower = "Upper/Lower"
    case fullBody = "Full Body"
    case bodyPartSplit = "Body Part Split"
    case custom = "Custom"
}

struct MuscleTarget: Codable {
    var muscleGroup: MuscleGroup
    var priority: MusclePriority
    var startingSets: Int  // Sets per week at start
    var targetMRV: Int?  // Target max recoverable volume
}

enum MusclePriority: String, Codable {
    case emphasize  // High volume, 3-4x/week
    case maintain  // Moderate volume, ~6 sets/week
    case ignore  // No direct work
}

enum MesocycleStatus: String, Codable {
    case planned
    case active
    case completed
    case abandoned
}
```

---

## Nutrition Domain

### Food

```swift
/// A food item from database or custom
struct Food: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var brand: String?
    var barcode: String?
    var servingSize: Double
    var servingUnit: ServingUnit
    var calories: Double
    var protein: Double  // grams
    var carbs: Double  // grams
    var fat: Double  // grams
    var fiber: Double?
    var sugar: Double?
    var sodium: Double?  // mg
    var micronutrients: [Micronutrient]?
    var isCustom: Bool
    var isVerified: Bool
    var source: FoodSource

    // Per gram values for easy calculation
    var caloriesPerGram: Double { calories / servingSize }
    var proteinPerGram: Double { protein / servingSize }
    var carbsPerGram: Double { carbs / servingSize }
    var fatPerGram: Double { fat / servingSize }
}

enum ServingUnit: String, Codable, CaseIterable {
    case gram = "g"
    case ounce = "oz"
    case cup = "cup"
    case tablespoon = "tbsp"
    case teaspoon = "tsp"
    case piece = "piece"
    case slice = "slice"
    case serving = "serving"
}

enum FoodSource: String, Codable {
    case usda
    case openFoodFacts
    case custom
    case aiGenerated
}

struct Micronutrient: Codable, Hashable {
    var name: String
    var amount: Double
    var unit: String
    var dailyValuePercent: Double?
}
```

### FoodEntry

```swift
/// A logged food item
struct FoodEntry: Identifiable, Codable {
    let id: UUID
    let foodId: UUID
    var foodName: String  // Denormalized
    var servings: Double
    var servingSize: Double
    var servingUnit: ServingUnit
    var timestamp: Date
    var mealType: MealType?
    var notes: String?

    // Calculated nutrition for this entry
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
}

enum MealType: String, Codable, CaseIterable {
    case breakfast
    case lunch
    case dinner
    case snack
}
```

### DailyNutrition

```swift
/// Aggregated nutrition for a single day
struct DailyNutrition: Identifiable, Codable {
    let id: UUID
    var date: Date
    var entries: [FoodEntry]
    var weight: Double?  // Morning weigh-in
    var waterIntake: Double?  // ml

    // Totals
    var totalCalories: Double {
        entries.reduce(0) { $0 + $1.calories }
    }
    var totalProtein: Double {
        entries.reduce(0) { $0 + $1.protein }
    }
    var totalCarbs: Double {
        entries.reduce(0) { $0 + $1.carbs }
    }
    var totalFat: Double {
        entries.reduce(0) { $0 + $1.fat }
    }

    // Compliance
    var calorieCompliance: Double?  // % of target
    var proteinCompliance: Double?
}
```

### NutritionGoal

```swift
/// User's nutrition targets
struct NutritionGoal: Codable {
    var goalType: NutritionGoalType
    var targetWeight: Double?
    var weeklyRateOfChange: Double  // % of bodyweight per week
    var calories: Int
    var protein: Int  // grams
    var carbs: Int  // grams
    var fat: Int  // grams
    var programMode: ProgramMode
    var dietStructure: DietStructure
    var lastAdjusted: Date
}

enum NutritionGoalType: String, Codable {
    case lose  // Cut
    case gain  // Bulk
    case maintain
    case recomp
}

enum ProgramMode: String, Codable {
    case coached  // App controls everything
    case collaborative  // User sets macros, app adjusts calories
    case manual  // Full user control
}

enum DietStructure: String, Codable {
    case balanced  // ~30% protein, 35% carbs, 35% fat
    case lowFat  // ~30% protein, 50% carbs, 20% fat
    case lowCarb  // ~30% protein, 20% carbs, 50% fat
    case keto  // ~25% protein, 5% carbs, 70% fat
}
```

### ExpenditureData

```swift
/// Data for adaptive TDEE calculation
struct ExpenditureData: Codable {
    var date: Date
    var estimatedExpenditure: Double
    var confidence: Double  // 0-1
    var trendWeight: Double  // Smoothed weight
    var rawWeight: Double?
    var caloriesConsumed: Double
    var trackingCompleteness: Double  // % of day tracked
}
```

---

## Health Domain

### RecoveryScore

```swift
/// Daily recovery assessment
struct RecoveryScore: Identifiable, Codable {
    let id: UUID
    var date: Date
    var score: Double  // 0-100
    var category: RecoveryCategory
    var hrvValue: Double?
    var hrvBaseline: Double?
    var hrvContribution: Double  // How much HRV affected score
    var rhrValue: Double?
    var rhrBaseline: Double?
    var rhrContribution: Double
    var factors: [RecoveryFactor]

    var recommendation: String {
        switch category {
        case .poor: return "Consider rest or light activity"
        case .fair: return "Moderate training recommended"
        case .good: return "Ready for normal training"
        case .excellent: return "Great day for hard training"
        }
    }
}

enum RecoveryCategory: String, Codable {
    case poor  // 0-33
    case fair  // 34-66
    case good  // 67-85
    case excellent  // 86-100
}

struct RecoveryFactor: Codable {
    var name: String
    var impact: FactorImpact
    var value: String
}

enum FactorImpact: String, Codable {
    case positive
    case neutral
    case negative
}
```

### StrainScore

```swift
/// Daily strain/exertion measurement
struct StrainScore: Identifiable, Codable {
    let id: UUID
    var date: Date
    var score: Double  // 0-100 (or 0-21 like Whoop)
    var activeStrain: Double  // From workouts
    var passiveStrain: Double  // From daily activity
    var targetStrain: Double?  // Recommended based on recovery
    var heartRateZones: HeartRateZoneData
    var workouts: [WorkoutStrain]
}

struct HeartRateZoneData: Codable {
    var zone1Minutes: Int  // 50-60% max HR
    var zone2Minutes: Int  // 60-70%
    var zone3Minutes: Int  // 70-80%
    var zone4Minutes: Int  // 80-90%
    var zone5Minutes: Int  // 90-100%

    var totalMinutes: Int {
        zone1Minutes + zone2Minutes + zone3Minutes + zone4Minutes + zone5Minutes
    }
}

struct WorkoutStrain: Codable {
    var workoutId: UUID
    var workoutName: String
    var strain: Double
    var duration: TimeInterval
    var averageHR: Double
    var maxHR: Double
    var calories: Double
}
```

### SleepData

```swift
/// Nightly sleep analysis
struct SleepData: Identifiable, Codable {
    let id: UUID
    var date: Date  // The night of (sleep that ends on this date's morning)
    var bedtime: Date
    var wakeTime: Date
    var totalSleepMinutes: Int
    var sleepScore: Double  // 0-100
    var stages: SleepStages
    var efficiency: Double  // Time asleep / time in bed
    var latency: Int  // Minutes to fall asleep
    var interruptions: Int
    var averageHRV: Double?
    var averageRHR: Double?
    var respiratoryRate: Double?

    var totalHours: Double {
        Double(totalSleepMinutes) / 60.0
    }
}

struct SleepStages: Codable {
    var awakeMinutes: Int
    var remMinutes: Int
    var lightMinutes: Int  // Core/N1+N2
    var deepMinutes: Int  // N3

    var remPercent: Double {
        let total = remMinutes + lightMinutes + deepMinutes
        return total > 0 ? Double(remMinutes) / Double(total) * 100 : 0
    }

    var deepPercent: Double {
        let total = remMinutes + lightMinutes + deepMinutes
        return total > 0 ? Double(deepMinutes) / Double(total) * 100 : 0
    }
}
```

### TrainingLoad

```swift
/// Acute and chronic training load tracking
struct TrainingLoad: Codable {
    var date: Date
    var acuteLoad: Double  // ATL - 7 day EWMA
    var chronicLoad: Double  // CTL - 42 day EWMA
    var trainingStressBalance: Double  // CTL - ATL
    var rampRate: Double  // Week-over-week change in CTL
    var status: TrainingStatus
}

enum TrainingStatus: String, Codable {
    case detraining  // CTL dropping significantly
    case maintaining  // CTL stable
    case productive  // CTL rising, TSB manageable
    case peaking  // High CTL, positive TSB
    case fatigued  // High ATL, negative TSB
    case overtraining  // Sustained negative TSB
}
```

### HealthMetrics

```swift
/// Point-in-time health reading
struct HealthMetrics: Codable {
    var timestamp: Date
    var heartRate: Double?
    var hrv: Double?
    var hrvMethod: HRVMethod?
    var bloodOxygen: Double?
    var respiratoryRate: Double?
    var wristTemperature: Double?
    var steps: Int?
    var activeCalories: Double?
    var source: HealthDataSource
}

enum HRVMethod: String, Codable {
    case sdnn
    case rmssd
}

enum HealthDataSource: String, Codable {
    case appleWatch
    case healthKit
    case manual
}
```

---

## User Domain

### UserProfile

```swift
/// User's profile and settings
struct UserProfile: Codable {
    var id: UUID
    var email: String?
    var displayName: String?
    var birthDate: Date?
    var biologicalSex: BiologicalSex?
    var height: Double?  // cm
    var activityLevel: ActivityLevel
    var fitnessGoal: FitnessGoal
    var createdAt: Date
    var lastSyncAt: Date?
}

enum BiologicalSex: String, Codable {
    case male
    case female
    case other
}

enum ActivityLevel: String, Codable {
    case sedentary  // Little or no exercise
    case lightlyActive  // Light exercise 1-3 days/week
    case moderatelyActive  // Moderate exercise 3-5 days/week
    case veryActive  // Hard exercise 6-7 days/week
    case extraActive  // Very hard exercise, physical job
}

enum FitnessGoal: String, Codable {
    case buildMuscle
    case loseWeight
    case gainStrength
    case improveEndurance
    case maintainHealth
}
```

### UserPreferences

```swift
/// User's app preferences
struct UserPreferences: Codable {
    // Units
    var weightUnit: WeightUnit
    var distanceUnit: DistanceUnit
    var energyUnit: EnergyUnit

    // Workout
    var defaultRestTimer: Int  // seconds
    var autoStartRestTimer: Bool
    var vibrateOnTimerEnd: Bool
    var showEstimated1RM: Bool

    // Nutrition
    var mealReminders: Bool
    var weighInReminder: Bool
    var weighInTime: Date?
    var showMicronutrients: Bool

    // Health
    var hrvMethod: HRVMethod
    var sleepGoalHours: Double
    var targetRecoveryThreshold: Double  // Min recovery to recommend hard training

    // Notifications
    var workoutReminders: Bool
    var insightNotifications: Bool
    var weeklyReportDay: Int  // 1-7
}

enum WeightUnit: String, Codable {
    case pounds = "lbs"
    case kilograms = "kg"
}

enum DistanceUnit: String, Codable {
    case miles
    case kilometers
}

enum EnergyUnit: String, Codable {
    case calories = "cal"
    case kilojoules = "kJ"
}
```

---

## SwiftData Models

### Example SwiftData @Model

```swift
import SwiftData

@Model
final class WorkoutModel {
    @Attribute(.unique) var id: UUID
    var mesocycleId: UUID?
    var name: String
    var scheduledDate: Date
    var startTime: Date?
    var endTime: Date?
    var notes: String?

    // Relationships
    @Relationship(deleteRule: .cascade)
    var exercises: [WorkoutExerciseModel] = []

    @Relationship(deleteRule: .cascade)
    var feedback: WorkoutFeedbackModel?

    // Sync metadata
    var createdAt: Date
    var updatedAt: Date
    var syncStatus: SyncStatus

    init(from entity: Workout) {
        self.id = entity.id
        self.mesocycleId = entity.mesocycleId
        self.name = entity.name
        self.scheduledDate = entity.scheduledDate
        self.startTime = entity.startTime
        self.endTime = entity.endTime
        self.notes = entity.notes
        self.createdAt = Date()
        self.updatedAt = Date()
        self.syncStatus = .pending
    }
}

@Model
final class WorkoutExerciseModel {
    @Attribute(.unique) var id: UUID
    var exerciseId: UUID
    var exerciseName: String
    var targetSets: Int
    var targetRepsMin: Int
    var targetRepsMax: Int
    var targetRIR: Int
    var suggestedWeight: Double?
    var restSeconds: Int
    var supersetGroup: Int?

    @Relationship(deleteRule: .cascade)
    var sets: [WorkoutSetModel] = []

    @Relationship(inverse: \WorkoutModel.exercises)
    var workout: WorkoutModel?
}

@Model
final class WorkoutSetModel {
    @Attribute(.unique) var id: UUID
    var exerciseId: UUID
    var weight: Double
    var reps: Int
    var rir: Int
    var timestamp: Date
    var notes: String?

    @Relationship(inverse: \WorkoutExerciseModel.sets)
    var workoutExercise: WorkoutExerciseModel?
}

enum SyncStatus: String, Codable {
    case pending
    case synced
    case conflict
    case failed
}
```

---

## Data Validation Rules

### Workout Validation
- Weight: 0-2000 lbs/kg
- Reps: 1-100
- RIR: 0-5
- Sets per exercise: 1-20
- Exercises per workout: 1-30
- Rest timer: 0-600 seconds

### Nutrition Validation
- Calories: 0-10000 per food
- Macros: 0-1000g per food
- Servings: 0.01-100
- Daily calories: 0-20000
- Weight: 50-500 lbs / 25-250 kg

### Health Validation
- HRV: 1-300 ms
- RHR: 30-200 bpm
- Sleep: 0-24 hours
- Recovery score: 0-100
- Strain score: 0-100

---

## Migration Strategy

For future schema changes:

```swift
enum VitalArcSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] = [
        WorkoutModel.self,
        WorkoutExerciseModel.self,
        WorkoutSetModel.self,
        // ... all models
    ]
}

// Future migration example
enum VitalArcSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] = [
        // Updated models
    ]
}

enum VitalArcMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [
        VitalArcSchemaV1.self,
        VitalArcSchemaV2.self
    ]

    static var stages: [MigrationStage] = [
        migrateV1toV2
    ]

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: VitalArcSchemaV1.self,
        toVersion: VitalArcSchemaV2.self
    )
}
```
