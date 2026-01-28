---
name: vitalarc-start-workstation
description: Initialize a VitalArc workstation development session. Use when starting work on Mac for feature development, UI changes, large refactors, or any work requiring Xcode builds and simulator testing.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
argument-hint: [focus-area]
---

# VitalArc Workstation Session Init

Start a full development session on Mac with Xcode builds and simulator access.

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
source .claude/skills/_shared/scripts/determine-session.sh mac
# Sets: SESSION (major), MINOR, FULL_SESSION (e.g., "12.2"), TODAY
```

**Or inline logic** (if script unavailable):
```bash
TODAY=$(date +%Y-%m-%d)
# Get latest session entry and extract major number
LATEST_ENTRY=$(grep -E "^## Session [0-9]+(\.[0-9]+)? - " SESSION_LOG.md | head -1)
LATEST_MAJOR=$(echo "$LATEST_ENTRY" | sed -E 's/## Session ([0-9]+).*/\1/')
LATEST_MAJOR=${LATEST_MAJOR:-0}
# Extract and convert the date (macOS version)
LATEST_DATE_STR=$(echo "$LATEST_ENTRY" | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | head -1)
LATEST_DATE=$(date -j -f "%B %d, %Y" "$LATEST_DATE_STR" +%Y-%m-%d 2>/dev/null || echo "")
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

### 3. Create branch

Format: `dev/mac-<focus>-<session>.<minor>-YYYY-MM-DD`

```bash
FOCUS="${ARGUMENTS:-session}"
BRANCH="dev/mac-${FOCUS}-${FULL_SESSION}-${TODAY}"
git checkout -b "$BRANCH"
```

### 4. Update state file

```bash
cat > .claude/session-state.json << EOF
{"current_session":"$FULL_SESSION","branch":"$BRANCH","platform":"mac","started_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","build_capable":true}
EOF
```

### 5. Restore stash and read docs

```bash
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

Read: CLAUDE.md, PROJECT_STATUS.md, SESSION_LOG.md (last 100 lines), README.md (Roadmap).

### 6. Suggest focus (if none provided)

If no `$ARGUMENTS`, analyze the project to suggest focus areas.

**Use the Task tool** with `subagent_type: Explore` to:
- Read README.md Roadmap section
- Review PROJECT_STATUS.md Known Issues
- Check recent SESSION_LOG.md entries

Prioritize "In Progress" features, then high-priority "Planned" items.

### 7. Build check

```bash
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD)"
```

### 8. Create session log entry

Add to SESSION_LOG.md using the template from [session-log-workstation.md](../_shared/templates/session-log-workstation.md).

**Use `$FULL_SESSION` for the session number** (e.g., "Session 12.2" not "Session 13"):

```markdown
## Session [FULL_SESSION] - [Month Day, Year] ([Time of Day])

### Session Start
- **Time**: [specific time, e.g., "3:45 PM PST" or "Evening"]
- **Platform**: macOS
- **Focus**: [focus or "General development"]
- **Branch**: [branch]
- **Base**: main @ [commit hash] [commit message]

### Environment
- **Build Capable**: Yes
- **Test Capable**: Yes (unit + UI)

### Pre-Session Status
- **Build**: Passing / Failing
- **Uncommitted Changes**: [list or None]
- **Recent Activity**: [summary of previous session's outcome]

### Session Goals
1. [Primary goal based on focus]
2. [Secondary goal]
3. [Stretch goal if applicable]

### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| [time] | Session started | - | Build verified |

### Work Completed
[To be filled]

### Session End
[To be filled by /vitalarc-end-workstation]
```

### 9. Output summary

```
═══════════════════════════════════════════════════════
       VITALARC WORKSTATION SESSION INITIALIZED
═══════════════════════════════════════════════════════
Branch:   [branch]
Session:  [FULL_SESSION]
Build:    [status]
Focus:    [focus]
───────────────────────────────────────────────────────
Full builds, simulator, and testing available
═══════════════════════════════════════════════════════
```
