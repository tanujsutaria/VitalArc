---
name: feature-planner
description: Orchestrator for planning new feature architecture. Coordinates domain-modeler, swiftui-architect, dependency-wirer, and test-scaffolder using task dependency graphs.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Task, TaskCreate, TaskUpdate, TaskList
argument-hint: <feature-name> [--skip-tests] [--domain-only] [--ui-only]
---

# Feature Planner

Orchestrator that coordinates architecture design for new features using **task dependency graphs** for automatic sequencing.

## When to Use

- Adding a new feature (e.g., "notifications", "achievements", "social sharing")
- Major enhancement to existing feature
- User asks to "plan", "design", or "architect" something new

## Task Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────┐
│                    FEATURE PLANNING PIPELINE                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────┐                     │
│  │  Phase 1: Analysis (PARALLELIZED)          │                     │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐   │                     │
│  │  │ Domain   │ │ Present. │ │   DI     │   │ ← All run parallel  │
│  │  │ Analysis │ │ Analysis │ │ Analysis │   │                     │
│  │  └────┬─────┘ └────┬─────┘ └────┬─────┘   │                     │
│  └───────┼────────────┼────────────┼─────────┘                     │
│          └────────────┼────────────┘                                │
│                       ▼                                             │
│  ┌──────────────┐                                                   │
│  │    Domain    │  ← Phase 2: Design entities, repos, use cases     │
│  └──────┬───────┘    (blockedBy: all 3 analysis tasks)              │
│         │                                                           │
│         ▼                                                           │
│  ┌──────────────┐                                                   │
│  │      UI      │  ← Phase 3: Design views, ViewModels              │
│  └──────┬───────┘    (blockedBy: domain)                            │
│         │                                                           │
│         ▼                                                           │
│  ┌──────────────┐                                                   │
│  │   Wiring     │  ← Phase 4: Update DependencyContainer            │
│  └──────┬───────┘    (blockedBy: domain + ui)                       │
│         │                                                           │
│         ▼                                                           │
│  ┌──────────────┐                                                   │
│  │    Tests     │  ← Phase 5: Generate test scaffolds               │
│  └──────────────┘    (blockedBy: wiring)                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Optimization**: Phase 1 now runs 3 analysis tasks in parallel, reducing analysis time.

## Options

| Option | Description | Effect on Graph |
|--------|-------------|-----------------|
| `--skip-tests` | Skip test scaffolding phase | Removes Phase 5 from graph |
| `--domain-only` | Only design domain layer | Only Phases 1-2 |
| `--ui-only` | Only design UI (assumes domain exists) | Only Phases 1, 3 |

## Implementation

### Step 1: Create Complete Task Graph

Create ALL tasks upfront with proper dependencies. This allows the system to automatically sequence and parallelize where possible.

