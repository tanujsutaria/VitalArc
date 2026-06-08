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
set -o pipefail

# Optional pretty output. xcpretty is NOT installed in this environment, so
# never pipe to it (the pipe would make $? report xcpretty's 127, not the build).
# Use xcbeautify if present, otherwise pass output through unchanged.
if command -v xcbeautify >/dev/null 2>&1; then
    FORMATTER="xcbeautify"
else
    FORMATTER="cat"
fi

# Run all tests. PIPESTATUS preserves xcodebuild's exit code through the pipe.
xcodebuild test \
    -scheme VitalArc \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -resultBundlePath /tmp/test-results.xcresult \
    -quiet \
    2>&1 | $FORMATTER
STATUS=${PIPESTATUS[0]}

# Pass/fail is xcodebuild's exit code (NOT the formatter's). The .xcresult
# bundle at /tmp/test-results.xcresult has the authoritative per-test outcome.
if [ "$STATUS" -eq 0 ]; then
    echo "ALL TESTS PASSED"
else
    echo "TESTS FAILED"
    exit 1
fi
```

### Quick Mode (`--quick`)

Runs only fast unit tests, skipping UI and integration tests:

```bash
set -o pipefail

# Run only unit tests (exclude UI tests). -quiet keeps output terse without
# relying on an external formatter; no pipe means $? is xcodebuild's exit code.
xcodebuild test \
    -scheme VitalArc \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -only-testing:VitalArcTests \
    -quiet
STATUS=$?

if [ "$STATUS" -eq 0 ]; then
    echo "ALL TESTS PASSED"
else
    echo "TESTS FAILED"
    exit 1
fi
```

### Coverage Mode (`--coverage`)

Generates code coverage report:

```bash
set -o pipefail

# Optional pretty output (xcbeautify if installed; never xcpretty).
if command -v xcbeautify >/dev/null 2>&1; then
    FORMATTER="xcbeautify"
else
    FORMATTER="cat"
fi

# Run with coverage enabled. PIPESTATUS preserves xcodebuild's exit code.
xcodebuild test \
    -scheme VitalArc \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -enableCodeCoverage YES \
    -resultBundlePath /tmp/coverage-results.xcresult \
    -quiet \
    2>&1 | $FORMATTER
STATUS=${PIPESTATUS[0]}

if [ "$STATUS" -ne 0 ]; then
    echo "TESTS FAILED"
    exit 1
fi

# Extract coverage report from the result bundle
xcrun xccov view --report /tmp/coverage-results.xcresult
```

### Affected Mode (`--affected`)

Only tests related to changed files:

```bash
set -o pipefail

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

# Run only affected tests. -quiet avoids needing an external formatter; with no
# pipe, $? is xcodebuild's own exit code.
xcodebuild test \
    -scheme VitalArc \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    $TESTS_TO_RUN \
    -quiet
STATUS=$?

if [ "$STATUS" -eq 0 ]; then
    echo "ALL TESTS PASSED"
else
    echo "TESTS FAILED"
    exit 1
fi
```

### Filter Mode (`--filter=pattern`)

Run tests matching a pattern:

```bash
set -o pipefail

PATTERN="$1"

# Run the unit-test bundle and write results to a bundle we can filter after.
# -quiet keeps output terse; with no pipe, $? is xcodebuild's exit code.
xcodebuild test \
    -scheme VitalArc \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -only-testing:VitalArcTests \
    -resultBundlePath /tmp/filter-results.xcresult \
    -quiet
STATUS=$?

if [ "$STATUS" -eq 0 ]; then
    echo "ALL TESTS PASSED (filter: $PATTERN)"
else
    echo "TESTS FAILED (filter: $PATTERN)"
    # Inspect matching cases in the result bundle:
    #   xcrun xcresulttool get test-results tests --path /tmp/filter-results.xcresult
    exit 1
fi
```

## Output Format

### Success Report

```markdown
## Test Results

**Status**: PASSED
**Mode**: Full test run
**Duration**: 45 seconds

### Summary
| Category | Passed | Failed |
|----------|--------|--------|
| Unit Tests | all | 0 |
| ViewModel Tests | all | 0 |
| Integration Tests | all | 0 |

> Read counts from the .xcresult bundle - do not hardcode totals (the suite
> changes over time, so any fixed total goes stale).

### Test Suites
- HealthKitTests: passed
- SleepTests: passed
- ProfileTests: passed
- TemplateTests: passed
- BMITests: passed
- WorkoutTests: passed

All tests passed. Ready for commit.
```

### Failure Report

```markdown
## Test Results

**Status**: FAILED
**Mode**: Full test run
**Duration**: 52 seconds

### Summary
| Category | Passed | Failed |
|----------|--------|--------|
| Unit Tests | most | 2 |
| ViewModel Tests | all | 0 |
| Integration Tests | all | 0 |

> Read counts from the .xcresult bundle - do not hardcode totals.

### Failed Tests

#### WorkoutTests.swift

**testVolumeCalculation_withZeroSets_returnsZero**
```
XCTAssertEqual failed: ("100.0") is not equal to ("0.0")
Location: WorkoutTests.swift:45
```

**testWorkoutTotals_withEmptyWorkout_returnsDefaults**
```
XCTAssertNil failed: "Optional(Workout)" - Expected nil
Location: WorkoutTests.swift:78
```

### Suggested Fixes

1. **testVolumeCalculation**: Check set handling in `calculateVolume()`
2. **testWorkoutTotals**: Verify empty state initialization in `Workout.swift`

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
| LogWorkoutUseCase.swift | 89 | 78 | 88% |
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

1. WorkoutTests.testVolumeCalculation
2. WorkoutTests.testWorkoutTotals

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
