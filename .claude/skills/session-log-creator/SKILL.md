---
name: session-log-creator
description: Creates initial SESSION_LOG.md entry from template. Use at session start. For updating existing entries, use progress-tracker instead.
disable-model-invocation: true
allowed-tools: Read, Edit, Bash
argument-hint: --session=N --platform=mac|cloud [--focus=area] [--branch=name]
---

# Session Log Creator

Creates the initial SESSION_LOG.md entry when a session starts. Separate from progress-tracker which updates existing entries.

## Responsibility Split

| Agent | When | What |
|-------|------|------|
| **session-log-creator** | Session START | Create new entry from template |
| **progress-tracker** | During session | Update Work Log table |

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `--session` | Yes | Full session number (e.g., "12.3") |
| `--platform` | Yes | "mac" or "cloud" |
| `--focus` | No | Focus area for session |
| `--branch` | No | Branch name (auto-detected if not provided) |
| `--base-commit` | No | Base commit hash and message |

## Template Selection

### Workstation Template (platform=mac)

```markdown
## Session [SESSION] - [Month Day, Year] ([Time of Day])

### Session Start
- **Time**: [current time]
- **Platform**: macOS 🖥️
- **Focus**: [focus or "General development"]
- **Branch**: [branch]
- **Base**: main @ [commit hash] [commit message]

### Environment
- **Build Capable**: Yes
- **Test Capable**: Yes (unit + UI)

### Pre-Session Status
- **Build**: [from build-validator or "Pending"]
- **Uncommitted Changes**: [from git status or "None"]
- **Recent Activity**: [from previous session summary]

### Session Goals
1. [Primary goal based on focus]
2. [Secondary goal if applicable]
3. [Stretch goal if applicable]

### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| [time] | Session started | - | Build verified ✅ |

### Work Completed
[To be filled during session]

### Session End
[To be filled by /vitalarc-end-workstation]

---
```

### Cloud Template (platform=cloud)

```markdown
## Session [SESSION] - [Month Day, Year] ([Time of Day])

### Session Start
- **Time**: [current time]
- **Platform**: cloud ☁️
- **Focus**: [focus or "General"]
- **Branch**: [branch]
- **Base**: main @ [commit hash] [commit message]

### Environment
- **Build Capable**: No
- **Test Capable**: No

### Pre-Session Status
- **Build**: ⏭️ Skipped (cloud)
- **Uncommitted Changes**: [from git status or "None"]
- **Recent Activity**: [from previous session summary]

### Session Goals
1. [Primary goal based on focus]
2. [Secondary goal if applicable]

### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| [time] | Session started | - | Cloud session |

### Work Completed
[To be filled during session]

### Session End
[To be filled by /vitalarc-end-cloud]

---
```

## Implementation

### 1. Gather Context

```bash
# Get current values
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
BASE_COMMIT=$(git log main -1 --oneline 2>/dev/null || echo "unknown")
UNCOMMITTED=$(git status --short 2>/dev/null | head -3)
[ -z "$UNCOMMITTED" ] && UNCOMMITTED="None"

# Get previous session summary
PREV_SESSION=$(grep -A 20 "^## Session" SESSION_LOG.md | head -25)

# Format date
DATE_FORMATTED=$(date "+%B %d, %Y")
TIME_NOW=$(date "+%I:%M %p %Z" | sed 's/^0//')
```

### 2. Determine Goals

Based on focus area, suggest relevant goals:

| Focus | Goal 1 | Goal 2 |
|-------|--------|--------|
| notifications | Implement notification scheduling | Add settings UI |
| workout | Add exercise feature | Update workout tracking |
| nutrition | Enhance food logging | Fix calorie calculation |
| analytics | Add new chart | Improve data visualization |
| ui | Design system compliance | Component updates |
| general | Continue from previous session | Address known issues |

### 3. Insert Entry

Insert new entry at the TOP of SESSION_LOG.md (after the title line):

```bash
# Read existing content
EXISTING=$(cat SESSION_LOG.md)

# Create new entry
NEW_ENTRY="[generated from template]"

# Combine: Title + New Entry + Rest
echo "# VitalArc Development Session Log

$NEW_ENTRY

$(echo "$EXISTING" | tail -n +3)" > SESSION_LOG.md
```

## Output Format

```markdown
## Session Log Entry Created

### Session [SESSION]
- **Platform**: [mac/cloud]
- **Branch**: [branch]
- **Focus**: [focus]

### Entry Preview
```
## Session 12.3 - January 28, 2026 (Evening)

### Session Start
- **Time**: 8:45 PM PST
- **Platform**: macOS 🖥️
...
```

✅ Entry added to SESSION_LOG.md
```

## Error Handling

### SESSION_LOG.md Missing

```markdown
## ⚠️ SESSION_LOG.md Not Found

Creating new SESSION_LOG.md with initial entry.
```

### Duplicate Session Entry

If an entry for this session already exists:

```markdown
## ⚠️ Session Entry Exists

An entry for Session [N] already exists in SESSION_LOG.md.

**Options:**
1. Continue with existing entry (use progress-tracker to update)
2. Remove duplicate and recreate

Proceeding with option 1 (preserving existing entry).
```
