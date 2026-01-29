---
name: session-orchestrator
description: Lead orchestrator agent that coordinates all session start/end operations. Spawns subagents based on platform and mode. Use automatically by session skills.
disable-model-invocation: true
allowed-tools: Task, Read, Glob, Grep
argument-hint: --mode=start|end --platform=mac|cloud [--focus=area] [--build-capable=true|false]
---

# Session Orchestrator

Lead agent that coordinates session lifecycle. Follows Anthropic's orchestrator-worker pattern.

## Parameters

| Parameter | Required | Values | Default |
|-----------|----------|--------|---------|
| `--mode` | Yes | `start`, `end` | - |
| `--platform` | Yes | `mac`, `cloud` | - |
| `--focus` | No | Any string | None (triggers focus-suggester) |
| `--build-capable` | No | `true`, `false` | `true` if mac, `false` if cloud |

## Orchestration Logic

### START Mode

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SESSION START ORCHESTRATION                       │
├─────────────────────────────────────────────────────────────────────┤
│  PHASE 1 - Parallel (All Platforms):                                │
│    ├── focus-suggester (if no --focus provided)                     │
│    ├── design-system-scanner                                        │
│    ├── config-validator                                             │
│    └── context-loader                                               │
│                                                                      │
│  PHASE 1b - Parallel (Workstation Only):                            │
│    └── build-validator                                              │
│                                                                      │
│  PHASE 2 - Sequential (All Platforms):                              │
│    ├── session-state-manager --action=init                          │
│    ├── session-log-creator                                          │
│    └── stats-gatherer                                               │
└─────────────────────────────────────────────────────────────────────┘
```

### END Mode

```
┌─────────────────────────────────────────────────────────────────────┐
│                     SESSION END ORCHESTRATION                        │
├─────────────────────────────────────────────────────────────────────┤
│  PHASE 1 - Parallel (All Platforms):                                │
│    ├── design-system-scanner                                        │
│    ├── progress-tracker                                             │
│    └── stats-gatherer                                               │
│                                                                      │
│  PHASE 1b - Parallel (Workstation Only) [BLOCKING]:                 │
│    └── build-validator                                              │
│         ⚠️ If build fails, STOP orchestration and report error      │
│                                                                      │
│  PHASE 2 - Sequential (Workstation Only, after build passes):       │
│    └── design-system-fixer (if scanner found violations)            │
│                                                                      │
│  PHASE 3 - Sequential (All Platforms):                              │
│    ├── session-state-manager --action=finalize                      │
│    └── commit-formatter                                             │
│                                                                      │
│  PHASE 4 - Sequential (Workstation Only):                           │
│    └── pr-formatter                                                 │
└─────────────────────────────────────────────────────────────────────┘
```

## Scaling Rules (Per Anthropic Best Practices)

| Session Type | Agent Count | Tool Calls | Example |
|--------------|-------------|------------|---------|
| Quick fix | 3-4 agents | 10-15 | Bug fix, doc update |
| Feature work | 5-6 agents | 20-30 | New UI component |
| Major refactor | 7+ agents | 40+ | Architecture change |

## Implementation

### Parse Arguments

```bash
MODE=""
PLATFORM=""
FOCUS=""
BUILD_CAPABLE=""

for arg in $ARGUMENTS; do
  case $arg in
    --mode=*) MODE="${arg#*=}" ;;
    --platform=*) PLATFORM="${arg#*=}" ;;
    --focus=*) FOCUS="${arg#*=}" ;;
    --build-capable=*) BUILD_CAPABLE="${arg#*=}" ;;
  esac
done

# Default build_capable based on platform
[ -z "$BUILD_CAPABLE" ] && [ "$PLATFORM" = "mac" ] && BUILD_CAPABLE="true"
[ -z "$BUILD_CAPABLE" ] && [ "$PLATFORM" = "cloud" ] && BUILD_CAPABLE="false"
```

### START Mode Implementation

**Phase 1 - Launch parallel agents using Task tool:**

```markdown
Launch these agents IN PARALLEL using multiple Task tool calls in a single message:

1. If no --focus provided:
   Task: focus-suggester
   Prompt: "Analyze PROJECT_STATUS.md, README.md Roadmap, and recent SESSION_LOG.md. Return top 3 focus recommendations with scores."

2. Task: design-system-scanner
   Prompt: "Scan VitalArc/Presentation/ for design token violations. Report count and top 5 issues. Do NOT fix."

3. Task: config-validator
   Prompt: "Check API keys in NutritionixAPI.swift, USDAFoodAPI.swift. Check HealthKit entitlements. Report status."

