#!/usr/bin/env bash
# stats.sh — Aggregate agent trace statistics
# Compatible with bash 3.2 (macOS default)
#
# Usage: stats.sh [agent_id] [--format ascii|json]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNS_DIR="$TRACE_DIR/runs"

AGENT_FILTER=""
FORMAT="ascii"

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
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

if [[ ! -d "$RUNS_DIR" ]] || [[ -z "$(ls -A "$RUNS_DIR" 2>/dev/null)" ]]; then
    echo "No runs found"
    exit 0
fi

# Collect unique operations
operations=$(grep -h "^operation_name:" "$RUNS_DIR"/*.yaml 2>/dev/null | sed 's/operation_name: //' | tr -d '"' | tr -d ' ' | sort -u)

case "$FORMAT" in
    json)
        echo "["
        first=true
        for op in $operations; do
            [[ -n "$AGENT_FILTER" && "$op" != "$AGENT_FILTER" ]] && continue

            # Count spans for this operation
            op_files=$(grep -l "operation_name: \"$op\"" "$RUNS_DIR"/*.yaml 2>/dev/null || true)
            [[ -z "$op_files" ]] && continue

            count=0
            success=0
            error=0
            total_duration=0

            for f in $op_files; do
                status=$(grep "^  code:" "$f" 2>/dev/null | head -1 | sed 's/  code: //' | tr -d '"' | tr -d ' ')
                [[ "$status" == "UNSET" || -z "$status" ]] && continue

                count=$((count + 1))
                [[ "$status" == "OK" ]] && success=$((success + 1))
                [[ "$status" == "ERROR" ]] && error=$((error + 1))

                dur=$(grep "^duration_ms:" "$f" 2>/dev/null | sed 's/duration_ms: //' | tr -d ' ')
                [[ -n "$dur" && "$dur" != "null" ]] && total_duration=$((total_duration + dur))
            done

            [[ $count -eq 0 ]] && continue

            avg=$((total_duration / count))
            rate=$(echo "scale=1; $success * 100 / $count" | bc 2>/dev/null || echo "0")

            [[ "$first" != "true" ]] && echo ","
            first=false
            echo -n "{\"operation\":\"$op\",\"count\":$count,\"success\":$success,\"error\":$error,\"success_rate\":\"$rate%\",\"avg_duration_ms\":$avg}"
        done
        echo ""
        echo "]"
        ;;

    ascii|*)
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo "AGENT TRACE STATISTICS"
        [[ -n "$AGENT_FILTER" ]] && echo "Filter: $AGENT_FILTER"
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo ""

        printf "%-20s %8s %8s %8s %10s %12s\n" "OPERATION" "RUNS" "OK" "ERROR" "SUCCESS%" "AVG(ms)"
        echo "─────────────────────────────────────────────────────────────────────────────"

        total_runs=0
        total_success=0
        total_error=0

        for op in $operations; do
            [[ -n "$AGENT_FILTER" && "$op" != "$AGENT_FILTER" ]] && continue

            op_files=$(grep -l "operation_name: \"$op\"" "$RUNS_DIR"/*.yaml 2>/dev/null || true)
            [[ -z "$op_files" ]] && continue

            count=0
            success=0
            error=0
            total_duration=0

            for f in $op_files; do
                status=$(grep "^  code:" "$f" 2>/dev/null | head -1 | sed 's/  code: //' | tr -d '"' | tr -d ' ')
                [[ "$status" == "UNSET" || -z "$status" ]] && continue

                count=$((count + 1))
                [[ "$status" == "OK" ]] && success=$((success + 1))
                [[ "$status" == "ERROR" ]] && error=$((error + 1))

                dur=$(grep "^duration_ms:" "$f" 2>/dev/null | sed 's/duration_ms: //' | tr -d ' ')
                [[ -n "$dur" && "$dur" != "null" ]] && total_duration=$((total_duration + dur))
            done

            [[ $count -eq 0 ]] && continue

            avg=$((total_duration / count))
            rate=$(echo "scale=0; $success * 100 / $count" | bc 2>/dev/null || echo "0")

            printf "%-20s %8d %8d %8d %9d%% %12d\n" "$op" "$count" "$success" "$error" "$rate" "$avg"

            total_runs=$((total_runs + count))
            total_success=$((total_success + success))
            total_error=$((total_error + error))
        done

        echo "─────────────────────────────────────────────────────────────────────────────"
        if [[ $total_runs -gt 0 ]]; then
            total_rate=$(echo "scale=0; $total_success * 100 / $total_runs" | bc 2>/dev/null || echo "0")
            printf "%-20s %8d %8d %8d %9d%%\n" "TOTAL" "$total_runs" "$total_success" "$total_error" "$total_rate"
        fi
        echo ""
        ;;
esac
