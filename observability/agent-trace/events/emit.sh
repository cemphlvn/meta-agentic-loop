#!/bin/bash
# emit.sh — Emit agent trace events to event queue
#
# Events are written to a JSONL file for consumption by:
# - MCP WebSocket server (real-time to browser)
# - /trace query commands (historical analysis)
# - Log aggregation systems
#
# Usage: emit.sh <event_type> <span_id> [json_payload]
#
# Event Types:
#   agent:spawn    — Agent spawn initiated
#   agent:complete — Agent completed (success)
#   agent:error    — Agent failed or timed out

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVENT_QUEUE="$SCRIPT_DIR/queue.jsonl"
EVENT_TYPE="${1:-unknown}"
SPAN_ID="${2:-unknown}"
PAYLOAD="${3:-"{}"}"

# Ensure queue file exists
touch "$EVENT_QUEUE"

# Get timestamp (macOS compatible - no %N support)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Build and append event JSON using printf (avoids shell interpolation issues)
printf '{"timestamp":"%s","event_type":"%s","span_id":"%s","payload":%s}\n' \
    "$TIMESTAMP" "$EVENT_TYPE" "$SPAN_ID" "$PAYLOAD" >> "$EVENT_QUEUE"

# Log to stderr for debugging (won't affect hook output)
echo "[emit] $EVENT_TYPE: $SPAN_ID" >&2
