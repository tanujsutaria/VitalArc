---
name: vitalarc-end
description: Finalize a VitalArc development session - update logs, verify builds, commit documentation, push changes, summarize work
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
argument-hint: [commit-message-summary]
disable-model-invocation: true
---

# VitalArc Session Finalization

You are ending a development session for the VitalArc iOS fitness app.

## Platform Detection

Detect the current platform and working directory:

```bash
# Detect platform
PLATFORM=$(uname -s)
if [ "$PLATFORM" = "Darwin" ]; then
    PLATFORM_SHORT="mac"
    PLATFORM_NAME="macOS (local)"
else
    PLATFORM_SHORT="cloud"
    PLATFORM_NAME="Linux (cloud)"
fi
echo "Platform: $PLATFORM_NAME"
echo "Working Directory: $(pwd)"
```

**Important**: All commands in this skill should be run from the repository root. The skill works on:
- **macOS (local)**: Developer's local machine
- **Linux/Cloud**: Claude Code cloud environment or CI/CD

## Session Summary (Auto-Fetched)

- **Platform**: !`uname -s | sed 's/Darwin/macOS (local)/;s/Linux/Linux (cloud)/'`
- **Working Directory**: !`pwd`
- **Current Branch**: !`git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "Not in git repo"`
- **Recent Commits**:
!`git log --oneline --since="6 hours ago" 2>/dev/null || git log --oneline -5`
- **Current Status**:
!`git status --short 2>/dev/null || echo "Not in git repo"`
- **Files Changed**:
!`git diff --stat HEAD~5 2>/dev/null | tail -5`

## Phase 1: Verify Build Status

**Note**: Build verification is only available on macOS with Xcode installed.

```bash
PLATFORM=$(uname -s)
if [ "$PLATFORM" = "Darwin" ]; then
    echo "Running build verification on macOS..."
    xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|warning:|BUILD SUCCEEDED|BUILD FAILED)" | head -30
else
    echo "Skipping build verification - not running on macOS"
    echo "Build verification requires macOS with Xcode"
    echo "Note: CI/CD will verify build when PR is created"
fi
```

If build fails (on macOS), report errors but continue with documentation.

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
   - **Platform**: [macOS (local) / Linux (cloud)]
   - **Status**: [Summary of what was accomplished]
   - **Build Status**: [Passing / Failing with reason / Skipped (cloud environment)]
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

If there are staged changes, commit using **Conventional Commits** format:

```bash
git commit -m "docs(session): update session [N] documentation

- [Summary of session work or $ARGUMENTS]
- Platform: [macOS/cloud]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

### Conventional Commits Reference

All commits should follow the format: `<type>(<scope>): <description>`

**Types:**
- `feat` - New feature or functionality
- `fix` - Bug fix
- `docs` - Documentation only changes
- `style` - Code style (formatting, whitespace)
- `refactor` - Code change that neither fixes nor adds features
- `perf` - Performance improvement
- `test` - Adding or updating tests
- `build` - Build system or dependency changes
- `chore` - Other maintenance tasks

**Scopes (optional):**
- `session` - Session documentation
- `workout` - Workout feature
- `nutrition` - Nutrition feature
- `health` - Health dashboard
- `analytics` - Analytics feature
- `ui` - Design system / UI components
- `infra` - Infrastructure / dependencies

**Examples:**
```
feat(workout): add custom exercise creation
fix(nutrition): correct calorie calculation for meals
docs(session): update session 8 documentation
refactor(ui): migrate ProfileView to design tokens
chore: update Swift package dependencies
```

## Phase 7: Push Feature Branch to Remote

Push the feature branch:

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push -u origin "$BRANCH"
```

Report push status. If push fails due to network errors, retry up to 4 times with exponential backoff (2s, 4s, 8s, 16s).

## Phase 7.5: Create Pull Request (Optional)

If the session's work is ready for review, create a PR to merge to main:

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Detect platform for PR body
PLATFORM=$(uname -s)
if [ "$PLATFORM" = "Darwin" ]; then
    PLATFORM_NAME="macOS (local)"
    BUILD_STATUS="Build verified locally"
else
    PLATFORM_NAME="Linux (cloud)"
    BUILD_STATUS="Build verification pending (CI/CD)"
fi

gh pr create --base main --head "$BRANCH" --title "<type>(<scope>): <description from $ARGUMENTS>" --body "## Summary
[Auto-generated from session work]

## Changes
- [List key changes from commits]

## Environment
- **Platform**: $PLATFORM_NAME
- **Build Status**: $BUILD_STATUS

## Testing
- [ ] Build passes (verified by CI)
- [ ] Manual testing completed

---
Generated by /vitalarc-end"
```

Use conventional commit format for PR title (e.g., `feat(workout): add template editor`).

If user prefers to continue work on the branch, skip PR creation and note that the branch is ready for future work.

## Phase 8: Generate Session Summary

Output a final session summary:

```
===========================================================
              VITALARC SESSION COMPLETE
===========================================================

ENVIRONMENT
  Platform: [macOS (local) / Linux (cloud)]
  Working Directory: [pwd]

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
  [Passing / Failing / Skipped (cloud - will verify via CI)]

PROJECT METRICS (updated)
  Design System Adoption: [X]%
  MVP Blockers Remaining: [count]
  TODOs Remaining: [count]

BRANCH STATUS
  Feature Branch: [branch name]
  Pushed to Remote: [Success / Failed]
  PR Created: [Yes with URL / No - continuing work]

NEXT SESSION PRIORITIES
  1. [priority 1]
  2. [priority 2]
  3. [priority 3]

PLATFORM NOTES
  [Any platform-specific notes, e.g., "Build skipped - verify on macOS or via CI"]

===========================================================
```

## Phase 9: Cleanup Reminders

Check for any cleanup needed:
- Unstaged files that might need attention
- Build warnings to address (if on macOS)
- TODO comments added this session
- Any temporary files to remove

Report any items needing attention next session.

## Final Checklist

Before confirming session end:
- [ ] Build passes or verified via CI (or noted as pending for cloud sessions)
- [ ] SESSION_LOG.md updated (includes platform info)
- [ ] PROJECT_STATUS.md updated (if needed)
- [ ] All documentation committed
- [ ] Feature branch pushed to remote
- [ ] PR created (if work is complete) or branch ready for continuation
- [ ] Next session priorities identified

Confirm session has been properly finalized.

## Platform-Specific Notes

| Platform | Build Verification | PR CI Check | Local Testing |
|----------|-------------------|-------------|---------------|
| macOS (local) | ✅ Available | ✅ Redundant | ✅ Available |
| Linux (cloud) | ❌ Skip | ✅ Required | ❌ Not available |

When on Linux/cloud:
- Build verification is skipped (no Xcode)
- CI/CD workflows will verify build on PR
- Mark build status as "Pending CI verification" in session log
- Consider running `/vitalarc-end` on macOS for full verification before merging