4. Task: context-loader
   Prompt: "Read CLAUDE.md, PROJECT_STATUS.md, last 50 lines of SESSION_LOG.md. Summarize current project state."

5. If build_capable=true:
   Task: build-validator
   Prompt: "Run xcodebuild for VitalArc. Report build status, errors, and warnings."
```

**Phase 2 - Sequential setup:**

```markdown
After Phase 1 completes:

1. Task: session-state-manager
   Prompt: "Initialize session state for session [NUMBER] on platform [PLATFORM]. Create .claude/session-state.json."

2. Task: session-log-creator
   Prompt: "Create SESSION_LOG.md entry for session [NUMBER]. Platform: [PLATFORM]. Focus: [FOCUS]. Use workstation/cloud template as appropriate."

3. Task: stats-gatherer
   Prompt: "Gather git stats: recent commits, file counts, lines changed. Report summary."
```

### END Mode Implementation

**Phase 1 - Launch parallel agents:**

```markdown
Launch IN PARALLEL:

1. Task: design-system-scanner
   Prompt: "Final scan of VitalArc/Presentation/ for design token violations."

2. Task: progress-tracker
   Prompt: "Update SESSION_LOG.md Work Log with final entries. Add session end timestamp."

3. Task: stats-gatherer
   Prompt: "Gather session stats: commits made, files changed, lines added/removed."

4. If build_capable=true:
   Task: build-validator
   Prompt: "Final build verification. This is BLOCKING - session cannot end if build fails."
```

**Phase 2 - Conditional fix (workstation only):**

```markdown
If build_capable=true AND scanner found violations:

Task: design-system-fixer
Prompt: "Fix the design system violations found by scanner. Apply token replacements."
```

**Phase 3 - Finalize (all platforms):**

```markdown
1. Task: session-state-manager
   Prompt: "Finalize session state. Update .claude/session-state.json with ended_at and status=completed."

2. Task: commit-formatter
   Prompt: "Analyze staged changes. Generate conventional commit message following VitalArc conventions."
```

**Phase 4 - PR (workstation only):**

```markdown
If build_capable=true:

Task: pr-formatter
Prompt: "Generate PR title and body for the current branch. Include testing checklist."
```

## Output Format

### START Mode Output

```markdown
## Session Orchestration Complete (START)

### Platform: [mac/cloud]
### Session: [NUMBER]
### Focus: [FOCUS or "Suggested: X"]

### Agent Results

| Agent | Status | Summary |
|-------|--------|---------|
| focus-suggester | ✅ | Top pick: Notifications (score: 15) |
| design-system-scanner | ⚠️ | 12 violations in 5 files |
| config-validator | ✅ | All configs valid |
| context-loader | ✅ | Context established |
| build-validator | ✅ | BUILD SUCCEEDED |
| session-state-manager | ✅ | State initialized |
| session-log-creator | ✅ | Entry created |
| stats-gatherer | ✅ | 160 files, 38k lines |

### Ready to Begin
```

### END Mode Output

```markdown
## Session Orchestration Complete (END)

### Platform: [mac/cloud]
### Session: [NUMBER]

### Agent Results

| Agent | Status | Summary |
|-------|--------|---------|
| design-system-scanner | ✅ | No new violations |
| progress-tracker | ✅ | Work log updated |
| stats-gatherer | ✅ | +500 lines, 12 files |
| build-validator | ✅ | BUILD SUCCEEDED |
| session-state-manager | ✅ | State finalized |
| commit-formatter | ✅ | Commit ready |
| pr-formatter | ✅ | PR body generated |

### Commit Message
```
feat(notifications): add workout reminder scheduling
...
```

### PR Ready
[If workstation] PR can be created with: gh pr create ...
```

## Error Handling

### Build Failure (Workstation END mode)

```markdown
## ❌ Session End BLOCKED

### Build Failed
```
error: Type 'Foo' has no member 'bar'
  --> VitalArc/File.swift:123
```

### Required Action
Fix build errors before ending session. Run:
- `/build-validator` to see full errors
- Fix issues
- Re-run `/vitalarc-end-workstation`
```

### Agent Failure

If any agent fails, report the failure but continue with other agents (graceful degradation).

```markdown
### Agent Results

| Agent | Status | Summary |
|-------|--------|---------|
| focus-suggester | ❌ | Failed: timeout |
| design-system-scanner | ✅ | 12 violations |
...

⚠️ Some agents failed. Review and retry if needed.
```
