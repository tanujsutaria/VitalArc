---
name: design-system-fixer
description: Auto-fix design system violations found by design-system-scanner. Workstation only - requires build verification after fixes. Takes scanner report as input.
context: fork
agent: general-purpose
disable-model-invocation: true
allowed-tools: Read, Edit, Bash
argument-hint: [--file=specific/file.swift] [--dry-run] [--all]
---

# Design System Fixer

Applies automatic fixes for design token violations. **Workstation only** - requires build capability to verify fixes.

**Execution**: Runs in forked context with general-purpose agent.
**Invocation**: User-triggered only (modifies files).

## Prerequisites

1. Run `design-system-scanner` first to identify violations
2. Have build capability (workstation session)
3. Review scanner report before fixing

## Responsibility Split

| Agent | Platform | Capability |
|-------|----------|------------|
| design-system-scanner | Both | Find violations (read-only) |
| **design-system-fixer** | Workstation only | Fix violations (read-write) |

## Fix Mappings

### Colors

| Violation | Fix |
|-----------|-----|
| `Color.red` | `Color.vitalDanger` |
| `Color.blue` | `Color.vitalInfo` |
| `Color.green` | `Color.vitalSuccess` |
| `Color.orange`, `Color.yellow` | `Color.vitalWarning` |
| `Color.purple` | `Color.vitalAccent` |
| `Color.gray` | `Color.vitalAdaptiveTextSecondary` |
| `Color.white` | `Color.vitalAdaptiveSurface` |
| `Color.black` | `Color.vitalAdaptiveTextPrimary` |

### Spacing

| Violation | Fix |
|-----------|-----|
| `.padding(4)` | `.padding(Spacing.xs)` |
| `.padding(8)` | `.padding(Spacing.sm)` |
| `.padding(12)` | `.padding(Spacing.md)` |
| `.padding(16)` | `.padding(Spacing.md)` |
| `.padding(20)` | `.padding(Spacing.screenPadding)` |
| `.padding(24)` | `.padding(Spacing.lg)` |
| `.cornerRadius(8)` | `.cornerRadius(Spacing.radiusSmall)` |
| `.cornerRadius(12)` | `.cornerRadius(Spacing.radiusMedium)` |
| `.cornerRadius(16)` | `.cornerRadius(Spacing.radiusLarge)` |

### Icon Sizes

| Violation | Fix |
|-----------|-----|
| `size: 10` | `size: Spacing.iconTiny` |
| `size: 12` | `size: Spacing.iconXSmall` |
| `size: 14`, `size: 16` | `size: Spacing.iconSmall` |
| `size: 18`, `size: 20` | `size: Spacing.iconMedium` |
| `size: 24` | `size: Spacing.iconLarge` |
| `size: 32` | `size: Spacing.iconXLarge` |
| `size: 40` | `size: Spacing.icon2XLarge` |

### Typography

| Violation | Fix |
|-----------|-----|
| `.font(.title)` | `.font(.vitalH1)` |
| `.font(.title2)` | `.font(.vitalH2)` |
| `.font(.title3)` | `.font(.vitalH3)` |
| `.font(.headline)` | `.font(.vitalLabel)` |
| `.font(.body)` | `.font(.vitalBody)` |
| `.font(.caption)` | `.font(.vitalCaption)` |
| `.font(.caption2)` | `.font(.vitalCaptionSmall)` |

## Implementation

### Single File Fix

```bash
FILE="$1"

# Read current content
CONTENT=$(cat "$FILE")

# Apply color fixes
CONTENT=$(echo "$CONTENT" | sed 's/Color\.red/Color.vitalDanger/g')
CONTENT=$(echo "$CONTENT" | sed 's/Color\.blue/Color.vitalInfo/g')
CONTENT=$(echo "$CONTENT" | sed 's/Color\.green/Color.vitalSuccess/g')
# ... more replacements

# Write back
echo "$CONTENT" > "$FILE"
```

### Using Edit Tool

For precise fixes, use the Edit tool with specific old_string/new_string pairs:

```
Edit file: ProfileView.swift
old_string: .fill(Color.red)
new_string: .fill(Color.vitalDanger)
```

## Modes

### --dry-run

Show what would be fixed without making changes:

```markdown
## Dry Run Results

### ProfileView.swift
Would fix 3 violations:
- Line 45: `Color.red` → `Color.vitalDanger`
- Line 78: `.padding(16)` → `.padding(Spacing.md)`
- Line 92: `.font(.system(size: 14))` → `.font(.vitalBody)`

### WorkoutView.swift
Would fix 2 violations:
- Line 23: `.cornerRadius(12)` → `.cornerRadius(Spacing.radiusMedium)`
- Line 45: `Color.green` → `Color.vitalSuccess`

**Total: 5 fixes across 2 files**

Run without --dry-run to apply fixes.
```

### --file=path

Fix only a specific file:

```bash
design-system-fixer --file=VitalArc/Presentation/Tabs/Profile/ProfileView.swift
```

### --all

Fix all violations found by scanner (use with caution):

```bash
design-system-fixer --all
```

## Output Format

### Fix Report

```markdown
## Design System Fixes Applied

### Summary
| Files | Violations Fixed | Build Status |
|-------|-----------------|--------------|
| 5 | 12 | Passing |

### Fixes by File

#### ProfileView.swift
| Line | Before | After |
|------|--------|-------|
| 45 | `Color.red` | `Color.vitalDanger` |
| 78 | `.padding(16)` | `.padding(Spacing.md)` |
| 92 | `.font(.system(size: 14))` | `.font(.vitalBody)` |

#### WorkoutView.swift
| Line | Before | After |
|------|--------|-------|
| 23 | `.cornerRadius(12)` | `.cornerRadius(Spacing.radiusMedium)` |

### Build Verification
BUILD SUCCEEDED after fixes

### Remaining Manual Fixes
Some violations require manual review:
- `ExerciseView.swift:67` - Complex color calculation
- `ChartView.swift:123` - Dynamic spacing based on data
```

## Safety Checks

### Pre-Fix Validation

Before applying fixes:
1. Verify file exists
2. Check file is not in exclusion list (tests, design system files)
3. Validate fix won't break syntax

### Post-Fix Validation

After applying fixes:
1. **Run build** to verify no syntax errors
2. If build fails, **revert changes** and report

```markdown
## Fix Failed

Build failed after applying fixes to ProfileView.swift.

**Error:**
```
error: Cannot find 'Spacing' in scope
```

**Action:** Changes reverted. Ensure Spacing.swift is properly imported.
```

## Error Handling

### Ambiguous Fixes

When a fix is ambiguous:

```markdown
## Manual Review Required

### ExerciseView.swift:67
```swift
let dynamicColor = isActive ? Color.green : Color.red
```

**Issue:** Context-dependent color usage. Suggested mapping:
- `Color.green` → `Color.vitalSuccess` (if success state)
- `Color.red` → `Color.vitalDanger` (if error state)

Please review and fix manually.
```

### Build Failure After Fix

```markdown
## Build Failed After Fixes

Fixes applied but build failed. Rolling back...

**Reverted files:**
- ProfileView.swift
- WorkoutView.swift

**Build error:**
```
error: Type 'Spacing' has no member 'iconDefault'
```

**Suggested action:** Check Spacing.swift for available tokens.
```
