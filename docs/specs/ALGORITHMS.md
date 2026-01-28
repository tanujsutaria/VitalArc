# VitalArc - Algorithm Specifications

## Overview

This document specifies the core algorithms powering VitalArc's intelligent features. Each algorithm includes mathematical formulas, implementation pseudocode, and edge case handling.

---

## 1. Workout Progression Algorithms

### 1.1 RIR-Based Weight Progression

**Purpose**: Calculate suggested weight for next set/workout based on RIR performance.

**Formula**:
```
If actual_RIR > target_RIR + 1:
    next_weight = current_weight × (1 + weight_increment_percent)
Else if actual_RIR < target_RIR - 1:
    next_weight = current_weight × (1 - weight_decrement_percent)
Else:
    next_weight = current_weight
```

**Implementation**:
```swift
struct ProgressionCalculator {
    /// Weight increment as percentage (default 2.5%)
    let weightIncrementPercent: Double = 0.025
    let weightDecrementPercent: Double = 0.025
    let minimumIncrements: [Equipment: Double] = [
        .barbell: 5.0,  // 2.5 lb plates each side
        .dumbbell: 5.0,  // Next dumbbell up
        .cable: 5.0,
        .machine: 10.0
    ]

    func calculateNextWeight(
        currentWeight: Double,
        actualRIR: Int,
        targetRIR: Int,
        equipment: Equipment
    ) -> Double {
        let minIncrement = minimumIncrements[equipment] ?? 5.0

        // Determine direction
        let rirDiff = actualRIR - targetRIR

        if rirDiff >= 2 {
            // Too easy - increase weight
            let increase = max(currentWeight * weightIncrementPercent, minIncrement)
            return roundToIncrement(currentWeight + increase, increment: minIncrement)
        } else if rirDiff <= -2 {
            // Too hard - decrease weight
            let decrease = max(currentWeight * weightDecrementPercent, minIncrement)
            return max(0, roundToIncrement(currentWeight - decrease, increment: minIncrement))
        } else {
            // On target - maintain
            return currentWeight
        }
    }

    func roundToIncrement(_ weight: Double, increment: Double) -> Double {
        return round(weight / increment) * increment
    }
}
```

### 1.2 Rep Fallback When Weight Can't Increase

**Purpose**: When equipment limits weight increases, add reps instead.

**Logic**:
```
If next_available_weight - current_weight > max_jump_percent × current_weight:
    Keep current weight
    Add 1-2 reps to target
Else:
    Use next_available_weight
    Reset reps to bottom of range
```

**Implementation**:
```swift
struct RepFallbackCalculator {
    let maxJumpPercent: Double = 0.10  // 10% max jump

    func calculateProgression(
        currentWeight: Double,
        currentReps: Int,
        targetRepRange: ClosedRange<Int>,
        availableWeights: [Double]
    ) -> (weight: Double, reps: Int) {
        // Find next available weight above current
        guard let nextWeight = availableWeights.first(where: { $0 > currentWeight }) else {
            // At max weight - add reps
            return (currentWeight, min(currentReps + 1, targetRepRange.upperBound))
        }

        let jumpPercent = (nextWeight - currentWeight) / currentWeight

        if jumpPercent > maxJumpPercent {
            // Jump too big - add reps instead
            if currentReps < targetRepRange.upperBound {
                return (currentWeight, currentReps + 1)
            } else {
                // At top of rep range - must increase weight
                return (nextWeight, targetRepRange.lowerBound)
            }
        } else {
            // Normal progression - increase weight, reset reps
            return (nextWeight, targetRepRange.lowerBound)
        }
    }
}
```

### 1.3 Volume Autoregulation (Feedback-Based)

**Purpose**: Adjust number of sets based on post-workout feedback.

**Decision Matrix**:

| Pump | Soreness | Workload | Action |
|------|----------|----------|--------|
| Low | Low | Easy | +2 sets next session |
| Low | Low | Moderate | +1 set next session |
| Low | Moderate | Any | +1 set next session |
| Moderate | Moderate | Moderate | Maintain |
| High | High | Hard | -1 set (approaching MRV) |
| Any | Very High | Very Hard | Deload trigger |

