# VitalArc Design System - Component Hierarchy

## Component Organization

```
Design System
├── Foundation Layer (Design Tokens)
│   ├── Colors.swift
│   │   ├── Primary Palette (vitalPrimary, vitalSecondary, vitalAccent)
│   │   ├── Functional Colors (success, warning, danger, info)
│   │   ├── Adaptive Colors (auto light/dark mode)
│   │   └── Gradients (pre-defined combinations)
│   │
│   ├── Typography.swift
│   │   ├── Display Fonts (Large, Medium, Small)
│   │   ├── Headings (H1, H2, H3, H4)
│   │   ├── Body Text (Large, Regular, Small)
│   │   ├── Labels (Regular, Small, Tiny)
│   │   └── Numbers (Large, Medium, Small - tabular)
│   │
│   ├── Spacing.swift
│   │   ├── Base Scale (xxs to xxxl)
│   │   ├── Semantic Spacing (card, screen, section, item)
│   │   ├── Corner Radius (small, medium, large, xlarge)
│   │   └── Shadow Styles (small, medium, large)
│   │
│   └── SpringAnimations.swift
│       ├── Spring Animations (spring, bouncy, snappy)
│       ├── Easing Animations (easeOut, easeInOut, smooth)
│       ├── Haptic Feedback (light, medium, heavy, selection, etc.)
│       ├── Button Styles (scale, press)
│       └── Transitions (slideUp, scale, fade)
│
├── Utility Layer
│   └── ViewExtensions.swift
│       ├── Conditional Modifiers (if/else)
│       ├── Keyboard Management
│       ├── Corner Radius Variants
│       ├── Card Styling
│       ├── Skeleton Loading
│       ├── Badge Modifier
│       ├── Shimmer Effect
│       ├── Accessibility Helpers
│       └── Debug Tools
│
├── Component Layer (Core UI)
│   ├── Containers
│   │   ├── VitalCard
│   │   │   ├── Standard (shadow)
│   │   │   ├── Gradient (gradient background)
│   │   │   └── Bordered (border instead of shadow)
│   │   │
│   │   └── VitalBottomSheet
│   │       ├── Basic (custom content)
│   │       ├── Confirmation (yes/no dialog)
│   │       └── Action Sheet (list of actions)
│   │
│   ├── Inputs
│   │   ├── VitalTextField (standard input)
│   │   ├── VitalTextEditor (multi-line)
│   │   └── VitalSearchField (search with clear)
│   │
│   ├── Buttons
│   │   ├── VitalButton
│   │   │   ├── Styles: primary, secondary, outline, text, danger, success
│   │   │   ├── Sizes: small, medium, large
│   │   │   └── States: normal, loading, disabled
│   │   │
│   │   └── VitalIconButton (circular icon button)
│   │
│   └── States
│       ├── VitalEmptyState (no data)
│       ├── VitalLoadingState (loading indicator)
│       └── VitalErrorState (error message)
│
└── Domain Layer (Specialized Components)
    ├── Health & Fitness
    │   ├── MetricCard
    │   │   ├── Icon with gradient background
    │   │   ├── Trend indicator (up/down/stable)
    │   │   └── Optional sparkline chart
    │   │
    │   └── ProgressChart
    │       ├── VitalLineChart (line with area fill)
    │       ├── VitalBarChart (gradient bars)
    │       └── CircularProgressRing (macro tracking)
    │
    ├── Workout
    │   └── ExerciseCard
    │       ├── Muscle group color coding
    │       ├── Equipment badges
    │       ├── Workout stats display
    │       └── Action buttons (tap, delete)
    │
    └── Nutrition
        └── FoodCard
            ├── Macro breakdown bars (P/C/F)
            ├── Calorie badge
            ├── Meal type tag
            └── Action buttons (tap, delete)
```

## Component Relationships

### Inheritance & Composition

```
View (SwiftUI)
│
├── VitalCard
│   ├── Used by: MetricCard, ExerciseCard, FoodCard
│   ├── Used by: VitalEmptyState, VitalErrorState
│   └── Used by: Custom views throughout app
│
├── VitalButton
│   ├── Used by: VitalEmptyState
│   ├── Used by: VitalBottomSheet variants
│   └── Used by: All action buttons
│
├── MetricCard
│   ├── Contains: VitalCard
│   ├── Contains: SparklineView (optional)
│   └── Used by: HealthDashboardView
│
├── ProgressChart variants
│   ├── Contains: VitalCard
│   ├── Contains: Charts framework
│   └── Used by: HealthDashboardView, Analytics
│
├── ExerciseCard
│   ├── Contains: VitalCard styling
│   └── Used by: ExerciseLibraryView, WorkoutViews
│
└── FoodCard
    ├── Contains: VitalCard styling
    ├── Contains: MacroBar components
    └── Used by: FoodLoggingView, FoodSearchView
```

## Usage Patterns

### Pattern 1: Simple Card
```swift
VitalCard {
    Text("Content")
}
```

