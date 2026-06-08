---
name: design-system-scanner
description: Audit VitalArc SwiftUI views for design system compliance (read-only). Use automatically before commits, during code review, or when the user asks to check design consistency. Finds hardcoded colors, spacing, fonts, and icon sizes that should use design tokens; does NOT fix them (use design-system-fixer). Works on cloud and workstation. Pass --deep for a full per-file audit.
context: fork
agent: Explore
allowed-tools: Read, Glob, Grep
---

# Design System Scanner

**YOU MUST execute immediately.** Do not ask for clarification. Do not ask what to explore. Run the scan below and produce the report.

## Scan Execution

1. Search `VitalArc/Modules/` for all `*.swift` files in `Presentation/` directories
2. Run grep patterns from the "Scan Patterns" section below
3. Exclude: Preview blocks, test files, design system definition files, comments
4. Output the report in the format specified in "Output Format"

## Default Settings
- **Scan path**: `VitalArc/Modules/` (all Presentation directories)
- **Output**: Summary report (not verbose)
- **Scope**: All violation categories (colors, spacing, typography, icon sizes)

### Optional Arguments (documented for reference)

When invoked by a user with specific needs:
- `--path=specific/path` - Scan only the specified path instead of full Presentation layer
- `--verbose` - Include code context around each violation
- `--deep` - Full per-file audit: report every category for every Presentation file (this mode supersedes the former separate design-system-auditor skill)

## Responsibility Split

| Agent | Platform | Capability | Purpose |
|-------|----------|------------|---------|
| **design-system-scanner** | Both | Read-only | Find violations |
| **design-system-fixer** | Workstation only | Read-write | Fix violations |

## What It Scans

### Colors
```swift
// Violations
Color.red
Color(.systemBlue)
Color(red: 0.5, green: 0.5, blue: 0.5)
UIColor.red

// Correct
Color.vitalPrimary
Color.vitalDanger
Color.vitalAdaptiveTextPrimary
```

### Spacing
```swift
// Violations
.padding(16)
.padding(.horizontal, 20)
.frame(width: 48)
.cornerRadius(12)

// Correct
.padding(Spacing.md)
.padding(.horizontal, Spacing.screenPadding)
.frame(width: Spacing.iconHuge)
.cornerRadius(Spacing.radiusMedium)
```

### Typography
```swift
// Violations
.font(.system(size: 14))
.font(.title)
.font(.headline)

// Correct
.font(.vitalBody)
.font(.vitalH1)
.font(.vitalLabel)
```

### Icon Sizes
```swift
// Violations
.font(.system(size: 24, weight: .bold))
Image(systemName: "star").font(.system(size: 20))

// Correct
.font(.system(size: Spacing.iconLarge, weight: .bold))
Image(systemName: "star").font(.system(size: Spacing.iconMedium))
```

## Scan Patterns

### Color Patterns (Grep)
```bash
# Direct Color references
grep -rn "Color\.\(red\|blue\|green\|yellow\|orange\|purple\|pink\|gray\|white\|black\)" VitalArc/Modules/

# System colors
grep -rn "Color(\.system" VitalArc/Modules/

# RGB colors
grep -rn "Color(red:" VitalArc/Modules/

# UIColor
grep -rn "UIColor\." VitalArc/Modules/
```

### Spacing Patterns (Grep)
```bash
# Hardcoded padding
grep -rn "\.padding([0-9]" VitalArc/Modules/

# Hardcoded frame dimensions
grep -rn "\.frame(width: [0-9]" VitalArc/Modules/
grep -rn "\.frame(height: [0-9]" VitalArc/Modules/

# Hardcoded corner radius
grep -rn "\.cornerRadius([0-9]" VitalArc/Modules/

# Hardcoded spacing in stacks
grep -rn "spacing: [0-9]" VitalArc/Modules/
```

