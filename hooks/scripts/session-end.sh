#!/bin/bash
# Session End Hook: Persist Learnings to Scoped Remembrance
#
# This hook runs on Stop/SessionEnd and persists any
# accumulated truths from the session to .remembrance
#
# Reads from: .session-truths (temp file written during session)
# Writes to: .remembrance (scoped by agent)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Determine agent ID
AGENT_ID="${CLAUDE_AGENT_ID:-orchestrator}"

# Check if session truths exist
SESSION_TRUTHS="$PROJECT_ROOT/.session-truths"
if [ ! -f "$SESSION_TRUTHS" ]; then
    echo "No session truths to persist"
    exit 0
fi

# Persist each truth
cd "$PROJECT_ROOT"
while IFS= read -r truth_json || [ -n "$truth_json" ]; do
    if [ -n "$truth_json" ]; then
        node "$SCRIPT_DIR/scoped-remembrance.js" write "$AGENT_ID" "$truth_json"
        echo "Persisted truth for agent: $AGENT_ID"
    fi
done < "$SESSION_TRUTHS"

# Clean up session file
rm -f "$SESSION_TRUTHS"
echo "Session truths persisted and cleaned up"
