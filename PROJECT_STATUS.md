# VitalArc Project Status

**Last Updated**: January 25, 2026 (Session 4.5)
**Build Status**: ✅ Passing
**Stage**: Pre-MVP (Foundation Built, Polish Required)

---

## Current State

The app compiles and runs. Core features exist but are **not MVP-ready** due to:
- Inconsistent units across screens
- Design system not uniformly applied
- Unimplemented settings/about features
- Error handling gaps

**The real work begins after consistency is fixed.**

---

## Feature Status Overview

### Foundation Built (Needs Polish)

| Feature | Status | Blocking Issues |
|---------|--------|-----------------|
| **Health Dashboard** | Built | Uses kg instead of lbs |
| **Workout Tracking** | Built | Hardcoded colors/spacing |
| **Exercise Library** | Built | - |
| **Templates System** | Built | ✅ Day-by-day editor now wired |
| **Mesocycle System** | Built | Week-to-week charts need testing |
| **Analytics Dashboard** | Built | Hardcoded colors, system colors |
| **Nutrition Tracking** | Built | Hardcoded colors in meal sections, **API keys not configured** |
| **Design System** | Built | Not uniformly applied |
| **Data Layer** | Built | - |
| **Profile/Settings** | Built | 6 unimplemented TODOs |

### Partially Implemented (⚠️)

| Feature | What's Done | What's Missing |
|---------|-------------|----------------|
| **Recovery Score** | UI with score rings | HRV baseline calculation, 60-day rolling average |
| **Strain Tracking** | UI display | TRIMP calculation, HR zone tracking |
| **Sleep Analysis** | Basic score from HealthKit | Sleep stage analysis (REM/deep/light), sleep debt |
| **Nutrition Algorithm** | Daily totals, basic calorie goal | TDEE estimation, adaptive recommendations |
| **Workout Progression** | Mesocycle-level auto-regulation | Real-time suggestions during workout |

### Not Implemented (❌)

| Feature | Priority | Notes |
|---------|----------|-------|
| AI Features | Medium | Cross-domain insights, predictions, photo food logging |
| Social Features | Low | Progress sharing, friends, challenges |
| Apple Watch | Medium | Companion app, complications |
| Widgets | Medium | Home/lock screen widgets |
| Notifications | High | Workout/meal reminders |
| CloudKit Sync | Medium | Framework ready, needs implementation |

---

## Consistency Issues

### Critical (Must Fix)

1. **Unit System Inconsistency**
   - Onboarding: cm, kg (metric)
   - Profile View: ft/in, lbs (American)
   - Health Dashboard: kg (metric)
   - Settings has toggle but not enforced

2. **Design System Violations** (~156 instances across 28 files)
   ```
   Hardcoded: .blue, .red, .green, .gray, .black, .white
   Should be: .vitalPrimary, .vitalDanger, .vitalSuccess, .vitalAdaptiveTextSecondary
   ```

   **Design System Adoption**: 58% (38/66 presentation files)

   Priority files needing migration:
   - `MesocycleDetailView.swift` - using .blue/.red for charts
   - `MesocycleListView.swift` - hardcoded colors
   - `MealSectionView.swift` - Color(.systemBackground)
   - `FoodLoggingView.swift` - hardcoded spacing/colors
   - `AboutView.swift` - .pink.gradient
   - `ChartView.swift` - hardcoded chart colors
   - `ProgressChartView.swift` - hardcoded colors
   - `ProfileView.swift` (edit mode) - Color(.systemGray6)
   - And 20+ others

3. **System Colors** (~40 instances)
   ```
   Hardcoded: Color(.systemGray6), Color(.systemBackground)
   Should be: Color.vitalAdaptiveSurface, Color.vitalAdaptiveBackground
   ```

### High Priority

4. **Unimplemented TODOs** (5 items remaining)
   ```
   SettingsView.swift:86  - TODO: Implement reset onboarding
   SettingsView.swift:92  - TODO: Implement delete all data
   SettingsView.swift:121 - syncHealthKitData() is empty placeholder
   AboutView.swift:85     - TODO: Add privacy policy link
   AboutView.swift:101    - TODO: Add terms of service link
   ✅ CreateTemplateView.swift - FIXED: Now uses TemplateEditorView with day columns
   ```

5. **Hardcoded Spacing** (100+ instances)
   ```
   Hardcoded: .padding(16), .frame(width: 100)
   Should be: .padding(Spacing.md), .frame(width: Spacing.*)
   ```

6. **Font System Bypass**
   ```
   Hardcoded: .font(.system(size: 32, weight: .bold))
   Should be: .font(.vitalDisplayLarge)
   ```

### Moderate

7. **Error Handling Inconsistency**
   - Some views: `alert()` for errors
   - Some views: inline error messages
   - Some views: silent `try?` failures

8. **Preview Coverage**: ~57% of presentation files have #Preview blocks

9. **API Configuration Pending**
   ```
   NutritionixAPI.swift: YOUR_APP_ID, YOUR_APP_KEY (placeholder)
   USDAFoodAPI.swift: DEMO_KEY (rate-limited demo key)
   ```
   Food search will fail or be rate-limited until proper API keys are configured.

