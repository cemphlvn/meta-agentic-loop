---
description: Session trace management
allowed-tools: Bash, Read
argument-hint: [subcommand]
---

# /mal-session — Session Trace Management

Manage the current session's trace context.

## Subcommands

### id
Show or initialize current session trace ID:
```bash
!`if [ -f /tmp/claude_trace_session ]; then cat /tmp/claude_trace_session; else TRACE_ID=$(openssl rand -hex 16); echo "$TRACE_ID" > /tmp/claude_trace_session; echo "Initialized: $TRACE_ID"; fi`
```

### traces
List all trace IDs in this session:
```bash
!`grep -h "^trace_id:" ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null | sort -u | sed 's/trace_id: //' | tr -d '"'`
```

### export [trace_id]
Export a trace for external analysis (OTel JSON format):
```bash
!`TRACE="$2"; if [ -z "$TRACE" ]; then TRACE=$(cat /tmp/claude_trace_session 2>/dev/null); fi; echo "{\"resourceSpans\":[{\"scopeSpans\":[{\"spans\":["; first=true; for f in ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml; do if grep -q "trace_id: \"$TRACE\"" "$f" 2>/dev/null; then [ "$first" = "false" ] && echo ","; first=false; cat "$f" | grep -v "^---" | grep -v "^#"; fi; done; echo "]}]}]}"`
```

### clear
Clear session trace context (start fresh):
```bash
!`rm -f /tmp/claude_trace_session && echo "Session trace cleared"`
```

### info
Show session trace info:
```bash
!`echo "Session file: /tmp/claude_trace_session" && echo "Current trace: $(cat /tmp/claude_trace_session 2>/dev/null || echo 'Not set')" && echo "Spans in session: $(grep -l "trace_id: \"$(cat /tmp/claude_trace_session 2>/dev/null)\"" ${CLAUDE_PLUGIN_ROOT}/observability/agent-trace/runs/*.yaml 2>/dev/null | wc -l | tr -d ' ')"`
```

## Session Trace Flow

1. `/mal-session id` — Get/create trace ID for session
2. Hooks use CLAUDE_TRACE_ID env var
3. All spans share same trace_id
4. `/mal-session export` — Export for visualization

## Usage

- `/mal-session id` — Show current trace ID
- `/mal-session traces` — List all traces
- `/mal-session export abc123...` — Export specific trace