```javascript
// FEATURE: $ARGUMENTS

// ═══════════════════════════════════════════════════════════════
// PHASE 1: Analysis (PARALLELIZED - all 3 run simultaneously)
// ═══════════════════════════════════════════════════════════════

// Launch ALL THREE analysis tasks in a SINGLE message for parallel execution:

TaskCreate({
  subject: "Analyze domain patterns for $ARGUMENTS",
  description: `Analyze VitalArc domain layer patterns:
  1. Read VitalArc/Modules/<Domain>/Domain/Entities/ - entity structure, protocols (Identifiable, Codable)
  2. Read VitalArc/Modules/<Domain>/Domain/Repositories/ - repository protocol patterns
  3. Read VitalArc/Modules/<Domain>/Domain/UseCases/ - use case structure, execute() methods

  (<Domain> = owning module: Workout, Wellness, or Shared)

  Output: Domain pattern summary for $ARGUMENTS feature`,
  activeForm: "Analyzing domain patterns"
})
// Returns: task-domain-analysis-id

TaskCreate({
  subject: "Analyze presentation patterns for $ARGUMENTS",
  description: `Analyze VitalArc presentation layer patterns:
  1. Read VitalArc/Modules/<Domain>/Presentation/ - view organization, view structure
  2. Read VitalArc/Modules/Shared/DesignSystem/ - available components
  3. Identify ViewModel patterns (@Observable, state management)

  (<Domain> = owning module: Workout, Wellness, or Shared)

  Output: Presentation pattern summary for $ARGUMENTS feature`,
  activeForm: "Analyzing presentation patterns"
})
// Returns: task-presentation-analysis-id

TaskCreate({
  subject: "Analyze DI patterns for $ARGUMENTS",
  description: `Analyze VitalArc dependency injection patterns:
  1. Read VitalArc/Modules/Shared/DependencyContainer/DependencyContainer.swift - orchestrator DI (delegates to WorkoutContainer / WellnessContainer / SharedContainer sub-containers in that same folder)
  2. Read VitalArc/Modules/<Domain>/Data/ - SwiftData model patterns
  3. Understand repository-to-sub-container wiring (new repos/use cases go in the owning sub-container, then a backward-compatible computed accessor is added)

  (<Domain> = owning module: Workout, Wellness, or Shared)

  Output: DI pattern summary for $ARGUMENTS feature`,
  activeForm: "Analyzing DI patterns"
})
// Returns: task-di-analysis-id

// ═══════════════════════════════════════════════════════════════
// PHASE 2: Domain Design (blocked by ALL analysis tasks)
// ═══════════════════════════════════════════════════════════════

TaskCreate({
  subject: "Design domain layer for $ARGUMENTS",
  description: `Design domain layer for $ARGUMENTS feature:

  Following patterns from all three analysis tasks, design:
  1. **Entities**: Define structs with Identifiable, Codable, Hashable
  2. **Repository Protocol**: Define async throwing methods
  3. **Use Cases**: Single-responsibility classes with execute()

  Output format:
  - Entity definitions with properties
  - Repository protocol with methods
  - Use case classes with signatures`,
  activeForm: "Designing domain layer",
  addBlockedBy: ["task-domain-analysis-id", "task-presentation-analysis-id", "task-di-analysis-id"]
})
// Returns: task-domain-id

// ═══════════════════════════════════════════════════════════════
// PHASE 3: UI Design (blocked by domain)
// ═══════════════════════════════════════════════════════════════

TaskCreate({
  subject: "Design UI layer for $ARGUMENTS",
  description: `Design UI layer for $ARGUMENTS feature:

  Using domain entities from previous phase, design:
  1. **View Hierarchy**: Main view, subviews, components
  2. **ViewModel**: @Observable class with state and actions
  3. **Navigation**: Entry points, sheets, navigation flow

  Use VitalArc design system:
  - VitalCard, VitalButton, VitalEmptyState
  - Color.vitalPrimary, Color.vitalAdaptive*
  - Spacing.*, Typography.*

  Output format:
  - View hierarchy diagram
  - ViewModel class with properties and methods
  - Navigation flow`,
  activeForm: "Designing UI layer",
  addBlockedBy: ["task-domain-id"]
})
// Returns: task-ui-id

// ═══════════════════════════════════════════════════════════════
// PHASE 4: Dependency Wiring (blocked by domain AND ui)
// ═══════════════════════════════════════════════════════════════

TaskCreate({
  subject: "Plan dependency wiring for $ARGUMENTS",
  description: `Plan DependencyContainer updates for $ARGUMENTS:

  Based on domain and UI designs:
  1. **Repository Implementation**: SwiftData repository class
  2. **DependencyContainer Updates**: Properties and init changes
  3. **SwiftData Model**: @Model class with converters

  Output format:
  - Repository implementation plan
  - DependencyContainer code additions
  - SwiftData model with fromDomain/toDomain`,
  activeForm: "Planning dependency wiring",
  addBlockedBy: ["task-domain-id", "task-ui-id"]
})
// Returns: task-wiring-id

// ═══════════════════════════════════════════════════════════════
// PHASE 5: Test Scaffolding (blocked by wiring)
// ═══════════════════════════════════════════════════════════════

TaskCreate({
  subject: "Generate test scaffolds for $ARGUMENTS",
  description: `Generate test scaffolds for $ARGUMENTS:

  Based on all previous phases:
  1. **Domain Tests**: Entity validation, use case logic
  2. **ViewModel Tests**: State management, async operations
  3. **Mock Classes**: Mock repositories for testing

  Output format:
  - Test file structure
  - Test case signatures
  - Mock class definitions`,
  activeForm: "Generating test scaffolds",
  addBlockedBy: ["task-wiring-id"]
})
// Returns: task-tests-id
```

### Step 2: Monitor Progress

Use TaskList to see graph status:

```javascript
TaskList()
// Shows all tasks with blockedBy relationships
// Completed tasks auto-unblock dependent tasks
```

### Step 3: Aggregate Results

After all tasks complete, compile the feature plan:

```javascript
TaskCreate({
  subject: "Compile feature plan document for $ARGUMENTS",
  description: `Compile all phase outputs into a single feature plan document:

  ## Feature Plan: $ARGUMENTS

  ### Overview
  [Brief description]

  ### Domain Layer
  [From Phase 2]

  ### Presentation Layer
  [From Phase 3]

  ### Integration
  [From Phase 4]

  ### Test Plan
  [From Phase 5]

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
  - [ ] Write tests`,
  activeForm: "Compiling feature plan",
  addBlockedBy: ["task-tests-id"]  // or task-wiring-id if --skip-tests
})
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
    case workout, wellness, consistency, milestone
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

### Task Failure

If any task in the graph fails:

```markdown
## ⚠️ Pipeline Interrupted

Task failed: [task subject]
Error: [error message]

Downstream tasks blocked:
- [list of blocked tasks]

Fix the error and re-run the failed task to continue.
```
