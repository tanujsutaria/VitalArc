---
name: vitalarc-end
description: Finalize a VitalArc development session with auto-detected platform. Prefer /vitalarc-end-workstation (Mac) or /vitalarc-end-cloud (phone/browser) for platform-specific workflows.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
argument-hint: [summary]
---

# VitalArc Session End (Auto-detect)

> **Prefer platform-specific skills:**
> - `/vitalarc-end-workstation` — Mac, with build verification
> - `/vitalarc-end-cloud` — Phone/browser, no build check

Auto-detects platform and finalizes accordingly.

## Current State

- **Platform**: !`uname -s | sed 's/Darwin/macOS/;s/Linux/cloud/'`
- **Branch**: !`git rev-parse --abbrev-ref HEAD 2>/dev/null`
- **Commits today**: !`git log --oneline --since="6 hours ago" 2>/dev/null | head -5`
- **Uncommitted**: !`git status --short 2>/dev/null`

## Steps

### 1. Detect platform and delegate

```bash
PLATFORM=$([ "$(uname -s)" = "Darwin" ] && echo "mac" || echo "cloud")
```

If `mac`: Follow `/vitalarc-end-workstation` workflow (with build check).
If `cloud`: Follow `/vitalarc-end-cloud` workflow (skip builds).

### 2. Build check (macOS only)

```bash
[ "$(uname -s)" = "Darwin" ] && xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD)"
```

### 3. Gather stats

```bash
git log --oneline --since="6 hours ago"
git diff --stat HEAD~10 2>/dev/null | tail -3
```

### 4. Update SESSION_LOG.md

Complete Work Log table, fill in "Work Completed" and "Session End" sections.

### 5. Update PROJECT_STATUS.md and README.md

If features changed, update status files accordingly.

### 6. Update state file

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
SESSION=$(echo "$BRANCH" | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f1)
cat > .claude/session-state.json << EOF
{"current_session":${SESSION:-0},"branch":"$BRANCH","platform":"$PLATFORM","status":"completed","ended_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
EOF
```

### 7. Commit and push

```bash
git add SESSION_LOG.md PROJECT_STATUS.md README.md .claude/session-state.json
git commit -m "docs(session): update session [N] documentation

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
```

### 8. Create PR (optional)

If ready for review, use `gh pr create` with conventional commit title.
