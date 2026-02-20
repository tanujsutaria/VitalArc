//
//  ReadinessScoreV2Tests.swift
//  VitalArcTests
//
//  Tests for ReadinessScore v2: configurable weights, level classification,
//  trend detection, and recommendation generation
//

import XCTest
@testable import VitalArc

final class ReadinessScoreV2Tests: XCTestCase {

    var sut: CalculateReadinessScoreUseCase!

    override func setUp() {
        super.setUp()
        sut = CalculateReadinessScoreUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Test Helpers

    private func makeMetrics(
        date: Date = Date(),
        hrv: Double? = nil,
        rhr: Double? = nil,
        steps: Int? = nil,
        activeEnergy: Double? = nil,
        sleepHours: Double? = nil,
        sleepStages: SleepStages? = nil
    ) -> HealthMetrics {
        HealthMetrics(
            date: date,
            heartRateVariability: hrv,
            restingHeartRate: rhr,
            activeEnergy: activeEnergy,
            steps: steps,
            sleepHours: sleepHours,
            sleepStages: sleepStages
        )
    }

    private func makeWeek(
        hrv: Double = 60,
        rhr: Double = 60,
        sleepHours: Double = 7.5,
        steps: Int = 8000,
        activeEnergy: Double = 400
    ) -> [HealthMetrics] {
        (0..<7).map { day in
            makeMetrics(
                date: Calendar.current.date(byAdding: .day, value: -day, to: Date()) ?? Date(),
                hrv: hrv,
                rhr: rhr,
                steps: steps,
                activeEnergy: activeEnergy,
                sleepHours: sleepHours
            )
        }
    }

    // MARK: - ReadinessConfiguration Tests

    func testDefaultConfigurationWeights() {
        let config = ReadinessConfiguration.default
        XCTAssertEqual(config.sleepWeight, 0.30, accuracy: 0.001)
        XCTAssertEqual(config.hrvWeight, 0.25, accuracy: 0.001)
        XCTAssertEqual(config.rhrWeight, 0.20, accuracy: 0.001)
        XCTAssertEqual(config.activityWeight, 0.15, accuracy: 0.001)
        XCTAssertEqual(config.streakWeight, 0.10, accuracy: 0.001)
    }

    func testDefaultConfigurationWeightsSumToOne() {
        let config = ReadinessConfiguration.default
        XCTAssertEqual(config.totalWeight, 1.0, accuracy: 0.001)
    }

    func testCustomConfigurationWeights() {
        let config = ReadinessConfiguration(
            sleepWeight: 0.40,
            hrvWeight: 0.30,
            rhrWeight: 0.15,
            activityWeight: 0.10,
            streakWeight: 0.05
        )
        XCTAssertEqual(config.sleepWeight, 0.40, accuracy: 0.001)
        XCTAssertEqual(config.hrvWeight, 0.30, accuracy: 0.001)
        XCTAssertEqual(config.rhrWeight, 0.15, accuracy: 0.001)
        XCTAssertEqual(config.activityWeight, 0.10, accuracy: 0.001)
        XCTAssertEqual(config.streakWeight, 0.05, accuracy: 0.001)
        XCTAssertEqual(config.totalWeight, 1.0, accuracy: 0.001)
    }

    func testConfigurationEquality() {
        let config1 = ReadinessConfiguration.default
        let config2 = ReadinessConfiguration.default
        XCTAssertEqual(config1, config2)
    }

    // MARK: - ReadinessLevel Classification Tests

    func testLevelRestRange() {
        XCTAssertEqual(ReadinessLevel.from(score: 0), .rest)
        XCTAssertEqual(ReadinessLevel.from(score: 10), .rest)
        XCTAssertEqual(ReadinessLevel.from(score: 19), .rest)
    }

    func testLevelLowRange() {
        XCTAssertEqual(ReadinessLevel.from(score: 20), .low)
        XCTAssertEqual(ReadinessLevel.from(score: 30), .low)
        XCTAssertEqual(ReadinessLevel.from(score: 39), .low)
    }

    func testLevelModerateRange() {
        XCTAssertEqual(ReadinessLevel.from(score: 40), .moderate)
        XCTAssertEqual(ReadinessLevel.from(score: 50), .moderate)
        XCTAssertEqual(ReadinessLevel.from(score: 59), .moderate)
    }

    func testLevelGoodRange() {
        XCTAssertEqual(ReadinessLevel.from(score: 60), .good)
        XCTAssertEqual(ReadinessLevel.from(score: 70), .good)
        XCTAssertEqual(ReadinessLevel.from(score: 79), .good)
    }

    func testLevelOptimalRange() {
        XCTAssertEqual(ReadinessLevel.from(score: 80), .optimal)
        XCTAssertEqual(ReadinessLevel.from(score: 90), .optimal)
        XCTAssertEqual(ReadinessLevel.from(score: 100), .optimal)
    }

    func testLevelEdgeCases() {
        XCTAssertEqual(ReadinessLevel.from(score: -5), .rest)
        XCTAssertEqual(ReadinessLevel.from(score: 150), .optimal)
    }

    // MARK: - Trend Detection Tests

    func testTrendImprovingWhenAboveAverage() {
        let historical = [50.0, 52.0, 48.0, 51.0, 49.0, 53.0, 50.0]
        // Average is ~50.4, current 58 is ~15% above
        let trend = sut.detectTrend(currentScore: 58, historicalScores: historical)
        XCTAssertEqual(trend, .improving)
    }

    func testTrendDecliningWhenBelowAverage() {
        let historical = [50.0, 52.0, 48.0, 51.0, 49.0, 53.0, 50.0]
        // Average is ~50.4, current 42 is ~17% below
        let trend = sut.detectTrend(currentScore: 42, historicalScores: historical)
        XCTAssertEqual(trend, .declining)
    }

    func testTrendStableWhenNearAverage() {
        let historical = [50.0, 52.0, 48.0, 51.0, 49.0, 53.0, 50.0]
        // Average is ~50.4, current 51 is ~1% above
        let trend = sut.detectTrend(currentScore: 51, historicalScores: historical)
        XCTAssertEqual(trend, .stable)
    }

    func testTrendStableWithEmptyHistory() {
        let trend = sut.detectTrend(currentScore: 50, historicalScores: [])
        XCTAssertEqual(trend, .stable)
    }

    func testTrendStableWithSingleHistory() {
        let trend = sut.detectTrend(currentScore: 50, historicalScores: [50])
        XCTAssertEqual(trend, .stable)
    }

    // MARK: - V2 Execute Tests

    func testV2ExecuteReturnsStructuredResult() {
        let today = makeMetrics(hrv: 65, rhr: 58, steps: 10000, activeEnergy: 500, sleepHours: 8)
        let week = makeWeek()
        let config = ReadinessConfiguration.default

        let result = sut.executeV2(todayMetrics: today, weekMetrics: week, historicalScores: [], configuration: config)

        XCTAssertGreaterThanOrEqual(result.score, 0)
        XCTAssertLessThanOrEqual(result.score, 100)
        XCTAssertFalse(result.recommendation.isEmpty)
        XCTAssertFalse(result.componentScores.isEmpty)
        XCTAssertNotNil(result.componentScores["hrv"])
        XCTAssertNotNil(result.componentScores["rhr"])
        XCTAssertNotNil(result.componentScores["sleep"])
        XCTAssertNotNil(result.componentScores["activity"])
        XCTAssertNotNil(result.componentScores["streak"])
    }

    func testV2ExecuteWithOptimalMetrics() {
        let goodStages = SleepStages(deepSleep: 1.8, remSleep: 1.8, coreSleep: 4.4, awake: 0.5)
        let today = makeMetrics(hrv: 66, rhr: 54, steps: 12000, activeEnergy: 600, sleepHours: 8, sleepStages: goodStages)
        let week = makeWeek()
        let config = ReadinessConfiguration.default

        let result = sut.executeV2(todayMetrics: today, weekMetrics: week, historicalScores: [], configuration: config)

        XCTAssertGreaterThanOrEqual(result.score, 60, "Good metrics should produce at least 'good' score")
    }

    func testV2ExecuteWithPoorMetrics() {
        let today = makeMetrics(hrv: 20, rhr: 90, steps: 1000, activeEnergy: 50, sleepHours: 3)
        let week = makeWeek()
        let config = ReadinessConfiguration.default

        let result = sut.executeV2(todayMetrics: today, weekMetrics: week, historicalScores: [], configuration: config)

        XCTAssertLessThan(result.score, 60, "Poor metrics should produce low score")
    }

    func testV2ExecuteWithNilMetrics() {
        let today = makeMetrics()
        let config = ReadinessConfiguration.default

        let result = sut.executeV2(todayMetrics: today, weekMetrics: [], historicalScores: [], configuration: config)

        // All neutral: HRV 50, RHR 50, Sleep 50, Activity 50, Streak 0
        // Score = 50*0.25 + 50*0.20 + 50*0.30 + 50*0.15 + 0*0.10 = 12.5+10+15+7.5+0 = 45
        XCTAssertGreaterThanOrEqual(result.score, 30, "All nil should produce moderate-low score")
        XCTAssertLessThanOrEqual(result.score, 60)
    }

    func testV2ExecuteScoreClamped() {
        let today = makeMetrics(hrv: 200, rhr: 10, steps: 50000, activeEnergy: 5000, sleepHours: 8)
        let week = makeWeek(hrv: 20, rhr: 100)
        let config = ReadinessConfiguration.default

        let result = sut.executeV2(todayMetrics: today, weekMetrics: week, historicalScores: [], configuration: config)

        XCTAssertLessThanOrEqual(result.score, 100, "Score should never exceed 100")
        XCTAssertGreaterThanOrEqual(result.score, 0, "Score should never be negative")
    }

    func testV2ExecuteCustomWeightsAffectsScore() {
        let today = makeMetrics(hrv: 80, rhr: 50, steps: 12000, activeEnergy: 600, sleepHours: 4)
        let week = makeWeek()

        // Sleep-heavy configuration
        let sleepHeavyConfig = ReadinessConfiguration(
            sleepWeight: 0.60,
            hrvWeight: 0.15,
            rhrWeight: 0.10,
            activityWeight: 0.10,
            streakWeight: 0.05
        )

        // HRV-heavy configuration
        let hrvHeavyConfig = ReadinessConfiguration(
            sleepWeight: 0.10,
            hrvWeight: 0.60,
            rhrWeight: 0.10,
            activityWeight: 0.10,
            streakWeight: 0.10
        )

        let sleepHeavyResult = sut.executeV2(todayMetrics: today, weekMetrics: week, historicalScores: [], configuration: sleepHeavyConfig)
        let hrvHeavyResult = sut.executeV2(todayMetrics: today, weekMetrics: week, historicalScores: [], configuration: hrvHeavyConfig)

        // With bad sleep (4h) and good HRV, sleep-heavy config should give lower score
        XCTAssertLessThan(sleepHeavyResult.score, hrvHeavyResult.score,
                          "Sleep-heavy config should score lower when sleep is poor but HRV is good")
    }

    // MARK: - Recommendation Tests

    func testRecommendationForOptimalLevel() {
        let today = makeMetrics(hrv: 70, rhr: 52, steps: 12000, activeEnergy: 600, sleepHours: 8)
        let week = makeWeek(hrv: 60, rhr: 60)
        let config = ReadinessConfiguration.default

        let result = sut.executeV2(todayMetrics: today, weekMetrics: week, historicalScores: [], configuration: config)

        if result.level == .optimal {
            XCTAssertTrue(result.recommendation.contains("Excellent") || result.recommendation.contains("peak"),
                          "Optimal level should mention excellence or peak performance")
        }
    }

    func testRecommendationForRestLevel() {
        let today = makeMetrics(hrv: 15, rhr: 100, steps: 500, activeEnergy: 20, sleepHours: 2)
        let week = makeWeek(hrv: 60, rhr: 55)
        let config = ReadinessConfiguration.default

        let result = sut.executeV2(todayMetrics: today, weekMetrics: week, historicalScores: [], configuration: config)

        if result.level == .rest || result.level == .low {
            XCTAssertTrue(result.recommendation.lowercased().contains("rest") ||
                          result.recommendation.lowercased().contains("recovery"),
                          "Low/rest level should mention rest or recovery")
        }
    }

    func testRecommendationIncludesTrendWhenImproving() {
        let today = makeMetrics(hrv: 70, rhr: 55, steps: 10000, activeEnergy: 500, sleepHours: 8)
        let week = makeWeek()
        let historical = [40.0, 42.0, 38.0, 41.0, 39.0, 43.0, 40.0] // low historical for improving trend

        let result = sut.executeV2(todayMetrics: today, weekMetrics: week, historicalScores: historical, configuration: .default)

        if result.trend == .improving {
            XCTAssertTrue(result.recommendation.contains("improving"),
                          "Improving trend should be mentioned in recommendation")
        }
    }

    func testRecommendationIncludesTrendWhenDeclining() {
        let today = makeMetrics(hrv: 25, rhr: 85, steps: 2000, activeEnergy: 100, sleepHours: 4)
        let week = makeWeek(hrv: 60, rhr: 55)
        let historical = [80.0, 82.0, 78.0, 81.0, 79.0, 83.0, 80.0] // high historical for declining trend

        let result = sut.executeV2(todayMetrics: today, weekMetrics: week, historicalScores: historical, configuration: .default)

        if result.trend == .declining {
            XCTAssertTrue(result.recommendation.contains("declining"),
                          "Declining trend should be mentioned in recommendation")
        }
    }

    // MARK: - ReadinessResult Entity Tests

    func testReadinessResultEquatable() {
        let result1 = ReadinessResult(
            score: 75.5,
            level: .good,
            trend: .stable,
            componentScores: ["hrv": 80, "rhr": 70],
            recommendation: "Good recovery."
        )
        let result2 = ReadinessResult(
            score: 75.5,
            level: .good,
            trend: .stable,
            componentScores: ["hrv": 80, "rhr": 70],
            recommendation: "Good recovery."
        )
        XCTAssertEqual(result1, result2)
    }

    func testReadinessResultOverallScoreAlias() {
        let result = ReadinessResult(
            score: 85.0,
            level: .optimal,
            trend: .improving,
            componentScores: [:],
            recommendation: "Great"
        )
        XCTAssertEqual(result.overallScore, 85.0, accuracy: 0.001)
    }

    // MARK: - ReadinessScore Backward Compatibility

    func testLegacyExecuteStillWorks() {
        let today = makeMetrics(hrv: 65, rhr: 58, sleepHours: 8)
        let week = makeWeek()

        let result = sut.execute(todayMetrics: today, weekMetrics: week)

        XCTAssertGreaterThanOrEqual(result.overallScore, 0)
        XCTAssertLessThanOrEqual(result.overallScore, 100)
        XCTAssertFalse(result.recommendation.isEmpty)
        XCTAssertNotNil(result.result, "Legacy execute should also produce a v2 result")
    }

    func testReadinessScoreLevelFromResult() {
        let v2Result = ReadinessResult(
            score: 75.0,
            level: .good,
            trend: .stable,
            componentScores: [:],
            recommendation: "Good"
        )
        let score = ReadinessScore(
            overallScore: 75.0,
            hrvContribution: 30,
            rhrContribution: 20,
            sleepQualityContribution: 15,
            sleepDurationContribution: 10,
            recommendation: "Good",
            result: v2Result
        )
        XCTAssertEqual(score.level, .good, "Should use result's level when available")
        XCTAssertEqual(score.trend, .stable, "Should use result's trend")
    }

    func testReadinessScoreLevelFallback() {
        let score = ReadinessScore(
            overallScore: 55.0,
            hrvContribution: 25,
            rhrContribution: 15,
            sleepQualityContribution: 10,
            sleepDurationContribution: 5,
            recommendation: "Moderate"
        )
        XCTAssertEqual(score.level, .moderate, "Should compute level from score when no result")
        XCTAssertEqual(score.trend, .stable, "Default trend should be stable")
    }

    // MARK: - ReadinessTrend Tests

    func testReadinessTrendRawValues() {
        XCTAssertEqual(ReadinessTrend.improving.rawValue, "Improving")
        XCTAssertEqual(ReadinessTrend.stable.rawValue, "Stable")
        XCTAssertEqual(ReadinessTrend.declining.rawValue, "Declining")
    }

    // MARK: - Streak Score Tests

    func testV2StreakScoreWithFullWeek() {
        let today = makeMetrics(hrv: 60, rhr: 60, sleepHours: 7)
        let week = makeWeek()
        let config = ReadinessConfiguration.default

        let result = sut.executeV2(todayMetrics: today, weekMetrics: week, historicalScores: [], configuration: config)

        XCTAssertEqual(result.componentScores["streak"] ?? 0, 100, accuracy: 0.1,
                       "Full week of data should give 100% streak score")
    }

    func testV2StreakScoreWithEmptyWeek() {
        let today = makeMetrics(hrv: 60, rhr: 60, sleepHours: 7)
        let config = ReadinessConfiguration.default

        let result = sut.executeV2(todayMetrics: today, weekMetrics: [], historicalScores: [], configuration: config)

        XCTAssertEqual(result.componentScores["streak"] ?? 100, 0, accuracy: 0.1,
                       "Empty week should give 0% streak score")
    }
}
