# VitalArc Design System

A comprehensive, modern design system for the VitalArc fitness tracking app.

## Overview

The VitalArc Design System provides a consistent, accessible, and visually polished set of components, colors, typography, and spacing tokens for building beautiful user interfaces.

## Core Principles

1. **Consistency**: All components follow the same visual language
2. **Accessibility**: Full support for Dynamic Type, VoiceOver, and high contrast modes
3. **Dark Mode**: Native dark mode support across all components
4. **Performance**: Lightweight components with smooth animations
5. **Developer Experience**: Easy to use with SwiftUI best practices

---

## Color System

### Primary Palette

```swift
Color.vitalPrimary      // Indigo (#6366F1) - Primary actions
Color.vitalSecondary    // Purple (#8B5CF6) - Secondary actions
Color.vitalAccent       // Pink (#EC4899) - Accent highlights
```

### Functional Colors

```swift
Color.vitalSuccess      // Green (#10B981) - Success states
Color.vitalWarning      // Amber (#F59E0B) - Warnings
Color.vitalDanger       // Red (#EF4444) - Errors/destructive
Color.vitalInfo         // Blue (#3B82F6) - Information
```

### Adaptive Colors (Auto Dark Mode)

```swift
Color.vitalAdaptiveBackground  // Switches between light/dark
Color.vitalAdaptiveSurface     // Card backgrounds
Color.vitalAdaptiveBorder      // Borders
Color.vitalAdaptiveTextPrimary // Primary text
Color.vitalAdaptiveTextSecondary // Secondary text
```

### Gradients

```swift
Color.vitalPrimaryGradient  // Indigo to Purple
Color.vitalAccentGradient   // Purple to Pink
Color.vitalSuccessGradient  // Green gradient
```

**Usage Example:**
```swift
Text("Hello")
    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
    .background(Color.vitalAdaptiveSurface)
```

---

## Typography

### Display Fonts

```swift
Font.vitalDisplayLarge   // 34pt, bold, rounded
Font.vitalDisplayMedium  // 28pt, bold, rounded
Font.vitalDisplaySmall   // 24pt, semibold, rounded
```

### Headings

```swift
Font.vitalH1  // 22pt, bold
Font.vitalH2  // 20pt, semibold
Font.vitalH3  // 18pt, semibold
Font.vitalH4  // 16pt, semibold
```

### Body Text

```swift
Font.vitalBody       // 14pt, regular
Font.vitalBodyLarge  // 16pt, regular
Font.vitalBodySmall  // 12pt, regular
```

### Labels

```swift
Font.vitalLabel      // 14pt, medium
Font.vitalLabelSmall // 12pt, medium
Font.vitalLabelTiny  // 10pt, medium
```

### Numbers (Tabular)

```swift
Font.vitalNumberLarge  // 28pt, bold, monospaced
Font.vitalNumberMedium // 20pt, semibold, monospaced
Font.vitalNumberSmall  // 16pt, medium, monospaced
```

**Usage Example:**
```swift
Text("Welcome")
    .font(.vitalDisplayLarge)
    .foregroundStyle(Color.vitalAdaptiveTextPrimary)
```

---

## Spacing Scale

```swift
Spacing.xxs   // 2pt
Spacing.xs    // 4pt
Spacing.sm    // 8pt
Spacing.md    // 16pt
Spacing.lg    // 24pt
Spacing.xl    // 32pt
Spacing.xxl   // 48pt
Spacing.xxxl  // 64pt
```

### Semantic Spacing

```swift
Spacing.cardPadding      // 16pt
Spacing.screenPadding    // 20pt
Spacing.sectionSpacing   // 24pt
Spacing.itemSpacing      // 12pt
```

### Corner Radius

```swift
Spacing.radiusSmall   // 8pt
Spacing.radiusMedium  // 12pt
Spacing.radiusLarge   // 16pt
Spacing.radiusXLarge  // 24pt
```

---

## Components

### VitalCard

Basic card component with shadow and rounded corners.

```swift
VitalCard {
    Text("Card content")
}

// With custom options
VitalCard(
    padding: Spacing.lg,
    shadow: true,
    backgroundColor: .vitalAdaptiveSurface,
    cornerRadius: Spacing.radiusLarge
) {
    Text("Custom card")
}
```

**Variants:**
- `VitalGradientCard` - Card with gradient background
- `VitalBorderedCard` - Card with border instead of shadow

### VitalButton

Modern button with multiple styles and states.

```swift
VitalButton(
    title: "Click Me",
    style: .primary,
    size: .medium,
    icon: "heart.fill",
    fullWidth: true
) {
    print("Tapped!")
}
```

**Styles:**
- `.primary` - Primary action (filled)
- `.secondary` - Secondary action (filled)
- `.outline` - Outlined button
- `.text` - Text-only button
- `.danger` - Destructive action
- `.success` - Success action

**Sizes:**
- `.small` - Compact size
- `.medium` - Standard size (default)
- `.large` - Large, prominent

**States:**
- `isLoading: true` - Shows loading spinner
- `isDisabled: true` - Disabled state

### VitalIconButton

Circular icon button.

```swift
VitalIconButton(
    icon: "heart.fill",
    style: .primary,
    size: 44
) {
    print("Icon tapped!")
}
```

### VitalTextField

Modern text input field.

```swift
VitalTextField(
    title: "Email",
    text: $email,
    placeholder: "Enter your email",
    icon: "envelope",
    keyboardType: .emailAddress,
    errorMessage: emailError
)
```

**Variants:**
- `VitalTextEditor` - Multi-line text input
- `VitalSearchField` - Search bar with clear button

### MetricCard

Health metric display card with sparkline.

