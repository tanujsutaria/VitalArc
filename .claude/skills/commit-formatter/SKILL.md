---
name: commit-formatter
description: Generate properly formatted conventional commit messages for VitalArc. Use automatically when preparing to commit changes, or when the user asks to commit. Analyzes staged changes and produces commit messages following project conventions.
maps-to-agent: general-purpose
allowed-tools: Read, Bash, Grep, Glob
---

# Commit Formatter Agent

Generates conventional commit messages following VitalArc's established patterns.

## When to Use

Auto-invoke when:
- User says "commit", "save changes", or "push"
- Preparing to run `git commit`
- Significant work block completed and ready to save

## Commit Format

```
<type>(<scope>): <description>

[optional body]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature or functionality |
| `fix` | Bug fix |
| `docs` | Documentation only changes |
| `style` | Code style (formatting, whitespace) |
| `refactor` | Code change that neither fixes nor adds features |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system or dependency changes |
| `chore` | Other maintenance tasks |

## Scopes

| Scope | Files/Areas |
|-------|-------------|
| `workout` | Workout tracking, exercise library, templates |
| `nutrition` | Food logging, macros, meal tracking |
| `health` | HealthKit, metrics, recovery score |
| `analytics` | Analytics dashboard, charts, exports |
| `ui` | Design system, shared components, general UI |
| `infra` | Build config, CI/CD, project structure |
| `session` | Session management, documentation |

## Analysis Process

### 1. Analyze Changes

```bash
git status --short
git diff --staged --stat
git diff --staged --name-only
```

### 2. Determine Type

- Adding new files/features → `feat`
- Modifying existing to fix issue → `fix`
- Only .md files → `docs`
- Restructuring without behavior change → `refactor`

### 3. Determine Scope

Based on primary files changed:
- `Presentation/Tabs/Workout/*` → `workout`
- `Presentation/Common/DesignSystem/*` → `ui`
- `Domain/UseCases/*Recovery*` → `health`
- `SESSION_LOG.md`, `.claude/*` → `session`

If multiple scopes, use the dominant one or most significant change.

### 4. Write Description

- Start with lowercase verb (add, fix, update, remove, refactor)
- Keep under 50 characters
- Describe the "what", not the "how"

**Good**: `add workout reminder notifications`
**Bad**: `Added a new NotificationManager class to handle scheduling`

### 5. Add Body (if needed)

Add body for:
- Breaking changes
- Complex changes needing explanation
- Multiple related changes

```
feat(workout): add custom exercise creation

- Users can now create exercises not in the library
- Custom exercises saved to SwiftData with isCustom flag
- Accessible from exercise picker via "Create Custom" button

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Output Format

Provide the commit command ready to execute:

```bash
git add [specific files]
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

[body if needed]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

## Examples

**Single file feature:**
```bash
git add VitalArc/Infrastructure/Notifications/NotificationManager.swift
git commit -m "$(cat <<'EOF'
feat(infra): add notification manager for local notifications

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

**Design system migration:**
```bash
git add VitalArc/Presentation/Tabs/Workout/*.swift
git commit -m "$(cat <<'EOF'
refactor(ui): migrate workout views to typography tokens

Replaced 12 instances of .font(.system()) with Typography tokens

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

**Bug fix:**
```bash
git add VitalArc/Domain/UseCases/CalculateVolumeUseCase.swift
git commit -m "$(cat <<'EOF'
fix(workout): correct volume calculation for partial sets

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

## Validation

Before outputting, verify:
- [ ] Type matches the nature of changes
- [ ] Scope matches the primary area
- [ ] Description is < 50 chars and starts with lowercase verb
- [ ] Co-author line is included
- [ ] No sensitive files (`.env`, credentials) are staged
