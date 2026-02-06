---
name: vitalarc-start-workstation
description: Initialize a VitalArc workstation development session. Use when starting work on Mac for feature development, UI changes, large refactors, or any work requiring Xcode builds and simulator testing.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task, TaskCreate, TaskUpdate, TaskList
argument-hint: [focus-area]
---

# VitalArc Workstation Session Init

Start a full development session on Mac with Xcode builds and simulator access.

## Task Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SESSION INITIALIZATION PIPELINE                   │
├─────────────────────────────────────────────────────────────────────┤
│  PHASE 1 - Git Sync (Sequential - required first):                  │
│    └── Stash changes → Fetch/pull main                              │
│                                                                      │
│  PHASE 2 - Parallel Initialization (Maximum parallelization):       │
│    ├── Task: session-number-calc  ─┐                                │
│    ├── Task: focus-analysis        ├── ALL run in parallel          │
│    ├── Task: build-validation      │   (no interdependencies)       │
│    └── Task: design-system-scan   ─┘                                │
│                                                                      │
│  PHASE 3 - Branch Creation (needs session number only):             │
│    └── Create branch (blockedBy: session-number-calc)               │
│                                                                      │
│  PHASE 4 - Session Log (needs all Phase 2 results):                 │
│    └── Task: create-session-log (blockedBy: ALL Phase 2 tasks)      │
└─────────────────────────────────────────────────────────────────────┘
```

**Optimization**: Session number calculation now runs in parallel with other tasks, reducing total init time.

## Implementation

### Phase 1: Git Sync (Sequential - Required First)

Execute these git commands before spawning any tasks:

```bash
# Stash any uncommitted changes
[ -n "$(git status --porcelain)" ] && git stash push -m "Auto-stash $(date +%Y-%m-%d-%H%M)"

# Sync with main
git fetch origin && git checkout main && git pull origin main --ff-only
```

### Phase 2: Parallel Task Initialization (Maximum Parallelization)

Launch these tasks in a single message for parallel execution.

This enables true parallel execution - session number calculation no longer blocks other tasks:

```javascript
// In a SINGLE message, create all four tasks:

// Task 1: Calculate session number (fast, enables branch creation)
TaskCreate({
  subject: "Calculate session number",
  description: `Determine next session number:
    1. Read SESSION_LOG.md to find latest session entry
    2. Apply rules:
       - Major number increments when DATE changes
       - Minor version increments for same-day sessions
       - Always include minor version (e.g., 13.0 not 13)
    3. Return: FULL_SESSION (e.g., "17.0") and TODAY date`,
  activeForm: "Calculating session number"
})
// Returns: task-session-id

// Task 2: Focus analysis (runs in parallel)
TaskCreate({
  subject: "Analyze focus areas for session",
  description: `Run focus-suggester analysis:
    1. Read PROJECT_STATUS.md and SESSION_LOG.md
    2. Score potential focus areas using priority rubric
    3. Return top 3 recommendations with scores
    Platform: workstation (all work types available)`,
  activeForm: "Analyzing focus areas"
})
// Returns: task-focus-id

// Task 3: Build validation (runs in parallel)
TaskCreate({
  subject: "Validate Xcode build",
  description: `Run build validation:
    1. Execute: xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|warning:|BUILD SUCCEEDED|BUILD FAILED)"
    2. Report: SUCCEEDED or FAILED with error count
    3. If FAILED, list top 3 errors`,
  activeForm: "Validating build"
})
// Returns: task-build-id

// Task 4: Design system scan (runs in parallel)
TaskCreate({
  subject: "Scan design system compliance",
  description: `Run design-system-scanner:
    1. Scan VitalArc/Presentation/ for design token violations
    2. Report summary: X color, Y spacing, Z typography violations
    3. List top 5 files by violation count`,
  activeForm: "Scanning design system"
})
// Returns: task-scan-id
```

### Phase 3: Create Branch (After Session Number Ready)

Once session number task completes, create the branch:

```javascript
// Blocked only by session number calculation (not by build/scan)
TaskCreate({
  subject: "Create development branch",
  description: `Create branch using session number from task:
    Format: dev/mac-<focus>-<session>.<minor>-YYYY-MM-DD
    FOCUS: ${ARGUMENTS:-session}
    Execute: git checkout -b "$BRANCH"`,
  activeForm: "Creating branch",
  addBlockedBy: ["task-session-id"]
})
// Returns: task-branch-id
```

### Phase 4: Restore Stash

```bash
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

### Phase 5: Create Session Log (After All Phase 2 Tasks)

After all parallel tasks complete, create the session log entry:

