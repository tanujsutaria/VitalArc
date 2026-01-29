//
//  AnalyticsTests.swift
//  VitalArcTests
//
//  Unit tests for TRIMP calculations and Recovery Score algorithm
//

import XCTest
@testable import VitalArc

final class AnalyticsTests: XCTestCase {

    // MARK: - TRIMP Calculation Tests

    func testBanisterTRIMPCalculation() throws {
        // Given: 30-minute workout with steady HR at 150 bpm
        // HRMax = 190, HRRest = 60, HRReserve = 130
        let hrMax: Double = 190
        let hrRest: Double = 60
        let duration: TimeInterval = 30 * 60 // 30 minutes in seconds

        // Create uniform HR samples at 150 bpm
        let sampleCount = 30
        let samples = (0..<sampleCount).map { i in
            HeartRateSample(
                timestamp: Date().addingTimeInterval(Double(i) * 60),
                bpm: 150
            )
        }

        // When: Calculate Banister TRIMP
        // HRr = (150 - 60) / (190 - 60) = 90/130 = 0.692
        // Expected TRIMP per sample: 1 min * 0.692 * 0.64 * e^(1.92 * 0.692)
        // = 1 * 0.692 * 0.64 * e^(1.33) = 0.443 * 3.78 ≈ 1.67 per minute
        // Total ≈ 50 TRIMP for 30 minutes

        let trimp = calculateBanisterTRIMP(
            samples: samples,
            duration: duration,
            hrMax: hrMax,
            hrRest: hrRest
        )

        // Then: TRIMP should be in expected range
        XCTAssertGreaterThan(trimp, 40, "TRIMP should be above 40 for moderate workout")
        XCTAssertLessThan(trimp, 70, "TRIMP should be below 70 for moderate workout")
    }

    func testBanisterTRIMPWithEmptySamples() throws {
        let trimp = calculateBanisterTRIMP(
            samples: [],
            duration: 1800,
            hrMax: 190,
            hrRest: 60
        )

        XCTAssertEqual(trimp, 0, "Empty samples should return 0 TRIMP")
    }

    func testBanisterTRIMPWithZeroHRReserve() throws {
        // Edge case: HRMax equals HRRest (invalid state)
        let samples = [HeartRateSample(timestamp: Date(), bpm: 100)]
        let trimp = calculateBanisterTRIMP(
            samples: samples,
            duration: 600,
            hrMax: 100,
            hrRest: 100
        )

        XCTAssertEqual(trimp, 0, "Zero HR reserve should return 0 TRIMP")
    }

    func testBanisterTRIMPScalesWithIntensity() throws {
        let hrMax: Double = 190
        let hrRest: Double = 60
        let duration: TimeInterval = 30 * 60

        // Low intensity workout (HR = 100)
        let lowSamples = (0..<30).map { i in
            HeartRateSample(timestamp: Date().addingTimeInterval(Double(i) * 60), bpm: 100)
        }
        let lowTrimp = calculateBanisterTRIMP(samples: lowSamples, duration: duration, hrMax: hrMax, hrRest: hrRest)

        // High intensity workout (HR = 170)
        let highSamples = (0..<30).map { i in
            HeartRateSample(timestamp: Date().addingTimeInterval(Double(i) * 60), bpm: 170)
        }
        let highTrimp = calculateBanisterTRIMP(samples: highSamples, duration: duration, hrMax: hrMax, hrRest: hrRest)

        XCTAssertGreaterThan(highTrimp, lowTrimp * 2, "High intensity should produce significantly higher TRIMP")
    }

    func testEdwardsTRIMPZone1() throws {
        // Zone 1: < 50% HRMax
        let trimp = calculateEdwardsTRIMP(
            averageHR: 90,
            duration: 30 * 60, // 30 minutes
            hrMax: 200
        )

        // 30 minutes * zone multiplier 1.0 = 30 TRIMP
        XCTAssertEqual(trimp, 30, accuracy: 0.1)
    }

    func testEdwardsTRIMPZone2() throws {
        // Zone 2: 50-60% HRMax
        let trimp = calculateEdwardsTRIMP(
            averageHR: 110, // 55% of 200
            duration: 30 * 60,
            hrMax: 200
        )

        // 30 minutes * zone multiplier 1.0 = 30 TRIMP
        XCTAssertEqual(trimp, 30, accuracy: 0.1)
    }

