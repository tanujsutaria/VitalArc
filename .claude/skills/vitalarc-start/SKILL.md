---
name: vitalarc-start
description: Initialize a VitalArc development session - pull latest, explore codebase, read docs, create session log, prepare context for coding
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
argument-hint: [optional-focus-area]
---

# VitalArc Session Initialization

Initialize a development session for VitalArc iOS app.

## Current State

- **Platform**: !`uname -s | sed 's/Darwin/macOS/;s/Linux/cloud/'`
- **Branch**: !`git rev-parse --abbrev-ref HEAD 2>/dev/null`
- **Recent Commits**: !`git log --oneline -3 2>/dev/null`
- **Uncommitted**: !`git status --short 2>/dev/null`

## Steps

### 1. Sync with main

```bash
# Stash uncommitted changes
[ -n "$(git status --porcelain)" ] && git stash push -m "Auto-stash $(date +%Y-%m-%d-%H%M)"

# Pull latest
git fetch origin && git checkout main && git pull origin main --ff-only
```

### 2. Determine session number and minor version

Session numbers increment only when the **date changes**. Multiple sessions on the same day use minor versions (11.0, 11.1, 11.2).

```bash
TODAY=$(date +%Y-%m-%d)

# Get current session number and date from SESSION_LOG.md
CURRENT_SESSION=$(grep -E "^## Session [0-9]+" SESSION_LOG.md | head -1 | sed 's/## Session \([0-9]*\).*/\1/')
CURRENT_SESSION=${CURRENT_SESSION:-0}

# Extract date from last session header (format: "## Session N - January 27, 2026")
LAST_SESSION_DATE=$(grep -E "^## Session ${CURRENT_SESSION}" SESSION_LOG.md | head -1 | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | head -1)

# Convert last session date to YYYY-MM-DD for comparison
if [ -n "$LAST_SESSION_DATE" ]; then
    LAST_DATE=$(date -j -f "%B %d, %Y" "$LAST_SESSION_DATE" +%Y-%m-%d 2>/dev/null || echo "")
else
    LAST_DATE=""
fi

# Determine session number based on date
if [ "$LAST_DATE" = "$TODAY" ]; then
    # Same day - keep session number
    SESSION=$CURRENT_SESSION
else
    # New day - increment session number
    SESSION=$((CURRENT_SESSION + 1))
fi

echo "Session: $SESSION (Last session date: $LAST_DATE, Today: $TODAY)"
```

### 3. Create feature branch

**Branch format**: `dev/<platform>-<focus>-<session>.<minor>-YYYY-MM-DD`

```bash
PLATFORM=$([ "$(uname -s)" = "Darwin" ] && echo "mac" || echo "cloud")

# Always include platform prefix
if [ -n "$ARGUMENTS" ]; then
    FOCUS="${PLATFORM}-$(echo "$ARGUMENTS" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
else
    FOCUS="${PLATFORM}-session"
fi

# Find minor version by counting existing branches for this session+date (any focus)
MINOR=$(git branch -a | grep -cE "dev/${PLATFORM}-[a-z]+-${SESSION}\\.[0-9]+-${TODAY}" || echo 0)

BRANCH="dev/${FOCUS}-${SESSION}.${MINOR}-${TODAY}"
git checkout -b "$BRANCH"
```

### 4. Update state file

```bash
mkdir -p .claude
cat > .claude/session-state.json << EOF
{
  "current_session": $SESSION,
  "branch": "$BRANCH",
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
```

### 5. Restore stashed changes

```bash
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

### 6. Read documentation

Read these files:
1. **CLAUDE.md** - Architecture and conventions
2. **PROJECT_STATUS.md** - Current feature status
3. **SESSION_LOG.md** (last 100 lines) - Recent history

### 7. Build check (macOS only)

```bash
[ "$(uname -s)" = "Darwin" ] && xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD)"
```

### 8. Create session log entry

Add to SESSION_LOG.md:

```markdown
## Session [N] - [Date] ([Time])

### Session Start
- **Platform**: [macOS / cloud]
- **Focus**: [From $ARGUMENTS or "General development"]
- **Branch**: [branch name]
- **Base**: main @ [commit]

### Pre-Session Status
- **Build**: [status]
- **Uncommitted**: [list]

### Work Completed
[To be filled]

### Session End
[To be filled by /vitalarc-end]
```

### 9. Output summary

```
===========================================================
              VITALARC SESSION INITIALIZED
===========================================================
Platform:       [macOS / cloud]
Branch:         [branch name]
Session:        [N]
Build:          [status]
Focus:          [focus area]
===========================================================
```

## Branch Naming

| Pattern | Example |
|---------|---------|
| `dev/<platform>-<focus>-<session>.<minor>-YYYY-MM-DD` | `dev/mac-nutrition-12.0-2026-01-27` |
| Default focus (no args) | `dev/mac-session-12.0-2026-01-27` |
| Cloud example | `dev/cloud-workout-12.0-2026-01-27` |
