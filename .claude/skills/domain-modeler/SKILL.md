---
name: domain-modeler
description: Design domain layer components for VitalArc features following Clean Architecture. Use when planning new features that need entities, repositories, or use cases. Analyzes existing patterns and produces consistent domain designs.
context: fork
agent: Plan
allowed-tools: Read, Grep, Glob
---

# Domain Modeler Agent

Designs domain layer components (Entities, Repositories, Use Cases) following VitalArc's Clean Architecture patterns.

**Execution**: Runs in forked context with Plan agent for isolated analysis.

## When to Use

Auto-invoke when:
- Planning a new feature that needs data modeling
- User mentions "entity", "repository", "use case", or "domain"
- Creating CRUD operations for a new data type
- Designing business logic for a feature

## VitalArc Domain Architecture

Domain code lives inside the owning module under `VitalArc/Modules/<Domain>/Domain/`:

```
VitalArc/Modules/<Domain>/Domain/
├── Entities/        # Pure Swift structs, no framework dependencies
├── Repositories/    # Protocol definitions (interfaces)
└── UseCases/        # Single-responsibility business operations
```

`<Domain>` is one of the surviving modules: **Workout**, **Wellness**, or **Shared** (which owns User, Analytics, Notifications, etc.).

### Key Patterns

**Entities** (pure value types):
```swift
struct Workout: Identifiable, Codable {
    let id: UUID
    var name: String
    var date: Date
    // ... properties
}
```

**Repositories** (protocol-only):
```swift
protocol WorkoutRepository {
    func save(_ workout: Workout) async throws
    func fetch(id: UUID) async throws -> Workout?
    func fetchAll() async throws -> [Workout]
    func delete(_ workout: Workout) async throws
}
```

**Use Cases** (single operation):
```swift
final class CreateWorkoutUseCase {
    private let repository: WorkoutRepository

    init(repository: WorkoutRepository) {
        self.repository = repository
    }

    func execute(name: String, date: Date) async throws -> Workout {
        let workout = Workout(id: UUID(), name: name, date: date)
        try await repository.save(workout)
        return workout
    }
}
```

## Analysis Process

### 1. Pick the Owning Module

Domain code is module-scoped, so decide which module owns the feature before designing anything:

- **Workout** — exercises, sets, mesocycles, templates
- **Wellness** — HealthKit, health metrics, sleep, recovery
- **Shared** — cross-domain concerns (User, Analytics, Notifications, etc.)

All paths below use `VitalArc/Modules/<Domain>/Domain/...` where `<Domain>` is the module you picked.

### 2. Understand the Feature

Questions to answer:
- What data does this feature manage?
- What operations are needed (CRUD, calculations, queries)?
- What existing entities does it relate to?
- Does it need HealthKit integration?

### 3. Analyze Existing Patterns

```bash
# Find similar entities (replace <Domain> with the module you picked)
ls VitalArc/Modules/<Domain>/Domain/Entities/

# Find similar repositories
ls VitalArc/Modules/<Domain>/Domain/Repositories/

# Find similar use cases
ls VitalArc/Modules/<Domain>/Domain/UseCases/
```

Study existing implementations for consistency.

### 4. Design Entities

For each new data type:

```swift
// VitalArc/Modules/<Domain>/Domain/Entities/[Name].swift

import Foundation

/// [Brief description of what this represents]
struct [Name]: Identifiable, Codable, Hashable {
    let id: UUID
    // Required properties (let)
    // Mutable properties (var)

    init(id: UUID = UUID(), ...) {
        self.id = id
        // ...
    }
}
```

**Guidelines:**
- Use `UUID` for identifiers
- Make immutable what shouldn't change after creation
- Include `Codable` for persistence
- Include `Hashable` for SwiftUI lists
- No UIKit/SwiftUI imports
- No business logic (that goes in Use Cases)

### 5. Design Repository Protocol

