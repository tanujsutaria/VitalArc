---
name: pre-commit-quality-gate
description: Reusable quality gate orchestrator. Runs build-validator and design-system-scanner in parallel. Can be invoked standalone or by session-orchestrator.
disable-model-invocation: true
allowed-tools: Task, Read
argument-hint: [--fix] [--skip-build]
---

# Pre-Commit Quality Gate

Orchestrator that validates code quality before commits. Reusable across different contexts.

## When to Use

| Context | Invoked By | Purpose |
|---------|-----------|---------|
| Session end | session-orchestrator | Final validation before commit |
| Mid-session | User (`/pre-commit-quality-gate`) | Check work-in-progress |
| Before PR | User | Ensure PR readiness |
| After refactor | User | Verify no regressions |

## Orchestration Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PRE-COMMIT QUALITY GATE                           │
├─────────────────────────────────────────────────────────────────────┤
│  PHASE 1 - Parallel Validation:                                     │
│    ├── build-validator (compile check)                              │
│    └── design-system-scanner (token compliance)                     │
│                                                                      │
│  PHASE 2 - Conditional Fix (if --fix and violations found):         │
│    └── design-system-fixer                                          │
│                                                                      │
│  PHASE 3 - Re-validate (if fixes applied):                          │
│    └── build-validator (verify fixes compile)                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Options

| Option | Description |
|--------|-------------|
| `--fix` | Auto-fix design system violations after scanning |
| `--skip-build` | Skip build validation (for quick checks) |
| `--strict` | Fail on any violation, even warnings |

## Implementation

### Phase 1: Parallel Validation

Launch both agents in parallel using Task tool:

```markdown
**Task 1: build-validator**
Prompt: "Run xcodebuild for VitalArc. Report build status with any errors and warnings."

**Task 2: design-system-scanner**
Prompt: "Scan VitalArc/Presentation/ for design token violations. Report summary and violations by file."
```

### Phase 2: Conditional Fix

If `--fix` flag provided AND scanner found violations:

```markdown
**Task: design-system-fixer**
Prompt: "Fix design system violations reported by scanner. Apply token replacements."
```

### Phase 3: Re-validate

If fixes were applied:

```markdown
**Task: build-validator**
Prompt: "Re-run build after design system fixes. Verify all changes compile."
```

## Output Format

### All Passing

```markdown
## Pre-Commit Quality Gate

### Results
| Check | Status | Details |
|-------|--------|---------|
| Build | ✅ PASSED | 0 errors, 0 warnings |
| Design System | ✅ PASSED | 0 violations |

### Verdict: ✅ READY TO COMMIT
```

### Violations Found (No Fix)

```markdown
## Pre-Commit Quality Gate

### Results
| Check | Status | Details |
|-------|--------|---------|
| Build | ✅ PASSED | 0 errors, 2 warnings |
| Design System | ⚠️ VIOLATIONS | 5 issues in 3 files |

### Design System Violations
| File | Count | Top Issue |
|------|-------|-----------|
| ProfileView.swift | 3 | Hardcoded colors |
| WorkoutView.swift | 2 | Hardcoded spacing |

### Verdict: ⚠️ REVIEW NEEDED

**Options:**
1. Run with `--fix` to auto-fix violations
2. Fix manually and re-run gate
3. Proceed anyway (not recommended)
```

### Violations Fixed

```markdown
## Pre-Commit Quality Gate

### Results
| Check | Status | Details |
|-------|--------|---------|
| Build | ✅ PASSED | 0 errors, 0 warnings |
| Design System | ✅ FIXED | 5 violations auto-fixed |
| Re-build | ✅ PASSED | Fixes compile correctly |

### Fixes Applied
| File | Fixes |
|------|-------|
| ProfileView.swift | 3 |
| WorkoutView.swift | 2 |

### Verdict: ✅ READY TO COMMIT
```

### Build Failed

```markdown
## Pre-Commit Quality Gate

### Results
| Check | Status | Details |
|-------|--------|---------|
| Build | ❌ FAILED | 2 errors |
| Design System | ⏸️ SKIPPED | Build must pass first |

### Build Errors
```
VitalArc/Presentation/ProfileView.swift:45:12: error: Type 'Foo' has no member 'bar'
VitalArc/Domain/UseCase.swift:23:5: error: Missing return
```

### Verdict: ❌ BLOCKED

**Action Required:** Fix build errors before committing.
```

## Error Handling

### Agent Failure

If an agent fails to complete:

```markdown
## Pre-Commit Quality Gate

### Results
| Check | Status | Details |
|-------|--------|---------|
| Build | ✅ PASSED | 0 errors |
| Design System | ⚠️ INCOMPLETE | Scanner timed out |

### Verdict: ⚠️ PARTIAL CHECK

Design system scan incomplete. Consider re-running or proceeding with caution.
```

### Conflicting Results

If build passes but has warnings that might relate to violations:

```markdown
## Pre-Commit Quality Gate

### Results
| Check | Status | Details |
|-------|--------|---------|
| Build | ⚠️ WARNINGS | 3 warnings |
| Design System | ✅ PASSED | 0 violations |

### Build Warnings
```
warning: 'foo' is deprecated
warning: Result unused
warning: Initialization never used
```

### Verdict: ✅ READY TO COMMIT (with warnings)

Consider addressing warnings in future session.
```

## Integration

### With Session End

The session-orchestrator calls this gate during END mode:

```
session-orchestrator --mode=end
  └── pre-commit-quality-gate (embedded)
        ├── build-validator
        └── design-system-scanner
```

### Standalone Usage

Users can invoke directly:

```bash
# Quick check
/pre-commit-quality-gate

# Check and auto-fix
/pre-commit-quality-gate --fix

# Skip slow build (design check only)
/pre-commit-quality-gate --skip-build
```
