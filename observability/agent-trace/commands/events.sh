#!/bin/bash
# events.sh — Show/tail event queue
#
# Usage: events.sh [--tail] [--limit N] [--type TYPE]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
EVENT_QUEUE="$TRACE_DIR/events/queue.jsonl"

TAIL=false
LIMIT=20
TYPE_FILTER=""

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --tail|-f)
            TAIL=true
            shift
            ;;
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        --type)
            TYPE_FILTER="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

if [[ ! -f "$EVENT_QUEUE" ]]; then
    echo "No events in queue"
    exit 0
fi

if [[ "$TAIL" == "true" ]]; then
    echo "Watching agent events (Ctrl+C to stop)..."
    echo "─────────────────────────────────────────────────"
    tail -f "$EVENT_QUEUE" | while read -r line; do
        event_type=$(echo "$line" | sed 's/.*"event_type":"\([^"]*\)".*/\1/')
        span_id=$(echo "$line" | sed 's/.*"span_id":"\([^"]*\)".*/\1/')
        timestamp=$(echo "$line" | sed 's/.*"timestamp":"\([^"]*\)".*/\1/')

        [[ -n "$TYPE_FILTER" && "$event_type" != "$TYPE_FILTER" ]] && continue

        # Icon based on event type
        case "$event_type" in
            agent:spawn) icon=">" ;;
            agent:complete) icon="+" ;;
            agent:error) icon="!" ;;
            *) icon="-" ;;
        esac

        echo "$icon ${timestamp:11:8} [$event_type] ${span_id:0:8}..."
    done
else
    echo "─────────────────────────────────────────────────"
    echo "RECENT EVENTS (last $LIMIT)"
    echo "─────────────────────────────────────────────────"

    tail -$LIMIT "$EVENT_QUEUE" | while read -r line; do
        # macOS compatible JSON parsing using sed
        event_type=$(echo "$line" | sed 's/.*"event_type":"\([^"]*\)".*/\1/' || echo "unknown")
        span_id=$(echo "$line" | sed 's/.*"span_id":"\([^"]*\)".*/\1/' || echo "unknown")
        timestamp=$(echo "$line" | sed 's/.*"timestamp":"\([^"]*\)".*/\1/' || echo "unknown")

        [[ -n "$TYPE_FILTER" && "$event_type" != "$TYPE_FILTER" ]] && continue

        printf "%-16s %-16s %s\n" "[$event_type]" "${span_id:0:14}..." "${timestamp:0:19}"
    done
fi
