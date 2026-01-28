# VitalArc - AI Agent Task Index

## Overview

This directory contains detailed task specifications for AI coding agents to implement VitalArc. Each task is self-contained with clear inputs, outputs, acceptance criteria, and implementation guidance.

---

## Task Organization

Tasks are organized by phase and feature area:

```
ai-agent-tasks/
├── TASK_INDEX.md                    # This file
├── phase-1-foundation/
│   ├── TASK-001-project-setup.md
│   ├── TASK-002-healthkit-manager.md
│   ├── TASK-003-swiftdata-models.md
│   ├── TASK-004-repository-layer.md
│   └── TASK-005-core-ui.md
├── phase-2-workout/
│   ├── TASK-006-exercise-library.md
│   ├── TASK-007-mesocycle-creation.md
│   ├── TASK-008-workout-logging.md
│   └── TASK-009-progression-algorithms.md
├── phase-3-nutrition/
│   ├── TASK-010-food-database.md
│   ├── TASK-011-food-logging.md
│   ├── TASK-012-adaptive-algorithm.md
│   └── TASK-013-weekly-checkin.md
├── phase-4-health/
│   ├── TASK-014-recovery-score.md
│   ├── TASK-015-strain-tracking.md
│   ├── TASK-016-sleep-analysis.md
│   └── TASK-017-training-load.md
├── phase-5-intelligence/
│   ├── TASK-018-correlation-engine.md
│   ├── TASK-019-recommendations.md
│   └── TASK-020-ai-features.md
└── phase-6-polish/
    ├── TASK-021-social-features.md
    ├── TASK-022-watch-app.md
    └── TASK-023-widgets.md
```

---

## Task Template

Each task follows this structure:

```markdown
# TASK-XXX: Task Title

## Metadata
- **Phase**: X
- **Priority**: P0/P1/P2
- **Estimated Hours**: X
- **Dependencies**: TASK-XXX, TASK-XXX
- **Blocked By**: None / TASK-XXX

## Objective
Clear, concise description of what this task accomplishes.

## Context
Background information and why this task matters.

## Requirements
### Functional Requirements
- [ ] Requirement 1
- [ ] Requirement 2

### Non-Functional Requirements
- Performance: X
- Accessibility: X

## Technical Specification
### Files to Create/Modify
- `Path/To/File.swift` - Description

### Data Models
```swift
// Relevant model definitions
```

### Architecture
Description of how this fits into the overall architecture.

## Implementation Guide
Step-by-step implementation instructions.

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Testing Requirements
- Unit tests for X
- Integration tests for Y

## References
- Link to relevant documentation
- Link to design specs
```

---

## Quick Reference: All Tasks

### Phase 1: Foundation

| Task ID | Title | Priority | Est. Hours | Dependencies |
|---------|-------|----------|------------|--------------|
| TASK-001 | Project Setup | P0 | 4 | None |
| TASK-002 | HealthKit Manager | P0 | 8 | TASK-001 |
| TASK-003 | SwiftData Models | P0 | 6 | TASK-001 |
| TASK-004 | Repository Layer | P0 | 6 | TASK-003 |
| TASK-005 | Core UI Framework | P0 | 8 | TASK-001 |

### Phase 2: Workout Engine

| Task ID | Title | Priority | Est. Hours | Dependencies |
|---------|-------|----------|------------|--------------|
| TASK-006 | Exercise Library | P0 | 6 | TASK-003, TASK-005 |
| TASK-007 | Mesocycle Creation | P0 | 10 | TASK-006 |
| TASK-008 | Workout Logging | P0 | 12 | TASK-006, TASK-002 |
| TASK-009 | Progression Algorithms | P0 | 8 | TASK-008 |

### Phase 3: Nutrition System

| Task ID | Title | Priority | Est. Hours | Dependencies |
|---------|-------|----------|------------|--------------|
| TASK-010 | Food Database Integration | P0 | 8 | TASK-004 |
| TASK-011 | Food Logging UI | P0 | 10 | TASK-010 |
| TASK-012 | Adaptive TDEE Algorithm | P0 | 8 | TASK-011 |
| TASK-013 | Weekly Check-in | P1 | 6 | TASK-012 |

### Phase 4: Health Analytics

