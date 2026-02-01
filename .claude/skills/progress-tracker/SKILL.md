---
name: progress-tracker
description: Track and update the SESSION_LOG.md Work Log table during development. Use automatically when significant work is completed, files are modified, or milestones are reached. Keeps the session log current without manual intervention.
context: fork
agent: general-purpose
allowed-tools: Read, Edit, Grep, Glob, TaskList, TaskUpdate
---

# Progress Tracker Agent

Maintains the SESSION_LOG.md Work Log table in real-time during development sessions.

**Execution**: Runs in forked context with general-purpose agent for file edits.

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

## Integration with Task System

When tasks are active, progress-tracker also updates task metadata:

### Sync Task Progress with Work Log

```javascript
// After updating Work Log, also update any related tasks
const tasks = await TaskList()
const activeTasks = tasks.filter(t => t.status === "in_progress")

// Find tasks related to current work
activeTasks.forEach(task => {
  if (isRelatedToCurrentWork(task, workLogEntry)) {
    TaskUpdate({
      taskId: task.id,
      metadata: {
        lastWorkLogEntry: workLogEntry.time,
        workLogNotes: workLogEntry.notes
      }
    })
  }
})
```

### Auto-Complete Related Tasks

When logging "Feature complete" or "Build verified":

```javascript
// If work log indicates completion, mark related task complete
if (workLogEntry.action.includes("completed") ||
    workLogEntry.action.includes("verified")) {

  const relatedTask = findRelatedTask(workLogEntry)
  if (relatedTask) {
    TaskUpdate({
      taskId: relatedTask.id,
      status: "completed"
    })
  }
}
```

### Task-Aware Work Log Updates

When updating the Work Log, check if tasks exist:

```javascript
// Read current tasks
const tasks = await TaskList()

// If tasks exist, include progress summary
if (tasks.length > 0) {
  const completed = tasks.filter(t => t.status === "completed").length
  const total = tasks.length

  // Add task progress to Work Log notes
  workLogEntry.notes += ` (Tasks: ${completed}/${total})`
}
```

### Example Output with Task Integration

```markdown
### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| 7:30 PM | Session started | - | Focus: notifications |
| 7:45 PM | Domain design complete | Notification.swift | Tasks: 2/5 |
| 8:00 PM | UI layer complete | NotificationView.swift | Tasks: 3/5 |
| 8:15 PM | Tests generated | NotificationTests.swift | Tasks: 4/5 |
| 8:30 PM | Build verified | - | Tasks: 5/5, all complete |
```

This keeps the Work Log and task system synchronized.

## Issue Resolution Tracking (CRITICAL)

**When logging work that fixes a Known Issue, you MUST update PROJECT_STATUS.md.**

### Issue Resolution Detection

Check if the completed work resolves a documented issue:

```javascript
// After logging work, check if it resolves a Known Issue
const workDescription = workLogEntry.action + " " + workLogEntry.notes;
const projectStatus = await Read("PROJECT_STATUS.md");

// Known issue patterns to match
const issuePatterns = [
  { pattern: /test.*integrat|cloud.*test/i, issue: "Cloud test files need integration" },
  { pattern: /design.*system.*violation|token.*migration/i, issue: "Design system violations" },
  { pattern: /api.*key|nutritionix|usda/i, issue: "API keys not configured" },
  { pattern: /build.*fix|compile.*error/i, issue: "Build errors" },
];

// Check for matches
issuePatterns.forEach(({ pattern, issue }) => {
  if (pattern.test(workDescription)) {
    // Check if this issue exists in PROJECT_STATUS.md Known Issues
    if (projectStatus.includes(issue)) {
      console.log(`ISSUE RESOLVED: "${issue}" - Update PROJECT_STATUS.md`);
      // Flag for update
    }
  }
});
```

### Auto-Update PROJECT_STATUS.md

When an issue is resolved:

1. **Remove from Known Issues section**:
```markdown
// Before:
### Known Issues
- Cloud test files (~15) need integration
- Design system gaps (4 violations)

// After (if cloud tests integrated):
### Known Issues
- Design system gaps (4 violations)
```

2. **Add to Recent Accomplishments**:
```markdown
### Recent Accomplishments (Session 16.3)
- Integrated 15 cloud test files (535 tests now passing)
```

### Implementation

```javascript
async function resolveKnownIssue(issueSummary, resolution) {
  // 1. Read PROJECT_STATUS.md
  const content = await Read("PROJECT_STATUS.md");

  // 2. Find and remove from Known Issues
  const knownIssuesSection = content.match(/### Known Issues[\s\S]*?(?=###|$)/);
  if (knownIssuesSection) {
    const updatedSection = knownIssuesSection[0]
      .split('\n')
      .filter(line => !line.includes(issueSummary))
      .join('\n');

    // 3. Add to Recent Accomplishments
    const accomplishment = `- ${resolution} (resolved Known Issue)`;

    // 4. Write updates
    await Edit({
      file_path: "PROJECT_STATUS.md",
      // Remove from Known Issues, add to Accomplishments
    });
  }

  // 5. Log in Work Log
  workLogEntry.notes += " [RESOLVED KNOWN ISSUE]";
}
```

### Verification Checklist

Before marking an issue as resolved, VERIFY:

| Issue Type | Verification Command |
|------------|---------------------|
| Test integration | `xcodebuild test ... \| grep "Executed .* tests"` |
| Design system | `grep -r "Color\.(red\|blue)" Presentation/Tabs/` |
| Build errors | `xcodebuild build ... \| grep "BUILD SUCCEEDED"` |
| API configuration | Check actual API response, not just file content |

**NEVER mark an issue resolved based only on documentation. Always verify against actual codebase state.**

### Example: Resolving Cloud Test Integration

```markdown
// Work Log Entry:
| 8:30 PM | Integrated cloud tests | 15 test files | 535 tests passing [RESOLVED KNOWN ISSUE] |

// PROJECT_STATUS.md Update:
// Remove: "- Cloud test files (~15) need integration"
// Add to accomplishments: "- Integrated 15 cloud test files (535 tests passing)"
```
