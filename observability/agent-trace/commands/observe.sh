#!/usr/bin/env bash
# observe.sh — Real-time observability dashboard
#
# Usage: observe.sh [summary|health|pending|events]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNS_DIR="$TRACE_DIR/runs"
EVENTS_FILE="$TRACE_DIR/events/queue.jsonl"
MODE="${1:-summary}"

case "$MODE" in
    summary)
        echo "═══ AGENT TRACE SUMMARY ═══"
        echo ""
        bash "$SCRIPT_DIR/stats.sh" 2>/dev/null || echo "(no stats yet)"
        echo ""
        echo "═══ PENDING SPANS ═══"
        # Count spans without duration (still running)
        if [ -d "$RUNS_DIR" ]; then
            PENDING=$(grep -l "duration_ms: null" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            echo "$PENDING agents in-flight"
        else
            echo "0 agents in-flight"
        fi
        echo ""
        echo "═══ RECENT EVENTS ═══"
        bash "$SCRIPT_DIR/events.sh" 5 2>/dev/null || echo "(no events yet)"
        ;;
    health)
        echo "═══ OBSERVABILITY HEALTH ═══"
        echo ""
        echo "Infrastructure:"
        [ -d "$TRACE_DIR" ] && echo "  ✓ Trace directory" || echo "  ✗ Trace directory"
        [ -d "$RUNS_DIR" ] && echo "  ✓ Runs directory" || echo "  ✗ Runs directory"
        [ -f "$EVENTS_FILE" ] && echo "  ✓ Events queue" || echo "  ✗ Events queue"
        [ -f "$TRACE_DIR/validate-spawn.sh" ] && echo "  ✓ Validate script" || echo "  ✗ Validate script"
        [ -f "$TRACE_DIR/capture-result.sh" ] && echo "  ✓ Capture script" || echo "  ✗ Capture script"
        echo ""
        echo "Data:"
        SPAN_COUNT=$(ls "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
        EVENT_COUNT=$(wc -l < "$EVENTS_FILE" 2>/dev/null | tr -d " " || echo "0")
        echo "  Spans:  $SPAN_COUNT"
        echo "  Events: $EVENT_COUNT"
        ;;
    pending)
        echo "═══ PENDING AGENTS ═══"
        echo ""
        if [ -d "$RUNS_DIR" ]; then
            PENDING_FILES=$(grep -l "duration_ms: null" "$RUNS_DIR"/*.yaml 2>/dev/null || true)
            if [ -n "$PENDING_FILES" ]; then
                for f in $PENDING_FILES; do
                    span_id=$(grep "^span_id:" "$f" | sed 's/span_id: //' | tr -d '"' | tr -d ' ')
                    operation=$(grep "^operation_name:" "$f" | sed 's/operation_name: //' | tr -d '"' | tr -d ' ')
                    start=$(grep "^start_time:" "$f" | sed 's/start_time: //' | tr -d '"' | tr -d ' ')
                    echo "[$span_id] $operation (started: $start)"
                done
            else
                echo "(no pending agents)"
            fi
        else
            echo "(no runs directory)"
        fi
        ;;
    events)
        echo "═══ EVENT STREAM ═══"
        echo ""
        bash "$SCRIPT_DIR/events.sh" 20 2>/dev/null || echo "(no events)"
        ;;
    *)
        echo "Usage: observe.sh [summary|health|pending|events]"
        echo ""
        echo "Modes:"
        echo "  summary   Overview with stats, pending, recent events (default)"
        echo "  health    Infrastructure health check"
        echo "  pending   List in-flight agents"
        echo "  events    Recent event stream"
        ;;
esac
