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
│  ┌──────────────┐                                                   │
│  │   Analysis   │  ← Phase 1: Analyze existing patterns             │
│  └──────┬───────┘                                                   │
│         │                                                           │
│         ▼                                                           │
│  ┌──────────────┐                                                   │
│  │    Domain    │  ← Phase 2: Design entities, repos, use cases     │
│  └──────┬───────┘    (blockedBy: analysis)                          │
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
// PHASE 1: Analysis (no dependencies - runs immediately)
// ═══════════════════════════════════════════════════════════════

TaskCreate({
  subject: "Analyze codebase patterns for $ARGUMENTS",
  description: `Analyze existing VitalArc patterns for $ARGUMENTS feature:

  1. Read Domain/Entities/ - understand entity patterns
  2. Read Domain/Repositories/ - understand repository protocols
  3. Read Domain/UseCases/ - understand use case patterns
  4. Read Presentation/Tabs/ - understand view organization
  5. Read Infrastructure/DependencyContainer.swift - understand DI setup

  Output: Summary of relevant patterns to follow`,
  activeForm: "Analyzing codebase patterns"
})
// Returns: task-analysis-id

// ═══════════════════════════════════════════════════════════════
// PHASE 2: Domain Design (blocked by analysis)
// ═══════════════════════════════════════════════════════════════

TaskCreate({
  subject: "Design domain layer for $ARGUMENTS",
  description: `Design domain layer for $ARGUMENTS feature:

  Following patterns from analysis, design:
  1. **Entities**: Define structs with Identifiable, Codable, Hashable
  2. **Repository Protocol**: Define async throwing methods
  3. **Use Cases**: Single-responsibility classes with execute()

  Output format:
  - Entity definitions with properties
  - Repository protocol with methods
  - Use case classes with signatures`,
  activeForm: "Designing domain layer",
  addBlockedBy: ["task-analysis-id"]
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
