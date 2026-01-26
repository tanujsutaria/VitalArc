# VitalArc Session 7 Execution Plan

**Date**: January 26, 2026
**Goal**: Usable MVP + User Testing Infrastructure
**Priority**: Ship a working app that real users can test

---

## Current State Assessment

### Completed (Sessions 1-6)
- [x] Unit consistency (American units)
- [x] Design system (~90% adoption)
- [x] Settings/About features
- [x] Error handling patterns
- [x] Recovery score algorithm

### Critical Blockers for User Testing

| Issue | Status | Impact |
|-------|--------|--------|
| Food search broken | ❌ Blocked | Users cannot log nutrition |
| Analytics export stubs | ❌ Blocked | Export buttons do nothing |
| Template picker limited | ⚠️ Partial | Only 8 exercises available |
| No feedback mechanism | ❌ Missing | No way to collect user input |
| No crash reporting | ❌ Missing | Blind to production issues |
| No TestFlight setup | ❌ Missing | Cannot distribute to testers |

---

## Execution Phases

### Phase 1: Food Search Fix (CRITICAL)

**Problem**: NutritionixAPI and USDAFoodAPI have placeholder keys. Food search is completely broken.

**Solution**: Make OpenFoodFacts the primary API (free, no keys required) with graceful fallback.

**Files to modify**:
- `VitalArc/Presentation/Tabs/Nutrition/FoodSearch/FoodSearchViewModel.swift`
- `VitalArc/Infrastructure/Networking/OpenFoodFactsAPI.swift`

**Tasks**:
1. [ ] Verify OpenFoodFactsAPI works without keys
2. [ ] Update FoodSearchViewModel to use OpenFoodFacts as primary
3. [ ] Add fallback chain: OpenFoodFacts → USDA (demo) → error message
4. [ ] Add user-facing error when all APIs fail
5. [ ] Test food search end-to-end

**Success Criteria**: User can search "banana" and get results.

---

### Phase 2: Analytics Export Implementation

**Problem**: `exportProgressReportPDF()` and `exportVolumeMetricsCSV()` return nil with error messages.

**Files to modify**:
- `VitalArc/Presentation/Tabs/Analytics/AnalyticsDashboardViewModel.swift`
- `VitalArc/Infrastructure/Export/` (existing export utilities)

**Tasks**:
1. [ ] Implement `exportProgressReportPDF()` using existing PDFExporter
2. [ ] Implement `exportVolumeMetricsCSV()` using existing CSVExporter
3. [ ] Wire share sheet to present exported files
4. [ ] Test export functionality

**Success Criteria**: User can tap Export → PDF and receive a shareable file.

---

### Phase 3: Template Exercise Picker

**Problem**: CreateTemplateView uses hardcoded 8-exercise placeholder instead of full exercise library.

**Note**: TemplateEditorView was created in Session 4.5 with proper picker. Need to verify which view is actually used and ensure the real exercise library is wired up.

**Files to check/modify**:
- `VitalArc/Presentation/Tabs/Workout/Templates/CreateTemplateView.swift`
- `VitalArc/Presentation/Tabs/Workout/Templates/TemplateEditorView.swift`
- `VitalArc/Presentation/Tabs/Workout/WorkoutTemplatesView.swift`

**Tasks**:
1. [ ] Verify which template creation flow is active
2. [ ] If CreateTemplateView is used, wire TemplateExercisePickerView (body-part grouped)
3. [ ] Ensure all 200+ seeded exercises are accessible
4. [ ] Test template creation with multiple exercises

**Success Criteria**: User can create template with any exercise from the library.

---

### Phase 4: In-App Feedback Mechanism

**Problem**: No way for beta testers to report issues or provide feedback.

**Files to create**:
- `VitalArc/Presentation/Common/FeedbackView.swift`
- `VitalArc/Infrastructure/Feedback/FeedbackManager.swift`

**Tasks**:
1. [ ] Create FeedbackView with:
   - Text field for description
   - Category picker (Bug, Feature Request, Other)
   - Optional screenshot attachment
   - Send button (opens email compose)
