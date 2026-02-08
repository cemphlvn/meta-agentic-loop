#!/bin/bash
# runs.sh — List completed agent runs
#
# Usage: runs.sh [agent_id] [--limit N] [--format ascii|json]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNS_DIR="$TRACE_DIR/runs"

AGENT_FILTER=""
LIMIT=20
FORMAT="ascii"

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        *)
            AGENT_FILTER="$1"
            shift
            ;;
    esac
done

if [[ ! -d "$RUNS_DIR" ]]; then
    echo "No runs directory found"
    exit 0
fi

# Get run files
if [[ -n "$AGENT_FILTER" ]]; then
    RUN_FILES=$(grep -l "operation_name: \"$AGENT_FILTER\"" "$RUNS_DIR"/*.yaml 2>/dev/null | head -$LIMIT || true)
else
    RUN_FILES=$(ls -t "$RUNS_DIR"/*.yaml 2>/dev/null | head -$LIMIT || true)
fi

if [[ -z "$RUN_FILES" ]]; then
    echo "No runs found"
    exit 0
fi

case "$FORMAT" in
    json)
        echo "["
        first=true
        for f in $RUN_FILES; do
            [[ "$first" != "true" ]] && echo ","
            first=false

            span_id=$(grep "^span_id:" "$f" | sed 's/span_id: //' | tr -d '"' | tr -d ' ')
            operation=$(grep "^operation_name:" "$f" | sed 's/operation_name: //' | tr -d '"' | tr -d ' ')
            duration=$(grep "^duration_ms:" "$f" | sed 's/duration_ms: //' | tr -d ' ')
            status=$(grep "^  code:" "$f" | head -1 | sed 's/  code: //' | tr -d '"' | tr -d ' ')
            start=$(grep "^start_time:" "$f" | sed 's/start_time: //' | tr -d '"' | tr -d ' ')

            echo -n "{\"span_id\":\"$span_id\",\"operation\":\"$operation\",\"start\":\"$start\",\"duration_ms\":$duration,\"status\":\"$status\"}"
        done
        echo ""
        echo "]"
        ;;

    ascii|*)
        printf "%-18s %-20s %-12s %-10s %s\n" "SPAN" "OPERATION" "DURATION" "STATUS" "START"
        echo "─────────────────────────────────────────────────────────────────────────────"

        for f in $RUN_FILES; do
            span_id=$(grep "^span_id:" "$f" | sed 's/span_id: //' | tr -d '"' | tr -d ' ')
            operation=$(grep "^operation_name:" "$f" | sed 's/operation_name: //' | tr -d '"' | tr -d ' ')
            duration=$(grep "^duration_ms:" "$f" | sed 's/duration_ms: //' | tr -d ' ')
            status=$(grep "^  code:" "$f" | head -1 | sed 's/  code: //' | tr -d '"' | tr -d ' ')
            start=$(grep "^start_time:" "$f" | sed 's/start_time: //' | tr -d '"' | tr -d ' ')

            # Format
            short_span="${span_id:0:16}..."
            short_start="${start:11:8}"  # Just time portion
            [[ "$duration" == "null" ]] && duration="pending"

            printf "%-18s %-20s %-12s %-10s %s\n" "$short_span" "$operation" "${duration}ms" "$status" "$short_start"
        done
        ;;
esac
