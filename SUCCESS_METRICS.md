# VitalArc Success Metrics

**Version**: 1.0
**Last Updated**: January 26, 2026

---

## Overview

This document defines the key metrics for measuring VitalArc's success during beta testing and post-launch. Metrics are categorized by phase and priority.

---

## Beta Testing Metrics

### Stability Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Crash-Free Sessions** | > 99% | Firebase Crashlytics |
| **App Launch Success** | > 99.5% | Crashlytics |
| **Background Recovery** | 100% no data loss | Manual testing |
| **Memory Warnings** | < 5 per session | Instruments |

### Engagement Metrics

| Metric | Target | Notes |
|--------|--------|-------|
| **Onboarding Completion** | > 80% | Users who start onboarding and finish |
| **Day 1 Retention** | > 60% | Users who return the next day |
| **Day 7 Retention** | > 40% | Users who return after 1 week |
| **Session Duration** | > 3 minutes | Average time in app |
| **Sessions per Week** | > 3 | For active users |

### Feature Adoption

| Feature | Target Usage | Priority |
|---------|--------------|----------|
| Log a workout | > 70% of users | P0 |
| Log food | > 50% of users | P0 |
| View analytics | > 40% of users | P1 |
| Create template | > 20% of users | P2 |
| Export data | > 10% of users | P2 |
| Send feedback | > 5% of users | P2 |

### Quality Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Feedback Sentiment** | > 70% positive | Manual review |
| **Bug Reports per User** | < 2 | Feedback tracking |
| **Critical Bugs** | 0 open | Bug tracker |
| **Feature Requests** | Track top 10 | Feedback analysis |

---

## Post-Launch Metrics (App Store)

### Acquisition

| Metric | Target | Timeframe |
|--------|--------|-----------|
| **Downloads** | 1,000 | First month |
| **Organic Installs** | > 50% | Ongoing |
| **App Store Rating** | > 4.5 stars | Ongoing |
| **Reviews** | > 50 | First month |

### Retention

| Metric | Target | Industry Benchmark |
|--------|--------|-------------------|
| **Day 1** | > 40% | 25% (fitness apps) |
| **Day 7** | > 20% | 12% (fitness apps) |
| **Day 30** | > 10% | 6% (fitness apps) |

### Engagement

| Metric | Target | Notes |
|--------|--------|-------|
| **Daily Active Users (DAU)** | Track | Baseline establishment |
| **Weekly Active Users (WAU)** | Track | Primary metric |
| **DAU/WAU Ratio** | > 30% | Stickiness indicator |
| **Workouts per Week** | > 2 | Per active user |
| **Foods Logged per Day** | > 3 | Per active user |

### Revenue (Future)

| Metric | Target | Notes |
|--------|--------|-------|
| **Premium Conversion** | > 5% | If premium tier added |
| **LTV** | > $20 | Lifetime value per user |
| **CAC** | < $5 | Cost to acquire user |

---

## Key Performance Indicators (KPIs)

### North Star Metric

**Weekly Active Workouts Logged**

*Rationale*: This metric directly correlates with user value. Users who log workouts are:
- Getting value from the app
- Building a habit
- Likely to retain long-term

### Supporting KPIs

1. **Workout Completion Rate**
   - Definition: % of started workouts that are completed
   - Target: > 85%
   - Why: Indicates app usability during workouts

2. **Data Entry Time**
   - Definition: Average time to log a workout set
   - Target: < 10 seconds per set
   - Why: Friction indicator

3. **Health Data Sync Rate**
   - Definition: % of users with HealthKit connected
   - Target: > 60%
   - Why: Enables recovery features

4. **Template Usage Rate**
   - Definition: % of workouts started from templates
   - Target: > 40%
   - Why: Indicates power user adoption

---

## Cohort Analysis Plan

### User Segments

