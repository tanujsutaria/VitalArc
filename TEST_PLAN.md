# VitalArc Test Plan

**Version**: 1.0
**Last Updated**: January 26, 2026
**Target**: MVP Beta Release

---

## Overview

This document outlines the critical user flows and test cases for VitalArc beta testing. Each flow includes expected behavior, edge cases, and acceptance criteria.

---

## Test Environment

### Supported Devices
| Device | Screen Size | Priority |
|--------|-------------|----------|
| iPhone SE (3rd gen) | 4.7" | High (smallest supported) |
| iPhone 15 | 6.1" | High (most common) |
| iPhone 15 Pro Max | 6.7" | Medium (largest) |
| iPhone 15 Pro | 6.1" | Medium (ProMotion display) |

### iOS Versions
| Version | Priority | Notes |
|---------|----------|-------|
| iOS 17.0 | High | Minimum supported |
| iOS 17.4+ | High | Current stable |
| iOS 18.0 | Medium | Future compatibility |

### Test Accounts
- Fresh install (no data)
- Existing user (with workout history)
- User with HealthKit data
- User without HealthKit permissions

---

## Critical User Flows

### 1. Onboarding Flow

**Priority**: P0 (Blocking)

#### Test Cases

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| ONB-01 | Complete onboarding | 1. Fresh install<br>2. Tap "Get Started"<br>3. Enter profile info<br>4. Grant/skip HealthKit | User lands on main app with profile saved |
| ONB-02 | Skip HealthKit | 1. Reach HealthKit screen<br>2. Tap "Skip for Now" | App continues without HealthKit, no crash |
| ONB-03 | Grant HealthKit | 1. Reach HealthKit screen<br>2. Tap "Connect"<br>3. Allow all permissions | Health data syncs, dashboard shows metrics |
| ONB-04 | Partial HealthKit | 1. Grant only some permissions | App handles partial data gracefully |
| ONB-05 | Profile validation | 1. Enter invalid data (empty name, negative weight) | Validation errors shown, cannot proceed |
| ONB-06 | Unit display | 1. Complete onboarding | Height shows ft/in, weight shows lbs |

#### Edge Cases
- Interrupt onboarding (kill app mid-flow)
- Background app during HealthKit permission dialog
- Device with no HealthKit capability (iPad)

#### Acceptance Criteria
- [ ] Onboarding completion rate > 90% in testing
- [ ] No crashes during onboarding
- [ ] Profile data persists after app restart
- [ ] Units display correctly (American by default)

---

### 2. Workout Logging Flow

**Priority**: P0 (Blocking)

#### Test Cases

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| WKT-01 | Start empty workout | 1. Tap Workout tab<br>2. Tap "Start Workout" | Empty workout screen appears |
| WKT-02 | Add exercise | 1. In workout, tap "Add Exercise"<br>2. Search "bench press"<br>3. Select exercise | Exercise added with default sets |
| WKT-03 | Log a set | 1. Enter weight and reps<br>2. Tap checkmark | Set marked complete, next set highlighted |
| WKT-04 | Edit set | 1. Tap completed set<br>2. Change values<br>3. Save | Values updated |
| WKT-05 | Delete set | 1. Swipe set left<br>2. Tap delete | Set removed |
| WKT-06 | Complete workout | 1. Log all sets<br>2. Tap "Finish Workout" | Workout saved, summary shown |
| WKT-07 | Cancel workout | 1. Start workout<br>2. Tap Cancel<br>3. Confirm | Workout discarded, no data saved |
| WKT-08 | View history | 1. Go to Workout tab<br>2. Tap "History" | Past workouts displayed |

#### Edge Cases
- App backgrounded during workout (should persist)
- Phone call interruption
- Very long workout (2+ hours)
- Workout with 20+ exercises
- Zero weight sets (bodyweight exercises)

#### Acceptance Criteria
- [ ] Workout data persists after app restart
- [ ] No data loss on background/foreground
- [ ] Performance acceptable with many exercises
- [ ] Correct volume calculations

---

### 3. Nutrition Logging Flow

**Priority**: P0 (Blocking)

