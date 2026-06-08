---
name: review-resolver
description: Track and resolve PR review findings. Creates tasks per finding, provides fix suggestions, tracks resolution status, and re-runs checks after fixes.
context: fork
agent: general-purpose
allowed-tools: Read, Edit, Grep, Glob, Bash, TaskCreate, TaskUpdate, TaskList, WebFetch
argument-hint: <pr-number> [--status] [--fix-all] [--recheck]
---

# Review Resolver

Tracks and resolves PR review findings systematically. Creates tasks for each finding, provides fix suggestions, and verifies fixes.

**Execution**: Runs in forked context with general-purpose agent for read-write operations.

## When to Use

- After receiving PR review feedback
- To systematically address review comments
- To track resolution progress
- To verify all findings are addressed before re-requesting review

## Implementation

### 1. Fetch PR Review Findings

```bash
# Get PR review comments
gh api repos/:owner/:repo/pulls/$PR_NUMBER/reviews --jq '.[] | select(.state != "APPROVED") | .body'

# Get inline comments
gh api repos/:owner/:repo/pulls/$PR_NUMBER/comments --jq '.[] | {path: .path, line: .line, body: .body}'

# Get requested changes
gh pr view $PR_NUMBER --json reviews --jq '.reviews[] | select(.state == "CHANGES_REQUESTED")'
```

### 2. Parse and Categorize Findings

Categories:
- **Critical**: Must fix before merge
- **Important**: Should fix
- **Suggestion**: Nice to have
- **Question**: Needs response

### 3. Create Tasks per Finding

```javascript
// Create task for each finding
findings.forEach((finding, index) => {
  TaskCreate({
    subject: `Fix: ${finding.summary}`,
    description: `PR Review Finding #${index + 1}

**File**: ${finding.path}:${finding.line}
**Severity**: ${finding.severity}
**Reviewer**: ${finding.reviewer}

**Comment**:
${finding.body}

**Suggested Fix**:
${generateFixSuggestion(finding)}`,
    activeForm: `Fixing ${finding.path}:${finding.line}`,
    metadata: {
      prNumber: PR_NUMBER,
      findingId: finding.id,
      severity: finding.severity,
      file: finding.path,
      line: finding.line
    }
  })
})
```

### 4. Generate Fix Suggestions

Based on common patterns:

```javascript
function generateFixSuggestion(finding) {
  // Force unwrap
  if (finding.body.includes("force unwrap") || finding.body.includes("!")) {
    return `Use optional binding:
\`\`\`swift
// Instead of: value!
guard let value = value else { return }
// or
if let value = value { ... }
\`\`\``
  }

  // Design system
  if (finding.body.includes("hardcoded") || finding.body.includes("design token")) {
    return `Replace with design token:
- Colors: Color.vitalPrimary, Color.vitalDanger, etc.
- Spacing: Spacing.sm, Spacing.md, Spacing.lg
- Typography: .font(.vitalBody), .font(.vitalH1)`
  }

  // Error handling
  if (finding.body.includes("error handling")) {
    return `Add proper error handling:
\`\`\`swift
do {
    try await operation()
} catch {
    // Handle error appropriately
    errorState = error.localizedDescription
}
\`\`\``
  }

  return "Review the comment and apply the suggested change."
}
```

## Output Format

### Findings Dashboard

```markdown
## PR Review Resolution: #123

### Summary
| Severity | Count | Resolved |
|----------|-------|----------|
| Critical | 2 | 0/2 |
| Important | 5 | 2/5 |
| Suggestion | 3 | 1/3 |
| **Total** | **10** | **3/10** |

**Progress**: 30% resolved

---

### Outstanding Findings

#### Critical (2 remaining)

**#1: Force unwrap in ProfileViewModel.swift:45**
- Reviewer: @teammate
- Status: Pending
- Task: #12

**#2: Missing error handling in APIClient.swift:89**
- Reviewer: @teammate
- Status: In Progress
- Task: #13

#### Important (3 remaining)

**#3: Add tests for VolumeCalculator**
- Reviewer: @lead
- Status: Pending
- Task: #14

...

---

### Resolved Findings

