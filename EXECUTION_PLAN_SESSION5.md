# VitalArc Session 5 Execution Plan

**Date**: January 26, 2026
**Goal**: MVP-Ready State
**Strategy**: Parallel sub-agents with iterative verification

---

## Execution Strategy

### Parallel Stream Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATOR (Main Agent)                     │
│  - Spawns sub-agents for each stream                            │
│  - Verifies completion after each phase                         │
│  - Runs build verification between phases                       │
│  - Commits after each successful phase                          │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
   ┌─────────┐          ┌─────────┐          ┌─────────┐
   │ Stream A│          │ Stream B│          │ Stream C│
   │  Units  │          │  Design │          │ Features│
   └─────────┘          └─────────┘          └─────────┘
```

### Phase Execution Order

1. **Phase 1**: Unit Consistency (Stream A) - BLOCKING
2. **Phase 2**: Design System (Stream B) - Can parallelize internally
3. **Phase 3**: Feature Completion (Stream C) - After Phase 1-2
4. **Phase 4**: Error Handling + Testing
5. **Phase 5**: New Features (if time permits)

---

## Phase 1: Unit Consistency

**Priority**: CRITICAL - Must complete first
**Estimated Agents**: 3 parallel

### Agent 1A: Onboarding Units

**Files to modify:**
- `VitalArc/Presentation/Onboarding/ProfileSetupView.swift`
- `VitalArc/Presentation/Onboarding/OnboardingViewModel.swift`

**Instructions:**
```
1. Read ProfileSetupView.swift and OnboardingViewModel.swift
2. Find all references to "cm" and "kg" in the UI
3. Replace with American units:
   - Height: Use two pickers - feet (4-7) and inches (0-11)
   - Weight: Use lbs with decimal input
4. Update OnboardingViewModel:
   - Change default height from 170.0 to separate feet/inches (5, 10)
   - Change default weight from 70.0 to 154.0 (lbs)
   - Add conversion before saving: convert ft/in → cm, lbs → kg
5. Use existing UnitConversion helpers from ProfileViewModel.swift:
   - UnitConversion.feetInchesToCm(feet:inches:)
   - UnitConversion.lbsToKg(_:)
6. Verify the view compiles and displays correctly
```

**Success Criteria:**
- No "cm" or "kg" visible in onboarding UI
- Height shows as "5 ft 10 in" format
- Weight shows as "lbs"
- Data still saves correctly in metric internally

### Agent 1B: Health Dashboard Units

**Files to modify:**
- `VitalArc/Presentation/Tabs/Health/HealthDashboardView.swift`
- `VitalArc/Presentation/Tabs/Health/HealthDashboardViewModel.swift`

**Instructions:**
```
1. Read HealthDashboardView.swift
2. Find weight display (currently shows "kg")
3. Add UnitConversion import/reference
4. Convert weight display: UnitConversion.kgToLbs(weight)
5. Update label from "kg" to "lbs"
6. Check for any other metric units and convert:
   - Distance: km → miles (if present)
   - Energy: kJ → kcal (should already be kcal)
7. Verify display shows American units
```

**Success Criteria:**
- Weight displays in lbs
- All metrics in American units
- No "kg" visible anywhere in Health tab

### Agent 1C: Settings Unit Toggle Enforcement

**Files to modify:**
- `VitalArc/Presentation/Tabs/Profile/SettingsView.swift`
- Create: `VitalArc/Infrastructure/UserPreferences.swift`

**Instructions:**
```
1. Read SettingsView.swift - find the useMetricUnits toggle
2. Create UserPreferences.swift with:
   ```swift
   enum UserPreferences {
       @AppStorage("useMetricUnits") static var useMetricUnits: Bool = false

       static var weightUnit: String { useMetricUnits ? "kg" : "lbs" }
       static var heightUnit: String { useMetricUnits ? "cm" : "ft" }

       static func formatWeight(_ kg: Double) -> String {
           if useMetricUnits {
               return String(format: "%.1f kg", kg)
           } else {
               return String(format: "%.1f lbs", UnitConversion.kgToLbs(kg))
           }
       }

       static func formatHeight(_ cm: Double) -> String {
           if useMetricUnits {
               return String(format: "%.0f cm", cm)
           } else {
               let (ft, inches) = UnitConversion.cmToFeetInches(cm)
               return "\(ft)'\(inches)\""
           }
       }
   }
   ```
