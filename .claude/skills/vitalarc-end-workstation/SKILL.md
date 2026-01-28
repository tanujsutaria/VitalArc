---
name: vitalarc-end-workstation
description: Finalize a VitalArc workstation development session. Use when ending a session on Mac. Verifies build passes, runs tests, commits documentation, and pushes changes.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
argument-hint: [summary]
---

# VitalArc Workstation Session End

Finalize a workstation session with build verification.

## Current State

- **Branch**: !`git rev-parse --abbrev-ref HEAD 2>/dev/null`
- **Commits today**: !`git log --oneline --since="6 hours ago" 2>/dev/null | head -5`
- **Uncommitted**: !`git status --short 2>/dev/null`

## Steps

### 1. Build check

**Do not proceed if build fails.** Fix issues first.

```bash
# Option 1: Use verification script
.claude/skills/_shared/scripts/verify-session.sh --require-build

# Option 2: Direct build check
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD)"
```

### 2. Run tests (optional)

```bash
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test 2>&1 | grep -E "(Test Case|passed|failed)"
```

### 3. Gather stats

```bash
git log --oneline --since="6 hours ago"
git diff --stat HEAD~10 2>/dev/null | tail -3
```

### 4. Update SESSION_LOG.md

Complete the current session's Work Log table and fill in sections using the template from [session-end.md](../_shared/templates/session-end.md):

```markdown
### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| ... | ... | ... | ... |
| [now] | Build verified | - | Passing |
| [now] | Session ended | - | [summary] |

### Work Completed
- [Features/fixes implemented]
- [UI changes verified in simulator]
- [Files modified]
- Commits: [list with hash and message]

### Session End
- **Time**: [end time]
- **Duration**: ~[N] hours (calculate from start time in session-state.json)
- **Status**: Complete / In Progress
- **Build**: Passing
- **Tests**: [N passed, N failed / Not run]
- **Commits**: [N] commits
- **Next**: [priorities from README Roadmap]
```

### 5. Update PROJECT_STATUS.md and README.md

If features changed:
- PROJECT_STATUS.md: Update "Last Updated", feature status, Known Issues, Codebase Stats
- README.md Roadmap: Move features between In Progress / Planned / Completed

### 6. Update state file

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
SESSION=$(echo "$BRANCH" | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f1)
cat > .claude/session-state.json << EOF
{"current_session":${SESSION:-0},"branch":"$BRANCH","platform":"mac","status":"completed","ended_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","build":"passing"}
EOF
```

### 7. Commit and push

```bash
git add SESSION_LOG.md PROJECT_STATUS.md README.md .claude/session-state.json
git commit -m "docs(session): update session [N] documentation

- [Summary from $ARGUMENTS]
- Build verified

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
```

### 8. Create PR (optional)

If ready for review:
```bash
gh pr create --title "<type>(<scope>): <description>" --body "## Summary
- [changes]

## Testing
- [x] Build passes locally
- [ ] CI passes
- [ ] Manual testing done

---
/vitalarc-end-workstation"
```

### 9. Output summary

```
═══════════════════════════════════════════════════════
       VITALARC WORKSTATION SESSION COMPLETE
═══════════════════════════════════════════════════════
Branch:   [branch]
Commits:  [N]
Build:    Passing
Tests:    [status]
Next:     [priorities]
═══════════════════════════════════════════════════════
```
