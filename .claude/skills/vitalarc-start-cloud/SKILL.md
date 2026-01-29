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

### 4. Restore stash

```bash
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

### 5. Invoke Session Orchestrator

**Delegate all agent coordination to session-orchestrator:**

```
┌───────────────────────────────────────────────────────────────┐
│              DELEGATE TO SESSION-ORCHESTRATOR                  │
├───────────────────────────────────────────────────────────────┤
│  session-orchestrator --mode=start --platform=cloud           │
│                       [--focus=$FOCUS]                        │
│                                                               │
│  The orchestrator will spawn:                                 │
│    • context-loader (reads CLAUDE.md, PROJECT_STATUS.md)      │
│    • focus-suggester (if no focus provided)                   │
│    • design-system-scanner (token compliance - read only)     │
│    • config-validator (API keys, entitlements)                │
│    • session-state-manager (init state file)                  │
│    • session-log-creator (create log entry)                   │
│    • stats-gatherer (codebase metrics)                        │
│                                                               │
│  Note: build-validator skipped (no Xcode on cloud)            │
└───────────────────────────────────────────────────────────────┘
```

**Invoke using Task tool:**

```markdown
Task: session-orchestrator
Prompt: "--mode=start --platform=cloud --focus=$FOCUS --build-capable=false"
```

The orchestrator will:
1. Load project context
2. Suggest focus if none provided (filtered for cloud-appropriate tasks)
3. Scan for design system violations (read-only)
4. Validate configuration
5. Create session state file
6. Create SESSION_LOG.md entry
7. Gather codebase statistics

**Cloud session limitations:**
- Cannot run build-validator (no Xcode)
- design-system-scanner reports only, no auto-fix recommended
- Focus suggestions filtered to non-UI work

### 6. Output summary

After orchestrator completes, display:

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

## Responsibilities

| This Skill Handles | Orchestrator Handles |
|-------------------|---------------------|
| Git stash/sync | Context loading |
| Branch handling | Focus suggestions |
| Stash restoration | Design system scanning |
| Final summary output | Config validation |
| | Session state management |
| | Session log creation |
| | Stats gathering |
