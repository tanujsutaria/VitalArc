---
name: vitalarc-start-cloud
description: Initialize a VitalArc cloud development session. Use when starting work from phone or browser, or for bug fixes, documentation, and small targeted changes that don't require Xcode builds.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task, TaskCreate, TaskUpdate, TaskList
argument-hint: [focus-area]
---

# VitalArc Cloud Session Init

Start a cloud session optimized for phone/browser access. No Xcode builds available.

## Task Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CLOUD SESSION INITIALIZATION                      │
├─────────────────────────────────────────────────────────────────────┤
│  PHASE 1 - Git Sync (Sequential):                                   │
│    └── Sync with main, create/use branch                            │
│                                                                      │
│  PHASE 2 - Parallel Analysis (Fan-Out):                             │
│    ├── Task: focus-analysis (cloud-filtered) ─┐                     │
│    └── Task: design-system-scan (report only) ─┘ Parallel           │
│                                                                      │
│  PHASE 3 - Session Setup (Blocked by Phase 2):                      │
│    └── Task: create-session-log                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Note**: Build validation skipped (no Xcode on cloud).

## Implementation

### Phase 1: Git Sync (Sequential)

```bash
# Stash any uncommitted changes
[ -n "$(git status --porcelain)" ] && git stash push -m "Auto-stash $(date +%Y-%m-%d-%H%M)"

# Sync with main
git fetch origin && git checkout main && git pull origin main --ff-only
```

### Phase 2: Determine Session Number

**Session numbering rules:**
- **Major number** increments when the DATE changes
- **Minor version** increments for same-day sessions
- **Always include minor version** in format

```bash
TODAY=$(date +%Y-%m-%d)
LATEST_ENTRY=$(grep -E "^## Session [0-9]+\.[0-9]+ - " SESSION_LOG.md | head -1)
LATEST_MAJOR=$(echo "$LATEST_ENTRY" | sed -E 's/## Session ([0-9]+)\..*/\1/')
LATEST_MAJOR=${LATEST_MAJOR:-0}
LATEST_DATE_STR=$(echo "$LATEST_ENTRY" | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | head -1)
LATEST_DATE=$(date -d "$LATEST_DATE_STR" +%Y-%m-%d 2>/dev/null || echo "")
if [ "$LATEST_DATE" = "$TODAY" ]; then
    SESSION=$LATEST_MAJOR
    MINOR=$(grep -E "^## Session ${SESSION}\.[0-9]+ - .*${LATEST_DATE_STR}" SESSION_LOG.md | wc -l | tr -d ' ')
else
    SESSION=$((LATEST_MAJOR + 1))
    MINOR=0
fi
FULL_SESSION="${SESSION}.${MINOR}"
```

### Phase 3: Use Platform-Provided Branch

> **Note**: Claude Code platform controls the branch name (format: `claude/vitalarc-start-cloud-<sessionID>`). Use the branch provided in the system instructions.

### Phase 4: Restore Stash

```bash
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

### Phase 5: Parallel Task Initialization

**CRITICAL: Launch BOTH tasks in a SINGLE message for true parallel execution.**

```javascript
// In a SINGLE message, create both tasks:

TaskCreate({
  subject: "Analyze focus areas (cloud-appropriate)",
  description: `Run focus-suggester analysis with cloud filter:
    1. Read PROJECT_STATUS.md and SESSION_LOG.md
    2. Score potential focus areas
    3. FILTER: Only recommend cloud-appropriate work:
       - Bug fixes (logic, not UI)
       - Documentation updates
       - Code review
       - Small, targeted changes
       - NO UI work, NO builds required
    4. Return top 3 recommendations with scores`,
  activeForm: "Analyzing focus areas"
})
// Returns: task-focus-id

TaskCreate({
  subject: "Scan design system (report only)",
  description: `Run design-system-scanner in report-only mode:
    1. Scan VitalArc/Presentation/ for violations
    2. Report summary counts only
    3. NOTE: Cloud session - report for awareness, no fixing`,
  activeForm: "Scanning design system"
})
// Returns: task-scan-id
```

### Phase 6: Create Session Log (Blocked by Phase 5)

```javascript
TaskCreate({
  subject: "Create SESSION_LOG.md entry",
  description: `Create cloud session entry:
    - Session: ${FULL_SESSION}
    - Platform: cloud
    - Focus: [from focus task, cloud-filtered]
    - Build: Skipped (cloud)

    Use cloud template format.`,
  activeForm: "Creating session log",
  addBlockedBy: ["task-focus-id", "task-scan-id"]
})
```

### Session Log Template

```markdown
## Session [FULL_SESSION] - [Month Day, Year] ([Time])

### Session Start
- **Time**: [Time] UTC
- **Platform**: cloud
- **Focus**: [FOCUS or suggested focus]
- **Branch**: [BRANCH]
- **Base**: main @ [latest commit]

### Environment
- **Build Capable**: No
- **Test Capable**: No

### Pre-Session Status
- **Build**: Skipped (cloud)
- **Design Violations**: [count from scan, for awareness]
- **Uncommitted Changes**: None

### Session Goals
1. [Based on focus area - cloud appropriate]
2. [Secondary goal if applicable]

### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| [Time] | Session started | - | Cloud session |
```

### Phase 7: Output Summary

```
═══════════════════════════════════════════════════════════════
         VITALARC CLOUD SESSION INITIALIZED
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Session:  [FULL_SESSION]
Focus:    [focus]
───────────────────────────────────────────────────────────────
Best for: Bug fixes, docs, code review, small changes
═══════════════════════════════════════════════════════════════
```
