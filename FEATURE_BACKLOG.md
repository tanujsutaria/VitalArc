# VitalArc Feature Backlog

**Generated**: February 5, 2026 | **Updated**: February 18, 2026 (Session 22.1)
**Method**: Agent team analysis (4 domain specialists explored all 201 Swift files)
**Total Features**: 61 (18 High, 25 Medium, 18 Low) | **Implemented**: 30

---

## Workout Domain (15 features)

### High Priority

#### W1. Rest Timer / Between-Set Timer ✅ (Session 18.4)
- **Complexity**: Small
- **Status**: Implemented with superset-aware rest logic
- **Files**: `WorkoutLoggingView.swift`, `SetRowView.swift`, `WorkoutLoggingViewModel.swift`

#### W2. Superset / Circuit / Giant Set Support ✅ (Session 18.4)
- **Complexity**: Medium
- **Status**: Implemented with grouping and edit group type
- **Files**: `WorkoutSet.swift`, `WorkoutLoggingViewModel.swift`, `ExerciseSetView.swift`

#### W3. Personal Records (PRs) Tracking ✅ (Session 18.4)
- **Complexity**: Medium
- **Status**: Implemented with PR detection, badges, and historical tracking
- **Files**: `PersonalRecord` entity, `DetectPersonalRecordUseCase`, `PersonalRecordsView.swift`

#### W4. Custom Exercise Creation UI ✅ (Session 18.4)
- **Complexity**: Small
- **Status**: Implemented with edit/delete support
- **Files**: `ExerciseLibraryView.swift`, `ExerciseLibraryViewModel.swift`

### Medium Priority

#### W5. Workout Detail / Review View ✅ (Session 21.0)
- **Complexity**: Small
- **Status**: Implemented with full set/weight review
- **Files**: `WorkoutDetailView.swift`, `WorkoutHistoryView.swift`

#### W6. Per-Exercise Progressive Overload Charts ✅ (Session 22.1)
- **Complexity**: Medium
- **Status**: Implemented with weight/volume/1RM charts via ExerciseLibrary
- **Files**: `ExerciseProgressView.swift`, `ExerciseLibraryView.swift`, `GetExerciseHistoryUseCase.swift`

#### W7. Live Workout Duration Timer ✅ (Session 21.0)
- **Complexity**: Small
- **Status**: Implemented with live-updating timer
- **Files**: `WorkoutLoggingView.swift`

#### W8. Estimated 1RM Calculation ✅ (Session 21.0)
- **Complexity**: Small
- **Status**: Implemented with historical PR comparison
- **Files**: `WorkoutSet` extension, `SetRowView.swift`, `WorkoutHistoryContentView.swift`

#### W9. Per-Set Notes ✅ (Session 22.1)
- **Complexity**: Small
- **Status**: Implemented with optional notes field on sets
- **Files**: `WorkoutSet.swift`, `WorkoutSetModel.swift`, `SetRowView.swift`

#### W10. Template Day Scheduling ✅ (Session 22.1)
- **Complexity**: Medium
- **Status**: Implemented with day-of-week picker per training block
- **Files**: `CreateMesocycleView.swift`, `MesocycleViewModel.swift`

### Low Priority

#### W11. Workout Sharing / Export
- **Complexity**: Medium
- **Insight**: No share functionality for workouts. Shared module has PDF/CSV exporters but they're analytics-focused.
- **Files**: New `WorkoutShareView`, integration with `Modules/Shared/Export/`

#### W12. Exercise Video/Image Integration
- **Complexity**: Large
- **Insight**: `Exercise` has `videoURL`/`imageURL` fields but ALL 200+ seeded exercises have `nil`. No media displayed anywhere.
- **Files**: All exercise seed files, `ExerciseRowView.swift`, new video player component

#### W13. Plate Calculator
- **Complexity**: Small
- **Insight**: Common QoL feature in workout apps. Users must mentally calculate plate loading.
- **Files**: New `PlateCalculatorView`

#### W14. Training Goal Selection in Mesocycle
- **Complexity**: Small
- **Insight**: `CreateMesocycleView` hardcodes `goal: .hypertrophy`. `TrainingGoal` enum has 4 cases but user cannot select one.
- **Files**: `CreateMesocycleView.swift`

