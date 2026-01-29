---
name: pr-reviewer
description: Analyze pull requests and suggest improvements. Read-only analysis of PR changes, comments, and CI status. Works on both platforms.
disable-model-invocation: true
allowed-tools: Read, Bash, Grep, Glob, WebFetch
argument-hint: <pr-number-or-url>
---

# PR Reviewer

Analyzes pull requests and provides improvement suggestions.

## What It Reviews

| Category | Checks |
|----------|--------|
| Code Quality | Logic errors, edge cases, error handling |
| Architecture | Pattern consistency, separation of concerns |
| Design System | Token compliance, component usage |
| Testing | Test coverage, missing test cases |
| Documentation | Comments, docstrings, PR description |
| Security | Hardcoded secrets, injection risks |
| Performance | Inefficient patterns, memory leaks |

## Implementation

### 1. Fetch PR Information

```bash
# Get PR details
gh pr view $PR_NUMBER --json title,body,files,commits,reviews,state

# Get changed files
gh pr diff $PR_NUMBER

# Get CI status
gh pr checks $PR_NUMBER
```

### 2. Analyze Changes

For each changed file:
- Read the diff
- Check against VitalArc patterns
- Identify potential issues

### 3. Generate Review

Categorize findings by severity:
- 🔴 **Critical**: Must fix before merge
- 🟠 **Important**: Should fix
- 🟡 **Suggestion**: Nice to have
- 🟢 **Positive**: Good practices observed

## Review Categories

### Code Quality

```markdown
### Code Quality Review

#### 🔴 Critical
- **ProfileView.swift:45** - Force unwrap could crash
  ```swift
  let user = users.first!  // Could crash if empty
  ```
  **Fix**: Use optional binding or guard

#### 🟠 Important
- **WorkoutViewModel.swift:123** - Missing error handling
  ```swift
  Task { await loadWorkouts() }  // Errors silently ignored
  ```
  **Fix**: Add do-catch or error state
```

### Architecture

```markdown
### Architecture Review

#### 🟠 Important
- **NotificationManager.swift** - Direct UIApplication access in Domain
  - Domain layer should not import UIKit
  - Move to Infrastructure layer

#### 🟢 Positive
- Clean separation between ViewModel and View
- Use cases follow single responsibility
```

### Design System

```markdown
### Design System Review

#### 🟡 Suggestion
- **NewFeatureView.swift:67** - Hardcoded padding
  ```swift
  .padding(16)  // Use Spacing.md
  ```

#### 🟢 Positive
- Correct use of VitalCard component
- Typography tokens used consistently
```

### Testing

```markdown
### Testing Review

#### 🟠 Important
- **New files without tests:**
  - CalculateStrainScoreUseCase.swift (business logic)
  - NotificationSettingsViewModel.swift (state management)

#### 🟡 Suggestion
- Add edge case tests for TRIMP calculation:
  - Zero duration workout
  - Maximum heart rate scenarios
```

## Output Format

### Full Review

```markdown
## PR Review: #22

### Summary
**Title**: feat(notifications): add notification settings and TRIMP calculation
**Author**: @tanujsutaria
**Branch**: dev/mac-session-12.3-2026-01-28 → main
**Files**: 37 changed (+2971, -74)
**CI Status**: ✅ Passing

### Review Summary
| Category | Critical | Important | Suggestions |
|----------|----------|-----------|-------------|
| Code Quality | 0 | 2 | 3 |
| Architecture | 0 | 1 | 0 |
| Design System | 0 | 0 | 2 |
| Testing | 0 | 2 | 1 |
| **Total** | **0** | **5** | **6** |

### Verdict: ✅ APPROVE (with suggestions)

No critical issues. Address important items before merge.

---

### Detailed Findings

#### Code Quality (2 important, 3 suggestions)
[detailed findings...]

#### Architecture (1 important)
[detailed findings...]

#### Design System (2 suggestions)
[detailed findings...]

#### Testing (2 important, 1 suggestion)
[detailed findings...]

---

### Recommended Actions

**Before merge:**
1. Add error handling to NotificationSettingsViewModel async calls
2. Move UIApplication access to Infrastructure layer

**After merge (follow-up):**
1. Add unit tests for TRIMP calculation
2. Replace hardcoded padding values
```

### Quick Summary

For quick checks:

```markdown
## PR #22 Quick Review

✅ **Ready to merge** with minor suggestions

**Stats**: 37 files, +2971/-74 lines
**CI**: ✅ Passing
**Issues**: 0 critical, 5 important, 6 suggestions

**Top 3 items:**
1. Add error handling in ViewModel async calls
2. Add tests for new use cases
3. Move UIApplication to Infrastructure

[Run with --verbose for full review]
```

## Options

| Option | Description |
|--------|-------------|
| `--verbose` | Full detailed review |
| `--quick` | Summary only |
| `--focus=category` | Focus on specific category |
| `--auto-comment` | Post review as PR comment |

## Error Handling

### PR Not Found

```markdown
## ❌ PR Not Found

Could not find PR #999

Check:
- PR number is correct
- You have access to the repository
- `gh auth status` shows logged in
```

### No Access

```markdown
## ❌ Authentication Required

Cannot access PR. Run:
```bash
gh auth login
```
```

### Large PR Warning

```markdown
## ⚠️ Large PR Detected

This PR has 100+ files changed. Full review may be slow.

**Options:**
1. Run `--quick` for summary only
2. Run `--focus=testing` for specific category
3. Continue with full review (may take longer)
```
