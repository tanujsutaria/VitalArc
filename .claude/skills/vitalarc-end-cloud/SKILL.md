---
name: vitalarc-end-cloud
description: Finalize a VitalArc cloud development session. Use when ending a session started from phone or browser. Commits documentation, pushes changes, no build verification.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
argument-hint: [summary]
---

# VitalArc Cloud Session End

Finalize a cloud session. No build verification—CI will validate.

## Current State

- **Branch**: !`git rev-parse --abbrev-ref HEAD 2>/dev/null`
- **Commits today**: !`git log --oneline --since="6 hours ago" 2>/dev/null | head -5`
- **Uncommitted**: !`git status --short 2>/dev/null`

## Steps

### 1. Gather stats

```bash
git log --oneline --since="6 hours ago"
git diff --stat HEAD~10 2>/dev/null | tail -3
```

### 2. Update SESSION_LOG.md

Complete the current session's Work Log table and fill in sections:

```markdown
### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| ... | ... | ... | ... |
| [now] | Session ended | - | [summary] |

### Work Completed
- [What was done]
- [Files modified]
- Commits: [list with hash and message]

### Session End
- **Time**: [end time]
- **Duration**: ~[N] min (calculate from start time in session-state.json)
- **Status**: Complete / In Progress / Needs Workstation
- **Build**: ⏭️ Not verified (cloud)
- **Tests**: N/A (cloud)
- **Commits**: [N] commits
- **Next**: [priorities from README Roadmap, or "Verify on workstation" if UI changes]
```

Use status **Needs Workstation** if changes require UI or build verification.

### 3. Update PROJECT_STATUS.md and README.md

If features changed:
- PROJECT_STATUS.md: Update "Last Updated", Known Issues, feature status
- README.md Roadmap: Move features between In Progress ↔ Planned as needed

### 4. Update state file

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
SESSION=$(echo "$BRANCH" | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f1)
cat > .claude/session-state.json << EOF
{"current_session":${SESSION:-0},"branch":"$BRANCH","platform":"cloud","status":"completed","ended_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
EOF
```

### 5. Commit and push

```bash
git add SESSION_LOG.md PROJECT_STATUS.md README.md .claude/session-state.json
git commit -m "docs(session): update session [N] documentation

- [Summary from $ARGUMENTS]
- Cloud session (build not verified)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
```

### 6. Create PR (optional)

If ready for review:
```bash
gh pr create --title "<type>(<scope>): <description>" --body "## Summary
- [changes]

## Testing
- [ ] CI build passes
- [ ] ⚠️ Cloud session—manual testing recommended

---
/vitalarc-end-cloud ☁️"
```

### 7. Output summary

```
═══════════════════════════════════════════════════════
           VITALARC CLOUD SESSION COMPLETE ☁️
═══════════════════════════════════════════════════════
Branch:   [branch]
Commits:  [N]
Build:    ⏭️ Not verified
Status:   [Complete / Needs Workstation]
Next:     [priorities]
═══════════════════════════════════════════════════════
```