**Implementation**:
```swift
struct VolumeAutoregulator {
    func calculateSetAdjustment(feedback: WorkoutFeedback) -> Int {
        let pumpScore = feedback.pumpQuality.rawValue
        let sorenessScore = feedback.muscleSoreness.rawValue
        let workloadScore = feedback.workloadPerception.rawValue
        let performanceScore = feedback.performanceRating.rawValue

        // Check for overreaching signals
        if sorenessScore >= 5 || workloadScore >= 5 || performanceScore <= 2 {
            return -2  // Reduce volume, possible deload needed
        }

        // Check for approaching MRV
        if sorenessScore >= 4 && workloadScore >= 4 {
            return -1  // Slight reduction
        }

        // Calculate stimulus score (lower = need more volume)
        let stimulusScore = (pumpScore + sorenessScore) / 2.0

        // Calculate fatigue score (higher = too much)
        let fatigueScore = (workloadScore + (6 - performanceScore)) / 2.0

        // Decision logic
        if stimulusScore < 2.5 && fatigueScore < 3.0 {
            return 2  // Definitely need more volume
        } else if stimulusScore < 3.0 && fatigueScore < 3.5 {
            return 1  // Could use a bit more
        } else if stimulusScore > 4.0 && fatigueScore > 4.0 {
            return -1  // Pulling back
        } else {
            return 0  // Maintain
        }
    }
}
```

### 1.4 Weekly RIR Progression

**Purpose**: Automatically decrease target RIR each week of mesocycle.

**Standard Progression**:
```
Week 1: 4 RIR
Week 2: 3 RIR
Week 3: 2 RIR
Week 4: 1 RIR
Week 5: 0-1 RIR (peak)
Week 6: Deload (4 RIR, 50% volume)
```

**Implementation**:
```swift
struct RIRProgression {
    func targetRIR(
        week: Int,
        totalWeeks: Int,
        startingRIR: Int = 4,
        deloadWeek: Int? = nil
    ) -> Int {
        let effectiveDeloadWeek = deloadWeek ?? totalWeeks

        if week >= effectiveDeloadWeek {
            return 4  // Deload RIR
        }

        let weeksBeforeDeload = effectiveDeloadWeek - 1
        let rirDecrease = min(week - 1, startingRIR)

        return max(0, startingRIR - rirDecrease)
    }

    func volumeMultiplier(week: Int, totalWeeks: Int, deloadWeek: Int? = nil) -> Double {
        let effectiveDeloadWeek = deloadWeek ?? totalWeeks

        if week >= effectiveDeloadWeek {
            return 0.5  // 50% volume on deload
        }

        // Progressive volume increase
        let baseMultiplier = 1.0
        let weeklyIncrease = 0.1  // 10% per week
        return baseMultiplier + (Double(week - 1) * weeklyIncrease)
    }
}
```

### 1.5 Estimated 1RM Calculation

**Purpose**: Track strength progress via estimated one-rep max.

**Formulas** (multiple for cross-validation):

```
Epley:     1RM = weight × (1 + reps/30)
Brzycki:   1RM = weight × (36 / (37 - reps))
Lombardi:  1RM = weight × reps^0.10
O'Conner:  1RM = weight × (1 + 0.025 × reps)
```

**Implementation**:
```swift
struct OneRepMaxCalculator {
    enum Formula {
        case epley, brzycki, lombardi, oconner, average
    }

    func calculate(weight: Double, reps: Int, rir: Int = 0, formula: Formula = .average) -> Double {
        // Effective reps = actual reps + RIR
        let effectiveReps = Double(reps + rir)

        guard effectiveReps > 0, effectiveReps < 37 else {
            return weight  // Edge case handling
        }

        switch formula {
        case .epley:
            return weight * (1 + effectiveReps / 30.0)
        case .brzycki:
            return weight * (36.0 / (37.0 - effectiveReps))
        case .lombardi:
            return weight * pow(effectiveReps, 0.10)
        case .oconner:
            return weight * (1 + 0.025 * effectiveReps)
        case .average:
            let epley = weight * (1 + effectiveReps / 30.0)
            let brzycki = weight * (36.0 / (37.0 - effectiveReps))
            return (epley + brzycki) / 2.0
        }
    }
}
```

---

## 2. Nutrition Algorithms

### 2.1 Adaptive TDEE Calculation

**Purpose**: Calculate Total Daily Energy Expenditure from actual intake and weight data.

**Core Formula**:
```
TDEE = Calories_In - (ΔWeight × Energy_Density)

Where:
- ΔWeight = change in trend weight (kg/day)
- Energy_Density = dynamic value based on rate of change
  - Slow loss (<0.5% BW/week): ~5,500 kcal/kg (more lean mass loss)
  - Moderate loss (0.5-1%): ~7,000 kcal/kg
  - Fast loss (>1%): ~7,700 kcal/kg (more fat loss)
  - Gain: ~5,000-6,000 kcal/kg (more lean mass gain possible)
```

