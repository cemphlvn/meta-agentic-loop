#!/usr/bin/env bash
# audit.sh — Workflow observability audit
#
# Usage: audit.sh [full|coverage|opportunities|evolution]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_ROOT="$(cd "$TRACE_DIR/../.." && pwd)"
RUNS_DIR="$TRACE_DIR/runs"
AUDIT_DIR="$PLUGIN_ROOT/observability/workflow-audit"
MODE="${1:-full}"

case "$MODE" in
    full)
        echo "═══ FULL OBSERVABILITY AUDIT ═══"
        echo ""
        echo "Infrastructure:"
        [ -d "$TRACE_DIR" ] && echo "  ✓ Agent trace" || echo "  ✗ Agent trace"
        [ -d "$AUDIT_DIR" ] && echo "  ✓ Workflow audit" || echo "  ✗ Workflow audit"
        [ -f "$PLUGIN_ROOT/hooks/hooks.json" ] && echo "  ✓ Hooks config" || echo "  ✗ Hooks config"
        echo ""
        echo "Hooks Integration:"
        if [ -f "$PLUGIN_ROOT/hooks/hooks.json" ]; then
            TOTAL_HOOKS=$(grep -c "\"command\":" "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null || echo 0)
            TRACE_HOOKS=$(grep -c "agent-trace" "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null || echo 0)
            echo "  Total hooks:  $TOTAL_HOOKS"
            echo "  Trace hooks:  $TRACE_HOOKS"
        fi
        echo ""
        echo "Data Volume:"
        SPAN_COUNT=$(ls "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
        echo "  Spans collected: $SPAN_COUNT"
        ;;
    coverage)
        echo "═══ OBSERVABILITY COVERAGE ═══"
        echo ""
        if [ -f "$PLUGIN_ROOT/hooks/hooks.json" ]; then
            TOTAL_HOOKS=$(grep -c "\"command\":" "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null || echo 0)
            TRACE_HOOKS=$(grep -c "agent-trace" "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null || echo 0)
            if [ "$TOTAL_HOOKS" -gt 0 ]; then
                COVERAGE=$((TRACE_HOOKS * 100 / TOTAL_HOOKS))
                echo "Hook coverage: ${COVERAGE}% ($TRACE_HOOKS/$TOTAL_HOOKS hooks with tracing)"
            else
                echo "Hook coverage: N/A (no hooks configured)"
            fi
        else
            echo "(No hooks.json found)"
        fi
        ;;
    opportunities)
        echo "═══ IMPROVEMENT OPPORTUNITIES ═══"
        echo ""
        if [ -d "$AUDIT_DIR/opportunities" ]; then
            for f in "$AUDIT_DIR/opportunities/"*.yaml; do
                [ -f "$f" ] || continue
                echo "---"
                grep -E "^(id|title|priority|status):" "$f"
            done
        else
            echo "(No opportunities directory)"
        fi
        ;;
    evolution)
        echo "═══ OBSERVABILITY EVOLUTION ═══"
        echo ""
        echo "Trajectory: ad-hoc → observable → adaptive → flourishing"
        echo ""
        SPANS=$(ls "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
        if [ "$SPANS" -gt 100 ]; then
            echo "Current stage: adaptive ($SPANS spans)"
        elif [ "$SPANS" -gt 10 ]; then
            echo "Current stage: observable ($SPANS spans)"
        elif [ "$SPANS" -gt 0 ]; then
            echo "Current stage: emerging ($SPANS spans)"
        else
            echo "Current stage: ad-hoc (no spans yet)"
        fi
        ;;
    *)
        echo "Usage: audit.sh [full|coverage|opportunities|evolution]"
        echo ""
        echo "Modes:"
        echo "  full          Complete audit (default)"
        echo "  coverage      Observability coverage metrics"
        echo "  opportunities List improvement opportunities"
        echo "  evolution     Show evolution trajectory"
        echo ""
        echo "Philosophy: Intelligent adaptation WITH clear observability"
        ;;
esac
