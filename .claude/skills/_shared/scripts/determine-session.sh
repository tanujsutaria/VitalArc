#!/bin/bash
# Determine session number and minor version
# Usage: ./determine-session.sh <platform>
# Output: SESSION=N MINOR=M

PLATFORM="${1:-mac}"
TODAY=$(date +%Y-%m-%d)

# Get current session from SESSION_LOG.md
CURRENT_SESSION=$(grep -E "^## Session [0-9]+" SESSION_LOG.md 2>/dev/null | head -1 | sed 's/## Session \([0-9]*\).*/\1/')
CURRENT_SESSION=${CURRENT_SESSION:-0}

# Get date of current session (try to parse it)
LAST_DATE=""
if [ -n "$CURRENT_SESSION" ] && [ "$CURRENT_SESSION" -gt 0 ]; then
    # Try to extract date from session header
    SESSION_LINE=$(grep -E "^## Session ${CURRENT_SESSION}" SESSION_LOG.md 2>/dev/null | head -1)
    # Try format: "January 27, 2026"
    LAST_DATE=$(echo "$SESSION_LINE" | grep -oE "[A-Z][a-z]+ [0-9]+, [0-9]+" | head -1)
    if [ -n "$LAST_DATE" ]; then
        # Convert to YYYY-MM-DD (macOS date command)
        if [ "$(uname -s)" = "Darwin" ]; then
            LAST_DATE=$(date -j -f "%B %d, %Y" "$LAST_DATE" +%Y-%m-%d 2>/dev/null || echo "")
        else
            # Linux date command
            LAST_DATE=$(date -d "$LAST_DATE" +%Y-%m-%d 2>/dev/null || echo "")
        fi
    fi
fi

# Determine session number
if [ "$LAST_DATE" = "$TODAY" ]; then
    SESSION=$CURRENT_SESSION
else
    SESSION=$((CURRENT_SESSION + 1))
fi

# Determine minor version (count existing branches for this session today)
MINOR=$(git branch -a 2>/dev/null | grep -cE "dev/${PLATFORM}-[a-z]+-${SESSION}\\.[0-9]+-${TODAY}" || echo 0)

echo "SESSION=$SESSION"
echo "MINOR=$MINOR"
echo "TODAY=$TODAY"
