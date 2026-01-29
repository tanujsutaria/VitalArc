---
name: stats-gatherer
description: Collects git statistics, file counts, and metrics for session reporting. Used at both session start and end.
disable-model-invocation: true
allowed-tools: Bash, Glob, Grep
argument-hint: [--mode=start|end] [--since=time]
---

# Stats Gatherer

Collects quantitative metrics about the codebase and session activity.

## Metrics Collected

### Codebase Metrics (Session Start)

| Metric | Command | Description |
|--------|---------|-------------|
| Swift files | `find . -name "*.swift" \| wc -l` | Total Swift file count |
| Lines of code | `find . -name "*.swift" -exec cat {} + \| wc -l` | Total LOC |
| Test files | `find . -name "*Tests.swift" \| wc -l` | Test file count |
| View files | `find . -path "*/Presentation/*.swift" \| wc -l` | Presentation layer |
| Domain files | `find . -path "*/Domain/*.swift" \| wc -l` | Domain layer |

### Session Metrics (Session End)

| Metric | Command | Description |
|--------|---------|-------------|
| Commits | `git log --oneline --since="6 hours ago" \| wc -l` | Commits this session |
| Files changed | `git diff --stat HEAD~N \| tail -1` | Files modified |
| Lines added | `git diff --stat HEAD~N \| grep -oE '[0-9]+ insertion'` | Lines added |
| Lines removed | `git diff --stat HEAD~N \| grep -oE '[0-9]+ deletion'` | Lines removed |

## Implementation

### Mode: start

Gather baseline codebase statistics:

```bash
echo "=== Codebase Statistics ==="

# File counts
SWIFT_FILES=$(find VitalArc -name "*.swift" 2>/dev/null | wc -l | tr -d ' ')
TEST_FILES=$(find VitalArc -name "*Tests.swift" 2>/dev/null | wc -l | tr -d ' ')
VIEW_FILES=$(find VitalArc -path "*/Presentation/*.swift" 2>/dev/null | wc -l | tr -d ' ')
DOMAIN_FILES=$(find VitalArc -path "*/Domain/*.swift" 2>/dev/null | wc -l | tr -d ' ')

# Lines of code (approximate)
TOTAL_LOC=$(find VitalArc -name "*.swift" -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')

# Recent commits
RECENT_COMMITS=$(git log --oneline --since="24 hours ago" 2>/dev/null | wc -l | tr -d ' ')

echo "Swift files: $SWIFT_FILES"
echo "Test files: $TEST_FILES"
echo "View files: $VIEW_FILES"
echo "Domain files: $DOMAIN_FILES"
echo "Total LOC: $TOTAL_LOC"
echo "Commits (24h): $RECENT_COMMITS"
```

### Mode: end

Gather session activity statistics:

```bash
echo "=== Session Statistics ==="

# Get session start time from state file
START_TIME=$(cat .claude/session-state.json 2>/dev/null | grep -o '"started_at": "[^"]*"' | cut -d'"' -f4)

# Commits this session
SESSION_COMMITS=$(git log --oneline --since="$START_TIME" 2>/dev/null | wc -l | tr -d ' ')

# Files changed (compare to main or use diff)
DIFF_STAT=$(git diff --stat main 2>/dev/null | tail -1)
FILES_CHANGED=$(echo "$DIFF_STAT" | grep -oE '[0-9]+ file' | grep -oE '[0-9]+')
INSERTIONS=$(echo "$DIFF_STAT" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
DELETIONS=$(echo "$DIFF_STAT" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+')

echo "Commits: $SESSION_COMMITS"
echo "Files changed: ${FILES_CHANGED:-0}"
echo "Lines added: ${INSERTIONS:-0}"
echo "Lines removed: ${DELETIONS:-0}"

# List changed files
echo ""
echo "=== Files Modified ==="
git diff --name-only main 2>/dev/null | head -20
```

## Output Format

### Start Mode Output

```markdown
## Codebase Statistics

| Metric | Count |
|--------|-------|
| Swift files | 160 |
| Test files | 6 |
| Presentation views | 70 |
| Domain entities | 25 |
| Total LOC | ~38,000 |

### Recent Activity
- Commits (24h): 3
- Last commit: feat(notifications): add settings view
```

### End Mode Output

```markdown
## Session Statistics

### Changes Made
| Metric | Count |
|--------|-------|
| Commits | 2 |
| Files changed | 15 |
| Lines added | +450 |
| Lines removed | -30 |
| Net change | +420 |

### Files Modified
```
VitalArc/Domain/Entities/Notifications/NotificationType.swift
VitalArc/Domain/Entities/Notifications/NotificationPreferences.swift
VitalArc/Presentation/Tabs/Profile/NotificationSettingsView.swift
... (12 more)
```

### Commit Summary
```
69df9e8 feat(notifications): add notification settings and TRIMP calculation
```
```

## Comparison Mode

When both start and end stats are available:

```markdown
## Session Comparison

| Metric | Start | End | Delta |
|--------|-------|-----|-------|
| Swift files | 160 | 167 | +7 |
| Total LOC | 38,000 | 38,450 | +450 |
| Test files | 6 | 6 | 0 |

### Growth
- Added 7 new Swift files
- Net +450 lines of code
- Test coverage unchanged
```

## Error Handling

### Git Not Available

```markdown
## ⚠️ Git Statistics Unavailable

Git commands failed. This may indicate:
- Not in a git repository
- Git not installed

Codebase statistics still available.
```

### No Changes

```markdown
## Session Statistics

No changes detected since session start.

This is normal if:
- Session just started
- Work not yet committed
- Working on a different branch
```
