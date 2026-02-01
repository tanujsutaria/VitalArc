---
name: lint-validator
description: Run SwiftLint on changed files and report violations. Use before commits or during code review to ensure code quality standards are met.
context: fork
agent: Bash
allowed-tools: Bash, Read, Glob, Grep
argument-hint: [--all] [--fix] [--strict]
---

# Lint Validator

Runs SwiftLint on changed files and reports violations. Integrates with the session workflow as a quality gate.

**Execution**: Runs in forked context with Bash agent.

## When to Use

- Before committing code changes
- During code review
- When user asks to "lint", "check code quality", or "run swiftlint"
- As part of session end workflow (quality gate)

## Prerequisites

SwiftLint must be installed:
```bash
# Check if installed
which swiftlint || brew install swiftlint

# Verify version
swiftlint version
```

## Implementation

### 1. Identify Files to Lint

By default, lint only changed files for efficiency:

```bash
# Get list of changed Swift files (staged + unstaged)
CHANGED_FILES=$(git diff --name-only HEAD -- '*.swift' 2>/dev/null)
STAGED_FILES=$(git diff --cached --name-only -- '*.swift' 2>/dev/null)
ALL_CHANGED=$(echo -e "$CHANGED_FILES\n$STAGED_FILES" | sort -u | grep -v '^$')

if [ -z "$ALL_CHANGED" ]; then
    echo "No Swift files changed - nothing to lint"
    exit 0
fi
```

### 2. Run SwiftLint

```bash
# Lint changed files only
echo "$ALL_CHANGED" | xargs swiftlint lint --quiet --reporter json

# Or lint all files (--all flag)
swiftlint lint --quiet --reporter json
```

### 3. Parse and Report Results

```bash
# Count violations by severity
ERRORS=$(swiftlint lint --quiet --reporter json | jq '[.[] | select(.severity == "error")] | length')
WARNINGS=$(swiftlint lint --quiet --reporter json | jq '[.[] | select(.severity == "warning")] | length')
```

## Options

| Option | Description |
|--------|-------------|
| `--all` | Lint entire codebase, not just changed files |
| `--fix` | Auto-fix violations where possible (use with caution) |
| `--strict` | Treat warnings as errors (fail on any violation) |

## Output Format

### Summary Report

```markdown
## SwiftLint Report

### Summary
| Severity | Count | Status |
|----------|-------|--------|
| Errors | 0 | Passing |
| Warnings | 3 | Review |

**Files Checked**: 5 changed files
**Time**: 1.2s

### Violations by File

#### ProfileViewModel.swift
| Line | Severity | Rule | Message |
|------|----------|------|---------|
| 45 | warning | line_length | Line should be 120 characters or less |
| 89 | warning | force_cast | Force casts should be avoided |

#### WorkoutView.swift
| Line | Severity | Rule | Message |
|------|----------|------|---------|
| 23 | warning | trailing_whitespace | Lines should not have trailing whitespace |

### Auto-Fixable Violations
3 violations can be auto-fixed with `--fix`:
- 1x trailing_whitespace
- 1x vertical_whitespace
- 1x colon_spacing

Run `/lint-validator --fix` to apply fixes.
```

### Clean Report

When no violations are found:

```markdown
## SwiftLint Report

**Status**: Clean
**Files Checked**: 5 changed files
**Violations**: 0 errors, 0 warnings

All changed files pass linting checks.
```

### Failure Report (--strict or errors)

```markdown
## SwiftLint Report

**Status**: FAILED
**Blocking Issues**: 2 errors

### Critical Violations

#### WorkoutUseCase.swift:67 - error
```swift
let result = data as! [String: Any]  // Force cast can crash
```
**Rule**: force_cast
**Fix**: Use optional casting with `as?` and handle nil case

#### ProfileView.swift:123 - error
```swift
fatalError("Not implemented")  // Fatal error in production code
```
**Rule**: fatal_error_message
**Fix**: Implement proper error handling or remove placeholder

---

Fix errors before proceeding. Warnings can be addressed later.
```

## Integration with Session Workflow

### Pre-Commit Gate

Add to `vitalarc-end-workstation` Phase 2:

```javascript
TaskCreate({
  subject: "Run lint validation",
  description: `Run lint-validator on changed files:
    1. Identify changed Swift files
    2. Run SwiftLint
    3. Report: errors (blocking), warnings (advisory)
    If errors found, report and block commit.`,
  activeForm: "Running lint validation"
})
```

### CI Integration

The lint-validator output can be used in CI:
- Exit code 0: No errors
- Exit code 1: Errors found (blocks merge)
- Warnings are reported but don't block

## Error Handling

### SwiftLint Not Installed

```markdown
## Lint Validation Skipped

SwiftLint is not installed. Install with:
```bash
brew install swiftlint
```

Then re-run `/lint-validator`.
```

### No .swiftlint.yml

If no configuration file exists:

```markdown
## Lint Validation

**Note**: No `.swiftlint.yml` found. Using default SwiftLint rules.

Consider creating a `.swiftlint.yml` configuration for project-specific rules.
```

## VitalArc SwiftLint Configuration

Recommended `.swiftlint.yml` rules for VitalArc:

```yaml
disabled_rules:
  - trailing_comma  # Allow trailing commas for cleaner diffs
  - todo  # Allow TODOs during development

opt_in_rules:
  - empty_count
  - force_unwrapping
  - implicitly_unwrapped_optional

line_length:
  warning: 120
  error: 150
  ignores_comments: true

type_body_length:
  warning: 300
  error: 500

file_length:
  warning: 500
  error: 1000

excluded:
  - Pods
  - DerivedData
  - .build
```
