---
name: task-dashboard
description: Display real-time progress visualization during long operations. Shows task status, progress bars, and estimated completion. Use during feature planning, multi-file operations, or any long-running task.
context: fork
agent: general-purpose
allowed-tools: TaskList, TaskGet, Read
---

# Task Dashboard

Provides real-time progress visualization for task-based operations.

**Execution**: Runs in forked context with general-purpose agent (read-only).

## When to Use

- During long-running operations like `/feature-planner`
- When multiple tasks are being processed in parallel
- To check overall progress of a multi-step operation
- When user asks "what's the status?" or "how far along?"

## Implementation

### 1. Fetch Current Tasks

```javascript
// Get all tasks
TaskList()

// Returns:
// - id, subject, status, owner, blockedBy for each task
```

### 2. Calculate Progress

```javascript
const tasks = await TaskList()
const total = tasks.length
const completed = tasks.filter(t => t.status === "completed").length
const inProgress = tasks.filter(t => t.status === "in_progress").length
const pending = tasks.filter(t => t.status === "pending").length
const blocked = tasks.filter(t => t.blockedBy && t.blockedBy.length > 0).length

const progress = Math.round((completed / total) * 100)
```

### 3. Generate Visualization

```
═══════════════════════════════════════════════════════════════
               TASK PROGRESS: 3/5 (60%)
═══════════════════════════════════════════════════════════════
[████████████████████████░░░░░░░░░░░░░░░░] 60%
───────────────────────────────────────────────────────────────
Currently: Running tests
Pending: Generate commit, Push changes
───────────────────────────────────────────────────────────────
```

## Output Format

### Progress Dashboard

```markdown
## Task Dashboard

### Overall Progress
```
[████████████████████░░░░░░░░░░░░░░░░░░░░] 50%  5/10 tasks
```

### Current Status

| Status | Count | Tasks |
|--------|-------|-------|
| Completed | 5 | Analysis, Domain design, UI design, ... |
| In Progress | 2 | Test scaffolding, Build validation |
| Pending | 2 | Commit, Push |
| Blocked | 1 | Deploy (blocked by: Push) |

### Active Tasks

**Test scaffolding** (in_progress)
- Started: 2 minutes ago
- Description: Generate XCTest files for new feature...

**Build validation** (in_progress)
- Started: 1 minute ago
- Description: Running xcodebuild to verify...

### Task Graph

```
Analysis ✓ ─────┐
                ├─→ Domain ✓ ─────┐
Presentation ✓ ─┘                 │
                                  ├─→ Wiring ⏳ ─→ Tests ⏳ ─→ Commit ○
DI Analysis ✓ ────────────────────┘
```

**Legend**: ✓ completed | ⏳ in_progress | ○ pending | ⊘ blocked
```

### Compact Dashboard (for periodic updates)

```
Tasks: ████████░░░░ 67% (4/6) | Active: Build validation, Test scaffolding
```

### Detailed Task View

When drilling down into a specific task:

```markdown
## Task Detail: #5 - Generate test scaffolds

**Status**: in_progress
**Started**: 2 minutes ago
**Description**: Generate XCTest files for Achievement feature...

### Dependencies
- Blocked by: None
- Blocks: #6 (Compile feature plan)

### Progress Notes
- Mock classes created
- Entity tests generated
- ViewModel tests in progress
```

## Refresh Modes

| Mode | Usage | Update Frequency |
|------|-------|------------------|
| `--once` | Single snapshot | One time |
| `--watch` | Continuous updates | Every 5 seconds |
| `--compact` | Minimal output | Single line |

### Watch Mode

When using `--watch`, the dashboard refreshes:

```markdown
## Task Dashboard (Live - updating every 5s)

Last updated: 3:45:23 PM

[████████████████████████████░░░░░░░░░░░░] 70%  7/10 tasks

Active: Test scaffolding (2m 30s)
Next up: Commit generation

Press Ctrl+C to stop watching
```

## Integration Examples

### With Feature Planner

```javascript
// Feature planner launches dashboard in background
TaskCreate({
  subject: "Monitor feature planning progress",
  description: "Run task-dashboard --watch to show progress",
  activeForm: "Monitoring progress"
})
```

### Periodic Check During Long Operations

```javascript
// Check progress every 30 seconds
while (hasActiveTasks) {
  await sleep(30000)
  const status = await TaskList()
  displayCompactProgress(status)
}
```

## Error States

### No Active Tasks

```markdown
## Task Dashboard

**No active tasks found.**

Tasks are created automatically during operations like:
- `/feature-planner <feature>`
- `/vitalarc-start-workstation`
- `/design-system-fixer --all`

Run one of these to see task progress.
```

### Stalled Tasks

```markdown
## Task Dashboard

**Warning**: Task may be stalled

**Test scaffolding** (in_progress)
- Running for: 15 minutes
- Expected: ~2 minutes

Consider checking:
- Task may have encountered an error
- External process may have failed
- May need manual intervention
```

## ASCII Progress Bar Generator

```javascript
function progressBar(percent, width = 40) {
  const filled = Math.round((percent / 100) * width)
  const empty = width - filled
  return `[${'\u2588'.repeat(filled)}${'\u2591'.repeat(empty)}] ${percent}%`
}

// Output: [████████████████░░░░░░░░░░░░░░░░░░░░░░░░] 40%
```

## Task Status Icons

| Status | Icon | Meaning |
|--------|------|---------|
| completed | ✓ | Task finished successfully |
| in_progress | ⏳ | Task currently running |
| pending | ○ | Task waiting to start |
| blocked | ⊘ | Task waiting on dependencies |
