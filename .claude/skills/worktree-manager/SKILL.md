---
name: worktree-manager
description: Manage git worktrees for parallel development. Create, list, remove, and switch between isolated worktrees. Enables working on multiple features simultaneously without branch switching.
context: fork
agent: general-purpose
allowed-tools: Bash, Read
argument-hint: <create|list|remove|switch|status> [name]
---

# Worktree Manager

Manages git worktrees for parallel development sessions. Worktrees allow working on multiple branches simultaneously in separate directories.

**Execution**: Runs in forked context with Bash agent.

## When to Use

- Starting work on a new feature while another is in progress
- Need to review a PR without disrupting current work
- Want to compare implementations across branches
- Running parallel development sessions

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `create <name>` | Create new worktree | `/worktree-manager create nutrition` |
| `list` | Show all worktrees | `/worktree-manager list` |
| `remove <name>` | Remove worktree (after PR merge) | `/worktree-manager remove nutrition` |
| `switch <name>` | Show path to worktree | `/worktree-manager switch nutrition` |
| `status` | Show status of all worktrees | `/worktree-manager status` |

## Implementation

### Create Worktree

Creates `../VitalArc-<name>` with proper branch setup.

```bash
NAME="$1"
BASE_DIR=$(dirname "$(pwd)")
WORKTREE_PATH="$BASE_DIR/VitalArc-$NAME"

# Check if worktree already exists
if [ -d "$WORKTREE_PATH" ]; then
    echo "Worktree already exists: $WORKTREE_PATH"
    exit 1
fi

# Calculate session number for branch name
TODAY=$(date +%Y-%m-%d)
LATEST_ENTRY=$(grep -E "^## Session [0-9]+\.[0-9]+ - " SESSION_LOG.md | head -1)
LATEST_MAJOR=$(echo "$LATEST_ENTRY" | sed -E 's/## Session ([0-9]+)\..*/\1/')
LATEST_MAJOR=${LATEST_MAJOR:-0}
SESSION=$((LATEST_MAJOR + 1))
BRANCH="dev/mac-$NAME-$SESSION.0-$TODAY"

# Create worktree with new branch
git worktree add "$WORKTREE_PATH" -b "$BRANCH" main

echo "Created worktree:"
echo "  Path: $WORKTREE_PATH"
echo "  Branch: $BRANCH"
echo ""
echo "To work in this worktree:"
echo "  cd $WORKTREE_PATH"
```

### List Worktrees

```bash
echo "VitalArc Worktrees"
echo "=================="
git worktree list --porcelain | while read -r line; do
    case "$line" in
        worktree*)
            path=$(echo "$line" | cut -d' ' -f2)
            echo ""
            echo "Path: $path"
            ;;
        HEAD*)
            commit=$(echo "$line" | cut -d' ' -f2 | cut -c1-7)
            echo "  Commit: $commit"
            ;;
        branch*)
            branch=$(echo "$line" | cut -d' ' -f2 | sed 's|refs/heads/||')
            echo "  Branch: $branch"
            ;;
    esac
done
```

### Remove Worktree

```bash
NAME="$1"
BASE_DIR=$(dirname "$(pwd)")
WORKTREE_PATH="$BASE_DIR/VitalArc-$NAME"

# Check if worktree exists
if [ ! -d "$WORKTREE_PATH" ]; then
    echo "Worktree not found: $WORKTREE_PATH"
    exit 1
fi

# Check for uncommitted changes
cd "$WORKTREE_PATH"
if [ -n "$(git status --porcelain)" ]; then
    echo "WARNING: Worktree has uncommitted changes!"
    echo ""
    git status --short
    echo ""
    echo "Commit or stash changes before removing."
    exit 1
fi

# Remove worktree
cd "$BASE_DIR/VitalArc"
git worktree remove "$WORKTREE_PATH"

echo "Removed worktree: $WORKTREE_PATH"
```

### Switch Worktree

Note: This doesn't actually switch directories (impossible in subshell), but provides the path and instructions.

```bash
NAME="$1"
BASE_DIR=$(dirname "$(pwd)")
WORKTREE_PATH="$BASE_DIR/VitalArc-$NAME"

if [ ! -d "$WORKTREE_PATH" ]; then
    echo "Worktree not found: $WORKTREE_PATH"
    echo ""
    echo "Available worktrees:"
    git worktree list
    exit 1
fi

echo "To switch to worktree '$NAME':"
echo ""
echo "  cd $WORKTREE_PATH"
echo ""
echo "Current branch in worktree:"
cd "$WORKTREE_PATH" && git branch --show-current
```

### Status of All Worktrees

