---
name: vitalarc-end-workstation
description: Finalize a VitalArc workstation development session. Use when ending a session on Mac. Verifies build passes, commits documentation, and pushes changes.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
argument-hint: [summary]
---

# VitalArc Workstation Session End

Finalize a workstation session with build verification.

## Steps

### 1. Build Validation (BLOCKING)

**This must pass before the session can end.**

```
Read: .claude/skills/build-validator/SKILL.md
Agent type: Bash (from maps-to-agent metadata)
Task prompt: "Run xcodebuild for VitalArc. This is a BLOCKING check - report SUCCEEDED or FAILED with any errors."
```

**If build fails, STOP and report:**
```
═══════════════════════════════════════════════════════════════
       ❌ SESSION END BLOCKED - BUILD FAILED
═══════════════════════════════════════════════════════════════
Fix build errors before ending session.
Run: xcodebuild ... to see full errors
Then: Re-run /vitalarc-end-workstation
═══════════════════════════════════════════════════════════════
```

### 2. Parallel Quality Checks (after build passes)

Launch these Task agents IN PARALLEL:

**Design System Scan**:
```
Read: .claude/skills/design-system-scanner/SKILL.md
Agent type: Explore (from maps-to-agent metadata)
Task prompt: "Final scan of VitalArc/Presentation/ for design token violations. Report summary."
```

**Progress Update**:
```
Read: .claude/skills/progress-tracker/SKILL.md
Agent type: general-purpose (from maps-to-agent metadata)
Task prompt: "Update SESSION_LOG.md Work Log with final entries. Add session end timestamp."
```

### 3. Commit Message Generation

```
Read: .claude/skills/commit-formatter/SKILL.md
Agent type: general-purpose (from maps-to-agent metadata)
Task prompt: "Analyze staged changes. Generate conventional commit message following VitalArc conventions."
```

### 4. Update documentation files

If features changed:
- PROJECT_STATUS.md: Update "Last Updated", feature status, Known Issues, Codebase Stats
- README.md Roadmap: Move features between In Progress / Planned / Completed

### 5. Commit and push

Using the commit message generated:

```bash
git add SESSION_LOG.md PROJECT_STATUS.md README.md
git commit -m "[generated commit message]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
```

### 6. Create PR (optional)

If ready for review:

**PR Title**: `<type>(<scope>): <short description>`
- Example: `feat(workout): add custom exercise creation`
- Example: `fix(nutrition): correct calorie calculation`

```bash
gh pr create --title "<type>(<scope>): <description>" --body "$(cat <<'EOF'
## Summary
- [Primary change and why]
- [Secondary changes if any]

## Changes
- [List of modified areas]

## Testing
- [x] Build passes locally
- [ ] CI passes
- [ ] Manual testing done

---
Session: [N] | Platform: macOS | Build: Verified
EOF
)"
```

### 7. Output summary

```
═══════════════════════════════════════════════════════════════
       VITALARC WORKSTATION SESSION COMPLETE
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Commits:  [N]
Build:    Passing
Next:     [priorities from focus-suggester]
═══════════════════════════════════════════════════════════════
```
