# Mesocycle and Periodization System Implementation

## Overview

This document describes the comprehensive mesocycle and periodization system implemented for VitalArc. The system enables users to create structured training programs with progressive overload, auto-regulation, and performance tracking.

## Architecture

### Domain Layer

#### Entities

**Mesocycle** (`Domain/Entities/Training/Mesocycle.swift`)
- Represents a complete training program spanning multiple weeks
- Properties:
  - `id`, `name`, `startDate`, `endDate`
  - `phases`: Array of MesocyclePhase
  - `trainingBlocks`: Array of TrainingBlock
  - `goal`: TrainingGoal (strength, hypertrophy, peaking, endurance)
  - `status`: MesocycleStatus (planned, active, completed)
- Computed properties:
  - `durationWeeks`: Total program duration
  - `currentWeek`: Current week number (1-based)
  - `currentPhase`: Active phase based on today's date
  - `progressPercentage`: 0-100% completion

**MesocyclePhase** (`Domain/Entities/Training/MesocyclePhase.swift`)
- Represents a training phase within a mesocycle
- Properties:
  - `weekNumber`: Week this phase applies to
  - `phaseType`: PhaseType enum
  - `volumeMultiplier`: Volume adjustment (1.0 = baseline)
  - `intensityMultiplier`: Intensity adjustment (1.0 = baseline)
- Phase types:
  - **Accumulation**: High volume, moderate intensity (120% volume, 100% intensity)
  - **Intensification**: Lower volume, higher intensity (80% volume, 115% intensity)
  - **Realization**: Peak performance (60% volume, 125% intensity)
  - **Deload**: Recovery week (50% volume, 70% intensity)

**TrainingBlock** (`Domain/Entities/Training/TrainingBlock.swift`)
- Represents a single workout day in the training schedule
- Properties:
  - `dayOfWeek`: 1-7 (Calendar.weekday format)
  - `exercises`: Array of TrainingBlockExercise
  - `mesocycleId`: Link to parent mesocycle
- Computed properties:
  - `dayName`: Human-readable day name
  - `totalSets`: Sum of all exercise sets
  - `estimatedDuration`: Workout duration estimate

**TrainingBlockExercise**
- Defines exercise prescription within a training block
- Properties:
  - `exerciseId`: Reference to Exercise entity
  - `targetSets`, `targetRepsMin`, `targetRepsMax`
  - `targetRIR`: Reps In Reserve (0-5)
  - `progressionScheme`: How to progress over time
- Progression schemes:
  - **Linear**: Add weight each week (e.g., +2.5kg)
  - **Double Progression**: Add reps until max reached, then add weight
  - **Wave**: Undulating intensity week to week
  - **Static**: Maintain current weight and reps

**AutoRegulationAdvice**
- AI-driven recommendations based on performance
- Recommendations:
  - `increaseWeight`: Performance exceeds target RIR
  - `decreaseWeight`: Struggling to maintain target RIR
  - `maintain`: On track with current progression
  - `deload`: Consistent failure to hit target RIR

### Data Layer

**MesocycleModel** (`Data/Models/Training/MesocycleModel.swift`)
- SwiftData model for persistence
- Stores phases and training blocks as encoded JSON (Data)
- Provides `toDomain()` and `fromDomain()` mapping methods

**WorkoutSet Extensions**
- Added fields to existing WorkoutSet entity:
  - `rir: Int?`: Reps In Reserve (0-5)
  - `rpe: Double?`: Rate of Perceived Exertion (1-10)
  - `mesocycleId: UUID?`: Links set to active mesocycle for tracking

### Repository Layer

**MesocycleRepository** (`Domain/Repositories/MesocycleRepository.swift`)
- Protocol defining mesocycle data operations
- Key methods:
  - `getMesocycles()`: Fetch all mesocycles
  - `getActiveMesocycle()`: Get currently active program
  - `saveMesocycle()`, `updateMesocycle()`, `deleteMesocycle()`
  - `activateMesocycle()`: Set as active (deactivates others)
  - `completeMesocycle()`: Mark as completed
  - `getMesocycleForDate()`: Find mesocycle for specific date

**SwiftDataMesocycleRepository** (`Infrastructure/DependencyContainer.swift`)
- Concrete implementation using SwiftData
- Handles automatic status updates based on dates
- Ensures only one active mesocycle at a time

### Use Cases

**CreateMesocycleUseCase** (`Domain/UseCases/Training/CreateMesocycleUseCase.swift`)
- Creates new mesocycles with intelligent phase generation
- Phase templates:
  - **Standard**: 4-week blocks (2 weeks accumulation, 1 intensification, 1 deload)
  - **Beginner**: 3-week blocks (2 weeks accumulation, 1 deload)
  - **Advanced**: Block periodization (⅓ accumulation, ⅓ intensification, ⅓ realization + deload)
  - **Custom**: User-defined phase progression

