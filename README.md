# VitalArc

**A unified iOS fitness platform combining workout tracking, nutrition management, and health analytics.**

VitalArc integrates workout tracking, nutrition logging, and health analytics into a single app that leverages Apple Health for comprehensive fitness data.

## Current Status

**Stage**: MVP-Ready

| Feature | Status |
|---------|--------|
| Health Dashboard | ✅ Ready |
| Workout Tracking | ✅ Ready |
| Exercise Library | ✅ 960+ exercises |
| Templates & Mesocycles | ✅ Ready |
| Nutrition Tracking | ✅ Ready |
| Food Search (API) | ⚠️ API keys not configured |
| Analytics Dashboard | ✅ Ready |
| Design System | ✅ ~99% adoption |
| Recovery Score | ✅ HRV algorithm + HealthKit integration |
| Sleep Analysis | ✅ Stage breakdown + quality scoring + consistency |
| Macro Goal Editing | ✅ TDEE-based recommendations |
| Notifications | ✅ Complete architecture + goal/streak/PR types |
| Blood Oxygen (SpO2) | ✅ HealthKit integration |
| VO2 Max | ✅ HealthKit integration |
| VoiceOver Accessibility | ✅ Labels, hints, values across all views |

See `PROJECT_STATUS.md` for detailed status.

## Roadmap

### Completed
| Feature | Status |
|---------|--------|
| Recovery Score | ✅ V2 with configurable weights + component breakdown |
| Strain Tracking | ✅ TRIMP calculation + custom settings |
| Nutrition Algorithm | ✅ TDEE estimation + UI integration + macro goal editing |
| Notifications | ✅ UI, ViewModel, use cases, goal notification cancellation |
| Sleep Analysis | ✅ Stage breakdown, quality scoring, 7-day trends, consistency |
| Wellness Accessibility | ✅ VoiceOver labels across all wellness views |
| Workout History & Trends | ✅ PR tracking, rest timer, supersets, plate calculator, progressive overload charts |
| Water Tracking | ✅ Manual logging with daily goals, timezone-aware reset |
| Body Composition | ✅ Body fat %, lean mass, waist/hip/chest/arm/thigh measurements + trends |
| HRV Tracking | ✅ Trend visualization with 7/30/90-day windows |
| Muscle Heat Maps | ✅ Training frequency visualization per muscle group |
| Volume Analysis | ✅ Per-muscle-group volume breakdown + weekly/monthly trends |
| Configurable Meal Times | ✅ User-defined breakfast/lunch/dinner/snack ranges |

### In Progress
| Feature | Status | Remaining |
|---------|--------|-----------|
| Body Composition | Waist/hip/chest/arm/thigh measurements + trends | HealthKit body fat sync |

### Planned
| Feature | Priority | Description |
|---------|----------|-------------|
| Apple Watch | Medium | Companion app for workout tracking |
| Widgets | Medium | Home screen glanceables |
| CloudKit Sync | Medium | Cross-device data sync |
| AI Features | Low | Predictive insights, coaching |
| Social Features | Low | Progress sharing, challenges |

## Core Features

### Workout Tracking
- Mesocycle-based periodization with progression
- RIR (Reps in Reserve) tracking and volume autoregulation
- Feedback-driven adjustments based on pump, soreness, performance
- Day-by-day template editor with day scheduling
- Per-exercise progressive overload charts (weight/volume/1RM)
- Per-set notes, rest timer, superset/circuit support
- 960+ exercise library organized by equipment type

### Nutrition Tracking
- Timeline-based food logging
- Multi-API food search (Nutritionix, OpenFoodFacts, USDA)
- Macro and calorie tracking with fiber/sugar micronutrients
- Edit food entry quantity with proportional macro recalculation
- Quick re-log from history
- Cached API responses for performance

### Health Analytics
- Recovery score based on HRV trends
- Sleep stage analysis (deep/REM/light/awake) with quality scoring and consistency
- Blood oxygen (SpO2) and VO2 Max tracking via HealthKit
- 7-day sleep trend visualization
- Weight and body metrics tracking
- PDF/CSV export for analytics data

## Technical Stack

- **Platform**: iOS 17+
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: Clean Architecture + MVVM
- **Local Storage**: SwiftData
- **Health Integration**: HealthKit

## Project Structure

```
VitalArc/
├── App/                     # App entry point, main tab view
├── Modules/
│   ├── Workout/             # Workout tracking, exercises, mesocycles, templates
│   │   ├── Domain/          # Entities, repositories, use cases
│   │   ├── Data/            # SwiftData models, exercise seeds
│   │   ├── Infrastructure/  # Repository implementations
│   │   └── Presentation/    # Views, ViewModels
│   ├── Nutrition/           # Food search, logging, API integration
│   │   ├── Domain/          # Entities, repositories, use cases
│   │   ├── Data/            # SwiftData models
│   │   ├── Infrastructure/  # API clients, cache, models
│   │   └── Presentation/    # Views, ViewModels
│   ├── Wellness/            # HealthKit, health metrics, sleep
│   │   ├── Domain/          # Entities, repositories, use cases
│   │   ├── Data/            # SwiftData models
│   │   ├── Infrastructure/  # HealthKit integration
│   │   └── Presentation/    # Views, ViewModels
│   └── Shared/              # Cross-domain: user, analytics, design system
│       ├── Analytics/       # Progress, recovery, strain
│       ├── DesignSystem/    # Colors, Typography, Spacing, Components
│       ├── DependencyContainer/ # DI orchestrator + sub-containers
│       ├── Protocols/       # Cross-domain data protocols
│       ├── User/            # Profile, onboarding, settings
│       └── Notifications/   # Notification scheduling
└── docs/                    # Documentation
```

## Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ device (HealthKit requires physical device)
- Apple Developer account (for HealthKit entitlements)

### Setup
1. Clone the repository
2. Open `VitalArc.xcodeproj` in Xcode
3. Configure signing with your Apple Developer account
4. Enable HealthKit capability
5. Build and run on a physical device

### API Configuration
Food APIs have placeholder keys that need to be configured:
- `NutritionixAPI.swift`: Get keys from nutritionix.com
- `USDAFoodAPI.swift`: Get key from fdc.nal.usda.gov
- `OpenFoodFactsAPI.swift`: No key required (public API)

## Development

See `CLAUDE.md` for development conventions, build commands, and architecture details.

### Quick Commands
```bash
# Build
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Test
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## Codebase Stats

| Metric | Value |
|--------|-------|
| Swift files | ~230 |
| Lines of code | ~51,600 |
| Views | ~80 |
| ViewModels | 14 |
| Use cases | 27 |
| Unit tests | 1096 |
| Exercises | 960+ |

## Author

tanujsutaria
