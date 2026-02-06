#!/bin/bash
# Session Start Hook: Load Scoped Remembrance
#
# This hook runs on SessionStart and outputs the agent's
# scoped portion of .remembrance to be injected into context.
#
# The agent ID is determined from:
# 1. CLAUDE_AGENT_ID env var (if set by subagent invocation)
# 2. Default to 'orchestrator' for main session

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Determine agent ID
AGENT_ID="${CLAUDE_AGENT_ID:-orchestrator}"

# Check if remembrance exists
if [ ! -f "$PROJECT_ROOT/.remembrance" ]; then
    echo "No .remembrance file found"
    exit 0
fi

# Load scoped remembrance
cd "$PROJECT_ROOT"
node "$SCRIPT_DIR/scoped-remembrance.js" read "$AGENT_ID"
