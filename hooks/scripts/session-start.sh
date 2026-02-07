#!/bin/bash
# Session Start Hook: Load Scoped Remembrance + Track Reads
#
# This hook runs on SessionStart and:
# 1. Outputs the agent's scoped portion of .remembrance to context
# 2. Tracks when remembrance was read (meta-reminder system)
#
# The agent ID is determined from:
# 1. CLAUDE_AGENT_ID env var (if set by subagent invocation)
# 2. Default to 'orchestrator' for main session

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TRACKER_FILE="$PROJECT_ROOT/.observability/remembrance-tracker.json"

# Determine agent ID
AGENT_ID="${CLAUDE_AGENT_ID:-orchestrator}"

# Check if remembrance exists
if [ ! -f "$PROJECT_ROOT/.remembrance" ]; then
    echo "No .remembrance file found"
    exit 0
fi

# Track remembrance read (meta-reminder system)
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
if [ -f "$TRACKER_FILE" ]; then
    LAST_READ=$(grep -o '"last_read": "[^"]*"' "$TRACKER_FILE" | cut -d'"' -f4 2>/dev/null || echo "never")
    READ_COUNT=$(grep -o '"read_count": [0-9]*' "$TRACKER_FILE" | grep -o '[0-9]*' 2>/dev/null || echo "0")
    NEW_COUNT=$((READ_COUNT + 1))

    # Calculate delta if possible (seconds since last read)
    if [ "$LAST_READ" != "never" ] && [ -n "$LAST_READ" ]; then
        LAST_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_READ" "+%s" 2>/dev/null || echo "0")
        NOW_EPOCH=$(date -u "+%s")
        if [ "$LAST_EPOCH" != "0" ]; then
            DELTA=$((NOW_EPOCH - LAST_EPOCH))
            DELTA_HUMAN="${DELTA}s"
            if [ "$DELTA" -gt 3600 ]; then
                DELTA_HUMAN="$((DELTA / 3600))h $((DELTA % 3600 / 60))m"
            elif [ "$DELTA" -gt 60 ]; then
                DELTA_HUMAN="$((DELTA / 60))m $((DELTA % 60))s"
            fi
            echo "--- Remembrance Tracker ---"
            echo "Last read: $LAST_READ"
            echo "Delta: $DELTA_HUMAN ago"
            echo "Read count: $NEW_COUNT"
            echo "---------------------------"
        fi
    fi

    # Update tracker with new read
    sed -i '' "s/\"last_read\": \"[^\"]*\"/\"last_read\": \"$NOW\"/" "$TRACKER_FILE" 2>/dev/null || true
    sed -i '' "s/\"read_count\": [0-9]*/\"read_count\": $NEW_COUNT/" "$TRACKER_FILE" 2>/dev/null || true
fi

# Load scoped remembrance
cd "$PROJECT_ROOT"
node "$SCRIPT_DIR/scoped-remembrance.cjs" read "$AGENT_ID"
