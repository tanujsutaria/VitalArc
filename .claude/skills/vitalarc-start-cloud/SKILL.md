---
name: vitalarc-start-cloud
description: Initialize a VitalArc cloud development session. Use when starting work from phone or browser, or for bug fixes, documentation, and small targeted changes that don't require Xcode builds.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task, Skill, TaskCreate, TaskUpdate, TaskList
argument-hint: [focus-area]
---

# VitalArc Cloud Session Init

Start a cloud session optimized for phone/browser access. No Xcode builds available.

## Task Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CLOUD SESSION INITIALIZATION                      │
├─────────────────────────────────────────────────────────────────────┤
│  PHASE 1 - Git Sync (inline bash):                                  │
│    └── Sync with main, stash changes                                │
│                                                                      │
│  PHASE 2 - Session Number (inline bash):                            │
│    └── Parse SESSION_LOG.md → Calculate number                      │
│    ⚠️ MUST run inline - never delegate to subagent                  │
│                                                                      │
│  PHASE 3 - Use Platform-Provided Branch                             │
│                                                                      │
│  PHASE 4 - Restore Stash (inline bash)                              │
│                                                                      │
│  PHASE 5 - Focus + Parallel Skill:                             │
│    ├── Skill: focus-suggester            ─┐                            │
│    └── Skill('design-system-scanner') ─┘  Parallel                  │
│                                                                      │
│  PHASE 6 - Session Log (inline write, uses Phase 5 results)        │
│                                                                      │
│  PHASE 7 - Output Summary                                           │
└─────────────────────────────────────────────────────────────────────┘
```

**Note**: Build validation skipped (no Xcode on cloud).

## Execution Rules

Every phase has a **binding execution method**. Do not deviate.

| Phase | Method | Rationale |
|-------|--------|-----------|
| 1 - Git Sync | Inline bash | Deterministic git commands |
| 2 - Session Number | Inline bash | Deterministic; **must not delegate** |
| 3 - Branch | Platform-provided | Cloud branch format: `claude/vitalarc-start-cloud-<sessionID>` |
| 4 - Restore Stash | Inline bash | Simple git command |
| 5 - Focus/Scan | `Skill()` | focus-suggester + scan via Skill |
| 6 - Session Log | Inline Write/Edit | Template fill from Phase 5 results |
| 7 - Output Summary | Inline text | Display to user |

**Prohibitions:**
- **Do not use TaskCreate for operations that have dedicated skills.** Design system scanning has a dedicated skill (`design-system-scanner`). Invoke it via `Skill()`.
- **Do not delegate deterministic calculations to subagents.** Session number parsing, date arithmetic, and focus determination must run inline. Subagents (especially lighter models) can produce incorrect results for arithmetic and date logic.

## Implementation

### Phase 1: Git Sync (Inline Bash)

```bash
# Stash any uncommitted changes
[ -n "$(git status --porcelain)" ] && git stash push -m "Auto-stash $(date +%Y-%m-%d-%H%M)"

# Sync with main
git fetch origin && git checkout main && git pull origin main --ff-only
```

### Phase 2: Determine Session Number (Inline Bash)

**Run this inline. Never delegate to a subagent.**

**Session numbering rules:**
- **Major number** increments when the DATE changes
- **Minor version** increments for same-day sessions
- **Always include minor version** in format

```bash
TODAY=$(date +%Y-%m-%d)
LATEST_ENTRY=$(grep -E "^## Session [0-9]+\.[0-9]+ - " SESSION_LOG.md | head -1)
LATEST_MAJOR=$(echo "$LATEST_ENTRY" | sed -E 's/## Session ([0-9]+)\..*/\1/')
LATEST_MAJOR=${LATEST_MAJOR:-0}
LATEST_DATE_STR=$(echo "$LATEST_ENTRY" | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | head -1)

# Platform note: `date -d` is Linux-only (correct for cloud environments).
# For macOS, use `date -jf "%B %d, %Y"` instead.
LATEST_DATE=$(date -d "$LATEST_DATE_STR" +%Y-%m-%d 2>/dev/null || echo "")

if [ "$LATEST_DATE" = "$TODAY" ]; then
    SESSION=$LATEST_MAJOR
    MINOR=$(grep -cE "^## Session ${SESSION}\.[0-9]+ - " SESSION_LOG.md)
else
    SESSION=$((LATEST_MAJOR + 1))
    MINOR=0
fi
FULL_SESSION="${SESSION}.${MINOR}"
```

**Validation**: After running, echo `$FULL_SESSION` to confirm correctness before proceeding.

### Phase 3: Use Platform-Provided Branch

> **Note**: Claude Code platform controls the branch name (format: `claude/vitalarc-start-cloud-<sessionID>`). Use the branch provided in the system instructions.

### Phase 4: Restore Stash (Inline Bash)

```bash
git stash list | grep -q "Auto-stash $(date +%Y-%m-%d)" && git stash pop
```

### Phase 5: Focus + Parallel Skill

Determine the session focus and invoke the design scan skill in parallel.

#### 5a. Focus (bash)

```bash
FOCUS="${ARGUMENTS:-session}"
echo "Requested focus: $FOCUS"
```

If no explicit focus was given (`FOCUS=session`), let `focus-suggester` recommend the highest-value area from the roadmap and recent history.

#### 5b. Parallel Skill Invocation

```javascript
// In a SINGLE message, invoke:
Skill('focus-suggester')        // agent: Explore - recommends focus from SESSION_LOG/PROJECT_STATUS/git
Skill('design-system-scanner')  // agent: Explore - scans Modules/*/Presentation for violations
                                // Report-only for cloud (awareness, no fixing)
```

Save the focus-suggester output for Phase 6 (session log) and Phase 7 (summary). Wait for both skills to complete before proceeding to Phase 6.

### Phase 6: Create Session Log (Inline Write/Edit)

Using results from focus-suggester and design scan, write the session log entry directly. Do not delegate this to a TaskCreate.

Use the Write or Edit tool to prepend/append the following template to SESSION_LOG.md, filled with actual values:

```markdown
## Session [FULL_SESSION] - [Month Day, Year] ([Time])

### Session Start
- **Time**: [Time] UTC
- **Platform**: cloud
- **Focus**: [FOCUS from arguments or focus-suggester recommendation]
- **Branch**: [BRANCH]
- **Base**: main @ [latest commit]

### Environment
- **Build Capable**: No
- **Test Capable**: No

### Pre-Session Status
- **Build**: Skipped (cloud)
- **Design Violations**: [count from design-system-scanner, for awareness]
- **Uncommitted Changes**: None

### Session Goals
1. [Top focus-suggester recommendation]
2. [Second recommendation, if any]

### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| [Time] | Session started | - | Cloud session |
```

### Phase 7: Output Summary

```
═══════════════════════════════════════════════════════════════
         VITALARC CLOUD SESSION INITIALIZED
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Session:  [FULL_SESSION]
Focus:    [focus area] + [N-1] more
───────────────────────────────────────────────────────────────
Best for: Bug fixes, docs, code review, small changes
═══════════════════════════════════════════════════════════════
```
