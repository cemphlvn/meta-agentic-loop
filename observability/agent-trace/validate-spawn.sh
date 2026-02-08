#!/bin/bash
# validate-spawn.sh — OTel-compatible agent spawn validation and logging
#
# Called by PreToolUse hook for Task tool
# Validates agent exists, is active, and logs the spawn intent with OTel fields
#
# Usage: validate-spawn.sh <agent_id> <task_description>
# Exit: 0 = valid, 1 = blocked, 2 = warn
#
# OTel Fields Generated:
#   trace_id      - Session identifier (from CLAUDE_TRACE_ID or generated)
#   span_id       - Unique 16-char hex for this run
#   parent_span_id - From AGENT_SPAN_ID (spawner's span)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TRACE_DIR="$SCRIPT_DIR"

AGENT_ID="${1:-unknown}"
TASK_DESC="${2:-No task description provided}"
SPAWNER="${CLAUDE_AGENT_ID:-orchestrator}"

# OTel identifiers
# trace_id: 32 hex chars (128-bit) - shared across session
TRACE_ID="${CLAUDE_TRACE_ID:-$(openssl rand -hex 16)}"
# span_id: 16 hex chars (64-bit) - unique per agent run
SPAN_ID=$(openssl rand -hex 8)
# parent_span_id: spawner's span_id (null for root)
PARENT_SPAN_ID="${AGENT_SPAN_ID:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

#─────────────────────────────────────────────────────────────────────────────
# VALIDATION
#─────────────────────────────────────────────────────────────────────────────

validate_agent() {
    local agent_id="$1"
    local index_file="$PLUGIN_ROOT/.claude/agents/INDEX.md"

    # Check index exists
    if [[ ! -f "$index_file" ]]; then
        echo -e "${YELLOW}WARN: Agent registry not found at $index_file${NC}"
        return 2
    fi

    # Check agent exists in registry (look for | `agent-id` | pattern)
    if ! grep -qE "^\| \`$agent_id\`" "$index_file" 2>/dev/null; then
        # Also check without backticks
        if ! grep -qE "^\| $agent_id \|" "$index_file" 2>/dev/null; then
            echo -e "${RED}BLOCK: Agent '$agent_id' not found in registry${NC}"
            echo "Available agents:"
            grep -E "^\| \`[a-z-]+\`" "$index_file" | head -10 || true
            return 1
        fi
    fi

    # Check agent status (look for Active or Master in the line)
    local agent_line=$(grep -E "^\| \`?$agent_id\`?" "$index_file" 2>/dev/null | head -1)
    if [[ -z "$agent_line" ]]; then
        echo -e "${YELLOW}WARN: Could not find agent line for '$agent_id'${NC}"
        return 2
    fi

    if echo "$agent_line" | grep -qE "Active|Master"; then
        return 0
    elif echo "$agent_line" | grep -qE "Draft"; then
        echo -e "${RED}BLOCK: Agent '$agent_id' is in DRAFT status, not ready for use${NC}"
        return 1
    elif echo "$agent_line" | grep -qE "DEPRECATED"; then
        echo -e "${RED}BLOCK: Agent '$agent_id' is DEPRECATED${NC}"
        return 1
    else
        echo -e "${YELLOW}WARN: Could not determine status for '$agent_id'${NC}"
        return 2
    fi
}

#─────────────────────────────────────────────────────────────────────────────
# LOGGING
#─────────────────────────────────────────────────────────────────────────────

