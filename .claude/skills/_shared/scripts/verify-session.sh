#!/bin/bash
# Verify session state before ending
# Usage: ./verify-session.sh [--require-build]

set -e

REQUIRE_BUILD=false
if [ "$1" = "--require-build" ]; then
    REQUIRE_BUILD=true
fi

echo "=== Session Verification ==="

# Check we're on a valid branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -z "$BRANCH" ] || [ "$BRANCH" = "HEAD" ]; then
    echo "ERROR: Not on a valid branch"
    exit 1
fi
echo "Branch: $BRANCH"

# Verify branch follows naming convention
if ! echo "$BRANCH" | grep -qE "^dev/(mac|cloud)-[a-z]+-[0-9]+\.[0-9]+-[0-9]{4}-[0-9]{2}-[0-9]{2}$"; then
    echo "WARNING: Branch doesn't follow naming convention: dev/<platform>-<focus>-<session>.<minor>-YYYY-MM-DD"
fi

# Check for uncommitted changes
UNCOMMITTED=$(git status --porcelain)
if [ -n "$UNCOMMITTED" ]; then
    echo "WARNING: Uncommitted changes detected:"
    echo "$UNCOMMITTED" | head -10
fi

# Check session state file exists
if [ -f ".claude/session-state.json" ]; then
    echo "Session state: OK"
    cat .claude/session-state.json
else
    echo "WARNING: No session state file found"
fi

# Build check (if required)
if [ "$REQUIRE_BUILD" = true ]; then
    echo ""
    echo "=== Build Verification ==="
    if [ "$(uname -s)" = "Darwin" ]; then
        BUILD_RESULT=$(xcodebuild -scheme VitalArc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD)" | tail -5)
        if echo "$BUILD_RESULT" | grep -q "BUILD SUCCEEDED"; then
            echo "Build: PASSED"
        else
            echo "Build: FAILED"
            echo "$BUILD_RESULT"
            exit 1
        fi
    else
        echo "Build: SKIPPED (not on macOS)"
    fi
fi

echo ""
echo "=== Verification Complete ==="
