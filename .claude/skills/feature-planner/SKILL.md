---
name: feature-planner
description: Orchestrator for planning new feature architecture. Coordinates domain-modeler, swiftui-architect, dependency-wirer, and test-scaffolder in sequence.
disable-model-invocation: true
allowed-tools: Task, Read, Glob, Grep
argument-hint: <feature-name> [--skip-tests] [--domain-only] [--ui-only]
---

# Feature Planner

Orchestrator that coordinates architecture design for new features. Follows VitalArc's Clean Architecture patterns.

## When to Use

- Adding a new feature (e.g., "notifications", "achievements", "social sharing")
- Major enhancement to existing feature
- User asks to "plan", "design", or "architect" something new

## Orchestration Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                      FEATURE PLANNING PIPELINE                       │
├─────────────────────────────────────────────────────────────────────┤
│  PHASE 1 - Analysis:                                                │
│    └── Analyze existing codebase patterns                           │
│                                                                      │
│  PHASE 2 - Domain Design (Sequential):                              │
│    └── domain-modeler                                               │
│        ├── Design entities                                          │
│        ├── Design repository protocols                              │
│        └── Design use cases                                         │
│                                                                      │
│  PHASE 3 - UI Design (Sequential, after domain):                    │
│    └── swiftui-architect                                            │
│        ├── Design view hierarchy                                    │
│        ├── Design ViewModels                                        │
│        └── Design navigation flow                                   │
│                                                                      │
│  PHASE 4 - Integration (Sequential, after UI):                      │
│    └── dependency-wirer                                             │
│        ├── Update DependencyContainer                               │
│        └── Wire repositories and use cases                          │
│                                                                      │
│  PHASE 5 - Test Planning (Sequential, after integration):           │
│    └── test-scaffolder                                              │
│        ├── Generate domain tests                                    │
│        ├── Generate ViewModel tests                                 │
│        └── Generate UI tests                                        │
└─────────────────────────────────────────────────────────────────────┘
```

## Options

| Option | Description |
|--------|-------------|
| `--skip-tests` | Skip test scaffolding phase |
| `--domain-only` | Only design domain layer (no UI) |
| `--ui-only` | Only design UI (assumes domain exists) |

## Implementation

### Phase 1: Codebase Analysis

Before designing, analyze existing patterns:

```markdown
**Read these files to understand patterns:**
- VitalArc/Domain/Entities/ - Entity patterns
- VitalArc/Domain/Repositories/ - Repository protocol patterns
- VitalArc/Domain/UseCases/ - Use case patterns
- VitalArc/Presentation/Tabs/ - View organization
- VitalArc/Infrastructure/DependencyContainer.swift - DI setup
```

### Phase 2: Domain Design

```markdown
**Task: domain-modeler**
Prompt: "Design domain layer for [FEATURE]. Include:
1. Entity definitions with properties and relationships
2. Repository protocol with required methods
3. Use case classes with execute() methods

Follow patterns from existing VitalArc domain layer.
Feature context: [FEATURE_DESCRIPTION]"
```

### Phase 3: UI Design

```markdown
**Task: swiftui-architect**
Prompt: "Design UI layer for [FEATURE]. Include:
1. View hierarchy (main view, subviews, components)
2. ViewModel with @Observable pattern
3. Navigation flow and state management

Use VitalArc design system (VitalCard, VitalButton, etc.)
Domain entities: [OUTPUT_FROM_DOMAIN_MODELER]"
```

### Phase 4: Integration

```markdown
**Task: dependency-wirer**
Prompt: "Wire [FEATURE] into VitalArc. Update:
1. DependencyContainer with repository and use case
2. Add @Model for SwiftData persistence
3. Environment injection in views

Domain design: [OUTPUT_FROM_DOMAIN_MODELER]
UI design: [OUTPUT_FROM_SWIFTUI_ARCHITECT]"
```

### Phase 5: Test Planning

```markdown
**Task: test-scaffolder**
Prompt: "Generate test scaffolds for [FEATURE]. Include:
1. Domain tests (entity validation, use case logic)
2. ViewModel tests (state management, async operations)
3. UI test stubs (navigation, user interactions)

Feature design: [COMBINED_OUTPUT]"
```

## Output Format

### Feature Plan Document

```markdown
## Feature Plan: [FEATURE_NAME]

### Overview
[Brief description of what this feature does]

### Domain Layer

#### Entities
```swift
struct Achievement: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let unlockedAt: Date?
    let category: AchievementCategory
}

enum AchievementCategory: String, CaseIterable, Codable {
    case workout, nutrition, consistency, milestone
}
```

#### Repository Protocol
```swift
protocol AchievementRepository {
    func getAll() async throws -> [Achievement]
    func getUnlocked() async throws -> [Achievement]
    func unlock(_ achievement: Achievement) async throws
}
```

#### Use Cases
```swift
class GetAchievementsUseCase {
    func execute() async throws -> [Achievement]
}

class UnlockAchievementUseCase {
    func execute(achievementId: UUID) async throws -> Achievement
}
```

### Presentation Layer

#### Views
```
AchievementsView (main)
├── AchievementGridView
│   └── AchievementCard
├── AchievementDetailSheet
└── AchievementCategoryPicker
```

#### ViewModel
```swift
@Observable
class AchievementsViewModel {
    var achievements: [Achievement] = []
    var selectedCategory: AchievementCategory?
    var isLoading = false

    func loadAchievements() async
    func filterByCategory(_ category: AchievementCategory?)
}
```

### Integration

#### DependencyContainer Updates
```swift
// Add to DependencyContainer
let achievementRepository: AchievementRepository
let getAchievementsUseCase: GetAchievementsUseCase
let unlockAchievementUseCase: UnlockAchievementUseCase
```

### Test Plan

#### Domain Tests
- [ ] Achievement entity initialization
- [ ] AchievementCategory enum coverage
- [ ] GetAchievementsUseCase returns correct data
- [ ] UnlockAchievementUseCase updates state

#### ViewModel Tests
- [ ] loadAchievements sets isLoading correctly
- [ ] filterByCategory filters correctly
- [ ] Error handling shows appropriate state

### Implementation Checklist

- [ ] Create domain entities
- [ ] Create repository protocol
- [ ] Create SwiftData @Model
- [ ] Implement repository
- [ ] Create use cases
- [ ] Create ViewModel
- [ ] Create views
- [ ] Update DependencyContainer
- [ ] Add navigation entry
- [ ] Write tests
```

## Error Handling

### Missing Feature Description

```markdown
## ⚠️ Insufficient Context

Please provide more details about the feature:
- What problem does it solve?
- What are the main user interactions?
- Does it integrate with existing features?

Example: `/feature-planner notifications --description "Push notifications for workout reminders and recovery alerts"`
```

### Conflicting Patterns

```markdown
## ⚠️ Pattern Conflict Detected

The proposed design conflicts with existing patterns:

**Existing**: Repositories return domain entities directly
**Proposed**: Repository returns DTOs

**Recommendation**: Follow existing pattern for consistency.
Adjusted design uses domain entities.
```
