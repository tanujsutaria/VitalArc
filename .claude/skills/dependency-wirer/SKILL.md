---
name: dependency-wirer
description: Update DependencyContainer.swift to wire new repositories, use cases, and ViewModels. Follows VitalArc's dependency injection patterns.
context: fork
agent: Plan
allowed-tools: Read, Edit, Grep, Glob, TaskCreate, TaskUpdate, TaskList
argument-hint: <feature-name> [--entity=Name] [--repository=Name] [--usecase=Name]
---

# Dependency Wirer

Wires new components into VitalArc's dependency injection system.

**Execution**: Runs in forked context with Plan agent for isolated analysis and targeted edits.

## What It Does

1. Adds repository implementations to DependencyContainer
2. Adds use case initializations
3. Updates environment injection
4. Creates SwiftData @Model if needed

## VitalArc DI Pattern

`DependencyContainer` is an `@MainActor final class` that does NOT hold repositories
inline. It delegates to per-domain sub-containers — `WorkoutContainer`,
`WellnessContainer`, and `SharedContainer` (all in
`VitalArc/Modules/Shared/DependencyContainer/`) — and exposes backward-compatible
computed accessors so callers can still use `container.workoutRepository`.

**To wire a new component:** add the repository/use case to the owning sub-container,
then add a computed accessor on `DependencyContainer` that delegates to it.

```swift
// DependencyContainer.swift structure
@MainActor
final class DependencyContainer {
    // Domain sub-containers
    let workout: WorkoutContainer
    let wellness: WellnessContainer
    let shared: SharedContainer

    init(modelContext: ModelContext) {
        self.workout = WorkoutContainer(modelContext: modelContext)
        self.wellness = WellnessContainer(modelContext: modelContext)
        self.shared = SharedContainer(modelContext: modelContext)
    }

    // Backward-compatible computed accessors delegate to sub-containers
    var workoutRepository: WorkoutRepository { workout.workoutRepository }
    var createWorkoutUseCase: CreateWorkoutUseCase { workout.createWorkoutUseCase }
    // ... add new accessors here
}

// WorkoutContainer.swift — the owning sub-container holds the real instances
@MainActor
final class WorkoutContainer {
    let workoutRepository: WorkoutRepository
    let createWorkoutUseCase: CreateWorkoutUseCase
    // ... add new repositories / use cases here

    init(modelContext: ModelContext) {
        self.workoutRepository = SwiftDataWorkoutRepository(modelContext: modelContext)
        self.createWorkoutUseCase = CreateWorkoutUseCase(repository: workoutRepository)
    }
}
```

## Task Tracking

When wiring multiple components, create tasks to track progress:

```javascript
// Create task for each component being wired
components.forEach(component => {
  TaskCreate({
    subject: `Wire ${component.type}: ${component.name}`,
    description: `Add ${component.name} to DependencyContainer:
      - Add property declaration
      - Add initialization in init()
      - Verify dependencies are available`,
    activeForm: `Wiring ${component.name}`
  })
})

// Update task status as each component is wired
TaskUpdate({
  taskId: task.id,
  status: "completed"
})
```

This provides visibility when wiring complex features with multiple components.

## Implementation

### 1. Read Current Container

```bash
# Get current DependencyContainer + sub-container structure
cat VitalArc/Modules/Shared/DependencyContainer/DependencyContainer.swift
cat VitalArc/Modules/Shared/DependencyContainer/WorkoutContainer.swift
```

### 2. Identify the Owning Sub-Container

Pick the sub-container that owns the domain:
- `WorkoutContainer` — workout repositories and use cases
- `WellnessContainer` — wellness / HealthKit repositories and use cases
- `SharedContainer` — user, analytics, notifications, cross-domain services

Then find where to add:
- Repository property declaration (in the sub-container)
- Repository initialization (in the sub-container `init`)
- Use case property declaration + initialization (in the sub-container)
- Backward-compatible computed accessor (on `DependencyContainer`)

### 3. Generate Wiring Code

For a new workout feature like "Achievements" (owned by `WorkoutContainer`):

```swift
// In WorkoutContainer — add to properties section
let achievementRepository: AchievementRepository
let getAchievementsUseCase: GetAchievementsUseCase
let unlockAchievementUseCase: UnlockAchievementUseCase

// In WorkoutContainer init
self.achievementRepository = SwiftDataAchievementRepository(modelContext: modelContext)
self.getAchievementsUseCase = GetAchievementsUseCase(repository: achievementRepository)
self.unlockAchievementUseCase = UnlockAchievementUseCase(repository: achievementRepository)

// On DependencyContainer — add backward-compatible accessors
var achievementRepository: AchievementRepository { workout.achievementRepository }
var getAchievementsUseCase: GetAchievementsUseCase { workout.getAchievementsUseCase }
var unlockAchievementUseCase: UnlockAchievementUseCase { workout.unlockAchievementUseCase }
```

### 4. Apply Edits

Use Edit tool to insert at correct locations in the owning sub-container:

```
Edit file: VitalArc/Modules/Shared/DependencyContainer/WorkoutContainer.swift
old_string: let workoutRepository: WorkoutRepository
new_string: let workoutRepository: WorkoutRepository
    let achievementRepository: AchievementRepository
```

Then add the delegating accessor:

```
Edit file: VitalArc/Modules/Shared/DependencyContainer/DependencyContainer.swift
old_string: var workoutRepository: WorkoutRepository { workout.workoutRepository }
new_string: var workoutRepository: WorkoutRepository { workout.workoutRepository }
    var achievementRepository: AchievementRepository { workout.achievementRepository }
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

1. **WorkoutContainer.swift** (owning sub-container)
   - Add repository property
   - Add use case properties
   - Add initializations in init()

2. **DependencyContainer.swift**
   - Add backward-compatible computed accessors delegating to the sub-container

3. **Create SwiftData Model** (if needed)
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
| WorkoutContainer.swift | +3 properties, +3 initializations |
| DependencyContainer.swift | +3 computed accessors |

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

Expected: VitalArc/Modules/Shared/DependencyContainer/DependencyContainer.swift

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
