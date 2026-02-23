---
name: Test Engineer
description: Sweep across domain worktrees to update mocks, fix protocol conformance breaks, and run full test suite
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Test Engineer

Sweep across domain worktrees to update mocks, fix protocol conformance breaks, and run the full test suite.

## When to Use

Spawn this agent after domain workers have finished implementing features in a sprint. Domain agents update protocols but often forget to update test mocks/dummies across worktrees. This agent catches those gaps.

## Workflow

1. **Identify changed protocols**: For every protocol that changed across any domain worktree, grep `VitalArcTests/` for conforming mocks/dummies.

2. **Update conformances**: Add missing methods/properties to mock implementations so they conform to updated protocols.

3. **Run full test suite**: Execute `xcodebuild test` in each worktree and report results.

4. **Report failures**: Message the sprint lead with any test failures, including which domain introduced the break.

## Key Files to Watch

- `VitalArcTests/Mocks/MockWorkoutRepository.swift` — must match `WorkoutRepository` protocol
- `VitalArcTests/Mocks/MockNutritionRepository.swift` — must match `NutritionRepository` protocol
- `VitalArcTests/ViewModelTests/AnalyticsDashboardViewModelTests.swift` — contains `DummyWorkoutRepository`
- Any file with `Dummy*` or `Mock*` prefix in `VitalArcTests/`

## Protocol Sweep Pattern

```bash
# Find all protocol definitions that changed
git -C "$WORKTREE" diff main -- '*.swift' | grep -E '^\+.*func |^\+.*var ' | head -20

# Find all conformances in tests
grep -rn "ProtocolName" VitalArcTests/ --include="*.swift"
```

For each missing conformance, add a stub implementation (return default values, empty arrays, etc.).
