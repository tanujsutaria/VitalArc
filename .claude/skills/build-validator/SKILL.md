---
name: build-validator
description: Verify VitalArc Xcode project builds successfully. Use automatically before commits, after code changes, or when the user asks to check the build. Reports errors clearly and suggests fixes.
context: fork
agent: general-purpose
allowed-tools: Bash, Read, Grep
---

# Build Validator Agent

Verifies the VitalArc Xcode project compiles without errors.

**Execution**: Runs in forked context with Bash agent for command execution.

## When to Use

Auto-invoke when:
- About to commit changes
- After significant code modifications
- User says "build", "compile", "check build"
- After creating new Swift files
- Before ending a session

## Build Command

```bash
xcodebuild -scheme VitalArc \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build 2>&1 | grep -E "(error:|warning:|BUILD SUCCEEDED|BUILD FAILED)"
```

## Process

### 1. Run Build

Execute the build command and capture output.

### 2. Parse Results

**Success:**
```
BUILD SUCCEEDED
```

**Failure:**
```
/path/to/File.swift:42:15: error: cannot find 'foo' in scope
BUILD FAILED
```

### 3. Report Results

**On Success:**
```markdown
## Build Status: PASSING

No errors. Ready to commit.
```

**On Failure:**
```markdown
## Build Status: FAILED

### Errors (N)

| File | Line | Error |
|------|------|-------|
| FeatureView.swift | 42 | Cannot find 'foo' in scope |
| ViewModel.swift | 15 | Type 'Bar' has no member 'baz' |

### Suggested Fixes

1. **FeatureView.swift:42** - `foo` is undefined
   - Did you mean `Foo` (capitalized)?
   - Check if import is missing

2. **ViewModel.swift:15** - Member not found
   - Verify `Bar` type definition
   - Check for typos in property name
```

### 4. Handle Warnings (Optional)

If user wants warnings:
```bash
xcodebuild ... 2>&1 | grep -E "(warning:)"
```

Report significant warnings (not deprecation noise).

## Error Categories

| Category | Pattern | Common Fix |
|----------|---------|------------|
| Missing import | "cannot find X in scope" | Add `import Framework` |
| Type mismatch | "cannot convert" | Check types, add conversion |
| Missing member | "has no member" | Check spelling, add property |
| Protocol conformance | "does not conform" | Implement required methods |
| Access control | "inaccessible" | Change to public/internal |

## Quick Validation Mode

For fast feedback during development:
```bash
# Syntax check only (faster)
swift -parse VitalArc/**/*.swift 2>&1 | head -20
```

## Integration

This agent is part of the **Pre-Commit Quality Gate** swarm:
1. `build-validator` (this) - Compilation check
2. `design-system-scanner` - Design token compliance

Both should pass before committing.

## Output Format

### Passing Build

```
BUILD VALIDATED

Status: PASSING
Time: 45s
Warnings: 0
```

### Failing Build

```
BUILD FAILED

Errors: 2
Files affected: FeatureView.swift, ViewModel.swift

Error 1: FeatureView.swift:42
  Cannot find 'foo' in scope
  Suggestion: Check imports or variable name

Error 2: ViewModel.swift:15
  Type 'Bar' has no member 'baz'
  Suggestion: Verify property exists on Bar type

Run full build for details:
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```
