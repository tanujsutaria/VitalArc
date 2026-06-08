---
name: test-runner
description: Execute VitalArc tests with various options. Required quality gate at session end. Supports quick, coverage, and affected-only modes.
context: fork
agent: general-purpose
allowed-tools: Bash, Read, Grep, Glob, TaskCreate, TaskUpdate, TaskList
argument-hint: [--quick] [--coverage] [--affected] [--filter=pattern]
---

# Test Runner

Executes VitalArc tests as a required quality gate. **Workstation only** - requires Xcode build capability.

**Execution**: Runs in forked context with Bash agent.

**IMPORTANT**: When invoked without arguments, execute immediately in Full mode (run all tests). Never ask for clarification - use defaults and produce results.

## When to Use

- **Required**: At session end (blocking gate after build passes)
- Before committing significant changes
- After implementing new features
- When user asks to "run tests", "verify tests", or "check tests"

## Test Modes

| Mode | Flag | Description | Use Case |
|------|------|-------------|----------|
| Full | (default) | Run all tests | Complete validation |
| Quick | `--quick` | Run fast unit tests only | Rapid feedback |
| Coverage | `--coverage` | Generate coverage report | Before PR |
| Affected | `--affected` | Tests for changed files only | Incremental check |

## Implementation

### Full Test Run (Default)

```bash
# Run all tests
xcodebuild test \
    -scheme VitalArc \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -resultBundlePath /tmp/test-results.xcresult \
    2>&1 | xcpretty --color

# Check exit code
if [ $? -eq 0 ]; then
    echo "ALL TESTS PASSED"
else
    echo "TESTS FAILED"
    exit 1
fi
```

### Quick Mode (`--quick`)

Runs only fast unit tests, skipping UI and integration tests:

```bash
# Run only unit tests (exclude UI tests)
xcodebuild test \
    -scheme VitalArc \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -only-testing:VitalArcTests \
    2>&1 | grep -E "(Test Case|passed|failed|error:)"
```

### Coverage Mode (`--coverage`)

Generates code coverage report:

```bash
# Run with coverage enabled
xcodebuild test \
    -scheme VitalArc \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -enableCodeCoverage YES \
    -resultBundlePath /tmp/coverage-results.xcresult \
    2>&1 | xcpretty --color

# Extract coverage report
xcrun xccov view --report /tmp/coverage-results.xcresult
```

### Affected Mode (`--affected`)

Only tests related to changed files:

```bash
# Get changed files
CHANGED_FILES=$(git diff --name-only HEAD~1 -- '*.swift')

# Find related test files
for file in $CHANGED_FILES; do
    base=$(basename "$file" .swift)
    # Look for corresponding test file
    TEST_FILE=$(find VitalArcTests -name "${base}Tests.swift" 2>/dev/null)
    if [ -n "$TEST_FILE" ]; then
        TESTS_TO_RUN="$TESTS_TO_RUN -only-testing:VitalArcTests/${base}Tests"
    fi
done

# Run only affected tests
xcodebuild test \
    -scheme VitalArc \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    $TESTS_TO_RUN \
    2>&1 | xcpretty --color
```

### Filter Mode (`--filter=pattern`)

Run tests matching a pattern:

```bash
PATTERN="$1"

# Run tests matching pattern
xcodebuild test \
    -scheme VitalArc \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -only-testing:VitalArcTests \
    2>&1 | grep -E "(Test Case.*$PATTERN|passed|failed)"
```

## Output Format

### Success Report

```markdown
## Test Results

**Status**: PASSED
**Mode**: Full test run
**Duration**: 45 seconds

### Summary
| Category | Tests | Passed | Failed |
|----------|-------|--------|--------|
| Unit Tests | 42 | 42 | 0 |
| ViewModel Tests | 18 | 18 | 0 |
| Integration Tests | 8 | 8 | 0 |
| **Total** | **68** | **68** | **0** |

### Test Suites
- HealthKitTests: 12 tests, 12 passed
- NutritionTests: 15 tests, 15 passed
- ProfileTests: 10 tests, 10 passed
- TemplateTests: 8 tests, 8 passed
- BMITests: 5 tests, 5 passed
- WorkoutTests: 18 tests, 18 passed

All tests passed. Ready for commit.
```

### Failure Report

