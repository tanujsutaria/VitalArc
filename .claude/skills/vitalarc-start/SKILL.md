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

### 2. Determine session number

```bash
# Get current session from SESSION_LOG.md
CURRENT=$(grep -E "^## Session [0-9]+" SESSION_LOG.md | head -1 | sed 's/## Session \([0-9]*\).*/\1/')

# Check state file as backup
[ -f ".claude/session-state.json" ] && STATE=$(grep -o '"current_session": *[0-9]*' .claude/session-state.json | grep -o '[0-9]*')

# Use higher of the two
SESSION=${CURRENT:-0}
[ -n "$STATE" ] && [ "$STATE" -gt "$SESSION" ] && SESSION=$STATE

# Increment if last session is complete (has "Session End")
if awk '/^## Session '"$SESSION"'/,/^## Session [0-9]/{if(/### Session End/) exit 0}' SESSION_LOG.md; then
    SESSION=$((SESSION + 1))
fi

echo "Session: $SESSION"
```

### 3. Create feature branch

**Branch format**: `dev/<focus>-<session>.<minor>-YYYY-MM-DD`

```bash
PLATFORM=$([ "$(uname -s)" = "Darwin" ] && echo "mac" || echo "cloud")
TODAY=$(date +%Y-%m-%d)
FOCUS="${ARGUMENTS:-${PLATFORM}-session}"
FOCUS=$(echo "$FOCUS" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Find minor version
MINOR=$(git branch -a | grep -cE "dev/${FOCUS}-${SESSION}\\.[0-9]+-${TODAY}" || echo 0)

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
| `dev/<focus>-<session>.<minor>-YYYY-MM-DD` | `dev/nutrition-12.0-2026-01-27` |
| Default focus (no args) | `dev/mac-session-12.0-2026-01-27` |
