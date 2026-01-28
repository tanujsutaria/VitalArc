# VitalArc Setup Guide

Getting started with VitalArc development.

---

## Prerequisites

- macOS 14+ (Sonoma)
- Xcode 15.2+
- Apple Developer account (for HealthKit testing)
- iOS 17+ device (HealthKit doesn't work in simulator)

---

## Quick Start

```bash
# Clone
git clone https://github.com/your-org/VitalArc.git
cd VitalArc

# Open in Xcode
open VitalArc.xcodeproj

# Build (Cmd+B)
# Run on simulator for UI development
# Run on device for HealthKit testing
```

---

## API Keys

Food search requires API keys. Without them, nutrition features will fail or be rate-limited.

### Nutritionix (Primary)
1. Sign up at https://developer.nutritionix.com
2. Get App ID and App Key
3. Edit `VitalArc/Infrastructure/Networking/NutritionixAPI.swift`:
```swift
private let appId = "YOUR_APP_ID"      // Replace
private let appKey = "YOUR_APP_KEY"    // Replace
```

### USDA FoodData Central (Fallback)
1. Get free key at https://fdc.nal.usda.gov/api-key-signup.html
2. Edit `VitalArc/Infrastructure/Networking/USDAFoodAPI.swift`:
```swift
private let apiKey = "YOUR_USDA_KEY"   // Replace DEMO_KEY
```

### OpenFoodFacts
No key required (public API).

---

## HealthKit Setup

HealthKit requires device testing with proper entitlements.

### 1. Enable HealthKit Capability
In Xcode:
- Select VitalArc target
- Signing & Capabilities tab
- Add "HealthKit" capability
- Check "Clinical Health Records" if needed

### 2. Configure Entitlements
The `VitalArc.entitlements` file should contain:
```xml
<key>com.apple.developer.healthkit</key>
<true/>
<key>com.apple.developer.healthkit.access</key>
<array/>
```

### 3. Test on Device
1. Connect iOS device
2. Select device in Xcode scheme
3. Build and run
4. Grant HealthKit permissions when prompted

---

## Project Structure

```
VitalArc/
├── Domain/           # Business logic (no dependencies)
├── Data/             # SwiftData persistence
├── Infrastructure/   # External services (HealthKit, APIs)
└── Presentation/     # SwiftUI views and ViewModels
```

See [ARCHITECTURE.md](./ARCHITECTURE.md) for details.

---

## Build Commands

```bash
# Build
xcodebuild -scheme VitalArc \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build

# Test
xcodebuild -scheme VitalArc \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test

# Quick check
xcodebuild -scheme VitalArc \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build 2>&1 | grep -E "(error:|BUILD)"
```

---

## Development Workflow

1. Run `/vitalarc-start` to initialize session
2. Create feature branch: `dev/<focus>-<session>.<minor>-YYYY-MM-DD`
3. Make changes
4. Run `/vitalarc-end` to finalize and create PR
5. PR triggers CI (build + tests)
6. Merge to main

---

## Common Issues

### "HealthKit not available"
- HealthKit only works on physical iOS devices
- Ensure entitlements are configured
- Check device has Health app

### "Food search returns no results"
- API keys not configured (see API Keys section)
- DEMO_KEY is rate-limited to ~30 requests/hour
- Check network connectivity

### "Build fails with signing error"
- Select your team in Signing & Capabilities
- Ensure Apple Developer account is connected
- Try "Automatically manage signing"

### "SwiftData migration error"
- Delete app from simulator/device
- Clean build folder (Cmd+Shift+K)
- Rebuild
