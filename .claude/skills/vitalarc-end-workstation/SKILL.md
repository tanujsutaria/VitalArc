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
│  PHASE 2 - Parallel Quality Checks (After build passes):            │
│    ├── Task: design-scan    ─┐                                      │
│    └── Task: progress-update ─┘ Parallel, blockedBy: build          │
│                                                                      │
│  PHASE 3 - Commit Preparation (After Phase 2):                      │
│    └── Task: generate-commit (blockedBy: scan + progress)           │
│                                                                      │
│  PHASE 4 - Finalization (Sequential):                               │
│    └── Update docs → Commit → Push → (Optional) Create PR           │
└─────────────────────────────────────────────────────────────────────┘
```

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

### Phase 2: Parallel Quality Checks (After Build Passes)

**Launch BOTH tasks in a SINGLE message for parallel execution:**

```javascript
// Both tasks blocked by build-check
TaskCreate({
  subject: "Final design system scan",
  description: `Run final design-system-scanner:
    1. Scan VitalArc/Presentation/ for violations
    2. Report summary for session log
    3. Note any new violations introduced this session`,
  activeForm: "Scanning design system",
  addBlockedBy: ["task-build-id"]
})
// Returns: task-scan-id

TaskCreate({
  subject: "Update progress in session log",
  description: `Run progress-tracker:
    1. Read current session entry in SESSION_LOG.md
    2. Add final Work Log entries
    3. Add session end timestamp
    4. Summarize work completed`,
  activeForm: "Updating progress",
  addBlockedBy: ["task-build-id"]
})
// Returns: task-progress-id
```

### Phase 3: Generate Commit Message (After Phase 2)

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
  addBlockedBy: ["task-scan-id", "task-progress-id"]
})
// Returns: task-commit-id
```

### Phase 4: Finalization (Sequential)

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

### Phase 5: Output Summary

```
═══════════════════════════════════════════════════════════════
       VITALARC WORKSTATION SESSION COMPLETE
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Commits:  [N]
Build:    Passing
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