### Typography Patterns (Grep)
```bash
# System fonts with size
grep -rn "\.font(\.system(size: [0-9]" VitalArc/Modules/

# Standard fonts
grep -rn "\.font(\.title)" VitalArc/Modules/
grep -rn "\.font(\.headline)" VitalArc/Modules/
grep -rn "\.font(\.body)" VitalArc/Modules/
grep -rn "\.font(\.caption)" VitalArc/Modules/
```

## Exclusions

Do NOT flag:
- Preview code (`#Preview { }`)
- Test files (`*Tests.swift`)
- Design system definition files (`Spacing.swift`, `Typography.swift`, `Colors.swift`)
- Comments
- Commented-out code

## Output Format

### Summary Report

```markdown
## Design System Scan Results

### Summary
| Category | Violations | Files |
|----------|------------|-------|
| Colors | 5 | 3 |
| Spacing | 12 | 7 |
| Typography | 8 | 4 |
| **Total** | **25** | **10** |

### Violations by File

#### ProfileView.swift (7 violations)
| Line | Category | Violation | Suggested Fix |
|------|----------|-----------|---------------|
| 45 | Color | `Color.red` | `Color.vitalDanger` |
| 78 | Spacing | `.padding(16)` | `.padding(Spacing.md)` |
| 92 | Typography | `.font(.system(size: 14))` | `.font(.vitalBody)` |

#### WorkoutView.swift (4 violations)
| Line | Category | Violation | Suggested Fix |
|------|----------|-----------|---------------|
| 23 | Spacing | `.cornerRadius(12)` | `.cornerRadius(Spacing.radiusMedium)` |
...

### Next Steps
Run `design-system-fixer` to auto-fix these violations (workstation only).
```

### Verbose Output

With `--verbose`, include code context:

```markdown
#### ProfileView.swift:45
```swift
// Line 43-47
ZStack {
    Circle()
        .fill(Color.red)  // Use Color.vitalDanger
        .frame(width: 48, height: 48)
}
```
**Suggested**: `.fill(Color.vitalDanger)`
```

## Token Reference

### Colors
| Token | Usage |
|-------|-------|
| `Color.vitalPrimary` | Primary actions (indigo) |
| `Color.vitalDanger` | Errors, destructive (red) |
| `Color.vitalSuccess` | Success states (green) |
| `Color.vitalWarning` | Warnings (amber) |
| `Color.vitalInfo` | Information (blue) |
| `Color.vitalAdaptiveBackground` | Screen backgrounds |
| `Color.vitalAdaptiveSurface` | Card surfaces |
| `Color.vitalAdaptiveTextPrimary` | Primary text |
| `Color.vitalAdaptiveTextSecondary` | Secondary text |

### Spacing
| Token | Value | Usage |
|-------|-------|-------|
| `Spacing.xs` | 4 | Tiny gaps |
| `Spacing.sm` | 8 | Small gaps |
| `Spacing.md` | 16 | Standard padding |
| `Spacing.lg` | 24 | Section spacing |
| `Spacing.screenPadding` | 20 | Screen edges |
| `Spacing.radiusSmall` | 8 | Small corners |
| `Spacing.radiusMedium` | 12 | Card corners |
| `Spacing.iconSmall` | 16 | Small icons |
| `Spacing.iconMedium` | 20 | Standard icons |
| `Spacing.iconLarge` | 24 | Large icons |

### Typography
| Token | Size | Usage |
|-------|------|-------|
| `.vitalDisplayLarge` | 34pt | Hero text |
| `.vitalH1` | 22pt | Page titles |
| `.vitalH2` | 20pt | Section headers |
| `.vitalH3` | 17pt | Card headers |
| `.vitalBody` | 14pt | Body text |
| `.vitalCaption` | 12pt | Secondary text |
| `.vitalLabel` | 14pt semibold | Labels |

## Error Handling

### No Violations Found

```markdown
## Design System Scan Results

No violations found!

Scanned 70 files in VitalArc/Modules/
All views comply with design system tokens.
```

### Scan Errors

```markdown
## Scan Incomplete

Some files could not be scanned:
- VitalArc/Modules/SomeView.swift: Permission denied

Results below are partial.
```
