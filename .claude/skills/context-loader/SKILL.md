---
name: context-loader
description: Reads project documentation and establishes session context. Loads CLAUDE.md, PROJECT_STATUS.md, recent SESSION_LOG.md entries.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep
argument-hint: [--verbose]
---

# Context Loader

Establishes session context by reading key project documents. Provides summary to orchestrator for decision-making.

## Documents Loaded

| Document | Purpose | Lines Read |
|----------|---------|------------|
| CLAUDE.md | Project conventions, architecture, commands | Full |
| PROJECT_STATUS.md | Feature status, known issues, stats | Full |
| SESSION_LOG.md | Recent session history | Last 100 lines |
| README.md | Roadmap section | Roadmap only |

## Implementation

### 1. Load CLAUDE.md

```bash
# Read full CLAUDE.md for project conventions
cat CLAUDE.md
```

Extract key information:
- Build commands
- Git workflow rules
- Architecture overview
- Design system tokens
- Current status

### 2. Load PROJECT_STATUS.md

```bash
cat PROJECT_STATUS.md
```

Extract:
- Feature completion status
- Known issues
- Codebase statistics
- Recent changes

### 3. Load Recent SESSION_LOG.md

```bash
# Last 100 lines covers ~2-3 recent sessions
tail -100 SESSION_LOG.md
```

Extract:
- Previous session outcomes
- Work in progress
- Noted blockers
- Suggested next steps

### 4. Load README.md Roadmap

```bash
# Extract just the Roadmap section
sed -n '/## Roadmap/,/^## /p' README.md | head -50
```

Extract:
- In Progress items
- Planned items
- Completed items

## Output Format

```markdown
## Project Context Loaded

### Project Overview
- **Name**: VitalArc
- **Type**: iOS fitness/health app
- **Architecture**: Clean Architecture + MVVM
- **Platform**: iOS 17+, SwiftUI, SwiftData

### Build Commands
```bash
# Build
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Test
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

### Current Status
- **Features**: 70% complete
- **Design System**: 90% adopted
- **Test Coverage**: ~68% preview coverage

### Known Issues
1. API keys need configuration (Nutritionix, USDA)
2. HealthKit requires physical device
3. [Other issues from PROJECT_STATUS.md]

### Recent Session Summary
- **Last Session**: 12.2 - Typography token migration
- **Outcome**: Completed icon size standardization
- **Next Steps**: Notifications feature, TRIMP integration

### Roadmap Priorities
**In Progress:**
- Notifications system
- Recovery score fine-tuning

**Planned (High Priority):**
- Analytics dashboard enhancements
- Export functionality

### Design System Conventions
- Colors: `Color.vitalPrimary`, `Color.vitalDanger`, etc.
- Spacing: `Spacing.sm`, `Spacing.md`, `Spacing.lg`
- Typography: `.font(.vitalH1)`, `.font(.vitalBody)`
- Components: `VitalCard`, `VitalButton`, `VitalTextField`

### Git Conventions
- Branch: `dev/<platform>-<focus>-<session>.<minor>-YYYY-MM-DD`
- Commits: `<type>(<scope>): <description>`
- Types: feat, fix, docs, style, refactor, perf, test, build, chore
```

## Context Summary (Compact)

For agents that need minimal context:

```markdown
## Context Summary

**Project**: VitalArc (iOS fitness app, SwiftUI + SwiftData)
**Status**: 70% features, 90% design system
**Last Session**: 12.2 - Typography tokens
**Priority**: Notifications, Recovery scoring
**Build**: `xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
```

## Error Handling

### Missing Documents

```markdown
## ⚠️ Missing Documents

| Document | Status |
|----------|--------|
| CLAUDE.md | ✅ Found |
| PROJECT_STATUS.md | ❌ Missing |
| SESSION_LOG.md | ✅ Found |
| README.md | ✅ Found |

**Note**: PROJECT_STATUS.md not found. Some context may be incomplete.
```

### Parse Errors

If a document can't be parsed:

```markdown
## ⚠️ Parse Warning

Could not extract Roadmap section from README.md.
Continuing with available context.
```
