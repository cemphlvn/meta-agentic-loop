#!/bin/bash
# lineage.sh — Show agent spawn hierarchy
#
# Usage: lineage.sh [trace_id] [--format ascii|mermaid|json]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNS_DIR="$TRACE_DIR/runs"

TRACE_ID="${1:-${CLAUDE_TRACE_ID:-}}"
FORMAT="${2:-ascii}"

# Remove -- prefix from format
FORMAT="${FORMAT#--format }"
FORMAT="${FORMAT#--format=}"

if [[ -z "$TRACE_ID" ]]; then
    echo "Usage: lineage.sh <trace_id> [--format ascii|mermaid|json]"
    echo ""
    echo "Available traces:"
    grep -h "^trace_id:" "$RUNS_DIR"/*.yaml 2>/dev/null | sort -u | sed 's/trace_id: /  /' | tr -d '"' || echo "  (no traces found)"
    exit 1
fi

# Find all spans for this trace
SPANS=$(grep -l "trace_id: \"$TRACE_ID\"" "$RUNS_DIR"/*.yaml 2>/dev/null || true)

if [[ -z "$SPANS" ]]; then
    echo "No spans found for trace: $TRACE_ID"
    exit 1
fi

# Build hierarchy
case "$FORMAT" in
    mermaid)
        echo "graph TD"
        for span_file in $SPANS; do
            span_id=$(grep "^span_id:" "$span_file" | sed 's/span_id: //' | tr -d '"' | tr -d ' ')
            parent=$(grep "^parent_span_id:" "$span_file" | sed 's/parent_span_id: //' | tr -d '"' | tr -d ' ')
            operation=$(grep "^operation_name:" "$span_file" | sed 's/operation_name: //' | tr -d '"' | tr -d ' ')
            status=$(grep "^  code:" "$span_file" | head -1 | sed 's/  code: //' | tr -d '"' | tr -d ' ')

            # Node style based on status
            style=""
            [[ "$status" == "OK" ]] && style=":::success"
            [[ "$status" == "ERROR" ]] && style=":::error"

            # Short span_id for display
            short_span="${span_id:0:8}"

            if [[ -n "$parent" && "$parent" != "null" ]]; then
                short_parent="${parent:0:8}"
                echo "    ${short_parent}[\"...\"] --> ${short_span}[\"$operation\"]$style"
            else
                echo "    ${short_span}[\"$operation (root)\"]$style"
            fi
        done
        echo ""
        echo "classDef success fill:#90EE90"
        echo "classDef error fill:#FFB6C1"
        ;;

    json)
        echo "["
        first=true
        for span_file in $SPANS; do
            [[ "$first" != "true" ]] && echo ","
            first=false

            span_id=$(grep "^span_id:" "$span_file" | sed 's/span_id: //' | tr -d '"' | tr -d ' ')
            parent=$(grep "^parent_span_id:" "$span_file" | sed 's/parent_span_id: //' | tr -d '"' | tr -d ' ')
            operation=$(grep "^operation_name:" "$span_file" | sed 's/operation_name: //' | tr -d '"' | tr -d ' ')
            duration=$(grep "^duration_ms:" "$span_file" | sed 's/duration_ms: //' | tr -d ' ')
            status=$(grep "^  code:" "$span_file" | head -1 | sed 's/  code: //' | tr -d '"' | tr -d ' ')

            echo -n "{\"span_id\":\"$span_id\",\"parent_span_id\":\"${parent:-null}\",\"operation\":\"$operation\",\"duration_ms\":$duration,\"status\":\"$status\"}"
        done
        echo ""
        echo "]"
        ;;

    ascii|*)
        echo "═══════════════════════════════════════════════════════"
        echo "TRACE LINEAGE: ${TRACE_ID:0:16}..."
        echo "═══════════════════════════════════════════════════════"
        echo ""

        # Find root spans (no parent)
        for span_file in $SPANS; do
            parent=$(grep "^parent_span_id:" "$span_file" | sed 's/parent_span_id: //' | tr -d '"' | tr -d ' ')
            if [[ -z "$parent" || "$parent" == "null" ]]; then
                span_id=$(grep "^span_id:" "$span_file" | sed 's/span_id: //' | tr -d '"' | tr -d ' ')
                operation=$(grep "^operation_name:" "$span_file" | sed 's/operation_name: //' | tr -d '"' | tr -d ' ')
                duration=$(grep "^duration_ms:" "$span_file" | sed 's/duration_ms: //' | tr -d ' ')
                status=$(grep "^  code:" "$span_file" | head -1 | sed 's/  code: //' | tr -d '"' | tr -d ' ')

                status_icon="○"
                [[ "$status" == "OK" ]] && status_icon="✓"
                [[ "$status" == "ERROR" ]] && status_icon="✗"

                echo "[$status_icon] $operation (${duration}ms)"
                echo "    └─ span: ${span_id:0:8}..."

                # Find children
                for child_file in $SPANS; do
                    child_parent=$(grep "^parent_span_id:" "$child_file" | sed 's/parent_span_id: //' | tr -d '"' | tr -d ' ')
                    if [[ "$child_parent" == "$span_id" ]]; then
                        child_span=$(grep "^span_id:" "$child_file" | sed 's/span_id: //' | tr -d '"' | tr -d ' ')
                        child_op=$(grep "^operation_name:" "$child_file" | sed 's/operation_name: //' | tr -d '"' | tr -d ' ')
                        child_dur=$(grep "^duration_ms:" "$child_file" | sed 's/duration_ms: //' | tr -d ' ')
                        child_status=$(grep "^  code:" "$child_file" | head -1 | sed 's/  code: //' | tr -d '"' | tr -d ' ')

                        child_icon="○"
                        [[ "$child_status" == "OK" ]] && child_icon="✓"
                        [[ "$child_status" == "ERROR" ]] && child_icon="✗"

                        echo "        └─ [$child_icon] $child_op (${child_dur}ms)"
                        echo "            └─ span: ${child_span:0:8}..."
                    fi
                done
            fi
        done
        echo ""
        ;;
esac
