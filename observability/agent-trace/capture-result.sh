#!/bin/bash
# capture-result.sh — OTel-compatible agent execution result capture
#
# Called by PostToolUse hook for Task tool
# Moves span from pending to completed, calculates duration_ms
#
# Usage: capture-result.sh <span_id> <status> [result_summary]
#
# OTel Fields Added:
#   end_time, end_time_unix_nano, duration_ms
#   status.code: OK | ERROR

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACE_DIR="$SCRIPT_DIR"

SPAN_ID="${1:-}"
STATUS="${2:-unknown}"  # success | failure | timeout | unknown
RESULT_SUMMARY="${3:-No summary provided}"

# If no span_id provided, read from file (written by PreToolUse hook)
if [[ -z "$SPAN_ID" || "$SPAN_ID" == "unknown" ]]; then
    if [[ -f /tmp/claude_spans/last_span ]]; then
        SPAN_ID=$(cat /tmp/claude_spans/last_span)
        # Pop from stack for nested agents
        if [[ -f /tmp/claude_spans/span_stack ]]; then
            head -n -1 /tmp/claude_spans/span_stack > /tmp/claude_spans/span_stack.tmp 2>/dev/null || true
            mv /tmp/claude_spans/span_stack.tmp /tmp/claude_spans/span_stack 2>/dev/null || true
            # Update last_span to previous in stack
            tail -1 /tmp/claude_spans/span_stack > /tmp/claude_spans/last_span 2>/dev/null || true
        fi
    fi
fi

# Map status to OTel StatusCode
case "$STATUS" in
    success) OTEL_STATUS="OK" ;;
    failure|timeout|error) OTEL_STATUS="ERROR" ;;
    *) OTEL_STATUS="UNSET" ;;
esac

if [[ -z "$SPAN_ID" ]]; then
    echo "WARN: No span_id available (not passed and no file)"
    exit 0
fi

PENDING_FILE="$TRACE_DIR/pending/$SPAN_ID.yaml"
RUN_FILE="$TRACE_DIR/runs/$SPAN_ID.yaml"

mkdir -p "$TRACE_DIR/runs"

# Capture end time
END_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
END_TIME_UNIX_NANO=$(($(date -u +%s) * 1000000000))

if [[ ! -f "$PENDING_FILE" ]]; then
    echo "WARN: No pending span found for $SPAN_ID"
    # Create a minimal span file anyway
    cat > "$RUN_FILE" << EOF
---
# OpenTelemetry-Compatible Span (Orphan)
trace_id: "unknown"
span_id: "$SPAN_ID"
parent_span_id: null
operation_name: "unknown"
task_description: "No pending record found"
start_time: "unknown"
end_time: "$END_TIME"
end_time_unix_nano: $END_TIME_UNIX_NANO
duration_ms: null
status:
  code: "$OTEL_STATUS"
  message: "$RESULT_SUMMARY"
attributes:
  note: "Pending record was missing - partial capture only"
---
EOF
    exit 0
fi

# Read start time from pending
START_TIME=$(grep "^start_time:" "$PENDING_FILE" | sed 's/start_time: //' | tr -d '"' | tr -d ' ')
START_NANO=$(grep "^start_time_unix_nano:" "$PENDING_FILE" | sed 's/start_time_unix_nano: //' | tr -d ' ')

# Calculate duration_ms (OTel uses nanoseconds, we output ms for readability)
DURATION_MS="null"
if [[ -n "$START_NANO" && "$START_NANO" != "null" ]]; then
    DURATION_NS=$((END_TIME_UNIX_NANO - START_NANO))
    DURATION_MS=$((DURATION_NS / 1000000))
fi

# Read trace_id and operation_name from pending
TRACE_ID=$(grep "^trace_id:" "$PENDING_FILE" | sed 's/trace_id: //' | tr -d '"' | tr -d ' ')
OPERATION=$(grep "^operation_name:" "$PENDING_FILE" | sed 's/operation_name: //' | tr -d '"' | tr -d ' ')

# Copy pending to runs and update with completion info
cp "$PENDING_FILE" "$RUN_FILE"

# Remove the trailing --- and UNSET status, add completion info
sed -i '' '/^---$/d' "$RUN_FILE" 2>/dev/null || sed -i '/^---$/d' "$RUN_FILE"
sed -i '' '/^status:$/,/^  message:/d' "$RUN_FILE" 2>/dev/null || sed -i '/^status:$/,/^  message:/d' "$RUN_FILE"

cat >> "$RUN_FILE" << EOF

# Completion (OTel)
end_time: "$END_TIME"
end_time_unix_nano: $END_TIME_UNIX_NANO
duration_ms: $DURATION_MS

# Status (OTel StatusCode)
status:
  code: "$OTEL_STATUS"
  message: |
    $RESULT_SUMMARY
---
EOF

# Remove pending file
rm "$PENDING_FILE"

# Emit completion event to WebSocket queue
EVENT_TYPE="agent:complete"
[[ "$OTEL_STATUS" == "ERROR" ]] && EVENT_TYPE="agent:error"

EVENT_PAYLOAD=$(cat << PAYLOAD
{"trace_id":"$TRACE_ID","operation":"$OPERATION","duration_ms":$DURATION_MS,"status_code":"$OTEL_STATUS"}
PAYLOAD
)
"$SCRIPT_DIR/events/emit.sh" "$EVENT_TYPE" "$SPAN_ID" "$EVENT_PAYLOAD" 2>/dev/null || true

echo "─────────────────────────────────────────────────"
echo "SPAN CAPTURED (OTel-Compatible)"
echo "─────────────────────────────────────────────────"
echo "Trace:    $TRACE_ID"
echo "Span:     $SPAN_ID"
echo "Op:       $OPERATION"
echo "Duration: ${DURATION_MS}ms"
echo "Status:   $OTEL_STATUS"
echo "─────────────────────────────────────────────────"