#### Test Cases

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| NUT-01 | Search food | 1. Tap Nutrition tab<br>2. Tap "Add Food"<br>3. Search "banana" | Results appear from OpenFoodFacts |
| NUT-02 | Log food | 1. Search food<br>2. Select result<br>3. Adjust quantity<br>4. Tap "Add" | Food added to daily log |
| NUT-03 | Barcode scan | 1. Tap barcode icon<br>2. Scan product barcode | Product info loaded |
| NUT-04 | View daily summary | 1. Log some foods<br>2. View Nutrition tab | Calories and macros shown correctly |
| NUT-05 | Change meal type | 1. Add food<br>2. Select "Lunch" instead of "Breakfast" | Food categorized correctly |
| NUT-06 | Delete food entry | 1. Swipe food entry<br>2. Delete | Entry removed, totals updated |
| NUT-07 | No results | 1. Search "asdfghjkl" | "No results" message shown |

#### Edge Cases
- No internet connection (should show cached results or error)
- API rate limiting (USDA demo key)
- Barcode not in database
- Very large quantities (10000 calories)

#### Acceptance Criteria
- [ ] Food search returns results within 3 seconds
- [ ] Barcode scanning works for common products
- [ ] Daily totals calculate correctly
- [ ] Data persists across sessions

---

### 4. Template Creation Flow

**Priority**: P1 (Important)

#### Test Cases

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| TPL-01 | Create template | 1. Workout tab → Templates<br>2. Tap "+"<br>3. Add name and exercises | Template saved |
| TPL-02 | Add exercises | 1. In editor, tap "Add" on a day<br>2. Select body part<br>3. Choose exercise | Exercise added to day |
| TPL-03 | Reorder exercises | 1. Long-press exercise<br>2. Drag to new position | Exercise reordered |
| TPL-04 | Delete exercise | 1. Swipe exercise left<br>2. Tap delete | Exercise removed |
| TPL-05 | Start from template | 1. View template<br>2. Tap "Start Workout" | Workout pre-filled with template exercises |
| TPL-06 | Edit template | 1. Open existing template<br>2. Make changes<br>3. Save | Changes persisted |

#### Edge Cases
- Template with 7 days of exercises
- Very long template names
- Duplicate exercise names

#### Acceptance Criteria
- [ ] Templates persist across app restarts
- [ ] Starting workout from template works correctly
- [ ] All 76 exercises accessible in picker

---

### 5. Analytics & Export Flow

**Priority**: P1 (Important)

#### Test Cases

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| ANA-01 | View dashboard | 1. Tap Analytics tab | Recovery, strain, sleep scores displayed |
| ANA-02 | Change time range | 1. Tap time range picker<br>2. Select "3 Months" | Data updates for selected range |
| ANA-03 | Export PDF | 1. Tap Export<br>2. Select "Progress Report (PDF)"<br>3. Share | PDF generated and shareable |
| ANA-04 | Export CSV | 1. Tap Export<br>2. Select "Volume Metrics (CSV)" | CSV generated and shareable |
| ANA-05 | View PRs | 1. Navigate to Personal Records | PRs listed by exercise |
| ANA-06 | Empty state | 1. New user views Analytics | Helpful empty state shown |

#### Edge Cases
- No workout data (should show empty states)
- Very large data set (1 year of workouts)
- Export with no data

#### Acceptance Criteria
- [ ] Scores calculate correctly from health data
- [ ] Charts render without crashes
- [ ] Export files are valid and openable
- [ ] Empty states are informative

---

### 6. Settings & Profile Flow

**Priority**: P1 (Important)

#### Test Cases

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| SET-01 | Toggle units | 1. Settings → Toggle "Use Metric Units" | All screens update to metric |
| SET-02 | Send feedback | 1. Settings → Send Feedback<br>2. Fill form<br>3. Send | Email compose opens with pre-filled data |
| SET-03 | Sync HealthKit | 1. Settings → Sync HealthKit Data | Sync completes, timestamp updates |
| SET-04 | Reset onboarding | 1. Settings → Reset Onboarding<br>2. Confirm | App returns to onboarding |
| SET-05 | Delete all data | 1. Settings → Delete All Data<br>2. Confirm | All data cleared, returns to onboarding |
| SET-06 | View About | 1. Profile → About | App info, privacy, terms displayed |

