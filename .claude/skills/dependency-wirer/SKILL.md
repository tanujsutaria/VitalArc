---
name: dependency-wirer
description: Update DependencyContainer.swift to wire new repositories, use cases, and ViewModels. Follows VitalArc's dependency injection patterns.
maps-to-agent: Plan
allowed-tools: Read, Edit, Grep, Glob
argument-hint: <feature-name> [--entity=Name] [--repository=Name] [--usecase=Name]
---

# Dependency Wirer

Wires new components into VitalArc's dependency injection system.

## What It Does

1. Adds repository implementations to DependencyContainer
2. Adds use case initializations
3. Updates environment injection
4. Creates SwiftData @Model if needed

## VitalArc DI Pattern

```swift
// DependencyContainer.swift structure
@MainActor
final class DependencyContainer: ObservableObject {
    // Repositories
    let workoutRepository: WorkoutRepository
    let nutritionRepository: NutritionRepository
    // ... add new repositories here

    // Use Cases
    let createWorkoutUseCase: CreateWorkoutUseCase
    let getWorkoutsUseCase: GetWorkoutsUseCase
    // ... add new use cases here

    init(modelContext: ModelContext) {
        // Initialize repositories
        self.workoutRepository = SwiftDataWorkoutRepository(modelContext: modelContext)

        // Initialize use cases
        self.createWorkoutUseCase = CreateWorkoutUseCase(repository: workoutRepository)
    }
}
```

## Implementation

### 1. Read Current Container

```bash
# Get current DependencyContainer structure
cat VitalArc/Infrastructure/DependencyContainer.swift
```

### 2. Identify Injection Points

Find where to add:
- Repository property declaration
- Repository initialization
- Use case property declaration
- Use case initialization

### 3. Generate Wiring Code

For a new feature like "Achievements":

```swift
// Add to properties section
let achievementRepository: AchievementRepository
let getAchievementsUseCase: GetAchievementsUseCase
let unlockAchievementUseCase: UnlockAchievementUseCase

// Add to init
self.achievementRepository = SwiftDataAchievementRepository(modelContext: modelContext)
self.getAchievementsUseCase = GetAchievementsUseCase(repository: achievementRepository)
self.unlockAchievementUseCase = UnlockAchievementUseCase(repository: achievementRepository)
```

### 4. Apply Edits

Use Edit tool to insert at correct locations:

```
Edit file: VitalArc/Infrastructure/DependencyContainer.swift
old_string: let nutritionRepository: NutritionRepository
new_string: let nutritionRepository: NutritionRepository
    let achievementRepository: AchievementRepository
```

## Input Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `feature-name` | Feature being wired | `achievements` |
| `--entity` | Entity name (optional) | `Achievement` |
| `--repository` | Repository protocol name | `AchievementRepository` |
| `--usecase` | Use case names (comma-separated) | `GetAchievements,UnlockAchievement` |

## Output Format

### Wiring Plan

```markdown
## Dependency Wiring Plan: Achievements

### Components to Wire

| Type | Name | Dependencies |
|------|------|--------------|
| Repository | AchievementRepository | ModelContext |
| Use Case | GetAchievementsUseCase | AchievementRepository |
| Use Case | UnlockAchievementUseCase | AchievementRepository |

### Files to Modify

1. **DependencyContainer.swift**
   - Add repository property
   - Add use case properties
   - Add initializations

2. **Create SwiftData Model** (if needed)
   - AchievementModel.swift with @Model

### Generated Code

#### Repository Property
```swift
let achievementRepository: AchievementRepository
```

#### Use Case Properties
```swift
let getAchievementsUseCase: GetAchievementsUseCase
let unlockAchievementUseCase: UnlockAchievementUseCase
```

#### Initialization
```swift
self.achievementRepository = SwiftDataAchievementRepository(modelContext: modelContext)
self.getAchievementsUseCase = GetAchievementsUseCase(repository: achievementRepository)
self.unlockAchievementUseCase = UnlockAchievementUseCase(repository: achievementRepository)
```

### Apply Changes?
Confirm to apply these edits to DependencyContainer.swift
```

### After Wiring

```markdown
## Dependency Wiring Complete

### Changes Applied

| File | Change |
|------|--------|
| DependencyContainer.swift | +3 properties, +3 initializations |

### Verification
- [ ] Build passes
- [ ] Repository accessible via container
- [ ] Use cases can be injected into ViewModels

### Next Steps
1. Create SwiftDataAchievementRepository implementation
2. Create ViewModel with use case injection
3. Add @Environment access in views
```

## SwiftData Model Generation

If entity needs persistence, generate @Model:

```swift
// AchievementModel.swift
import SwiftData

@Model
final class AchievementModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var achievementDescription: String
    var unlockedAt: Date?
    var category: String

    init(id: UUID = UUID(), name: String, description: String, unlockedAt: Date? = nil, category: String) {
        self.id = id
        self.name = name
        self.achievementDescription = description
        self.unlockedAt = unlockedAt
        self.category = category
    }

    // Domain conversion
    func toDomain() -> Achievement {
        Achievement(
            id: id,
            name: name,
            description: achievementDescription,
            unlockedAt: unlockedAt,
            category: AchievementCategory(rawValue: category) ?? .milestone
        )
    }

    static func fromDomain(_ achievement: Achievement) -> AchievementModel {
        AchievementModel(
            id: achievement.id,
            name: achievement.name,
            description: achievement.description,
            unlockedAt: achievement.unlockedAt,
            category: achievement.category.rawValue
        )
    }
}
```

## Error Handling

### Container Not Found

```markdown
## ❌ DependencyContainer Not Found

Could not find DependencyContainer.swift at expected location.

Expected: VitalArc/Infrastructure/DependencyContainer.swift

Please verify project structure.
```

### Duplicate Component

```markdown
## ⚠️ Component Already Exists

AchievementRepository is already declared in DependencyContainer.

**Existing declaration** (line 45):
```swift
let achievementRepository: AchievementRepository
```

Skip this component or choose a different name.
```

### Missing Dependencies

```markdown
## ⚠️ Missing Dependencies

The following dependencies are required but not found:

- `AchievementRepository` protocol (not in Domain/Repositories/)
- `SwiftDataAchievementRepository` class (not in Data/)

Create these files first, then re-run dependency-wirer.
```