#### W15. Muscle Group Filtering in Exercise Library
- **Complexity**: Small
- **Insight**: Exercises have `primaryMuscles`/`secondaryMuscles` but no UI for filtering by specific muscle group.
- **Files**: `ExerciseLibraryViewModel.swift`, `ExerciseLibraryView.swift`

### Workout Bonus Findings
- **Unit inconsistency**: `WorkoutLoggingView` shows "kg" but `MesocycleDetailView` shows "lbs". App convention is American units (lbs).
- **RPE gap**: `WorkoutSetData` DTO doesn't carry RPE even though `WorkoutSet` entity supports it.
- **Hardcoded defaults**: `CreateMesocycleView` hardcodes goal (hypertrophy) and phase template (standard).

---

## Nutrition Domain (15 features)

### High Priority

#### N1. Food Favorites ✅ (Session 18.4)
- **Complexity**: Small
- **Status**: Implemented with toggle button and favorites section
- **Files**: `FoodResultRowView.swift`, `FoodSearchView.swift`

#### N2. Recent/Frequent Foods ✅ (Session 18.4)
- **Complexity**: Small
- **Status**: Implemented with sort options
- **Files**: `FoodSearchView.swift`, `LogFoodUseCase`

#### N3. Custom Food Creation ✅ (Session 18.4)
- **Complexity**: Medium
- **Status**: Implemented with custom food creation flow
- **Files**: `CreateCustomFoodView.swift`, `FoodSearchView.swift`

#### N4. Water Tracking ✅ (Session 18.4)
- **Complexity**: Medium
- **Status**: Implemented with manual logging, daily goals, use cases, delete entry
- **Files**: `WaterEntry` entity/model, `NutritionTabContentView.swift`, `LogWaterUseCase`

### Medium Priority

#### N5. Micronutrient Display (Fiber/Sugar) ✅ (Session 22.0)
- **Complexity**: Small
- **Status**: Implemented end-to-end (entity → model → use case → DI → UI)
- **Files**: `FoodResultRowView.swift`, `FoodLoggingView.swift`, `NutritionTabContentView.swift`

#### N6. Edit Food Entry Quantity ✅ (Session 22.1)
- **Complexity**: Small
- **Status**: Implemented with swipe-to-edit and proportional macro recalculation
- **Files**: `UpdateFoodEntryUseCase.swift`, `FoodLoggingViewModel.swift`, `MealSectionView.swift`

#### N7. Quick Re-Log from History ✅ (Session 22.1)
- **Complexity**: Small
- **Status**: Implemented with swipe-to-relog using current date
- **Files**: `FoodLoggingViewModel.swift`, `MealSectionView.swift`

#### N8. Meal Templates / Saved Meals
- **Complexity**: Large
- **Insight**: Save a complete meal (e.g., "My usual breakfast") and log all items at once. High value for routine meals but significant scope.
- **Files**: New `MealTemplate` entity/model, repository, use case, template management view, "log from template" flow

#### N9. Copy Previous Day's Meals
- **Complexity**: Small
- **Insight**: Duplicate all entries from previous day. Simple implementation using existing use cases in a loop.
- **Files**: `NutritionTabContentView.swift`, new action using `GetFoodEntriesUseCase` + `LogFoodUseCase`

#### N10. Nutrition Streak / Consistency Tracking
- **Complexity**: Medium
- **Insight**: Track consecutive days of logging or hitting macro goals. Gamification motivates consistent logging.
- **Files**: New calculation from `DailyNutrition` history, streak counter UI

#### N11. Weekly/Monthly Nutrition Summary
- **Complexity**: Medium
- **Insight**: `MacroDetailSheet` shows 7-day trends. Extend with average daily intake, goal adherence %, best/worst days.
- **Files**: New summary view, data from `NutritionRepository.getFoodEntries(from:to:)`

### Low Priority

#### N12. Multi-Serving Size Units
- **Complexity**: Medium
- **Insight**: Quantity input hardcodes grams. `Food.servingUnit` exists but `QuantityInputView` doesn't use it.
- **Files**: `QuantityInputView.swift` (unit picker), conversion logic

#### N13. Food Entry Notes
- **Complexity**: Small
- **Insight**: Optional annotation on entries (e.g., "pre-workout meal"). Minor but adds context.
- **Files**: `FoodEntry.swift`, `FoodEntryModel.swift`, `QuantityInputView.swift`