**Implementation**:
```swift
struct AdaptiveTDEECalculator {
    /// Minimum days of data needed for reliable estimate
    let minimumDataDays = 14

    /// Rolling window for trend calculation
    let trendWindowDays = 7

    func calculateExpenditure(
        dailyData: [DailyNutritionData],  // Must be sorted by date
        currentWeight: Double
    ) -> ExpenditureEstimate? {
        guard dailyData.count >= minimumDataDays else {
            return nil
        }

        // Calculate trend weight using exponentially weighted moving average
        let trendWeights = calculateTrendWeights(from: dailyData)

        // Calculate rate of weight change
        let recentTrend = trendWeights.suffix(trendWindowDays)
        guard let firstTrend = recentTrend.first,
              let lastTrend = recentTrend.last else {
            return nil
        }

        let weightChangeDays = Double(recentTrend.count)
        let dailyWeightChange = (lastTrend - firstTrend) / weightChangeDays  // kg/day
        let weeklyWeightChangePercent = (dailyWeightChange * 7) / currentWeight * 100

        // Determine energy density based on rate of change
        let energyDensity = calculateEnergyDensity(
            weeklyChangePercent: weeklyWeightChangePercent
        )

        // Calculate average calorie intake over trend period
        let recentIntake = dailyData.suffix(trendWindowDays)
        let avgCalories = recentIntake.map(\.totalCalories).reduce(0, +) / Double(recentIntake.count)

        // TDEE = Intake - (Weight Change × Energy Density)
        let tdee = avgCalories - (dailyWeightChange * energyDensity)

        // Calculate confidence based on tracking consistency
        let trackingDays = recentIntake.filter { $0.trackingCompleteness > 0.8 }.count
        let confidence = Double(trackingDays) / Double(trendWindowDays)

        return ExpenditureEstimate(
            tdee: tdee,
            trendWeight: lastTrend,
            weeklyChangePercent: weeklyWeightChangePercent,
            confidence: confidence
        )
    }

    private func calculateTrendWeights(from data: [DailyNutritionData]) -> [Double] {
        // Exponentially weighted moving average
        let alpha = 0.1  // Smoothing factor

        var trendWeights: [Double] = []
        var ewma: Double?

        for day in data {
            guard let weight = day.weight else { continue }

            if let previous = ewma {
                ewma = alpha * weight + (1 - alpha) * previous
            } else {
                ewma = weight
            }

            trendWeights.append(ewma!)
        }

        return trendWeights
    }

    private func calculateEnergyDensity(weeklyChangePercent: Double) -> Double {
        // kcal per kg of body weight change
        if weeklyChangePercent < -1.0 {
            return 7700  // Fast loss - mostly fat
        } else if weeklyChangePercent < -0.5 {
            return 7000  // Moderate loss
        } else if weeklyChangePercent < 0 {
            return 5500  // Slow loss - more lean mass
        } else if weeklyChangePercent < 0.5 {
            return 5000  // Slow gain - some lean mass
        } else {
            return 6000  // Fast gain - mix of fat/lean
        }
    }
}

struct DailyNutritionData {
    let date: Date
    let totalCalories: Double
    let weight: Double?
    let trackingCompleteness: Double  // 0-1
}

struct ExpenditureEstimate {
    let tdee: Double
    let trendWeight: Double
    let weeklyChangePercent: Double
    let confidence: Double
}
```

### 2.2 Macro Recommendation Algorithm

**Purpose**: Calculate optimal macro targets based on goal, TDEE, and preferences.

**Formulas**:
```
Protein:
- Building muscle: 0.8-1.0g per lb bodyweight
- Cutting: 1.0-1.2g per lb bodyweight (preserve muscle)
- Maintaining: 0.7-0.8g per lb bodyweight

Fat (minimum):
- 0.3-0.4g per lb bodyweight (hormone health)
- Never below 20% of calories

Carbs:
- Remaining calories after protein and fat
```

