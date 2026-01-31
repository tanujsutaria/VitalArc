---
name: vitalarc-end-cloud
description: Finalize a VitalArc cloud development session. Use when ending a session started from phone or browser. Commits documentation, pushes changes, no build verification.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task, TaskCreate, TaskUpdate, TaskList
argument-hint: [summary]
---

# VitalArc Cloud Session End

Finalize a cloud session. No build verification—CI will validate.

## Task Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CLOUD SESSION END PIPELINE                        │
├─────────────────────────────────────────────────────────────────────┤
│  PHASE 1 - Parallel Quality Checks:                                 │
│    ├── Task: design-scan (report only) ─┐                           │
│    └── Task: progress-update            ─┘ Parallel                 │
│                                                                      │
│  PHASE 2 - Commit Preparation (After Phase 1):                      │
│    └── Task: generate-commit (blockedBy: phase-1-tasks)             │
│                                                                      │
│  PHASE 3 - Finalization:                                            │
│    └── Update docs → Commit → Push → (Optional) Create PR           │
└─────────────────────────────────────────────────────────────────────┘
```

**Note**: No blocking build check (cloud session - CI will verify).

## Implementation

### Phase 1: Parallel Quality Checks

**Launch BOTH tasks in a SINGLE message for true parallel execution:**

```javascript
// In a SINGLE message, create both tasks:

TaskCreate({
  subject: "Final design system scan (report only)",
  description: `Run design-system-scanner in report-only mode:
    1. Scan VitalArc/Presentation/ for violations
    2. Report summary for session log
    3. NOTE: Cloud session - report only, no fixing available`,
  activeForm: "Scanning design system"
})
// Returns: task-scan-id

TaskCreate({
  subject: "Update progress in session log",
  description: `Run progress-tracker:
    1. Read current session entry in SESSION_LOG.md
    2. Add final Work Log entries
    3. Add session end timestamp
    4. Summarize work completed`,
  activeForm: "Updating progress"
})
// Returns: task-progress-id
```

### Phase 2: Generate Commit Message (After Phase 1)

```javascript
TaskCreate({
  subject: "Generate commit message",
  description: `Run commit-formatter:
    1. Analyze staged changes with git diff --staged
    2. Determine type and scope
    3. Generate conventional commit message
    4. Add note: "Cloud session (build not verified)"
    5. Include Co-Authored-By`,
  activeForm: "Generating commit message",
  addBlockedBy: ["task-scan-id", "task-progress-id"]
})
// Returns: task-commit-id
```

### Phase 3: Finalization (Sequential)

#### Update Documentation Files

If features changed:
- **PROJECT_STATUS.md**: Update "Last Updated", Known Issues, feature status
- **README.md Roadmap**: Move features as needed

#### Commit and Push

```bash
git add SESSION_LOG.md PROJECT_STATUS.md README.md
git commit -m "$(cat <<'EOF'
[generated commit message]

- Cloud session (build not verified)

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
- [ ] CI build passes
- [ ] Cloud session—manual testing recommended on workstation

---
Session: [N] | Platform: cloud

Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### Phase 4: Output Summary

```
═══════════════════════════════════════════════════════════════
           VITALARC CLOUD SESSION COMPLETE
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Commits:  [N]
Build:    Not verified (cloud)
Status:   [Complete / Needs Workstation]
───────────────────────────────────────────────────────────────
Next:     [priorities]
═══════════════════════════════════════════════════════════════
```

Use status **Needs Workstation** if changes require UI or build verification.

## Error Handling

### No Changes to Commit

```
═══════════════════════════════════════════════════════════════
           VITALARC CLOUD SESSION COMPLETE
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Commits:  0 (no changes)
Build:    Not verified (cloud)
───────────────────────────────────────────────────────────────
Session ended with no uncommitted changes.
═══════════════════════════════════════════════════════════════
```

### Push Failed

If push fails (e.g., remote branch already exists):

```
═══════════════════════════════════════════════════════════════
       ⚠️ PUSH FAILED
═══════════════════════════════════════════════════════════════
Error: [git error message]

Try: git push --force-with-lease origin [branch]
Or: Create PR from GitHub web interface
═══════════════════════════════════════════════════════════════
```
