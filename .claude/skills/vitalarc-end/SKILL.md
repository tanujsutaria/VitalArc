---
name: vitalarc-end
description: Finalize a VitalArc development session - update logs, verify builds, commit documentation, push changes, summarize work
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
argument-hint: [commit-message-summary]
disable-model-invocation: true
---

# VitalArc Session Finalization

You are ending a development session for the VitalArc iOS fitness app.

## Session Summary (Auto-Fetched)

- **Recent Commits**:
!`cd /Users/tanujsutaria/Development/VitalArc && git log --oneline --since="6 hours ago" 2>/dev/null || git log --oneline -5`
- **Current Status**:
!`cd /Users/tanujsutaria/Development/VitalArc && git status --short`
- **Files Changed**:
!`cd /Users/tanujsutaria/Development/VitalArc && git diff --stat HEAD~5 2>/dev/null | tail -5`

## Phase 1: Verify Build Status

Run a full build to ensure codebase compiles:

```bash
cd /Users/tanujsutaria/Development/VitalArc
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|warning:|BUILD SUCCEEDED|BUILD FAILED)" | head -30
```

If build fails, report errors but continue with documentation.

## Phase 2: Gather Session Statistics

1. **Get commits made this session**:
   ```bash
   git log --oneline --since="6 hours ago"
   ```

2. **Count changes**:
   ```bash
   git diff --stat HEAD~10 2>/dev/null | tail -3
   ```

3. **Find files modified today**:
   ```bash
   find VitalArc -name "*.swift" -mtime 0 -type f 2>/dev/null | head -20
   ```

## Phase 3: Update SESSION_LOG.md

Read the current SESSION_LOG.md and update the most recent session entry:

1. Fill in the "Work Completed" section with:
   - Features implemented
   - Bugs fixed
   - Files created/modified
   - Commits made (with hashes)

2. Fill in the "Session End" section:
   ```markdown
   ### Session End
   - **Status**: [Summary of what was accomplished]
   - **Build Status**: [Passing / Failing with reason]
   - **Commits**: [Number] commits pushed
   - **Next Steps**: [What should be done next session]
   ```

## Phase 4: Update PROJECT_STATUS.md

Check if any status changes are needed:

1. Read current PROJECT_STATUS.md
2. Update any completed items (check boxes)
3. Update any metrics that changed:
   - Design system adoption %
   - Hardcoded violations count
   - Feature status
4. Update "Recent Commits" table with today's commits

## Phase 5: Update CLAUDE.md (if needed)

If any architectural changes were made:
1. Update architecture overview
2. Add any new key files
3. Update codebase statistics

## Phase 6: Stage and Commit Documentation

If there are uncommitted documentation changes:

```bash
git add SESSION_LOG.md PROJECT_STATUS.md CLAUDE.md EXECUTION_PLAN*.md 2>/dev/null
git status --short
```

If there are staged changes, commit them with $ARGUMENTS as the summary (or auto-generate):

```bash
git commit -m "Update session documentation

[Summary of session work or $ARGUMENTS]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

## Phase 7: Push to Remote

Push all changes:

```bash
git push origin main
```

Report push status.

## Phase 8: Generate Session Summary

Output a final session summary:

```
===========================================================
              VITALARC SESSION COMPLETE
===========================================================

SESSION SUMMARY
  Duration: [estimate based on commits]
  Commits: [count]
  Files Changed: [count]

WORK COMPLETED
  - [item 1]
  - [item 2]
  - [item 3]

COMMITS MADE
  [hash1] [message1]
  [hash2] [message2]

BUILD STATUS
  [Passing / Failing]

PROJECT METRICS (updated)
  Design System Adoption: [X]%
  MVP Blockers Remaining: [count]
  TODOs Remaining: [count]

PUSHED TO REMOTE
  [Success / Failed with reason]

NEXT SESSION PRIORITIES
  1. [priority 1]
  2. [priority 2]
  3. [priority 3]

===========================================================
```

## Phase 9: Cleanup Reminders

Check for any cleanup needed:
- Unstaged files that might need attention
- Build warnings to address
- TODO comments added this session
- Any temporary files to remove

Report any items needing attention next session.

## Final Checklist

Before confirming session end:
- [ ] Build passes (or failures documented)
- [ ] SESSION_LOG.md updated
- [ ] PROJECT_STATUS.md updated (if needed)
- [ ] All documentation committed
- [ ] Changes pushed to remote
- [ ] Next session priorities identified

Confirm session has been properly finalized.
