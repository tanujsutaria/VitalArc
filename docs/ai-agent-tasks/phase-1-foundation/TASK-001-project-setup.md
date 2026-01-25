# TASK-001: Project Setup

## Metadata
- **Phase**: 1 - Foundation
- **Priority**: P0 (Critical)
- **Estimated Hours**: 4
- **Dependencies**: None
- **Blocked By**: None

## Objective
Create the Xcode project with proper structure, configure build settings, set up dependency injection, and establish coding standards.

## Context
This is the foundational task for VitalArc. The project structure established here will be used throughout development. Getting this right ensures clean architecture and maintainability.

## Requirements

### Functional Requirements
- [ ] Create iOS app target (iOS 17.0+)
- [ ] Create watchOS app target (watchOS 10.0+)
- [ ] Create widget extension target
- [ ] Configure app capabilities (HealthKit, CloudKit, Background Modes)
- [ ] Set up project folder structure matching architecture
- [ ] Create dependency injection container
- [ ] Add logging infrastructure

### Non-Functional Requirements
- Build time < 30 seconds for incremental builds
- Support both simulator and device builds
- Enable strict concurrency checking

## Technical Specification

### Project Structure

Create this folder structure in Xcode:

```
VitalArc/
├── VitalArc/
│   ├── App/
│   │   ├── VitalArcApp.swift
│   │   ├── AppDelegate.swift
│   │   └── DependencyContainer.swift
│   ├── Core/
│   │   ├── Extensions/
│   │   ├── Utilities/
│   │   └── Constants/
│   ├── Domain/
│   │   ├── Entities/
│   │   ├── UseCases/
│   │   └── Repositories/
│   ├── Data/
│   │   ├── Models/
│   │   ├── Repositories/
│   │   ├── DataSources/
│   │   └── Mappers/
│   ├── Presentation/
│   │   ├── Common/
│   │   ├── Workout/
│   │   ├── Nutrition/
│   │   ├── Health/
│   │   └── Settings/
│   ├── Infrastructure/
│   │   ├── HealthKit/
│   │   ├── ML/
│   │   ├── Networking/
│   │   └── Notifications/
│   └── Resources/
│       ├── Assets.xcassets
│       └── Localizable.strings
├── VitalArcWatch/
├── VitalArcWidgets/
└── VitalArcTests/
```

### Files to Create

#### VitalArcApp.swift
```swift
import SwiftUI
import SwiftData

@main
struct VitalArcApp: App {
    @State private var container = DependencyContainer.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(container)
        }
        .modelContainer(container.modelContainer)
    }
}
```

#### DependencyContainer.swift
```swift
import SwiftUI
import SwiftData

@MainActor
@Observable
final class DependencyContainer {
    static let shared = DependencyContainer()

    // MARK: - Model Container
    let modelContainer: ModelContainer

    // MARK: - Infrastructure
    lazy var healthKitManager = HealthKitManager()
    lazy var networkManager = NetworkManager()
    lazy var notificationManager = NotificationManager()

    // MARK: - Repositories
    lazy var workoutRepository: WorkoutRepositoryProtocol = {
        WorkoutRepository(modelContext: modelContainer.mainContext)
    }()

    lazy var nutritionRepository: NutritionRepositoryProtocol = {
        NutritionRepository(modelContext: modelContainer.mainContext)
    }()

    lazy var healthRepository: HealthRepositoryProtocol = {
        HealthRepository(
            healthKitManager: healthKitManager,
            modelContext: modelContainer.mainContext
        )
    }()

    // MARK: - Initialization
    private init() {
        do {
            let schema = Schema([
                // Add all @Model types here
            ])

            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )

            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Use Case Factories
    func makeCalculateRecoveryUseCase() -> CalculateRecoveryUseCase {
        CalculateRecoveryUseCase(healthRepository: healthRepository)
    }

    func makeLogWorkoutSetUseCase() -> LogWorkoutSetUseCase {
        LogWorkoutSetUseCase(workoutRepository: workoutRepository)
    }

    // Add more use case factories as needed
}
```

#### Logger.swift (in Core/Utilities/)
```swift
import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.vitalarc"

    static let app = Logger(subsystem: subsystem, category: "app")
    static let health = Logger(subsystem: subsystem, category: "health")
    static let workout = Logger(subsystem: subsystem, category: "workout")
    static let nutrition = Logger(subsystem: subsystem, category: "nutrition")
    static let sync = Logger(subsystem: subsystem, category: "sync")
    static let ui = Logger(subsystem: subsystem, category: "ui")
}
```

