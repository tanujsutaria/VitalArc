---
name: vitalarc-end-cloud
description: Finalize a VitalArc cloud development session. Use when ending a session started from phone or browser. Commits documentation, pushes changes, no build verification.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
argument-hint: [summary]
---

# VitalArc Cloud Session End

Finalize a cloud session. No build verification—CI will validate.

## Steps

### 1. Parallel Quality Checks

Launch these Task agents IN PARALLEL:

**Design System Scan**:
```
Read: .claude/skills/design-system-scanner/SKILL.md
Agent type: Explore (from maps-to-agent metadata)
Task prompt: "Final scan of VitalArc/Presentation/ for design token violations. Report summary only (cloud session - no fixing)."
```

**Progress Update**:
```
Read: .claude/skills/progress-tracker/SKILL.md
Agent type: general-purpose (from maps-to-agent metadata)
Task prompt: "Update SESSION_LOG.md Work Log with final entries. Add session end timestamp."
```

### 2. Commit Message Generation

```
Read: .claude/skills/commit-formatter/SKILL.md
Agent type: general-purpose (from maps-to-agent metadata)
Task prompt: "Analyze staged changes. Generate conventional commit message following VitalArc conventions."
```

### 3. Update documentation files

If features changed:
- PROJECT_STATUS.md: Update "Last Updated", Known Issues, feature status
- README.md Roadmap: Move features between In Progress / Planned as needed

### 4. Commit and push

Using the commit message generated:

```bash
git add SESSION_LOG.md PROJECT_STATUS.md README.md
git commit -m "[generated commit message]

- Cloud session (build not verified)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
```

### 5. Create PR (optional)

If ready for review:

**PR Title**: `<type>(<scope>): <short description>`
- Example: `fix(infra): correct session numbering logic`
- Example: `refactor(ui): standardize icon sizes with design tokens`

```bash
gh pr create --title "<type>(<scope>): <description>" --body "$(cat <<'EOF'
## Summary
- [Primary change and why]
- [Secondary changes if any]

## Changes
- [List of modified areas]

## Testing
- [ ] CI build passes
- [ ] Cloud session—manual testing recommended on workstation

---
Session: [N] | Platform: cloud
EOF
)"
```

### 6. Output summary

```
═══════════════════════════════════════════════════════════════
           VITALARC CLOUD SESSION COMPLETE
═══════════════════════════════════════════════════════════════
Branch:   [branch]
Commits:  [N]
Build:    Not verified (cloud)
Status:   [Complete / Needs Workstation]
Next:     [priorities]
═══════════════════════════════════════════════════════════════
```

Use status **Needs Workstation** if changes require UI or build verification.
