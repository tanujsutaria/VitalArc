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
| Design System | ✅ ~90% adoption |
| Recovery Score | ⚠️ HRV algorithm done, fine-tuning needed |

See `PROJECT_STATUS.md` for detailed status.

## Roadmap

### In Progress
| Feature | Status | Remaining |
|---------|--------|-----------|
| Recovery Score | HRV algorithm done | Fine-tuning |
| Strain Tracking | UI complete | TRIMP calculation |
| Sleep Analysis | Basic score | Sleep stage analysis |
| Nutrition Algorithm | Daily totals | Adaptive TDEE estimation |

### Planned
| Feature | Priority | Description |
|---------|----------|-------------|
| Notifications | High | Workout reminders, recovery alerts |
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
- Day-by-day template editor
- 960+ exercise library organized by equipment type

### Nutrition Tracking
- Timeline-based food logging
- Multi-API food search (Nutritionix, OpenFoodFacts, USDA)
- Macro and calorie tracking
- Cached API responses for performance

### Health Analytics
- Recovery score based on HRV trends
- Sleep quality analysis
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
├── Domain/                  # Pure Swift business logic
│   ├── Entities/            # Business models (UserProfile, Workout, Food, etc.)
│   ├── Repositories/        # Protocol definitions for data access
│   └── UseCases/            # Single-responsibility business operations
├── Data/
│   ├── Models/              # SwiftData @Model classes
│   └── Seeds/               # Exercise database (960+ exercises)
├── Infrastructure/
│   ├── HealthKit/           # HealthKitManager, permissions, queries
│   ├── Networking/          # Food API clients
│   ├── Cache/               # API response caching
│   └── Export/              # PDF/CSV export utilities
├── Presentation/
│   ├── Common/              # Design system, shared components
│   ├── Onboarding/          # Welcome, profile setup, permissions
│   └── Tabs/                # Main app tabs (Health, Workout, Nutrition, Profile)
└── docs/                    # Documentation
    ├── ARCHITECTURE.md      # Technical architecture deep-dive
    ├── DESIGN_SYSTEM.md     # Component and token reference
    └── SETUP.md             # Development environment setup
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
| Swift files | ~153 |
| Lines of code | ~35,000 |
| Views | 70 |
| ViewModels | 10 |
| Use cases | 16 |
| Exercises | 960+ |

## Author

tanujsutaria
