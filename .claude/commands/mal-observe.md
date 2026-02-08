---
description: Real-time agent observability dashboard
allowed-tools: Bash, Read
argument-hint: [mode]
---

# /mal-observe — Real-time Observability

Monitor agent activity in real-time.

## Modes

### live (default)
Watch agent events as they happen:
```bash
!`${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/commands/events.sh --tail`
```

### summary
Current session summary:
```bash
!`echo "═══ AGENT TRACE SUMMARY ═══" && ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/commands/stats.sh && echo "" && echo "═══ PENDING SPANS ═══" && ls -1 ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/pending/*.yaml 2>/dev/null | wc -l | xargs -I{} echo "{} agents in-flight" && echo "" && echo "═══ RECENT EVENTS ═══" && ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/commands/events.sh --limit 5`
```

### pending
Show in-flight (pending) agent runs:
```bash
!`ls -la ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/pending/ 2>/dev/null || echo "No pending spans"`
```

### health
Check observability system health:
```bash
!`echo "Hooks: " && test -f ${CLAUDE_PLUGIN_ROOT}/hooks/hooks.json && echo "OK" || echo "MISSING" && echo "Runs dir: " && ls ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/ 2>/dev/null | wc -l | xargs -I{} echo "{} completed spans" && echo "Events queue: " && wc -l < ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/events/queue.jsonl 2>/dev/null || echo "0 events"`
```

## Usage

- `/mal-observe` — Start live event stream
- `/mal-observe summary` — Quick dashboard
- `/mal-observe health` — System health check
