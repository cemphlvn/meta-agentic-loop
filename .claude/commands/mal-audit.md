---
description: Run observability workflow audit
allowed-tools: Bash(bash:*)
argument-hint: [mode]
---

# /mal-audit — Workflow Observability Audit

!`bash -c '
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-/Users/cem/humanitic/plugin}"
AUDIT_DIR="$PLUGIN_ROOT/observability/workflow-audit"
MODE="${1:-full}"

case "$MODE" in
    full)
        echo "═══ FULL OBSERVABILITY AUDIT ═══"
        echo ""
        if [ -f "$AUDIT_DIR/audit.sh" ]; then
            bash "$AUDIT_DIR/audit.sh"
        else
            echo "Audit script not found. Running inline audit..."
            echo ""
            echo "Infrastructure:"
            test -d "$PLUGIN_ROOT/observability/agent-trace" && echo "  ✓ Agent trace" || echo "  ✗ Agent trace"
            test -d "$AUDIT_DIR" && echo "  ✓ Workflow audit" || echo "  ✗ Workflow audit"
            test -f "$PLUGIN_ROOT/hooks/hooks.json" && echo "  ✓ Hooks config" || echo "  ✗ Hooks config"
        fi
        ;;
    coverage)
        echo "═══ OBSERVABILITY COVERAGE ═══"
        echo ""
        if [ -f "$AUDIT_DIR/audit.sh" ]; then
            bash "$AUDIT_DIR/audit.sh" coverage
        else
            # Inline coverage check
            TOTAL_HOOKS=$(grep -c "\"command\":" "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null || echo 0)
            TRACE_HOOKS=$(grep -c "agent-trace" "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null || echo 0)
            echo "Hook coverage: $TRACE_HOOKS/$TOTAL_HOOKS hooks with tracing"
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
        if [ -f "$AUDIT_DIR/audit.sh" ]; then
            bash "$AUDIT_DIR/audit.sh" evolution
        else
            # Inline evolution check
            SPANS=$(ls "$PLUGIN_ROOT/observability/agent-trace/runs/"*.yaml 2>/dev/null | wc -l | tr -d " ")
            if [ "$SPANS" -gt 100 ]; then
                echo "Current stage: adaptive ($SPANS spans)"
            elif [ "$SPANS" -gt 10 ]; then
                echo "Current stage: observable ($SPANS spans)"
            elif [ "$SPANS" -gt 0 ]; then
                echo "Current stage: emerging ($SPANS spans)"
            else
                echo "Current stage: ad-hoc (no spans yet)"
            fi
        fi
        ;;
    *)
        echo "Usage: /mal-audit [full|coverage|opportunities|evolution]"
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
' -- "$1" 2>&1 || echo "AUDIT_ERROR"`

Analyze the audit output above. For AUDIT_ERROR, run `/mal-observe health` to diagnose.
