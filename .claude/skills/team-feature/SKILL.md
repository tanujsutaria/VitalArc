---
description: Spawn an agent team for multi-domain feature development
disable-model-invocation: true
---

# Team Feature Development

Spawn an agent team with specialized domain agents for cross-domain feature work.

## Setup

1. Create a team using `Teammate(operation: "spawnTeam")`
2. Analyze the feature request to determine which domains are involved
3. Create tasks for each domain's work using TaskCreate
4. Spawn only the agents needed (don't spawn all 4 if only 2 domains are involved)

## Available Domain Agents

| Agent | File | Owns |
|-------|------|------|
| `nutrition-agent` | `.claude/agents/nutrition-agent.md` | `Modules/Nutrition/` |
| `workout-agent` | `.claude/agents/workout-agent.md` | `Modules/Workout/` |
| `wellness-agent` | `.claude/agents/wellness-agent.md` | `Modules/Wellness/` |
| `orchestrator-agent` | `.claude/agents/orchestrator-agent.md` | `Modules/Shared/`, `App/` |

## Workflow

1. **Analyze** - Determine which domains the feature touches
2. **Plan** - Create tasks with dependencies (use `addBlockedBy` for ordering)
3. **Spawn** - Launch domain agents via Task tool with `team_name` and `subagent_type: "general-purpose"`
4. **Assign** - Give each agent its domain-specific tasks
5. **Coordinate** - Handle cross-domain integration (shared protocols, container wiring)
6. **Verify** - Run build validation after all agents complete
7. **Cleanup** - Shut down agents and clean up team

## Domain Isolation Rules

- Each agent only modifies files in its own `Modules/` subdirectory
- Cross-domain data access goes through `Modules/Shared/Protocols/`
- DependencyContainer changes go to the orchestrator-agent
- Design system changes go to the orchestrator-agent

## Example: "Add calorie summary to today dashboard"

```
Tasks:
1. [Nutrition Agent] Create CalorieSummaryCard view in Modules/Nutrition/Presentation/Views/
2. [Orchestrator Agent] Wire CalorieSummaryCard into TodayDashboardView (blocked by #1)
3. [Orchestrator Agent] Run build validation (blocked by #2)
```
