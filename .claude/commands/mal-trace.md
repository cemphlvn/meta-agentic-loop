---
description: Query OTel-compatible agent traces
allowed-tools: Bash, Read
argument-hint: [subcommand] [args...]
---

# /mal-trace — Agent Trace Query

Query and visualize agent execution traces with OTel-compatible spans.

## Subcommands

Based on argument $1, execute the appropriate trace query:

### runs [agent_id] [--limit N]
```bash
!`${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/commands/runs.sh $2 $3 $4`
```

### stats [agent_id]
```bash
!`${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/commands/stats.sh $2`
```

### lineage <trace_id> [--format ascii|mermaid|json]
```bash
!`${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/commands/lineage.sh $2 $3`
```

### events [--limit N] [--type TYPE]
```bash
!`${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/commands/events.sh $2 $3 $4`
```

### span <span_id>
Show full details of a specific span by reading the YAML file.

## Usage Examples

- `/mal-trace runs` — List recent agent runs
- `/mal-trace stats explore` — Stats for explore agent
- `/mal-trace lineage abc123 --format mermaid` — Mermaid diagram
- `/mal-trace events --limit 10` — Recent events

## Schema Reference

See `observability/agent-trace/schema.yaml` for OTel field definitions.
