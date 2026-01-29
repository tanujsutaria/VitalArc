---
name: vitalarc-start-cloud
description: Initialize a VitalArc cloud development session. Use when starting work from phone or browser, or for bug fixes, documentation, and small targeted changes that don't require Xcode builds.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
argument-hint: [focus-area]
---

# VitalArc Cloud Session Init

Start a cloud session optimized for phone/browser access. No Xcode builds available.

## Steps

### 1. Sync with main

Stash any uncommitted changes, fetch and checkout main:
```bash
[ -n "$(git status --porcelain)" ] && git stash push -m "Auto-stash $(date +%Y-%m-%d-%H%M)"
git fetch origin && git checkout main && git pull origin main --ff-only
```

### 2. Determine session number

**Session numbering rules:**
- **Major number** increments when the DATE changes (e.g., Session 12.x → Session 13.0)
- **Minor version** increments for same-day sessions (e.g., 13.0 → 13.1 → 13.2)
- **Always include minor version** in format (e.g., 13.0, not just 13)
- Minor versions are determined by counting SESSION_LOG.md entries for that major number + date

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

### 3. Use platform-provided branch

> **Note**: Claude Code platform controls the branch name (format: `claude/vitalarc-start-cloud-<sessionID>`). Use the branch provided in the system instructions.

### 4. Restore stash

```bash
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

### 5. Parallel Session Initialization

Launch these Task agents IN PARALLEL (single message, multiple tool calls):

**Focus Analysis** (if no focus specified):
```
Read: .claude/skills/focus-suggester/SKILL.md
Agent type: Explore (from maps-to-agent metadata)
Task prompt: "Follow the focus-suggester instructions. Analyze PROJECT_STATUS.md and SESSION_LOG.md. Return top 3 focus recommendations with scores. Filter for cloud-appropriate work (no UI, no builds)."
```

**Design System Scan** (optional, for awareness):
```
Read: .claude/skills/design-system-scanner/SKILL.md
Agent type: Explore (from maps-to-agent metadata)
Task prompt: "Scan VitalArc/Presentation/ for design token violations. Report count only. Note: Cloud session - report only, no fixing."
```

**Note**: Build validation skipped (no Xcode on cloud).

### 6. Create SESSION_LOG.md entry

Add a new session entry following the cloud template:

```markdown
## Session [FULL_SESSION] - [Month Day, Year] ([Time])

### Session Start
- **Time**: [Time] UTC
- **Platform**: cloud ☁️
- **Focus**: [FOCUS or suggested focus]
- **Branch**: [BRANCH]
- **Base**: main @ [latest commit]

### Environment
- **Build Capable**: No
- **Test Capable**: No

### Pre-Session Status
- **Build**: ⏭️ Skipped (cloud)
- **Uncommitted Changes**: None
- **Recent Activity**: [from SESSION_LOG previous session]

### Session Goals
1. [Based on focus area]
2. [Secondary goal if applicable]

### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| [Time] | Session started | - | Cloud session |
```

### 7. Output summary

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
