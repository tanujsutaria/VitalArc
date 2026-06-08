# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Agent Note**: The `/docs/` folder contains detailed human documentation (design system reference, architecture deep-dive, setup guide). Do not read these unless specifically asked - they're for human developers, not agent context.

## Build Commands

```bash
# Build the app
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run tests
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

# Quick build check (grep for errors)
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD SUCCEEDED|BUILD FAILED)"
```

HealthKit features require a physical device with Apple Developer account and HealthKit entitlements configured.

## Verification

Always verify work with concrete feedback loops:
- **Code changes**: Run the build (`xcodebuild ... build`) after modifications
- **Test changes**: Run affected tests to confirm they pass
- **UI changes**: Check SwiftUI previews or simulator if available
- **Design system**: Run design-system-scanner on modified views

Concrete verification produces significantly better results than assumption-based work.

## Git Workflow

**Branch naming**: `dev/<platform>-<focus>-<session>.<minor>-YYYY-MM-DD`

| Component | Description | Required |
|-----------|-------------|----------|
| `dev/` | Branch prefix | Yes |
| `<platform>` | `mac` or `cloud` | Yes |
| `<focus>` | Feature area (e.g., `workout`, `wellness`) or `session` for general work | Yes |
| `<session>` | Session number from SESSION_LOG.md | Yes |
| `<minor>` | Sub-version for same day (0, 1, 2...) | Yes |
| `<date>` | ISO date (YYYY-MM-DD) | Yes |

**Valid examples**:
- `dev/mac-wellness-12.0-2026-01-27` - Working on wellness feature on macOS
- `dev/mac-session-12.0-2026-01-27` - General work on macOS
- `dev/cloud-workout-12.0-2026-01-27` - Working on workout on cloud

**Cloud session exception**: When using Claude Code platform (phone/browser), the platform controls the branch name using format `claude/<skill>-<sessionID>`. This is acceptable for cloud sessions since manual branch creation isn't available.

**Invalid examples**:
- `dev/wellness-12.0-2026-01-27` - Missing platform
- `feature/wellness` - Wrong prefix, missing session info

**Conventional Commits**: All commits must follow this format:

