---
name: sprint-launcher
description: Launch a parallel development sprint. Creates domain branches, worktrees, agent team, and assigns beads from the backlog.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task, Skill, AskUserQuestion, TeamCreate, SendMessage, TaskCreate, TaskUpdate, TaskList
argument-hint: [--domains=workout,nutrition,wellness,shared] [--beads-per-domain=N]
---

# Sprint Launcher

Launch a parallel development sprint with domain worktrees and agent teams.

## Overview

Standard entry point for shipping multiple features in parallel. Creates domain branches, worktrees, spawns agent teams, and assigns beads from the backlog.

## Git Branching Model

```
main (stable trunk)
├── dev/mac-workout-<session>-YYYY-MM-DD     (domain integration branch)
├── dev/mac-nutrition-<session>-YYYY-MM-DD   (domain integration branch)
├── dev/mac-wellness-<session>-YYYY-MM-DD    (domain integration branch)
└── dev/mac-shared-<session>-YYYY-MM-DD      (domain integration branch)
```

Each domain gets **one worktree** (at `../VitalArc-<domain>`). Multiple beads per domain are committed sequentially within that worktree.

## Execution Phases

```
Phase 1: Session number (inline bash, never delegate)
Phase 2: Beads backlog query (bd ready --json per type, score and rank)
Phase 3: Bead selection (AskUserQuestion — grouped by domain, user picks)
Phase 4: Domain branch creation (sequential bash — create + push each branch from main)
Phase 5: Worktree creation (parallel bash — one worktree per active domain)
  - Copy Secrets.swift to each worktree (it's gitignored)
Phase 6: Team creation (TeamCreate + Task per domain worker)
  - Each worker prompt includes: worktree path, bead IDs, domain rules, test requirements
Phase 7: Session log entry
Phase 8: Sprint dashboard output
```

## Implementation

### Phase 1: Session Number (Inline Bash)

**Run inline. Never delegate to a subagent.**

```bash
TODAY=$(date +%Y-%m-%d)

LATEST_ENTRY=$(grep -E "^## Session [0-9]+\.[0-9]+ - " SESSION_LOG.md | head -1)
LATEST_MAJOR=$(echo "$LATEST_ENTRY" | sed -E 's/## Session ([0-9]+)\..*/\1/')
LATEST_MAJOR=${LATEST_MAJOR:-0}
LATEST_DATE_STR=$(echo "$LATEST_ENTRY" | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | head -1)
LATEST_DATE=$(date -jf "%B %d, %Y" "$LATEST_DATE_STR" +%Y-%m-%d 2>/dev/null || echo "")

if [ "$LATEST_DATE" = "$TODAY" ]; then
    SESSION=$LATEST_MAJOR
    MINOR=$(grep -cE "^## Session ${SESSION}\.[0-9]+ - " SESSION_LOG.md)
else
    SESSION=$((LATEST_MAJOR + 1))
    MINOR=0
fi

FULL_SESSION="${SESSION}.${MINOR}"
echo "Session: $FULL_SESSION"
```

### Phase 2: Beads Backlog Query

```bash
bd ready --json --sort=priority -n 15 --type=feature 2>/dev/null
bd ready --json --sort=priority -n 15 --type=bug 2>/dev/null
bd ready --json --sort=priority -n 15 --type=task 2>/dev/null
bd stats 2>/dev/null
```

When `--domains` flag is provided, filter by domain label:
```bash
bd ready --json --label-any <domain> --sort=priority -n 15 2>/dev/null
```

**Scoring rubric:**

| Factor | Score | JSON field |
|--------|-------|------------|
| Priority P0 | +10 | `priority: 0` |
| Priority P1 | +7 | `priority: 1` |
| Priority P2 | +4 | `priority: 2` |
| Priority P3 | +2 | `priority: 3` |
| Priority P4 | +1 | `priority: 4` |
| Type: bug | +5 | `issue_type: "bug"` |
| Type: task | +3 | `issue_type: "task"` |
| Type: feature | +2 | `issue_type: "feature"` |
| Blocks other issues | +3 | `dependent_count > 0` |
| Label matches domain | +4 | from `--label-any` filter |

### Phase 3: Bead Selection

Present the top-scored beads grouped by domain via `AskUserQuestion`. User picks beads per domain (4 options max per question, one question per domain).

### Phase 4: Domain Branch Creation

```bash
for domain in wellness workout nutrition shared; do
    git checkout -b "dev/mac-${domain}-${FULL_SESSION}-${TODAY}" main
    git push -u origin "dev/mac-${domain}-${FULL_SESSION}-${TODAY}"
    git checkout main
done
```

Only create branches for domains that have selected beads.

### Phase 5: Worktree Creation

```bash
BASE_DIR=$(dirname "$(pwd)")
for domain in wellness workout nutrition shared; do
    WORKTREE="$BASE_DIR/VitalArc-$domain"
    BRANCH="dev/mac-${domain}-${FULL_SESSION}-${TODAY}"
    git worktree add "$WORKTREE" "$BRANCH"
done

# Copy Secrets.swift to each worktree (gitignored)
SECRETS="VitalArc/Modules/Shared/Security/Secrets.swift"
if [ -f "$SECRETS" ]; then
    for domain in wellness workout nutrition shared; do
        cp "$SECRETS" "$BASE_DIR/VitalArc-$domain/$SECRETS"
    done
fi
```

### Phase 6: Team Creation

Use `TeamCreate` to create the sprint team, then spawn one `Task` per active domain using the appropriate domain agent type.

Each worker prompt must include:
- Worktree path
- Bead IDs to implement
- Domain rules from the agent definition
- Test requirements: write tests for new/changed code paths
- Protocol rule: update ALL conformances (including test mocks) when modifying protocols
- Bead workflow: `bd show <id>` → implement → test → commit → `bd close <id>` → message lead

### Phase 7: Session Log Entry

Write the sprint session entry to SESSION_LOG.md with the sprint beads table.

### Phase 8: Sprint Dashboard Output

```
═══════════════════════════════════════════════════════════════
       VITALARC SPRINT LAUNCHED
═══════════════════════════════════════════════════════════════
Session:     [FULL_SESSION]
Domains:     [N] active
Beads:       [N] assigned
Agents:      [N] spawned
───────────────────────────────────────────────────────────────
  Domain     │ Worktree              │ Beads │ Agent
─────────────┼───────────────────────┼───────┼────────────
  Wellness   │ ../VitalArc-wellness  │ [N]   │ wellness-dev
  Workout    │ ../VitalArc-workout   │ [N]   │ workout-dev
  Nutrition  │ ../VitalArc-nutrition │ [N]   │ nutrition-dev
  Shared     │ ../VitalArc-shared    │ [N]   │ shared-dev
═══════════════════════════════════════════════════════════════
```

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `--domains=<list>` | Comma-separated domains to include | All with ready beads |
| `--beads-per-domain=<N>` | Max beads to assign per domain | 4 |

## Error Handling

| Scenario | Behavior |
|----------|----------|
| `bd` not installed / fails | Warn, skip beads, ask user for custom focus |
| No ready issues | Show `bd stats`, ask user for custom focus |
| Worktree exists | AskUserQuestion: reuse existing or choose different name |
| Claim fails | Warn, proceed without claiming |
