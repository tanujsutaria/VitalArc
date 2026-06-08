---
name: config-validator
description: Check entitlements and build settings. Reports configuration status and missing requirements. Read-only, works on both platforms.
context: fork
agent: Explore
allowed-tools: Read, Glob, Grep, Bash
---

# Config Validator

Validates project configuration including entitlements and build settings.

**Execution**: Runs in forked context with Explore agent for read-only analysis.

**IMPORTANT**: When invoked without arguments, execute immediately with default settings. Never ask for clarification - use defaults and produce results.

## Default Behavior (No Arguments)

When invoked without arguments:
- **Scope**: Check all configurations (entitlements, build settings)
- **Output**: Summary report (not verbose)
- **Verbosity**: Show status table only; use `--verbose` for file locations and exact values

Execute the full configuration check immediately. Do not ask for clarification.

## What It Checks

### 1. HealthKit Entitlements

| Check | File | Expected |
|-------|------|----------|
| HealthKit capability | `*.entitlements` | `com.apple.developer.healthkit` = true |
| Health records | `*.entitlements` | `com.apple.developer.healthkit.access` |

### 2. Build Settings

| Setting | Expected |
|---------|----------|
| iOS Deployment Target | 17.0+ |
| Swift Version | 5.0+ |
| Code Signing | Valid team ID |

## Implementation

### Check HealthKit Entitlements

```bash
echo "=== HealthKit Entitlements ==="

ENTITLEMENTS_FILE=$(find . -name "*.entitlements" | head -1)

if [ -z "$ENTITLEMENTS_FILE" ]; then
    echo "No entitlements file found"
else
    if grep -q "com.apple.developer.healthkit" "$ENTITLEMENTS_FILE"; then
        echo "HealthKit capability enabled"
    else
        echo "HealthKit capability not enabled"
    fi
fi
```

### Check Build Settings

```bash
echo "=== Build Settings ==="

# Check project.pbxproj for deployment target
DEPLOYMENT_TARGET=$(grep -o 'IPHONEOS_DEPLOYMENT_TARGET = [0-9.]*' VitalArc.xcodeproj/project.pbxproj | head -1 | cut -d'=' -f2 | tr -d ' ')

if [ -n "$DEPLOYMENT_TARGET" ]; then
    echo "iOS Deployment Target: $DEPLOYMENT_TARGET"
    if [ "$(echo "$DEPLOYMENT_TARGET >= 17.0" | bc)" -eq 1 ]; then
        echo "Deployment target is iOS 17+"
    else
        echo "Deployment target below iOS 17"
    fi
fi

# Check Swift version
SWIFT_VERSION=$(grep -o 'SWIFT_VERSION = [0-9.]*' VitalArc.xcodeproj/project.pbxproj | head -1 | cut -d'=' -f2 | tr -d ' ')
echo "Swift Version: ${SWIFT_VERSION:-5.0}"
```

## Output Format

### All Valid

```markdown
## Configuration Validation

### Entitlements
| Capability | Status |
|------------|--------|
| HealthKit | Enabled |
| Health Records | Enabled |

### Build Settings
| Setting | Value | Status |
|---------|-------|--------|
| iOS Target | 17.0 | OK |
| Swift Version | 5.0 | OK |
| Team ID | ABC123 | OK |

### Verdict: ALL CONFIGURATIONS VALID
```

### Missing Configuration

```markdown
## Configuration Validation

### Entitlements
| Capability | Status |
|------------|--------|
| HealthKit | Not enabled |

### Build Settings
| Setting | Value | Status |
|---------|-------|--------|
| iOS Target | 16.0 | Below 17.0 |

### Verdict: CONFIGURATION ISSUES FOUND

### Required Actions
1. **HealthKit**: Add HealthKit capability in Xcode project settings
2. **iOS Target**: Update deployment target to iOS 17.0+
```

## Verbose Mode

With `--verbose`, show file locations and exact values:

```markdown
### Entitlements Details
- **File**: `VitalArc/VitalArc.entitlements`
- **HealthKit**: Present
- **Health Records Access**: Missing

### Build Settings Details
- **File**: `VitalArc.xcodeproj/project.pbxproj`
- **IPHONEOS_DEPLOYMENT_TARGET**: 17.0
- **SWIFT_VERSION**: 5.0
```

## Error Handling

### Files Not Found

```markdown
## Configuration Check Incomplete

Could not find:
- *.entitlements (entitlements check skipped)

Available checks completed. Some validations skipped.
```

### Parse Errors

```markdown
## Parse Warning

Could not parse project.pbxproj for build settings.
Manual verification recommended.
```
