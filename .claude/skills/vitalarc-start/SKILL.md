---
name: vitalarc-start
description: Initialize a VitalArc development session - pull latest, explore codebase, read docs, create session log, prepare context for coding
allowed-tools: Read, Grep, Glob, Bash, Write, Task
argument-hint: [optional-focus-area]
---

# VitalArc Session Initialization

You are starting a new development session for the VitalArc iOS fitness app.

## Phase 1: Sync with Remote

Execute these commands to get latest code:

```bash
cd /Users/tanujsutaria/Development/VitalArc
git fetch origin
git status
git pull origin main --ff-only || echo "Pull failed - check for conflicts"
```

Report any merge conflicts or diverged branches.

## Phase 2: Explore Codebase State

1. **Get recent commits** (last 10):
   ```bash
   git log --oneline -10
   ```

2. **Check modified files**:
   ```bash
   git status --short
   ```

3. **Count Swift files** to verify codebase integrity:
   ```bash
   find VitalArc -name "*.swift" | wc -l
   ```

4. **Find recently modified files** (last 24 hours):
   ```bash
   find VitalArc -name "*.swift" -mtime -1 -type f
   ```

## Phase 3: Read Core Documentation

Read these files to understand current project state:

1. **CLAUDE.md** - Project memory and architecture overview
2. **PROJECT_STATUS.md** - Current feature status and MVP blockers
3. **SESSION_LOG.md** - Recent development history
4. **EXECUTION_PLAN_SESSION5.md** - Planned work (if exists)

Summarize key points from each.

## Phase 4: Analyze Codebase Statistics

Use the Explore agent to gather:
- Total Swift files and lines of code
- Design system adoption percentage
- Any new TODOs or FIXMEs added
- Test coverage status

## Phase 5: Create Session Log Entry

Add a new session entry to SESSION_LOG.md with this format:

```markdown
## Session X - [Today's Date] ([Time of Day])

### Session Start
- **Time**: [Current time]
- **Focus**: [From $ARGUMENTS if provided, otherwise "General development"]
- **Branch**: [Current git branch]
- **Last Commit**: [Most recent commit hash and message]

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

## Phase 6: Prepare Execution Context

Output a structured summary for the coding session:

### Context Summary Format

```
═══════════════════════════════════════════════════════════
                 VITALARC SESSION INITIALIZED
═══════════════════════════════════════════════════════════

📍 PROJECT STATE
   Branch: [branch]
   Last Commit: [hash] [message]
   Uncommitted: [count] files

📊 CODEBASE METRICS
   Swift Files: [count]
   Lines of Code: ~[count]
   Design System Adoption: [X]%

🔴 MVP BLOCKERS (from PROJECT_STATUS.md)
   1. [blocker 1]
   2. [blocker 2]
   ...

📋 PENDING TASKS
   - [task 1]
   - [task 2]
   ...

🎯 SESSION FOCUS
   [From $ARGUMENTS or suggested based on blockers]

⚠️  WARNINGS
   [Any issues found: API keys, conflicts, errors]

═══════════════════════════════════════════════════════════
```

## Phase 7: Build Verification

Run a quick build to ensure codebase compiles:

```bash
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|warning:|BUILD SUCCEEDED|BUILD FAILED)" | head -20
```

Report build status.

## Final Output

After completing all phases, confirm:
1. Codebase is synced and builds
2. Session log entry created
3. Context summary displayed
4. Ready for coding work

If $ARGUMENTS was provided (e.g., "Nutrition" or "Design System"), focus the context summary on that area.
