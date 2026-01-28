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

## Git Workflow

**Branch naming**: `dev/<platform>-<focus>-<session>.<minor>-YYYY-MM-DD`

| Component | Description | Required |
|-----------|-------------|----------|
| `dev/` | Branch prefix | Yes |
| `<platform>` | `mac` or `cloud` | Yes |
| `<focus>` | Feature area (e.g., `nutrition`, `workout`) or `session` for general work | Yes |
| `<session>` | Session number from SESSION_LOG.md | Yes |
| `<minor>` | Sub-version for same day (0, 1, 2...) | Yes |
| `<date>` | ISO date (YYYY-MM-DD) | Yes |

**Valid examples**:
- `dev/mac-nutrition-12.0-2026-01-27` - Working on nutrition feature on macOS
- `dev/mac-session-12.0-2026-01-27` - General work on macOS
- `dev/cloud-workout-12.0-2026-01-27` - Working on workout on cloud

**Invalid examples**:
- `claude/vitalarc-start-UA45Z` - Wrong prefix, missing required parts
- `dev/nutrition-12.0-2026-01-27` - Missing platform
- `feature/nutrition` - Wrong prefix, missing session info

**Conventional Commits**: All commits must follow this format:

```
<type>(<scope>): <description>

[optional body]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
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

**Scopes:** `workout`, `nutrition`, `health`, `analytics`, `ui`, `infra`, `session`

**Examples:**
```
feat(workout): add custom exercise creation
fix(nutrition): correct calorie calculation for meals
docs(session): update session 8 documentation
refactor(ui): migrate ProfileView to design tokens
```

## Architecture Overview

VitalArc uses **Clean Architecture** with **MVVM** pattern:

```
VitalArc/
├── Domain/           # Pure Swift business logic (no framework dependencies)
│   ├── Entities/     # Business models (UserProfile, Workout, Food, HealthMetrics, Mesocycle)
│   ├── Repositories/ # Protocol definitions for data access
│   └── UseCases/     # Business logic operations (single responsibility)
├── Data/
│   ├── Models/       # SwiftData @Model classes (persist Domain entities)
│   └── Seeds/        # Exercise database seeds (200+ exercises by body part)
├── Infrastructure/
│   ├── HealthKit/    # HealthKitManager, permissions, queries
│   ├── Networking/   # Food API clients (Nutritionix, OpenFoodFacts, USDA)
│   ├── Cache/        # FoodCache for API response caching
│   └── Export/       # PDF/CSV export utilities
└── Presentation/
    ├── Common/       # Design system, shared components
    ├── Onboarding/   # Welcome, profile setup, HealthKit permissions
    └── Tabs/         # Main app tabs (Health, Workout, Nutrition, Profile)
```

### Key Architectural Patterns

**Dependency Injection**: `DependencyContainer` holds all repositories and is injected via SwiftUI environment:
```swift
@Environment(\.dependencyContainer) private var container
```

**Repository Pattern**: Domain defines protocols, Data provides SwiftData implementations:
```swift
// Domain/Repositories/WorkoutRepository.swift - protocol
// Infrastructure/DependencyContainer.swift - SwiftDataWorkoutRepository implementation
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
Spacing.xs (4)    Spacing.sm (8)     Spacing.md (12)
Spacing.lg (16)   Spacing.xl (24)    Spacing.xxl (48)
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

- `VitalArcApp.swift` - App entry, SwiftData schema, DependencyContainer setup
- `DependencyContainer.swift` - All repository implementations
- `MainTabView.swift` - Main app navigation (Health, Workout, Nutrition, Profile tabs)
- `Presentation/Common/DesignSystem/` - Colors, Typography, Spacing, Components

## Codebase Statistics

- **152 Swift files**, ~35,000 lines of code
- **70 presentation views**, 10 ViewModels, 16 use cases
- **14 design system files** (complete), ~90% view adoption
- **6 test files**, ~68% preview coverage

## API Configuration

Food APIs have placeholder keys that need to be configured:
- `NutritionixAPI.swift`: `YOUR_APP_ID`, `YOUR_APP_KEY` → Get from nutritionix.com
- `USDAFoodAPI.swift`: `DEMO_KEY` → Get from fdc.nal.usda.gov
- `OpenFoodFactsAPI.swift`: No key required (public API)

Food search will fail or be rate-limited until proper keys are set.

## GitHub Workflows & CI/CD

Automated workflows are configured in `.github/workflows/`:

| Workflow | Purpose |
|----------|---------|
| `ci.yml` | Build verification, tests, SwiftLint on PRs and main |
| `pr-automation.yml` | Auto-labeling, PR size tracking, welcome messages |
| `claude-review.yml` | AI-powered code review (requires `ANTHROPIC_API_KEY` secret) |

**PR Requirements:**
- Title must follow conventional commits format
- CI checks must pass (build + tests)
- SwiftLint warnings should be addressed

**Labels are auto-applied based on:**
- Files changed (architecture layers, feature areas)
- Branch name patterns
- Conventional commit type in title
- PR size (XS/S/M/L/XL)

## Current Status

See `PROJECT_STATUS.md` for feature status and `SESSION_LOG.md` for development history.

## For Humans

See `/docs/` for detailed documentation:
- `DESIGN_SYSTEM.md` - Complete component and token reference
- `ARCHITECTURE.md` - Deep-dive into app architecture
- `SETUP.md` - Development environment setup guide
