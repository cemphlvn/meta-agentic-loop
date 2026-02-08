#!/usr/bin/env bash
# assess.sh — System functionality and observability assessment
#
# Evaluates current observability infrastructure against target state.
# Produces metrics that prove engineering improvements.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RUNS_DIR="$SCRIPT_DIR/runs"
PENDING_DIR="$SCRIPT_DIR/pending"
EVENTS_FILE="$SCRIPT_DIR/events/queue.jsonl"

echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║           AGENT TRACE OBSERVABILITY ASSESSMENT                             ║"
echo "║           $(date -u +%Y-%m-%dT%H:%M:%SZ)                                          ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""

#─────────────────────────────────────────────────────────────────────────────
# 1. INFRASTRUCTURE CHECK
#─────────────────────────────────────────────────────────────────────────────
echo "═══ 1. INFRASTRUCTURE STATUS ═══"
echo ""

check_file() {
    if [[ -f "$1" ]]; then
        echo "  ✓ $2"
        return 0
    else
        echo "  ✗ $2 (MISSING)"
        return 1
    fi
}

check_dir() {
    if [[ -d "$1" ]]; then
        echo "  ✓ $2"
        return 0
    else
        echo "  ✗ $2 (MISSING)"
        return 1
    fi
}

INFRA_SCORE=0
INFRA_TOTAL=8

check_file "$SCRIPT_DIR/schema.yaml" "OTel schema definition" && ((INFRA_SCORE++))
check_file "$SCRIPT_DIR/validate-spawn.sh" "PreToolUse hook script" && ((INFRA_SCORE++))
check_file "$SCRIPT_DIR/capture-result.sh" "PostToolUse hook script" && ((INFRA_SCORE++))
check_file "$SCRIPT_DIR/events/emit.sh" "Event emitter" && ((INFRA_SCORE++))
check_dir "$SCRIPT_DIR/commands" "Query commands" && ((INFRA_SCORE++))
check_file "$PLUGIN_ROOT/hooks/hooks.json" "Hooks configuration" && ((INFRA_SCORE++))
check_file "$PLUGIN_ROOT/.mcp.json" "MCP server config" && ((INFRA_SCORE++))
check_dir "$PLUGIN_ROOT/observability/mcp-server/node_modules" "MCP dependencies" && ((INFRA_SCORE++))

echo ""
echo "  Infrastructure: $INFRA_SCORE/$INFRA_TOTAL ($(( INFRA_SCORE * 100 / INFRA_TOTAL ))%)"
echo ""

#─────────────────────────────────────────────────────────────────────────────
# 2. DATA METRICS
#─────────────────────────────────────────────────────────────────────────────
echo "═══ 2. DATA METRICS ═══"
echo ""

