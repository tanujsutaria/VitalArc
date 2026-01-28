# VitalArc Design System - Implementation Checklist

## ✅ Completed Items

### Core Design Tokens
- [x] Colors.swift - Complete color palette with dark mode
- [x] Typography.swift - Full typography scale
- [x] Spacing.swift - Spacing tokens and semantic values
- [x] SpringAnimations.swift - Animation library with haptics
- [x] ViewExtensions.swift - Common view modifiers and utilities

### Components
- [x] VitalCard - Standard, gradient, and bordered variants
- [x] VitalButton - 6 styles, 3 sizes, loading/disabled states
- [x] VitalIconButton - Circular icon buttons
- [x] VitalTextField - Text input with error states
- [x] VitalTextEditor - Multi-line text input
- [x] VitalSearchField - Search bar with clear button
- [x] MetricCard - Health metrics with sparklines
- [x] ProgressChart - Line, bar, and circular charts
- [x] ExerciseCard - Exercise display with muscle groups
- [x] FoodCard - Food items with macro bars
- [x] VitalEmptyState - Empty, loading, and error states

### Views Updated
- [x] Health/HealthDashboardView.swift
- [x] Health/Components/MetricCardView.swift
- [x] Health/Components/ChartView.swift
- [x] Onboarding/WelcomeView.swift
- [x] Profile/ProfileView.swift
- [x] Workout/ExerciseLibrary/ExerciseRowView.swift
- [x] Nutrition/FoodSearch/FoodResultRowView.swift
- [x] Nutrition/NutritionSummary/MacroRingView.swift
- [x] Nutrition/NutritionSummary/NutritionSummaryView.swift

### Documentation
- [x] Design System README
- [x] Implementation Summary
- [x] This Checklist
- [x] Code examples in all components

## 🔄 Pending Updates (For New Views from Other Streams)

These views may be created by other parallel agents. Once created, they should adopt the design system:

### Stream 1 - Mesocycle/Periodization
- [ ] MesocycleListView - Use VitalCard for mesocycle cards
- [ ] MesocycleDetailView - Use MetricCard for stats
- [ ] PeriodizationPlannerView - Use ProgressChart for timelines
- [ ] BlockProgressView - Use CircularProgressRing
- [ ] DeloadWeekView - Use gradient cards for status

### Stream 3 - Exercise Database
- [ ] ExerciseDetailView - Use VitalCard for exercise info
- [ ] EquipmentFilterView - Use VitalButton for filters
- [ ] MuscleGroupFilterView - Use color-coded badges
- [ ] ExerciseVideoView - Use VitalCard as container
- [ ] ExerciseFavoritesList - Use ExerciseCard

### Stream 4 - Food Databases (Completed)
- [x] FoodResultRowView - Already updated
- [ ] FoodDetailView - Use VitalCard and MacroBar (if created)
- [ ] FoodSourceSettings - Use VitalButton for toggles (if created)

### Stream 5 - Advanced Features
- [ ] WorkoutTemplateCard - Use VitalCard
- [ ] WorkoutTemplateListView - Use ExerciseCard in templates
- [ ] AnalyticsDashboard - Use ProgressChart variants
- [ ] ExportSettingsView - Use VitalButton
- [ ] ProgressPhotosView - Use VitalCard for photo cards
- [ ] PersonalRecordsView - Use MetricCard for PRs

## 📋 Integration Guidelines for Other Streams

When creating new views, follow these steps:

### 1. Import Design System
```swift
// No explicit import needed - components are in same module
```

### 2. Use Design Tokens

**Colors:**
```swift
// ✅ Do this
.foregroundStyle(Color.vitalAdaptiveTextPrimary)
.background(Color.vitalAdaptiveSurface)

// ❌ Don't do this
.foregroundStyle(.black)
.background(.white)
```

**Typography:**
```swift
// ✅ Do this
Text("Title").font(.vitalH2)
Text("Body").font(.vitalBody)

// ❌ Don't do this
Text("Title").font(.system(size: 20, weight: .semibold))
```

**Spacing:**
```swift
// ✅ Do this
VStack(spacing: Spacing.md) { }
.padding(Spacing.screenPadding)

// ❌ Don't do this
VStack(spacing: 16) { }
.padding(20)
```

### 3. Use Components

**Cards:**
```swift
// ✅ Do this
VitalCard {
    Text("Content")
}

// ❌ Don't do this
VStack {
    Text("Content")
}
.padding()
.background(.white)
.cornerRadius(12)
.shadow(radius: 5)
```