2. [ ] Add "Send Feedback" button to Settings
3. [ ] Pre-fill email with device info, app version, iOS version
4. [ ] Alternative: Integrate with GitHub Issues API for direct submission

**Success Criteria**: User can tap Settings → Send Feedback and submit a report.

---

### Phase 5: Crash Reporting Setup

**Problem**: No visibility into crashes or errors in production.

**Options**:
1. **Firebase Crashlytics** (recommended - free, comprehensive)
2. **Sentry** (good alternative)
3. **Apple's built-in crash reports** (requires App Store Connect access)

**Files to create/modify**:
- Add Firebase SDK via SPM (if chosen)
- `VitalArc/VitalArcApp.swift` - Initialize crash reporting
- `VitalArc/Infrastructure/Analytics/CrashReporter.swift`

**Tasks**:
1. [ ] Choose crash reporting solution
2. [ ] Add SDK dependency
3. [ ] Initialize in app launch
4. [ ] Add non-fatal error logging to key flows
5. [ ] Test crash reporting works

**Success Criteria**: Test crash appears in dashboard within 5 minutes.

---

### Phase 6: TestFlight Preparation

**Problem**: Cannot distribute app to beta testers.

**Prerequisites**:
- Apple Developer account ($99/year)
- App Store Connect access
- Bundle ID configured

**Tasks**:
1. [ ] Verify bundle identifier is unique
2. [ ] Configure App Store Connect app record
3. [ ] Create App Store provisioning profile
4. [ ] Archive and upload build
5. [ ] Add internal testers
6. [ ] Document TestFlight onboarding for testers

**Success Criteria**: First build available in TestFlight.

---

### Phase 7: Test Plan & Success Metrics

**Problem**: No documented test plan or success criteria.

**Files to create**:
- `TEST_PLAN.md`
- `SUCCESS_METRICS.md`

**Test Plan Contents**:
1. [ ] Critical user flows to test:
   - Onboarding completion
   - Log a workout
   - Log food/nutrition
   - View analytics
   - Export data
   - Change settings
2. [ ] Device matrix (iPhone SE, iPhone 15, iPhone 15 Pro Max)
3. [ ] iOS version compatibility (iOS 17+)
4. [ ] HealthKit permission scenarios

**Success Metrics**:
1. [ ] Onboarding completion rate (target: >80%)
2. [ ] Daily active users logging workouts
3. [ ] Crash-free sessions (target: >99%)
4. [ ] User feedback sentiment
5. [ ] Feature usage distribution

---

## Priority Order

```
MUST HAVE (Ship Blocker)
├── Phase 1: Food Search Fix
├── Phase 2: Analytics Export
└── Phase 3: Template Picker

SHOULD HAVE (Before Beta)
├── Phase 4: Feedback Mechanism
├── Phase 5: Crash Reporting
└── Phase 6: TestFlight Prep

NICE TO HAVE (During Beta)
└── Phase 7: Test Plan & Metrics Documentation
```

---

## Session 7 Goal

Complete Phases 1-3 to have a functionally complete app, then start Phase 4 (feedback mechanism) so beta testers can report issues.

**Definition of Done**:
- User can search and log food
- User can export analytics
- User can create templates with full exercise library
- User can send feedback from Settings

---

## Post-MVP Roadmap (Updated)

### Phase A: Algorithm Completion
- [ ] TDEE estimation for nutrition goals
- [ ] Real-time workout progression suggestions
- [ ] Sleep debt calculation

### Phase B: Platform Features
- [ ] Push notifications (workout/meal reminders)
- [ ] Home screen widgets
- [ ] CloudKit sync

### Phase C: Advanced Features
- [ ] Apple Watch companion app
- [ ] AI-powered insights
- [ ] Social features (sharing, challenges)

### Phase D: Growth & Iteration
- [ ] A/B testing framework
- [ ] User analytics (Mixpanel/Amplitude)
- [ ] App Store optimization
- [ ] Marketing website

---

## Quick Commands

```bash
# Build
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Archive for TestFlight
xcodebuild -scheme VitalArc -destination generic/platform=iOS archive -archivePath ./build/VitalArc.xcarchive

# Export for App Store
xcodebuild -exportArchive -archivePath ./build/VitalArc.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist
```