# Count spans
COMPLETED_SPANS=$(ls "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d ' ')
PENDING_SPANS=$(ls "$PENDING_DIR"/*.yaml 2>/dev/null | wc -l | tr -d ' ')
EVENTS=$(wc -l < "$EVENTS_FILE" 2>/dev/null | tr -d ' ' || echo "0")

echo "  Completed spans: $COMPLETED_SPANS"
echo "  Pending spans:   $PENDING_SPANS"
echo "  Events logged:   $EVENTS"
echo ""

#─────────────────────────────────────────────────────────────────────────────
# 3. DETERMINISM METRICS
#─────────────────────────────────────────────────────────────────────────────
echo "═══ 3. DETERMINISM METRICS ═══"
echo ""

if [[ $COMPLETED_SPANS -gt 0 ]]; then
    VALIDATED=$(grep -l 'validation.status: "passed"' "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d ' ')
    WARNED=$(grep -l 'validation.status: "warned"' "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d ' ')

    TOTAL_VALIDATED=$((VALIDATED + WARNED))
    if [[ $TOTAL_VALIDATED -gt 0 ]]; then
        VALIDATION_RATE=$((VALIDATED * 100 / TOTAL_VALIDATED))
    else
        VALIDATION_RATE=0
    fi

    echo "  Validated spawns: $VALIDATED"
    echo "  Warned spawns:    $WARNED"
    echo "  Validation rate:  ${VALIDATION_RATE}%"
    echo ""

    # Target: 100% validation rate
    if [[ $VALIDATION_RATE -eq 100 ]]; then
        echo "  ✓ TARGET MET: All spawns validated"
    else
        echo "  ⚠ TARGET: 100% validation rate"
    fi
else
    echo "  (No spans to analyze)"
fi
echo ""

#─────────────────────────────────────────────────────────────────────────────
# 4. LINEAGE METRICS
#─────────────────────────────────────────────────────────────────────────────
echo "═══ 4. LINEAGE METRICS ═══"
echo ""

if [[ $COMPLETED_SPANS -gt 0 ]]; then
    WITH_PARENT=$(grep -l 'parent_span_id: "[a-f0-9]' "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d ' ')
    ROOT_SPANS=$(grep -l 'parent_span_id: "null"\|parent_span_id: null' "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d ' ')
    ORPHANS=$((COMPLETED_SPANS - WITH_PARENT - ROOT_SPANS))

    LINEAGE_COVERAGE=$(( (WITH_PARENT + ROOT_SPANS) * 100 / COMPLETED_SPANS ))

    echo "  Root spans:       $ROOT_SPANS"
    echo "  With parent:      $WITH_PARENT"
    echo "  Orphan spans:     $ORPHANS"
    echo "  Lineage coverage: ${LINEAGE_COVERAGE}%"
    echo ""

    # Target: 100% lineage coverage (no orphans)
    if [[ $ORPHANS -eq 0 ]]; then
        echo "  ✓ TARGET MET: Complete lineage tracking"
    else
        echo "  ⚠ TARGET: 0 orphan spans"
    fi
else
    echo "  (No spans to analyze)"
fi
echo ""

#─────────────────────────────────────────────────────────────────────────────
# 5. SUCCESS METRICS
#─────────────────────────────────────────────────────────────────────────────
echo "═══ 5. SUCCESS METRICS ═══"
echo ""

if [[ $COMPLETED_SPANS -gt 0 ]]; then
    OK=$(grep -l 'code: "OK"' "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d ' ')
    ERROR=$(grep -l 'code: "ERROR"' "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d ' ')

    TOTAL_COMPLETED=$((OK + ERROR))
    if [[ $TOTAL_COMPLETED -gt 0 ]]; then
        SUCCESS_RATE=$((OK * 100 / TOTAL_COMPLETED))
    else
        SUCCESS_RATE=0
    fi

    echo "  Successful: $OK"
    echo "  Failed:     $ERROR"
    echo "  Success rate: ${SUCCESS_RATE}%"
    echo ""

    # Target: >95% success rate
    if [[ $SUCCESS_RATE -ge 95 ]]; then
        echo "  ✓ TARGET MET: Success rate >= 95%"
    else
        echo "  ⚠ TARGET: >= 95% success rate"
    fi
else
    echo "  (No spans to analyze)"
fi
echo ""

#─────────────────────────────────────────────────────────────────────────────
# 6. LATENCY METRICS
#─────────────────────────────────────────────────────────────────────────────
echo "═══ 6. LATENCY METRICS ═══"
echo ""

if [[ $COMPLETED_SPANS -gt 0 ]]; then
    DURATIONS=$(grep "^duration_ms:" "$RUNS_DIR"/*.yaml 2>/dev/null | sed 's/.*duration_ms: //' | grep -v null | sort -n)

    if [[ -n "$DURATIONS" ]]; then
        COUNT=$(echo "$DURATIONS" | wc -l | tr -d ' ')
        MIN=$(echo "$DURATIONS" | head -1)
        MAX=$(echo "$DURATIONS" | tail -1)
        SUM=$(echo "$DURATIONS" | awk '{sum+=$1} END {print sum}')
        AVG=$((SUM / COUNT))

        # P95 approximation (95th percentile position)
        P95_POS=$(( COUNT * 95 / 100 ))
        [[ $P95_POS -lt 1 ]] && P95_POS=1
        P95=$(echo "$DURATIONS" | sed -n "${P95_POS}p")

        echo "  Count:  $COUNT"
        echo "  Min:    ${MIN}ms"
        echo "  Max:    ${MAX}ms"
        echo "  Avg:    ${AVG}ms"
        echo "  P95:    ${P95}ms"
    else
        echo "  (No duration data)"
    fi
else
    echo "  (No spans to analyze)"
fi
echo ""

#─────────────────────────────────────────────────────────────────────────────
# 7. HOOK INTEGRATION CHECK
#─────────────────────────────────────────────────────────────────────────────
echo "═══ 7. HOOK INTEGRATION ═══"
echo ""

HOOKS_OK=0
HOOKS_TOTAL=2

if grep -q "validate-spawn.sh" "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null; then
    echo "  ✓ PreToolUse hook registered"
    ((HOOKS_OK++))
else
    echo "  ✗ PreToolUse hook NOT registered"
fi

if grep -q "capture-result.sh" "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null; then
    echo "  ✓ PostToolUse hook registered"
    ((HOOKS_OK++))
else
    echo "  ✗ PostToolUse hook NOT registered"
fi

echo ""
echo "  Hooks: $HOOKS_OK/$HOOKS_TOTAL"
echo ""

#─────────────────────────────────────────────────────────────────────────────
# 8. MISSING COMPONENTS
#─────────────────────────────────────────────────────────────────────────────
echo "═══ 8. MISSING FOR FULL OBSERVABILITY ═══"
echo ""

echo "  Phase 1 (Critical):"
[[ -f /tmp/claude_spans/last_span ]] && echo "    ✓ Span passing (file-based)" || echo "    ⚠ Span passing not tested"
echo "    ⚠ Real-time WebSocket server (MCP is stdio only)"
echo "    ⚠ Browser client for visualization"
echo ""

echo "  Phase 2 (Visualization):"
echo "    ⚠ React + R3F-ForceGraph frontend"
echo "    ⚠ 3D agent hierarchy rendering"
echo "    ⚠ Time-travel debugging slider"
echo ""

echo "  Phase 3 (Advanced):"
echo "    ⚠ Token tracking per span"
echo "    ⚠ Cost aggregation"
echo "    ⚠ OTel collector export (Jaeger)"
echo ""

#─────────────────────────────────────────────────────────────────────────────
# SUMMARY
#─────────────────────────────────────────────────────────────────────────────
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                           ASSESSMENT SUMMARY                               ║"
echo "╠═══════════════════════════════════════════════════════════════════════════╣"
printf "║  Infrastructure:     %3d%%                                                 ║\n" $((INFRA_SCORE * 100 / INFRA_TOTAL))
printf "║  Hooks Integration:  %3d%%                                                 ║\n" $((HOOKS_OK * 100 / HOOKS_TOTAL))
if [[ $COMPLETED_SPANS -gt 0 ]]; then
printf "║  Validation Rate:    %3d%%  (target: 100%%)                                ║\n" "$VALIDATION_RATE"
printf "║  Lineage Coverage:   %3d%%  (target: 100%%)                                ║\n" "$LINEAGE_COVERAGE"
printf "║  Success Rate:       %3d%%  (target: >=95%%)                               ║\n" "$SUCCESS_RATE"
else
echo "║  (Run agents to generate metrics)                                         ║"
fi
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
