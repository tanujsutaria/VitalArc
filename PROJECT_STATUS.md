# VitalArc Project Status

**Last Updated**: January 31, 2026 (Session 15.1)
**Build**: Passing ✅ (Workstation verified)
**Tests**: 291 passing ✅
**Stage**: MVP-Ready

---

## Current State

The app compiles and runs with core MVP requirements addressed:
- American units enforced across all screens
- Design system ~99% adopted
- Settings/About features implemented
- Standardized error handling
- Analytics export (PDF/CSV) functional
- In-app feedback mechanism
- Recovery score algorithm implemented
- TRIMP/Strain calculation implemented
- Notification system architecture complete (Session 14)
- NotificationSchedulerProtocol enables DI/testability (Session 14)
- Notification use cases wired into ViewModel (Session 15.1)
- TDEE integrated into Nutrition tab UI (Session 15.1)

**Ready for beta testing.**

---

## Feature Status

| Feature | Status | Notes |
|---------|--------|-------|
| Health Dashboard | Ready | Uses lbs |
| Workout Tracking | Ready | Minor polish needed |
| Exercise Library | Ready | 960+ exercises |
| Templates System | Ready | Day-by-day editor |
| Mesocycle System | Ready | - |
| Analytics Dashboard | Ready | TRIMP integrated, gender-aware |
| Recovery Score | Ready | HRV + HealthKit HR integration |
| Strain Tracking | Ready | TRIMP + HealthKit HR, custom settings |
| Nutrition Tracking | Ready | **API keys not configured** |
| Design System | Ready | ~99% adoption |
| Profile/Settings | Ready | - |

### Partially Implemented

| Feature | Done | Missing |
|---------|------|---------|
| Sleep Analysis | Basic score | Sleep stage analysis |
| Nutrition Algorithm | Daily totals, TDEE estimation, TDEE UI integration | Macro tracking refinement |
| Notifications | UI, ViewModel, Repository, Use Cases (wired), Infrastructure, Protocol | - |

### Not Implemented

| Feature | Priority |
|---------|----------|
| Apple Watch | Medium |
| Widgets | Medium |
| CloudKit Sync | Medium |
| AI Features | Low |
| Social Features | Low |

---

## Known Issues

1. **API Keys**: Food APIs need configuration
   - `NutritionixAPI.swift`: placeholder keys
   - `USDAFoodAPI.swift`: demo key (rate-limited)

2. **Design System Gaps**: Near complete
   - ~126 frame dimension violations (acceptable for charts)
   - ~4 minor violations (cornerRadius, padding)

3. **Cloud Session Test Files**: ~15 files on disk need fixes before integration
   - Wrong entity constructors, duplicate mocks, enum mismatches
   - See SESSION_LOG.md Session 14 for details

---

## Codebase Stats

| Metric | Value |
|--------|-------|
| Swift files | ~190 |
| Lines of code | ~44,000 |
| Views | 73 |
| ViewModels | 12 |
| Use cases | 25 |
| Test files | 14 (in project) |
| Unit tests | 291 (passing) |

### Test Coverage by ViewModel

| ViewModel | Status | Tests | Notes |
|-----------|--------|-------|-------|
| OnboardingViewModel | Pending | - | Test file needs fixes |
| ProfileViewModel | Pending | - | Test file needs fixes |
| FoodSearchViewModel | Pending | - | Test file needs fixes |
| FoodLoggingViewModel | Tested | ~20 | In project ✅ |
| WorkoutLoggingViewModel | Tested | 28 | In project ✅ |
| MetricDetailViewModel | Tested | ~10 | In project ✅ |
| ExerciseLibraryViewModel | Pending | - | Test file needs fixes |
| WorkoutHistoryViewModel | Pending | - | Test file needs fixes |
| HealthDashboardViewModel | Pending | - | Test file needs fixes |
| MesocycleViewModel | Pending | - | Test file needs fixes |
| NotificationSettingsViewModel | Pending | - | Test file needs fixes |
| AnalyticsDashboardViewModel | Pending | - | Test file needs fixes |

**Note**: Cloud sessions created test files for 8 additional ViewModels (~195 tests), but they require fixes before integration. Files exist on disk in `VitalArcTests/`.
