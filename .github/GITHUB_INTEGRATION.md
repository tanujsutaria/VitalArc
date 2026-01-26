# GitHub Integration Setup for VitalArc

This document describes the GitHub workflows and integrations configured for VitalArc.

## Workflows Overview

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **CI** | Push to main, PRs | Build verification, testing, linting |
| **PR Automation** | PR events | Auto-labeling, size tracking, welcomes |
| **Claude Review** | PR opened/updated | AI-powered code review |

---

## 1. CI Workflow (`ci.yml`)

Runs on every push to `main` and all pull requests.

### Jobs

**Build**
- Compiles the VitalArc scheme on macOS 14
- Uses Xcode 15.2 with iPhone 15 Pro simulator
- Caches DerivedData for faster subsequent builds
- Disables code signing for CI environment

**Test**
- Runs unit tests after successful build
- Uploads test results as artifacts (7-day retention)
- Results available in Actions tab

**SwiftLint**
- Checks code style and conventions
- Currently set to warn-only (doesn't fail build)
- Configuration in `.swiftlint.yml`

### Required Secrets
None - uses default GITHUB_TOKEN

---

## 2. PR Automation (`pr-automation.yml`)

Automates pull request management.

### Features

**Auto-Labeling**
- Labels based on files changed (see `.github/labeler.yml`)
- Labels based on branch name patterns
- Labels based on conventional commit title

**PR Size Labels**
- `size/XS` - < 10 lines changed
- `size/S` - 10-49 lines
- `size/M` - 50-199 lines
- `size/L` - 200-499 lines
- `size/XL` - 500+ lines

**First-Time Contributor Welcome**
- Posts welcome message on first PR
- Includes checklist for PR requirements

**Dependabot Auto-Merge**
- Automatically merges Dependabot PRs after CI passes

### Required Secrets
None - uses default GITHUB_TOKEN

---

## 3. Claude Code Review (`claude-review.yml`)

AI-powered code review using Claude API.

### How It Works
1. Triggered when a non-draft PR is opened or updated
2. Collects changed Swift files and diff
3. Sends code context to Claude API
4. Posts review as PR comment

### What It Reviews
- Potential bugs and issues
- Code quality and best practices
- Security considerations
- Brief summary of changes

### Setup Required

**Add Anthropic API Key:**
1. Go to repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `ANTHROPIC_API_KEY`
4. Value: Your Anthropic API key from [console.anthropic.com](https://console.anthropic.com)

**API Key Permissions:**
- Needs access to Claude Sonnet model
- Estimated cost: ~$0.01-0.05 per review depending on PR size

### Limitations
- Reviews first 10 changed Swift files
- Truncates large files at 5000 characters
- Diff limited to 10000 characters
- Advisory only - always verify suggestions

---

## Label Configuration

Labels are automatically created and applied based on:

### Architecture Layers
- `domain` - Domain layer changes
- `data` - Data layer changes
- `infrastructure` - Infrastructure changes
- `presentation` - UI changes

### Feature Areas
- `workout` - Workout tracking
- `nutrition` - Nutrition/food logging
- `health` - HealthKit integration
- `analytics` - Analytics dashboard
- `training` - Mesocycles/templates
- `profile` - User profile/settings
- `design-system` - Design tokens/components

### Other
- `testing` - Test files
- `documentation` - Markdown files
- `configuration` - Config/workflow files
- `dependencies` - Package/project changes

---

## Branch Protection (Recommended)

Configure branch protection for `main`:

1. Go to Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Enable:
   - [x] Require a pull request before merging
   - [x] Require status checks to pass (select "Build", "Test")
   - [x] Require conversation resolution before merging
   - [x] Do not allow bypassing the above settings

---

## Alternative: Claude GitHub App

For a more integrated experience, you can use the official Claude GitHub App:

### Installation
1. Visit [github.com/apps/claude](https://github.com/apps/claude) (when available)
2. Install on your repository
3. Configure permissions

### Features (App)
- Direct `@claude` mentions in PRs and issues
- Inline code suggestions
- Issue triage assistance
- No API key management needed

**Note:** The custom workflow above provides similar functionality without requiring the GitHub App, using your own API key.

---

## Troubleshooting

### Build Failures
- Check Xcode version matches (15.2)
- Verify simulator destination exists
- Review build logs for compilation errors

### Test Failures
- Download test-results artifact for detailed report
- Check for flaky tests (run locally first)

### SwiftLint Warnings
- Run `swiftlint lint` locally to see issues
- Fix or add `// swiftlint:disable:next <rule>` for exceptions

### Claude Review Not Posting
- Verify `ANTHROPIC_API_KEY` secret is set
- Check API key has sufficient credits
- Review workflow logs for API errors

---

## Local Development

### Run SwiftLint Locally
```bash
brew install swiftlint
swiftlint lint
```

### Run Tests Locally
```bash
xcodebuild test \
  -scheme VitalArc \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Validate Workflows
```bash
# Install act (GitHub Actions local runner)
brew install act

# Run CI workflow locally
act -j build
```