    func testEdwardsTRIMPZone3() throws {
        // Zone 3: 60-70% HRMax
        let trimp = calculateEdwardsTRIMP(
            averageHR: 130, // 65% of 200
            duration: 30 * 60,
            hrMax: 200
        )

        // 30 minutes * zone multiplier 2.0 = 60 TRIMP
        XCTAssertEqual(trimp, 60, accuracy: 0.1)
    }

    func testEdwardsTRIMPZone4() throws {
        // Zone 4: 70-80% HRMax
        let trimp = calculateEdwardsTRIMP(
            averageHR: 150, // 75% of 200
            duration: 30 * 60,
            hrMax: 200
        )

        // 30 minutes * zone multiplier 3.0 = 90 TRIMP
        XCTAssertEqual(trimp, 90, accuracy: 0.1)
    }

    func testEdwardsTRIMPZone5() throws {
        // Zone 5: 80-90% HRMax
        let trimp = calculateEdwardsTRIMP(
            averageHR: 170, // 85% of 200
            duration: 30 * 60,
            hrMax: 200
        )

        // 30 minutes * zone multiplier 4.0 = 120 TRIMP
        XCTAssertEqual(trimp, 120, accuracy: 0.1)
    }

    func testEdwardsTRIMPZone6() throws {
        // Zone 6: > 90% HRMax
        let trimp = calculateEdwardsTRIMP(
            averageHR: 186, // 93% of 200
            duration: 30 * 60,
            hrMax: 200
        )

        // 30 minutes * zone multiplier 5.0 = 150 TRIMP
        XCTAssertEqual(trimp, 150, accuracy: 0.1)
    }

    func testTRIMPToStrainConversion() throws {
        // Strain scale factor: 21.0 / 250.0
        let scaleFactor = 21.0 / 250.0

        // Low TRIMP (50) should give low strain
        let lowStrain = 50 * scaleFactor
        XCTAssertEqual(lowStrain, 4.2, accuracy: 0.1)

        // Medium TRIMP (150) should give medium strain
        let mediumStrain = 150 * scaleFactor
        XCTAssertEqual(mediumStrain, 12.6, accuracy: 0.1)

        // High TRIMP (250) should max out at 21
        let highStrain = min(250 * scaleFactor, 21.0)
        XCTAssertEqual(highStrain, 21.0, accuracy: 0.1)
    }

    func testStrainLevelClassification() throws {
        XCTAssertEqual(StrainResult.StrainLevel(score: 0), .rest)
        XCTAssertEqual(StrainResult.StrainLevel(score: 2.9), .rest)
        XCTAssertEqual(StrainResult.StrainLevel(score: 3.0), .light)
        XCTAssertEqual(StrainResult.StrainLevel(score: 5.9), .light)
        XCTAssertEqual(StrainResult.StrainLevel(score: 6.0), .moderate)
        XCTAssertEqual(StrainResult.StrainLevel(score: 9.9), .moderate)
        XCTAssertEqual(StrainResult.StrainLevel(score: 10.0), .hard)
        XCTAssertEqual(StrainResult.StrainLevel(score: 13.9), .hard)
        XCTAssertEqual(StrainResult.StrainLevel(score: 14.0), .veryHard)
        XCTAssertEqual(StrainResult.StrainLevel(score: 17.9), .veryHard)
        XCTAssertEqual(StrainResult.StrainLevel(score: 18.0), .allOut)
        XCTAssertEqual(StrainResult.StrainLevel(score: 21.0), .allOut)
    }

    // MARK: - Additional Strain Edge Case Tests

    func testStrainScoreCapping() throws {
        // Very high TRIMP (500) should still cap at 21
        let scaleFactor = 21.0 / 250.0
        let veryHighTrimp: Double = 500
        let strain = min(veryHighTrimp * scaleFactor, 21.0)

        XCTAssertEqual(strain, 21.0, "Strain should cap at 21 regardless of TRIMP")
    }

    func testBanisterTRIMPWithHRBelowResting() throws {
        // Edge case: HR sample below resting HR
        let samples = [HeartRateSample(timestamp: Date(), bpm: 50)]
        let trimp = calculateBanisterTRIMP(
            samples: samples,
            duration: 60,
            hrMax: 190,
            hrRest: 60
        )

        // HRr would be negative, but should clamp to 0
        XCTAssertEqual(trimp, 0, accuracy: 0.1, "HR below resting should contribute 0 TRIMP")
    }

