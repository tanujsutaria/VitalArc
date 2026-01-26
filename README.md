# VitalArc

**The unified iOS fitness platform combining workout tracking, nutrition management, and health analytics.**

VitalArc replaces three separate apps (RP Hypertrophy, MacroFactor, Athlytic/Bevel) with a single, integrated experience that leverages Apple Health for comprehensive fitness tracking.

## Core Features

### 1. Workout Tracking (RP Hypertrophy-style)
- Mesocycle-based periodization with automatic progression
- RIR (Reps in Reserve) tracking and volume autoregulation
- Feedback-driven set/rep adjustments based on pump, soreness, and performance
- MEV → MRV volume progression with intelligent deload scheduling
- 500+ exercise library with muscle group mapping

### 2. Nutrition Tracking (MacroFactor-style)
- Adaptive TDEE algorithm that learns from your data
- Timeline-based food logging with AI-powered entry
- Automatic macro adjustments based on weight trends
- Coached, Collaborative, and Manual program modes
- Comprehensive micronutrient tracking

### 3. Health Analytics (Athlytic/Bevel-style)
- Recovery score based on HRV and RHR trends
- Strain/exertion tracking with TRIMP methodology
- Sleep quality analysis with debt tracking
- Training load monitoring (Acute vs Chronic)
- Real-time readiness recommendations

### 4. Unified Intelligence (New Features)
- Cross-domain AI insights connecting workout, nutrition, and recovery
- Predictive analytics for optimal training timing
- Social features for sharing progress and competing
- Advanced correlation analysis across all health data

## Technical Stack

- **Platform**: iOS 17+ (iPhone), watchOS 10+ (Apple Watch)
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM + Clean Architecture
- **Local Storage**: SwiftData (Core Data successor)
- **Cloud Sync**: CloudKit
- **Health Integration**: HealthKit (read/write)
- **AI/ML**: Core ML, Create ML, on-device LLM integration

## Project Structure

```
VitalArc/
├── docs/
│   ├── specs/                    # Feature specifications
│   ├── architecture/             # Technical architecture docs
│   ├── ai-agent-tasks/          # Task files for AI implementation
│   └── api/                      # API documentation
├── VitalArc/                     # Main iOS app
│   ├── App/                      # App entry point
│   ├── Core/                     # Shared utilities, extensions
│   ├── Domain/                   # Business logic, use cases
│   ├── Data/                     # Repositories, data sources
│   ├── Presentation/             # Views, ViewModels
│   └── Infrastructure/           # HealthKit, CloudKit, ML
├── VitalArcWatch/               # watchOS companion app
├── VitalArcWidgets/             # Home screen widgets
└── Tests/                        # Unit and integration tests
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

## Development Phases

See [docs/specs/ROADMAP.md](docs/specs/ROADMAP.md) for the complete development roadmap.

### Phase 1: Foundation (Weeks 1-4)
- Project setup, HealthKit integration, data models
- Basic workout logging and exercise library

### Phase 2: Workout Engine (Weeks 5-8)
- Mesocycle creation and management
- RIR tracking and volume progression algorithms
- Feedback collection and autoregulation

### Phase 3: Nutrition System (Weeks 9-12)
- Food database and logging interface
- Adaptive TDEE algorithm
- Macro recommendations and adjustments

### Phase 4: Health Analytics (Weeks 13-16)
- Recovery score calculation
- Strain/exertion tracking
- Sleep analysis and recommendations

### Phase 5: Intelligence Layer (Weeks 17-20)
- Cross-domain insights and correlations
- Predictive recommendations
- AI-powered coaching

### Phase 6: Social & Polish (Weeks 21-24)
- Social features and sharing
- watchOS companion app
- Widgets and notifications

## Documentation

- [Product Requirements Document](docs/specs/PRD.md)
- [Technical Architecture](docs/architecture/ARCHITECTURE.md)
- [Data Models](docs/architecture/DATA_MODELS.md)
- [HealthKit Integration](docs/architecture/HEALTHKIT.md)
- [Algorithm Specifications](docs/specs/ALGORITHMS.md)
- [AI Agent Task List](docs/ai-agent-tasks/TASK_INDEX.md)

## Current Implementation Status

**Stage**: Pre-MVP (Foundation Built, Polish Required)

| Feature | Status |
|---------|--------|
| Workout Tracking | ✅ Built |
| Exercise Library | ✅ 200+ exercises seeded |
| Templates & Mesocycles | ✅ Built |
| Nutrition Logging | ✅ Built |
| Food Search (API) | ⚠️ Built, **API keys not configured** |
| Health Dashboard | ✅ Built |
| Analytics Dashboard | ✅ Built |
| Design System | ⚠️ 58% adoption |
| Recovery/Strain Algorithms | ⚠️ UI only, algorithms pending |
| TDEE Algorithm | ❌ Not implemented |
| AI Features | ❌ Not implemented |
| Apple Watch | ❌ Not implemented |
| CloudKit Sync | ❌ Not implemented |

See `PROJECT_STATUS.md` for detailed status and MVP blockers.

## License

Private repository - All rights reserved.

## Author

Tanuj Sutaria (tanujsutaria@gmail.com)