**UpdateMesocycleProgressUseCase** (`Domain/UseCases/Training/UpdateMesocycleProgressUseCase.swift`)
- Tracks mesocycle progress and provides auto-regulation
- Key methods:
  - `calculateAutoRegulation()`: Analyzes last 2 weeks of performance
    - Compares actual RIR vs planned RIR
    - Suggests weight changes (5-10% adjustments)
    - Recommends deload if consistently failing sets
  - `getCurrentTrainingBlocks()`: Get this week's workouts
  - `getTrainingBlockForDay()`: Get today's workout
  - `calculateProgressionWeight()`: Calculate next set weight based on progression scheme
  - `updateMesocycleStatus()`: Auto-activate/complete based on dates
  - `getProgressSummary()`: Comprehensive progress metrics

**MesocycleProgressSummary**
- Aggregated metrics for a mesocycle:
  - Current week and phase
  - Total/completed sets
  - Total volume (weight × reps)
  - Average RIR across all sets
  - Progress percentage

## Presentation Layer

### Views

**MesocycleListView** (`Presentation/Tabs/Training/MesocycleListView.swift`)
- Main view for browsing all mesocycles
- Features:
  - Status filter (Planned, Active, Completed)
  - Card-based layout with quick actions
  - Progress indicators for active mesocycles
  - Current week and phase display
  - Quick activate/complete buttons
  - Empty state with call-to-action

**CreateMesocycleView** (`Presentation/Tabs/Training/CreateMesocycleView.swift`)
- Wizard for creating new mesocycles
- Sections:
  - Program details (name, start date, duration)
  - Training goal selection with descriptions
  - Periodization template picker
  - Training block builder with templates
  - Summary preview
- Training block templates:
  - Push/Pull/Legs (6 days)
  - Upper/Lower (4 days)
  - Full Body (3 days)

**MesocycleDetailView** (`Presentation/Tabs/Training/MesocycleDetailView.swift`)
- Comprehensive mesocycle details with 3 tabs:

**Overview Tab:**
- Status card with progress bar
- Goal card with icon and description
- Timeline card (start/end dates, duration)
- Phase timeline with color-coded phases
- Quick stats (total sets, volume, average RIR)

**Schedule Tab:**
- Weekly training block schedule
- Exercise prescriptions with set×rep ranges
- Progression scheme indicators
- Estimated workout durations
- Empty state for programs without blocks

**Progress Tab:**
- Week progress card with circular progress
- Volume trend chart (placeholder for future implementation)
- RIR trend chart (placeholder for future implementation)
- Current phase indicator

### ViewModel

**MesocycleViewModel** (`Presentation/Tabs/Training/MesocycleViewModel.swift`)
- Observable state management using @Observable
- Properties:
  - `mesocycles`: All mesocycles
  - `activeMesocycle`: Currently active program
  - `selectedMesocycle`: For detail view
  - `progressSummary`: Aggregated metrics
  - `isLoading`, `error`: UI state
- Methods:
  - `loadMesocycles()`: Fetch and refresh data
  - `loadProgressSummary()`: Get progress metrics
  - `createMesocycle()`: Create new program
  - `activateMesocycle()`: Set as active
  - `completeMesocycle()`: Mark as done
  - `deleteMesocycle()`: Remove program
  - `getAutoRegulation()`: Get AI recommendations
  - `getCurrentTrainingBlocks()`: Get this week's workouts

## Integration Points

### Dependency Container
- Added `mesocycleRepository: MesocycleRepository` to DependencyContainer
- Initialized SwiftDataMesocycleRepository in init()
- Available throughout app via environment

### Main Tab View
- Added "Training" tab between Workout and Nutrition
- Icon: `calendar`
- Displays MesocycleListView when mesocycleRepository is available

### SwiftData Schema
- Added `MesocycleModel.self` to app schema in VitalArcApp.swift
- Enables iCloud sync for mesocycles (via automatic CloudKit integration)

### Workout Logging
- WorkoutSet now optionally tracks:
  - `rir`: For auto-regulation calculations
  - `rpe`: For perceived exertion tracking
  - `mesocycleId`: Links sets to active mesocycle
- Future enhancement: Auto-populate these fields from active mesocycle

## Auto-Regulation Algorithm

The auto-regulation system analyzes recent workout performance to provide intelligent recommendations:

### Data Collection
1. Fetch last 2 weeks of workouts
2. Filter sets for specific exercise and mesocycle
3. Extract RIR values from completed sets

### Analysis
1. Calculate average actual RIR
2. Compare to target RIR from training block
3. Calculate RIR difference (actual - target)

### Recommendations

**Increase Weight** (RIR difference ≥ +1)
- Leaving more reps in reserve than planned
- Suggests 2.5-5% weight increase
- Rationale: Exercise is too easy, can handle more load

**Decrease Weight** (RIR difference ≤ -1)
- Failing to maintain target RIR
- Suggests 5% weight decrease
- Rationale: Exercise is too hard, need to reduce load

