# VitalArc - Product Requirements Document

## Executive Summary

VitalArc is a comprehensive iOS fitness platform that unifies workout tracking, nutrition management, and health analytics into a single, intelligent application. By combining the best features of RP Hypertrophy, MacroFactor, and Athlytic/Bevel, VitalArc eliminates the need for multiple subscriptions while providing deeper insights through cross-domain data analysis.

## Problem Statement

Fitness enthusiasts currently need 3+ separate apps to:
1. Track workouts with intelligent progression (RP Hypertrophy - $300/year)
2. Monitor nutrition with adaptive algorithms (MacroFactor - $72/year)
3. Analyze recovery and readiness (Athlytic - $30/year or Bevel - $60/year)

**Total cost: $400-460/year** with no data integration between apps.

## Solution

A unified platform that:
- Provides all three feature sets in one app
- Connects workout, nutrition, and recovery data for holistic insights
- Uses AI to optimize training, eating, and recovery timing
- Leverages Apple Health as the central data hub

## Target Users

### Primary Persona: "Optimized Alex"
- Age: 25-40
- Trains 4-6x/week with specific hypertrophy or strength goals
- Tracks macros and adjusts nutrition based on goals
- Owns Apple Watch and values data-driven decisions
- Currently uses 2-3 fitness apps
- Willing to pay for premium features

### Secondary Persona: "Aspiring Athlete"
- Age: 18-30
- Newer to structured training
- Wants guidance on workout programming
- Learning about nutrition and recovery
- Price-sensitive but values quality

## Feature Requirements

---

## Module 1: Workout Tracking

### 1.1 Exercise Library
**Priority: P0 (Must Have)**

| Requirement | Description |
|-------------|-------------|
| Exercise database | 500+ exercises with muscle group mapping |
| Custom exercises | Users can add custom exercises |
| Exercise search | Search by name, muscle group, equipment |
| Exercise details | Instructions, video links, muscle activation map |
| Equipment filters | Filter by available equipment |

### 1.2 Mesocycle Management
**Priority: P0**

| Requirement | Description |
|-------------|-------------|
| Mesocycle creation | Create 4-6 week training blocks |
| Template library | Pre-built mesocycle templates (PPL, Upper/Lower, etc.) |
| Custom meso builder | Select muscles to emphasize/maintain/ignore |
| Deload scheduling | Automatic deload week programming |
| Mesocycle history | View and repeat past mesocycles |

### 1.3 Workout Logging
**Priority: P0**

| Requirement | Description |
|-------------|-------------|
| Set logging | Log weight, reps, RIR for each set |
| Rest timer | Configurable rest timer between sets |
| Exercise swapping | Swap exercises mid-workout |
| Superset support | Group exercises into supersets |
| Workout notes | Add notes to workouts and exercises |
| Workout duration | Track total workout time |

### 1.4 Progression System
**Priority: P0**

| Requirement | Description |
|-------------|-------------|
| RIR targets | Weekly RIR progression (4→3→2→1) |
| Weight progression | Automatic weight increase suggestions |
| Rep fallback | Add reps when weight can't increase |
| Volume progression | MEV→MRV set progression over mesocycle |
| Performance tracking | Track estimated 1RM over time |

### 1.5 Feedback & Autoregulation
**Priority: P0**

| Requirement | Description |
|-------------|-------------|
| Post-workout feedback | Rate pump, soreness, workload, performance |
| Volume adjustment | Adjust next workout based on feedback |
| Fatigue detection | Detect approaching MRV |
| Recovery integration | Factor recovery score into recommendations |

### 1.6 Analytics
**Priority: P1 (Should Have)**

| Requirement | Description |
|-------------|-------------|
| Volume charts | Weekly volume by muscle group |
| Strength progression | Track estimated 1RM trends |
| Workout frequency | Training frequency heatmap |
| Muscle balance | Identify imbalances in training |

---

## Module 2: Nutrition Tracking

### 2.1 Food Database
**Priority: P0**

| Requirement | Description |
|-------------|-------------|
| Food database | Integration with USDA/Open Food Facts databases |
| Barcode scanning | Scan packaged food barcodes |
| Custom foods | Create and save custom foods |
| Recent foods | Quick access to recently logged foods |
| Frequent foods | Quick access to frequently logged foods |

### 2.2 Food Logging
**Priority: P0**