#### N14. Nutritionix Common Foods Support
- **Complexity**: Small
- **Insight**: `NutritionixAPI.search()` skips common foods (only returns branded). Code has a comment about needing additional requests.
- **Files**: `NutritionixAPI.swift`

#### N15. Persistent Disk Cache
- **Complexity**: Medium
- **Insight**: `FoodCache` is in-memory only -- lost on app restart. Could persist to SwiftData or UserDefaults.
- **Files**: `FoodCache.swift`, potentially new persistence layer

### Nutrition Bonus Findings
- **UX gap**: `FoodEntryModel` doesn't store food name -- entry rows show quantity/macros but not the food name. Should store name on entry or fetch via repository lookup.
- **Architecture**: `NutritionRepository` protocol needs new methods for favorites, recent foods, and water if those features are added.
- **Cross-domain**: `NutritionDataProviding` may need extending if Analytics wants water or micronutrient data.

---

## Wellness Domain (11 features)

### High Priority

#### H1. Hydration Tracking
- **Complexity**: Medium
- **Insight**: HealthKit `dietaryWater` type not requested or queried. No hydration tracking at all. Core wellness metric.
- **Files**: `HealthMetrics.swift`, `HealthMetricsModel.swift`, `HealthKitPermissions.swift`, `HealthKitManager.swift`, `HealthDashboardView.swift`, `HealthMetricType.swift`

#### H2. Body Composition Tracking ✅ (Session 18.4)
- **Complexity**: Medium
- **Status**: Implemented with body fat % and lean body mass from HealthKit
- **Files**: `HealthMetrics.swift`, `HealthMetricsModel.swift`, `HealthKitManager.swift`, `HealthDashboardView.swift`

#### H3. Enhanced Readiness Score (Multi-Factor) ✅ (Session 18.4)
- **Complexity**: Medium
- **Status**: Implemented with 7-day baselines, 22 bugs fixed (Session 19.0)
- **Files**: `CalculateReadinessScoreUseCase.swift`, `HealthDashboardViewModel.swift`, `HealthDashboardView.swift`

#### H4. Respiratory Rate Tracking ✅ (Session 18.4)
- **Complexity**: Small
- **Status**: Implemented via HealthKit
- **Files**: `HealthMetrics.swift`, `HealthMetricsModel.swift`, `HealthKitManager.swift`, `HealthDashboardView.swift`

### Medium Priority

#### H5. Blood Oxygen (SpO2) Tracking ✅ (Session 22.1)
- **Complexity**: Small
- **Status**: Implemented with HealthKit integration, dashboard card, metric drill-down
- **Files**: `HealthMetrics.swift`, `HealthKitManager.swift`, `HealthDashboardView.swift`, `HealthMetricType.swift`

#### H6. Sleep Consistency / Bedtime Regularity Score ✅ (Session 22.1)
- **Complexity**: Medium
- **Status**: Implemented with 7-day bedtime/wake variance scoring, consistency score in SleepDetailSheet
- **Files**: `CalculateSleepConsistencyUseCase.swift`, `HealthDashboardViewModel.swift`, `SleepDetailSheet.swift`

#### H7. Stress / HRV Variability Analysis
- **Complexity**: Large
- **Insight**: HRV is a single daily average. No intra-day tracking, no stress detection, no daytime vs sleep HRV separation.
- **Files**: New `StressAnalysis.swift` entity, new use case, `HealthKitManager.swift` (separate queries), new stress view

#### H8. Health Correlations Dashboard
- **Complexity**: Large
- **Insight**: Each metric displayed independently. No scatter plots, correlation coefficients, or insight cards linking metrics.
- **Files**: New `HealthCorrelation.swift` entity, new `CalculateCorrelationsUseCase`, new `CorrelationsView.swift`

### Low Priority

#### H9. VO2 Max Tracking ✅ (Session 22.1)
- **Complexity**: Small
- **Status**: Implemented with HealthKit integration, dashboard card, metric drill-down
- **Files**: `HealthMetrics.swift`, `HealthKitManager.swift`, `HealthDashboardView.swift`, `HealthMetricType.swift`

#### H10. Menstrual Cycle Integration
- **Complexity**: Medium
- **Insight**: HealthKit cycle data available but unused. Important for inclusivity, correlation with recovery/performance.
- **Files**: New entities, HealthKit queries, dedicated UI