**Buttons:**
```swift
// ✅ Do this
VitalButton(
    title: "Save",
    style: .primary,
    icon: "checkmark",
    action: save
)

// ❌ Don't do this
Button("Save") { save() }
    .padding()
    .background(.blue)
    .foregroundColor(.white)
    .cornerRadius(12)
```

**Empty States:**
```swift
// ✅ Do this
if items.isEmpty {
    VitalEmptyState(
        icon: "tray",
        title: "No Items",
        message: "Add your first item",
        actionTitle: "Add Item",
        action: addItem
    )
}

// ❌ Don't do this
if items.isEmpty {
    VStack {
        Image(systemName: "tray")
        Text("No Items")
        Button("Add Item", action: addItem)
    }
}
```

### 4. Add Animations & Haptics

```swift
// Button actions
VitalButton("Save") {
    HapticFeedback.light()
    save()
}

// Transitions
if showView {
    ContentView()
        .transition(.vitalSlideUp)
}
.animation(.vitalSpring, value: showView)

// Interactive elements
.vitalScaleButton() // for buttons
```

### 5. Support Accessibility

```swift
Image(systemName: "heart")
    .vitalAccessibility(
        label: "Favorite",
        hint: "Double tap to favorite this item"
    )
```

## 🎨 Component Quick Reference

| Need | Use | Example |
|------|-----|---------|
| Container | `VitalCard` | Wrapping content |
| Action Button | `VitalButton` | Primary/secondary actions |
| Icon Button | `VitalIconButton` | Toolbar, floating buttons |
| Text Input | `VitalTextField` | Forms, search |
| Search Bar | `VitalSearchField` | Search screens |
| Health Metric | `MetricCard` | Health stats with trends |
| Chart | `VitalLineChart` / `VitalBarChart` | Data visualization |
| Progress Ring | `CircularProgressRing` | Macro tracking, goals |
| Exercise | `ExerciseCard` | Exercise lists |
| Food Item | `FoodCard` | Food logs, search results |
| Empty State | `VitalEmptyState` | No data screens |
| Loading | `VitalLoadingState` | Loading screens |
| Error | `VitalErrorState` | Error handling |

## 🔍 Testing Checklist

Before submitting a PR, verify:

- [ ] View works in both light and dark mode
- [ ] Text scales properly with Dynamic Type
- [ ] Colors use adaptive variants
- [ ] Spacing uses tokens (no magic numbers)
- [ ] Typography uses scale (no custom sizes)
- [ ] Buttons have haptic feedback
- [ ] Animations use design system animations
- [ ] Empty states use VitalEmptyState
- [ ] VoiceOver labels are present
- [ ] Works on iPhone and iPad
- [ ] No console warnings

## 📚 Resources

- **Full Documentation**: `/VitalArc/Presentation/Common/DesignSystem/README.md`
- **Component Examples**: Check `#Preview` in each component file
- **Summary**: `/DESIGN_SYSTEM_SUMMARY.md`
- **This Checklist**: `/DESIGN_SYSTEM_CHECKLIST.md`

## 🆘 Common Questions

**Q: Which color should I use for X?**
A: Check the color mapping in DESIGN_SYSTEM_SUMMARY.md. Use adaptive colors for backgrounds and text.

**Q: How do I create a custom component?**
A: Follow the pattern in existing components. Use design tokens, support dark mode, add accessibility labels.

**Q: Can I override design system values?**
A: Only if absolutely necessary. Try to work within the system. If you need something new, discuss adding it to the design system.

**Q: Do I have to use VitalButton for all buttons?**
A: For standard buttons, yes. For very custom interactions, you can use Button with design system styling.

**Q: How do I handle loading states?**
A: Use `VitalLoadingState` for full-screen loading, or `.skeleton(isLoading: true)` for inline loading.

## 🚀 Next Steps

1. Other stream developers: Review this checklist
2. Adopt design system in all new views
3. Update any existing views not yet migrated
4. Report any missing components or patterns
5. Keep design system synchronized across streams

---

**Last Updated**: 2026-01-25
**Status**: ⚠️ Design System Complete - Adoption ~58%

**Adoption Statistics:**
- Design system files: 14 (complete)
- Presentation files using design system: 38/66 (58%)
- Hardcoded color violations remaining: ~156 instances
- Hardcoded spacing violations remaining: ~100+ instances

**Priority files for migration:**
- MesocycleDetailView.swift (using .blue/.red for charts)
- MealSectionView.swift (using Color(.systemBackground))
- FoodLoggingView.swift (hardcoded spacing)
- AboutView.swift (using .pink.gradient)
