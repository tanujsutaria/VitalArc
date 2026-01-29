---
name: progress-tracker
description: Track and update the SESSION_LOG.md Work Log table during development. Use automatically when significant work is completed, files are modified, or milestones are reached. Keeps the session log current without manual intervention.
maps-to-agent: general-purpose
allowed-tools: Read, Edit, Grep, Glob
---

# Progress Tracker Agent

Maintains the SESSION_LOG.md Work Log table in real-time during development sessions.

## When to Use

Auto-invoke when:
- A feature or fix is completed
- Multiple files have been modified
- A build or test passes/fails
- A commit is made
- Significant milestone reached
- User explicitly asks to update progress

## Work Log Table Format

```markdown
### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| 7:30 PM | Session started | - | Focus: notifications |
| 7:45 PM | Created NotificationManager | NotificationManager.swift | Basic structure |
| 8:00 PM | Added permission request | NotificationManager.swift, SettingsView.swift | Uses UNUserNotificationCenter |
| 8:15 PM | Build verified | - | Passing |
```

## Update Process

### 1. Read Current Session

Find the current session entry in SESSION_LOG.md (topmost entry).

### 2. Determine Action Type

| Action Type | When to Log |
|-------------|-------------|
| Feature added | New functionality implemented |
| Bug fixed | Issue resolved |
| Refactored | Code restructured without behavior change |
| Build verified | Successful xcodebuild |
| Tests passed/failed | Test run completed |
| Design system | Migrated to tokens |
| Committed | Git commit made |
| Session ended | Closing session |

### 3. Identify Changed Files

```bash
git diff --name-only HEAD~1  # Recent changes
git status --short           # Uncommitted changes
```

Summarize to key files (max 3-4), use "Multiple files" if >4.

### 4. Add Entry

Insert new row at the end of the Work Log table, before "Work Completed" section.

**Time format**: Use current time in user's timezone (e.g., "8:15 PM")

### 5. Example Updates

**After implementing a feature:**
```markdown
| 8:30 PM | Added notification scheduling | NotificationManager.swift | Workout reminders |
```

**After fixing a bug:**
```markdown
| 9:00 PM | Fixed calorie calculation | NutritionUseCase.swift | Off-by-one error |
```

**After design system migration:**
```markdown
| 9:15 PM | Migrated to Typography tokens | 5 view files | Removed hardcoded fonts |
```

**After build check:**
```markdown
| 9:30 PM | Build verified | - | Passing, 0 warnings |
```

## Notes Column Guidelines

Keep notes concise (< 50 chars):
- Describe the "what" or "why"
- Include key technical detail if relevant
- Use sentence fragments, not full sentences

Good: "Added UNUserNotificationCenter support"
Bad: "I added support for the UNUserNotificationCenter framework to enable local notifications"

## Integration with Session Workflow

This agent works alongside:
- `/vitalarc-start-*` - Creates initial Work Log entry
- `/vitalarc-end-*` - Adds final entries, completes session

The main orchestrator should invoke this agent after significant work blocks.