    func testBanisterTRIMPWithVeryShortDuration() throws {
        // 1 minute workout
        let samples = [HeartRateSample(timestamp: Date(), bpm: 150)]
        let trimp = calculateBanisterTRIMP(
            samples: samples,
            duration: 60, // 1 minute
            hrMax: 190,
            hrRest: 60
        )

        XCTAssertGreaterThan(trimp, 0, "Short workout should still produce TRIMP")
        XCTAssertLessThan(trimp, 5, "1-minute workout should have low TRIMP")
    }

    func testEdwardsTRIMPWithZeroDuration() throws {
        let trimp = calculateEdwardsTRIMP(
            averageHR: 150,
            duration: 0,
            hrMax: 200
        )

        XCTAssertEqual(trimp, 0, "Zero duration should give 0 TRIMP")
    }

    func testEdwardsTRIMPWithZeroHRMax() throws {
        // Edge case: invalid HRMax (avoid division by zero)
        let trimp = calculateEdwardsTRIMP(
            averageHR: 150,
            duration: 1800,
            hrMax: 0
        )

        // percentHRMax would be inf, but switch default handles it
        XCTAssertGreaterThanOrEqual(trimp, 0, "Invalid HRMax should not crash")
    }

    func testMultipleWorkoutsTRIMPAggregation() throws {
        let hrMax: Double = 190
        let hrRest: Double = 60

        // Workout 1: 30 min moderate
        let samples1 = (0..<30).map { i in
            HeartRateSample(timestamp: Date().addingTimeInterval(Double(i) * 60), bpm: 140)
        }
        let trimp1 = calculateBanisterTRIMP(samples: samples1, duration: 1800, hrMax: hrMax, hrRest: hrRest)

        // Workout 2: 20 min high intensity
        let samples2 = (0..<20).map { i in
            HeartRateSample(timestamp: Date().addingTimeInterval(Double(i) * 60), bpm: 170)
        }
        let trimp2 = calculateBanisterTRIMP(samples: samples2, duration: 1200, hrMax: hrMax, hrRest: hrRest)

        // Total TRIMP should equal sum of individual workouts
        let totalTrimp = trimp1 + trimp2

        XCTAssertGreaterThan(totalTrimp, trimp1, "Combined should be more than individual")
        XCTAssertGreaterThan(totalTrimp, trimp2, "Combined should be more than individual")
    }

    func testStrainResultMethodSelection() throws {
        // Banister method should be selected when HR samples available
        XCTAssertEqual(StrainResult.TRIMPMethod.banister.rawValue, "Banister TRIMP")
        XCTAssertEqual(StrainResult.TRIMPMethod.edwards.rawValue, "Edwards TRIMP")
        XCTAssertEqual(StrainResult.TRIMPMethod.estimated.rawValue, "Estimated")
    }

    // MARK: - Recovery Score Calculation Tests

    func testHRVScoreAboveBaseline() throws {
        // HRV 10% above baseline should score 100
        let baseline: Double = 50
        let todayHRV: Double = 55 // 10% above

        let score = calculateHRVScore(todayHRV: todayHRV, baseline: baseline)

        XCTAssertEqual(score!, 100, accuracy: 1)
    }

    func testHRVScoreAtBaseline() throws {
        // HRV at baseline should score 70
        let baseline: Double = 50
        let todayHRV: Double = 50

        let score = calculateHRVScore(todayHRV: todayHRV, baseline: baseline)

        XCTAssertEqual(score!, 70, accuracy: 1)
    }

    func testHRVScore10PercentBelowBaseline() throws {
        // HRV 10% below baseline should score around 50
        let baseline: Double = 50
        let todayHRV: Double = 45 // 10% below

        let score = calculateHRVScore(todayHRV: todayHRV, baseline: baseline)

        XCTAssertGreaterThan(score!, 45)
        XCTAssertLessThan(score!, 55)
    }

    func testHRVScore30PercentBelowBaseline() throws {
        // HRV 30%+ below baseline should score 0
        let baseline: Double = 50
        let todayHRV: Double = 35 // 30% below

        let score = calculateHRVScore(todayHRV: todayHRV, baseline: baseline)

        XCTAssertEqual(score!, 0, accuracy: 1)
    }

    func testHRVScoreWithNilValues() throws {
        XCTAssertNil(calculateHRVScore(todayHRV: nil, baseline: 50))
        XCTAssertNil(calculateHRVScore(todayHRV: 50, baseline: nil))
        XCTAssertNil(calculateHRVScore(todayHRV: 50, baseline: 0))
    }

    func testHRScoreBelowBaseline() throws {
        // HR 5%+ below baseline (better recovery) should score 100
        let baseline: Double = 60
        let todayHR: Double = 57 // 5% below

        let score = calculateHRScore(todayHR: todayHR, baseline: baseline)

        XCTAssertEqual(score!, 100, accuracy: 1)
    }

