---
description: Real-time agent observability dashboard
allowed-tools: Bash(bash:*)
argument-hint: [mode]
---

# /mal-observe — Observability Dashboard

Mode: $1

!`bash -c '
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-/Users/cem/humanitic/plugin}"
TRACE_DIR="$PLUGIN_ROOT/observability/agent-trace"
MODE="${1:-summary}"

case "$MODE" in
    live)
        echo "═══ LIVE EVENT STREAM ═══"
        echo "(showing last 10 events)"
        bash "$TRACE_DIR/commands/events.sh" --limit 10
        ;;
    summary)
        echo "═══ AGENT TRACE SUMMARY ═══"
        echo ""
        bash "$TRACE_DIR/commands/stats.sh" 2>/dev/null || echo "(no stats yet)"
        echo ""
        echo "═══ PENDING SPANS ═══"
        PENDING=$(ls "$TRACE_DIR/pending/"*.yaml 2>/dev/null | wc -l | tr -d " ")
        echo "$PENDING agents in-flight"
        echo ""
        echo "═══ RECENT EVENTS ═══"
        bash "$TRACE_DIR/commands/events.sh" --limit 5 2>/dev/null || echo "(no events)"
        ;;
    health)
        echo "═══ OBSERVABILITY HEALTH ═══"
        echo ""
        echo "Infrastructure:"
        test -f "$TRACE_DIR/schema.yaml" && echo "  ✓ Schema" || echo "  ✗ Schema MISSING"
        test -f "$TRACE_DIR/validate-spawn.sh" && echo "  ✓ PreToolUse hook" || echo "  ✗ PreToolUse MISSING"
        test -f "$TRACE_DIR/capture-result.sh" && echo "  ✓ PostToolUse hook" || echo "  ✗ PostToolUse MISSING"
        test -f "$PLUGIN_ROOT/hooks/hooks.json" && echo "  ✓ Hooks config" || echo "  ✗ Hooks MISSING"
        echo ""
        echo "Data:"
        RUNS=$(ls "$TRACE_DIR/runs/"*.yaml 2>/dev/null | wc -l | tr -d " ")
        EVENTS=$(wc -l < "$TRACE_DIR/events/queue.jsonl" 2>/dev/null | tr -d " " || echo 0)
        echo "  Completed spans: $RUNS"
        echo "  Events logged: $EVENTS"
        ;;
    pending)
        echo "═══ PENDING SPANS ═══"
        ls -la "$TRACE_DIR/pending/" 2>/dev/null || echo "No pending spans"
        ;;
    *)
        echo "Usage: /mal-observe [live|summary|health|pending]"
        echo ""
        echo "Modes:"
        echo "  summary  - Quick dashboard (default)"
        echo "  live     - Recent events"
        echo "  health   - Infrastructure check"
        echo "  pending  - In-flight agents"
        ;;
esac
' -- "$1" 2>&1 || echo "OBSERVE_ERROR"`

Present the observability status above. Highlight any issues that need attention.
