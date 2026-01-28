# VitalArc Design System

A modern, fitness-focused design system with dark mode support.

---

## Colors

### Primary Palette
| Token | Hex | Usage |
|-------|-----|-------|
| `vitalPrimary` | #6366F1 | Primary actions, CTAs |
| `vitalSecondary` | #8B5CF6 | Secondary elements |
| `vitalAccent` | #EC4899 | Highlights, accents |

### Functional Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `vitalSuccess` | #10B981 | Success states, positive trends |
| `vitalWarning` | #F59E0B | Warnings, caution |
| `vitalDanger` | #EF4444 | Errors, destructive actions |
| `vitalInfo` | #3B82F6 | Information, neutral highlights |

### Adaptive Colors (auto dark/light mode)
| Token | Light | Dark |
|-------|-------|------|
| `vitalAdaptiveBackground` | #F9FAFB | #111827 |
| `vitalAdaptiveSurface` | white | #1F2937 |
| `vitalAdaptiveBorder` | #E5E7EB | #374151 |
| `vitalAdaptiveTextPrimary` | #111827 | #F9FAFB |
| `vitalAdaptiveTextSecondary` | #6B7280 | #9CA3AF |

### Gradients
```swift
Color.vitalGradientPrimary    // Indigo → Purple
Color.vitalGradientSuccess    // Teal → Green
Color.vitalGradientWarning    // Orange → Amber
Color.vitalGradientDanger     // Red → Pink
```

---

## Typography

### Scale
| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `.vitalDisplayLarge` | 34pt | Bold | Hero text |
| `.vitalDisplayMedium` | 28pt | Bold | Section headers |
| `.vitalH1` | 22pt | Bold | Screen titles |
| `.vitalH2` | 20pt | Semibold | Card titles |
| `.vitalH3` | 17pt | Semibold | Subsections |
| `.vitalH4` | 15pt | Medium | Labels |
| `.vitalBody` | 14pt | Regular | Body text |
| `.vitalBodySmall` | 13pt | Regular | Secondary text |
| `.vitalCaption` | 12pt | Regular | Captions |
| `.vitalCaptionSmall` | 11pt | Regular | Fine print |

### Special
```swift
.font(.vitalTabular)           // Monospace numbers for metrics
.font(.vitalLabel)             // Uppercase tracking for labels
```

---

## Spacing

### Base Scale (8-point system)
| Token | Value | Usage |
|-------|-------|-------|
| `Spacing.xxs` | 2pt | Hairline gaps |
| `Spacing.xs` | 4pt | Tight spacing |
| `Spacing.sm` | 8pt | Related elements |
| `Spacing.md` | 12pt | Default gap |
| `Spacing.lg` | 16pt | Section spacing |
| `Spacing.xl` | 24pt | Major sections |
| `Spacing.xxl` | 32pt | Screen sections |
| `Spacing.xxxl` | 48pt | Hero spacing |

### Semantic Tokens
| Token | Value | Usage |
|-------|-------|-------|
| `Spacing.screenPadding` | 20pt | Screen edge padding |
| `Spacing.cardPadding` | 16pt | Card internal padding |
| `Spacing.listItemSpacing` | 12pt | Between list items |
| `Spacing.sectionSpacing` | 24pt | Between sections |

### Corner Radius
| Token | Value |
|-------|-------|
| `Spacing.radiusSmall` | 8pt |
| `Spacing.radiusMedium` | 12pt |
| `Spacing.radiusLarge` | 16pt |
| `Spacing.radiusXLarge` | 24pt |

---

## Components

### VitalCard
Container for grouped content.

```swift
VitalCard {
    // content
}

VitalCard(style: .gradient)    // Gradient background
VitalCard(style: .bordered)    // Border instead of shadow
```

### VitalButton
Primary interaction element.

**Styles:**
| Style | Usage |
|-------|-------|
| `.primary` | Main CTAs (filled, primary color) |
| `.secondary` | Secondary actions (filled, gray) |
| `.outline` | Tertiary actions (bordered) |
| `.text` | Minimal actions (text only) |
| `.danger` | Destructive actions (red) |
| `.success` | Confirmation actions (green) |

**Sizes:** `.small`, `.medium`, `.large`

```swift
VitalButton("Save", style: .primary, size: .large) { }
VitalButton("Delete", style: .danger, isLoading: isDeleting) { }
VitalButton("Edit", icon: "pencil") { }
```

### VitalTextField
Text input with validation.

```swift
VitalTextField("Email", text: $email, icon: "envelope")
VitalTextField("Password", text: $password, isSecure: true)
VitalTextField("Name", text: $name, error: nameError)
```

**Variants:**
- `VitalSearchField` - Search with clear button
- `VitalTextEditor` - Multi-line input

### MetricCard
Health metric display with trends.

```swift
MetricCard(
    title: "Weight",
    value: "165",
    unit: "lbs",
    trend: .down,
    icon: "scalemass",
    color: .vitalInfo
)
```

**Trend indicators:** `.up` (green), `.down` (red), `.stable` (gray)

### ProgressChart
Data visualization components.

```swift
VitalLineChart(data: weights, color: .vitalPrimary)
VitalBarChart(data: volumes, gradient: .vitalGradientPrimary)
CircularProgressRing(progress: 0.75, color: .vitalSuccess)
```

### ExerciseCard
Exercise display with muscle group coloring.

```swift
ExerciseCard(exercise: exercise, onTap: { })
```

### VitalEmptyState
Placeholder for empty lists/states.

```swift
VitalEmptyState(
    icon: "dumbbell",
    title: "No Workouts",
    message: "Start your first workout to see it here"
)
```

---

## Animations

### Springs
| Token | Feel |
|-------|------|
| `.vitalBouncy` | Playful, high bounce |
| `.vitalSnappy` | Quick, responsive |
| `.vitalSmooth` | Gentle, relaxed |

### Usage
```swift
withAnimation(.vitalSnappy) { }
.transition(.vitalSlideUp)
.transition(.vitalFade)
```

### Haptics
```swift
HapticFeedback.light()
HapticFeedback.medium()
HapticFeedback.success()
HapticFeedback.error()
```

---

## View Modifiers

```swift
.vitalCard()                   // Apply card styling
.vitalCardPadding()            // Standard card padding
.vitalScreenPadding()          // Standard screen padding
.vitalShadow(.medium)          // Elevation shadow
.vitalAccessibility(label:)    // Accessibility label
```

---

## File Locations

```
VitalArc/Presentation/Common/DesignSystem/
├── Colors.swift
├── Typography.swift
├── Spacing.swift
├── ViewExtensions.swift
├── Animations/
│   └── SpringAnimations.swift
└── Components/
    ├── VitalCard.swift
    ├── VitalButton.swift
    ├── VitalTextField.swift
    ├── MetricCard.swift
    ├── ProgressChart.swift
    ├── ExerciseCard.swift
    └── VitalEmptyState.swift
```