```javascript
TaskCreate({
  subject: "Create SESSION_LOG.md entry",
  description: `Create session entry with results from all parallel tasks:
    - Session: [from session-number task]
    - Branch: [from branch task]
    - Build status: [from build task]
    - Focus: [from focus task or user-specified]
    - Design violations: [from scan task]

    Use workstation template format.`,
  activeForm: "Creating session log",
  addBlockedBy: ["task-session-id", "task-focus-id", "task-build-id", "task-scan-id", "task-branch-id"]
})
```

### Session Log Template

```markdown
## Session [FULL_SESSION] - [Month Day, Year] ([Time])

### Session Start
- **Time**: [Time] PST
- **Platform**: macOS
- **Focus**: [FOCUS or suggested focus]
- **Branch**: [BRANCH]
- **Base**: main @ [latest commit]

### Environment
- **Build Capable**: Yes
- **Test Capable**: Yes (unit + UI)

### Pre-Session Status
- **Build**: [from build-validator task]
- **Design Violations**: [from design-system-scanner task]
- **Uncommitted Changes**: None

### Session Goals
1. [Based on focus area]
2. [Secondary goal if applicable]
3. General development as directed

### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| [Time] | Session started | - | Build verified |
```

### Phase 7: Output Summary

```
═══════════════════════════════════════════════════════════════
       VITALARC WORKSTATION SESSION INITIALIZED
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Session:  [FULL_SESSION]
Build:    [status from task]
Focus:    [focus]
Violations: [count from scan task]
───────────────────────────────────────────────────────────────
Full builds, simulator, and testing available
═══════════════════════════════════════════════════════════════
```

## Error Handling

### Build Failed on Init

If build-validation task reports FAILED:

```
═══════════════════════════════════════════════════════════════
       ⚠️ SESSION STARTED WITH BUILD ERRORS
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Session:  [FULL_SESSION]
Build:    FAILED ([N] errors)
───────────────────────────────────────────────────────────────
Priority: Fix build before starting new work
═══════════════════════════════════════════════════════════════
```

### Task Timeout

If any parallel task doesn't complete within 2 minutes, proceed with available results and note the timeout in the session log.

## Options

| Option | Description |
|--------|-------------|
| `--worktree` | Create isolated worktree for this session |
| `--no-build` | Skip build validation (for quick starts) |

### Worktree Mode (`--worktree`)

When `--worktree` flag is provided, creates an isolated worktree before starting the session:

```javascript
// Step 0: Create worktree (before git sync)
// This runs FIRST, before any other operations

FOCUS="${ARGUMENTS:-session}"
BASE_DIR=$(dirname "$(pwd)")
WORKTREE_PATH="$BASE_DIR/VitalArc-$FOCUS"

// Check if worktree already exists
if [ -d "$WORKTREE_PATH" ]; then
    echo "Worktree exists at $WORKTREE_PATH"
    echo "Use existing worktree or choose different focus name."
    exit 1
fi

// Calculate session number first (needed for branch name)
TODAY=$(date +%Y-%m-%d)
SESSION_INFO=$(determine_session_number)  // From Phase 2 logic
BRANCH="dev/mac-$FOCUS-${SESSION_INFO.session}.${SESSION_INFO.minor}-$TODAY"

// Create worktree
git worktree add "$WORKTREE_PATH" -b "$BRANCH" main

// Output worktree info
echo "Created worktree: $WORKTREE_PATH"
echo "Branch: $BRANCH"
echo ""
echo "IMPORTANT: Open a new terminal and run:"
echo "  cd $WORKTREE_PATH"
echo "  # Then continue session init in new location"
```

**Worktree Output Summary**:

```
═══════════════════════════════════════════════════════════════
       VITALARC WORKTREE SESSION INITIALIZED
═══════════════════════════════════════════════════════════════
Worktree: /Users/user/Development/VitalArc-nutrition
Branch:   dev/mac-nutrition-17.0-2026-02-01
Session:  17.0
Build:    [status]
Focus:    nutrition
───────────────────────────────────────────────────────────────
NEXT STEPS:
1. Open new terminal
2. cd /Users/user/Development/VitalArc-nutrition
3. Continue development in isolated worktree
═══════════════════════════════════════════════════════════════
```

### Benefits of Worktree Mode

- **Parallel Development**: Work on multiple features simultaneously
- **No Branch Switching**: Each worktree has its own branch
- **Isolated Changes**: Changes in one worktree don't affect others
- **Easy Cleanup**: Remove worktree after PR merge

### When to Use Worktree Mode

- Starting a new feature while another is in review
- Need to make urgent fixes while feature work is in progress
- Want to experiment without affecting main development
- Running parallel sessions for different focus areas
