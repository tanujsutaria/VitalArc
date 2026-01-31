---
name: focus-suggester
description: Analyze VitalArc roadmap and recent session history to suggest the most valuable focus area for the current development session. Use automatically when starting a session without a specified focus, or when the user asks what to work on next.
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

# Focus Suggester Agent

Analyzes the project state and suggests the highest-value focus area for the current session.

**Execution**: Runs in forked context with Explore agent for read-only analysis.

## When to Use

- Starting a session without a specified focus area
- User asks "what should I work on?" or "what's next?"
- After completing a task and looking for the next priority

## Analysis Process

### 1. Read Current State

Analyze these files to understand project status:

```
README.md          → Roadmap (In Progress, Planned features)
PROJECT_STATUS.md  → Feature status, Known Issues, priorities
SESSION_LOG.md     → Recent sessions (last 3), what was completed/deferred
```

### 2. Priority Scoring

Score potential focus areas using this rubric:

| Factor | Weight | Description |
|--------|--------|-------------|
| In Progress | 5x | Continue partially completed work |
| Known Issue | 4x | Fix documented bugs/issues |
| High Priority Planned | 3x | From roadmap "High" priority |
| Session Continuity | 2x | Follows naturally from last session |
| Medium Priority Planned | 1x | From roadmap "Medium" priority |

### 3. Consider Context

- **Workstation session**: Can suggest UI work, builds, simulator testing
- **Cloud session**: Suggest logic fixes, documentation, code review only

### 4. Output Format

Provide a ranked list with rationale:

```
## Suggested Focus Areas

### 1. [Top Recommendation] (Score: X)
**Why**: [Rationale based on roadmap/status]
**Scope**: [What this would involve]
**Files**: [Key files to touch]

### 2. [Second Option] (Score: Y)
**Why**: [Rationale]
**Scope**: [What this would involve]

### 3. [Third Option] (Score: Z)
**Why**: [Rationale]
```

## VitalArc-Specific Context

Current high-value areas (update as project evolves):
- **Notifications** - High priority planned feature
- **Typography tokens** - ~36 remaining hardcoded instances
- **Recovery fine-tuning** - In Progress feature
- **TRIMP calculation** - In Progress (Strain Tracking)
- **Sleep stage analysis** - In Progress feature

## Example Analysis

```markdown
## Suggested Focus Areas

### 1. Notifications Feature (Score: 15)
**Why**: High priority on roadmap, not started, enables user engagement
**Scope**: Local notifications for workout reminders, recovery alerts
**Files**: New NotificationManager, Settings integration

### 2. Typography Token Migration (Score: 12)
**Why**: Known issue from Session 12.2, ~36 instances remaining
**Scope**: Replace .font(.system()) with Typography tokens
**Files**: ~15 view files identified in previous session

### 3. Recovery Score Fine-tuning (Score: 10)
**Why**: In Progress feature, algorithm done but needs tuning
**Scope**: Adjust weights, test with real data
**Files**: CalculateRecoveryScoreUseCase.swift
```
