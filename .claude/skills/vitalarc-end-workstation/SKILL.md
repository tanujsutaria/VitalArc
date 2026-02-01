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
│  PHASE 4 - Commit Preparation (After Phase 3):                      │
│    └── Task: generate-commit (blockedBy: scan + lint + progress)    │
│                                                                      │
│  PHASE 5 - Finalization (Sequential):                               │
│    └── Update docs → Commit → Push → (Optional) Create PR           │
└─────────────────────────────────────────────────────────────────────┘
```

**Note**: Test execution is now a **required blocking gate** after build passes.

## Implementation

### Phase 1: Build Validation (BLOCKING)

**This MUST pass before proceeding. If build fails, STOP and report.**

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

**Tests MUST pass before proceeding. If tests fail, STOP and report.**

```javascript
TaskCreate({
  subject: "Run test suite before session end",
  description: `BLOCKING TEST CHECK:
    1. Run: /test-runner (full mode)
    2. If any tests FAIL: Return immediately with failure details
    3. If all tests PASS: Return success with summary

    This is a required quality gate.`,
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

**Launch ALL THREE quality check tasks in a SINGLE message for parallel execution.**

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
    3. Note any new violations introduced this session`,
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

### Phase 4: Generate Commit Message (After Phase 3)

```javascript
TaskCreate({
  subject: "Generate commit message",
  description: `Run commit-formatter:
    1. Analyze staged changes with git diff --staged
    2. Determine type (feat/fix/refactor/docs/etc)
    3. Determine scope (workout/nutrition/health/ui/infra/session)
    4. Generate conventional commit message
    5. Include Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>`,
  activeForm: "Generating commit message",
  addBlockedBy: ["task-scan-id", "task-lint-id", "task-progress-id"]
})
// Returns: task-commit-id
```

### Phase 5: Finalization (Sequential)

After commit message is generated:

#### Update Documentation Files

If features changed, update:
- **PROJECT_STATUS.md**: Update "Last Updated", feature status, Known Issues, Codebase Stats
- **README.md Roadmap**: Move features between In Progress / Planned / Completed

#### Commit and Push

```bash
git add SESSION_LOG.md PROJECT_STATUS.md README.md
git commit -m "$(cat <<'EOF'
[generated commit message]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
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
Next:     [priorities from focus-suggester]
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

## Issue Reconciliation (CRITICAL)

**At session end, validate that Known Issues in PROJECT_STATUS.md match actual codebase state.**

This prevents stale documentation from wasting future session time on already-resolved issues.

### Reconciliation Process

Before finalizing the session, run these checks:

```javascript
// 1. Read current Known Issues from PROJECT_STATUS.md
const projectStatus = await Read("PROJECT_STATUS.md");
const knownIssuesSection = projectStatus.match(/## Known Issues[\s\S]*?(?=##|$)/);

// 2. Validate each issue against actual codebase
const validations = [
  {
    issue: "Cloud Session Test Files",
    check: async () => {
      // Run tests and check results
      const result = await Bash("xcodebuild test ... 2>&1 | grep 'Executed'");
      return result.includes("0 failures") ? "RESOLVED" : "STILL_OPEN";
    }
  },
  {
    issue: "Design System Gaps",
    check: async () => {
      // Check for violations in app code (not DesignSystem folder)
      const violations = await Grep({
        pattern: "Color\\.(red|blue|green|gray)",
        path: "VitalArc/Presentation/Tabs"
      });
      return violations.length === 0 ? "RESOLVED" : "STILL_OPEN";
    }
  },
  {
    issue: "API Keys",
    check: async () => {
      // Check for placeholder keys
      const placeholders = await Grep({
        pattern: "YOUR_.*_HERE|DEMO_KEY",
        path: "VitalArc/Infrastructure"
      });
      return placeholders.length === 0 ? "RESOLVED" : "STILL_OPEN";
    }
  }
];

// 3. Report discrepancies
validations.forEach(({ issue, check }) => {
  if (knownIssuesSection.includes(issue)) {
    const status = await check();
    if (status === "RESOLVED") {
      console.log(`⚠️ STALE ISSUE: "${issue}" is resolved but still in Known Issues`);
    }
  }
});
```

### Auto-Update on Resolution

When discrepancies are found:

1. **Prompt for confirmation**:
```
═══════════════════════════════════════════════════════════════
       ⚠️ STALE DOCUMENTATION DETECTED
═══════════════════════════════════════════════════════════════
The following Known Issues appear to be resolved:

1. Cloud Session Test Files - 535 tests passing, 0 failures
2. Design System Gaps - 0 violations in app code

Update PROJECT_STATUS.md to remove resolved issues? [Y/n]
═══════════════════════════════════════════════════════════════
```

2. **Update PROJECT_STATUS.md**:
   - Remove resolved items from Known Issues section
   - Add resolution note to session accomplishments

3. **Add Work Log entry**:
```markdown
| [Time] | Updated PROJECT_STATUS.md | PROJECT_STATUS.md | Removed N resolved Known Issues |
```

### Integration with Session End Pipeline

Add to Phase 5 (Finalization), before commit:

```javascript
// After progress-update, before generate-commit
TaskCreate({
  subject: "Reconcile Known Issues",
  description: `Run issue reconciliation:
    1. Read PROJECT_STATUS.md Known Issues section
    2. Validate each issue against actual codebase state
    3. Report any stale/resolved issues
    4. Prompt to update documentation if discrepancies found`,
  activeForm: "Reconciling issues",
  addBlockedBy: ["task-progress-id"]
})
// Returns: task-reconcile-id
// generate-commit should addBlockedBy: ["task-reconcile-id", ...]
```

### Why This Matters

Without reconciliation:
- Future sessions waste time investigating resolved issues
- Focus-suggester recommends already-completed work
- Documentation diverges from reality
- Developer trust in tooling erodes

**Every session end MUST verify documentation accuracy.**
