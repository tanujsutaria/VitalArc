---
name: config-validator
description: Check API keys, entitlements, and build settings. Reports configuration status and missing requirements. Read-only, works on both platforms.
context: fork
agent: Explore
allowed-tools: Read, Glob, Grep, Bash
argument-hint: [--verbose]
---

# Config Validator

Validates project configuration including API keys, entitlements, and build settings.

**Execution**: Runs in forked context with Explore agent for read-only analysis.

## What It Checks

### 1. API Keys

| Service | File | Key Pattern |
|---------|------|-------------|
| Nutritionix | `NutritionixAPI.swift` | `YOUR_APP_ID`, `YOUR_APP_KEY` |
| USDA FoodData | `USDAFoodAPI.swift` | `DEMO_KEY` |
| OpenFoodFacts | `OpenFoodFactsAPI.swift` | No key required |

### 2. HealthKit Entitlements

| Check | File | Expected |
|-------|------|----------|
| HealthKit capability | `*.entitlements` | `com.apple.developer.healthkit` = true |
| Health records | `*.entitlements` | `com.apple.developer.healthkit.access` |

### 3. Build Settings

| Setting | Expected |
|---------|----------|
| iOS Deployment Target | 17.0+ |
| Swift Version | 5.0+ |
| Code Signing | Valid team ID |

## Implementation

### Check API Keys

```bash
echo "=== API Key Configuration ==="

# Nutritionix
NUTRITIONIX_APP_ID=$(grep -o 'appId.*=.*"[^"]*"' VitalArc/Infrastructure/Networking/NutritionixAPI.swift | head -1)
NUTRITIONIX_APP_KEY=$(grep -o 'appKey.*=.*"[^"]*"' VitalArc/Infrastructure/Networking/NutritionixAPI.swift | head -1)

if echo "$NUTRITIONIX_APP_ID" | grep -q "YOUR_APP_ID"; then
    echo "Nutritionix: APP_ID not configured"
else
    echo "Nutritionix: APP_ID configured"
fi

# USDA
USDA_KEY=$(grep -o 'apiKey.*=.*"[^"]*"' VitalArc/Infrastructure/Networking/USDAFoodAPI.swift | head -1)

if echo "$USDA_KEY" | grep -q "DEMO_KEY"; then
    echo "USDA: Using DEMO_KEY (rate limited)"
else
    echo "USDA: API key configured"
fi

# OpenFoodFacts
echo "OpenFoodFacts: No key required (public API)"
```

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

### API Keys
| Service | Status | Notes |
|---------|--------|-------|
| Nutritionix | Configured | Ready for use |
| USDA FoodData | Configured | Production key |
| OpenFoodFacts | N/A | Public API |

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

### API Keys
| Service | Status | Notes |
|---------|--------|-------|
| Nutritionix | Missing | Set YOUR_APP_ID and YOUR_APP_KEY |
| USDA FoodData | Demo Key | Rate limited, get key from fdc.nal.usda.gov |
| OpenFoodFacts | N/A | Public API |

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
1. **Nutritionix API**: Register at nutritionix.com and add keys to NutritionixAPI.swift
2. **USDA API**: Get production key from fdc.nal.usda.gov
3. **HealthKit**: Add HealthKit capability in Xcode project settings
4. **iOS Target**: Update deployment target to iOS 17.0+
```

## Verbose Mode

With `--verbose`, show file locations and exact values:

```markdown
### API Key Details

#### Nutritionix
- **File**: `VitalArc/Infrastructure/Networking/NutritionixAPI.swift`
- **Line 15**: `private let appId = "YOUR_APP_ID"`
- **Line 16**: `private let appKey = "YOUR_APP_KEY"`
- **Status**: Placeholder values detected

#### USDA
- **File**: `VitalArc/Infrastructure/Networking/USDAFoodAPI.swift`
- **Line 12**: `private let apiKey = "DEMO_KEY"`
- **Status**: Using demo key

### Entitlements Details
- **File**: `VitalArc/VitalArc.entitlements`
- **HealthKit**: Present
- **Health Records Access**: Missing
```

## Error Handling

### Files Not Found

```markdown
## Configuration Check Incomplete

Could not find:
- NutritionixAPI.swift (API key check skipped)
- *.entitlements (entitlements check skipped)

Available checks completed. Some validations skipped.
```

### Parse Errors

```markdown
## Parse Warning

Could not parse project.pbxproj for build settings.
Manual verification recommended.
```
