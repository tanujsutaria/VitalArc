---
name: vitalarc-start-workstation
description: Initialize a VitalArc workstation development session. Use when starting work on Mac for feature development, UI changes, large refactors, or any work requiring Xcode builds and simulator testing.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task, TaskCreate, TaskUpdate, TaskList
argument-hint: [focus-area]
---

# VitalArc Workstation Session Init

Start a full development session on Mac with Xcode builds and simulator access.

## Task Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SESSION INITIALIZATION PIPELINE                   │
├─────────────────────────────────────────────────────────────────────┤
│  PHASE 1 - Git Sync (Sequential):                                   │
│    └── Task: sync-with-main                                         │
│                                                                      │
│  PHASE 2 - Parallel Initialization (Fan-Out):                       │
│    ├── Task: focus-analysis      ─┐                                 │
│    ├── Task: build-validation     ├── All run in parallel           │
│    └── Task: design-system-scan  ─┘                                 │
│                                                                      │
│  PHASE 3 - Session Setup (Blocked by Phase 2):                      │
│    └── Task: create-session-log (blockedBy: phase-2-tasks)          │
└─────────────────────────────────────────────────────────────────────┘
```

## Implementation

### Phase 1: Git Sync (Sequential)

Execute these git commands before spawning any tasks:

```bash
# Stash any uncommitted changes
[ -n "$(git status --porcelain)" ] && git stash push -m "Auto-stash $(date +%Y-%m-%d-%H%M)"

# Sync with main
git fetch origin && git checkout main && git pull origin main --ff-only
```

### Phase 2: Determine Session Number

**Session numbering rules:**
- **Major number** increments when the DATE changes (e.g., Session 12.x → Session 13.0)
- **Minor version** increments for same-day sessions (e.g., 13.0 → 13.1 → 13.2)
- **Always include minor version** in format (e.g., 13.0, not just 13)

```bash
TODAY=$(date +%Y-%m-%d)
LATEST_ENTRY=$(grep -E "^## Session [0-9]+\.[0-9]+ - " SESSION_LOG.md | head -1)
LATEST_MAJOR=$(echo "$LATEST_ENTRY" | sed -E 's/## Session ([0-9]+)\..*/\1/')
LATEST_MAJOR=${LATEST_MAJOR:-0}
LATEST_DATE_STR=$(echo "$LATEST_ENTRY" | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | head -1)
LATEST_DATE=$(date -j -f "%B %d, %Y" "$LATEST_DATE_STR" +%Y-%m-%d 2>/dev/null || echo "")
if [ "$LATEST_DATE" = "$TODAY" ]; then
    SESSION=$LATEST_MAJOR
    MINOR=$(grep -E "^## Session ${SESSION}\.[0-9]+ - .*${LATEST_DATE_STR}" SESSION_LOG.md | wc -l | tr -d ' ')
else
    SESSION=$((LATEST_MAJOR + 1))
    MINOR=0
fi
FULL_SESSION="${SESSION}.${MINOR}"
```

### Phase 3: Create Branch

Format: `dev/mac-<focus>-<session>.<minor>-YYYY-MM-DD`

```bash
FOCUS="${ARGUMENTS:-session}"
BRANCH="dev/mac-${FOCUS}-${FULL_SESSION}-${TODAY}"
git checkout -b "$BRANCH"
```

### Phase 4: Restore Stash

```bash
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

### Phase 5: Parallel Task Initialization

**CRITICAL: Launch all three tasks in a SINGLE message with multiple TaskCreate calls.**

This enables true parallel execution where all tasks run simultaneously:

```javascript
// In a SINGLE message, create all three tasks:

TaskCreate({
  subject: "Analyze focus areas for session",
  description: `Run focus-suggester analysis:
    1. Read PROJECT_STATUS.md and SESSION_LOG.md
    2. Score potential focus areas using priority rubric
    3. Return top 3 recommendations with scores
    Platform: workstation (all work types available)`,
  activeForm: "Analyzing focus areas"
})
// Returns: task-focus-id

TaskCreate({
  subject: "Validate Xcode build",
  description: `Run build validation:
    1. Execute: xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|warning:|BUILD SUCCEEDED|BUILD FAILED)"
    2. Report: SUCCEEDED or FAILED with error count
    3. If FAILED, list top 3 errors`,
  activeForm: "Validating build"
})
// Returns: task-build-id

TaskCreate({
  subject: "Scan design system compliance",
  description: `Run design-system-scanner:
    1. Scan VitalArc/Presentation/ for design token violations
    2. Report summary: X color, Y spacing, Z typography violations
    3. List top 5 files by violation count`,
  activeForm: "Scanning design system"
})
// Returns: task-scan-id
```

### Phase 6: Create Session Log (Blocked by Phase 5)

After all parallel tasks complete, create the session log entry:

```javascript
TaskCreate({
  subject: "Create SESSION_LOG.md entry",
  description: `Create session entry with results from parallel tasks:
    - Session: ${FULL_SESSION}
    - Branch: ${BRANCH}
    - Build status: [from build task]
    - Focus: [from focus task or user-specified]
    - Design violations: [from scan task]

    Use workstation template format.`,
  activeForm: "Creating session log",
  addBlockedBy: ["task-focus-id", "task-build-id", "task-scan-id"]
})
```

### Session Log Template

```markdown
## Session [FULL_SESSION] - [Month Day, Year] ([Time])

### Session Start
- **Time**: [Time] PST
- **Platform**: macOS
- **Focus**: [FOCUS or suggested focus]
- **Branch**: [BRANCH]
- **Base**: main @ [latest commit]

### Environment
- **Build Capable**: Yes
- **Test Capable**: Yes (unit + UI)

### Pre-Session Status
- **Build**: [from build-validator task]
- **Design Violations**: [from design-system-scanner task]
- **Uncommitted Changes**: None

### Session Goals
1. [Based on focus area]
2. [Secondary goal if applicable]
3. General development as directed

### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| [Time] | Session started | - | Build verified |
```

### Phase 7: Output Summary

```
═══════════════════════════════════════════════════════════════
       VITALARC WORKSTATION SESSION INITIALIZED
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Session:  [FULL_SESSION]
Build:    [status from task]
Focus:    [focus]
Violations: [count from scan task]
───────────────────────────────────────────────────────────────
Full builds, simulator, and testing available
═══════════════════════════════════════════════════════════════
```

## Error Handling

### Build Failed on Init

If build-validation task reports FAILED:

```
═══════════════════════════════════════════════════════════════
       ⚠️ SESSION STARTED WITH BUILD ERRORS
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Session:  [FULL_SESSION]
Build:    FAILED ([N] errors)
───────────────────────────────────────────────────────────────
Priority: Fix build before starting new work
═══════════════════════════════════════════════════════════════
```

### Task Timeout

If any parallel task doesn't complete within 2 minutes, proceed with available results and note the timeout in the session log.
