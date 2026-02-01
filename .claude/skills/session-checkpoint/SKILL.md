---
name: session-checkpoint
description: Mid-session verification of progress toward session goals. Validates build, checks uncommitted changes, and assesses goal completion. Use periodically during long sessions.
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob, Bash, TaskList
---

# Session Checkpoint

Provides mid-session verification of progress toward session goals. Use during long sessions to ensure you're on track.

**Execution**: Runs in forked context with Explore agent (read-only analysis).

## When to Use

- Periodically during long development sessions (every 1-2 hours)
- Before taking a break
- When unsure about progress toward goals
- When session feels scattered or unfocused
- When user asks "how are we doing?" or "what's our progress?"

## Implementation

### 1. Read Session Goals

```bash
# Find current session in SESSION_LOG.md
SESSION_ENTRY=$(grep -A 50 "^## Session [0-9]\+\.[0-9]\+ - " SESSION_LOG.md | head -60)

# Extract goals
GOALS=$(echo "$SESSION_ENTRY" | grep -A 10 "### Session Goals" | grep "^[0-9]\.")
```

### 2. Check Build Status

```bash
# Quick build check
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(BUILD SUCCEEDED|BUILD FAILED|error:)"
```

### 3. Check Uncommitted Changes

```bash
# Get changed files
git status --short

# Get diff summary
git diff --stat
```

### 4. Review Work Log

```bash
# Count work log entries for current session
WORK_ENTRIES=$(echo "$SESSION_ENTRY" | grep -c "^|.*|.*|.*|$")
```

### 5. Check Active Tasks

```javascript
// Get task status
const tasks = await TaskList()
const completed = tasks.filter(t => t.status === "completed").length
const inProgress = tasks.filter(t => t.status === "in_progress").length
const pending = tasks.filter(t => t.status === "pending").length
```

## Output Format

### Checkpoint Report

```markdown
## Session Checkpoint

**Session**: 17.0 - February 1, 2026
**Duration**: 1h 45m (started 2:30 PM)
**Focus**: Nutrition feature

---

### Goal Progress

| # | Goal | Status | Notes |
|---|------|--------|-------|
| 1 | Implement meal logging | In Progress | Core logic done, UI pending |
| 2 | Add calorie calculations | Complete | Verified with tests |
| 3 | Connect to food API | Not Started | Blocked on API key |

**Overall**: 1/3 goals complete (33%)

---

### Build Status
**Current**: Passing
**Last verified**: 10 minutes ago

---

### Uncommitted Changes

**Files**: 8 modified, 2 new
**Lines**: +450, -32

| Status | File | Notes |
|--------|------|-------|
| M | NutritionView.swift | Main UI |
| M | NutritionViewModel.swift | State management |
| M | MealLogUseCase.swift | Business logic |
| A | FoodSearchView.swift | New view |
| A | FoodSearchViewModel.swift | New ViewModel |

---

### Work Log Summary

**Entries**: 5 since session start

| Time | Action |
|------|--------|
| 2:30 PM | Session started |
| 2:45 PM | Created domain models |
| 3:15 PM | Implemented use cases |
| 3:45 PM | Built UI components |
| 4:00 PM | Added calorie calculations |

---

### Task Progress

```
[████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 30%  3/10 tasks
```

**Active**: UI implementation
**Next**: API integration

---

### Recommendations

1. **Commit current work** - 8 files with ~450 lines is getting large
2. **Consider breaking session** - 1h 45m, good stopping point
3. **API key needed** - Goal 3 blocked, may need to deprioritize

---

### Health Check

| Metric | Status |
|--------|--------|
| Build | Passing |
| Tests | Not run since start |
| Uncommitted size | Large (consider commit) |
| Session duration | Normal |
| Focus alignment | Good |
```

### Quick Checkpoint (Compact)

For rapid status check:

```markdown
## Quick Checkpoint

Session 17.0 | 1h 45m | Focus: Nutrition

Goals: 1/3 complete | Build: Passing | Changes: 8 files (+450/-32)

**Status**: On track, consider committing soon
```

### Warning States

#### Large Uncommitted Changes

```markdown
## Session Checkpoint

**Warning: Large uncommitted changes**

Files: 15 modified, 5 new
Lines: +1,200, -89

**Recommendation**: Commit incrementally to avoid:
- Large, hard-to-review PRs
- Risk of losing work
- Merge conflicts

Consider splitting into logical commits:
1. Domain layer changes
2. UI implementation
3. Test additions
```

#### Build Broken

```markdown
## Session Checkpoint

**Warning: Build is FAILING**

Errors: 3

1. ProfileView.swift:45 - Cannot find 'UserProfile' in scope
2. NutritionVM.swift:89 - Missing argument for 'repository'
3. ...

**Recommendation**: Fix build errors before continuing.
The longer you work with a broken build, the harder debugging becomes.
```

#### Off-Focus Work

```markdown
## Session Checkpoint

**Warning: Work may be off-focus**

**Session Focus**: Nutrition feature
**Recent Work**: Profile refactoring, Settings updates

Recent work appears unrelated to session goals.

**Options**:
1. Return to nutrition focus
2. Update session goals to reflect actual work
3. Create separate branch for side work
```

#### Long Session

```markdown
## Session Checkpoint

**Warning: Extended session**

Duration: 4h 30m

Long sessions can lead to:
- Decreased productivity
- Accumulated technical debt
- Large, hard-to-review changes

**Recommendation**: Consider ending session:
1. Commit current work
2. Run `/vitalarc-end-workstation`
3. Take a break
4. Start fresh session for remaining work
```

## Integration with Session Workflow

### Auto-Checkpoint

Some skills can auto-invoke checkpoint:

```javascript
// After significant milestone
if (milestoneReached) {
  // Run checkpoint
  await runSkill("session-checkpoint")
}
```

### Scheduled Reminders

The session could remind for checkpoint:

```markdown
**Session Reminder**: 2 hours since last checkpoint

Run `/session-checkpoint` to review progress.
```

## Best Practices

1. **Checkpoint every 1-2 hours** during active development
2. **Checkpoint before breaks** to capture progress
3. **Checkpoint when feeling stuck** to reassess priorities
4. **Act on recommendations** - checkpoints are only useful if you follow up
5. **Commit regularly** - don't let uncommitted changes grow too large