```swift
MetricCard(
    title: "Heart Rate",
    value: "72",
    unit: "BPM",
    icon: "heart.fill",
    color: .vitalDanger,
    trend: .down,
    sparklineData: [65, 68, 70, 72, 71, 69, 72]
)
```

### ProgressChart

Chart components using Swift Charts.

```swift
// Line Chart
VitalLineChart(
    title: "Heart Rate Variability",
    data: chartData,
    color: .vitalDanger,
    unit: "ms"
)

// Bar Chart
VitalBarChart(
    title: "Daily Steps",
    data: chartData,
    color: .vitalInfo,
    unit: "steps"
)

// Circular Progress
CircularProgressRing(
    progress: 0.75,
    color: .vitalPrimary,
    lineWidth: 12,
    size: 120
)
```

### ExerciseCard

Exercise display card with muscle group visualization.

```swift
ExerciseCard(
    exerciseName: "Bench Press",
    muscleGroup: "Chest",
    equipment: "Barbell",
    sets: 4,
    reps: "8-10",
    weight: "80 kg",
    onTap: { print("Tapped") },
    onDelete: { print("Delete") }
)
```

### FoodCard

Food item card with macro visualization.

```swift
FoodCard(
    foodName: "Chicken Breast",
    servingSize: "150g",
    calories: 165,
    protein: 31,
    carbs: 0,
    fat: 3.6,
    mealType: "Lunch",
    onTap: { print("Tapped") },
    onDelete: { print("Delete") }
)
```

---

## Animations

### Spring Animations

```swift
Animation.vitalSpring        // Standard spring (0.3s, 0.7 damping)
Animation.vitalSpringBouncy  // Bouncy spring
Animation.vitalSpringSnappy  // Quick, snappy spring
```

### Easing Animations

```swift
Animation.vitalEaseOut    // 0.2s ease out
Animation.vitalEaseInOut  // 0.25s ease in-out
Animation.vitalSmooth     // 0.3s smooth
```

### Button Styles

```swift
VitalButton(...)
    .vitalScaleButton()  // Scale down on press

Button(...) {}
    .vitalPressButton()  // Opacity on press
```

### Transitions

```swift
.transition(.vitalSlideUp)  // Slide up with fade
.transition(.vitalScale)    // Scale with fade
.transition(.vitalFade)     // Fade only
```

**Usage Example:**
```swift
if showContent {
    Text("Animated")
        .transition(.vitalSlideUp)
}
.animation(.vitalSpring, value: showContent)
```

---

## Haptic Feedback

Provide tactile feedback for interactions.

```swift
HapticFeedback.light()     // Light tap
HapticFeedback.medium()    // Medium tap
HapticFeedback.heavy()     // Heavy tap
HapticFeedback.selection() // Selection changed
HapticFeedback.success()   // Success notification
HapticFeedback.warning()   // Warning notification
HapticFeedback.error()     // Error notification
```

---

## Shadow Styles

```swift
.vitalCardShadow()      // Small shadow (cards)
.vitalElevatedShadow()  // Medium shadow (elevated elements)
.vitalFloatingShadow()  // Large shadow (floating elements)
```

---

## Accessibility

All components support:

1. **Dynamic Type** - Text scales with user preferences
2. **VoiceOver** - All components have proper labels
3. **High Contrast** - Colors adjust in high contrast mode
4. **Reduced Motion** - Animations respect reduced motion settings
5. **Dark Mode** - Full native support

**Testing Accessibility:**
```swift
// Enable in simulator
// Settings > Accessibility > Display & Text Size > Larger Text
// Settings > Accessibility > Display & Text Size > Increase Contrast
// Settings > Accessibility > Motion > Reduce Motion
```

---

## Best Practices

### 1. Use Adaptive Colors

```swift
// Good ✅
Text("Hello")
    .foregroundStyle(Color.vitalAdaptiveTextPrimary)

// Avoid ❌
Text("Hello")
    .foregroundStyle(.black) // Won't work in dark mode
```

### 2. Use Spacing Tokens

```swift
// Good ✅
VStack(spacing: Spacing.md) { ... }

// Avoid ❌
VStack(spacing: 16) { ... } // Use token instead
```

### 3. Use Typography Scale

```swift
// Good ✅
Text("Title")
    .font(.vitalH2)

// Avoid ❌
Text("Title")
    .font(.system(size: 20, weight: .semibold)) // Use scale
```

### 4. Add Haptic Feedback to Interactions

```swift
Button("Save") {
    HapticFeedback.light()
    save()
}
```

### 5. Use Semantic Components

```swift
// Good ✅
MetricCard(title: "Steps", value: "10,000", ...)

// Avoid ❌
VStack {
    Text("Steps")
    Text("10,000")
} // Use semantic component instead
```

---

## Migration Guide

### Updating Existing Views

1. Replace `Color(.systemBackground)` with `Color.vitalAdaptiveBackground`
2. Replace custom spacing with `Spacing` tokens
3. Replace `.font(.headline)` with `.font(.vitalH3)`
4. Wrap content in `VitalCard` instead of manual styling
5. Replace custom buttons with `VitalButton`

**Before:**
```swift
VStack(spacing: 16) {
    Text("Title")
        .font(.headline)
        .foregroundColor(.primary)
}
.padding()
.background(Color(.systemBackground))
.cornerRadius(12)
.shadow(color: .black.opacity(0.05), radius: 5)
```

**After:**
```swift
VitalCard {
    VStack(spacing: Spacing.md) {
        Text("Title")
            .font(.vitalH3)
            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
    }
}
```

---

## Examples

See `#Preview` blocks in each component file for live examples and usage patterns.

---

## Support

For questions or issues with the design system, please refer to component preview examples or consult the VitalArc development team.