3. Update SettingsView toggle to use @AppStorage
4. This creates centralized unit formatting for future use
```

**Success Criteria:**
- UserPreferences.swift created
- Settings toggle persists and is accessible app-wide
- Helper methods for consistent formatting

### Phase 1 Verification

After all 3 agents complete:
```bash
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Commit: "Enforce American units across all screens"

---

## Phase 2: Design System Enforcement

**Priority**: HIGH
**Estimated Agents**: 5 parallel (by domain)

### Agent 2A: Training/Mesocycle Views

**Files to modify:**
- `VitalArc/Presentation/Tabs/Training/MesocycleDetailView.swift`
- `VitalArc/Presentation/Tabs/Training/MesocycleListView.swift`
- `VitalArc/Presentation/Tabs/Training/CreateMesocycleView.swift`

**Instructions:**
```
1. Read each file and identify design system violations
2. Replace hardcoded colors:
   - .blue → Color.vitalPrimary or Color.vitalInfo
   - .green → Color.vitalSuccess
   - .red → Color.vitalDanger
   - .orange → Color.vitalWarning
   - .gray → Color.vitalAdaptiveTextSecondary
   - Color(.systemGray6) → Color.vitalAdaptiveSurface
   - Color(.systemBackground) → Color.vitalAdaptiveBackground
3. Replace hardcoded spacing:
   - .padding(8) → .padding(Spacing.sm)
   - .padding(12) → .padding(Spacing.md)
   - .padding(16) → .padding(Spacing.lg)
   - .padding(24) → .padding(Spacing.xl)
   - .padding() → .padding(Spacing.md) (be explicit)
4. Replace hardcoded fonts:
   - .font(.headline) → .font(.vitalH3)
   - .font(.title) → .font(.vitalH1)
   - .font(.title2) → .font(.vitalH2)
   - .font(.caption) → .font(.vitalCaption)
   - .font(.subheadline) → .font(.vitalBody)
5. Replace hardcoded corner radius:
   - .cornerRadius(8) → .cornerRadius(Spacing.radiusSmall)
   - .cornerRadius(12) → .cornerRadius(Spacing.radiusMedium)
   - .cornerRadius(16) → .cornerRadius(Spacing.radiusLarge)
```

**Success Criteria:**
- No hardcoded colors in Training views
- No hardcoded spacing values
- All using design tokens

### Agent 2B: Nutrition Views

**Files to modify:**
- `VitalArc/Presentation/Tabs/Nutrition/FoodLogging/FoodLoggingView.swift`
- `VitalArc/Presentation/Tabs/Nutrition/FoodLogging/MealSectionView.swift`
- `VitalArc/Presentation/Tabs/Nutrition/NutritionSummary/NutritionSummaryView.swift`
- `VitalArc/Presentation/Tabs/Nutrition/NutritionSummary/MacroRingView.swift`

**Instructions:**
```
Same as Agent 2A - apply design system tokens to all nutrition views.
Pay special attention to macro colors:
- Protein: Color.vitalInfo (blue)
- Carbs: Color.vitalWarning (orange)
- Fat: Color.vitalDanger (red)
- Calories: Color.vitalPrimary
```

### Agent 2C: Health Views

**Files to modify:**
- `VitalArc/Presentation/Tabs/Health/Components/MetricCardView.swift`
- `VitalArc/Presentation/Tabs/Health/Components/ChartView.swift`
- `VitalArc/Presentation/Tabs/Health/HealthDashboardView.swift`