**Implementation**:
```swift
struct MacroCalculator {
    struct MacroTargets {
        let calories: Int
        let protein: Int  // grams
        let carbs: Int
        let fat: Int
    }

    func calculate(
        tdee: Double,
        bodyWeight: Double,  // in lbs
        goal: NutritionGoalType,
        weeklyRatePercent: Double,
        dietStructure: DietStructure
    ) -> MacroTargets {
        // Calculate calorie target
        let weeklyChange = bodyWeight * (weeklyRatePercent / 100)
        let dailyCalorieAdjustment = weeklyChange * 500  // ~500 cal per lb

        let calories: Double
        switch goal {
        case .lose:
            calories = tdee - dailyCalorieAdjustment
        case .gain:
            calories = tdee + dailyCalorieAdjustment
        case .maintain, .recomp:
            calories = tdee
        }

        // Calculate protein based on goal
        let proteinPerLb: Double
        switch goal {
        case .lose:
            proteinPerLb = 1.1  // Higher during cut
        case .gain:
            proteinPerLb = 0.9
        case .maintain, .recomp:
            proteinPerLb = 0.85
        }
        let protein = bodyWeight * proteinPerLb

        // Calculate fat and carbs based on diet structure
        let (fatPercent, carbPercent) = macroSplit(for: dietStructure, protein: protein, calories: calories)

        let fatCalories = calories * fatPercent
        let carbCalories = calories * carbPercent

        let fat = fatCalories / 9  // 9 cal per gram
        let carbs = carbCalories / 4  // 4 cal per gram

        return MacroTargets(
            calories: Int(calories),
            protein: Int(protein),
            carbs: Int(carbs),
            fat: Int(fat)
        )
    }

    private func macroSplit(
        for structure: DietStructure,
        protein: Double,
        calories: Double
    ) -> (fat: Double, carbs: Double) {
        let proteinCalories = protein * 4
        let proteinPercent = proteinCalories / calories
        let remaining = 1.0 - proteinPercent

        switch structure {
        case .balanced:
            // Equal fat and carbs from remaining
            return (remaining * 0.45, remaining * 0.55)
        case .lowFat:
            // Minimize fat (but not below 20% total)
            let minFatPercent = 0.20
            return (minFatPercent, 1.0 - proteinPercent - minFatPercent)
        case .lowCarb:
            // Higher fat, lower carbs
            return (remaining * 0.65, remaining * 0.35)
        case .keto:
            // Very low carbs (5% of total)
            let carbPercent = 0.05
            return (1.0 - proteinPercent - carbPercent, carbPercent)
        }
    }
}
```

### 2.3 Weekly Adjustment Algorithm

**Purpose**: Recommend calorie/macro changes during weekly check-in.

**Logic**:
```
If weight_change matches goal_rate (within ±0.1% BW/week):
    No adjustment needed
Else if weight_change < goal_rate:
    If goal is loss: decrease calories by 50-100
    If goal is gain: increase calories by 100-150
Else (weight_change > goal_rate):
    If goal is loss: increase calories by 50-100 (prevent crash)
    If goal is gain: decrease calories by 50-100 (minimize fat gain)
```

**Implementation**:
```swift
struct WeeklyAdjustmentCalculator {
    let tolerancePercent = 0.1  // ±0.1% BW/week tolerance

    func calculateAdjustment(
        currentCalories: Int,
        actualWeeklyChangePercent: Double,
        targetWeeklyChangePercent: Double,
        goal: NutritionGoalType
    ) -> CalorieAdjustment {
        let difference = actualWeeklyChangePercent - targetWeeklyChangePercent

        // Within tolerance - no change
        if abs(difference) <= tolerancePercent {
            return CalorieAdjustment(
                newCalories: currentCalories,
                change: 0,
                reason: "On track - maintaining current calories"
            )
        }

        let adjustment: Int
        let reason: String

        switch goal {
        case .lose:
            if difference > tolerancePercent {
                // Losing too fast
                adjustment = 75
                reason = "Losing faster than target - slight increase to preserve muscle"
            } else {
                // Not losing fast enough
                adjustment = -75
                reason = "Weight loss slower than target - slight decrease"
            }

        case .gain:
            if difference > tolerancePercent {
                // Gaining too fast
                adjustment = -75
                reason = "Gaining faster than target - slight decrease to minimize fat"
            } else {
                // Not gaining fast enough
                adjustment = 100
                reason = "Weight gain slower than target - slight increase"
            }

        case .maintain, .recomp:
            if difference > 0 {
                adjustment = -50
                reason = "Weight trending up - slight decrease"
            } else {
                adjustment = 50
                reason = "Weight trending down - slight increase"
            }
        }

        return CalorieAdjustment(
            newCalories: currentCalories + adjustment,
            change: adjustment,
            reason: reason
        )
    }
}

struct CalorieAdjustment {
    let newCalories: Int
    let change: Int
    let reason: String
}
```

---

## 3. Health Analytics Algorithms

### 3.1 Recovery Score Calculation

**Purpose**: Calculate 0-100% recovery score from HRV and RHR data.

**Formula**:
```
HRV_Score = ((Current_HRV - Baseline_HRV) / Baseline_HRV) × 50 + 50
RHR_Score = ((Baseline_RHR - Current_RHR) / Baseline_RHR) × 50 + 50

Recovery = (HRV_Score × 0.7) + (RHR_Score × 0.3)

Clamped to 0-100 range
```

