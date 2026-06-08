# VitalArc

**A unified iOS fitness platform combining workout tracking and health analytics.**

VitalArc integrates workout tracking and health analytics into a single app that leverages Apple Health for comprehensive fitness data.

## Current Status

**Stage**: MVP-Ready

| Feature | Status |
|---------|--------|
| Health Dashboard | ✅ Ready |
| Workout Tracking | ✅ Ready |
| Exercise Library | ✅ 960+ exercises |
| Templates & Mesocycles | ✅ Ready |
| Analytics Dashboard | ✅ Ready |
| Design System | ✅ ~99% adoption |
| Recovery Score | ✅ HRV algorithm + HealthKit integration |
| Sleep Analysis | ✅ Stage breakdown + quality scoring + consistency |
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
| Notifications | ✅ UI, ViewModel, use cases, goal notification cancellation |
| Sleep Analysis | ✅ Stage breakdown, quality scoring, 7-day trends, consistency |
| Wellness Accessibility | ✅ VoiceOver labels across all wellness views |
| Workout History & Trends | ✅ PR tracking, rest timer, supersets, plate calculator, progressive overload charts |
| HRV Tracking | ✅ Trend visualization with 7/30/90-day windows |
| Muscle Heat Maps | ✅ Training frequency visualization per muscle group |
| Volume Analysis | ✅ Per-muscle-group volume breakdown + weekly/monthly trends |

### In Progress
_None currently._

> **Note:** Nutrition/food tracking (food logging, search, macros, water, body composition, TDEE) was removed in Session 27.0 to refocus the app on workout + health analytics.

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
No third-party API keys are required.

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
| Swift files | ~193 (app target) |
| Lines of code | ~47,000 |
| Views | ~63 |
| ViewModels | ~19 |
| Exercises | 960+ |

## Author

tanujsutaria