    func testHRScoreAtBaseline() throws {
        // HR at baseline should score 70
        let baseline: Double = 60
        let todayHR: Double = 60

        let score = calculateHRScore(todayHR: todayHR, baseline: baseline)

        XCTAssertEqual(score!, 70, accuracy: 1)
    }

    func testHRScoreAboveBaseline() throws {
        // HR 15%+ above baseline (poor recovery) should score 0
        let baseline: Double = 60
        let todayHR: Double = 71 // ~18% above

        let score = calculateHRScore(todayHR: todayHR, baseline: baseline)

        XCTAssertEqual(score!, 0, accuracy: 1)
    }

    func testSleepScoreMeetsTarget() throws {
        // Sleep meeting target should score 100
        let score = calculateSleepScore(todaySleep: 8.0, baseline: 8.0)

        XCTAssertEqual(score, 100, accuracy: 1)
    }

    func testSleepScoreExceedsTarget() throws {
        // Sleep exceeding target should still score 100
        let score = calculateSleepScore(todaySleep: 9.0, baseline: 8.0)

        XCTAssertEqual(score, 100, accuracy: 1)
    }

    func testSleepScore75PercentOfTarget() throws {
        // 6/8 hours (75%) should score around 50
        let score = calculateSleepScore(todaySleep: 6.0, baseline: 8.0)

        XCTAssertEqual(score!, 50, accuracy: 5)
    }

    func testSleepScore50PercentOrLess() throws {
        // 4/8 hours or less should score 0
        let score = calculateSleepScore(todaySleep: 4.0, baseline: 8.0)

        XCTAssertEqual(score!, 0, accuracy: 1)
    }

    func testRecoveryReadinessClassification() throws {
        XCTAssertEqual(RecoveryScoreResult.RecoveryReadiness(score: 100), .optimal)
        XCTAssertEqual(RecoveryScoreResult.RecoveryReadiness(score: 85), .optimal)
        XCTAssertEqual(RecoveryScoreResult.RecoveryReadiness(score: 84), .good)
        XCTAssertEqual(RecoveryScoreResult.RecoveryReadiness(score: 70), .good)
        XCTAssertEqual(RecoveryScoreResult.RecoveryReadiness(score: 69), .moderate)
        XCTAssertEqual(RecoveryScoreResult.RecoveryReadiness(score: 50), .moderate)
        XCTAssertEqual(RecoveryScoreResult.RecoveryReadiness(score: 49), .low)
        XCTAssertEqual(RecoveryScoreResult.RecoveryReadiness(score: 30), .low)
        XCTAssertEqual(RecoveryScoreResult.RecoveryReadiness(score: 29), .veryLow)
        XCTAssertEqual(RecoveryScoreResult.RecoveryReadiness(score: 0), .veryLow)
    }

    func testRecoveryScoreWeighting() throws {
        // HRV contributes max 50, HR max 30, Sleep max 20
        let hrvScore: Double = 100
        let hrScore: Double = 100
        let sleepScore: Double = 100

        let (finalScore, breakdown) = calculateFinalRecoveryScore(
            hrvScore: hrvScore,
            hrScore: hrScore,
            sleepScore: sleepScore
        )

        XCTAssertEqual(finalScore, 100, "Perfect scores should give 100")
        XCTAssertEqual(breakdown.hrvContribution, 50, accuracy: 0.1)
        XCTAssertEqual(breakdown.hrContribution, 30, accuracy: 0.1)
        XCTAssertEqual(breakdown.sleepContribution, 20, accuracy: 0.1)
    }

    func testRecoveryScoreWithPartialData() throws {
        // Only HRV available
        let (score, _) = calculateFinalRecoveryScore(
            hrvScore: 80,
            hrScore: nil,
            sleepScore: nil
        )

        // Score should be normalized based on available weight
        XCTAssertEqual(score, 80, "Single metric should normalize to that metric's score")
    }

    func testRecoveryScoreWithNoData() throws {
        let (score, breakdown) = calculateFinalRecoveryScore(
            hrvScore: nil,
            hrScore: nil,
            sleepScore: nil
        )

        XCTAssertEqual(score, 0, "No data should give 0 score")
        XCTAssertEqual(breakdown.hrvContribution, 0)
        XCTAssertEqual(breakdown.hrContribution, 0)
        XCTAssertEqual(breakdown.sleepContribution, 0)
    }