**Instructions:**
```
Same design system enforcement as above.
Health-specific colors:
- Heart rate: Color.vitalDanger
- HRV: Color.vitalInfo
- Sleep: Color.vitalAccent (purple)
- Steps: Color.vitalSuccess
- Energy: Color.vitalWarning
```

### Agent 2D: Analytics Views

**Files to modify:**
- `VitalArc/Presentation/Tabs/Analytics/AnalyticsDashboardView.swift`
- `VitalArc/Presentation/Tabs/Analytics/ProgressChartView.swift`
- `VitalArc/Presentation/Tabs/Analytics/VolumeChartView.swift`
- `VitalArc/Presentation/Tabs/Analytics/Components/*.swift` (all)

**Instructions:**
```
Same design system enforcement.
Keep chart colors semantic but use design tokens.
Score rings should use:
- Recovery: Color.vitalSuccess
- Strain: Color.vitalDanger
- Sleep: Color.vitalAccent
```

### Agent 2E: Profile Views

**Files to modify:**
- `VitalArc/Presentation/Tabs/Profile/ProfileView.swift`
- `VitalArc/Presentation/Tabs/Profile/SettingsView.swift`
- `VitalArc/Presentation/Tabs/Profile/AboutView.swift`

**Instructions:**
```
Same design system enforcement.
AboutView specifically:
- Replace .pink.gradient → Color.vitalPrimaryGradient
- Replace .pink → Color.vitalPrimary
```

### Phase 2 Verification

After all 5 agents complete:
```bash
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Commit: "Apply design system tokens across all views"

---

## Phase 3: Feature Completion

**Priority**: HIGH
**Estimated Agents**: 3 parallel

### Agent 3A: Settings Implementation

**File:** `VitalArc/Presentation/Tabs/Profile/SettingsView.swift`

**Instructions:**
```
1. Implement resetOnboarding():
   ```swift
   private func resetOnboarding() {
       Task {
           await userRepository.setOnboardingCompleted(false)
           // Post notification to reset app state
           NotificationCenter.default.post(name: .resetToOnboarding, object: nil)
       }
   }
   ```

2. Implement deleteAllData():
   ```swift
   private func deleteAllData() {
       showingDeleteConfirmation = true
   }

   // Add confirmation alert
   .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
       Button("Cancel", role: .cancel) { }
       Button("Delete", role: .destructive) {
           Task {
               try? await userRepository.deleteUserProfile()
               // Delete other data...
               await userRepository.setOnboardingCompleted(false)
           }
       }
   } message: {
       Text("This will permanently delete all your data. This cannot be undone.")
   }
   ```

3. Implement syncHealthKitData():
   ```swift
   private func syncHealthKitData() {
       isSyncing = true
       Task {
           do {
               try await healthRepository?.syncFromHealthKit()
               lastSyncDate = Date()
           } catch {
               syncError = error.localizedDescription
           }
           isSyncing = false
       }
   }
   ```

4. Add required state variables and UI feedback
```

### Agent 3B: About View Links

**File:** `VitalArc/Presentation/Tabs/Profile/AboutView.swift`

**Instructions:**
```
1. Add privacy policy link:
   ```swift
   Link(destination: URL(string: "https://vitalarc.app/privacy")!) {
       // ... existing row UI
   }
   ```

2. Add terms of service link:
   ```swift
   Link(destination: URL(string: "https://vitalarc.app/terms")!) {
       // ... existing row UI
   }
   ```

3. If URLs don't exist yet, use placeholder that opens in-app:
   - Create simple PrivacyPolicyView.swift with placeholder text
   - Create simple TermsOfServiceView.swift with placeholder text
   - Use NavigationLink instead of Link
