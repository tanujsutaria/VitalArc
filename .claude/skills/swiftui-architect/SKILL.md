---
name: swiftui-architect
description: Design SwiftUI view hierarchies and state management for VitalArc features. Use when planning new screens, complex UI components, or navigation flows. Produces view structures following VitalArc's design system and MVVM patterns.
context: fork
agent: Plan
allowed-tools: Read, Grep, Glob
---

# SwiftUI Architect Agent

Designs SwiftUI view hierarchies, state management, and navigation for VitalArc features.

**Execution**: Runs in forked context with Plan agent for isolated analysis.

## When to Use

Auto-invoke when:
- Planning a new screen or feature UI
- User mentions "view", "screen", "UI", "SwiftUI"
- Designing navigation flows
- Creating complex component hierarchies
- Setting up ViewModels and state management

## VitalArc UI Architecture

```
VitalArc/Modules/
├── Workout/Presentation/         # Exercises, templates, logging
├── Wellness/Presentation/        # Health dashboard, metrics, sleep
└── Shared/
    ├── DesignSystem/             # Tokens and reusable components
    ├── Common/                   # Cross-feature components
    ├── User/Presentation/        # Onboarding, settings, profile
    └── Analytics/Presentation/   # Charts, insights
```

### Key Patterns

**View + ViewModel**:
```swift
// ViewModel (@Observable, @MainActor)
@MainActor
@Observable
final class FeatureViewModel {
    var items: [Item] = []
    var isLoading = false
    var error: Error?

    private let useCase: SomeUseCase

    init(useCase: SomeUseCase) {
        self.useCase = useCase
    }

    func loadItems() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await useCase.execute()
        } catch {
            self.error = error
        }
    }
}

// View
struct FeatureView: View {
    @State private var viewModel: FeatureViewModel

    init(useCase: SomeUseCase) {
        _viewModel = State(initialValue: FeatureViewModel(useCase: useCase))
    }

    var body: some View {
        // ...
    }
}
```

**Design System Usage**:
```swift
var body: some View {
    VStack(spacing: Spacing.md) {
        Text("Title")
            .font(.vitalH1)
            .foregroundStyle(Color.vitalAdaptiveTextPrimary)

        VitalCard {
            // Content
        }

        VitalButton("Action", style: .primary) {
            // Action
        }
    }
    .padding(Spacing.screenPadding)
    .background(Color.vitalAdaptiveBackground)
}
```

## Analysis Process

### 1. Understand Requirements

- What data is displayed?
- What actions can the user take?
- How does this fit into navigation?
- What states exist (loading, empty, error, content)?

### 2. Analyze Existing Patterns

```bash
# Find similar views
ls VitalArc/Modules/[Domain]/Presentation/

# Check design system components
ls VitalArc/Modules/Shared/DesignSystem/Components/

# Find ViewModels
grep -r "final class.*ViewModel" VitalArc/Modules/
```

### 3. Design View Hierarchy

Break down into:
- **Screen View** - Top-level, owns ViewModel
- **Section Views** - Logical groupings
- **Component Views** - Reusable pieces
- **Row Views** - List item templates

### 4. Design State Management

**ViewModel responsibilities:**
- Hold view state (`@Observable` properties)
- Call use cases
- Transform data for display
- Handle user actions

**View responsibilities:**
- Render UI based on ViewModel state
- Send user actions to ViewModel
- Handle navigation presentation

### 5. Apply Design System

**Always use tokens:**
| Instead of | Use |
|------------|-----|
| `Color.blue` | `Color.vitalPrimary` |
| `Color.red` | `Color.vitalDanger` |
| `.padding(16)` | `.padding(Spacing.md)` |
| `.font(.title)` | `.font(.vitalH1)` |
| Custom card | `VitalCard { }` |
| Custom button | `VitalButton()` |

## Output Format

```markdown
## UI Design: [Feature Name]

### Navigation

- **Entry point**: [Tab / Button / Link]
- **Presentation**: [Push / Sheet / FullScreenCover]
- **Back navigation**: [Standard / Custom]

### View Hierarchy

```
FeatureView (Screen)
├── FeatureViewModel
├── HeaderSection
│   ├── TitleView
│   └── ActionButtons
├── ContentSection
│   ├── List/ScrollView
│   └── ItemRowView (repeated)
├── EmptyStateView (conditional)
└── LoadingOverlay (conditional)
```

### ViewModel

**File**: `VitalArc/Modules/[Domain]/Presentation/[Feature]ViewModel.swift`

```swift
@MainActor
@Observable
final class [Feature]ViewModel {
    // State
    var items: [Item] = []
    var isLoading = false
    var selectedItem: Item?
    var showingSheet = false
    var error: Error?

    // Dependencies
    private let fetchUseCase: Fetch[Item]UseCase
    private let saveUseCase: Save[Item]UseCase

    // Actions
    func loadItems() async { }
    func selectItem(_ item: Item) { }
    func saveItem() async { }
}
```

### Views

#### [Feature]View (Screen)
**File**: `VitalArc/Modules/[Domain]/Presentation/[Feature]View.swift`
**Owns**: [Feature]ViewModel
**Shows**: [Description of content]

```swift
struct [Feature]View: View {
    @State private var viewModel: [Feature]ViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("[Title]")
                .toolbar { toolbarContent }
        }
        .task { await viewModel.loadItems() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if viewModel.items.isEmpty {
            VitalEmptyState(...)
        } else {
            itemList
        }
    }
}
```

#### [Item]RowView (Component)
**File**: `VitalArc/Modules/[Domain]/Presentation/[Item]RowView.swift`
**Purpose**: Single item in list

```swift
struct [Item]RowView: View {
    let item: [Item]
    let onTap: () -> Void

    var body: some View {
        VitalCard {
            HStack(spacing: Spacing.md) {
                // Content
            }
        }
    }
}
```

### Design System Components Used

- `VitalCard` - Item containers
- `VitalButton` - Actions
- `VitalEmptyState` - No content state
- `Color.vitalPrimary` - Accent color
- `Spacing.md/lg` - Layout spacing
- `.font(.vitalBody)` - Text styling

### State Diagram

```
[Loading] → [Empty] or [Content]
[Content] → [Detail Sheet] → [Content]
[Content] → [Edit Mode] → [Content]
[Any] → [Error Alert] → [Previous]
```
```

## Example: Notifications Settings UI

```markdown
## UI Design: Notification Settings

### Navigation
- **Entry**: Profile Tab → Settings → Notifications
- **Presentation**: Push navigation

### View Hierarchy

```
NotificationSettingsView (Screen)
├── NotificationSettingsViewModel
├── MasterToggleSection
│   └── Toggle (Enable All)
├── ReminderTypesSection
│   ├── NotificationTypeRow (Workout)
│   ├── NotificationTypeRow (Recovery)
│   └── NotificationTypeRow (Sleep)
├── ScheduleSection
│   └── TimePickerRow
└── PreviewSection
    └── NotificationPreviewCard
```

### ViewModel

```swift
@MainActor
@Observable
final class NotificationSettingsViewModel {
    var notificationsEnabled = false
    var workoutReminders = true
    var recoveryAlerts = true
    var sleepReminders = false
    var reminderTime = Date()

    private let scheduleUseCase: ScheduleNotificationUseCase

    func toggleNotifications() async { }
    func updateReminderTime(_ time: Date) async { }
}
```

### Components Used
- `VitalCard` for sections
- Standard `Toggle` with `.tint(Color.vitalPrimary)`
- `DatePicker` for time selection
- `VitalButton` for "Test Notification"
```