```markdown
## Test Results

**Status**: FAILED
**Mode**: Full test run
**Duration**: 52 seconds

### Summary
| Category | Tests | Passed | Failed |
|----------|-------|--------|--------|
| Unit Tests | 42 | 40 | 2 |
| ViewModel Tests | 18 | 18 | 0 |
| Integration Tests | 8 | 8 | 0 |
| **Total** | **68** | **66** | **2** |

### Failed Tests

#### NutritionTests.swift

**testCalorieCalculation_withZeroPortions_returnsZero**
```
XCTAssertEqual failed: ("100.0") is not equal to ("0.0")
Location: NutritionTests.swift:45
```

**testMealTotals_withEmptyMeal_returnsDefaults**
```
XCTAssertNil failed: "Optional(Meal)" - Expected nil
Location: NutritionTests.swift:78
```

### Suggested Fixes

1. **testCalorieCalculation**: Check portion handling in `calculateCalories()`
2. **testMealTotals**: Verify empty state initialization in `Meal.swift`

---

**BLOCKED**: Fix failing tests before session end.
```

### Coverage Report

```markdown
## Test Coverage Report

**Overall Coverage**: 68%

### Coverage by File

| File | Lines | Covered | % |
|------|-------|---------|---|
| ProfileViewModel.swift | 150 | 135 | 90% |
| NutritionUseCase.swift | 89 | 78 | 88% |
| WorkoutManager.swift | 210 | 168 | 80% |
| HealthKitManager.swift | 180 | 108 | 60% |
| NotificationService.swift | 120 | 48 | 40% |

### Uncovered Areas

**HealthKitManager.swift** (60% coverage)
- Lines 45-67: Error handling paths
- Lines 120-145: Background refresh logic

**NotificationService.swift** (40% coverage)
- Lines 30-55: Notification scheduling
- Lines 78-95: Permission request handling

### Recommendations
1. Add tests for HealthKit error scenarios
2. Add tests for notification scheduling
3. Consider mock framework for better isolation
```

## Integration with Session End

### As Required Gate

In `vitalarc-end-workstation`, test execution is **required after build passes**:

```
PHASE 1: Build validation (BLOCKING)
PHASE 2: Test execution (BLOCKING - after build)
PHASE 3: Parallel quality checks (after tests)
PHASE 4: Commit generation
```

```javascript
// In vitalarc-end-workstation Phase 2:
TaskCreate({
  subject: "Run test suite",
  description: `Execute tests as required quality gate:
    1. Run: /test-runner (full mode)
    2. If FAILED: Block session end, report failures
    3. If PASSED: Proceed to quality checks`,
  activeForm: "Running tests",
  addBlockedBy: ["task-build-id"]  // After build passes
})
// Returns: task-test-id

// Phase 3 tasks blocked by test-id
TaskCreate({
  subject: "Design system scan",
  ...
  addBlockedBy: ["task-test-id"]  // After tests pass
})
```

### Test Failure Handling

If tests fail, session end is blocked:

```
═══════════════════════════════════════════════════════════════
       SESSION END BLOCKED - TESTS FAILED
═══════════════════════════════════════════════════════════════
Failed Tests: 2

1. NutritionTests.testCalorieCalculation
2. NutritionTests.testMealTotals

Fix failing tests, then re-run /vitalarc-end-workstation
═══════════════════════════════════════════════════════════════
```

## Error Handling

### Simulator Not Available

```markdown
## Test Run Failed

**Error**: iOS Simulator not available

The specified simulator "iPhone 17 Pro" is not available.

**Available simulators**:
```bash
xcrun simctl list devices available
```

Update test destination or create required simulator.
```

### Build Required

```markdown
## Test Run Failed

**Error**: Build required before testing

Tests cannot run without a successful build.

Run `/build-validator` first, then retry tests.
```

### Timeout

```markdown
## Test Run Warning

**Warning**: Tests taking longer than expected

Running for: 5 minutes (expected: ~2 minutes)

Consider:
- Running `--quick` mode for faster feedback
- Running `--affected` to test only changed code
- Checking for hanging tests or infinite loops
```

## Best Practices

1. **Run quick tests frequently** during development
2. **Run full tests before commits** to catch regressions
3. **Run coverage before PRs** to ensure adequate coverage
4. **Run affected tests for rapid iteration** during feature work
5. **Never skip tests** - they're a required gate for a reason
