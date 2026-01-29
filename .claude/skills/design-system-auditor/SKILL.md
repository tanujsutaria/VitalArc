---
name: design-system-auditor
description: Audit VitalArc SwiftUI views for design system compliance. Use automatically before commits, during code review, or when the user asks to check design consistency. Finds hardcoded colors, spacing, and fonts that should use design tokens.
maps-to-agent: Explore
allowed-tools: Read, Grep, Glob, Edit
---

# Design System Auditor Agent

Audits SwiftUI views for design system violations and can auto-fix them.

## When to Use

Auto-invoke when:
- Before committing UI changes
- After creating or modifying views
- User asks to "check design system", "audit tokens", "fix hardcoded"
- During code review of Presentation layer changes

## VitalArc Design Tokens

### Colors
| Violation | Correct Token |
|-----------|---------------|
| `Color.blue`, `.blue` | `Color.vitalPrimary` |
| `Color.red`, `.red` | `Color.vitalDanger` |
| `Color.green`, `.green` | `Color.vitalSuccess` |
| `Color.orange`, `.orange` | `Color.vitalWarning` |
| `Color(.systemBackground)` | `Color.vitalAdaptiveBackground` |
| `Color(.systemGray6)` | `Color.vitalAdaptiveSurface` |
| `Color.primary` | `Color.vitalAdaptiveTextPrimary` |
| `Color.secondary` | `Color.vitalAdaptiveTextSecondary` |

### Spacing
| Violation | Correct Token |
|-----------|---------------|
| `.padding(4)` | `.padding(Spacing.xs)` |
| `.padding(8)` | `.padding(Spacing.sm)` |
| `.padding(12)` | `.padding(Spacing.md)` |
| `.padding(16)` | `.padding(Spacing.lg)` |
| `.padding(20)` | `.padding(Spacing.screenPadding)` |
| `.padding(24)` | `.padding(Spacing.xl)` |
| `spacing: 8` | `spacing: Spacing.sm` |
| `spacing: 16` | `spacing: Spacing.lg` |
| `.cornerRadius(8)` | `.cornerRadius(Spacing.radiusSmall)` |
| `.cornerRadius(12)` | `.cornerRadius(Spacing.radiusMedium)` |

### Typography
| Violation | Correct Token |
|-----------|---------------|
| `.font(.largeTitle)` | `.font(.vitalDisplayLarge)` |
| `.font(.title)` | `.font(.vitalH1)` |
| `.font(.title2)` | `.font(.vitalH2)` |
| `.font(.title3)` | `.font(.vitalH3)` |
| `.font(.headline)` | `.font(.vitalH4)` |
| `.font(.body)` | `.font(.vitalBody)` |
| `.font(.caption)` | `.font(.vitalCaption)` |
| `.font(.system(size: N))` | Check context, use appropriate token |

### Icon Sizes (in Spacing.swift)
| Size | Token |
|------|-------|
| 10 | `Spacing.iconTiny` |
| 12 | `Spacing.iconXSmall` |
| 14 | `Spacing.iconSmall` |
| 16 | `Spacing.iconMedium` |
| 20 | `Spacing.iconDefault` |
| 24 | `Spacing.iconLarge` |
| 32 | `Spacing.iconXLarge` |
| 40 | `Spacing.icon2XLarge` |
| 48 | `Spacing.iconHuge` |
| 60 | `Spacing.iconGiant` |
| 64 | `Spacing.iconHero` |

## Audit Process

### 1. Scan for Violations

```bash
# Colors
grep -rn "Color\.blue\|Color\.red\|Color\.green\|\.blue\|\.red\|\.green" Presentation/
grep -rn "Color(.system" Presentation/
grep -rn "Color\.primary\|Color\.secondary" Presentation/

# Spacing
grep -rn "\.padding([0-9]" Presentation/
grep -rn "spacing: [0-9]" Presentation/
grep -rn "\.cornerRadius([0-9]" Presentation/

# Typography
grep -rn "\.font(.largeTitle)\|\.font(.title)\|\.font(.body)" Presentation/
grep -rn "\.font(.system(size:" Presentation/
```

### 2. Categorize Results

**Critical** (must fix):
- Hardcoded semantic colors (`.blue`, `.red`)
- System colors in UI (`.systemGray6`)

**High** (should fix):
- Hardcoded spacing values
- Hardcoded corner radius

**Medium** (review):
- `.font(.system(size:))` - may be valid for icons
- Typography overrides

**Acceptable exceptions:**
- SF Symbol sizing (`.font(.system(size: N))` for icons)
- Dynamic calculations
- Third-party library requirements
- Preview blocks

### 3. Report Findings

```markdown
## Design System Audit Report

### Summary
- **Files scanned**: 70
- **Violations found**: 15
- **Auto-fixable**: 12

### Critical Violations (3)

| File | Line | Violation | Fix |
|------|------|-----------|-----|
| FeatureView.swift | 42 | `Color.blue` | `Color.vitalPrimary` |
| CardView.swift | 18 | `.red` | `Color.vitalDanger` |
| ListRow.swift | 55 | `Color(.systemGray6)` | `Color.vitalAdaptiveSurface` |

### High Priority (8)

| File | Line | Violation | Fix |
|------|------|-----------|-----|
| FeatureView.swift | 30 | `.padding(16)` | `.padding(Spacing.lg)` |
| ... | ... | ... | ... |

### Acceptable (4)
- FeatureView.swift:67 - Icon sizing (SF Symbol)
- ChartView.swift:23 - Dynamic calculation
```

### 4. Auto-Fix (if enabled)

When user confirms, apply fixes:

```swift
// Before
.foregroundColor(.blue)
.padding(16)
.font(.title)

// After
.foregroundColor(Color.vitalPrimary)
.padding(Spacing.lg)
.font(.vitalH1)
```

## Output Modes

### Audit Only (default)
```
/design-system-auditor

→ Reports violations, no changes
```

### Audit + Fix
```
/design-system-auditor fix

→ Reports violations and applies auto-fixes
```

### Single File
```
/design-system-auditor FeatureView.swift

→ Audits specific file only
```

## Integration

This agent is part of the **Pre-Commit Quality Gate** swarm:
1. `build-validator` - Compilation check
2. `design-system-auditor` (this) - Design token compliance

Run both before committing:
```
Pre-commit check:
1. Build: PASSING
2. Design System: 0 violations

Ready to commit!
```

## Example Report

```markdown
## Design System Audit: Presentation/Tabs/Workout/

### Summary
Files: 12 | Violations: 5 | Auto-fixable: 5

### Violations

1. **WorkoutLoggingView.swift:89**
   ```swift
   // Before
   .foregroundColor(.green)
   // After
   .foregroundColor(Color.vitalSuccess)
   ```

2. **SetRowView.swift:34**
   ```swift
   // Before
   .padding(8)
   // After
   .padding(Spacing.sm)
   ```

3. **ExerciseCard.swift:56**
   ```swift
   // Before
   Color(.systemGray6)
   // After
   Color.vitalAdaptiveSurface
   ```

### Fix Command
Apply all fixes? (y/n)
```
