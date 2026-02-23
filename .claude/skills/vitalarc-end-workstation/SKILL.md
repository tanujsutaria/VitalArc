---
name: vitalarc-end-workstation
description: Finalize a VitalArc workstation development session. Use when ending a session on Mac. Verifies build passes, commits documentation, and pushes changes.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task, TaskCreate, TaskUpdate, TaskList
argument-hint: [summary]
---

# VitalArc Workstation Session End

Finalize a workstation session with build verification.

## Task Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SESSION END PIPELINE                              │
├─────────────────────────────────────────────────────────────────────┤
│  PHASE 1 - Build Validation (BLOCKING):                             │
│    └── Task: build-check (MUST PASS)                                │
│                                                                      │
│  PHASE 2 - Test Execution (BLOCKING - after build):                 │
│    └── Task: test-run (MUST PASS)                                   │
│                                                                      │
│  PHASE 3 - Parallel Quality Checks (after tests pass):              │
│    ├── Task: design-scan    (blockedBy: test-run)                   │
│    ├── Task: lint-check     (blockedBy: test-run)                   │
│    └── Task: progress-update (NO DEPENDENCIES - starts immediately) │
│                                                                      │
│  PHASE 3.5 - Documentation Update (after Phase 2 + 3):             │
│    └── Task: docs-update (blockedBy: test-run + design-scan)        │
│                                                                      │
│  PHASE 4 - Commit Preparation (After Phase 3 + 3.5):               │
│    └── Task: generate-commit (blockedBy: all above)                 │
│                                                                      │
│  PHASE 5 - Finalization (Sequential):                               │
│    └── Commit → Push → (Optional) Create PR                         │
└─────────────────────────────────────────────────────────────────────┘
```

**Note**: Test execution is now a **required blocking gate** after build passes.

## Implementation

### Phase 1: Build Validation (BLOCKING)

This must pass before proceeding. If build fails, stop and report.

```javascript
TaskCreate({
  subject: "Validate build before session end",
  description: `BLOCKING BUILD CHECK:
    1. Run: xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|warning:|BUILD SUCCEEDED|BUILD FAILED)"
    2. If BUILD FAILED: Return immediately with error details
    3. If BUILD SUCCEEDED: Return success confirmation`,
  activeForm: "Validating build (blocking)"
})
// Returns: task-build-id
```

**If build fails, STOP and output:**

```
═══════════════════════════════════════════════════════════════
       ❌ SESSION END BLOCKED - BUILD FAILED
═══════════════════════════════════════════════════════════════
Fix build errors before ending session.
Run: xcodebuild ... to see full errors
Then: Re-run /vitalarc-end-workstation
═══════════════════════════════════════════════════════════════
```

### Phase 2: Test Execution (BLOCKING - After Build Passes)

Tests must pass before proceeding. If tests fail, stop and report.

```javascript
TaskCreate({
  subject: "Run test suite before session end",
  description: `BLOCKING TEST CHECK:
    1. Run: /test-runner (full mode)
    2. If any tests FAIL: Return immediately with failure details
    3. If all tests PASS: Return success with test count summary

    This is a required quality gate.
    IMPORTANT: Save the actual test count (e.g. "535 tests") - it will be needed by docs-update.`,
  activeForm: "Running tests (blocking)",
  addBlockedBy: ["task-build-id"]
})
// Returns: task-test-id
```

**If tests fail, STOP and output:**

```
═══════════════════════════════════════════════════════════════
       ❌ SESSION END BLOCKED - TESTS FAILED
═══════════════════════════════════════════════════════════════
Failed Tests: [N]

1. [TestClass.testMethod1]
2. [TestClass.testMethod2]
...

Fix failing tests before ending session.
Run: xcodebuild test ... to see full output
Then: Re-run /vitalarc-end-workstation
═══════════════════════════════════════════════════════════════
```

### Phase 3: Parallel Quality Checks (After Tests Pass)

Launch all three quality check tasks in a single message for parallel execution.

> **Note**: `progress-update` does NOT depend on test results - it only summarizes work done.
> `design-scan` and `lint-check` wait for tests to ensure they're checking valid, working code.

```javascript
// In a SINGLE message, create all three tasks:

// design-scan blocked by tests (needs valid, tested code to scan)
TaskCreate({
  subject: "Final design system scan",
  description: `Run final design-system-scanner:
    1. Scan VitalArc/Presentation/ for violations
    2. Report summary for session log
    3. Note any new violations introduced this session
    4. Report the design system adoption percentage (needed by docs-update)`,
  activeForm: "Scanning design system",
  addBlockedBy: ["task-test-id"]
})
// Returns: task-scan-id

