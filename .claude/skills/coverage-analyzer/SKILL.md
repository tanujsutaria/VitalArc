---
name: coverage-analyzer
description: Identify untested code and suggest test priorities. Analyzes source files vs test files to find coverage gaps.
context: fork
agent: Explore
allowed-tools: Read, Glob, Grep
---

# Coverage Analyzer

Analyzes test coverage by comparing source files with corresponding test files.

**Execution**: Runs in forked context with Explore agent for read-only analysis.

**IMPORTANT**: When invoked without arguments, execute immediately with default settings. Never ask for clarification - use defaults and produce results.

## Default Behavior (No Arguments)

When invoked without arguments:
- **Layer**: All layers (domain, presentation, infrastructure)
- **Output**: Summary report with priority queue (not verbose)
- **Scope**: Full heuristic coverage analysis

Execute the full coverage analysis immediately. Do not ask for clarification.

## Analysis Approach

Since we can't run actual code coverage tools via CLI, this agent uses heuristic analysis:

1. Find all source files
2. Find corresponding test files
3. Identify files without tests
4. Prioritize based on importance

## Priority Scoring

| Layer | Priority | Rationale |
|-------|----------|-----------|
| Domain/UseCases | Highest (10) | Core business logic |
| Domain/Entities | High (8) | Data validation |
| Presentation/ViewModels | High (8) | State management |
| Infrastructure/Repositories | Medium (6) | Data access |
| Presentation/Views | Low (3) | UI (better suited for UI tests) |
| Utilities | Low (2) | Helper functions |

## Implementation

### Find Source Files

```bash
# Domain layer
find VitalArc/Domain -name "*.swift" -not -name "*Tests*"

# Presentation layer
find VitalArc/Presentation -name "*ViewModel*.swift"
find VitalArc/Presentation -name "*View.swift"

# Infrastructure
find VitalArc/Infrastructure -name "*.swift"
```

### Find Test Files

```bash
find . -name "*Tests.swift" -o -name "*Test.swift"
```

### Match Source to Tests

For each source file, look for corresponding test:
- `ProfileViewModel.swift` → `ProfileViewModelTests.swift`
- `CreateWorkoutUseCase.swift` → `CreateWorkoutUseCaseTests.swift`

## Output Format

### Coverage Summary

```markdown
## Test Coverage Analysis

### Summary
| Layer | Files | Tested | Coverage |
|-------|-------|--------|----------|
| Domain/UseCases | 16 | 4 | 25% |
| Domain/Entities | 12 | 2 | 17% |
| ViewModels | 10 | 3 | 30% |
| Infrastructure | 8 | 1 | 12% |
| **Total** | **46** | **10** | **22%** |

### Priority Queue (Top 10 Files to Test)

| Priority | File | Layer | Why |
|----------|------|-------|-----|
| 10 | CreateWorkoutUseCase.swift | UseCases | Core workout logic |
| 10 | CalculateRecoveryScoreUseCase.swift | UseCases | Critical calculation |
| 10 | LogFoodUseCase.swift | UseCases | Nutrition tracking |
| 8 | Workout.swift | Entities | Complex validation |
| 8 | WorkoutViewModel.swift | ViewModels | State management |
| 8 | NutritionViewModel.swift | ViewModels | Async operations |
| 6 | SwiftDataWorkoutRepository.swift | Repositories | Data persistence |
| 6 | HealthKitManager.swift | Infrastructure | HealthKit integration |
| 3 | ProfileView.swift | Views | UI (preview exists) |
| 2 | DateFormatters.swift | Utilities | Simple helpers |

### Existing Tests

| Test File | Covers |
|-----------|--------|
| WorkoutTests.swift | Workout entity |
| RecoveryScoreTests.swift | Recovery calculation |
| FoodTests.swift | Food entity |
| UserProfileTests.swift | Profile entity |
| HealthDashboardViewModelTests.swift | Dashboard VM |
| ExerciseFilterTests.swift | Filter logic |
```

### Untested Critical Paths

```markdown
### Critical Untested Code

These code paths handle important logic and have no test coverage:

#### 1. TRIMP Calculation
**File**: `CalculateStrainScoreUseCase.swift`
**Risk**: Incorrect training load calculation
**Suggested Tests**:
- Test Banister method with known inputs
- Test Edwards method zone calculations
- Test edge cases (zero duration, max HR)

#### 2. Notification Scheduling
**File**: `NotificationSettingsViewModel.swift`
**Risk**: Notifications not delivered correctly
**Suggested Tests**:
- Test reminder scheduling
- Test notification cancellation
- Test permission handling

#### 3. Food API Coordination
**File**: `FoodAPICoordinator.swift`
**Risk**: Search results missing or duplicated
**Suggested Tests**:
- Test multi-source aggregation
- Test error handling per source
- Test caching behavior
```

## Layer-Specific Analysis

### --layer=domain

```markdown
## Domain Layer Coverage

### Use Cases (16 files, 4 tested)
| File | Status | Priority |
|------|--------|----------|
| CreateWorkoutUseCase.swift | Untested | High |
| GetWorkoutsUseCase.swift | Untested | Medium |
| CalculateRecoveryScoreUseCase.swift | Tested | - |
| LogFoodUseCase.swift | Untested | High |
...

### Entities (12 files, 2 tested)
| File | Status | Priority |
|------|--------|----------|
| Workout.swift | Tested | - |
| Food.swift | Tested | - |
| Exercise.swift | Untested | Medium |
| UserProfile.swift | Tested | - |
...
```

### --layer=presentation

```markdown
## Presentation Layer Coverage

### ViewModels (10 files, 3 tested)
| File | Status | Has Preview |
|------|--------|-------------|
| WorkoutViewModel.swift | Untested | Yes |
| ProfileViewModel.swift | Untested | Yes |
| HealthDashboardViewModel.swift | Tested | Yes |
| NutritionViewModel.swift | Untested | Yes |
...

### Views (70 files)
Views are primarily covered by SwiftUI Previews.
**Preview Coverage**: 68% (48/70 have #Preview)
```

## Recommendations

```markdown
## Testing Recommendations

### Quick Wins (Easy to test, high value)
1. **Entity tests** - Pure data, no dependencies
2. **Utility tests** - Isolated helper functions
3. **ViewModel state tests** - Predictable state changes

### High Impact (Complex but critical)
1. **Use case tests** - Core business logic
2. **Repository tests** - Data integrity
3. **Integration tests** - End-to-end flows

### Suggested Test Sprint
Week 1: All use cases (16 files)
Week 2: All ViewModels (10 files)
Week 3: Critical infrastructure (5 files)

**Estimated effort**: 31 test files
**Target coverage**: 70%+
```

## Error Handling

### No Test Directory

```markdown
## Test Directory Not Found

No test files found in expected locations:
- VitalArcTests/
- Tests/

Create test target or specify custom test path.
```
