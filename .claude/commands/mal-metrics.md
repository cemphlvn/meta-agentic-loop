---
description: Trace-derived metrics for engineering improvements
allowed-tools: Bash(bash:*)
argument-hint: [metric-type]
---

# /mal-metrics — Engineering Metrics

!`bash -c '
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-/Users/cem/humanitic/plugin}"
RUNS_DIR="$PLUGIN_ROOT/observability/agent-trace/runs"
METRIC="${1:-all}"

count_files() {
    ls "$1"/*.yaml 2>/dev/null | wc -l | tr -d " "
}

case "$METRIC" in
    determinism)
        echo "═══ DETERMINISM METRICS ═══"
        echo ""
        TOTAL=$(count_files "$RUNS_DIR")
        if [ "$TOTAL" -gt 0 ]; then
            VALIDATED=$(grep -l "validation.status: \"passed\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            WARNED=$(grep -l "validation.status: \"warned\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            RATE=$((VALIDATED * 100 / (VALIDATED + WARNED + 1)))
            echo "Validated spawns: $VALIDATED"
            echo "Warned spawns:    $WARNED"
            echo "Validation rate:  ${RATE}%"
            echo ""
            [ $RATE -eq 100 ] && echo "✓ TARGET MET: 100% validation" || echo "⚠ TARGET: 100%"
        else
            echo "(No data - run agents first)"
        fi
        ;;
    lineage)
        echo "═══ LINEAGE METRICS ═══"
        echo ""
        TOTAL=$(count_files "$RUNS_DIR")
        if [ "$TOTAL" -gt 0 ]; then
            WITH_PARENT=$(grep -l "parent_span_id: \"[a-f0-9]" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            ROOTS=$(grep -l "parent_span_id: null\|parent_span_id: \"null\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            COVERAGE=$(( (WITH_PARENT + ROOTS) * 100 / TOTAL ))
            echo "Total spans:      $TOTAL"
            echo "Root spans:       $ROOTS"
            echo "With parent:      $WITH_PARENT"
            echo "Lineage coverage: ${COVERAGE}%"
            echo ""
            [ $COVERAGE -eq 100 ] && echo "✓ TARGET MET: Complete lineage" || echo "⚠ TARGET: 100%"
        else
            echo "(No data - run agents first)"
        fi
        ;;
    success)
        echo "═══ SUCCESS METRICS ═══"
        echo ""
        TOTAL=$(count_files "$RUNS_DIR")
        if [ "$TOTAL" -gt 0 ]; then
            OK=$(grep -l "code: \"OK\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            ERROR=$(grep -l "code: \"ERROR\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            COMPLETED=$((OK + ERROR))
            [ $COMPLETED -gt 0 ] && RATE=$((OK * 100 / COMPLETED)) || RATE=0
            echo "Successful: $OK"
            echo "Failed:     $ERROR"
            echo "Success rate: ${RATE}%"
            echo ""
            [ $RATE -ge 95 ] && echo "✓ TARGET MET: >=95% success" || echo "⚠ TARGET: >=95%"
        else
            echo "(No data - run agents first)"
        fi
        ;;
    latency)
        echo "═══ LATENCY METRICS ═══"
        echo ""
        if [ -d "$RUNS_DIR" ]; then
            DURATIONS=$(grep "^duration_ms:" "$RUNS_DIR"/*.yaml 2>/dev/null | sed "s/.*duration_ms: //" | grep -v null | sort -n)
            if [ -n "$DURATIONS" ]; then
                COUNT=$(echo "$DURATIONS" | wc -l | tr -d " ")
                MIN=$(echo "$DURATIONS" | head -1)
                MAX=$(echo "$DURATIONS" | tail -1)
                SUM=$(echo "$DURATIONS" | awk "{sum+=\$1} END {print sum}")
                AVG=$((SUM / COUNT))
                echo "Count:  $COUNT"
                echo "Min:    ${MIN}ms"
                echo "Max:    ${MAX}ms"
                echo "Avg:    ${AVG}ms"
            else
                echo "(No duration data)"
            fi
        else
            echo "(No data - run agents first)"
        fi
        ;;
    all)
        echo "═══ ALL METRICS ═══"
        echo ""
        # Inline each metric (cannot use $0 in bash -c)
        echo "── DETERMINISM ──"
        TOTAL=$(count_files "$RUNS_DIR")
        if [ "$TOTAL" -gt 0 ]; then
            VALIDATED=$(grep -l "validation.status: \"passed\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            WARNED=$(grep -l "validation.status: \"warned\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            RATE=$((VALIDATED * 100 / (VALIDATED + WARNED + 1)))
            echo "Validation rate: ${RATE}%"
        else
            echo "(no data)"
        fi
        echo ""
        echo "── LINEAGE ──"
        if [ "$TOTAL" -gt 0 ]; then
            WITH_PARENT=$(grep -l "parent_span_id: \"[a-f0-9]" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            ROOTS=$(grep -l "parent_span_id: null\|parent_span_id: \"null\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            COVERAGE=$(( (WITH_PARENT + ROOTS) * 100 / TOTAL ))
            echo "Lineage coverage: ${COVERAGE}%"
        else
            echo "(no data)"
        fi
        echo ""
        echo "── SUCCESS ──"
        if [ "$TOTAL" -gt 0 ]; then
            OK=$(grep -l "code: \"OK\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            ERROR=$(grep -l "code: \"ERROR\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
            COMPLETED=$((OK + ERROR))
            [ $COMPLETED -gt 0 ] && RATE=$((OK * 100 / COMPLETED)) || RATE=0
            echo "Success rate: ${RATE}%"
        else
            echo "(no data)"
        fi
        echo ""
        echo "── LATENCY ──"
        if [ -d "$RUNS_DIR" ]; then
            DURATIONS=$(grep "^duration_ms:" "$RUNS_DIR"/*.yaml 2>/dev/null | sed "s/.*duration_ms: //" | grep -v null | sort -n)
            if [ -n "$DURATIONS" ]; then
                COUNT=$(echo "$DURATIONS" | wc -l | tr -d " ")
                SUM=$(echo "$DURATIONS" | awk "{sum+=\$1} END {print sum}")
                AVG=$((SUM / COUNT))
                echo "Avg latency: ${AVG}ms ($COUNT samples)"
            else
                echo "(no duration data)"
            fi
        else
            echo "(no data)"
        fi
        ;;
    *)
        echo "Usage: /mal-metrics [determinism|lineage|success|latency|all]"
        echo ""
        echo "Metrics:"
        echo "  determinism  Spawn validation rates"
        echo "  lineage      Parent-child tracking"
        echo "  success      Success/failure rates"
        echo "  latency      Duration distribution"
        echo "  all          All metrics (default)"
        ;;
esac
' -- "$1" 2>&1 || echo "METRICS_ERROR"`

Analyze the metrics above and provide engineering improvement recommendations.