```

### Agent 3C: Template Exercise Picker ✅ COMPLETED (Session 4.5)

**Status:** DONE - Wired `TemplateEditorView` (day-by-day editor) into the app

**Completed:**
- Replaced `CreateTemplateView` with `TemplateEditorView` in MainTabView.swift and WorkoutTemplatesView.swift
- TemplateEditorView now accepts WorkoutTemplatesViewModel and saves to repository
- Day columns (Day 1-7) with horizontal scroll
- Exercises added via body-part grouped `TemplateExercisePickerView`
- Swipe-to-delete on exercises
- Category and description editing
- Proper persistence via SaveWorkoutTemplateUseCase

**Commit:** `fb39b9a` - Wire day-by-day template editor into Templates section

### Phase 3 Verification

```bash
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Commit: "Complete Settings, About, and Template features"

---

## Phase 4: Error Handling Standardization

**Priority**: MEDIUM
**Estimated Agents**: 2 parallel

### Agent 4A: Replace Silent Failures

**Files to scan and fix:**
- `VitalArc/Presentation/Tabs/MainTabView.swift`
- All files with `try?` patterns

**Instructions:**
```
1. Search for all `try?` in presentation layer
2. Replace with proper error handling:

   BEFORE:
   try? await someOperation()

   AFTER:
   do {
       try await someOperation()
   } catch {
       // Log error for debugging
       print("Operation failed: \(error)")
       // Optionally show user feedback for critical operations
   }

3. For user-facing operations, add error state:
   @State private var errorMessage: String?

   .alert("Error", isPresented: .constant(errorMessage != nil)) {
       Button("OK") { errorMessage = nil }
   } message: {
       Text(errorMessage ?? "")
   }
```

### Agent 4B: Standardize Error Display Pattern

**Create:** `VitalArc/Presentation/Common/ErrorHandling.swift`

**Instructions:**
```
Create a standardized error handling pattern:

```swift
// Error display modifier
struct ErrorAlert: ViewModifier {
    @Binding var error: Error?

    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: .constant(error != nil)) {
                Button("OK") { error = nil }
            } message: {
                Text(error?.localizedDescription ?? "An error occurred")
            }
    }
}

extension View {
    func errorAlert(_ error: Binding<Error?>) -> some View {
        modifier(ErrorAlert(error: error))
    }
}

// Usage in views:
// .errorAlert($viewModel.error)
```

Document the pattern in the file for future reference.
```

### Phase 4 Verification

```bash
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Commit: "Standardize error handling across app"

---

## Phase 5: New Features (If Time Permits)

### Agent 5A: Recovery Score Algorithm

**Files to create/modify:**
- Create: `VitalArc/Domain/UseCases/Health/CalculateRecoveryScoreUseCase.swift`
- Modify: `VitalArc/Presentation/Tabs/Analytics/AnalyticsDashboardViewModel.swift`

**Instructions:**
```
Implement HRV-based recovery score:

1. Create CalculateRecoveryScoreUseCase:
   - Fetch last 60 days of HRV data
   - Calculate rolling baseline (average)
   - Compare today's HRV to baseline
   - Score = (todayHRV / baselineHRV) * 100, capped at 0-100
   - Factor in: resting HR, sleep hours

2. Formula:
   ```swift
   func calculateRecoveryScore(
       todayHRV: Double,
       baselineHRV: Double,
       restingHR: Double,
       baselineHR: Double,
       sleepHours: Double
   ) -> Int {
       let hrvScore = min(100, (todayHRV / baselineHRV) * 100)
       let hrScore = min(100, (baselineHR / restingHR) * 100) // Lower HR = better
       let sleepScore = min(100, (sleepHours / 8.0) * 100)

       // Weighted average
       let recovery = (hrvScore * 0.5) + (hrScore * 0.3) + (sleepScore * 0.2)
       return Int(recovery.clamped(to: 0...100))
   }
   ```

