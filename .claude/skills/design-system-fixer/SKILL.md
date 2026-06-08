---
name: design-system-fixer
description: Auto-fix design system violations found by design-system-scanner. Workstation only - requires build verification after fixes. Takes scanner report as input.
context: fork
agent: general-purpose
disable-model-invocation: true
allowed-tools: Read, Edit, Bash, TaskCreate, TaskUpdate, TaskList
argument-hint: [--file=specific/file.swift] [--dry-run] [--all]
---

# Design System Fixer

Applies automatic fixes for design token violations. **Workstation only** - requires build capability to verify fixes.

**Execution**: Runs in forked context with general-purpose agent.
**Invocation**: User-triggered only (modifies files).

**IMPORTANT**: When invoked without arguments, execute immediately with default settings. Never ask for clarification - use defaults and produce results.

## Default Behavior (No Arguments)

When invoked without arguments:
- **Mode**: Dry-run first, then apply all fixes across `VitalArc/Modules/`
- **Scope**: All violation categories (colors, spacing, typography, icon sizes)
- **Verification**: Run build after applying fixes

Execute the full default fix workflow immediately. Do not ask for clarification.

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

Only auto-fix values that have an **exact** token match (matching the values in `VitalArc/Modules/Shared/DesignSystem/Spacing.swift`). Values with no exact token must be FLAGGED for manual review, never silently snapped to a nearby token. These mappings are kept in sync with `design-system-scanner`.

| Violation | Fix (exact match) |
|-----------|-----|
| `.padding(4)` | `.padding(Spacing.xs)` |
| `.padding(8)` | `.padding(Spacing.sm)` |
| `.padding(16)` | `.padding(Spacing.md)` |
| `.padding(20)` | `.padding(Spacing.screenPadding)` |
| `.padding(24)` | `.padding(Spacing.lg)` |
| `.padding(32)` | `.padding(Spacing.xl)` |
| `.padding(48)` | `.padding(Spacing.xxl)` |
| `.cornerRadius(8)` | `.cornerRadius(Spacing.radiusSmall)` |
| `.cornerRadius(12)` | `.cornerRadius(Spacing.radiusMedium)` |
| `.cornerRadius(16)` | `.cornerRadius(Spacing.radiusLarge)` |

**Flag, do NOT auto-fix (no exact base token — value would change):**

| Violation | Why flagged |
|-----------|-------------|
| `.padding(12)` | No exact base-scale token (`Spacing.md` is `16`, so auto-fixing would change `12` → `16`). May be intended as `Spacing.itemSpacing` (`12`) depending on context — review manually. |

### Icon Sizes

Auto-fix only exact matches against the `iconXxx` tokens in `Spacing.swift`. Off-scale sizes (e.g. `14`, `18`) must be FLAGGED, not snapped to the nearest token.

| Violation | Fix (exact match) |
|-----------|-----|
| `size: 16` | `size: Spacing.iconSmall` |
| `size: 20` | `size: Spacing.iconMedium` |
| `size: 24` | `size: Spacing.iconLarge` |
| `size: 48` | `size: Spacing.iconHuge` |

> Only `iconSmall`(16), `iconMedium`(20), `iconLarge`(24), `iconHuge`(48) exist in `Spacing.swift`.

**Flag, do NOT auto-fix (off the icon scale — no exact token):**

| Violation | Why flagged |
|-----------|-------------|
| `size: 10`, `12`, `14`, `18` | Below/between `iconSmall` (`16`) / `iconMedium` (`20`) — review manually. |
| `size: 32`, `40` | Between `iconLarge` (`24`) and `iconHuge` (`48`) — review manually. |

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

## Task Tracking

When fixing multiple files, create tasks to track progress:

```javascript
// Create task for each file being fixed
files_to_fix.forEach(file => {
  TaskCreate({
    subject: `Fix design tokens in ${basename(file)}`,
    description: `Apply design system fixes to ${file}:
      - Replace hardcoded colors with vitalColor tokens
      - Replace hardcoded spacing with Spacing tokens
      - Replace system fonts with Typography tokens`,
    activeForm: `Fixing ${basename(file)}`
  })
})

// Update task status as each file is processed
TaskUpdate({
  taskId: task.id,
  status: "completed"
})
```

This provides visibility into progress during multi-file fixing operations.

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
design-system-fixer --file=VitalArc/Modules/Shared/User/Presentation/ProfileView.swift
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