#### H11. Walking Steadiness / Mobility Metrics
- **Complexity**: Small
- **Insight**: HealthKit provides walking metrics (step length, speed, double support). Niche audience.
- **Files**: Standard HealthKit addition pattern

### Wellness Bonus Findings
- **Architecture debt**: `calculateRecoveryScore()`, `calculateSleepScore()`, `calculateActivityScore()` are private methods in `HealthDashboardView.swift` (View layer). Should be domain use cases for testability and reuse.
- **Minimal DI**: `WellnessContainer` only creates `SwiftDataHealthRepository`. Needs to wire additional use cases as features grow.
- **Single use case**: Domain has only `GetHealthMetricsUseCase` -- needs use cases for scoring, trends, thresholds.
- **Legacy views**: `ChartView.swift` and `MetricCardView.swift` are marked legacy but still in codebase.
- **No write permissions**: `HealthKitPermissions.requiredWriteTypes()` returns empty set. Hydration logging would need write for `dietaryWater`.

---

## Shared / Cross-Domain (20 features)

### High Priority

#### S1. Today Dashboard - Wire Navigation ✅ (Session 18.4)
- **Complexity**: Medium
- **Status**: Implemented with quick action tab navigation
- **Files**: `TodayDashboardView.swift`

#### S2. Today Dashboard - Date Navigation ✅ (Session 18.4)
- **Complexity**: Small
- **Status**: Implemented with date navigation
- **Files**: `TodayDashboardView.swift`

#### S3. Today Dashboard - Recovery/Strain Score Integration ✅ (Session 18.4)
- **Complexity**: Medium
- **Status**: Implemented with recovery/strain score integration
- **Files**: `TodayDashboardView.swift`, `TodayDashboardViewModel.swift`

#### S4. CloudKit Sync
- **Complexity**: Large
- **Insight**: `VitalArcApp.swift` line 54 explicitly disables CloudKit: `cloudKitDatabase: .none`. All data local-only. Significant gap for multi-device users.
- **Files**: `VitalArcApp.swift`, CKRecord mappings for all SwiftData models

#### S5. Design System V1/V2 Consolidation ✅ (Session 22.1)
- **Complexity**: Medium
- **Status**: V2 documented as premium theme for TodayDashboard, V1 adaptive tokens remain standard
- **Files**: `Colors.swift`

### Medium Priority

#### S6. Workout-Nutrition Correlation Analysis
- **Complexity**: Medium
- **Insight**: `GenerateProgressReportUseCase` fetches both domains but doesn't correlate. Cross-domain protocols already in place.
- **Files**: New correlation use case in Analytics, cross-domain protocol usage

#### S7. Sleep-Recovery-Performance Insights
- **Complexity**: Medium
- **Insight**: Recovery and strain calculated independently. No generated insights like "Your recovery drops after >15 strain."
- **Files**: New `GenerateInsightsUseCase` in Analytics

#### S8. iOS Widgets (WidgetKit)
- **Complexity**: Large
- **Insight**: Not implemented. Today Dashboard data model is widget-ready. Needs WidgetKit extension + App Group shared container.
- **Files**: New widget extension target

#### S9. Apple Watch Companion App
- **Complexity**: Large
- **Insight**: Not implemented. Workout logging and recovery glances are natural Watch features.
- **Files**: New watchOS target

#### S10. Export Format Enhancement
- **Complexity**: Small
- **Insight**: `PDFExporter` generates plain text PDFs (just `drawText` calls, no colors/charts/branding). No JSON export option.
- **Files**: `PDFExporter.swift`, `CSVExporter.swift`

#### S11. Goal Achievement Notifications ✅ (Session 22.1)
- **Complexity**: Small
- **Status**: 3 new notification types added (goalAchievement, streakMilestone, personalRecord)
- **Files**: `NotificationType.swift`

#### S12. Onboarding - TDEE / Goal Setup Step
- **Complexity**: Small
- **Insight**: Onboarding has 3 steps (Welcome, Profile, HealthKit). `CalculateTDEEUseCase` exists but isn't used during onboarding. Users must find settings post-onboarding.
- **Files**: `OnboardingCoordinator.swift`, new `GoalSetupView`

