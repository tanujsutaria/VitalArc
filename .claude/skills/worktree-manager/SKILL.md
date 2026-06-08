---
name: worktree-manager
description: Inspect and clean up git worktrees for parallel development. Lists worktrees, shows per-worktree status, and guides removal. Creation/switching is done with the native EnterWorktree/ExitWorktree tools, not this skill.
context: fork
agent: general-purpose
allowed-tools: Bash, Read
argument-hint: <list|status|remove> [name]
---

# Worktree Manager

Inspect and clean up git worktrees used for parallel development.

> **Create / switch with the native tools, not this skill.** This skill runs in a forked subagent, which cannot change the main session's working directory. To create a worktree and switch into it, the main session calls the native **`EnterWorktree`** tool (it creates the worktree under `.claude/worktrees/<name>` on a fresh branch from `origin/main` and switches the session into it). To leave, the main session calls **`ExitWorktree`** (`action: "keep"` to preserve, `action: "remove"` to delete). This skill provides the read-only inventory and cleanup commands that complement them.

## When to Use
- See every active worktree and which branch each is on (`list`)
- Check uncommitted/unpushed state across worktrees before cleanup (`status`)
- Remove a stale worktree whose branch is already merged (`remove <name>`)

## Commands

| Command | Action |
|---------|--------|
| `list` | Show all worktrees and their branches |
| `status` | Per-worktree dirty/ahead-behind summary |
| `remove <name>` | Remove a worktree after its work is merged (guards against uncommitted changes) |

## Implementation

### List Worktrees

```bash
git worktree list --porcelain | awk '
  /^worktree / { path=$2 }
  /^branch /   { print path"  ->  "$2 }
  /^detached/  { print path"  ->  (detached)" }
'
```

### Status of All Worktrees

```bash
git worktree list --porcelain | grep "^worktree " | cut -d' ' -f2 | while read -r path; do
  [ -d "$path" ] || continue
  branch=$(git -C "$path" branch --show-current 2>/dev/null)
  dirty=$(git -C "$path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  echo "• $path  [$branch]  uncommitted=$dirty"
done
```

### Remove a Worktree

> For the worktree the **current session** is in, prefer the native `ExitWorktree({ action: "remove" })`. Use the commands below for *other* worktrees.

```bash
# Resolve the worktree path (project convention: .claude/worktrees/<name>)
WORKTREE_PATH=$(git worktree list --porcelain | grep "^worktree " | cut -d' ' -f2 | grep "/$NAME$" | head -1)

[ -z "$WORKTREE_PATH" ] && { echo "No worktree named '$NAME'. Run 'list' to see paths."; exit 0; }

# Guard: refuse if there are uncommitted changes
if [ -n "$(git -C "$WORKTREE_PATH" status --porcelain 2>/dev/null)" ]; then
  echo "Worktree '$NAME' has uncommitted changes — commit/stash first, or use git worktree remove --force."
  exit 0
fi

git worktree remove "$WORKTREE_PATH"
echo "Removed $WORKTREE_PATH"
```

## Output Format

```markdown
## Worktrees
| Path | Branch | Uncommitted |
|------|--------|-------------|
| .../.claude/worktrees/dev+mac-infra-27.2-... | dev/mac-infra-27.2-... | 0 |
| .../VitalArc (main) | main | 0 |

### Cleanup suggestions
- `dev/mac-…` is merged into main and clean → safe to remove.
```

## Integration with Session Workflow

- **Start parallel work**: the main session calls `EnterWorktree({ name: "dev/mac-<focus>-<session>.<minor>-<date>" })` then runs `/vitalarc-start-workstation`.
- **Finish**: commit + push + open the PR, then `ExitWorktree({ action: "keep" })` (or `"remove"` once merged).
- **Housekeeping**: use this skill's `list`/`status`/`remove` to prune merged worktrees.

> Branch naming must satisfy CI: `^dev/(mac|cloud)-[a-z]+-\d+\.\d+-\d{4}-\d{2}-\d{2}$` — a **single-word** focus (no hyphens/digits).