#### AppConstants.swift (in Core/Constants/)
```swift
import Foundation

enum AppConstants {
    static let appName = "VitalArc"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    enum HealthKit {
        static let hrvBaselineDays = 60
        static let rhrBaselineDays = 60
        static let minDataPointsForRecovery = 7
    }

    enum Workout {
        static let defaultRestTimerSeconds = 90
        static let maxSetsPerExercise = 20
        static let maxExercisesPerWorkout = 30
    }

    enum Nutrition {
        static let minDaysForTDEE = 14
        static let trendWeightAlpha = 0.1
        static let maxDailyCalories = 10000
    }
}
```

### Build Settings

Configure these in the Xcode project:

1. **Deployment Target**: iOS 17.0, watchOS 10.0
2. **Swift Language Version**: Swift 5.9
3. **Strict Concurrency Checking**: Complete
4. **Build Settings**:
   - `SWIFT_STRICT_CONCURRENCY = complete`
   - `ENABLE_USER_SCRIPT_SANDBOXING = YES`

### Capabilities to Enable

In the Signing & Capabilities tab:

1. **HealthKit**
   - Clinical Health Records: NO
   - Background Delivery: YES

2. **iCloud**
   - CloudKit: YES
   - Container: iCloud.com.vitalarc.app

3. **Background Modes**
   - Background fetch: YES
   - Background processing: YES

### Info.plist Entries

```xml
<key>NSHealthShareUsageDescription</key>
<string>VitalArc reads your health data to calculate recovery scores, track strain, and provide personalized fitness insights.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>VitalArc saves your workouts and weight measurements to Apple Health to keep all your fitness data in sync.</string>

<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

## Implementation Guide

### Step 1: Create Xcode Project
1. Open Xcode → File → New → Project
2. Select "App" template for iOS
3. Product Name: "VitalArc"
4. Team: Select your team
5. Organization Identifier: com.vitalarc
6. Interface: SwiftUI
7. Language: Swift
8. Storage: SwiftData
9. Include Tests: YES

### Step 2: Add Targets
1. File → New → Target → watchOS App
2. File → New → Target → Widget Extension

### Step 3: Create Folder Structure
1. In Project Navigator, create all folders as groups
2. Move VitalArcApp.swift to App/ folder
3. Create placeholder files in each folder (can be empty Swift files)

### Step 4: Configure Capabilities
1. Select VitalArc target
2. Go to Signing & Capabilities
3. Add HealthKit, iCloud, Background Modes

### Step 5: Create Core Files
1. Create DependencyContainer.swift
2. Create Logger.swift
3. Create AppConstants.swift
4. Update VitalArcApp.swift to use container

### Step 6: Configure SwiftLint (Optional but Recommended)
1. Add SwiftLint via SPM or manually
2. Create .swiftlint.yml with project rules

## Acceptance Criteria

- [ ] Project compiles without errors or warnings
- [ ] App launches on simulator showing empty ContentView
- [ ] All folder groups exist in project navigator
- [ ] HealthKit capability is enabled
- [ ] iCloud capability is enabled with CloudKit
- [ ] Background Modes capability is enabled
- [ ] DependencyContainer initializes without crash
- [ ] Logger outputs to console correctly
- [ ] Strict concurrency checking enabled
- [ ] Watch target compiles
- [ ] Widget target compiles

## Testing Requirements

### Manual Tests
1. Build and run on iOS Simulator - should show blank screen
2. Build and run on watchOS Simulator - should show blank screen
3. Check Console for any initialization errors

### Automated Tests
Create `VitalArcTests/DependencyContainerTests.swift`:

```swift
import XCTest
@testable import VitalArc

final class DependencyContainerTests: XCTestCase {
    @MainActor
    func testContainerInitializes() {
        let container = DependencyContainer.shared
        XCTAssertNotNil(container.modelContainer)
    }

    @MainActor
    func testLoggerWorks() {
        // This should not crash
        Logger.app.info("Test log message")
    }
}
```

## References

- [Architecture Documentation](../../architecture/ARCHITECTURE.md)
- [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Apple HealthKit Setup Guide](https://developer.apple.com/documentation/healthkit/setting_up_healthkit)

## Notes for AI Agent

- Create real Xcode project files, not just Swift code
- Ensure all imports are correct
- Test that the project actually builds
- Don't add features beyond this task - just the skeleton
