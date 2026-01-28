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

Session numbers increment on date change. Same-day sessions use minor versions (11.0, 11.1).

Use the shared script or inline logic:
```bash
# Option 1: Use shared script
source .claude/skills/_shared/scripts/determine-session.sh mac

# Option 2: Inline (if script unavailable)
TODAY=$(date +%Y-%m-%d)
CURRENT_SESSION=$(grep -E "^## Session [0-9]+" SESSION_LOG.md | head -1 | sed 's/## Session \([0-9]*\).*/\1/')
LAST_DATE=$(grep -E "^## Session ${CURRENT_SESSION:-0}" SESSION_LOG.md | head -1 | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | xargs -I{} date -j -f "%B %d, %Y" "{}" +%Y-%m-%d 2>/dev/null)
[ "$LAST_DATE" = "$TODAY" ] && SESSION=$CURRENT_SESSION || SESSION=$((${CURRENT_SESSION:-0} + 1))
MINOR=$(git branch -a | grep -cE "dev/mac-[a-z]+-${SESSION}\\.[0-9]+-${TODAY}" || echo 0)
```

### 3. Create branch

Format: `dev/mac-<focus>-<session>.<minor>-YYYY-MM-DD`

```bash
FOCUS="mac-${ARGUMENTS:-session}"
BRANCH="dev/${FOCUS}-${SESSION}.${MINOR}-${TODAY}"
git checkout -b "$BRANCH"
```

### 4. Update state file

```bash
cat > .claude/session-state.json << EOF
{"current_session":$SESSION,"branch":"$BRANCH","platform":"mac","started_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","build_capable":true}
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

Add to SESSION_LOG.md using the template from [session-log-workstation.md](../_shared/templates/session-log-workstation.md):

```markdown
## Session [N] - [Month Day, Year] ([Time of Day])

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
Session:  [N]
Build:    [status]
Focus:    [focus]
───────────────────────────────────────────────────────
Full builds, simulator, and testing available
═══════════════════════════════════════════════════════
```