---

## Codebase Statistics

| Metric | Value |
|--------|-------|
| Total Swift files | 146 |
| Lines of code | ~34,800 |
| Presentation views | 66 |
| ViewModels | 10 |
| Use cases | 16 |
| Data models | 15 |
| Test files | 6 |

## Architecture Quality

| Aspect | Status | Notes |
|--------|--------|-------|
| Architecture Pattern | ✅ | Clean Architecture (Domain, Data, Presentation, Infrastructure) |
| Design Pattern | ✅ | MVVM with @Observable ViewModels |
| Dependency Injection | ✅ | DependencyContainer pattern |
| Data Persistence | ✅ | SwiftData with repositories |
| Thread Safety | ✅ | @MainActor isolation throughout |
| Design System Adoption | ⚠️ | 58% (38/66 files) |
| Error Handling | ⚠️ | Needs standardization |
| Testing | ⚠️ | 6 test files, ~57% preview coverage |

---

## Recent Commits

| Commit | Description |
|--------|-------------|
| `fb39b9a` | Wire day-by-day template editor into Templates section |
| `c2c7115` | Sync weight from Apple Health with American units |
| `98982f7` | Add week-to-week progression tracking in mesocycle analytics |
| `4c577d2` | Redesign workout section with body-part grouping and custom exercises |
| `bd0ed67` | Add @MainActor isolation for SwiftData thread safety |

---

## Path to MVP

### MVP Blockers (Must Fix Before Launch)

**1. Unit Consistency**
- [ ] Onboarding: Convert to American units (ft/in, lbs)
- [ ] Health Dashboard: Convert to American units
- [ ] Enforce settings toggle across all screens
- [ ] Test all screens for unit display

**2. Design System Enforcement**
- [ ] Replace 47+ hardcoded colors with design tokens
- [ ] Replace 100+ hardcoded spacing values
- [ ] Replace direct font calls with typography tokens
- [ ] Replace `Color(.systemGray6)` with `Color.vitalAdaptiveSurface`

**3. Complete Unfinished Features**
- [ ] SettingsView: Implement reset onboarding
- [ ] SettingsView: Implement delete all data
- [ ] SettingsView: Implement syncHealthKitData()
- [ ] AboutView: Add privacy policy link
- [ ] AboutView: Add terms of service link
- [x] ~~CreateTemplateView: Replace placeholder exercise picker~~ ✅ Done (Session 4.5)

**4. Error Handling Standardization**
- [ ] Replace silent `try?` failures with user feedback
- [ ] Standardize error display pattern (alert vs inline)
- [ ] Add error states to all async operations

**5. Testing & Polish**
- [ ] Add #Preview to remaining 20 presentation files
- [ ] Test all flows end-to-end in simulator
- [ ] Verify HealthKit permissions flow
- [ ] Test on multiple device sizes

### Post-MVP Enhancements

**Phase 1: Algorithm Completion**
- [ ] Recovery score calculation (HRV baseline)
- [ ] TDEE estimation for nutrition
- [ ] Real-time workout progression suggestions

**Phase 2: Platform Features**
- [ ] Notifications (reminders)
- [ ] Home screen widgets
- [ ] CloudKit sync

**Phase 3: Advanced**
- [ ] Apple Watch companion
- [ ] AI-powered insights
- [ ] Social features

---

## File Structure

```
VitalArc/
├── Domain/
│   ├── Entities/        # Business models
│   ├── Repositories/    # Repository protocols
│   └── UseCases/        # Business logic
├── Data/
│   ├── Models/          # SwiftData models
│   └── Seeds/           # Exercise database seeds
├── Infrastructure/
│   ├── HealthKit/       # HealthKit integration
│   ├── Networking/      # API clients
│   ├── Cache/           # Caching layer
│   └── Export/          # PDF/CSV export
└── Presentation/
    ├── Common/          # Design system, shared components
    ├── Onboarding/      # Onboarding flow
    └── Tabs/            # Main app tabs
        ├── Health/
        ├── Workout/
        ├── Nutrition/
        ├── Analytics/
        ├── Training/
        └── Profile/
```

---

## Quick Reference

**Run build:**
```bash
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

**Design System Colors:**
- Primary: `Color.vitalPrimary`
- Danger: `Color.vitalDanger`
- Success: `Color.vitalSuccess`
- Warning: `Color.vitalWarning`
- Background: `Color.vitalAdaptiveBackground`
- Surface: `Color.vitalAdaptiveSurface`
- Text: `Color.vitalAdaptiveTextPrimary/Secondary/Tertiary`

**Spacing Tokens:**
- `Spacing.xs` (4), `Spacing.sm` (8), `Spacing.md` (12), `Spacing.lg` (16), `Spacing.xl` (24)

**Typography:**
- Display: `.vitalDisplayLarge`, `.vitalDisplayMedium`
- Headings: `.vitalH1`, `.vitalH2`, `.vitalH3`
- Body: `.vitalBody`, `.vitalBodySmall`
- Labels: `.vitalLabel`, `.vitalLabelSmall`
- Captions: `.vitalCaption`, `.vitalCaptionSmall`
