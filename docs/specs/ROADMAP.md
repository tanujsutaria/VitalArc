# VitalArc - Development Roadmap

## Overview

This roadmap outlines a 24-week development plan for VitalArc, organized into 6 phases. Each phase builds upon the previous, delivering incremental value while maintaining a solid technical foundation.

---

## Timeline Summary

| Phase | Name | Weeks | Key Deliverables |
|-------|------|-------|------------------|
| 1 | Foundation | 1-4 | Project setup, HealthKit, data layer, basic UI |
| 2 | Workout Engine | 5-8 | Mesocycles, workout logging, progression |
| 3 | Nutrition System | 9-12 | Food logging, adaptive algorithm, goals |
| 4 | Health Analytics | 13-16 | Recovery, strain, sleep analysis |
| 5 | Intelligence Layer | 17-20 | Cross-domain insights, AI recommendations |
| 6 | Social & Polish | 21-24 | Social features, watchOS, widgets, launch prep |

---

## Phase 1: Foundation (Weeks 1-4)

### Goals
- Establish project architecture and coding standards
- Implement HealthKit integration
- Create core data models and persistence layer
- Build basic navigation and UI framework

### Week 1: Project Setup

**Tasks:**
- [ ] Create Xcode project with proper structure
- [ ] Configure SwiftData schema and container
- [ ] Set up dependency injection container
- [ ] Configure logging and error handling
- [ ] Set up Git repository with branch strategy
- [ ] Create CI/CD pipeline (GitHub Actions)
- [ ] Add SwiftLint and code formatting

**Deliverables:**
- Empty app that compiles and runs
- Project structure matching architecture doc
- Basic CI running on push

### Week 2: HealthKit Integration

**Tasks:**
- [ ] Implement HealthKitManager with all permissions
- [ ] Add authorization flow and UI
- [ ] Implement heart rate reading
- [ ] Implement HRV reading (SDNN and RMSSD calculation)
- [ ] Implement resting heart rate reading
- [ ] Implement sleep data reading
- [ ] Implement weight reading/writing
- [ ] Add background delivery setup

**Deliverables:**
- HealthKit permissions working
- Can read/display all health metrics
- Unit tests for HRV calculation

### Week 3: Data Layer

**Tasks:**
- [ ] Implement all SwiftData models
- [ ] Create repository protocols and implementations
- [ ] Implement CloudKit sync setup
- [ ] Create data mappers (Entity ↔ Model)
- [ ] Implement offline-first data flow
- [ ] Add data migration strategy

**Deliverables:**
- All models persisting correctly
- Data survives app restart
- Basic CloudKit sync working

### Week 4: Core UI Framework

**Tasks:**
- [ ] Create main tab navigation
- [ ] Build reusable UI components (cards, charts, buttons)
- [ ] Implement theming/design system
- [ ] Create loading, error, and empty states
- [ ] Build settings screen skeleton
- [ ] Add onboarding flow skeleton

**Deliverables:**
- App navigates between main tabs
- Consistent visual design
- Onboarding collects basic info

### Phase 1 Milestone
**Demo:** App shows HealthKit data on dashboard, persists user preferences, syncs to iCloud.

---

## Phase 2: Workout Engine (Weeks 5-8)

### Goals
- Implement complete workout tracking system
- Build mesocycle creation and management
- Add RIR-based progression algorithms
- Create feedback collection and volume autoregulation

### Week 5: Exercise Library

**Tasks:**
- [ ] Import exercise database (JSON)
- [ ] Build exercise search and filtering
- [ ] Create exercise detail view
- [ ] Implement custom exercise creation
- [ ] Add muscle group visualization
- [ ] Build exercise selection flow

**Deliverables:**
- Searchable exercise library
- Can create custom exercises
- Exercise shows muscle groups worked

### Week 6: Mesocycle Management

**Tasks:**
- [ ] Build mesocycle creation wizard
- [ ] Implement template selection
- [ ] Create custom meso builder (muscle priorities)
- [ ] Add workout scheduling logic
- [ ] Build mesocycle detail/overview view
- [ ] Implement mesocycle editing

**Deliverables:**
- Can create mesocycle from template
- Can customize muscle emphasis
- Workouts auto-scheduled

### Week 7: Workout Logging

**Tasks:**
- [ ] Build active workout screen
- [ ] Implement set logging (weight/reps/RIR)
- [ ] Add rest timer with haptics
- [ ] Create exercise swapping mid-workout
- [ ] Implement superset support
- [ ] Add workout notes
- [ ] Save completed workouts to HealthKit

**Deliverables:**
- Full workout logging flow
- Rest timer working
- Workouts saved to Apple Health

### Week 8: Progression System

**Tasks:**
- [ ] Implement RIR-based weight progression
- [ ] Add rep fallback logic
- [ ] Build feedback collection screen
- [ ] Implement volume autoregulation algorithm
- [ ] Create estimated 1RM tracking
- [ ] Add weekly RIR progression
- [ ] Implement deload detection/scheduling

