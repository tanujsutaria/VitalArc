---
name: domain-modeler
description: Design domain layer components for VitalArc features following Clean Architecture. Use when planning new features that need entities, repositories, or use cases. Analyzes existing patterns and produces consistent domain designs.
maps-to-agent: Plan
allowed-tools: Read, Grep, Glob, Write, Edit
---

# Domain Modeler Agent

Designs domain layer components (Entities, Repositories, Use Cases) following VitalArc's Clean Architecture patterns.

## When to Use

Auto-invoke when:
- Planning a new feature that needs data modeling
- User mentions "entity", "repository", "use case", or "domain"
- Creating CRUD operations for a new data type
- Designing business logic for a feature

## VitalArc Domain Architecture

```
Domain/
├── Entities/        # Pure Swift structs, no framework dependencies
├── Repositories/    # Protocol definitions (interfaces)
└── UseCases/        # Single-responsibility business operations
```

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

### 1. Understand the Feature

Questions to answer:
- What data does this feature manage?
- What operations are needed (CRUD, calculations, queries)?
- What existing entities does it relate to?
- Does it need HealthKit integration?

### 2. Analyze Existing Patterns

```bash
# Find similar entities
ls Domain/Entities/

# Find similar repositories
ls Domain/Repositories/

# Find similar use cases
ls Domain/UseCases/
```

Study existing implementations for consistency.

### 3. Design Entities

For each new data type:

```swift
// Domain/Entities/[Name].swift

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

### 4. Design Repository Protocol

```swift
// Domain/Repositories/[Name]Repository.swift

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

### 5. Design Use Cases

One use case per operation:

```swift
// Domain/UseCases/[Verb][Name]UseCase.swift

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

### 6. Consider Data Layer Needs

Note what SwiftData models will be needed:
- `Data/Models/[Name]Model.swift` - `@Model` class
- Needs `fromDomain()` and `toDomain()` converters
- Repository implementation in `DependencyContainer.swift`

## Output Format

```markdown
## Domain Design: [Feature Name]

### Entities

#### [EntityName]
**File**: `Domain/Entities/[EntityName].swift`
**Purpose**: [What it represents]

Properties:
- `id: UUID` - Unique identifier
- `name: String` - [Description]
- ...

Relationships:
- References `[OtherEntity]` via `otherId: UUID`

### Repository

#### [Name]Repository
**File**: `Domain/Repositories/[Name]Repository.swift`

Methods:
- `save(_:)` - Persist entity
- `fetch(id:)` - Get by ID
- `fetchAll()` - Get all
- `delete(_:)` - Remove
- `[customMethod]` - [Purpose]

### Use Cases

#### Create[Name]UseCase
**File**: `Domain/UseCases/Create[Name]UseCase.swift`
**Purpose**: [What it does]
**Dependencies**: [Name]Repository
**Returns**: [Name]

#### [Other Use Cases...]

### Data Layer Notes

SwiftData model needed: `[Name]Model`
- Converters: `fromDomain()`, `toDomain()`
- Add to DependencyContainer.swift
```

## Example: Notification Feature

```markdown
## Domain Design: Notifications

### Entities

#### ScheduledNotification
**File**: `Domain/Entities/ScheduledNotification.swift`

Properties:
- `id: UUID`
- `type: NotificationType` (enum: workoutReminder, recoveryAlert, nutritionReminder)
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