// lint-check blocked by tests
TaskCreate({
  subject: "Run lint validation",
  description: `Run lint-validator on changed files:
    1. Identify changed Swift files
    2. Run SwiftLint
    3. Report errors (blocking) and warnings (advisory)`,
  activeForm: "Running lint validation",
  addBlockedBy: ["task-test-id"]
})
// Returns: task-lint-id

// progress-update runs immediately (no dependency on build/tests)
TaskCreate({
  subject: "Update progress in session log",
  description: `Run progress-tracker:
    1. Read current session entry in SESSION_LOG.md
    2. Add final Work Log entries
    3. Add session end timestamp
    4. Summarize work completed`,
  activeForm: "Updating progress"
  // NOTE: No blockedBy - can start immediately while tests run
})
// Returns: task-progress-id
```

### Phase 3.5: Update Project Documentation (After Tests + Design Scan)

This task ensures all documentation files reflect actual session data. It must run before committing.

```javascript
TaskCreate({
  subject: "Update project documentation",
  description: `REQUIRED - Update all documentation files with verified data from this session.
    Use actual results from the test run and design scan tasks - do NOT use stale values.

    **PROJECT_STATUS.md**:
    1. Update "Last Updated" line to current date and session number
    2. Update test count in both the header line AND Codebase Stats table to actual count from test run
    3. Update the bottom "Note" line test count to match
    4. Update "Current State" section with this session's accomplishments
    5. Update Design System adoption % in Feature Status table if design scan shows a different value
    6. Review Known Issues section:
       - Remove any issues that are now resolved (verify against codebase)
       - Update counts for remaining issues
       - If issues were resolved, add them to "Recent Resolutions" section

    **README.md**:
    1. Update unit test count in Codebase Stats table if it differs from actual count

    **SESSION_LOG.md**:
    1. Add "Session ended" row to Work Log with current time
    2. Note any deferred or incomplete session goals with status`,
  activeForm: "Updating documentation",
  addBlockedBy: ["task-test-id", "task-scan-id"]
})
// Returns: task-docs-id
```

### Phase 4: Generate Commit Message (After Phase 3 + 3.5)

```javascript
TaskCreate({
  subject: "Generate commit message",
  description: `Run commit-formatter:
    1. Analyze staged changes with git diff --staged
    2. Determine type (feat/fix/refactor/docs/etc)
    3. Determine scope (workout/nutrition/health/ui/infra/session)
    4. Generate conventional commit message
    5. Include Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`,
  activeForm: "Generating commit message",
  addBlockedBy: ["task-scan-id", "task-lint-id", "task-progress-id", "task-docs-id"]
})
// Returns: task-commit-id
```

### Phase 5: Finalization (Sequential)

After commit message is generated:

#### Commit and Push

```bash
git add SESSION_LOG.md PROJECT_STATUS.md README.md
git commit -m "$(cat <<'EOF'
[generated commit message]

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
```

#### Create PR (Optional)

If ready for review:

**PR Title**: `<type>(<scope>): <short description>`

```bash
gh pr create --title "<type>(<scope>): <description>" --body "$(cat <<'EOF'
## Summary
- [Primary change and why]
- [Secondary changes if any]

## Changes
- [List of modified areas]

## Testing
- [x] Build passes locally
- [ ] CI passes
- [ ] Manual testing done

---
Session: [N] | Platform: macOS | Build: Verified

Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### Phase 6: Output Summary

```
═══════════════════════════════════════════════════════════════
       VITALARC WORKSTATION SESSION COMPLETE
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Commits:  [N]
Build:    Passing
Tests:    Passing ([N] tests)
Lint:     [N] warnings (0 errors)
PR:       [URL if created]
───────────────────────────────────────────────────────────────
Next:     [top ready beads from bd ready]
═══════════════════════════════════════════════════════════════
```

## Error Handling

### Build Failure

If build fails at any point, the pipeline halts:

```
═══════════════════════════════════════════════════════════════
       ❌ SESSION END BLOCKED - BUILD FAILED
═══════════════════════════════════════════════════════════════
Errors: [N]
Top error: [first error message]

Fix build errors, then re-run /vitalarc-end-workstation
═══════════════════════════════════════════════════════════════
```

### No Changes to Commit

If git status shows no changes:

```
═══════════════════════════════════════════════════════════════
       VITALARC WORKSTATION SESSION COMPLETE
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Commits:  0 (no changes)
Build:    Passing
───────────────────────────────────────────────────────────────
Session ended with no uncommitted changes.
═══════════════════════════════════════════════════════════════
```
