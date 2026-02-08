---
description: Trace-derived metrics for engineering improvements
allowed-tools: Bash(bash:*)
argument-hint: [metric-type]
---

# /mal-metrics — Engineering Metrics

!`bash ${CLAUDE_PLUGIN_ROOT:-/Users/cem/humanitic/plugin}/observability/agent-trace/commands/metrics.sh $ARGUMENTS 2>&1 || echo "METRICS_ERROR"`

Analyze the metrics above and provide engineering improvement recommendations.

If METRICS_ERROR appeared:
- Check if observability infrastructure is set up
- Run `/mal-observe health` to diagnose
- Ensure trace data exists in runs/ directory
