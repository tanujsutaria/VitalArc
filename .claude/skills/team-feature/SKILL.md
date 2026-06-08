---
description: Spawn an agent team for multi-domain feature development
disable-model-invocation: true
---

# Team Feature Development

Spawn an agent team with specialized domain agents for cross-domain feature work.

## Setup

1. Create a team with the `TeamCreate` tool, passing `team_name` and a short `description`
2. Analyze the feature request to determine which domains are involved
3. Create tasks for each domain's work using `TaskCreate`
4. Spawn only the agents needed via the `Task` tool (don't spawn all 3 if only 2 domains are involved)

```
TeamCreate(team_name: "feature-x", description: "Cross-domain work for feature X")

Task(subagent_type: "workout-agent",      team_name: "feature-x", ...)
Task(subagent_type: "wellness-agent",     team_name: "feature-x", ...)
Task(subagent_type: "orchestrator-agent", team_name: "feature-x", ...)
```

## Available Domain Agents

| Agent | File | Owns |
|-------|------|------|
| `workout-agent` | `.claude/agents/workout-agent.md` | `Modules/Workout/` |
| `wellness-agent` | `.claude/agents/wellness-agent.md` | `Modules/Wellness/` |
| `orchestrator-agent` | `.claude/agents/orchestrator-agent.md` | `Modules/Shared/`, `App/` |

## Workflow

1. **Analyze** - Determine which domains the feature touches
2. **Plan** - Create tasks with dependencies (use `addBlockedBy` for ordering)
3. **Spawn** - Launch domain agents via the `Task` tool with `team_name` and `subagent_type` set to the domain agent (e.g. `workout-agent`, `wellness-agent`, `orchestrator-agent`)
4. **Assign** - Give each agent its domain-specific tasks
5. **Coordinate** - Handle cross-domain integration (shared protocols, container wiring)
6. **Verify** - Run build validation after all agents complete
7. **Cleanup** - Shut down agents and clean up team

## Domain Isolation Rules

- Each agent only modifies files in its own `Modules/` subdirectory
- Cross-domain data access goes through `Modules/Shared/Protocols/`
- DependencyContainer changes go to the orchestrator-agent
- Design system changes go to the orchestrator-agent

## Example: "Add weekly volume summary to today dashboard"

```
Tasks:
1. [Workout Agent] Create VolumeSummaryCard view in Modules/Workout/Presentation/Views/
2. [Orchestrator Agent] Wire VolumeSummaryCard into TodayDashboardView (blocked by #1)
3. [Orchestrator Agent] Run build validation (blocked by #2)
```