**Implementation**:
```swift
struct RecoveryCalculator {
    let hrvWeight = 0.7
    let rhrWeight = 0.3
    let baselineDays = 60

    func calculate(
        currentHRV: Double,
        hrvBaseline: Double,
        currentRHR: Double,
        rhrBaseline: Double
    ) -> RecoveryResult {
        // HRV score (higher is better)
        // Normalize to 0-100 where 50 = baseline
        let hrvDeviation = (currentHRV - hrvBaseline) / hrvBaseline
        let hrvScore = clamp(50 + (hrvDeviation * 50), min: 0, max: 100)

        // RHR score (lower is better)
        // Normalize to 0-100 where 50 = baseline
        let rhrDeviation = (rhrBaseline - currentRHR) / rhrBaseline
        let rhrScore = clamp(50 + (rhrDeviation * 50), min: 0, max: 100)

        // Weighted combination
        let totalScore = (hrvScore * hrvWeight) + (rhrScore * rhrWeight)
        let finalScore = clamp(totalScore, min: 0, max: 100)

        // Determine category
        let category: RecoveryCategory
        switch finalScore {
        case 0..<34:
            category = .poor
        case 34..<67:
            category = .fair
        case 67..<86:
            category = .good
        default:
            category = .excellent
        }

        return RecoveryResult(
            score: finalScore,
            category: category,
            hrvScore: hrvScore,
            rhrScore: rhrScore,
            hrvValue: currentHRV,
            rhrValue: currentRHR
        )
    }

    private func clamp(_ value: Double, min: Double, max: Double) -> Double {
        Swift.min(Swift.max(value, min), max)
    }
}

struct RecoveryResult {
    let score: Double
    let category: RecoveryCategory
    let hrvScore: Double
    let rhrScore: Double
    let hrvValue: Double
    let rhrValue: Double
}
```

### 3.2 RMSSD Calculation (HRV)

**Purpose**: Calculate Root Mean Square of Successive Differences from raw HR data.

**Formula**:
```
RMSSD = √(Σ(RRᵢ₊₁ - RRᵢ)² / (N-1))

Where:
- RRᵢ = time between heartbeats in ms
- N = number of RR intervals
```

**Implementation**:
```swift
struct HRVCalculator {
    /// Calculate RMSSD from RR intervals
    func calculateRMSSD(rrIntervals: [Double]) -> Double? {
        guard rrIntervals.count >= 2 else { return nil }

        // Filter outliers (ectopic beats, artifacts)
        let filtered = filterOutliers(rrIntervals)
        guard filtered.count >= 2 else { return nil }

        // Calculate successive differences
        var sumSquaredDiff: Double = 0
        for i in 0..<(filtered.count - 1) {
            let diff = filtered[i + 1] - filtered[i]
            sumSquaredDiff += diff * diff
        }

        // RMSSD
        let rmssd = sqrt(sumSquaredDiff / Double(filtered.count - 1))
        return rmssd
    }

    /// Calculate SDNN from RR intervals
    func calculateSDNN(rrIntervals: [Double]) -> Double? {
        guard rrIntervals.count >= 2 else { return nil }

        let filtered = filterOutliers(rrIntervals)
        guard filtered.count >= 2 else { return nil }

        let mean = filtered.reduce(0, +) / Double(filtered.count)

        var sumSquaredDeviation: Double = 0
        for interval in filtered {
            let deviation = interval - mean
            sumSquaredDeviation += deviation * deviation
        }

        let sdnn = sqrt(sumSquaredDeviation / Double(filtered.count - 1))
        return sdnn
    }

    /// Filter outliers using median-based approach
    private func filterOutliers(_ intervals: [Double]) -> [Double] {
        guard intervals.count >= 3 else { return intervals }

        let sorted = intervals.sorted()
        let median = sorted[sorted.count / 2]

        // Keep intervals within 25% of median
        let lowerBound = median * 0.75
        let upperBound = median * 1.25

        return intervals.filter { $0 >= lowerBound && $0 <= upperBound }
    }
}
```

### 3.3 Strain/Exertion Calculation (TRIMP-based)

**Purpose**: Calculate daily strain from heart rate data.

**Formula** (Banister TRIMP):
```
TRIMP = Duration × HRr × 0.64e^(y×HRr)

Where:
- Duration = minutes
- HRr = (HR - HRrest) / (HRmax - HRrest)  [Heart Rate Reserve fraction]
- y = 1.92 (men) or 1.67 (women)
```