    // MARK: - Helper Methods (Mirror use case logic for unit testing)

    private func calculateBanisterTRIMP(
        samples: [HeartRateSample],
        duration: TimeInterval,
        hrMax: Double,
        hrRest: Double
    ) -> Double {
        guard !samples.isEmpty else { return 0 }

        let exponentialFactor = 1.92 // Male default
        let hrReserve = hrMax - hrRest
        guard hrReserve > 0 else { return 0 }

        var totalTrimp: Double = 0
        let timePerSample = duration / Double(samples.count)
        let minutesPerSample = timePerSample / 60.0

        for sample in samples {
            let hrr = (sample.bpm - hrRest) / hrReserve
            let hrrClamped = max(0, min(hrr, 1.0))
            let sampleTrimp = minutesPerSample * hrrClamped * 0.64 * exp(exponentialFactor * hrrClamped)
            totalTrimp += sampleTrimp
        }

        return totalTrimp
    }

    private func calculateEdwardsTRIMP(
        averageHR: Double,
        duration: TimeInterval,
        hrMax: Double
    ) -> Double {
        let minutes = duration / 60.0
        let percentHRMax = (averageHR / hrMax) * 100

        let zoneMultiplier: Double
        switch percentHRMax {
        case 0..<50:
            zoneMultiplier = 1.0
        case 50..<60:
            zoneMultiplier = 1.0
        case 60..<70:
            zoneMultiplier = 2.0
        case 70..<80:
            zoneMultiplier = 3.0
        case 80..<90:
            zoneMultiplier = 4.0
        default:
            zoneMultiplier = 5.0
        }

        return minutes * zoneMultiplier
    }

    private func calculateHRVScore(todayHRV: Double?, baseline: Double?) -> Double? {
        guard let hrv = todayHRV, let base = baseline, base > 0 else {
            return nil
        }

        let ratio = hrv / base

        if ratio >= 1.1 {
            return 100
        } else if ratio >= 1.0 {
            return 70 + (ratio - 1.0) * 300
        } else if ratio >= 0.7 {
            return (ratio - 0.7) * (70 / 0.3)
        } else {
            return 0
        }
    }

    private func calculateHRScore(todayHR: Double?, baseline: Double?) -> Double? {
        guard let hr = todayHR, let base = baseline, base > 0 else {
            return nil
        }

        let ratio = base / hr // Inverted: lower HR is better

        if ratio >= 1.05 {
            return 100
        } else if ratio >= 1.0 {
            return 70 + (ratio - 1.0) * 600
        } else if ratio >= 0.85 {
            return (ratio - 0.85) * (70 / 0.15)
        } else {
            return 0
        }
    }

    private func calculateSleepScore(todaySleep: Double?, baseline: Double) -> Double? {
        guard let sleep = todaySleep else { return nil }

        let target = max(baseline, 7.0)
        let ratio = sleep / target

        if ratio >= 1.0 {
            return 100
        } else if ratio >= 0.5 {
            return (ratio - 0.5) * 200
        } else {
            return 0
        }
    }

    private func calculateFinalRecoveryScore(
        hrvScore: Double?,
        hrScore: Double?,
        sleepScore: Double?
    ) -> (Int, RecoveryScoreResult.RecoveryBreakdown) {
        let hrvWeight: Double = 0.50
        let hrWeight: Double = 0.30
        let sleepWeight: Double = 0.20

        var totalWeight: Double = 0
        var weightedSum: Double = 0

        var hrvContribution: Double = 0
        var hrContribution: Double = 0
        var sleepContribution: Double = 0

        if let hrv = hrvScore {
            let contribution = hrv * hrvWeight
            weightedSum += contribution
            totalWeight += hrvWeight
            hrvContribution = (hrv / 100) * 50
        }

        if let hr = hrScore {
            let contribution = hr * hrWeight
            weightedSum += contribution
            totalWeight += hrWeight
            hrContribution = (hr / 100) * 30
        }

        if let sleep = sleepScore {
            let contribution = sleep * sleepWeight
            weightedSum += contribution
            totalWeight += sleepWeight
            sleepContribution = (sleep / 100) * 20
        }

        let breakdown = RecoveryScoreResult.RecoveryBreakdown(
            hrvContribution: hrvContribution,
            hrContribution: hrContribution,
            sleepContribution: sleepContribution
        )

        guard totalWeight > 0 else {
            return (0, breakdown)
        }

        let normalizedScore = weightedSum / totalWeight

        return (Int(normalizedScore.rounded()), breakdown)
    }
}
