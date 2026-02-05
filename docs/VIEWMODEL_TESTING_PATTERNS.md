# ViewModel Testing Patterns

This guide documents the testing patterns used for VitalArc ViewModels. Follow these patterns when writing new ViewModel tests.

## Table of Contents

- [Overview](#overview)
- [Test Class Structure](#test-class-structure)
- [Mock Implementation Patterns](#mock-implementation-patterns)
- [Common Test Categories](#common-test-categories)
- [Async Testing](#async-testing)
- [Examples](#examples)

---

## Overview

VitalArc ViewModels follow the MVVM pattern with:
- `@Observable` for state management
- `@MainActor` for thread safety
- Dependency injection via initializer
- Protocol-based dependencies for testability

Tests mirror this structure with:
- `@MainActor` test classes
- Protocol-conforming mocks
- Arrange-Act-Assert (AAA) pattern

---

## Test Class Structure

### Basic Template

```swift
import XCTest
@testable import VitalArc

@MainActor
final class MyViewModelTests: XCTestCase {

    // MARK: - Properties
    var mockRepository: MockMyRepository!
    var mockUseCase: MockMyUseCase!
    var viewModel: MyViewModel!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        mockRepository = MockMyRepository()
        mockUseCase = MockMyUseCase()
        viewModel = MyViewModel(
            repository: mockRepository,
            useCase: mockUseCase
        )
    }

    override func tearDown() {
        mockRepository = nil
        mockUseCase = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func createSampleData() -> MyModel {
        // Factory method for test data
    }

    // MARK: - Tests

    func testInitialState() {
        // Verify initial property values
    }
}
```

### Key Points

| Aspect | Pattern |
|--------|---------|
| Thread safety | Always use `@MainActor` on test class |
| Lifecycle | Initialize in `setUp()`, nil out in `tearDown()` |
| Dependencies | Use protocol mocks, not real implementations |
| Naming | `test<Method><Condition><ExpectedResult>()` |

---

## Mock Implementation Patterns

### Standard Mock Structure

```swift
class MockMyUseCase: MyUseCaseProtocol {
    // MARK: - Mock Data
    var mockResult: MyResult?
    var mockResults: [MyResult] = []

    // MARK: - Call Tracking
    var executeCallCount = 0
    var lastParameter: String?

    // MARK: - Error Simulation
    var shouldThrowOnExecute = false
    var errorToThrow: Error?

    // MARK: - Delay Simulation
    var executionDelay: UInt64 = 0  // nanoseconds

    // MARK: - Protocol Implementation
    func execute(param: String) async throws -> MyResult {
        executeCallCount += 1
        lastParameter = param

        if executionDelay > 0 {
            try await Task.sleep(nanoseconds: executionDelay)
        }

        if shouldThrowOnExecute {
            throw errorToThrow ?? MockError.failed
        }

        guard let result = mockResult else {
            throw MockError.noData
        }
        return result
    }

    // MARK: - Helpers
    func reset() {
        mockResult = nil
        mockResults = []
        executeCallCount = 0
        lastParameter = nil
        shouldThrowOnExecute = false
        errorToThrow = nil
        executionDelay = 0
    }

    static func createSampleResult() -> MyResult {
        // Factory method
    }
}
```

### Mock Capabilities Checklist

- [ ] **Mock data** - Properties to set expected return values
- [ ] **Call tracking** - Count calls and capture parameters
- [ ] **Error simulation** - `shouldThrowOn*` flags with optional custom error
- [ ] **Delay simulation** - For testing loading states and debouncing
- [ ] **Reset method** - Clean state between tests
- [ ] **Factory methods** - Static helpers for sample data

---

## Common Test Categories

### 1. Initial State Tests

Verify ViewModel properties have correct defaults.

```swift
func testInitialState() {
    XCTAssertNil(viewModel.profile)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertNil(viewModel.errorMessage)
    XCTAssertTrue(viewModel.results.isEmpty)
}
```

### 2. Loading State Tests

Verify loading indicators work correctly.

```swift
func testLoadSetsLoading() async {
    mockRepository.savedData = createSampleData()

    await viewModel.load()

    // After completion, loading should be false
    XCTAssertFalse(viewModel.isLoading)
}
```

### 3. Success Path Tests

Verify correct behavior with valid data.

```swift
func testLoadSuccess() async {
    let sampleData = createSampleData()
    mockRepository.savedData = sampleData

    await viewModel.load()

    XCTAssertNotNil(viewModel.data)
    XCTAssertEqual(viewModel.data?.name, "Expected Name")
    XCTAssertFalse(viewModel.isLoading)
}
```

### 4. Error Handling Tests

Verify graceful error handling.

```swift
func testLoadHandlesError() async {
    mockRepository.shouldThrowOnLoad = true

    await viewModel.load()

    XCTAssertNotNil(viewModel.errorMessage)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertNil(viewModel.data)
}
```

### 5. Validation Tests

Verify input validation logic.

```swift
func testCanSaveWithValidData() {
    viewModel.editName = "Valid Name"
    viewModel.editValue = 100

    XCTAssertTrue(viewModel.canSave)
}

func testCanSaveWithEmptyName() {
    viewModel.editName = ""
    viewModel.editValue = 100

    XCTAssertFalse(viewModel.canSave)
}
```

### 6. Edit Mode Tests

Verify edit/cancel workflows.

```swift
func testStartEditingPopulatesFields() {
    viewModel.data = createSampleData()

    viewModel.startEditing()

    XCTAssertTrue(viewModel.isEditMode)
    XCTAssertEqual(viewModel.editName, "Sample Name")
}

func testCancelEditingClearsError() {
    viewModel.isEditMode = true
    viewModel.errorMessage = "Some error"

    viewModel.cancelEditing()

    XCTAssertFalse(viewModel.isEditMode)
    XCTAssertNil(viewModel.errorMessage)
}
```

### 7. Unit Conversion Tests

For ViewModels that handle unit conversions.

```swift
func testDisplayWeightFormatsCorrectly() {
    viewModel.profile = createProfile(weight: 75.0)  // kg

    let display = viewModel.displayWeight

    XCTAssertTrue(display.contains("165"))  // lbs
    XCTAssertTrue(display.contains("lbs"))
}
```

---

## Async Testing

### Waiting for Async Operations

```swift
func testAsyncOperation() async throws {
    mockUseCase.mockResults = createSampleResults()

    await viewModel.performOperation()

    XCTAssertEqual(viewModel.results.count, 5)
}
```

### Testing Debounced Operations

```swift
func testSearchDebounces() async throws {
    mockUseCase.mockResults = createSampleResults()
    viewModel.searchQuery = "test"

    viewModel.search()

    // Check immediately - should not have executed
    try await Task.sleep(for: .milliseconds(100))
    XCTAssertEqual(mockUseCase.executeCallCount, 0)

    // Wait for debounce (500ms) to complete
    try await Task.sleep(for: .milliseconds(500))
    XCTAssertEqual(mockUseCase.executeCallCount, 1)
}
```

### Testing Task Cancellation

```swift
func testSearchCancelsPreviousTask() async throws {
    mockUseCase.mockResults = createSampleResults()

    // Start first search
    viewModel.searchQuery = "apple"
    viewModel.search()

    // Start second search before first completes
    try await Task.sleep(for: .milliseconds(100))
    viewModel.searchQuery = "banana"
    viewModel.search()

    // Wait for completion
    try await Task.sleep(for: .milliseconds(700))

    // Only second search should complete
    XCTAssertEqual(mockUseCase.lastSearchQuery, "banana")
}
```

### Testing Loading State Transitions

For operations that fire-and-forget with Task:

```swift
func testBarcodeSearchSetsLoading() async throws {
    mockUseCase.mockBarcodeResult = createSampleFood()

    viewModel.searchByBarcode("123456")

    // After async completion
    try await Task.sleep(for: .milliseconds(100))
    XCTAssertFalse(viewModel.isLoading)
}
```

---

## Examples

### Example 1: ProfileViewModel Test Suite

```swift
@MainActor
final class ProfileViewModelTests: XCTestCase {
    var userRepository: MockUserRepository!
    var healthRepository: MockHealthRepository!
    var viewModel: ProfileViewModel!

    override func setUp() {
        super.setUp()
        userRepository = MockUserRepository()
        healthRepository = MockHealthRepository()
        viewModel = ProfileViewModel(
            userRepository: userRepository,
            healthRepository: healthRepository
        )
    }

    // Initial state
    func testInitialState() {
        XCTAssertNil(viewModel.profile)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    // Load success
    func testLoadProfileSuccess() async {
        userRepository.savedProfile = createSampleProfile()
        healthRepository.mockAuthorizationSuccess = true

        await viewModel.loadProfile()

        XCTAssertNotNil(viewModel.profile)
        XCTAssertFalse(viewModel.isLoading)
    }

    // Save with unit conversion
    func testSaveConvertsUnitsToMetric() async {
        viewModel.profile = createSampleProfile()
        viewModel.editHeightFeet = 6
        viewModel.editHeightInches = 0  // 182.88 cm
        viewModel.editWeightLbs = 220.0  // 99.79 kg

        await viewModel.saveProfile()

        XCTAssertEqual(viewModel.profile?.height ?? 0, 182.88, accuracy: 0.1)
        XCTAssertEqual(viewModel.profile?.weight ?? 0, 99.79, accuracy: 0.1)
    }

    // Helper
    private func createSampleProfile() -> UserProfile {
        UserProfile(
            name: "Test User",
            birthDate: Date(),
            biologicalSex: .male,
            height: 180.0,
            weight: 75.0,
            activityLevel: .moderate,
            weightGoal: .maintain
        )
    }
}
```

### Example 2: FoodSearchViewModel with Debouncing

```swift
@MainActor
final class FoodSearchViewModelTests: XCTestCase {
    var multiSourceUseCase: MockSearchMultiSourceFoodUseCase!
    var viewModel: FoodSearchViewModel!

    override func setUp() {
        super.setUp()
        multiSourceUseCase = MockSearchMultiSourceFoodUseCase()
        viewModel = FoodSearchViewModel(
            searchFoodUseCase: MockSearchFoodUseCase(),
            multiSourceUseCase: multiSourceUseCase
        )
    }

    // Empty query clears results
    func testSearchWithEmptyQueryClearsResults() async throws {
        viewModel.searchResults = MockSearchMultiSourceFoodUseCase.createSampleResults()
        viewModel.searchQuery = ""

        viewModel.search()

        try await Task.sleep(for: .milliseconds(50))
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }

    // Debounce behavior
    func testSearchDebounces500ms() async throws {
        multiSourceUseCase.mockResults = MockSearchMultiSourceFoodUseCase.createSampleResults()
        viewModel.searchQuery = "test"

        viewModel.search()

        try await Task.sleep(for: .milliseconds(100))
        XCTAssertEqual(multiSourceUseCase.executeCallCount, 0)

        try await Task.sleep(for: .milliseconds(500))
        XCTAssertEqual(multiSourceUseCase.executeCallCount, 1)
    }

    // Rapid searches cancel previous
    func testMultipleSearchesOnlyLastExecutes() async throws {
        multiSourceUseCase.mockResults = MockSearchMultiSourceFoodUseCase.createSampleResults()

        for char in ["a", "ap", "app", "apple"] {
            viewModel.searchQuery = char
            viewModel.search()
            try await Task.sleep(for: .milliseconds(100))
        }

        try await Task.sleep(for: .milliseconds(700))

        XCTAssertEqual(multiSourceUseCase.lastSearchQuery, "apple")
    }
}
```

---

## File Organization

```
VitalArcTests/
├── Mocks/
│   ├── MockUserRepository.swift
│   ├── MockHealthRepository.swift
│   ├── MockSearchFoodUseCase.swift
│   └── ... (one per protocol)
├── ViewModelTests/
│   ├── ProfileViewModelTests.swift
│   ├── FoodSearchViewModelTests.swift
│   └── ... (one per ViewModel)
└── APITests/
    └── ... (API client tests)
```

---

## Quick Reference

| Pattern | When to Use |
|---------|-------------|
| `XCTAssertEqual(a, b, accuracy:)` | Floating point comparisons |
| `try await Task.sleep(for:)` | Wait for async/debounce |
| `mockUseCase.executeCallCount` | Verify method was called |
| `mockUseCase.lastParameter` | Verify correct argument passed |
| `mockUseCase.shouldThrowOnExecute = true` | Simulate errors |
| `XCTAssertTrue(result.contains("text"))` | Partial string matching |

---

## Checklist for New ViewModel Tests

- [ ] Test class marked `@MainActor`
- [ ] All dependencies mocked via protocols
- [ ] `setUp()` creates fresh instances
- [ ] `tearDown()` nils out all properties
- [ ] Initial state tests included
- [ ] Success path tests included
- [ ] Error handling tests included
- [ ] Validation tests (if applicable)
- [ ] Edit mode tests (if applicable)
- [ ] Async operations use `async throws`
- [ ] Debounced operations tested with proper timing
- [ ] Test names follow `test<Method><Condition><Result>` pattern
