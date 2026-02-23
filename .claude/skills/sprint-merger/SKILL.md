---
name: sprint-merger
description: Merge completed domain branches into main via PRs. Handles rebase, build verification, PR creation, and cleanup.
disable-model-invocation: true
allowed-tools: Read, Bash, Write, Edit, Skill, AskUserQuestion, SendMessage
argument-hint: [--domain=<name>|--all]
---

# Sprint Merger

Merge completed domain branches into main via PRs with build verification.

## Overview

Handles the merge pipeline at sprint end. Merges domains in isolation order (most isolated first) to minimize conflicts: **Wellness -> Workout -> Nutrition -> Shared**.

## Merge Order

```
Wellness  ──→  Workout  ──→  Nutrition  ──→  Shared
(most isolated)                              (most shared)
```

Each domain rebases on latest main after the prior domain merges. This prevents cascading conflicts.

## Execution Phases (Per Domain)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SPRINT MERGE PIPELINE                            │
├─────────────────────────────────────────────────────────────────────┤
│  Per domain (in merge order: wellness → workout → nutrition → shared)│
│                                                                      │
│  PHASE 1 - Verify Worktree Status                                  │
│    └── git status, uncommitted changes, bead closure check         │
│                                                                      │
│  PHASE 2 - Build + Test in Worktree                                │
│    └── Skill('build-validator'), Skill('test-runner')              │
│                                                                      │
│  PHASE 3 - Rebase on Latest Main                                   │
│    └── If prior domains already merged, rebase to pick them up     │
│                                                                      │
│  PHASE 4 - Push Domain Branch                                      │
│    └── git push -u origin <branch>                                 │
│                                                                      │
│  PHASE 5 - Create PR                                               │
│    └── gh pr create --base main, aggregate bead IDs in body        │
│                                                                      │
│  PHASE 6 - Wait for User Approval                                  │
│    └── AskUserQuestion: approve merge or skip domain               │
│                                                                      │
│  After all domains:                                                  │
│                                                                      │
│  PHASE 7 - Post-Merge Cleanup                                      │
│    └── Remove worktrees, delete remote branches, bd sync, build    │
└─────────────────────────────────────────────────────────────────────┘
```

## Implementation

### Phase 1: Verify Worktree Status

For each domain worktree, check:

```bash
BASE_DIR=$(dirname "$(pwd)")
WORKTREE="$BASE_DIR/VitalArc-<domain>"

# Check for uncommitted changes
git -C "$WORKTREE" status --porcelain

# Check current branch
git -C "$WORKTREE" rev-parse --abbrev-ref HEAD

# Count commits ahead of main
git -C "$WORKTREE" log --oneline main..HEAD
```

**If uncommitted changes exist**: Warn and ask user whether to commit them or discard.

**If no commits ahead of main**: Skip this domain (nothing to merge).

### Phase 2: Build + Test in Worktree

Run build and test validation in each worktree:

```bash
# Build in worktree
cd "$WORKTREE"
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD SUCCEEDED|BUILD FAILED)"
```

**If build fails**: Stop and report. Do not proceed with this domain's merge.

Run tests if build passes:
```bash
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test 2>&1 | grep -E "(Test Suite|Executed|error:|FAILED|PASSED)"
```

**If tests fail**: Report failures. Ask user whether to proceed anyway or fix first.

### Phase 3: Rebase on Latest Main

If prior domains have already merged to main, rebase this domain's branch:

```bash
cd "$WORKTREE"
git fetch origin main
git rebase origin/main
```

**If rebase conflicts**:
1. Report conflicting files
2. For `DependencyContainer.swift` conflicts: Accept theirs + note for shared-dev
3. For `project.pbxproj` conflicts: Accept theirs + run `xcodegen generate`
4. For other conflicts: Ask user for resolution strategy

### Phase 4: Push Domain Branch

```bash
cd "$WORKTREE"
git push -u origin "$(git rev-parse --abbrev-ref HEAD)" --force-with-lease
```

Use `--force-with-lease` since rebase may have rewritten history.

### Phase 5: Create PR

Create a PR for each domain branch:

```bash
BRANCH=$(git -C "$WORKTREE" rev-parse --abbrev-ref HEAD)
DOMAIN="<domain>"
BEAD_LIST="<comma-separated bead IDs>"

gh pr create \
  --base main \
  --head "$BRANCH" \
  --title "feat($DOMAIN): sprint <session> — <summary>" \
  --body "$(cat <<'EOF'
## Summary
Sprint <session> changes for the <domain> domain.

## Beads Completed
- [bead-id-1]: [title]
- [bead-id-2]: [title]

## Changes
- [List key changes per bead]

## Testing
- [x] Build passes in worktree
- [x] Tests pass in worktree
- [ ] CI passes

---
Sprint: <session> | Domain: <domain> | Merge Order: <N> of <total>

Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### Phase 6: Wait for User Approval

```
AskUserQuestion: "Merge <domain> PR #<number> to main?"
Options:
  - "Approve and merge" — merge PR, continue to next domain
  - "Skip this domain" — leave PR open, continue to next domain
  - "Stop merging" — halt the pipeline
```

If approved:
```bash
gh pr merge <number> --merge --delete-branch
```

### Phase 7: Post-Merge Cleanup (After All Domains)

```bash
# Return to main repo
cd /Users/tanujsutaria/Development/VitalArc

# Pull latest main with all merges
git checkout main && git pull origin main

# Remove worktrees
for domain in wellness workout nutrition shared; do
    WORKTREE="$BASE_DIR/VitalArc-$domain"
    if [ -d "$WORKTREE" ]; then
        git worktree remove "$WORKTREE" --force
    fi
done

# Prune worktree references
git worktree prune

# Sync beads
bd sync --from-main

# Final build verification
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD SUCCEEDED|BUILD FAILED)"
```

### Output Summary

```
═══════════════════════════════════════════════════════════════
       VITALARC SPRINT MERGE COMPLETE
═══════════════════════════════════════════════════════════════
Session:     [SESSION]
Domains:     [N] merged, [N] skipped
Beads:       [N] closed
Build:       [status]
───────────────────────────────────────────────────────────────
  Domain     │ PR      │ Status    │ Beads
─────────────┼─────────┼───────────┼──────────
  Wellness   │ #[N]    │ Merged    │ [N]
  Workout    │ #[N]    │ Merged    │ [N]
  Nutrition  │ #[N]    │ Skipped   │ [N]
  Shared     │ #[N]    │ Merged    │ [N]
───────────────────────────────────────────────────────────────
Worktrees:   Cleaned up
Main:        Up to date
═══════════════════════════════════════════════════════════════
```

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `--domain=<name>` | Merge only a single domain | All active domains |
| `--all` | Merge all domains without per-domain approval | Off (asks per domain) |

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Build fails in worktree | Stop that domain, report errors, continue to next |
| Rebase conflicts | Report conflicts, ask user for resolution |
| PR creation fails | Report error, suggest manual PR creation |
| Merge fails | Report error, do not proceed to next domain |
| Worktree removal fails | Warn, suggest manual cleanup with `git worktree remove` |
