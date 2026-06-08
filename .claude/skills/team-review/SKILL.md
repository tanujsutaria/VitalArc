---
description: Spawn reviewers per domain for comprehensive PR review
disable-model-invocation: true
---

# Team Code Review

Spawn a review team with one reviewer per domain touched in a PR.

## Setup

1. Analyze the PR to determine which domains are affected
2. Create a team using `TeamCreate`
3. Spawn one reviewer per affected domain via `Task(...)`
4. Each reviewer focuses on their domain's patterns and conventions

```javascript
// Create the review team
TeamCreate({ team_name: "pr-review", description: "Per-domain PR review" })

// Spawn one reviewer per affected domain (only those the PR touches)
Task({ team_name: "pr-review", name: "workout-reviewer",  subagent_type: "workout-agent" })
Task({ team_name: "pr-review", name: "wellness-reviewer", subagent_type: "wellness-agent" })
Task({ team_name: "pr-review", name: "shared-reviewer",   subagent_type: "orchestrator-agent" })
```

## Workflow

1. **Analyze PR** - Use `gh pr diff` to identify changed files
2. **Map to domains** - Group files by module:
   - `Modules/Workout/` -> workout-agent
   - `Modules/Wellness/` -> wellness-agent
   - `Modules/Shared/`, `App/` -> orchestrator-agent
3. **Spawn reviewers** - Only for affected domains
4. **Assign review tasks** - Each reviewer checks:
   - Domain boundary violations (modifying files outside their module)
   - Design system compliance (hardcoded colors, fonts, spacing)
   - Architecture patterns (@Observable, @MainActor, repository pattern)
   - Cross-domain protocol usage (using protocols vs direct imports)
5. **Synthesize** - Lead collects findings and posts unified review

## Review Checklist Per Domain

### All Domains
- [ ] Uses design tokens (Color.vitalPrimary, Spacing.lg, .font(.vitalBody))
- [ ] ViewModels use @Observable (not ObservableObject)
- [ ] Repositories use @MainActor isolation
- [ ] No hardcoded values for colors, spacing, or fonts
- [ ] Cross-domain access uses Shared/Protocols/ not direct imports

### Workout
- [ ] Exercise seeds not modified without migration plan
- [ ] Mesocycle status transitions are valid
- [ ] Template encoding/decoding is correct

### Wellness
- [ ] HealthKit authorization checked before queries
- [ ] Health metrics properly mapped from HealthKit types
- [ ] Simulator fallbacks for HealthKit unavailability