| Requirement | Description |
|-------------|-------------|
| Timeline logging | Time-based food log (not meal buckets) |
| Quick add | Add calories/macros directly |
| Copy/paste | Copy meals between days |
| Meal templates | Save and reuse meal combinations |
| Recipe builder | Create recipes from ingredients |

### 2.3 AI Food Logging
**Priority: P1**

| Requirement | Description |
|-------------|-------------|
| Photo logging | Take photo to log food |
| Voice logging | Describe food via voice |
| Natural language | Type natural language food descriptions |
| AI breakdown | Break complex meals into ingredients |

### 2.4 Adaptive Algorithm
**Priority: P0**

| Requirement | Description |
|-------------|-------------|
| Expenditure calculation | Calculate TDEE from intake + weight data |
| Trend weight | Calculate trend weight from daily weigh-ins |
| Weekly adjustment | Recommend calorie/macro changes weekly |
| Goal tracking | Track progress toward weight goals |
| Rate of change | Configurable weight change rate |

### 2.5 Program Modes
**Priority: P0**

| Requirement | Description |
|-------------|-------------|
| Coached mode | Fully automated macro recommendations |
| Collaborative mode | User sets macros, app adjusts calories |
| Manual mode | Full user control |
| Goal types | Cut, bulk, maintain, recomp |
| Diet structures | Balanced, low-fat, low-carb, keto options |

### 2.6 Micronutrients
**Priority: P2 (Nice to Have)**

| Requirement | Description |
|-------------|-------------|
| Micronutrient tracking | Track vitamins, minerals, etc. |
| Nutrient goals | RDA-based goals with thresholds |
| Deficiency alerts | Alert when nutrients consistently low |

---

## Module 3: Health Analytics

### 3.1 Data Collection
**Priority: P0**

| Requirement | Description |
|-------------|-------------|
| HRV reading | Read HRV from HealthKit (SDNN/RMSSD) |
| RHR reading | Read resting heart rate from HealthKit |
| Sleep data | Read sleep stages and duration |
| Workout data | Read/write workout data |
| Weight sync | Sync weight data bidirectionally |
| Steps/activity | Read daily activity metrics |

### 3.2 Recovery Score
**Priority: P0**

| Requirement | Description |
|-------------|-------------|
| Recovery calculation | Calculate 0-100% recovery score |
| HRV baseline | 60-day rolling HRV baseline |
| RHR baseline | 60-day rolling RHR baseline |
| Recovery history | View recovery score trends |
| Recovery factors | Show contributing factors |

### 3.3 Strain/Exertion
**Priority: P0**

| Requirement | Description |
|-------------|-------------|
| Strain calculation | Calculate daily strain (0-100 or 0-10) |
| HR zone tracking | Track time in each HR zone |
| TRIMP calculation | Training impulse methodology |
| Active vs passive | Distinguish workout vs daily strain |
| Target strain | Recommend daily strain based on recovery |

### 3.4 Sleep Analysis
**Priority: P1**

| Requirement | Description |
|-------------|-------------|
| Sleep score | Calculate sleep quality score |
| Sleep stages | Analyze REM, deep, light sleep |
| Sleep debt | Track accumulated sleep debt |
| Sleep consistency | Track bedtime/wake consistency |
| Sleep recommendations | Recommend target sleep and bedtime |

### 3.5 Training Load
**Priority: P1**

| Requirement | Description |
|-------------|-------------|
| Acute load (ATL) | 7-day exponential moving average |
| Chronic load (CTL) | 42-day exponential moving average |
| Training status | Detraining/Maintaining/Productive/Peaking/Overtraining |
| Load visualization | Chart showing ATL vs CTL over time |

---

## Module 4: Unified Intelligence

### 4.1 Cross-Domain Insights
**Priority: P1**

| Requirement | Description |
|-------------|-------------|
| Correlation detection | Find correlations between metrics |
| Pattern recognition | Identify patterns affecting performance |
| Insight generation | Generate actionable insights |
| Trend analysis | Analyze long-term trends |

### 4.2 AI Recommendations
**Priority: P1**

| Requirement | Description |
|-------------|-------------|
| Training timing | Recommend optimal workout timing |
| Nutrition timing | Recommend meal timing around workouts |
| Recovery actions | Suggest recovery-boosting actions |
| Goal optimization | Adjust goals based on progress patterns |