3. Integrate into AnalyticsDashboardViewModel
4. Display real score instead of placeholder
```

### Agent 5B: Basic Notifications

**Files to create:**
- `VitalArc/Infrastructure/Notifications/NotificationManager.swift`
- Modify: `VitalArc/Presentation/Tabs/Profile/SettingsView.swift`

**Instructions:**
```
1. Create NotificationManager:
   - Request notification permissions
   - Schedule local notifications
   - Notification types: workout reminder, meal logging reminder

2. Add to Settings:
   - Toggle for workout reminders
   - Time picker for reminder time
   - Toggle for meal logging reminders

3. Basic implementation:
   ```swift
   class NotificationManager {
       static let shared = NotificationManager()

       func requestPermission() async -> Bool
       func scheduleWorkoutReminder(at time: DateComponents, days: [Int])
       func scheduleMealReminder(at times: [DateComponents])
       func cancelAll()
   }
   ```
```

---

## Orchestrator Instructions

### Execution Flow

```
1. START Phase 1
   - Spawn Agents 1A, 1B, 1C in parallel
   - Wait for all to complete
   - Run build verification
   - If build fails: debug and fix
   - If build passes: commit

2. START Phase 2
   - Spawn Agents 2A, 2B, 2C, 2D, 2E in parallel
   - Wait for all to complete
   - Run build verification
   - If build fails: debug and fix
   - If build passes: commit

3. START Phase 3
   - Spawn Agents 3A, 3B, 3C in parallel
   - Wait for all to complete
   - Run build verification
   - If build fails: debug and fix
   - If build passes: commit

4. START Phase 4
   - Spawn Agents 4A, 4B in parallel
   - Wait for all to complete
   - Run build verification
   - If build fails: debug and fix
   - If build passes: commit

5. ASSESS remaining time
   - If time available: START Phase 5
   - Otherwise: finalize and document

6. FINAL
   - Run full build
   - Update SESSION_LOG.md
   - Update PROJECT_STATUS.md
   - Push all commits
```

### Build Verification Command

```bash
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD SUCCEEDED|BUILD FAILED)"
```

### Commit Strategy

After each phase:
```bash
git add -A
git commit -m "Phase X: [Description]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

At end of session:
```bash
git push origin main
```

---

## Success Metrics

### MVP Ready Checklist

- [ ] All screens show American units (or respect settings toggle)
- [ ] No hardcoded colors (grep for `.blue`, `.red`, `.green`, `.gray`)
- [ ] No hardcoded spacing (grep for `.padding(8)`, `.padding(16)`)
- [ ] All 6 TODOs implemented
- [ ] No silent `try?` failures in user-facing code
- [ ] Build passes with 0 errors
- [ ] All features functional in simulator

### Verification Commands

```bash
# Check for hardcoded colors
grep -r "\.blue\|\.red\|\.green\|\.gray" VitalArc/Presentation --include="*.swift" | grep -v "//"

# Check for system colors
grep -r "Color(.system" VitalArc/Presentation --include="*.swift"

# Check for hardcoded spacing
grep -r "\.padding(8)\|\.padding(16)\|\.padding(24)" VitalArc/Presentation --include="*.swift"

# Check for remaining TODOs
grep -r "TODO" VitalArc/Presentation --include="*.swift"

# Check for silent failures
grep -r "try?" VitalArc/Presentation --include="*.swift"
```

---

## Rollback Plan

If a phase causes critical issues:

```bash
# Stash current changes
git stash

# Or reset to last good commit
git reset --hard HEAD~1

# Re-attempt with fixed approach
```

---

## Notes for Agent

1. **Always read before writing** - Understand the existing code structure
2. **Match existing patterns** - Follow conventions already in the codebase
3. **Test incrementally** - Build after each significant change
4. **Don't over-engineer** - Make minimal changes to achieve the goal
5. **Preserve functionality** - Changes should not break existing features
6. **Use design system** - Reference `Common/DesignSystem/` for tokens
7. **American units default** - Unless settings toggle says otherwise
