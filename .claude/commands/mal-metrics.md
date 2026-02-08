---
description: Derive metrics from agent traces for engineering improvements
allowed-tools: Bash, Read
argument-hint: [metric-type]
---

# /mal-metrics — Trace-Derived Metrics

Extract actionable metrics from agent traces to prove engineering improvements.

## Core Metrics

### determinism
Measure how deterministically agents are spawning:
```bash
!`echo "═══ DETERMINISM METRICS ═══" && echo "" && VALIDATED=$(grep -l "validation.status: \"passed\"" ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null | wc -l | tr -d ' ') && WARNED=$(grep -l "validation.status: \"warned\"" ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null | wc -l | tr -d ' ') && TOTAL=$((VALIDATED + WARNED)) && echo "Validated spawns: $VALIDATED" && echo "Warned spawns: $WARNED" && echo "Total: $TOTAL" && if [ $TOTAL -gt 0 ]; then RATE=$((VALIDATED * 100 / TOTAL)); echo "Validation rate: ${RATE}%"; fi && echo "" && echo "Orphan spans (no parent tracking):" && grep -l "parent_span_id: null" ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null | wc -l | tr -d ' '`
```

### latency
Agent execution latency distribution:
```bash
!`echo "═══ LATENCY METRICS ═══" && echo "" && echo "Duration distribution (ms):" && grep "^duration_ms:" ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null | sed 's/duration_ms: //' | sort -n | awk 'BEGIN{min=999999999;max=0;sum=0;count=0} {if($1!="null"){v=$1;if(v<min)min=v;if(v>max)max=v;sum+=v;count++}} END{if(count>0){avg=sum/count;print "  Min: "min"ms";print "  Max: "max"ms";print "  Avg: "int(avg)"ms";print "  Count: "count}else{print "  No data"}}'`
```

### success
Success/failure rates:
```bash
!`echo "═══ SUCCESS METRICS ═══" && echo "" && OK=$(grep -c "code: \"OK\"" ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null || echo 0) && ERROR=$(grep -c "code: \"ERROR\"" ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null || echo 0) && UNSET=$(grep -c "code: \"UNSET\"" ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null || echo 0) && TOTAL=$((OK + ERROR)) && echo "Successful: $OK" && echo "Failed: $ERROR" && echo "In-flight: $UNSET" && if [ $TOTAL -gt 0 ]; then RATE=$((OK * 100 / TOTAL)); echo "Success rate: ${RATE}%"; fi`
```

### lineage
Lineage completeness (parent-child tracking):
```bash
!`echo "═══ LINEAGE METRICS ═══" && echo "" && TOTAL=$(ls ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null | wc -l | tr -d ' ') && WITH_PARENT=$(grep -l "parent_span_id: \"[a-f0-9]" ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null | wc -l | tr -d ' ') && ROOTS=$(grep -l "parent_span_id: null" ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null | wc -l | tr -d ' ') && echo "Total spans: $TOTAL" && echo "With parent: $WITH_PARENT" && echo "Root spans: $ROOTS" && if [ $TOTAL -gt 0 ]; then LINKED=$((WITH_PARENT + ROOTS)); RATE=$((LINKED * 100 / TOTAL)); echo "Lineage coverage: ${RATE}%"; fi`
```

### all
Show all metrics:
```bash
!`${CLAUDE_PLUGIN_ROOT}/.claude/commands/mal-metrics.md determinism && echo "" && ${CLAUDE_PLUGIN_ROOT}/.claude/commands/mal-metrics.md latency && echo "" && ${CLAUDE_PLUGIN_ROOT}/.claude/commands/mal-metrics.md success && echo "" && ${CLAUDE_PLUGIN_ROOT}/.claude/commands/mal-metrics.md lineage`
```

## Derived Insights

These metrics enable:
1. **Validation Rate** — Are agents spawning through proper channels?
2. **Latency Distribution** — Where are bottlenecks?
3. **Success Rate** — What's the failure pattern?
4. **Lineage Coverage** — Is parent-child tracking working?

## Engineering Improvement Targets

| Metric | Current | Target | Action |
|--------|---------|--------|--------|
| Validation Rate | ? | 100% | Fix span_id passing |
| Lineage Coverage | ? | 100% | Ensure parent_span_id set |
| Success Rate | ? | >95% | Investigate failures |

## Usage

- `/mal-metrics determinism` — Validation metrics
- `/mal-metrics latency` — Timing distribution
- `/mal-metrics success` — Success/failure rates
- `/mal-metrics all` — Complete dashboard