```
<type>(<scope>): <description>

[optional body]

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Types:**
| Type | Description |
|------|-------------|
| `feat` | New feature or functionality |
| `fix` | Bug fix |
| `docs` | Documentation only changes |
| `style` | Code style (formatting, whitespace) |
| `refactor` | Code change that neither fixes nor adds features |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system or dependency changes |
| `chore` | Other maintenance tasks |

**Scopes:** `workout`, `health`, `analytics`, `ui`, `infra`, `session`

**Examples:**
```
feat(workout): add custom exercise creation
fix(health): correct recovery score calculation
docs(session): update session 8 documentation
refactor(ui): migrate ProfileView to design tokens
```

## Session Skills

Use platform-specific skills to start and end development sessions:

### Workstreams

| Skill | Platform | Best For |
|-------|----------|----------|
| `/vitalarc-start-workstation` | Mac | Feature dev, UI work, testing, large changes |
| `/vitalarc-start-cloud` | Phone/Browser | Bug fixes, docs, code review, small changes |
| `/vitalarc-end-workstation` | Mac | Full build verification, comprehensive close |
| `/vitalarc-end-cloud` | Phone/Browser | Quick close, no build check |

### When to Use Each

**Workstation** 🖥️ (Mac):
- New feature development
- UI/UX changes (need simulator)
- Large refactors
- Work requiring builds/tests
- HealthKit integration

**Cloud** ☁️ (Phone/Browser):
- Bug fixes (logic bugs, not UI)
- Documentation updates
- Code review
- Small, targeted changes
- Quick fixes on the go

### Session Log Format

Both workstreams use an enhanced session log with a **Work Log table** for tracking progress:

```markdown
### Work Log
| Time | Action | Files | Notes |
|------|--------|-------|-------|
| 7:30 | Session started | - | Focus: bug fix |
| 7:45 | Fixed bug | ProfileVM.swift | Off-by-one error |
| 8:00 | Session ended | - | Complete |
```

## Agent Swarms

Skills in `.claude/skills/` serve as **prompt templates** for specialized tasks. They use native Claude Code frontmatter for execution control.

> **Opus 4.8 Note**: This model has strong native subagent orchestration. Use subagents when tasks can run in parallel or require isolated context. For simple tasks, single-file edits, or sequential operations, work directly rather than delegating.

### Skill Frontmatter

| Field | Purpose | Example |
|-------|---------|---------|
| `context: fork` | Run in isolated subagent context | All worker skills |
| `agent:` | Specify agent type for execution | `Explore`, `Plan`, `Bash`, `general-purpose` |
| `disable-model-invocation: true` | User-triggered only (has side effects) | Session starters, commit-formatter, design-system-fixer |
| `allowed-tools:` | Tools available to the skill | `Read, Grep, Glob, Bash` |

### Skill Categories

**Orchestrators** (coordinate other tasks):
- Session starters/enders - Use TaskCreate with `addBlockedBy` for dependency graphs
- `feature-planner` - Pipeline: Analysis → Domain → UI → Wiring → Tests

**Workers** (run in forked context with `context: fork`):

| Agent Type | Use For | Skills |
|------------|---------|--------|
| `Explore` | Read-only analysis | focus-suggester, design-system-scanner, design-system-auditor, coverage-analyzer, config-validator, cloud-quality-gate, session-checkpoint |
| `Plan` | Architecture design | domain-modeler, swiftui-architect, dependency-wirer |
| `general-purpose` | Read-write & command execution | build-validator, lint-validator, test-runner, worktree-manager, commit-formatter, test-scaffolder, progress-tracker, design-system-fixer, pr-formatter, task-dashboard, review-resolver |
| `feature-dev:code-reviewer` | Code review | pr-reviewer |

### Skill Invocation Types

Skills are classified by whether they can run autonomously (no arguments) or require user input:

| Type | Skills | Can Auto-invoke? |
|------|--------|-------------------|
| **Autonomous** (no args needed) | focus-suggester, build-validator, design-system-auditor, session-checkpoint, cloud-quality-gate, progress-tracker, task-dashboard | Yes - always |
| **Args Optional** (has defaults) | design-system-scanner, design-system-fixer, config-validator, lint-validator, test-runner, coverage-analyzer, pr-formatter, commit-formatter, test-scaffolder | Yes - uses defaults |
| **Args Required** | dependency-wirer, worktree-manager, pr-reviewer, review-resolver, feature-planner, domain-modeler, swiftui-architect | No - needs user input |

**For orchestrator skills**: When invoking "Args Optional" skills programmatically (e.g., from `vitalarc-start-workstation`), they will execute with defaults. No clarification needed.

### Parallel Execution

When tasks are independent and can run concurrently, launch multiple TaskCreate calls in a single message. For simple, sequential operations or tasks that share context, work directly rather than delegating to subagents.

```javascript
// All three run simultaneously
TaskCreate({ subject: "Analyze focus areas", ... })
TaskCreate({ subject: "Validate build", ... })
TaskCreate({ subject: "Scan design system", ... })
```

For sequential dependencies, use `addBlockedBy`:

```javascript
TaskCreate({
  subject: "Create session log",
  addBlockedBy: ["task-focus-id", "task-build-id", "task-scan-id"]
})
```

### Available Skills

**Session Management:**
- `/focus-suggester` - Recommend development focus areas
- `/progress-tracker` - Update SESSION_LOG.md Work Log
- `/commit-formatter` - Generate conventional commit messages
- `/session-checkpoint` - Mid-session progress verification
- `/task-dashboard` - Real-time task progress visualization

**Feature Development:**
- `/domain-modeler` - Design domain entities, repositories, use cases
- `/swiftui-architect` - Design view hierarchies and state management
- `/feature-planner` - Plan full feature architecture (with parallelized analysis)
- `/test-scaffolder` - Generate XCTest files

**Quality & Validation:**
- `/build-validator` - Verify Xcode build passes
- `/test-runner` - Execute tests (required gate at session end)
- `/lint-validator` - Run SwiftLint on changed files
- `/design-system-scanner` - Find design token violations (read-only)
- `/design-system-fixer` - Fix design token violations (workstation only)
- `/design-system-auditor` - Comprehensive design audit
- `/config-validator` - Check API keys and entitlements
- `/coverage-analyzer` - Identify untested code
- `/cloud-quality-gate` - Validate without builds (cloud sessions)

**Code Review & PR:**
- `/pr-formatter` - Generate PR title and body
- `/pr-reviewer` - Analyze pull requests (with worktree option)
- `/review-resolver` - Track and resolve PR review findings

**Worktree Management:**
- `/worktree-manager` - Create/list/remove/switch git worktrees for parallel development

## Architecture Overview

VitalArc uses **Clean Architecture** with **MVVM** pattern, organized into **domain-bounded modules**:

```
VitalArc/
├── App/                          # App entry point
│   ├── VitalArcApp.swift         # SwiftData schema, DependencyContainer setup
│   └── MainTabView.swift         # Tab navigation
├── Modules/
│   ├── Workout/                  # Workout domain (exercises, sets, mesocycles, templates)
│   │   ├── Domain/               # Entities, Repositories, UseCases
│   │   ├── Data/                 # SwiftData Models, Seeds (200+ exercises)
│   │   ├── Infrastructure/       # SwiftDataWorkoutRepository, etc.
│   │   └── Presentation/         # Views, ViewModels
│   ├── Wellness/                 # Health/Wellness domain (HealthKit, metrics, sleep)
│   │   ├── Domain/               # Entities, Repositories, UseCases
│   │   ├── Data/                 # SwiftData Models
│   │   ├── Infrastructure/       # HealthKit, Mappers, Repositories
│   │   └── Presentation/         # Views, ViewModels
│   └── Shared/                   # Cross-domain code
│       ├── User/                 # User profile, onboarding
│       ├── Analytics/            # Progress tracking, reports
│       ├── Notifications/        # Notification scheduling
│       ├── Protocols/            # Cross-domain data access protocols
│       ├── DependencyContainer/  # DI containers (main + per-domain)
│       ├── DesignSystem/         # Colors, Typography, Spacing, Components
│       ├── Export/               # PDF/CSV exporters
│       └── Common/               # Shared UI components
```

### Key Architectural Patterns

**Dependency Injection**: `DependencyContainer` holds all repositories and is injected via SwiftUI environment:
```swift
@Environment(\.dependencyContainer) private var container
```

**Repository Pattern**: Domain defines protocols, Infrastructure provides SwiftData implementations:
```swift
// Modules/Workout/Domain/Repositories/WorkoutRepository.swift - protocol
// Modules/Shared/DependencyContainer/DependencyContainer.swift - SwiftDataWorkoutRepository implementation
```

**Use Cases**: Single-purpose business operations that ViewModels call:
```swift
let workout = try await createWorkoutUseCase.execute(sets: workoutSets)
```

**ViewModels**: `@Observable` classes that hold view state and call use cases:
```swift
@Observable
final class ProfileViewModel {
    var profile: UserProfile?
    var isLoading = false
}
```

### Data Flow

1. View calls ViewModel method
2. ViewModel calls UseCase
3. UseCase calls Repository protocol
4. Repository implementation (SwiftData) performs operation
5. Domain entity returned up the chain

### SwiftData Models

All persistence uses SwiftData. Models have `fromDomain()` and `toDomain()` converters:
```swift
// Data model stores data
@Model class WorkoutModel { ... }