**Implementation**:
```swift
struct StrainCalculator {
    func calculateTRIMP(
        heartRateData: [HeartRateSample],  // 1-minute samples
        restingHR: Double,
        maxHR: Double,
        sex: BiologicalSex
    ) -> Double {
        let y = sex == .female ? 1.67 : 1.92
        let hrReserve = maxHR - restingHR

        var totalTRIMP: Double = 0

        for sample in heartRateData {
            // Calculate HR reserve fraction
            let hrr = (sample.heartRate - restingHR) / hrReserve
            let clampedHRR = max(0, min(1, hrr))

            // TRIMP for this minute
            let trimp = 1.0 * clampedHRR * 0.64 * exp(y * clampedHRR)
            totalTRIMP += trimp
        }

        return totalTRIMP
    }

    /// Convert TRIMP to 0-100 scale
    func normalizeToScale(trimp: Double, maxExpectedTRIMP: Double = 500) -> Double {
        // Logarithmic scaling (harder to increase at higher levels)
        let normalized = log10(trimp + 1) / log10(maxExpectedTRIMP + 1) * 100
        return min(100, max(0, normalized))
    }

    /// Calculate heart rate zones
    func calculateZones(
        heartRateData: [HeartRateSample],
        maxHR: Double
    ) -> HeartRateZoneData {
        var zones = [0, 0, 0, 0, 0]  // Minutes in each zone

        for sample in heartRateData {
            let percent = sample.heartRate / maxHR * 100

            switch percent {
            case 0..<60:
                zones[0] += 1  // Zone 1
            case 60..<70:
                zones[1] += 1  // Zone 2
            case 70..<80:
                zones[2] += 1  // Zone 3
            case 80..<90:
                zones[3] += 1  // Zone 4
            default:
                zones[4] += 1  // Zone 5
            }
        }

        return HeartRateZoneData(
            zone1Minutes: zones[0],
            zone2Minutes: zones[1],
            zone3Minutes: zones[2],
            zone4Minutes: zones[3],
            zone5Minutes: zones[4]
        )
    }
}

struct HeartRateSample {
    let timestamp: Date
    let heartRate: Double
}
```

### 3.4 Training Load (ATL/CTL)

**Purpose**: Calculate Acute and Chronic Training Load for fitness/fatigue balance.

**Formulas**:
```
ATL (Acute) = EWMA with τ = 7 days
CTL (Chronic) = EWMA with τ = 42 days

EWMA = Previous × (1 - 2/(τ+1)) + Today × (2/(τ+1))

TSB (Training Stress Balance) = CTL - ATL
```

**Implementation**:
```swift
struct TrainingLoadCalculator {
    let atlTimeConstant = 7.0  // 7 days
    let ctlTimeConstant = 42.0  // 6 weeks

    func calculate(dailyLoads: [DailyLoad]) -> [TrainingLoad] {
        guard !dailyLoads.isEmpty else { return [] }

        let atlAlpha = 2.0 / (atlTimeConstant + 1)
        let ctlAlpha = 2.0 / (ctlTimeConstant + 1)

        var results: [TrainingLoad] = []
        var atl = dailyLoads[0].load
        var ctl = dailyLoads[0].load

        for day in dailyLoads {
            // Exponentially weighted moving average
            atl = day.load * atlAlpha + atl * (1 - atlAlpha)
            ctl = day.load * ctlAlpha + ctl * (1 - ctlAlpha)

            let tsb = ctl - atl

            // Calculate ramp rate (week-over-week CTL change)
            let rampRate: Double
            if results.count >= 7 {
                let weekAgo = results[results.count - 7].chronicLoad
                rampRate = ((ctl - weekAgo) / weekAgo) * 100
            } else {
                rampRate = 0
            }

            // Determine training status
            let status = determineStatus(atl: atl, ctl: ctl, tsb: tsb, rampRate: rampRate)

            results.append(TrainingLoad(
                date: day.date,
                acuteLoad: atl,
                chronicLoad: ctl,
                trainingStressBalance: tsb,
                rampRate: rampRate,
                status: status
            ))
        }

        return results
    }

    private func determineStatus(
        atl: Double,
        ctl: Double,
        tsb: Double,
        rampRate: Double
    ) -> TrainingStatus {
        // TSB thresholds
        if rampRate < -10 {
            return .detraining
        } else if tsb < -30 && atl > ctl * 1.3 {
            return .overtraining
        } else if tsb < -15 {
            return .fatigued
        } else if tsb > 10 && ctl > 50 {
            return .peaking
        } else if rampRate > 5 && tsb > -10 {
            return .productive
        } else {
            return .maintaining
        }
    }
}

struct DailyLoad {
    let date: Date
    let load: Double  // TRIMP or other load metric
}
```

### 3.5 Sleep Score Calculation

**Purpose**: Calculate overall sleep quality score from multiple factors.

