---
name: cloud-quality-gate
description: Validate code quality without requiring builds. Use in cloud sessions to catch issues before they reach CI. Checks syntax, design system compliance, secrets, and import consistency.
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

# Cloud Quality Gate

Validates code quality without requiring Xcode builds. Designed for cloud sessions where build capability is unavailable.

**Execution**: Runs in forked context with Explore agent (read-only analysis).

## When to Use

- During cloud sessions before ending
- When build capability is unavailable
- Quick validation before pushing changes
- As part of `/vitalarc-end-cloud` workflow

## What It Validates

| Check | Description | Severity |
|-------|-------------|----------|
| Syntax Patterns | Common Swift syntax issues | Error |
| Design System | Token compliance | Warning |
| Secrets Detection | Hardcoded credentials | Critical |
| Import Consistency | Missing/unused imports | Warning |
| TODO/FIXME | Uncommitted blockers | Info |

## Implementation

### 1. Syntax Pattern Checks

Look for common issues without compiling:

```bash
# Force unwraps (potential crashes)
grep -rn "\.force" VitalArc/ --include="*.swift" | grep -v "Test"
grep -rn "as!" VitalArc/ --include="*.swift" | grep -v "Test"

# Unclosed braces (basic syntax)
# Check for mismatched { } counts per file

# Print statements (debug code)
grep -rn "print(" VitalArc/ --include="*.swift" | grep -v "Test" | grep -v "// debug"
```

### 2. Secrets Detection

**CRITICAL**: Flag any potential credentials:

```bash
# API keys
grep -rniE "(api[_-]?key|apikey|secret|password|credential)" VitalArc/ --include="*.swift"

# Hardcoded URLs with potential tokens
grep -rn "https://.*\?.*token=" VitalArc/ --include="*.swift"

# Known placeholder patterns that should be replaced
grep -rn "YOUR_.*_HERE\|DEMO_KEY\|changeme\|placeholder" VitalArc/ --include="*.swift"
```

### 3. Design System Compliance

Check for design token violations:

```bash
# Hardcoded colors
grep -rn "Color\.\(red\|blue\|green\|gray\|black\|white\)" VitalArc/Modules/ --include="*.swift"

# Hardcoded padding values
grep -rn "\.padding([0-9]" VitalArc/Modules/ --include="*.swift"

# System fonts instead of design tokens
grep -rn "\.font(.system" VitalArc/Modules/ --include="*.swift"
```

### 4. Import Consistency

Check for import issues:

```bash
# UIKit in SwiftUI views (should use SwiftUI)
grep -rn "^import UIKit" VitalArc/Modules/ --include="*.swift"

# UIKit in Domain layer (architecture violation)
grep -rn "^import UIKit" VitalArc/Domain/ --include="*.swift"

# Foundation where not needed
# (heuristic: file uses only types available in Swift stdlib)
```

### 5. TODO/FIXME Check

Flag blockers before commit:

```bash
# TODO and FIXME comments
grep -rn "// TODO:\|// FIXME:\|// HACK:\|// XXX:" VitalArc/ --include="*.swift"
```

## Output Format

### Full Report

```markdown
## Cloud Quality Gate Report

### Summary
| Check | Status | Issues |
|-------|--------|--------|
| Secrets | Pass | 0 |
| Syntax | Warning | 2 |
| Design System | Warning | 5 |
| Imports | Pass | 0 |
| TODOs | Info | 3 |

**Overall**: Passed (no blockers)

---

### Critical Issues (0)
No critical issues found.

### Warnings (7)

#### Syntax Patterns
| File | Line | Issue |
|------|------|-------|
| WorkoutView.swift | 45 | Force cast: `as! String` |
| ProfileVM.swift | 89 | Force unwrap: `.first!` |

**Suggestion**: Use optional binding or guard statements.

#### Design System Violations
| File | Line | Violation |
|------|------|-----------|
| NewFeatureView.swift | 23 | `Color.red` -> `Color.vitalDanger` |
| NewFeatureView.swift | 45 | `.padding(16)` -> `.padding(Spacing.md)` |
| SettingsRow.swift | 12 | `.font(.system(size: 14))` -> `.font(.vitalBody)` |

**Note**: Run `/design-system-fixer` on workstation to auto-fix.

### Info (3)

#### TODOs/FIXMEs
- `NotificationManager.swift:67`: `// TODO: Add retry logic`
- `CacheManager.swift:34`: `// FIXME: Handle edge case`
- `ExportService.swift:89`: `// TODO: Support CSV format`

These are informational - review before marking PR ready.

---

### Recommendation
Code is safe to push. Address warnings in follow-up commit.
```

### Failure Report (Critical Issues)

```markdown
## Cloud Quality Gate Report

### Summary
| Check | Status | Issues |
|-------|--------|--------|
| Secrets | CRITICAL | 2 |
| Syntax | Warning | 1 |
| Design System | Warning | 3 |
| Imports | Pass | 0 |
| TODOs | Info | 1 |

**Overall**: BLOCKED

---

### CRITICAL Issues (2)

These MUST be fixed before pushing:

#### Potential Secrets Detected

**NutritionixAPI.swift:15**
```swift
private let apiKey = "abc123def456"  // Hardcoded API key!
```
**Fix**: Move to environment variable or secure storage.

**ConfigManager.swift:8**
```swift
let password = "admin123"  // Hardcoded password!
```
**Fix**: Remove or use secure credential storage.

---

Fix critical issues and re-run `/cloud-quality-gate`.
```

### Clean Report

```markdown
## Cloud Quality Gate Report

**Status**: Passed
**Files Checked**: 12 changed files
**Issues**: 0 critical, 0 warnings

All checks passed. Safe to push.
```

## Integration with Cloud Session End

Add to `vitalarc-end-cloud` as a quality gate:

```javascript
TaskCreate({
  subject: "Run cloud quality gate",
  description: `Run cloud-quality-gate validation:
    1. Check for secrets/credentials
    2. Validate design system compliance
    3. Check for syntax patterns
    4. Review TODOs/FIXMEs

    If CRITICAL issues found, block session end.`,
  activeForm: "Running quality gate"
})
```

## Limitations

This is a **heuristic-based** check, not a full compiler:

- May miss some issues that only manifest at compile time
- False positives possible for complex patterns
- Design system checks are pattern-based, not semantic

For complete validation, use workstation with full build.

## Comparison with Workstation Validation

| Check | Cloud | Workstation |
|-------|-------|-------------|
| Syntax patterns | Heuristic | Full compiler |
| Design system | Pattern matching | Pattern matching |
| Secrets | Same | Same |
| Build errors | No | Yes |
| Type checking | No | Yes |
| Test execution | No | Yes |

Cloud validation catches ~70% of issues without build. Use for quick feedback, verify with CI.
