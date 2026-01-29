---
name: session-state-manager
description: Owns the .claude/session-state.json lifecycle. Handles init, update, and finalize operations for session state tracking.
disable-model-invocation: true
allowed-tools: Read, Write, Bash
argument-hint: --action=init|update|finalize [--session=N] [--platform=mac|cloud]
---

# Session State Manager

Single source of truth for session state. Prevents inconsistent state writes across skills.

## State File Schema

```json
{
  "current_session": "12.3",
  "branch": "dev/mac-session-12.3-2026-01-28",
  "platform": "mac|cloud",
  "status": "active|completed",
  "started_at": "2026-01-28T20:00:00Z",
  "ended_at": "2026-01-28T22:00:00Z",
  "build_capable": true,
  "build_status": "passing|failing|unknown",
  "focus": "notifications"
}
```

## Actions

### init

Create initial state file when session starts.

**Input:**
- `--session`: Full session number (e.g., "12.3")
- `--platform`: "mac" or "cloud"
- `--branch`: Branch name
- `--focus`: Optional focus area

**Implementation:**

```bash
SESSION="${SESSION:-unknown}"
PLATFORM="${PLATFORM:-mac}"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
FOCUS="${FOCUS:-general}"
BUILD_CAPABLE="true"
[ "$PLATFORM" = "cloud" ] && BUILD_CAPABLE="false"

cat > .claude/session-state.json << EOF
{
  "current_session": "$SESSION",
  "branch": "$BRANCH",
  "platform": "$PLATFORM",
  "status": "active",
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "build_capable": $BUILD_CAPABLE,
  "build_status": "unknown",
  "focus": "$FOCUS"
}
EOF
```

**Output:**
```markdown
## Session State Initialized

- **Session**: 12.3
- **Branch**: dev/mac-session-12.3-2026-01-28
- **Platform**: mac
- **Status**: active
- **Started**: 2026-01-28T20:00:00Z
```

### update

Update specific fields in the state file.

**Input:**
- `--field=value` pairs (e.g., `--build_status=passing`)

**Implementation:**

```bash
# Read current state
STATE=$(cat .claude/session-state.json)

# Update fields using jq or sed
# Example: update build_status
if [ -n "$BUILD_STATUS" ]; then
  STATE=$(echo "$STATE" | sed "s/\"build_status\": \"[^\"]*\"/\"build_status\": \"$BUILD_STATUS\"/")
fi

echo "$STATE" > .claude/session-state.json
```

**Output:**
```markdown
## Session State Updated

- **Changed**: build_status → passing
```

### finalize

Mark session as completed with end timestamp.

**Input:**
- `--build_status`: Final build status (passing/failing)

**Implementation:**

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
SESSION=$(cat .claude/session-state.json | grep -o '"current_session": "[^"]*"' | cut -d'"' -f4)
PLATFORM=$(cat .claude/session-state.json | grep -o '"platform": "[^"]*"' | cut -d'"' -f4)
BUILD_STATUS="${BUILD_STATUS:-unknown}"

cat > .claude/session-state.json << EOF
{
  "current_session": "$SESSION",
  "branch": "$BRANCH",
  "platform": "$PLATFORM",
  "status": "completed",
  "started_at": "$(cat .claude/session-state.json | grep -o '"started_at": "[^"]*"' | cut -d'"' -f4)",
  "ended_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "build_capable": $([ "$PLATFORM" = "mac" ] && echo "true" || echo "false"),
  "build_status": "$BUILD_STATUS"
}
EOF
```

**Output:**
```markdown
## Session State Finalized

- **Session**: 12.3
- **Status**: completed
- **Ended**: 2026-01-28T22:00:00Z
- **Build**: passing
```

### read

Read current state (for other agents to query).

**Implementation:**

```bash
cat .claude/session-state.json
```

## Error Handling

### Missing State File

If `.claude/session-state.json` doesn't exist during update/finalize:

```markdown
## ⚠️ State File Missing

No session state found. This may indicate:
- Session was not properly started
- State file was accidentally deleted

**Recovery**: Run session-state-manager --action=init to create new state.
```

### Invalid JSON

If state file is corrupted:

```markdown
## ⚠️ State File Corrupted

Could not parse .claude/session-state.json

**Recovery**:
1. Check git history: `git show HEAD:.claude/session-state.json`
2. Restore or reinitialize
```
