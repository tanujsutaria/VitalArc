---
name: sprint-status
description: Show sprint progress — beads status, worktree diffs, build status per domain.
context: fork
agent: Explore
allowed-tools: Read, Bash, Grep, Glob
---

# Sprint Status

Quick read-only dashboard showing sprint progress across domain worktrees.

## Overview

Shows per-domain progress: commits ahead of main, bead status, and build status. Use during a sprint to check how each domain is progressing.

## Implementation

### Step 1: Detect Active Worktrees

```bash
git worktree list
```

Identify VitalArc-* worktrees (wellness, workout, nutrition, shared).

### Step 2: Per-Domain Status

For each active worktree:

```bash
BASE_DIR=$(dirname "$(pwd)")
for domain in wellness workout nutrition shared; do
    WORKTREE="$BASE_DIR/VitalArc-$domain"
    if [ -d "$WORKTREE" ]; then
        echo "=== $domain ==="
        echo "Branch: $(git -C "$WORKTREE" rev-parse --abbrev-ref HEAD)"
        echo "Commits: $(git -C "$WORKTREE" log --oneline main..HEAD | wc -l | tr -d ' ')"
        echo "Status: $(git -C "$WORKTREE" status --porcelain | wc -l | tr -d ' ') uncommitted"
        git -C "$WORKTREE" log --oneline main..HEAD
        echo
    fi
done
```

### Step 3: Beads Status

```bash
bd list --status=in_progress 2>/dev/null
```

### Step 4: Output Dashboard

```
═══════════════════════════════════════════════════════════════
       VITALARC SPRINT STATUS
═══════════════════════════════════════════════════════════════
  Domain     │ Branch              │ Commits │ Dirty │ Beads
─────────────┼─────────────────────┼─────────┼───────┼──────
  Wellness   │ dev/mac-wellness-.. │ 4       │ No    │ 3/4
  Workout    │ dev/mac-workout-..  │ 6       │ Yes   │ 4/4
  Nutrition  │ dev/mac-nutrition-..│ 2       │ No    │ 2/4
  Shared     │ dev/mac-shared-..   │ 0       │ No    │ 0/4
───────────────────────────────────────────────────────────────
In Progress: [beads list]
═══════════════════════════════════════════════════════════════
```