| Segment | Definition | Tracking |
|---------|------------|----------|
| **New Users** | < 7 days since install | Onboarding completion, first workout |
| **Active Users** | Logged workout in last 7 days | Feature usage, retention |
| **Power Users** | > 3 workouts/week | Template usage, export usage |
| **At-Risk Users** | No activity in 7+ days | Re-engagement triggers |
| **Churned Users** | No activity in 30+ days | Win-back potential |

### Cohort Questions

1. Do users who complete onboarding HealthKit have better retention?
2. Do users who create templates stay longer?
3. What's the activation event that predicts long-term retention?
4. How does workout frequency correlate with nutrition logging?

---

## Instrumentation Requirements

### Events to Track

#### Onboarding
```
onboarding_started
onboarding_profile_completed
onboarding_healthkit_granted
onboarding_healthkit_skipped
onboarding_completed
```

#### Workouts
```
workout_started
workout_exercise_added
workout_set_logged
workout_completed
workout_cancelled
workout_from_template
```

#### Nutrition
```
food_search_initiated
food_search_completed
food_barcode_scanned
food_logged
food_deleted
```

#### Analytics
```
analytics_viewed
analytics_time_range_changed
export_pdf_initiated
export_csv_initiated
export_completed
```

#### Settings
```
feedback_initiated
feedback_sent
healthkit_sync_initiated
units_toggled
```

### User Properties

```
onboarding_completed: boolean
healthkit_connected: boolean
unit_preference: string (metric/imperial)
workouts_logged_total: number
days_since_install: number
app_version: string
```

---

## Reporting Cadence

| Report | Frequency | Audience |
|--------|-----------|----------|
| Daily Stability | Daily | Development team |
| Weekly Metrics | Weekly | Product team |
| Monthly Review | Monthly | Stakeholders |
| Cohort Analysis | Monthly | Product team |

---

## Success Criteria by Phase

### Phase 1: Alpha (Internal)
- [ ] App launches without crash
- [ ] All P0 features functional
- [ ] < 5 critical bugs

### Phase 2: Closed Beta (10-50 users)
- [ ] Crash-free rate > 95%
- [ ] Onboarding completion > 70%
- [ ] Positive feedback > 60%
- [ ] No data loss incidents

### Phase 3: Open Beta (100+ users)
- [ ] Crash-free rate > 99%
- [ ] Day 7 retention > 30%
- [ ] App Store ready (no blocking bugs)
- [ ] Performance targets met

### Phase 4: Public Launch
- [ ] App Store approval
- [ ] 4.0+ star rating maintained
- [ ] Crash-free rate > 99.5%
- [ ] Support response < 24 hours

---

## Tools & Infrastructure

### Required for Beta
| Tool | Purpose | Status |
|------|---------|--------|
| Firebase Crashlytics | Crash reporting | ❌ Not configured |
| TestFlight | Beta distribution | ❌ Not configured |
| In-app Feedback | User feedback | ✅ Implemented |

### Recommended for Launch
| Tool | Purpose | Priority |
|------|---------|----------|
| Mixpanel/Amplitude | Analytics | High |
| App Store Connect | Store analytics | Required |
| Customer.io | Email engagement | Medium |
| Intercom/Zendesk | Support | Medium |

---

## Metric Definitions

### Retention Calculation
```
Day N Retention = (Users active on day N) / (Users who installed N days ago) × 100
```

### Crash-Free Rate
```
Crash-Free Rate = (Sessions without crash) / (Total sessions) × 100
```

### DAU/WAU Ratio (Stickiness)
```
Stickiness = DAU / WAU × 100
```

### Activation Rate
```
Activation Rate = (Users who completed activation event) / (Total installs) × 100
```

*Activation Event*: Logging first complete workout

---

## Review Schedule

- **Weekly**: Review crash reports, critical bugs
- **Bi-weekly**: Review engagement metrics, feedback sentiment
- **Monthly**: Full metrics review, cohort analysis
- **Quarterly**: Strategy review based on metrics

---

## Notes

- All metrics should be tracked anonymously where possible
- Comply with App Tracking Transparency (ATT) requirements
- User consent required for analytics in EU (GDPR)
- Document any metric definition changes