| # | Finding | Resolution |
|---|---------|------------|
| 4 | Hardcoded color in ProfileView | Changed to Color.vitalPrimary |
| 5 | Missing docstring | Added documentation |
| 8 | Typo in variable name | Renamed to correct spelling |

---

### Next Steps

1. Fix critical findings first (#1, #2)
2. Address important findings (#3, #6, #7)
3. Run `/review-resolver --recheck` to verify fixes
4. Re-request review when all critical/important resolved
```

### Status Check (`--status`)

Quick status of resolution progress:

```markdown
## PR #123 Review Resolution Status

**Progress**: 7/10 resolved (70%)

Outstanding:
- 0 Critical
- 2 Important
- 1 Suggestion

Ready for re-review when important findings resolved.
```

### Fix Report (after applying fixes)

```markdown
## Fix Applied: Finding #1

**File**: ProfileViewModel.swift:45
**Change**: Replaced force unwrap with optional binding

**Before**:
```swift
let user = users.first!
```

**After**:
```swift
guard let user = users.first else {
    return
}
```

**Verification**: Build passes

---

Task #12 marked as completed.
Remaining: 9 findings (2 critical, 5 important, 2 suggestions)
```

### Recheck Report (`--recheck`)

After fixes, verify everything is resolved:

```markdown
## PR #123 Recheck Results

### Build Verification
**Status**: Passing

### Test Verification
**Status**: All tests pass (68/68)

### Findings Verification

| Finding | Status | Verified |
|---------|--------|----------|
| #1 Force unwrap | Fixed | Code changed |
| #2 Error handling | Fixed | Try-catch added |
| #3 Missing tests | Fixed | 3 tests added |
| #4 Hardcoded color | Fixed | Using token |
| ... | ... | ... |

### Automated Checks
- Design system scan: No new violations
- Lint check: No errors
- Type safety: No force unwraps in changed files

### Recommendation

All critical and important findings resolved.
**Ready to re-request review.**

```bash
gh pr ready $PR_NUMBER
gh pr edit $PR_NUMBER --add-reviewer @teammate
```
```

## Task Integration

### Track Resolution with Tasks

```javascript
// Create master tracking task
const masterTask = TaskCreate({
  subject: `Resolve PR #${PR_NUMBER} review findings`,
  description: `Track resolution of all review findings for PR #${PR_NUMBER}`,
  activeForm: "Tracking PR review resolution"
})

// Create sub-task for each finding
findings.forEach(finding => {
  TaskCreate({
    subject: `Fix: ${finding.summary}`,
    ...
    addBlockedBy: []  // Can work in parallel
  })
})

// Create final verification task
TaskCreate({
  subject: `Verify all PR #${PR_NUMBER} fixes`,
  description: "Run --recheck to verify all findings resolved",
  addBlockedBy: findingTaskIds  // Blocked by all finding tasks
})
```

### Dashboard Integration

Show in task-dashboard:

```
PR Review Resolution: #123
[████████████████████░░░░░░░░░░░░░░░░░░░░] 50%  5/10 findings

Critical: 0/2 | Important: 3/5 | Suggestions: 2/3
Active: Fix error handling in APIClient.swift
```

## Commands

| Command | Description |
|---------|-------------|
| `/review-resolver 123` | Load and track findings for PR #123 |
| `/review-resolver 123 --status` | Quick status check |
| `/review-resolver 123 --fix-all` | Apply auto-fixable suggestions |
| `/review-resolver 123 --recheck` | Verify all fixes, run checks |

## Error Handling

### No Review Comments

```markdown
## PR #123 Review Status

No review comments found.

The PR may be:
- Pending review
- Already approved
- Not yet reviewed

Check PR status:
```bash
gh pr view 123 --json state,reviews
```
```

### PR Not Found

```markdown
## Error: PR Not Found

Could not find PR #999

Check:
- PR number is correct
- You have access to the repository
- `gh auth status` shows logged in
```

## Best Practices

1. **Address critical findings first** - they block merge
2. **Don't dismiss suggestions without consideration** - reviewers may have good reasons
3. **Run --recheck before re-requesting review** - verify your fixes actually work
4. **Respond to questions** - don't just fix, communicate
5. **Keep changes focused** - don't introduce new issues while fixing old ones