// Domain entity for business logic
struct Workout { ... }

// Conversions
WorkoutModel.fromDomain(workout)  // Domain → Data
workoutModel.toDomain()           // Data → Domain
```

### Thread Safety

All repositories and ViewModels use `@MainActor` isolation for SwiftData thread safety.

## Design System

**Always use design tokens instead of hardcoded values.**

> **Note**: Design system adoption is currently ~90%. A few older views still have minor hardcoded values. When modifying these views, migrate to design tokens.

### Colors
```swift
Color.vitalPrimary              // Primary actions (indigo)
Color.vitalDanger               // Errors, destructive (red)
Color.vitalSuccess              // Success states (green)
Color.vitalWarning              // Warnings (amber)
Color.vitalInfo                 // Information (blue)
Color.vitalAdaptiveBackground   // Screen backgrounds
Color.vitalAdaptiveSurface      // Card/elevated surfaces
Color.vitalAdaptiveTextPrimary  // Primary text
Color.vitalAdaptiveTextSecondary // Secondary text
```

### Spacing
```swift
Spacing.xs (4)    Spacing.sm (8)     Spacing.md (16)
Spacing.lg (24)   Spacing.xl (32)    Spacing.xxl (48)
Spacing.screenPadding (20)          Spacing.cardPadding (16)
Spacing.radiusSmall (8)             Spacing.radiusMedium (12)
```

### Typography
```swift
.font(.vitalDisplayLarge)   // 34pt bold
.font(.vitalH1)             // 22pt bold
.font(.vitalH2)             // 20pt semibold
.font(.vitalBody)           // 14pt regular
.font(.vitalCaption)        // 12pt
```

### Components
- `VitalCard` - Standard card container
- `VitalButton` - Primary/secondary/danger buttons
- `VitalTextField` - Text input with validation
- `VitalEmptyState` - Empty state placeholder

## Unit System

Internal storage uses **metric** (kg, cm) for HealthKit compatibility. Display uses **American units** (lbs, ft/in) by default.

Use `UnitConversion` helpers in `ProfileViewModel.swift`:
```swift
UnitConversion.kgToLbs(weight)                    // kg → lbs
UnitConversion.lbsToKg(weight)                    // lbs → kg
UnitConversion.cmToFeetInches(height)             // cm → (feet, inches)
UnitConversion.feetInchesToCm(feet:inches:)       // ft/in → cm
```

## Key Files

- `App/VitalArcApp.swift` - App entry, SwiftData schema, DependencyContainer setup
- `Modules/Shared/DependencyContainer/DependencyContainer.swift` - Orchestrator DI container
- `Modules/Shared/DependencyContainer/WorkoutContainer.swift` - Workout domain DI
- `Modules/Shared/DependencyContainer/WellnessContainer.swift` - Wellness domain DI
- `Modules/Shared/DependencyContainer/SharedContainer.swift` - Shared/cross-domain DI
- `App/MainTabView.swift` - Main app navigation (Today, Workout, Progress, Profile)
- `Modules/Shared/DesignSystem/` - Colors, Typography, Spacing, Components
- `Modules/Shared/Protocols/` - Cross-domain data access protocols

## Codebase Statistics

- **~193 Swift files**, ~47,000 lines of code (app target, excludes tests)
- **~63 presentation views**, ~19 ViewModels
- **14 design system files**, high design-token adoption
- **~49 test files**

> Stats are approximate; regenerate from source rather than hand-editing.

## API Configuration

No third-party API keys are required. (The food-tracking APIs — Nutritionix, USDA FoodData Central, OpenFoodFacts — were removed with the Nutrition module.) CI's "Generate Secrets file" step copies `Modules/Shared/Security/Secrets.template.txt` to a gitignored `Secrets.swift` at build time; the committed `project.pbxproj` references `Secrets.swift`, so after deleting/adding files run `xcodegen generate` with that file present.

## GitHub Workflows & CI/CD

Automated workflows are configured in `.github/workflows/`:

| Workflow | Purpose |
|----------|---------|
| `ci.yml` | Build verification, tests, SwiftLint on PRs and main |
| `pr-automation.yml` | Auto-labeling, PR size tracking, welcome messages |
| `openai-review.yml` | AI-powered code review with GPT-5.2-Codex (requires `OPENAI_API_KEY` secret) |

**PR Requirements:**
- Title must follow conventional commits format
- CI checks must pass (build + tests)
- SwiftLint warnings should be addressed

**Labels are auto-applied based on:**
- Files changed (architecture layers, feature areas)
- Branch name patterns
- Conventional commit type in title
- PR size (XS/S/M/L/XL)

## Domain Modules & Agent Teams

The codebase is organized into **domain-bounded modules** for parallel agent team development.

### Module Ownership

| Module | Agent | Directory | Key Files |
|--------|-------|-----------|-----------|
| **Workout** | `workout-agent` | `Modules/Workout/` | Exercises, sets, mesocycles, templates |
| **Wellness** | `wellness-agent` | `Modules/Wellness/` | HealthKit, health metrics, sleep |
| **Shared** | `orchestrator-agent` | `Modules/Shared/`, `App/` | User, analytics, DI, design system |

### Cross-Domain Protocols

Domains communicate via read-only protocols in `Modules/Shared/Protocols/`:

| Protocol | Purpose | Used By |
|----------|---------|---------|
| `WorkoutDataProviding` | Read-only workout data | Analytics |
| `HealthDataProviding` | Read-only health metrics | Analytics, Recovery |
| `UserProfileProviding` | Read-only user profile | Analytics |

### Agent Team Skills

- `/team-feature` - Spawn domain agents for multi-domain feature work
- `/team-review` - Spawn reviewers per domain for PR review

### DependencyContainer Structure

The main `DependencyContainer` delegates to domain sub-containers:
```swift
DependencyContainer
├── workout: WorkoutContainer      (workoutRepository, mesocycleRepository, templateRepository)
├── wellness: WellnessContainer    (healthRepository)
└── shared: SharedContainer        (userRepository, analyticsRepository, notifications, TDEE)
```

Backward-compatible: `container.workoutRepository` still works (delegates to `container.workout.workoutRepository`).

## Current Status

See `PROJECT_STATUS.md` for feature status and `SESSION_LOG.md` for development history.

## For Humans

See `/docs/` for detailed documentation:
- `DESIGN_SYSTEM.md` - Complete component and token reference
- `ARCHITECTURE.md` - Deep-dive into app architecture
- `SETUP.md` - Development environment setup guide
