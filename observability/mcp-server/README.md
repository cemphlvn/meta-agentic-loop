# Agent Trace MCP Server

MCP server providing tools to query OTel-compatible agent traces.

## Installation

```bash
cd observability/mcp-server
npm install
```

## Tools

| Tool | Description |
|------|-------------|
| `trace_lineage` | Show parent-child agent spawn hierarchy |
| `trace_runs` | List completed agent runs |
| `trace_stats` | Aggregate statistics (success rate, avg duration) |
| `trace_span` | Get full details of a specific span |
| `trace_events` | Get recent events from queue |

## Usage

The server is auto-registered via `plugin/.mcp.json`:

```json
{
  "mcpServers": {
    "agent-trace": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/observability/mcp-server/server.js"]
    }
  }
}
```

## Example Queries

```
# Show lineage as Mermaid diagram
trace_lineage(trace_id: "abc123...", format: "mermaid")

# Get stats for explore agent
trace_stats(agent_id: "explore")

# Get recent spawn events
trace_events(type: "agent:spawn", limit: 10)
```

## Architecture

```
hooks → emit.sh → events/queue.jsonl
                          ↓
              MCP Server (trace_events)
                          ↓
runs/*.yaml ←── trace_runs, trace_stats, trace_span, trace_lineage
```

## Future: WebSocket Real-time

For 3D visualization, add WebSocket transport:
1. Use chokidar to watch events/queue.jsonl
2. Broadcast new events to connected clients
3. Configure as `type: "ws"` in client