#### S13. Cross-Domain Protocol Conformance
- **Complexity**: Small
- **Insight**: `WorkoutDataProviding`, `NutritionDataProviding`, `HealthDataProviding`, `UserProfileProviding` defined but repositories may not actually conform to them. Analytics uses full repository types directly.
- **Files**: Repository implementations, Analytics use cases

### Low Priority

#### S14. Accessibility (VoiceOver) ✅ (Session 22.1)
- **Complexity**: Medium
- **Status**: Labels, hints, values added across all domains (wellness, workout, nutrition, shared)
- **Files**: ~15 presentation views across all modules

#### S15. Dynamic Type Support
- **Complexity**: Small
- **Insight**: Typography uses fixed-size fonts. No `@ScaledMetric` or `DynamicTypeSize` support.
- **Files**: `Typography.swift`, views using typography tokens

#### S16. Data Import from Other Apps
- **Complexity**: Large
- **Insight**: Only export exists. Users from Strong, MyFitnessPal, Hevy have no import path.
- **Files**: New CSV/JSON importer

#### S17. PDF Export - Exercise Name Resolution
- **Complexity**: Small
- **Insight**: `PDFExporter.exportWorkoutLog` displays `exerciseId.uuidString.prefix(8)...` instead of actual exercise names.
- **Files**: `PDFExporter.swift`

#### S18. App Theme Selection
- **Complexity**: Small
- **Insight**: No System/Light/Dark toggle in settings. No `.preferredColorScheme()` override.
- **Files**: `SettingsView.swift`, app-level color scheme state

#### S19. Data Backup/Restore
- **Complexity**: Medium
- **Insight**: No manual backup beyond CloudKit. Users lose all data on uninstall.
- **Files**: New backup/restore flow, SwiftData store export

#### S20. Haptic Feedback Standardization
- **Complexity**: Small
- **Insight**: `AnalyticsDashboardView` uses haptics but `TodayDashboardView` has none. Should be standardized in design system.
- **Files**: Design system haptic utility, all interactive views

### Shared Bonus Findings
- **V1/V2 split**: This is a significant maintenance burden. V2 should be the standard; V1 should be deprecated.
- **PDF quality**: PDFs are text-only with system fonts. No branding, charts, or color. Nearly unusable for sharing.
- **Onboarding gap**: Missing TDEE/goal setup means users don't get nutrition value until they discover settings.

---

## Quick Reference: Top Picks by Strategy

### "Low-Hanging Fruit" (High Priority + Small Complexity)
| ID | Feature | Domain |
|----|---------|--------|
| W1 | Rest Timer | Workout |
| W4 | Custom Exercise Creation UI | Workout |
| N1 | Food Favorites | Nutrition |
| N2 | Recent/Frequent Foods | Nutrition |
| S2 | Today Dashboard Date Navigation | Shared |
| H4 | Respiratory Rate Tracking | Wellness |

### "Biggest Impact" (High Priority, any complexity)
| ID | Feature | Domain | Size |
|----|---------|--------|------|
| H3 | Enhanced Readiness Score | Wellness | Medium |
| S1 | Today Dashboard Navigation | Shared | Medium |
| S3 | Today Dashboard Scores | Shared | Medium |
| W3 | Personal Records Tracking | Workout | Medium |
| N3 | Custom Food Creation | Nutrition | Medium |
| S5 | Design System V1/V2 Consolidation | Shared | Medium |

### "Feature Sprint" Bundles
- **Workout Power Session**: W1 (rest timer) + W4 (custom exercises) + W7 (live timer) + W8 (1RM calc)
- **Nutrition Polish**: N1 (favorites) + N2 (recents) + N5 (fiber/sugar) + N6 (edit quantity)
- **Health Dashboard Upgrade**: H2 (body composition) + H3 (readiness score) + H4 (respiratory rate)
- **Today Dashboard Completion**: S1 (navigation) + S2 (date picker) + S3 (real scores)

---

## Hydration Note

Water/hydration tracking appears in both Nutrition (N4) and Wellness (H1) domains. Implementation decision needed:
- **Nutrition domain**: Manual water logging, daily goal, quick-add buttons (user-driven input)
- **Wellness domain**: HealthKit `dietaryWater` integration, correlation with other health metrics
- **Recommendation**: Implement in Nutrition (user input) and sync to HealthKit via Wellness (read-back for correlations)
