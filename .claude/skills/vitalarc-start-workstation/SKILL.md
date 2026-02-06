---
name: vitalarc-start-workstation
description: Initialize a VitalArc workstation development session. Use when starting work on Mac for feature development, UI changes, large refactors, or any work requiring Xcode builds and simulator testing.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task, Skill, TaskCreate, TaskUpdate, TaskList
argument-hint: [focus-area]
---

# VitalArc Workstation Session Init

Start a full development session on Mac with Xcode builds and simulator access.

## Task Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SESSION INITIALIZATION PIPELINE                   │
├─────────────────────────────────────────────────────────────────────┤
│  PHASE 1 - Git Sync (inline bash):                                  │
│    └── Stash changes → Fetch/pull main                              │
│                                                                      │
│  PHASE 2 - Session Number + Branch (inline bash):                   │
│    └── Parse SESSION_LOG.md → Calculate number → Create branch      │
│    ⚠️ MUST run inline - never delegate to subagent                  │
│                                                                      │
│  PHASE 3 - Parallel Skill Invocations:                              │
│    ├── Skill('focus-suggester')       ─┐                            │
│    ├── Skill('build-validator')        ├── ALL run in parallel      │
│    └── Skill('design-system-scanner') ─┘                            │
│                                                                      │
│  PHASE 4 - Restore Stash (inline bash)                              │
│                                                                      │
│  PHASE 5 - Session Log (inline write, uses Phase 3 results)        │
│                                                                      │
│  PHASE 6 - Output Summary                                           │
└─────────────────────────────────────────────────────────────────────┘
```

## Execution Rules

Every phase has a **binding execution method**. Do not deviate.

| Phase | Method | Rationale |
|-------|--------|-----------|
| 1 - Git Sync | Inline bash | Deterministic git commands |
| 2 - Session Number + Branch | Inline bash | Deterministic; **must not delegate** |
| 3 - Focus/Build/Scan | `Skill()` tool | Reuses existing skills with correct agent types |
| 4 - Restore Stash | Inline bash | Simple git command |
| 5 - Session Log | Inline Write/Edit | Template fill from Phase 3 results |
| 6 - Output Summary | Inline text | Display to user |

**Prohibitions:**
- **Do not use TaskCreate for operations that have dedicated skills.** Focus analysis, build validation, and design system scanning each have dedicated skills (`focus-suggester`, `build-validator`, `design-system-scanner`). Invoke them via `Skill()`.
- **Do not delegate deterministic calculations to subagents.** Session number parsing and date arithmetic must run inline. Subagents (especially lighter models) can produce incorrect results for arithmetic and date logic.

## Implementation

### Phase 1: Git Sync (Inline Bash)

Execute these git commands directly before any other work:

```bash
# Stash any uncommitted changes
[ -n "$(git status --porcelain)" ] && git stash push -m "Auto-stash $(date +%Y-%m-%d-%H%M)"

# Sync with main
git fetch origin && git checkout main && git pull origin main --ff-only
```

### Phase 2: Session Number + Branch (Inline Bash)

**Run this inline. Never delegate to a subagent.**

Calculate the session number and create the branch in a single inline bash block:

```bash
TODAY=$(date +%Y-%m-%d)
FOCUS="${ARGUMENTS:-session}"

# Parse latest session entry from SESSION_LOG.md
LATEST_ENTRY=$(grep -E "^## Session [0-9]+\.[0-9]+ - " SESSION_LOG.md | head -1)
LATEST_MAJOR=$(echo "$LATEST_ENTRY" | sed -E 's/## Session ([0-9]+)\..*/\1/')
LATEST_MAJOR=${LATEST_MAJOR:-0}

# Extract and parse the date from the latest entry
# Format in log: "February 5, 2026" → need to compare with today
LATEST_DATE_STR=$(echo "$LATEST_ENTRY" | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | head -1)

# macOS date parsing (use -jf, NOT -d which is Linux-only)
LATEST_DATE=$(date -jf "%B %d, %Y" "$LATEST_DATE_STR" +%Y-%m-%d 2>/dev/null || echo "")

if [ "$LATEST_DATE" = "$TODAY" ]; then
    SESSION=$LATEST_MAJOR
    # Count existing entries for this session number today
    MINOR=$(grep -cE "^## Session ${SESSION}\.[0-9]+ - " SESSION_LOG.md)
else
    SESSION=$((LATEST_MAJOR + 1))
    MINOR=0
fi

FULL_SESSION="${SESSION}.${MINOR}"
BRANCH="dev/mac-${FOCUS}-${FULL_SESSION}-${TODAY}"

# Create the branch
git checkout -b "$BRANCH"
```

**Validation**: After running, echo `$FULL_SESSION` and `$BRANCH` to confirm correctness before proceeding.

### Phase 3: Parallel Skill Invocations

Invoke all three skills in a **single message** for parallel execution. Each skill has `context: fork` in its frontmatter and runs as an isolated subagent with the correct agent type.

```javascript
// In a SINGLE message, invoke all three:
Skill('focus-suggester')        // agent: Explore - reads PROJECT_STATUS + SESSION_LOG
Skill('build-validator')        // agent: Bash - runs xcodebuild
Skill('design-system-scanner')  // agent: Explore - scans Presentation/ for violations
```

Wait for all three to complete before proceeding to Phase 5.

### Phase 4: Restore Stash (Inline Bash)

```bash
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

### Phase 5: Create Session Log (Inline Write/Edit)

Using results from the three completed skills, write the session log entry directly. Do not delegate this to a TaskCreate.

Use the Write or Edit tool to prepend/append the following template to SESSION_LOG.md, filled with actual values:

```markdown
## Session [FULL_SESSION] - [Month Day, Year] ([Time])

### Session Start
- **Time**: [Time] PST
- **Platform**: macOS
- **Focus**: [FOCUS or suggested focus from focus-suggester]
- **Branch**: [BRANCH]
- **Base**: main @ [latest commit]

### Environment
- **Build Capable**: Yes
- **Test Capable**: Yes (unit + UI)

### Pre-Session Status
- **Build**: [from build-validator result]
- **Design Violations**: [from design-system-scanner result]
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

### Phase 6: Output Summary

```
═══════════════════════════════════════════════════════════════
       VITALARC WORKSTATION SESSION INITIALIZED
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Session:  [FULL_SESSION]
Build:    [status from build-validator]
Focus:    [focus]
Violations: [count from design-system-scanner]
───────────────────────────────────────────────────────────────
Full builds, simulator, and testing available
═══════════════════════════════════════════════════════════════
```

## Error Handling

### Build Failed on Init

If build-validator reports FAILED:

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

### Skill Timeout

If any skill doesn't complete within 2 minutes, proceed with available results and note the timeout in the session log.

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