```swift
// VitalArc/Modules/<Domain>/Domain/Repositories/[Name]Repository.swift

import Foundation

protocol [Name]Repository {
    // Basic CRUD
    func save(_ item: [Name]) async throws
    func fetch(id: UUID) async throws -> [Name]?
    func fetchAll() async throws -> [[Name]]
    func delete(_ item: [Name]) async throws

    // Feature-specific queries
    func fetchRecent(limit: Int) async throws -> [[Name]]
    // ...
}
```

**Guidelines:**
- All methods are `async throws`
- Return optionals for single-item fetches
- Return arrays for multi-item fetches
- Add feature-specific query methods as needed

### 6. Design Use Cases

One use case per operation:

```swift
// VitalArc/Modules/<Domain>/Domain/UseCases/[Verb][Name]UseCase.swift

import Foundation

final class [Verb][Name]UseCase {
    private let repository: [Name]Repository
    // Other dependencies

    init(repository: [Name]Repository) {
        self.repository = repository
    }

    func execute(...) async throws -> [ReturnType] {
        // Business logic here
    }
}
```

**Common Use Case patterns:**
- `Create[Name]UseCase` - Create and save new entity
- `Update[Name]UseCase` - Modify existing entity
- `Delete[Name]UseCase` - Remove entity
- `Fetch[Name]UseCase` - Retrieve with business rules
- `Calculate[Name]UseCase` - Compute derived values

### 7. Consider Data Layer Needs

Note what SwiftData models will be needed:
- `VitalArc/Modules/<Domain>/Data/Models/[Name]Model.swift` - `@Model` class
- Needs `fromDomain()` and `toDomain()` converters
- Repository implementation lives in the owning sub-container (`WorkoutContainer` / `WellnessContainer` / `SharedContainer` in `VitalArc/Modules/Shared/DependencyContainer/`); then add a backward-compatible computed accessor on `DependencyContainer`

## Output Format

```markdown
## Domain Design: [Feature Name]

### Entities

#### [EntityName]
**File**: `VitalArc/Modules/<Domain>/Domain/Entities/[EntityName].swift`
**Purpose**: [What it represents]

Properties:
- `id: UUID` - Unique identifier
- `name: String` - [Description]
- ...

Relationships:
- References `[OtherEntity]` via `otherId: UUID`

### Repository

#### [Name]Repository
**File**: `VitalArc/Modules/<Domain>/Domain/Repositories/[Name]Repository.swift`

Methods:
- `save(_:)` - Persist entity
- `fetch(id:)` - Get by ID
- `fetchAll()` - Get all
- `delete(_:)` - Remove
- `[customMethod]` - [Purpose]

### Use Cases

#### Create[Name]UseCase
**File**: `VitalArc/Modules/<Domain>/Domain/UseCases/Create[Name]UseCase.swift`
**Purpose**: [What it does]
**Dependencies**: [Name]Repository
**Returns**: [Name]

#### [Other Use Cases...]

### Data Layer Notes

SwiftData model needed: `[Name]Model`
- Converters: `fromDomain()`, `toDomain()`
- Wire into the owning sub-container (WorkoutContainer / WellnessContainer / SharedContainer), then add a computed accessor on DependencyContainer
```

## Example: Notification Feature

```markdown
## Domain Design: Notifications

### Entities

#### ScheduledNotification
**File**: `VitalArc/Modules/Shared/Domain/Entities/ScheduledNotification.swift`

Properties:
- `id: UUID`
- `type: NotificationType` (enum: workoutReminder, recoveryAlert, sleepReminder)
- `scheduledTime: Date`
- `title: String`
- `body: String`
- `isEnabled: Bool`
- `repeatInterval: RepeatInterval?` (enum: daily, weekly, custom)

### Repository

#### NotificationRepository
Methods:
- `save(_:)`, `fetch(id:)`, `fetchAll()`, `delete(_:)`
- `fetchEnabled() -> [ScheduledNotification]`
- `fetchByType(_ type:) -> [ScheduledNotification]`

### Use Cases

#### ScheduleNotificationUseCase
- Creates notification and schedules with UNUserNotificationCenter
- Saves to repository for persistence

#### CancelNotificationUseCase
- Removes from UNUserNotificationCenter
- Deletes from repository

#### SyncNotificationsUseCase
- Called on app launch
- Reconciles repository with system notifications
```
