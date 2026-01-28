---
name: vitalarc-start
description: Initialize a VitalArc development session with auto-detected platform. Prefer /vitalarc-start-workstation (Mac) or /vitalarc-start-cloud (phone/browser) for platform-specific workflows.
disable-model-invocation: true
allowed-tools: Read, Bash
argument-hint: [focus-area]
---

# VitalArc Session Init (Auto-detect)

> **Prefer platform-specific skills for explicit control:**
> - `/vitalarc-start-workstation` — Mac, full builds and simulator
> - `/vitalarc-start-cloud` — Phone/browser, no builds

This skill auto-detects platform and **delegates** to the appropriate platform-specific skill.

## Current State

- **Platform**: !`uname -s | sed 's/Darwin/macOS/;s/Linux/cloud/'`
- **Branch**: !`git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached"`

## Steps

### 1. Detect platform

```bash
PLATFORM=$([ "$(uname -s)" = "Darwin" ] && echo "mac" || echo "cloud")
echo "Detected platform: $PLATFORM"
```

### 2. Delegate to platform-specific skill

Based on detected platform, **invoke the appropriate skill**:

#### If macOS (Darwin):

Tell the user:
```
Platform detected: macOS

Please run: /vitalarc-start-workstation $ARGUMENTS

This will give you full build and simulator capabilities.
```

Then follow ALL steps from `/vitalarc-start-workstation` with `$ARGUMENTS`.

#### If Linux/Cloud:

Tell the user:
```
Platform detected: cloud

Please run: /vitalarc-start-cloud $ARGUMENTS

This is optimized for bug fixes, docs, and small changes.
```

Then follow ALL steps from `/vitalarc-start-cloud` with `$ARGUMENTS`.

### 3. Output delegation notice

```
═══════════════════════════════════════════════════════
              PLATFORM AUTO-DETECTION
═══════════════════════════════════════════════════════
Detected:  [mac/cloud]
Skill:     /vitalarc-start-[workstation/cloud]
Arguments: [$ARGUMENTS or "none"]
───────────────────────────────────────────────────────
Tip: Use platform-specific skills directly for
     explicit control over your session type.
═══════════════════════════════════════════════════════
```

## Why Delegate?

The platform-specific skills (`/vitalarc-start-workstation` and `/vitalarc-start-cloud`) contain the complete, authoritative workflows. This skill exists for convenience but delegates to avoid:

1. **Code duplication** — Changes only need to be made in one place
2. **Inconsistency** — Platform skills are always the source of truth
3. **Maintenance burden** — Fewer places to update when workflows change

For full functionality, use the platform-specific skills directly.