**Formula**:
```
Sleep_Score = (
    Duration_Score × 0.30 +
    Efficiency_Score × 0.20 +
    REM_Score × 0.20 +
    Deep_Score × 0.20 +
    Consistency_Score × 0.10
)
```

**Implementation**:
```swift
struct SleepScoreCalculator {
    func calculate(
        sleepData: SleepData,
        targetHours: Double,
        averageBedtime: Date?
    ) -> Double {
        // Duration score (0-100)
        let durationScore = calculateDurationScore(
            hours: sleepData.totalHours,
            target: targetHours
        )

        // Efficiency score (time asleep / time in bed)
        let efficiencyScore = sleepData.efficiency * 100

        // REM score (target: 20-25% of sleep)
        let remScore = calculateStageScore(
            percent: sleepData.stages.remPercent,
            idealRange: 20...25
        )

        // Deep sleep score (target: 15-20% of sleep)
        let deepScore = calculateStageScore(
            percent: sleepData.stages.deepPercent,
            idealRange: 15...20
        )

        // Consistency score (how close to usual bedtime)
        let consistencyScore = calculateConsistencyScore(
            actualBedtime: sleepData.bedtime,
            averageBedtime: averageBedtime
        )

        // Weighted combination
        let totalScore = (
            durationScore * 0.30 +
            efficiencyScore * 0.20 +
            remScore * 0.20 +
            deepScore * 0.20 +
            consistencyScore * 0.10
        )

        return min(100, max(0, totalScore))
    }

    private func calculateDurationScore(hours: Double, target: Double) -> Double {
        let ratio = hours / target
        if ratio >= 1.0 {
            // Met or exceeded target - perfect score up to 120%
            return ratio <= 1.2 ? 100 : max(0, 100 - (ratio - 1.2) * 100)
        } else {
            // Below target - linear decrease
            return ratio * 100
        }
    }

    private func calculateStageScore(percent: Double, idealRange: ClosedRange<Double>) -> Double {
        if idealRange.contains(percent) {
            return 100
        } else if percent < idealRange.lowerBound {
            let deficit = idealRange.lowerBound - percent
            return max(0, 100 - deficit * 5)
        } else {
            let excess = percent - idealRange.upperBound
            return max(0, 100 - excess * 3)
        }
    }

    private func calculateConsistencyScore(actualBedtime: Date, averageBedtime: Date?) -> Double {
        guard let average = averageBedtime else { return 80 }  // No baseline yet

        let calendar = Calendar.current
        let actualMinutes = calendar.component(.hour, from: actualBedtime) * 60 +
                          calendar.component(.minute, from: actualBedtime)
        let averageMinutes = calendar.component(.hour, from: average) * 60 +
                           calendar.component(.minute, from: average)

        var diff = abs(actualMinutes - averageMinutes)
        // Handle midnight wraparound
        if diff > 720 { diff = 1440 - diff }

        // Perfect if within 30 min, decreases after
        if diff <= 30 {
            return 100
        } else {
            return max(0, 100 - Double(diff - 30) * 0.5)
        }
    }
}
```

---

## 4. Insight Generation Algorithms

### 4.1 Correlation Detection

**Purpose**: Find statistically significant correlations between metrics.

**Implementation**:
```swift
struct CorrelationAnalyzer {
    /// Calculate Pearson correlation coefficient
    func pearsonCorrelation(_ x: [Double], _ y: [Double]) -> Double? {
        guard x.count == y.count, x.count >= 7 else { return nil }

        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumX2 = x.map { $0 * $0 }.reduce(0, +)
        let sumY2 = y.map { $0 * $0 }.reduce(0, +)

        let numerator = n * sumXY - sumX * sumY
        let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))

        guard denominator != 0 else { return nil }
        return numerator / denominator
    }

    /// Find significant correlations in user data
    func findCorrelations(data: AnalyticsData) -> [Correlation] {
        var correlations: [Correlation] = []

        // Check sleep vs recovery
        if let r = pearsonCorrelation(data.sleepHours, data.recoveryScores),
           abs(r) > 0.3 {
            correlations.append(Correlation(
                metric1: "Sleep Duration",
                metric2: "Recovery Score",
                coefficient: r,
                interpretation: r > 0 ?
                    "Better sleep correlates with higher recovery" :
                    "Unexpected: less sleep correlates with higher recovery"
            ))
        }

        // Check protein vs performance
        if let r = pearsonCorrelation(data.proteinIntake, data.workoutPerformance),
           abs(r) > 0.3 {
            correlations.append(Correlation(
                metric1: "Protein Intake",
                metric2: "Workout Performance",
                coefficient: r,
                interpretation: r > 0 ?
                    "Higher protein intake correlates with better performance" :
                    "Lower protein may be affecting performance"
            ))
        }

        // Add more correlation checks...

        return correlations.sorted { abs($0.coefficient) > abs($1.coefficient) }
    }
}

struct Correlation {
    let metric1: String
    let metric2: String
    let coefficient: Double
    let interpretation: String

    var strength: String {
        let abs = abs(coefficient)
        switch abs {
        case 0..<0.3: return "Weak"
        case 0.3..<0.5: return "Moderate"
        case 0.5..<0.7: return "Strong"
        default: return "Very Strong"
        }
    }
}

struct AnalyticsData {
    let sleepHours: [Double]
    let recoveryScores: [Double]
    let proteinIntake: [Double]
    let workoutPerformance: [Double]
    // ... other metrics
}
```

