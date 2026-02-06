---
name: pr-formatter
description: Generate PR title and body following conventional commits format. Includes testing checklist and session metadata. Workstation only.
context: fork
agent: general-purpose
disable-model-invocation: true
allowed-tools: Read, Bash, Grep
argument-hint: [--draft] [--no-checklist]
---

# PR Formatter

Generates pull request title and body following VitalArc conventions.

**Execution**: Runs in forked context with general-purpose agent.
**Invocation**: User-triggered only (creates PRs).

**IMPORTANT**: When invoked without arguments, execute immediately with default settings. Never ask for clarification - use defaults and produce results.

## Default Behavior (No Arguments)

When invoked without arguments:
- **Base branch**: `main`
- **Mode**: Full PR (not draft)
- **Checklist**: Include testing checklist
- **Analysis**: Auto-detect type and scope from commits and changed files

Execute the full PR generation workflow immediately. Do not ask for clarification.

## When to Use

- End of workstation session (via session-orchestrator)
- User requests PR creation
- After significant feature completion

## PR Format

### Title
Follow conventional commits: `<type>(<scope>): <description>`

| Type | When to Use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructure |
| `docs` | Documentation |
| `style` | Formatting |
| `test` | Tests |
| `chore` | Maintenance |

| Scope | Area |
|-------|------|
| `workout` | Workout tracking |
| `nutrition` | Food logging |
| `health` | HealthKit, metrics |
| `analytics` | Charts, insights |
| `ui` | Design system, components |
| `infra` | Infrastructure, DI |

### Body Template

```markdown
## Summary
- [Primary change and why]
- [Secondary changes]

## Changes
- [List modified areas]

## Testing
- [x] Build passes locally
- [ ] CI passes
- [ ] Unit tests pass
- [ ] Manual testing done

---
Session: [N] | Platform: macOS | Build: Verified

Generated with [Claude Code](https://claude.ai/code)
```

## Implementation

### 1. Analyze Changes

```bash
# Get branch info
BRANCH=$(git rev-parse --abbrev-ref HEAD)
BASE_BRANCH="main"

# Get commit history on this branch
COMMITS=$(git log $BASE_BRANCH..HEAD --oneline)

# Get diff stats
DIFF_STAT=$(git diff --stat $BASE_BRANCH)

# Get changed files by category
DOMAIN_CHANGES=$(git diff --name-only $BASE_BRANCH | grep "Domain/")
PRESENTATION_CHANGES=$(git diff --name-only $BASE_BRANCH | grep "Presentation/")
INFRA_CHANGES=$(git diff --name-only $BASE_BRANCH | grep "Infrastructure/")
```

### 2. Determine Type and Scope

Based on changes:
- New files in Domain/Entities → `feat`
- Changes to existing files → `fix` or `refactor`
- Only Presentation changes → `ui` scope
- Only Domain changes → appropriate domain scope

### 3. Generate Title

```bash
# Extract from branch name or commits
# Branch: dev/mac-notifications-12.3-2026-01-28
# → feat(notifications): add notification settings

# Or from commit messages
FIRST_COMMIT=$(git log $BASE_BRANCH..HEAD --oneline | tail -1)
```

### 4. Generate Body

```bash
# Count changes
FILES_CHANGED=$(git diff --name-only $BASE_BRANCH | wc -l)
INSERTIONS=$(git diff --stat $BASE_BRANCH | tail -1 | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
DELETIONS=$(git diff --stat $BASE_BRANCH | tail -1 | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+')

# Get session info
SESSION=$(cat .claude/session-state.json | grep -o '"current_session": "[^"]*"' | cut -d'"' -f4)
```

## Output Format

### PR Ready Output

```markdown
## PR Ready

### Title
```
feat(notifications): add notification settings and TRIMP calculation
```

### Body
```markdown
## Summary
- Added notification settings UI with UNUserNotificationCenter integration
- Implemented TRIMP/Strain calculation for workout analytics
- Completed typography token migration

## Changes
- **Domain**: NotificationType, NotificationPreferences, StrainResult entities
- **Presentation**: NotificationSettingsView, NotificationPreviewCard
- **Use Cases**: CalculateStrainScoreUseCase

## Testing
- [x] Build passes locally
- [ ] CI passes
- [ ] Unit tests pass
- [ ] Manual testing done

---
Session: 12.3 | Platform: macOS | Build: Verified

Generated with [Claude Code](https://claude.ai/code)
```

### Create Command
```bash
gh pr create --title "feat(notifications): add notification settings and TRIMP calculation" --body "$(cat <<'EOF'
[body content]
EOF
)"
```
```

### Draft PR

With `--draft` flag:

```bash
gh pr create --draft --title "..." --body "..."
```

## Options

| Option | Description |
|--------|-------------|
| `--draft` | Create as draft PR |
| `--no-checklist` | Omit testing checklist |
| `--base=branch` | Specify base branch (default: main) |

## Error Handling

### No Changes

```markdown
## No Changes to PR

No commits found between main and current branch.

Make sure you have:
1. Committed your changes
2. Pushed to remote
```

### Cannot Determine Type

```markdown
## Cannot Auto-Detect PR Type

Changes span multiple areas. Please specify:

**Suggested titles:**
1. `feat(notifications): add notification scheduling` (if primary feature)
2. `refactor(ui): update design system tokens` (if refactoring)
3. `chore(infra): update agent skills` (if infrastructure)

Which would you like to use?
```

### GitHub CLI Not Available

```markdown
## GitHub CLI Not Found

`gh` command not available. Install with:
```bash
brew install gh
gh auth login
```

**Manual PR creation:**
1. Push branch: `git push -u origin $(git branch --show-current)`
2. Open: https://github.com/tanujsutaria/VitalArc/pull/new/[branch]
3. Use the title and body above
```