#### Edge Cases
- Toggle units with existing data
- Delete data with active workout
- Send feedback without email configured

#### Acceptance Criteria
- [ ] Settings persist across app restarts
- [ ] Destructive actions require confirmation
- [ ] Feedback mechanism works or shows fallback

---

### 7. Health Dashboard Flow

**Priority**: P1 (Important)

#### Test Cases

| ID | Test Case | Steps | Expected Result |
|----|-----------|-------|-----------------|
| HLT-01 | View metrics | 1. Tap Health tab | Weight, steps, heart rate displayed |
| HLT-02 | No HealthKit | 1. Deny HealthKit permissions<br>2. View Health tab | Appropriate message shown |
| HLT-03 | Partial data | 1. Only grant weight access | Available data shown, others hidden |
| HLT-04 | Refresh data | 1. Pull to refresh | Latest HealthKit data loaded |

#### Edge Cases
- HealthKit permissions revoked mid-session
- No health data for today
- Very old health data only

#### Acceptance Criteria
- [ ] Health metrics display in American units
- [ ] Graceful handling of missing permissions
- [ ] Data refreshes correctly

---

## Non-Functional Tests

### Performance

| Test | Criteria | Method |
|------|----------|--------|
| App launch | < 2 seconds to interactive | Stopwatch |
| Search response | < 3 seconds for food search | Stopwatch |
| Workout save | < 1 second | Stopwatch |
| Memory usage | < 200MB during normal use | Instruments |

### Stability

| Test | Criteria |
|------|----------|
| Crash-free sessions | > 99% |
| Background/foreground | No data loss |
| Low memory | Graceful degradation |

### Accessibility

| Test | Criteria |
|------|----------|
| VoiceOver | All interactive elements labeled |
| Dynamic Type | Text scales appropriately |
| Color contrast | WCAG AA compliant |

---

## Test Execution Checklist

### Pre-Beta Checklist

- [ ] All P0 test cases pass
- [ ] All P1 test cases pass
- [ ] No critical bugs open
- [ ] Performance criteria met
- [ ] Tested on smallest device (iPhone SE)
- [ ] Tested on largest device (iPhone 15 Pro Max)
- [ ] Tested with fresh install
- [ ] Tested with existing data

### Beta Release Checklist

- [ ] TestFlight build uploaded
- [ ] Internal testers added
- [ ] Crash reporting configured
- [ ] Feedback mechanism verified
- [ ] Release notes written

---

## Bug Reporting Template

When reporting bugs, include:

```
**Summary**: [Brief description]
**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result**: [What should happen]
**Actual Result**: [What actually happened]

**Device**: [e.g., iPhone 15]
**iOS Version**: [e.g., 17.4]
**App Version**: [e.g., 1.0 (1)]
**Reproducibility**: [Always/Sometimes/Once]

**Screenshots/Video**: [Attach if applicable]
```

---

## Test Tracking

| Flow | Tester | Date | Status | Notes |
|------|--------|------|--------|-------|
| Onboarding | | | | |
| Workout Logging | | | | |
| Nutrition | | | | |
| Templates | | | | |
| Analytics | | | | |
| Settings | | | | |
| Health | | | | |

---

## Appendix: Test Data

### Sample Workout
```
Name: Push Day
Exercises:
- Barbell Bench Press: 4x8 @ 135 lbs
- Incline Dumbbell Press: 3x10 @ 50 lbs
- Cable Fly: 3x12 @ 30 lbs
- Tricep Pushdown: 3x15 @ 40 lbs
```

### Sample Foods
```
- Banana (1 medium): 105 cal, 27g carbs, 1g protein
- Chicken Breast (6 oz): 280 cal, 0g carbs, 52g protein
- Rice (1 cup cooked): 205 cal, 45g carbs, 4g protein
```

### Sample User Profile
```
Name: Test User
Height: 5'10" (178 cm)
Weight: 175 lbs (79 kg)
Activity Level: Moderate
Goal: Build Muscle
```
