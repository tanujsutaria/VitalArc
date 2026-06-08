---
name: vitalarc-end-workstation
description: Finalize a VitalArc workstation development session. Use when ending a session on Mac. Verifies build passes, commits documentation, and pushes changes.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Skill, Task, TaskCreate, TaskUpdate, TaskList
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
│    └── Skill: build-validator (MUST PASS)                           │
│                                                                      │
│  PHASE 2 - Test Execution (BLOCKING - after build):                 │
│    └── Skill: test-runner (MUST PASS)                               │
│                                                                      │
│  PHASE 3 - Parallel Quality Checks (after tests pass):              │
│    ├── Skill: design-system-scanner                                 │
│    ├── Skill: lint-validator                                        │
│    └── Skill: progress-tracker                                      │
│                                                                      │
│  PHASE 3.5 - Documentation Update (after Phase 2 + 3):             │
│    └── Task: docs-update                                            │
│                                                                      │
│  PHASE 4 - Commit Preparation (After Phase 3 + 3.5):               │
│    └── Skill: commit-formatter                                      │
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
Skill({
  skill: "build-validator"
})
```

> **BLOCKING**: `build-validator` runs the Xcode build and reports errors with suggested fixes. If it reports BUILD FAILED, STOP immediately and output the block below.

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
Skill({
  skill: "test-runner",
  args: "full"
})
```

> **BLOCKING** (after build passes): `test-runner` is a required quality gate. If any test fails, STOP and output the block below. Save the actual test count (e.g. "535 tests") - it will be needed by docs-update.

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

Invoke the three quality-check skills after tests pass.

> **Note**: `progress-tracker` does NOT depend on test results - it only summarizes work done.
> `design-system-scanner` and `lint-validator` run after tests to ensure they're checking valid, working code.

```javascript
// design-system-scanner: scans VitalArc/Modules/ for violations, reports a summary
// for the session log, notes new violations, and reports the design system adoption
// percentage (needed by docs-update).
Skill({
  skill: "design-system-scanner"
})

// lint-validator: runs SwiftLint on the changed Swift files and reports
// errors (blocking) and warnings (advisory).
Skill({
  skill: "lint-validator"
})

// progress-tracker: updates the SESSION_LOG.md Work Log with final entries, the
// session end timestamp, and a summary of work completed. Independent of test results.
Skill({
  skill: "progress-tracker"
})
```

### Phase 3.5: Update Project Documentation (After Tests + Design Scan)

This task ensures all documentation files reflect actual session data. It must run before committing.

```javascript
TaskCreate({
  subject: "Update project documentation",
  description: `REQUIRED - Update all documentation files with verified data from this session.
    Use actual results from the test-runner and design-system-scanner skills - do NOT use stale values.

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
  activeForm: "Updating documentation"
})
```

### Phase 4: Generate Commit Message (After Phase 3 + 3.5)

```javascript
Skill({
  skill: "commit-formatter"
})
```

> `commit-formatter` analyzes the staged changes (`git diff --staged`), determines the type (feat/fix/refactor/docs/etc) and scope (workout/health/ui/infra/session), generates a conventional commit message, and includes the `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>` trailer.

### Phase 5: Finalization (Sequential)

After commit message is generated:

#### Commit and Push

```bash
git add SESSION_LOG.md PROJECT_STATUS.md README.md
git commit -m "$(cat <<'EOF'
[generated commit message]

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
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
Next:     [top focus-suggester recommendations]
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
