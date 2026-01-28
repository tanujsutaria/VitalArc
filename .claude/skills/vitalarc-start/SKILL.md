---
name: vitalarc-start
description: Initialize a VitalArc development session with auto-detected platform. Prefer /vitalarc-start-workstation (Mac) or /vitalarc-start-cloud (phone/browser) for platform-specific workflows.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
argument-hint: [focus-area]
---

# VitalArc Session Init (Auto-detect)

> **Prefer platform-specific skills:**
> - `/vitalarc-start-workstation` — Mac, full builds
> - `/vitalarc-start-cloud` — Phone/browser, no builds

Auto-detects platform and initializes accordingly.

## Current State

- **Platform**: !`uname -s | sed 's/Darwin/macOS/;s/Linux/cloud/'`
- **Branch**: !`git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached"`
- **Uncommitted**: !`git status --short 2>/dev/null | head -5`

## Steps

### 1. Detect platform and delegate

```bash
PLATFORM=$([ "$(uname -s)" = "Darwin" ] && echo "mac" || echo "cloud")
```

If `mac`: Follow `/vitalarc-start-workstation` workflow (with build check).
If `cloud`: Follow `/vitalarc-start-cloud` workflow (skip builds).

### 2. Sync with main

```bash
[ -n "$(git status --porcelain)" ] && git stash push -m "Auto-stash $(date +%Y-%m-%d-%H%M)"
git fetch origin && git checkout main && git pull origin main --ff-only
```

### 3. Determine session number

```bash
TODAY=$(date +%Y-%m-%d)
CURRENT_SESSION=$(grep -E "^## Session [0-9]+" SESSION_LOG.md | head -1 | sed 's/## Session \([0-9]*\).*/\1/')
LAST_DATE=$(grep -E "^## Session ${CURRENT_SESSION:-0}" SESSION_LOG.md | head -1 | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | xargs -I{} date -j -f "%B %d, %Y" "{}" +%Y-%m-%d 2>/dev/null)
[ "$LAST_DATE" = "$TODAY" ] && SESSION=$CURRENT_SESSION || SESSION=$((${CURRENT_SESSION:-0} + 1))
MINOR=$(git branch -a | grep -cE "claude/${PLATFORM}-[a-z]+-${SESSION}\\.[0-9]+-${TODAY}" || echo 0)
```

### 4. Create branch

> **Note**: The `claude/` prefix is required by the Claude Code platform for push permissions.

```bash
FOCUS="${PLATFORM}-${ARGUMENTS:-session}"
BRANCH="claude/${FOCUS}-${SESSION}.${MINOR}-${TODAY}"
git checkout -b "$BRANCH"
```

### 5. Update state and restore stash

```bash
cat > .claude/session-state.json << EOF
{"current_session":$SESSION,"branch":"$BRANCH","platform":"$PLATFORM","started_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
EOF
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

### 6. Read docs

Read: CLAUDE.md, PROJECT_STATUS.md, SESSION_LOG.md (last 100 lines), README.md (Roadmap).

### 7. Build check (macOS only)

```bash
[ "$(uname -s)" = "Darwin" ] && xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD)"
```

### 8. Create session log entry

Use platform-appropriate template from `/vitalarc-start-workstation` or `/vitalarc-start-cloud`.
