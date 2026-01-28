---
name: vitalarc-start-cloud
description: Initialize a VitalArc cloud development session. Use when starting work from phone or browser, or for bug fixes, documentation, and small targeted changes that don't require Xcode builds.
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

Session numbers increment on date change. Same-day sessions use minor versions (11.0, 11.1).

```bash
TODAY=$(date +%Y-%m-%d)
CURRENT_SESSION=$(grep -E "^## Session [0-9]+" SESSION_LOG.md | head -1 | sed 's/## Session \([0-9]*\).*/\1/')
LAST_DATE=$(grep -E "^## Session ${CURRENT_SESSION:-0}" SESSION_LOG.md | head -1 | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | xargs -I{} date -j -f "%B %d, %Y" "{}" +%Y-%m-%d 2>/dev/null)
[ "$LAST_DATE" = "$TODAY" ] && SESSION=$CURRENT_SESSION || SESSION=$((${CURRENT_SESSION:-0} + 1))
MINOR=$(git branch -a | grep -cE "claude/cloud-[a-z]+-${SESSION}\\.[0-9]+-${TODAY}" || echo 0)
```

### 3. Create branch

Format: `claude/cloud-<focus>-<session>.<minor>-YYYY-MM-DD`

> **Note**: The `claude/` prefix is required by the Claude Code platform for push permissions.

```bash
FOCUS="cloud-${ARGUMENTS:-session}"
BRANCH="claude/${FOCUS}-${SESSION}.${MINOR}-${TODAY}"
git checkout -b "$BRANCH"
```

### 4. Update state file

```bash
cat > .claude/session-state.json << EOF
{"current_session":$SESSION,"branch":"$BRANCH","platform":"cloud","started_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","build_capable":false}
EOF
```

### 5. Restore stash and read docs

```bash
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

Read: CLAUDE.md, PROJECT_STATUS.md (focus on Known Issues), SESSION_LOG.md (last 100 lines), README.md (Roadmap).

### 6. Suggest focus (if none provided)

If no `$ARGUMENTS`, suggest from **Known Issues** in PROJECT_STATUS.md or documentation tasks. Cloud is best for logic bugs, docs, and small refactors—not UI changes.

### 7. Create session log entry

Add to SESSION_LOG.md:

```markdown
## Session [N] - [Month Day, Year] ([Time of Day])

### Session Start
- **Time**: [specific time, e.g., "3:45 PM PST" or "Evening"]
- **Platform**: cloud ☁️
- **Focus**: [focus or "General"]
- **Branch**: [branch]
- **Base**: main @ [commit hash] [commit message]

### Environment
- **Build Capable**: No
- **Test Capable**: No

### Pre-Session Status
- **Build**: ⏭️ Skipped (cloud)
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
         VITALARC CLOUD SESSION INITIALIZED ☁️
═══════════════════════════════════════════════════════
Branch:   [branch]
Session:  [N]
Focus:    [focus]
───────────────────────────────────────────────────────
Best for: Bug fixes, docs, code review, small changes
═══════════════════════════════════════════════════════
```
