#!/usr/bin/env bash
# dispatch.sh — Route trace subcommands
#
# Usage: dispatch.sh <subcommand> [args...]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SUBCMD="${1:-help}"
shift 2>/dev/null || true

case "$SUBCMD" in
    runs)
        bash "$SCRIPT_DIR/runs.sh" "$@"
        ;;
    stats)
        bash "$SCRIPT_DIR/stats.sh" "$@"
        ;;
    lineage)
        bash "$SCRIPT_DIR/lineage.sh" "$@"
        ;;
    events)
        bash "$SCRIPT_DIR/events.sh" "$@"
        ;;
    span)
        SPAN_ID="${1:-}"
        if [[ -z "$SPAN_ID" ]]; then
            echo "ERROR: span_id required"
            echo "Usage: /mal-trace span <span_id>"
            exit 1
        fi
        SPAN_FILE="$TRACE_DIR/runs/$SPAN_ID.yaml"
        if [[ -f "$SPAN_FILE" ]]; then
            cat "$SPAN_FILE"
        else
            echo "ERROR: Span not found: $SPAN_ID"
            echo "Available spans:"
            ls "$TRACE_DIR/runs/"*.yaml 2>/dev/null | xargs -I{} basename {} .yaml | head -5
            exit 1
        fi
        ;;
    assess)
        bash "$TRACE_DIR/assess.sh"
        ;;
    help|*)
        echo "═══ /mal-trace — Agent Trace Query ═══"
        echo ""
        echo "Subcommands:"
        echo "  runs [agent_id] [--limit N]    List completed agent runs"
        echo "  stats [agent_id]               Aggregate statistics"
        echo "  lineage <trace_id> [--format]  Show spawn hierarchy"
        echo "  events [--limit N]             Show event queue"
        echo "  span <span_id>                 Show span details"
        echo "  assess                         Run full assessment"
        echo ""
        echo "Examples:"
        echo "  /mal-trace runs"
        echo "  /mal-trace stats librarian"
        echo "  /mal-trace lineage abc123 --format mermaid"
        ;;
esac
