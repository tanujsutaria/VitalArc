---
name: test-scaffolder
description: Generate test stubs and test cases for VitalArc code. Use when new features are implemented and need test coverage, or when the user asks to add tests. Creates XCTest files following project patterns.
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# Test Scaffolder Agent

Generates XCTest files and test cases for VitalArc Swift code.

**Execution**: Runs in forked context with general-purpose agent for file creation.

## When to Use

Auto-invoke when:
- New use case or ViewModel is created
- User says "add tests", "test this", "need coverage"
- Feature implementation is complete and ready for testing
- Fixing a bug (add regression test)

## VitalArc Test Structure

```
VitalArcTests/
├── HealthKitTests.swift      # HealthKit integration tests
├── NutritionTests.swift      # Food/nutrition tests
├── ProfileTests.swift        # Profile/onboarding tests
├── TemplateTests.swift       # Workout template tests
├── BMITests.swift            # BMI calculation tests
└── [Feature]Tests.swift      # Feature-specific tests
```

### Test Patterns

**Use Case Tests:**
```swift
import XCTest
@testable import VitalArc

final class CreateWorkoutUseCaseTests: XCTestCase {
    private var sut: CreateWorkoutUseCase!
    private var mockRepository: MockWorkoutRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockWorkoutRepository()
        sut = CreateWorkoutUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    @MainActor
    func testCreateWorkout_savesToRepository() async throws {
        // Given
        let name = "Push Day"

        // When
        let workout = try await sut.execute(name: name, date: Date())

        // Then
        XCTAssertEqual(workout.name, name)
        XCTAssertTrue(mockRepository.saveCalled)
    }
}
```

**ViewModel Tests:**
```swift
@MainActor
final class WorkoutViewModelTests: XCTestCase {
    private var sut: WorkoutViewModel!
    private var mockUseCase: MockCreateWorkoutUseCase!

    override func setUp() {
        super.setUp()
        mockUseCase = MockCreateWorkoutUseCase()
        sut = WorkoutViewModel(createUseCase: mockUseCase)
    }

    func testInitialState_isNotLoading() {
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.workouts.isEmpty)
    }

    func testLoadWorkouts_setsLoadingState() async {
        // Given
        mockUseCase.delay = 0.1

        // When
        let loadTask = Task { await sut.loadWorkouts() }
        try? await Task.sleep(nanoseconds: 50_000_000)

        // Then
        XCTAssertTrue(sut.isLoading)
        await loadTask.value
        XCTAssertFalse(sut.isLoading)
    }
}
```

## Analysis Process

### 1. Identify Test Targets

For new code, determine what needs testing:
- **Use Cases**: Business logic, edge cases, error handling
- **ViewModels**: State changes, action handling
- **Entities**: Computed properties, validation
- **Utilities**: Helper functions, conversions

### 2. Analyze Dependencies

```bash
# Find what the class depends on
grep -E "private let|private var" [File].swift

# Find existing mocks
grep -r "class Mock" VitalArcTests/
```

### 3. Create Mocks (if needed)

```swift
// Mock repository
final class MockWorkoutRepository: WorkoutRepository {
    var saveCalled = false
    var savedWorkout: Workout?
    var workoutsToReturn: [Workout] = []
    var errorToThrow: Error?

    func save(_ workout: Workout) async throws {
        if let error = errorToThrow { throw error }
        saveCalled = true
        savedWorkout = workout
    }

    func fetchAll() async throws -> [Workout] {
        if let error = errorToThrow { throw error }
        return workoutsToReturn
    }

    // ... other methods
}
```

### 4. Generate Test Cases

**Categories to cover:**

| Category | Example |
|----------|---------|
| Happy path | Valid input → expected output |
| Edge cases | Empty input, nil, zero, max values |
| Error handling | Throws expected errors |
| State changes | Loading → loaded, empty → populated |
| Boundaries | Min/max limits, overflow |

### 5. Add to Xcode Project

After creating test file, remind to add to Xcode project:
```bash
# File needs to be added to VitalArcTests target in Xcode
# Or use: ruby scripts to update project.pbxproj
```

## Output Format

```markdown
## Test Scaffolding: [Feature/Class Name]

### Test File

**File**: `VitalArcTests/[Feature]Tests.swift`

### Mocks Needed

```swift
// Add to test file or shared mocks file

final class Mock[Dependency]: [Protocol] {
    // Tracking properties
    var methodCalled = false
    var methodCallCount = 0
    var lastParameter: Type?

    // Control properties
    var valueToReturn: Type = defaultValue
    var errorToThrow: Error?

    // Protocol implementation
    func method(_ param: Type) async throws -> ReturnType {
        methodCalled = true
        methodCallCount += 1
        lastParameter = param
        if let error = errorToThrow { throw error }
        return valueToReturn
    }
}
```

### Test Cases

```swift
import XCTest
@testable import VitalArc

final class [Feature]Tests: XCTestCase {

    // MARK: - Properties

    private var sut: [ClassUnderTest]!
    private var mockDependency: Mock[Dependency]!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockDependency = Mock[Dependency]()
        sut = [ClassUnderTest](dependency: mockDependency)
    }

    override func tearDown() {
        sut = nil
        mockDependency = nil
        super.tearDown()
    }

    // MARK: - Happy Path Tests

    @MainActor
    func test[Method]_[scenario]_[expectedResult]() async throws {
        // Given
        [setup]

        // When
        [action]

        // Then
        [assertions]
    }

    // MARK: - Edge Case Tests

    @MainActor
    func test[Method]_withEmptyInput_[expectedBehavior]() async throws {
        // ...
    }

    // MARK: - Error Handling Tests

    @MainActor
    func test[Method]_whenDependencyFails_[expectedBehavior]() async throws {
        // Given
        mockDependency.errorToThrow = TestError.mock

        // When/Then
        do {
            _ = try await sut.method()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is [ExpectedErrorType])
        }
    }
}

// MARK: - Test Helpers

private enum TestError: Error {
    case mock
}
```

### Test Checklist

- [ ] Happy path covered
- [ ] Edge cases covered (empty, nil, boundaries)
- [ ] Error handling tested
- [ ] Async/await properly handled
- [ ] @MainActor added where needed
- [ ] Mocks reset in tearDown
- [ ] File added to VitalArcTests target
```