log_spawn() {
    local agent_id="$1"
    local task="$2"
    local spawner="$3"
    local validation_status="$4"

    local start_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    # Get Unix timestamp in milliseconds for OTel
    local start_time_unix_nano=$(($(date -u +%s) * 1000000000))

    # Determine agent tier from INDEX.md (default: operational)
    local agent_tier="operational"
    local index_file="$PLUGIN_ROOT/.claude/agents/INDEX.md"
    if [[ -f "$index_file" ]]; then
        local agent_line=$(grep -E "^\| \`?$agent_id\`?" "$index_file" 2>/dev/null | head -1)
        if echo "$agent_line" | grep -qE "strategic"; then
            agent_tier="strategic"
        elif echo "$agent_line" | grep -qE "tactical"; then
            agent_tier="tactical"
        fi
    fi

    mkdir -p "$TRACE_DIR/pending"

    # Use span_id as filename for OTel compatibility
    cat > "$TRACE_DIR/pending/$SPAN_ID.yaml" << EOF
---
# OpenTelemetry-Compatible Span (Pending)
# Schema: observability/agent-trace/schema.yaml

# Identifiers (OTel)
trace_id: "$TRACE_ID"
span_id: "$SPAN_ID"
parent_span_id: "${PARENT_SPAN_ID:-null}"

# Operation
operation_name: "$agent_id"
task_description: |
  $task

# Timing
start_time: "$start_time"
start_time_unix_nano: $start_time_unix_nano

# Status (UNSET while pending)
status:
  code: "UNSET"
  message: "Span in progress"

# Attributes
attributes:
  agent.tier: "$agent_tier"
  agent.spawner: "$spawner"
  validation.status: "$validation_status"
---
EOF

    # Emit agent:spawn event to WebSocket queue
    local event_payload=$(cat << PAYLOAD
{"trace_id":"$TRACE_ID","parent_span_id":"${PARENT_SPAN_ID:-null}","operation":"$agent_id","tier":"$agent_tier","spawner":"$spawner"}
PAYLOAD
)
    "$SCRIPT_DIR/events/emit.sh" "agent:spawn" "$SPAN_ID" "$event_payload" 2>/dev/null || true

    echo "$SPAN_ID"
}

#─────────────────────────────────────────────────────────────────────────────
# MAIN
#─────────────────────────────────────────────────────────────────────────────

echo "─────────────────────────────────────────────────"
echo "AGENT SPAWN VALIDATION"
echo "─────────────────────────────────────────────────"
echo "Spawner: $SPAWNER"
echo "Target:  $AGENT_ID"
echo "Task:    ${TASK_DESC:0:60}..."
echo "─────────────────────────────────────────────────"

# Validate
validation_result=0
validate_agent "$AGENT_ID" || validation_result=$?

case $validation_result in
    0)
        # Valid - log and proceed
        SPAN_ID=$(log_spawn "$AGENT_ID" "$TASK_DESC" "$SPAWNER" "passed")
        echo -e "${GREEN}PASS: Agent spawn validated${NC}"
        echo "Trace ID: $TRACE_ID"
        echo "Span ID:  $SPAN_ID"
        echo ""
        # Export for child agents and PostToolUse hook
        echo "export CLAUDE_TRACE_ID=\"$TRACE_ID\""
        echo "export AGENT_SPAN_ID=\"$SPAN_ID\""
        echo "export AGENT_RUN_ID=\"$SPAN_ID\""
        exit 0
        ;;
    1)
        # Blocked
        echo ""
        echo -e "${RED}SPAWN BLOCKED${NC}"
        echo "The agent '$AGENT_ID' cannot be spawned."
        echo "Check .claude/agents/INDEX.md for available agents."
        exit 1
        ;;
    2)
        # Warning only - log but don't block
        SPAN_ID=$(log_spawn "$AGENT_ID" "$TASK_DESC" "$SPAWNER" "warned")
        echo -e "${YELLOW}WARN: Proceeding with warnings${NC}"
        echo "Trace ID: $TRACE_ID"
        echo "Span ID:  $SPAN_ID"
        echo "export CLAUDE_TRACE_ID=\"$TRACE_ID\""
        echo "export AGENT_SPAN_ID=\"$SPAN_ID\""
        echo "export AGENT_RUN_ID=\"$SPAN_ID\""
        exit 0
        ;;
esac