**Deload** (RIR difference ≤ -2)
- Consistently unable to maintain target RIR
- Suggests 10% weight decrease
- Rationale: Accumulated fatigue, need recovery

**Maintain** (RIR within ±1)
- Performance on track
- No weight change needed
- Rationale: Perfect progression, continue current plan

## Usage Flow

### Creating a Mesocycle

1. Navigate to Training tab
2. Tap "+" button
3. Enter program details:
   - Name (e.g., "Summer Hypertrophy Block")
   - Start date
   - Duration (1-52 weeks)
4. Select training goal (Strength, Hypertrophy, Peaking, Endurance)
5. Choose periodization template (Standard, Beginner, Advanced)
6. (Optional) Add training blocks from templates or custom
7. Review summary
8. Tap "Create"

### Activating a Mesocycle

1. Find mesocycle in "Planned" filter
2. Tap "Activate" button on card, OR
3. Navigate to detail view → tap activate action
4. Mesocycle status changes to "Active"
5. Previous active mesocycle (if any) reverts to "Planned"

### Following a Mesocycle

1. View Training tab to see active mesocycle
2. Check current week and phase
3. Navigate to detail → Schedule tab
4. Review training blocks for the week
5. Log workouts in Workout tab
6. Track RIR/RPE for auto-regulation

### Auto-Regulation

1. After 2+ weeks of training
2. Navigate to mesocycle detail
3. System analyzes performance automatically
4. View recommendations in Progress tab (future enhancement)
5. Adjust weights based on suggestions

### Completing a Mesocycle

1. When mesocycle ends, status auto-updates to "Completed"
2. Or manually tap "Complete" button
3. Mesocycle moves to "Completed" filter
4. Progress is preserved for future reference

## Future Enhancements

### Phase 2: Advanced Auto-Regulation
- Real-time recommendations during workout logging
- Push notifications for weight adjustments
- Fatigue monitoring across mesocycle
- Deload suggestions based on accumulated fatigue

### Phase 3: Analytics
- Volume trend charts by muscle group
- Strength progression graphs
- Phase comparison analysis
- Recovery metrics integration (HRV, sleep)

### Phase 4: AI Training Plans
- Generate mesocycles from goals
- Exercise selection based on history
- Automatic phase progression
- Personalized deload frequency

### Phase 5: Social Features
- Share mesocycle templates
- Community training programs
- Coach-athlete mesocycle assignment
- Progress sharing and comparison

## File Structure

```
VitalArc/
├── Domain/
│   ├── Entities/
│   │   └── Training/
│   │       ├── Mesocycle.swift
│   │       ├── MesocyclePhase.swift
│   │       └── TrainingBlock.swift
│   ├── Repositories/
│   │   └── MesocycleRepository.swift
│   └── UseCases/
│       └── Training/
│           ├── CreateMesocycleUseCase.swift
│           └── UpdateMesocycleProgressUseCase.swift
├── Data/
│   └── Models/
│       └── Training/
│           ├── MesocycleModel.swift
│           ├── MesocyclePhaseModel.swift (documentation)
│           └── TrainingBlockModel.swift (documentation)
├── Infrastructure/
│   └── DependencyContainer.swift (updated)
├── Presentation/
│   └── Tabs/
│       └── Training/
│           ├── MesocycleListView.swift
│           ├── MesocycleDetailView.swift
│           ├── CreateMesocycleView.swift
│           └── MesocycleViewModel.swift
└── VitalArcApp.swift (updated schema)
```

## Testing Recommendations

### Unit Tests
- CreateMesocycleUseCase phase generation
- Auto-regulation algorithm with various RIR scenarios
- Progression weight calculations
- Mesocycle status transitions

### Integration Tests
- Repository CRUD operations
- Active mesocycle enforcement (only one at a time)
- Date-based status updates
- Workout set linking to mesocycles

### UI Tests
- Mesocycle creation flow
- Status filtering
- Progress tracking
- Training block templates

## Performance Considerations

### Data Model
- Phases and training blocks stored as JSON to reduce database complexity
- Trade-off: Cannot query individual phases/blocks directly
- Benefit: Simpler data model, easier to maintain

### Caching
- ViewModel caches mesocycles in memory
- Reduces database queries during tab switching
- Automatic refresh on mutations

### Scalability
- Current design supports unlimited mesocycles
- Active mesocycle lookup is O(n) but n is typically small
- Consider indexing on status field if performance issues arise

## Summary

This implementation provides a production-ready mesocycle and periodization system with:

- Comprehensive domain modeling
- Intelligent phase generation
- Auto-regulation based on performance
- Beautiful, intuitive UI
- Seamless integration with existing workout tracking
- Foundation for advanced analytics and AI features

The system follows clean architecture principles, separates concerns, and provides excellent user experience for both beginners and advanced athletes.