### 4.3 Predictive Analytics
**Priority: P2**

| Requirement | Description |
|-------------|-------------|
| Performance prediction | Predict workout performance |
| Weight prediction | Predict weight trajectory |
| Recovery prediction | Predict next-day recovery |
| Plateau detection | Detect and address plateaus |

---

## Module 5: Social Features

### 5.1 Progress Sharing
**Priority: P2**

| Requirement | Description |
|-------------|-------------|
| Progress photos | Take and store progress photos |
| Share workouts | Share workout summaries |
| Share achievements | Share milestones and PRs |
| Privacy controls | Granular sharing permissions |

### 5.2 Community
**Priority: P3 (Future)**

| Requirement | Description |
|-------------|-------------|
| Friends | Add and follow friends |
| Challenges | Create/join fitness challenges |
| Leaderboards | Compete on various metrics |
| Groups | Join interest-based groups |

---

## Module 6: Platform Features

### 6.1 Apple Watch App
**Priority: P1**

| Requirement | Description |
|-------------|-------------|
| Workout logging | Log sets from watch |
| Recovery display | View recovery score |
| Strain display | View current strain |
| Complications | Watch face complications |

### 6.2 Widgets
**Priority: P2**

| Requirement | Description |
|-------------|-------------|
| Recovery widget | Show current recovery |
| Today's workout | Show scheduled workout |
| Macro progress | Show daily macro progress |
| Streak widget | Show training streak |

### 6.3 Notifications
**Priority: P1**

| Requirement | Description |
|-------------|-------------|
| Workout reminders | Remind to complete scheduled workouts |
| Logging reminders | Remind to log meals |
| Weigh-in reminders | Remind to log weight |
| Insight notifications | Push important insights |

---

## Non-Functional Requirements

### Performance
- App launch: < 2 seconds
- Screen transitions: < 300ms
- Workout logging: < 100ms response
- Sync latency: < 5 seconds to cloud

### Reliability
- Offline support: Full functionality without internet
- Data sync: Automatic conflict resolution
- Crash rate: < 0.1%

### Security
- Data encryption: AES-256 at rest
- Transport: TLS 1.3
- Authentication: Sign in with Apple, biometrics
- Privacy: No data sold, GDPR compliant

### Accessibility
- VoiceOver support
- Dynamic Type support
- High contrast mode
- Reduced motion support

---

## Success Metrics

### Engagement
- DAU/MAU ratio > 50%
- Average session length > 5 minutes
- Workout completion rate > 80%
- Food logging consistency > 70%

### Retention
- Day 1 retention > 60%
- Day 7 retention > 40%
- Day 30 retention > 25%

### Quality
- App Store rating > 4.5 stars
- NPS score > 50
- Support tickets < 1% of users/month

---

## Monetization (Future)

### Freemium Model
**Free Tier:**
- Basic workout logging (no mesocycles)
- Manual calorie tracking
- View HealthKit data (no scores)

**Premium Tier ($9.99/month or $79.99/year):**
- Full mesocycle and progression system
- Adaptive nutrition algorithm
- Recovery and strain scores
- AI insights and recommendations
- Cloud sync and backup
- Priority support

---

## Appendix

### Competitive Analysis

| Feature | VitalArc | RP Hypertrophy | MacroFactor | Athlytic |
|---------|----------|----------------|-------------|----------|
| Mesocycles | ✅ | ✅ | ❌ | ❌ |
| RIR Tracking | ✅ | ✅ | ❌ | ❌ |
| Adaptive TDEE | ✅ | ❌ | ✅ | ❌ |
| AI Food Logging | ✅ | ❌ | ✅ | ❌ |
| Recovery Score | ✅ | ❌ | ❌ | ✅ |
| Strain Tracking | ✅ | ❌ | ❌ | ✅ |
| Cross-Domain AI | ✅ | ❌ | ❌ | ❌ |
| Offline Support | ✅ | ❌ | ✅ | ✅ |
| Price/Year | $80 | $300 | $72 | $30 |

### References
- [RP Hypertrophy Methodology](https://rpstrength.com/blogs/articles/training-volume-landmarks-muscle-growth)
- [MacroFactor Algorithm](https://macrofactorapp.com/expenditure-v3/)
- [Athlytic Recovery](https://athlyticapp.helpscoutdocs.com/article/21-recovery-preferences)
- [Apple HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
