# /trace — Agent Trace Query Commands

Query and visualize agent execution traces.

## Commands

### /trace lineage [trace_id]
Show parent-child agent spawn relationships.
- If trace_id omitted, uses current session's CLAUDE_TRACE_ID
- Output: Mermaid DAG or ASCII tree

### /trace runs [agent_id] [--limit N]
List completed agent runs.
- Filter by agent_id if provided
- Shows: span_id, operation, duration_ms, status
- Default limit: 20

### /trace pending
Show in-flight (pending) agent runs.

### /trace span <span_id>
Show full details of a specific span.
- All OTel fields
- Task description
- Attributes

### /trace stats [agent_id]
Aggregate statistics.
- Total runs, success rate, avg duration
- By agent if agent_id provided

### /trace events [--tail] [--limit N]
Show event queue.
- --tail: Follow new events (like tail -f)
- agent:spawn, agent:complete, agent:error

## Output Formats

Use `--format` flag:
- `ascii` (default): Human-readable tables
- `json`: Machine-parseable JSONL
- `mermaid`: Mermaid diagram syntax

## Examples

```bash
# Show current session's agent hierarchy
/trace lineage

# Find slowest agents
/trace stats | sort by duration

# Watch live agent activity
/trace events --tail

# Get details of a failed run
/trace span abc123def456
```

## Implementation

Scripts in `observability/agent-trace/commands/`:
- `lineage.sh`
- `runs.sh`
- `pending.sh`
- `span.sh`
- `stats.sh`
- `events.sh`