### 4.2 Recommendation Engine

**Purpose**: Generate personalized recommendations based on current state.

**Implementation**:
```swift
struct RecommendationEngine {
    func generateRecommendations(
        recovery: RecoveryResult,
        strain: StrainScore,
        sleep: SleepData,
        nutrition: DailyNutrition,
        goals: NutritionGoal
    ) -> [Recommendation] {
        var recommendations: [Recommendation] = []

        // Recovery-based training recommendation
        let trainingRec = generateTrainingRecommendation(recovery: recovery, strain: strain)
        recommendations.append(trainingRec)

        // Sleep recommendation
        if sleep.totalHours < 7 {
            recommendations.append(Recommendation(
                category: .sleep,
                priority: .high,
                title: "Sleep Deficit Detected",
                message: "You got \(String(format: "%.1f", sleep.totalHours)) hours last night. Aim for 7-9 hours to support recovery.",
                action: "Consider going to bed 30 minutes earlier tonight"
            ))
        }

        // Nutrition recommendations
        let proteinTarget = Double(goals.protein)
        if nutrition.totalProtein < proteinTarget * 0.8 {
            recommendations.append(Recommendation(
                category: .nutrition,
                priority: .medium,
                title: "Protein Below Target",
                message: "You've logged \(Int(nutrition.totalProtein))g of \(goals.protein)g protein target",
                action: "Add a protein-rich snack or meal"
            ))
        }

        return recommendations.sorted { $0.priority.rawValue < $1.priority.rawValue }
    }

    private func generateTrainingRecommendation(
        recovery: RecoveryResult,
        strain: StrainScore
    ) -> Recommendation {
        switch recovery.category {
        case .excellent:
            return Recommendation(
                category: .training,
                priority: .low,
                title: "Excellent Recovery",
                message: "Your body is well-recovered. Great day for intense training.",
                action: "Consider a challenging workout targeting lagging muscle groups"
            )
        case .good:
            return Recommendation(
                category: .training,
                priority: .low,
                title: "Good Recovery",
                message: "You're ready for normal training intensity.",
                action: "Proceed with your scheduled workout"
            )
        case .fair:
            return Recommendation(
                category: .training,
                priority: .medium,
                title: "Moderate Recovery",
                message: "Consider reducing intensity or volume today.",
                action: "Focus on technique work or lighter weights"
            )
        case .poor:
            return Recommendation(
                category: .training,
                priority: .high,
                title: "Low Recovery",
                message: "Your body needs more rest. Consider active recovery or rest.",
                action: "Light walking, stretching, or complete rest recommended"
            )
        }
    }
}

struct Recommendation {
    let category: RecommendationCategory
    let priority: RecommendationPriority
    let title: String
    let message: String
    let action: String
}

enum RecommendationCategory {
    case training, nutrition, sleep, recovery
}

enum RecommendationPriority: Int {
    case high = 1
    case medium = 2
    case low = 3
}
```

---

## 5. Edge Cases and Error Handling

### Common Edge Cases

1. **Insufficient Data**
   - Recovery: Require minimum 7 days of HRV data before showing score
   - TDEE: Require 14 days before showing adaptive estimate
   - Correlations: Require 30+ data points

2. **Missing Data Points**
   - Use interpolation for single missing days
   - Reset calculations if gap > 3 days
   - Show "insufficient data" message rather than inaccurate results

3. **Outliers**
   - HRV: Filter values outside 25% of median
   - Weight: Flag changes > 2% in single day for review
   - Heart Rate: Ignore readings outside 40-220 bpm

4. **New Users**
   - Use population averages until personal baseline established
   - Clearly indicate "calibrating" status
   - Provide helpful prompts to collect needed data

### Error States

```swift
enum AlgorithmError: Error {
    case insufficientData(required: Int, actual: Int)
    case invalidInput(description: String)
    case calculationFailed(reason: String)
    case outlierDetected(value: Double, expected: ClosedRange<Double>)
}
```