### Pattern 2: Metric Display
```swift
MetricCard(
    title: "Steps",
    value: "10,000",
    unit: "steps",
    icon: "figure.walk",
    color: .vitalInfo,
    sparklineData: [...]
)
```

### Pattern 3: Data Visualization
```swift
VitalLineChart(
    title: "Heart Rate",
    data: chartData,
    color: .vitalDanger,
    unit: "BPM"
)
```

### Pattern 4: User Action
```swift
VitalButton(
    title: "Save",
    style: .primary,
    icon: "checkmark",
    action: save
)
```

### Pattern 5: Empty State
```swift
if items.isEmpty {
    VitalEmptyState(
        icon: "tray",
        title: "No Items",
        message: "Add your first item",
        actionTitle: "Add Item",
        action: addItem
    )
}
```

## Color Mapping

### By Component Type

| Component | Primary Color | Usage |
|-----------|---------------|-------|
| **Health Metrics** | | |
| Heart Rate, HRV | vitalDanger | Cardiovascular |
| Steps, Movement | vitalInfo | Activity |
| Sleep, Recovery | vitalSecondary | Rest |
| Energy, Calories | vitalWarning | Energy |
| Weight, Progress | vitalSuccess | Goals |
| **Workout** | | |
| Chest exercises | vitalDanger | Push movements |
| Back exercises | vitalInfo | Pull movements |
| Leg exercises | vitalSuccess | Lower body |
| Core exercises | vitalWarning | Stability |
| Arms/Shoulders | vitalSecondary | Upper body |
| **Nutrition** | | |
| Protein | vitalDanger | Muscle building |
| Carbs | vitalInfo | Energy |
| Fats | vitalWarning | Essential nutrients |
| Calories | vitalWarning | Total energy |
| **UI States** | | |
| Success | vitalSuccess | Positive feedback |
| Warning | vitalWarning | Caution |
| Error | vitalDanger | Problems |
| Info | vitalInfo | Information |
| Primary Action | vitalPrimary | Main actions |

## Accessibility Hierarchy

```
Accessibility Support
├── Visual
│   ├── Dynamic Type (all text scales)
│   ├── High Contrast (adaptive colors)
│   └── Dark Mode (full support)
│
├── Motor
│   ├── Large Touch Targets (44pt minimum)
│   ├── Reduced Motion (animation respect)
│   └── Haptic Feedback (tactile cues)
│
└── Screen Reader
    ├── VoiceOver Labels (all components)
    ├── Hints (contextual help)
    └── Values (current state)
```

## File Dependencies

```
Your View
├── Imports Design Tokens
│   ├── Colors (automatic via extension)
│   ├── Typography (automatic via extension)
│   ├── Spacing (enum, manual import)
│   └── SpringAnimations (extension & enum)
│
├── Uses Components
│   ├── VitalCard (auto-imports all styling)
│   ├── VitalButton (includes haptics)
│   ├── MetricCard (includes sparkline)
│   └── Other specialized components
│
└── Applies Utilities
    ├── ViewExtensions (automatic)
    ├── Shadow modifiers (via Spacing)
    └── Animation helpers (via SpringAnimations)
```

## Component Selection Guide

### Need a container?
- **Basic**: Use `VitalCard`
- **Highlight**: Use `VitalGradientCard`
- **Subtle**: Use `VitalBorderedCard`

### Need a button?
- **Primary action**: Use `VitalButton(.primary)`
- **Secondary action**: Use `VitalButton(.secondary)`
- **Destructive**: Use `VitalButton(.danger)`
- **Icon only**: Use `VitalIconButton`

### Need to show data?
- **Single metric**: Use `MetricCard`
- **Time series**: Use `VitalLineChart` or `VitalBarChart`
- **Progress**: Use `CircularProgressRing`
- **Comparison**: Use `VitalBarChart`

### Need user input?
- **Short text**: Use `VitalTextField`
- **Long text**: Use `VitalTextEditor`
- **Search**: Use `VitalSearchField`

### Need to show state?
- **No data**: Use `VitalEmptyState`
- **Loading**: Use `VitalLoadingState`
- **Error**: Use `VitalErrorState`

### Need a modal?
- **Custom content**: Use `VitalBottomSheet`
- **Confirm action**: Use `VitalConfirmationSheet`
- **Choose option**: Use `VitalActionSheet`

## Best Practices Summary

1. **Always use design tokens** - Never hardcode colors, sizes, or spacing
2. **Compose with VitalCard** - Build complex components from VitalCard
3. **Add haptics to interactions** - Use HapticFeedback for user actions
4. **Support dark mode** - Use adaptive colors throughout
5. **Include accessibility** - Add labels, hints, and values
6. **Animate transitions** - Use design system animations
7. **Handle empty states** - Show helpful messages when no data
8. **Test on real devices** - Verify animations and interactions
9. **Check Dynamic Type** - Ensure text scales properly
10. **Document your components** - Add examples and previews

---

For complete documentation, see `README.md` in the DesignSystem folder.
