---
description: Run observability workflow audit
allowed-tools: Bash(bash:*)
argument-hint: [mode]
---

# /mal-audit — Workflow Observability Audit

!`bash ${CLAUDE_PLUGIN_ROOT:-/Users/cem/humanitic/plugin}/observability/agent-trace/commands/audit.sh $ARGUMENTS 2>&1 || echo "AUDIT_ERROR"`

Analyze the audit output above. For AUDIT_ERROR, run `/mal-observe health` to diagnose.
