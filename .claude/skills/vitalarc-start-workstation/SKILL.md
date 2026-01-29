---
name: vitalarc-start-workstation
description: Initialize a VitalArc workstation development session. Use when starting work on Mac for feature development, UI changes, large refactors, or any work requiring Xcode builds and simulator testing.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
argument-hint: [focus-area]
---

# VitalArc Workstation Session Init

Start a full development session on Mac with Xcode builds and simulator access.

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

### 3. Create branch

Format: `dev/mac-<focus>-<session>.<minor>-YYYY-MM-DD`

```bash
FOCUS="${ARGUMENTS:-session}"
BRANCH="dev/mac-${FOCUS}-${FULL_SESSION}-${TODAY}"
git checkout -b "$BRANCH"
```

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
Task prompt: "Follow the focus-suggester instructions. Analyze PROJECT_STATUS.md and SESSION_LOG.md. Return top 3 focus recommendations with scores."
```

**Build Validation**:
```
Read: .claude/skills/build-validator/SKILL.md
Agent type: Bash (from maps-to-agent metadata)
Task prompt: "Run xcodebuild for VitalArc. Report build status (SUCCEEDED/FAILED) and any errors."
```

**Design System Scan** (optional, for awareness):
```
Read: .claude/skills/design-system-scanner/SKILL.md
Agent type: Explore (from maps-to-agent metadata)
Task prompt: "Scan VitalArc/Presentation/ for design token violations. Report count only."
```

### 6. Create SESSION_LOG.md entry

Add a new session entry following the workstation template:

```markdown
## Session [FULL_SESSION] - [Month Day, Year] ([Time])

### Session Start
- **Time**: [Time] PST
- **Platform**: macOS 🖥️
- **Focus**: [FOCUS or suggested focus]
- **Branch**: [BRANCH]
- **Base**: main @ [latest commit]

### Environment
- **Build Capable**: Yes
- **Test Capable**: Yes (unit + UI)

### Pre-Session Status
- **Build**: [from build-validator]
- **Uncommitted Changes**: None
- **Recent Activity**: [from SESSION_LOG previous session]

### Session Goals
1. [Based on focus area]
2. [Secondary goal if applicable]
3. General development as directed

### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| [Time] | Session started | - | Build verified ✅ |
```

### 7. Output summary

```
═══════════════════════════════════════════════════════════════
       VITALARC WORKSTATION SESSION INITIALIZED
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Session:  [FULL_SESSION]
Build:    [status]
Focus:    [focus]
───────────────────────────────────────────────────────────────
Full builds, simulator, and testing available
═══════════════════════════════════════════════════════════════
```
