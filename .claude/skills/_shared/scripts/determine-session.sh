#!/bin/bash
# Determine session number and minor version
# Usage: source determine-session.sh <platform>
# Output: Sets SESSION, MINOR, FULL_SESSION, TODAY variables
#
# Session numbering rules:
# - Major number increments when DATE changes (e.g., 12 -> 13)
# - Minor version increments for same-day sessions (e.g., 12.0 -> 12.1 -> 12.2)
# - Minor versions are determined by counting SESSION_LOG.md entries for that major+date

PLATFORM="${1:-mac}"
TODAY=$(date +%Y-%m-%d)

# Get the most recent session entry (handles both "Session 12" and "Session 12.1" formats)
LATEST_ENTRY=$(grep -E "^## Session [0-9]+(\.[0-9]+)? - " SESSION_LOG.md 2>/dev/null | head -1)

# Extract major session number (integer part only)
LATEST_MAJOR=$(echo "$LATEST_ENTRY" | sed -E 's/## Session ([0-9]+).*/\1/')
LATEST_MAJOR=${LATEST_MAJOR:-0}

# Extract the date from the latest session entry (format: "January 28, 2026")
LATEST_DATE_STR=$(echo "$LATEST_ENTRY" | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | head -1)

# Convert to YYYY-MM-DD for comparison
if [ -n "$LATEST_DATE_STR" ]; then
    if [ "$(uname -s)" = "Darwin" ]; then
        LATEST_DATE=$(date -j -f "%B %d, %Y" "$LATEST_DATE_STR" +%Y-%m-%d 2>/dev/null || echo "")
    else
        # Linux date command
        LATEST_DATE=$(date -d "$LATEST_DATE_STR" +%Y-%m-%d 2>/dev/null || echo "")
    fi
else
    LATEST_DATE=""
fi

# Determine session number based on date
if [ "$LATEST_DATE" = "$TODAY" ]; then
    # Same day: keep major number, calculate minor version
    SESSION=$LATEST_MAJOR

    # Count existing sessions with this major number on today's date
    # This counts entries like "Session 12 -" and "Session 12.1 -" and "Session 12.2 -" that have today's date
    # We need to count how many sessions with major=$SESSION exist for today
    MINOR=$(grep -E "^## Session ${SESSION}(\.[0-9]+)? - .*${LATEST_DATE_STR}" SESSION_LOG.md 2>/dev/null | wc -l | tr -d ' ')
    MINOR=${MINOR:-0}
else
    # New day: increment major number, start at minor 0
    SESSION=$((LATEST_MAJOR + 1))
    MINOR=0
fi

# Format the full session number
if [ "$MINOR" -eq 0 ]; then
    FULL_SESSION="$SESSION"
else
    FULL_SESSION="${SESSION}.${MINOR}"
fi

# Export variables
export SESSION
export MINOR
export FULL_SESSION
export TODAY

# Output for debugging/sourcing
echo "SESSION=$SESSION"
echo "MINOR=$MINOR"
echo "FULL_SESSION=$FULL_SESSION"
echo "TODAY=$TODAY"