| Task ID | Title | Priority | Est. Hours | Dependencies |
|---------|-------|----------|------------|--------------|
| TASK-014 | Recovery Score | P0 | 8 | TASK-002 |
| TASK-015 | Strain Tracking | P0 | 8 | TASK-002, TASK-008 |
| TASK-016 | Sleep Analysis | P1 | 6 | TASK-002 |
| TASK-017 | Training Load (ATL/CTL) | P1 | 6 | TASK-015 |

### Phase 5: Intelligence Layer

| Task ID | Title | Priority | Est. Hours | Dependencies |
|---------|-------|----------|------------|--------------|
| TASK-018 | Correlation Engine | P1 | 10 | TASK-014, TASK-012 |
| TASK-019 | Recommendation System | P1 | 10 | TASK-018 |
| TASK-020 | AI Features | P2 | 12 | TASK-019 |

### Phase 6: Social & Polish

| Task ID | Title | Priority | Est. Hours | Dependencies |
|---------|-------|----------|------------|--------------|
| TASK-021 | Social Features | P2 | 8 | TASK-005 |
| TASK-022 | watchOS App | P1 | 16 | TASK-008, TASK-014 |
| TASK-023 | Widgets | P2 | 8 | TASK-014, TASK-012 |

---

## Dependency Graph

```
TASK-001 (Project Setup)
    ├── TASK-002 (HealthKit)
    │   ├── TASK-014 (Recovery)
    │   ├── TASK-015 (Strain)
    │   ├── TASK-016 (Sleep)
    │   └── TASK-008 (Workout Logging)
    │       ├── TASK-009 (Progression)
    │       ├── TASK-015 (Strain)
    │       │   └── TASK-017 (Training Load)
    │       └── TASK-022 (Watch App)
    │
    ├── TASK-003 (SwiftData Models)
    │   ├── TASK-004 (Repository)
    │   │   └── TASK-010 (Food Database)
    │   │       └── TASK-011 (Food Logging)
    │   │           └── TASK-012 (Adaptive TDEE)
    │   │               └── TASK-013 (Check-in)
    │   └── TASK-006 (Exercise Library)
    │       └── TASK-007 (Mesocycle)
    │           └── TASK-008 (Workout Logging)
    │
    └── TASK-005 (Core UI)
        ├── TASK-006 (Exercise Library)
        ├── TASK-021 (Social)
        └── TASK-023 (Widgets)

TASK-014 + TASK-012 → TASK-018 (Correlations)
TASK-018 → TASK-019 (Recommendations)
TASK-019 → TASK-020 (AI Features)
```

---

## Agent Instructions

### Before Starting a Task

1. **Read the task file completely** before writing any code
2. **Check dependencies** - ensure prerequisite tasks are complete
3. **Review referenced documentation**:
   - `docs/architecture/ARCHITECTURE.md` for structure
   - `docs/architecture/DATA_MODELS.md` for models
   - `docs/specs/ALGORITHMS.md` for algorithm details
   - `docs/architecture/HEALTHKIT.md` for health integration

### During Implementation

1. **Follow the project structure** defined in ARCHITECTURE.md
2. **Use existing patterns** - check similar code in the project
3. **Write tests** as specified in the task
4. **Document public APIs** with Swift documentation comments
5. **Handle errors gracefully** - never crash on bad data

### After Completing a Task

1. **Verify all acceptance criteria** are met
2. **Run existing tests** to ensure no regressions
3. **Update any documentation** affected by changes
4. **Note any deviations** from the spec and why

### Code Quality Standards

- SwiftLint must pass with no errors
- Public methods must have documentation
- Complex logic must have inline comments
- Test coverage for new code >70%
- No force unwrapping except in tests
- Async/await for all async operations
- @Observable for ViewModels

---

## Getting Started

For a new agent starting on this project:

1. Start with **TASK-001: Project Setup**
2. Complete all Phase 1 tasks in order
3. Phase 2+ tasks can be parallelized based on dependencies
4. Always check the dependency graph before starting a task

---

## Task Status Tracking

| Task ID | Status | Assignee | Started | Completed |
|---------|--------|----------|---------|-----------|
| TASK-001 | Not Started | - | - | - |
| TASK-002 | Not Started | - | - | - |
| ... | ... | ... | ... | ... |

*Update this table as tasks are assigned and completed.*
