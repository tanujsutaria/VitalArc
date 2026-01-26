---
name: vitalarc-start
description: Initialize a VitalArc development session - pull latest, explore codebase, read docs, create session log, prepare context for coding
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
argument-hint: [optional-focus-area]
---

# VitalArc Session Initialization

You are starting a new development session for the VitalArc iOS fitness app.

## Current State (Auto-Fetched)

- **Branch**: !`cd /Users/tanujsutaria/Development/VitalArc && git rev-parse --abbrev-ref HEAD`
- **Last 5 Commits**:
!`cd /Users/tanujsutaria/Development/VitalArc && git log --oneline -5`
- **Uncommitted Changes**:
!`cd /Users/tanujsutaria/Development/VitalArc && git status --short`

## Phase 1: Sync with Remote and Create Feature Branch

Pull the latest changes from main:

```bash
cd /Users/tanujsutaria/Development/VitalArc
git fetch origin
git checkout main
git pull origin main --ff-only || echo "Pull failed - check for conflicts"
```

Report any merge conflicts or diverged branches.

Then create a feature branch for this session's work:

```bash
# Create branch name based on date and optional focus area
# Format: dev/session-YYYY-MM-DD or dev/[focus-area]-YYYY-MM-DD
git checkout -b dev/session-$(date +%Y-%m-%d) || git checkout dev/session-$(date +%Y-%m-%d)
```

If $ARGUMENTS was provided, use it for a more descriptive branch name:
```bash
# Example: dev/nutrition-2026-01-26
git checkout -b dev/$ARGUMENTS-$(date +%Y-%m-%d) 2>/dev/null || git checkout dev/$ARGUMENTS-$(date +%Y-%m-%d)
```

**Note**: All development work should happen on feature branches, not main. The branch will be merged to main via PR when work is complete.

## Phase 2: Explore Codebase State

1. **Count Swift files** to verify codebase integrity:
   ```bash
   find VitalArc -name "*.swift" | wc -l
   ```

2. **Find recently modified files** (last 24 hours):
   ```bash
   find VitalArc -name "*.swift" -mtime -1 -type f 2>/dev/null | head -15
   ```

## Phase 3: Read Core Documentation

Read these files to understand current project state:

1. **CLAUDE.md** - Project memory and architecture overview
2. **PROJECT_STATUS.md** - Current feature status and MVP blockers
3. **SESSION_LOG.md** - Recent development history (read last 100 lines)
4. **EXECUTION_PLAN_SESSION5.md** - Planned work (if exists)

Summarize key points from each.

## Phase 4: Analyze Codebase Statistics

Use the Explore agent to gather:
- Design system adoption percentage
- Any new TODOs or FIXMEs
- Test coverage status

## Phase 5: Create Session Log Entry

Add a new session entry to SESSION_LOG.md with this format:

```markdown
## Session [N] - [Today's Date] ([Time of Day])

### Session Start
- **Time**: [Current time]
- **Focus**: [From $ARGUMENTS if provided, otherwise "General development"]
- **Branch**: [Feature branch created for this session]
- **Base**: main @ [Most recent commit hash and message]

### Pre-Session Status
- **Build**: [Run quick build check]
- **Uncommitted Changes**: [List any]
- **Recent Activity**: [Summary of last session's work]

### Planned Work
[Based on EXECUTION_PLAN or user focus area]

### Work Completed
[To be filled during session]

### Session End
[To be filled by /vitalarc-end]
```

## Phase 6: Build Verification

Run a quick build to ensure codebase compiles:

```bash
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|warning:|BUILD SUCCEEDED|BUILD FAILED)" | head -20
```

Report build status.

## Phase 7: Prepare Execution Context

Output a structured summary for the coding session:

```
===========================================================
              VITALARC SESSION INITIALIZED
===========================================================

PROJECT STATE
  Feature Branch: [branch created for this session]
  Base (main): [hash] [message]
  Uncommitted: [count] files

CODEBASE METRICS
  Swift Files: [count]
  Design System Adoption: [X]%

MVP BLOCKERS (from PROJECT_STATUS.md)
  1. [blocker 1]
  2. [blocker 2]

PENDING TASKS
  - [task 1]
  - [task 2]

SESSION FOCUS
  [From $ARGUMENTS or suggested based on blockers]

WARNINGS
  [Any issues found: API keys, conflicts, errors]

===========================================================
```

## Final Output

After completing all phases, confirm:
1. Codebase is synced with main and builds
2. Feature branch created for this session
3. Session log entry created
4. Context summary displayed
5. Ready for coding work on feature branch

If $ARGUMENTS was provided (e.g., "Nutrition" or "Design System"), focus the context summary on that area.
