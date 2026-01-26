# VitalArc Session 7 Execution Plan

**Date**: January 26, 2026
**Goal**: Usable MVP + User Testing Infrastructure
**Status**: Partially Complete - Documentation Ready

---

## Session 7 Progress

### ✅ Completed This Session

| Phase | Task | Status |
|-------|------|--------|
| Phase 1 | Food Search | ✅ Verified working (OpenFoodFacts fallback) |
| Phase 2 | Analytics Export | ✅ Implemented (PDF + CSV) |
| Phase 3 | Template Picker | ✅ Verified (~76 exercises available) |
| Phase 4 | Feedback Mechanism | ✅ Implemented (Settings → Send Feedback) |
| Phase 7 | Test Plan | ✅ Created TEST_PLAN.md |
| Phase 7 | Success Metrics | ✅ Created SUCCESS_METRICS.md |

### ❌ Remaining for Next Session

| Phase | Task | Blocker |
|-------|------|---------|
| Phase 5 | Crash Reporting | Needs Firebase/Sentry SDK setup |
| Phase 6 | TestFlight | Needs Apple Developer account |

---

## Current State Assessment

### Completed (Sessions 1-7)
- [x] Unit consistency (American units)
- [x] Design system (~90% adoption)
- [x] Settings/About features
- [x] Error handling patterns
- [x] Recovery score algorithm
- [x] Analytics export (PDF/CSV)
- [x] In-app feedback mechanism
- [x] Test plan documentation
- [x] Success metrics definition

### Ready for Beta Testing
| Feature | Status | Notes |
|---------|--------|-------|
| Food search | ✅ Working | OpenFoodFacts as primary, USDA fallback |
| Analytics export | ✅ Working | PDF progress reports, CSV volume data |
| Template picker | ✅ Working | 76 exercises across 7 body parts |
| Feedback collection | ✅ Working | Email-based with device info |
| Test documentation | ✅ Complete | TEST_PLAN.md, SUCCESS_METRICS.md |

### Not Yet Configured
| Feature | Required Action | Owner |
|---------|-----------------|-------|
| Crash reporting | Add Firebase Crashlytics SDK | Developer |
| TestFlight | Configure App Store Connect | Developer + Apple account |
| Analytics tracking | Add Mixpanel/Amplitude | Post-beta |

---

## Next Session Tasks

### Phase 5: Crash Reporting Setup

**Recommended**: Firebase Crashlytics (free, comprehensive)

**Steps**:
1. Create Firebase project at console.firebase.google.com
2. Add iOS app with bundle ID `com.vitalarc.app`
3. Download `GoogleService-Info.plist`
4. Add Firebase SDK via Swift Package Manager:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
5. Add to VitalArcApp.swift:
   ```swift
   import FirebaseCore
   import FirebaseCrashlytics

   @main
   struct VitalArcApp: App {
       init() {
           FirebaseApp.configure()
       }
   }
   ```
6. Test with intentional crash

**Files to modify**:
- `VitalArc/VitalArcApp.swift`
- `VitalArc.xcodeproj` (add SPM dependency)
- Add `GoogleService-Info.plist` to project

---

### Phase 6: TestFlight Preparation

**Prerequisites**:
- Apple Developer Program membership ($99/year)
- App Store Connect access

**Steps**:
1. Verify bundle identifier: `com.vitalarc.app`
2. Create App Store Connect app record
3. Configure app metadata:
   - App name: VitalArc
   - Primary category: Health & Fitness
   - Subtitle: Fitness & Nutrition Tracker
4. Create provisioning profile (App Store Distribution)
5. Archive build:
   ```bash
   xcodebuild -scheme VitalArc \
     -destination generic/platform=iOS \
     archive -archivePath ./build/VitalArc.xcarchive
   ```
6. Export for App Store:
   ```bash
   xcodebuild -exportArchive \
     -archivePath ./build/VitalArc.xcarchive \
     -exportPath ./build \
     -exportOptionsPlist ExportOptions.plist
   ```
7. Upload to App Store Connect
8. Add internal testers

**Files to create**:
- `ExportOptions.plist` for archive export

---

## Documentation Checklist

| Document | Status | Location |
|----------|--------|----------|
| Project Status | ✅ Updated | PROJECT_STATUS.md |
| Test Plan | ✅ Created | TEST_PLAN.md |
| Success Metrics | ✅ Created | SUCCESS_METRICS.md |
| Session 7 Plan | ✅ Updated | EXECUTION_PLAN_SESSION7.md |
| API Documentation | ❌ Not created | (post-beta priority) |
| User Guide | ❌ Not created | (post-beta priority) |

---

## Post-MVP Roadmap

### Phase A: Algorithm Completion (Post-Beta)
- [ ] TDEE estimation for nutrition goals
- [ ] Real-time workout progression suggestions
- [ ] Sleep debt calculation

### Phase B: Platform Features (v1.1)
- [ ] Push notifications (workout/meal reminders)
- [ ] Home screen widgets
- [ ] CloudKit sync

### Phase C: Advanced Features (v2.0)
- [ ] Apple Watch companion app
- [ ] AI-powered insights
- [ ] Social features (sharing, challenges)

### Phase D: Growth & Iteration (Ongoing)
- [ ] User analytics (Mixpanel/Amplitude)
- [ ] A/B testing framework
- [ ] App Store optimization
- [ ] Marketing website

---

## Quick Reference

### Build Commands
```bash
# Development build
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Quick build check
xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD SUCCEEDED|BUILD FAILED)"

# Archive for TestFlight
xcodebuild -scheme VitalArc -destination generic/platform=iOS archive -archivePath ./build/VitalArc.xcarchive
```

### Key Files
| Purpose | File |
|---------|------|
| App entry | `VitalArc/VitalArcApp.swift` |
| Dependencies | `VitalArc/Infrastructure/DependencyContainer.swift` |
| Design system | `VitalArc/Presentation/Common/DesignSystem/` |
| Feedback | `VitalArc/Presentation/Common/FeedbackView.swift` |
| Export | `VitalArc/Infrastructure/Export/` |

### API Keys Status
| API | Status | Notes |
|-----|--------|-------|
| OpenFoodFacts | ✅ No key needed | Primary food search |
| USDA | ⚠️ Demo key | Rate-limited fallback |
| Nutritionix | ❌ Placeholder | Needs configuration |

---

## Session 7 Summary

**Commits**:
1. `78500d0` - Implement analytics export and add Session 7 execution plan
2. `bbbc091` - Add in-app feedback mechanism for beta testers
3. (pending) - Documentation updates

**Key Achievements**:
- Analytics export fully functional (PDF progress reports, CSV volume data)
- In-app feedback mechanism ready for beta testers
- Comprehensive test plan with 50+ test cases
- Success metrics defined with targets

**Next Steps**:
1. Configure Firebase Crashlytics
2. Set up TestFlight distribution
3. Recruit 10-50 beta testers
4. Begin closed beta testing