**Deliverables:**
- App suggests next workout weights
- Feedback affects future volume
- 1RM trends visible

### Phase 2 Milestone
**Demo:** Complete workout from mesocycle, log sets with progression suggestions, see volume adjustments based on feedback.

---

## Phase 3: Nutrition System (Weeks 9-12)

### Goals
- Build food logging system with database
- Implement adaptive TDEE algorithm
- Create macro recommendation engine
- Add weekly check-in and adjustment flow

### Week 9: Food Database

**Tasks:**
- [ ] Integrate food database API (Open Food Facts/USDA)
- [ ] Build food search interface
- [ ] Implement barcode scanning
- [ ] Create custom food entry
- [ ] Add frequently/recently used foods
- [ ] Build nutrition facts display

**Deliverables:**
- Can search and find foods
- Barcode scanning works
- Nutrition info displays correctly

### Week 10: Food Logging

**Tasks:**
- [ ] Build timeline-based food log
- [ ] Implement serving size adjustment
- [ ] Add copy/paste meals between days
- [ ] Create meal templates/recipes
- [ ] Build daily macro summary view
- [ ] Add quick-add calories/macros

**Deliverables:**
- Can log full day of eating
- Copy meals between days
- See daily totals

### Week 11: Adaptive Algorithm

**Tasks:**
- [ ] Implement trend weight calculation
- [ ] Build TDEE estimation algorithm
- [ ] Create calorie/macro recommendation engine
- [ ] Implement program modes (Coached/Collaborative/Manual)
- [ ] Add goal setting (cut/bulk/maintain)
- [ ] Build expenditure visualization

**Deliverables:**
- Algorithm calculates TDEE from data
- Recommendations adjust based on progress
- Different modes work correctly

### Week 12: Weekly Check-in

**Tasks:**
- [ ] Build weekly check-in flow
- [ ] Implement adjustment recommendations
- [ ] Create compliance tracking
- [ ] Add weight logging reminders
- [ ] Build nutrition insights/trends
- [ ] Implement micronutrient basics

**Deliverables:**
- Weekly check-in prompts user
- Recommendations make sense
- Can track compliance over time

### Phase 3 Milestone
**Demo:** Log food for a week, see adaptive calorie recommendations, complete weekly check-in with adjustments.

---

## Phase 4: Health Analytics (Weeks 13-16)

### Goals
- Implement recovery score calculation
- Build strain/exertion tracking
- Create sleep analysis system
- Add training load monitoring

### Week 13: Recovery Score

**Tasks:**
- [ ] Implement HRV baseline calculation
- [ ] Build RHR baseline calculation
- [ ] Create recovery score algorithm
- [ ] Build recovery dashboard
- [ ] Add recovery history chart
- [ ] Implement recovery factors breakdown

**Deliverables:**
- Daily recovery score displayed
- Score based on HRV/RHR vs baseline
- Can see recovery trends

### Week 14: Strain Tracking

**Tasks:**
- [ ] Implement TRIMP calculation
- [ ] Build heart rate zone tracking
- [ ] Create daily strain aggregation
- [ ] Add workout strain breakdown
- [ ] Implement target strain recommendations
- [ ] Build strain vs recovery visualization

**Deliverables:**
- Daily strain score calculated
- HR zones tracked during workouts
- Target strain based on recovery

### Week 15: Sleep Analysis

**Tasks:**
- [ ] Build sleep score calculation
- [ ] Implement sleep stage analysis
- [ ] Create sleep debt tracking
- [ ] Add sleep consistency metrics
- [ ] Build sleep dashboard
- [ ] Implement sleep recommendations

**Deliverables:**
- Sleep score calculated nightly
- Sleep stages visualized
- Sleep debt tracked over time

### Week 16: Training Load

**Tasks:**
- [ ] Implement ATL/CTL calculation
- [ ] Build training status classification
- [ ] Create load visualization (fitness/fatigue)
- [ ] Add ramp rate tracking
- [ ] Implement overtraining warnings
- [ ] Build training calendar heatmap

**Deliverables:**
- ATL/CTL chart working
- Training status displayed
- Warnings for overtraining

### Phase 4 Milestone
**Demo:** Full health dashboard showing recovery, strain, sleep, and training load with recommendations.

---

## Phase 5: Intelligence Layer (Weeks 17-20)

### Goals
- Build cross-domain correlation detection
- Implement AI-powered recommendations
- Create predictive analytics
- Add personalized insights

### Week 17: Correlation Engine

**Tasks:**
- [ ] Implement correlation calculation
- [ ] Build data aggregation for analysis
- [ ] Create correlation significance testing
- [ ] Add correlation visualization
- [ ] Implement pattern detection
- [ ] Build insights from correlations

**Deliverables:**
- Correlations detected across domains
- Statistically significant patterns shown
- Insights generated from data

### Week 18: Recommendation System