```bash
echo "VitalArc Worktree Status"
echo "========================"
echo ""

git worktree list --porcelain | grep "^worktree " | cut -d' ' -f2 | while read -r path; do
    name=$(basename "$path")
    branch=$(cd "$path" && git branch --show-current)
    changes=$(cd "$path" && git status --porcelain | wc -l | tr -d ' ')
    ahead=$(cd "$path" && git rev-list --count origin/main..HEAD 2>/dev/null || echo "?")

    echo "$name"
    echo "  Branch: $branch"
    echo "  Changes: $changes uncommitted"
    echo "  Ahead of main: $ahead commits"
    echo ""
done
```

## Output Format

### Create Output

```markdown
## Worktree Created

**Path**: /Users/user/Development/VitalArc-nutrition
**Branch**: dev/mac-nutrition-17.0-2026-02-01
**Based on**: main @ 310ec55

### Next Steps

1. Open new terminal/tab
2. `cd /Users/user/Development/VitalArc-nutrition`
3. Run `/vitalarc-start-workstation nutrition` in new session

### Current Worktrees

| Name | Branch | Status |
|------|--------|--------|
| VitalArc (main) | main | Clean |
| VitalArc-nutrition | dev/mac-nutrition-17.0-2026-02-01 | New |
```

### List Output

```markdown
## VitalArc Worktrees

| Name | Path | Branch | Status |
|------|------|--------|--------|
| VitalArc | /Users/user/Dev/VitalArc | main | Clean |
| VitalArc-nutrition | /Users/user/Dev/VitalArc-nutrition | dev/mac-nutrition-16.0 | 3 uncommitted |
| VitalArc-ui-bugs | /Users/user/Dev/VitalArc-ui-bugs | dev/mac-ui-16.1 | Clean |

**Total**: 3 worktrees
```

### Status Output

```markdown
## Worktree Status

### VitalArc (main)
- **Branch**: main
- **Status**: Clean
- **Last commit**: 310ec55 (Merge pull request #44)

### VitalArc-nutrition
- **Branch**: dev/mac-nutrition-16.0-2026-02-01
- **Status**: 2 files modified
- **Ahead of main**: 3 commits
- **Files**:
  - M VitalArc/Modules/Nutrition/Presentation/Views/NutritionView.swift
  - M VitalArc/Modules/Nutrition/Domain/UseCases/NutritionUseCases.swift

### VitalArc-ui-bugs
- **Branch**: dev/mac-ui-16.1-2026-02-01
- **Status**: Clean
- **Ahead of main**: 5 commits
- **Ready to merge**: Yes
```

## Integration with Session Workflow

### With Session Starters

Use `--worktree` flag to auto-create worktree:

```bash
# This creates worktree + starts session
/vitalarc-start-workstation nutrition --worktree
```

Internally calls:
1. `/worktree-manager create nutrition`
2. `cd ../VitalArc-nutrition`
3. Normal session start

### With PR Workflow

When reviewing PRs, create isolated worktree:

```bash
# For PR review
/worktree-manager create review-PR123
cd ../VitalArc-review-PR123
gh pr checkout 123
```

After review:
```bash
/worktree-manager remove review-PR123
```

## Best Practices

### Naming Conventions

| Type | Naming | Example |
|------|--------|---------|
| Feature work | `VitalArc-<feature>` | VitalArc-nutrition |
| Bug fixes | `VitalArc-<area>-bugs` | VitalArc-ui-bugs |
| PR review | `VitalArc-review-PR<num>` | VitalArc-review-PR123 |
| Experiments | `VitalArc-exp-<name>` | VitalArc-exp-new-arch |

### Cleanup

After merging PR:
```bash
# 1. Delete remote branch
git push origin --delete dev/mac-nutrition-16.0-2026-02-01

# 2. Remove worktree
/worktree-manager remove nutrition

# 3. Prune local refs
git fetch --prune
```

## Error Handling

### Worktree Already Exists

```markdown
## Worktree Exists

**Path**: /Users/user/Development/VitalArc-nutrition

The worktree already exists. Options:
1. Use existing: `cd /Users/user/Development/VitalArc-nutrition`
2. Remove first: `/worktree-manager remove nutrition`
3. Use different name: `/worktree-manager create nutrition-v2`
```

### Uncommitted Changes on Remove

```markdown
## Cannot Remove Worktree

**Path**: /Users/user/Development/VitalArc-nutrition

Worktree has uncommitted changes:
- M NutritionView.swift
- M FoodSearch.swift

**Options**:
1. Commit changes: `cd ../VitalArc-nutrition && git commit -am "WIP"`
2. Stash changes: `cd ../VitalArc-nutrition && git stash`
3. Force remove: `/worktree-manager remove nutrition --force`
```

### Branch Exists

```markdown
## Branch Conflict

Branch `dev/mac-nutrition-17.0-2026-02-01` already exists.

**Options**:
1. Use existing branch: `git worktree add ../VitalArc-nutrition dev/mac-nutrition-17.0-2026-02-01`
2. Increment minor version: Creates `dev/mac-nutrition-17.1-2026-02-01`
3. Choose different name: `/worktree-manager create nutrition-new`
```
