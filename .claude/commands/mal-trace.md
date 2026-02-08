---
description: Query OTel-compatible agent traces
allowed-tools: Bash(bash:*)
argument-hint: [subcommand] [args...]
---

# /mal-trace — Agent Trace Query

!`bash ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/commands/dispatch.sh $ARGUMENTS 2>&1 || echo "TRACE_ERROR"`

Analyze and present the trace output above.

If TRACE_ERROR appeared:
- Check if observability infrastructure is set up
- Run `/mal-observe health` to diagnose
- Ensure hooks are registered in hooks.json
