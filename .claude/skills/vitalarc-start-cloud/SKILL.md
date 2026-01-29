---
name: vitalarc-start-cloud
description: Initialize a VitalArc cloud development session. Use when starting work from phone or browser, or for bug fixes, documentation, and small targeted changes that don't require Xcode builds.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
argument-hint: [focus-area]
---

# VitalArc Cloud Session Init

Start a cloud session optimized for phone/browser access. No Xcode builds available.

## Current State

- **Platform**: !`uname -s | sed 's/Darwin/macOS/;s/Linux/cloud/'`
- **Branch**: !`git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached"`
- **Uncommitted**: !`git status --short 2>/dev/null | head -5`

## Steps

### 1. Sync with main

Stash any uncommitted changes, fetch and checkout main:
```bash
[ -n "$(git status --porcelain)" ] && git stash push -m "Auto-stash $(date +%Y-%m-%d-%H%M)"
git fetch origin && git checkout main && git pull origin main --ff-only
```

### 2. Determine session number

**Session numbering rules:**
- **Major number** increments when the DATE changes (e.g., Session 12 → Session 13)
- **Minor version** increments for same-day sessions (e.g., 12 → 12.1 → 12.2)
- Minor versions are determined by counting SESSION_LOG.md entries for that major number + date

Use the shared script:
```bash
source .claude/skills/_shared/scripts/determine-session.sh cloud
# Sets: SESSION (major), MINOR, FULL_SESSION (e.g., "12.2"), TODAY
```

**Or inline logic** (if script unavailable):
```bash
TODAY=$(date +%Y-%m-%d)
# Get latest session entry and extract major number
LATEST_ENTRY=$(grep -E "^## Session [0-9]+(\.[0-9]+)? - " SESSION_LOG.md | head -1)
LATEST_MAJOR=$(echo "$LATEST_ENTRY" | sed -E 's/## Session ([0-9]+).*/\1/')
LATEST_MAJOR=${LATEST_MAJOR:-0}
# Extract and convert the date
LATEST_DATE_STR=$(echo "$LATEST_ENTRY" | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | head -1)
LATEST_DATE=$(date -d "$LATEST_DATE_STR" +%Y-%m-%d 2>/dev/null || echo "")
# Determine session number
if [ "$LATEST_DATE" = "$TODAY" ]; then
    SESSION=$LATEST_MAJOR
    # Count existing sessions with this major number on today
    MINOR=$(grep -E "^## Session ${SESSION}(\.[0-9]+)? - .*${LATEST_DATE_STR}" SESSION_LOG.md | wc -l | tr -d ' ')
else
    SESSION=$((LATEST_MAJOR + 1))
    MINOR=0
fi
# Format full session number
[ "$MINOR" -eq 0 ] && FULL_SESSION="$SESSION" || FULL_SESSION="${SESSION}.${MINOR}"
```

### 3. Use platform-provided branch

> **Note**: Claude Code platform controls the branch name (format: `claude/vitalarc-start-cloud-<sessionID>`). Use the branch provided in the system instructions—custom naming is not supported for cloud sessions.

Use the branch specified in the Git Development Branch Requirements from the system context.

### 4. Update state file

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
cat > .claude/session-state.json << EOF
{"current_session":"$FULL_SESSION","branch":"$BRANCH","platform":"cloud","started_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","build_capable":false}
EOF
```

### 5. Restore stash and read docs

```bash
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

Read: CLAUDE.md, PROJECT_STATUS.md (focus on Known Issues), SESSION_LOG.md (last 100 lines), README.md (Roadmap).

### 6. Session Start Agent Swarm

Run these agents **in parallel** to get a comprehensive session kickoff:

```
┌───────────────────────────────────────────────────┐
│            CLOUD SESSION START SWARM              │
├─────────────────┬─────────────────────────────────┤
│ focus-suggester │ design-system-auditor           │
│ (if no focus)   │ (token compliance - read only)  │
└─────────────────┴─────────────────────────────────┘
```

**Invoke using Task tool with parallel calls:**

1. **focus-suggester** (if no `$ARGUMENTS` provided):
   - Analyzes README.md Roadmap, PROJECT_STATUS.md Known Issues, recent SESSION_LOG.md
   - Returns ranked focus recommendations appropriate for cloud sessions
   - Filters to: logic bugs, documentation, code review, small refactors

2. **design-system-auditor** (read-only mode):
   - Scans Presentation/ for hardcoded colors, spacing, fonts
   - Reports violation count (fixes require workstation session)

**Output format:**
```markdown
## Session Health Check

### Focus Recommendations (Cloud-Appropriate)
1. **Documentation updates** (Score: 12) - README needs refresh
2. **Logic bug in CalorieUseCase** (Score: 10) - Known issue
3. **Code review PR #15** (Score: 8) - Pending review

### Design System Compliance
⚠️ 12 violations found in 5 files
- ProfileView.swift: 3 hardcoded colors
- WorkoutView.swift: 2 hardcoded spacing
[Note: Auto-fix requires workstation session]

### Build Status
⏭️ Skipped (cloud session - no Xcode)
```

**Cloud session limitations:**
- Cannot run build-validator (no Xcode)
- design-system-auditor reports only, no auto-fix recommended
- Focus suggestions filtered to non-UI work

### 7. Create session log entry

Add to SESSION_LOG.md using the template from [session-log-cloud.md](../_shared/templates/session-log-cloud.md).

**Use `$FULL_SESSION` for the session number** (e.g., "Session 12.2" not "Session 13"):

```markdown
## Session [FULL_SESSION] - [Month Day, Year] ([Time of Day])

### Session Start
- **Time**: [specific time, e.g., "3:45 PM PST" or "Evening"]
- **Platform**: cloud
- **Focus**: [focus or "General"]
- **Branch**: [branch]
- **Base**: main @ [commit hash] [commit message]

### Environment
- **Build Capable**: No
- **Test Capable**: No

### Pre-Session Status
- **Build**: Skipped (cloud)
- **Uncommitted Changes**: [list or None]
- **Recent Activity**: [summary of previous session's outcome]

### Session Goals
1. [Primary goal]
2. [Secondary goal if applicable]

### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| [time] | Session started | - | [focus] |

### Work Completed
[To be filled]

### Session End
[To be filled by /vitalarc-end-cloud]
```

### 8. Output summary

```
═══════════════════════════════════════════════════════
         VITALARC CLOUD SESSION INITIALIZED
═══════════════════════════════════════════════════════
Branch:   [branch]
Session:  [FULL_SESSION]
Focus:    [focus]
───────────────────────────────────────────────────────
Best for: Bug fixes, docs, code review, small changes
═══════════════════════════════════════════════════════
```