**Tasks:**
- [ ] Build recommendation engine framework
- [ ] Implement training recommendations
- [ ] Add nutrition recommendations
- [ ] Create recovery recommendations
- [ ] Implement timing recommendations
- [ ] Add recommendation prioritization

**Deliverables:**
- Daily recommendations generated
- Recommendations personalized
- Priority ordering makes sense

### Week 19: Predictive Features

**Tasks:**
- [ ] Build weight trajectory prediction
- [ ] Implement performance prediction
- [ ] Create recovery prediction
- [ ] Add plateau detection
- [ ] Build "what if" scenario modeling
- [ ] Implement goal timeline prediction

**Deliverables:**
- Predictions shown on relevant screens
- Accuracy improves over time
- Plateau alerts working

### Week 20: AI Integration

**Tasks:**
- [ ] Integrate on-device LLM for insights
- [ ] Build natural language insight generation
- [ ] Create AI-powered food logging (photo/voice)
- [ ] Add conversational interface prototype
- [ ] Implement personalized coaching messages
- [ ] Build AI feedback on workouts

**Deliverables:**
- AI generates readable insights
- Photo food logging working
- Coaching feels personalized

### Phase 5 Milestone
**Demo:** AI-generated daily briefing with cross-domain insights, predictions, and personalized recommendations.

---

## Phase 6: Social & Polish (Weeks 21-24)

### Goals
- Add social features and sharing
- Build watchOS companion app
- Create widgets
- Polish UI and prepare for launch

### Week 21: Social Features

**Tasks:**
- [ ] Build user profile with achievements
- [ ] Implement progress photo capture/storage
- [ ] Create workout sharing
- [ ] Add PR/milestone sharing
- [ ] Build friend connections (future prep)
- [ ] Implement privacy controls

**Deliverables:**
- Can capture progress photos
- Can share workouts externally
- Privacy controls working

### Week 22: Apple Watch App

**Tasks:**
- [ ] Create watchOS app target
- [ ] Build workout logging on watch
- [ ] Add recovery/strain glance
- [ ] Implement complications
- [ ] Create workout controls
- [ ] Build watch ↔ phone sync

**Deliverables:**
- Watch app runs independently
- Can log sets from watch
- Complications show key metrics

### Week 23: Widgets & Notifications

**Tasks:**
- [ ] Build home screen widgets (small, medium, large)
- [ ] Create lock screen widgets
- [ ] Implement smart notifications
- [ ] Add workout reminders
- [ ] Create insight notifications
- [ ] Build notification preferences

**Deliverables:**
- Widgets available on home screen
- Notifications well-timed
- User can customize notification preferences

### Week 24: Launch Preparation

**Tasks:**
- [ ] Performance optimization pass
- [ ] Accessibility audit and fixes
- [ ] Localization setup (English first)
- [ ] App Store assets (screenshots, description)
- [ ] Privacy policy and terms
- [ ] Beta testing (TestFlight)
- [ ] Bug fixes from beta feedback

**Deliverables:**
- App passes App Store review
- Performance targets met
- Ready for public beta

### Phase 6 Milestone
**Demo:** Full app with watch companion, widgets, social sharing, ready for TestFlight beta.

---

## Post-Launch Roadmap

### Version 1.1 (Month 2)
- Additional exercise video content
- Enhanced AI food recognition
- Apple Watch standalone workouts
- iPad support

### Version 1.2 (Month 3)
- Challenges and competitions
- Friend leaderboards
- Enhanced analytics exports
- Siri Shortcuts integration

### Version 2.0 (Month 6)
- Full social platform
- Coach/client features
- Team/gym management
- API for third-party integrations

---

## Risk Mitigation

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| HealthKit data gaps | Medium | High | Graceful degradation, show partial data |
| Algorithm accuracy | Medium | High | Conservative estimates, user feedback loop |
| Performance issues | Low | Medium | Regular profiling, lazy loading |
| CloudKit sync conflicts | Medium | Medium | Conflict resolution strategy |

### Schedule Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Feature creep | High | High | Strict scope management, MVP focus |
| Underestimated complexity | Medium | High | Buffer time in each phase |
| Third-party API changes | Low | Medium | Abstraction layers, fallbacks |

---

## Success Metrics

### Development Metrics
- Sprint velocity consistency
- Code coverage >70%
- Zero critical bugs at milestone
- Performance targets met

### Product Metrics (Post-Launch)
- Day 1 retention >60%
- Week 1 retention >40%
- Average session >5 minutes
- App Store rating >4.5 stars

---

## Resources Required

### Development
- 1 iOS developer (full-time)
- 1 designer (part-time, weeks 1-4, 21-24)
- 1 QA tester (part-time, phases 4-6)

### Infrastructure
- Apple Developer account ($99/year)
- CloudKit (included with developer account)
- Food database API (varies)
- CI/CD (GitHub Actions free tier)

### External
- Exercise video content (license or create)
- Legal review (privacy policy, terms)
- App Store optimization consultant (optional)
