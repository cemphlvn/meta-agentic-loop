# Agent Trace — OpenTelemetry-Compatible Observability

> **"What the agent does must be observable. How the agent decides must be traceable."**
>
> Scriptic architecture ENABLES agentic intelligence through observability.
> OpenTelemetry compatibility enables 2050-vision 3D visualization.

## Schema

See `schema.yaml` for full OTel-compatible field definitions.

**Key Fields:**
- `trace_id` — 32 hex chars, shared across session (like distributed trace)
- `span_id` — 16 hex chars, unique per agent run
- `parent_span_id` — links to spawner's span (hierarchical)
- `status.code` — UNSET | OK | ERROR (OTel StatusCode)
- `duration_ms` — calculated from start/end nanoseconds

## The Gap We're Filling

**Before:**
- Agents documented but spawning not logged
- No lineage tracing (who spawned who)
- No result capture (what happened)
- No deterministic validation (just prompts)

**After (OTel-Compatible):**
- Every agent spawn creates a SPAN with trace/span IDs
- Full lineage via parent_span_id (A → B → C)
- Results captured with duration_ms and OTel status
- Deterministic validation with blocking enforcement

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      AGENT TRACE INFRASTRUCTURE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PreToolUse (Task)                 PostToolUse (Task)                       │
│  ┌──────────────────────┐          ┌──────────────────────┐                │
│  │ 1. VALIDATE agent    │          │ 1. CAPTURE result    │                │
│  │    - exists in INDEX │          │    - success/fail    │                │
│  │    - status ACTIVE   │          │    - duration        │                │
│  │ 2. LOG spawn intent  │          │ 2. UPDATE lineage    │                │
│  │    - spawner         │          │ 3. LOG to run file   │                │
│  │    - spawned         │          │                      │                │
│  │    - task            │          │                      │                │
│  │    - context_hash    │          │                      │                │
│  │ 3. ASSIGN run_id     │          │                      │                │
│  └──────────────────────┘          └──────────────────────┘                │
│           │                                   │                             │
│           ▼                                   ▼                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                 OTEL-COMPATIBLE SPAN FILE                            │   │
│  │  .observability/agent-trace/runs/{span_id}.yaml                     │   │
│  │                                                                      │   │
│  │  # Identifiers (OTel)                                               │   │
│  │  trace_id: "4bf92f3577b34da6a3ce929d0e0e4736"                       │   │
│  │  span_id: "00f067aa0ba902b7"                                         │   │
│  │  parent_span_id: "a1b2c3d4e5f67890"  # null for root                │   │
│  │                                                                      │   │
│  │  # Operation                                                        │   │
│  │  operation_name: "brand-builder"                                     │   │
│  │  task_description: "Create brand identity for kidlearnio"           │   │
│  │                                                                      │   │
│  │  # Timing                                                           │   │
│  │  start_time: "2026-02-08T12:34:56Z"                                 │   │
│  │  end_time: "2026-02-08T12:35:42Z"                                   │   │
│  │  duration_ms: 46000                                                  │   │
│  │                                                                      │   │
│  │  # Status (OTel StatusCode)                                         │   │
│  │  status:                                                             │   │
│  │    code: "OK"  # UNSET | OK | ERROR                                 │   │
│  │    message: "Agent completed successfully"                           │   │
│  │                                                                      │   │
│  │  # Attributes                                                        │   │
│  │  attributes:                                                         │   │
│  │    agent.tier: "tactical"                                           │   │
│  │    agent.spawner: "orchestrator"                                     │   │
│  │    validation.status: "passed"                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                   LINEAGE GRAPH (Future)                             │   │
│  │  .observability/agent-trace/lineage/{trace_id}.yaml                 │   │
│  │                                                                      │   │
│  │  trace_id: "4bf92f3577b34da6a3ce929d0e0e4736"                       │   │
│  │  root_span: "a1b2c3d4e5f67890"                                       │   │
│  │  spans:                                                              │   │
│  │    - span_id: "a1b2c3d4e5f67890"                                    │   │
│  │      operation: "orchestrator"                                       │   │
│  │      children: ["00f067aa0ba902b7", "11g078bb1cb013c8"]             │   │
│  │    - span_id: "00f067aa0ba902b7"                                    │   │
│  │      operation: "brand-builder"                                      │   │
│  │      children: ["22h189cc2dc124d9"]                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Validation Rules (Deterministic)

```yaml
pre_spawn_validation:
  required:
    - agent_exists_in_registry: true
    - agent_status_active: true
    - agent_tier_appropriate: true  # opus for strategic, etc.

  optional_but_logged:
    - agent_has_required_tools: warn
    - agent_scope_matches_task: warn

  enforcement:
    block_if:
      - agent not found in INDEX.md
      - agent status != ACTIVE and status != MASTER
    warn_if:
      - tier mismatch (using opus for simple task)
      - scope mismatch (agent for wrong domain)
```

## Hook Implementation

### PreToolUse Hook (validate-and-log-spawn.sh)

```bash
#!/bin/bash
# Validate agent spawn and log intent

AGENT_ID="$1"
TASK_DESC="$2"
SPAWNER="${CLAUDE_AGENT_ID:-orchestrator}"

# 1. Validate agent exists
if ! grep -q "^\| \`$AGENT_ID\`" "$PLUGIN_ROOT/.claude/agents/INDEX.md"; then
    echo "BLOCK: Agent '$AGENT_ID' not found in registry"
    exit 1
fi

# 2. Validate agent status
STATUS=$(grep -A1 "^\| \`$AGENT_ID\`" "$PLUGIN_ROOT/.claude/agents/INDEX.md" | grep -oE "Active|Master|Draft" || echo "Unknown")
if [[ "$STATUS" != "Active" && "$STATUS" != "Master" ]]; then
    echo "BLOCK: Agent '$AGENT_ID' status is '$STATUS', not Active/Master"
    exit 1
fi

# 3. Log spawn intent
RUN_ID="RUN-$(date -u +%Y-%m-%dT%H:%M:%S)-$AGENT_ID"
cat >> "$PLUGIN_ROOT/.observability/agent-trace/pending/$RUN_ID.yaml" << EOF
run_id: $RUN_ID
spawner: $SPAWNER
spawned: $AGENT_ID
task: "$TASK_DESC"
started: $(date -u +%Y-%m-%dT%H:%M:%SZ)
status: pending
EOF

echo "PASS: Agent spawn validated and logged ($RUN_ID)"
export AGENT_RUN_ID="$RUN_ID"
```

### PostToolUse Hook (capture-agent-result.sh)

```bash
#!/bin/bash
# Capture agent result and update lineage

RUN_ID="$AGENT_RUN_ID"
STATUS="$1"  # success | failure
RESULT_SUMMARY="$2"

# Move from pending to runs
PENDING_FILE="$PLUGIN_ROOT/.observability/agent-trace/pending/$RUN_ID.yaml"
RUN_FILE="$PLUGIN_ROOT/.observability/agent-trace/runs/$RUN_ID.yaml"

if [[ -f "$PENDING_FILE" ]]; then
    STARTED=$(grep "^started:" "$PENDING_FILE" | cut -d' ' -f2)
    NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Calculate duration
    START_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$STARTED" "+%s" 2>/dev/null || echo "0")
    NOW_EPOCH=$(date -u "+%s")
    DURATION=$((NOW_EPOCH - START_EPOCH))

    # Complete the run file
    cat "$PENDING_FILE" > "$RUN_FILE"
    cat >> "$RUN_FILE" << EOF
completed: $NOW
duration_seconds: $DURATION
status: $STATUS
result_summary: |
  $RESULT_SUMMARY
EOF

    rm "$PENDING_FILE"
    echo "Agent run captured: $RUN_ID (${DURATION}s, $STATUS)"
fi
```

## Query Commands

```bash
# Show agent lineage for current session
/trace lineage

# Show all runs for an agent
/trace runs brand-builder

# Show pending (in-flight) agents
/trace pending

# Show run details
/trace run RUN-2026-02-08T12:34:56-brand-builder

# Aggregate stats
/trace stats              # Overall
/trace stats brand-builder # Per agent
```

## Backtracking from Future State

To claim high alignment, we need to implement:

```yaml
phase_1_foundation:
  priority: critical
  items:
    - [ ] Create agent-trace/ directory structure
    - [ ] Create validate-and-log-spawn.sh
    - [ ] Update hooks.json PreToolUse to use real validation
    - [ ] Create basic run logging

phase_2_lineage:
  priority: high
  items:
    - [ ] Create lineage graph structure
    - [ ] Track parent-child relationships
    - [ ] Enable lineage queries

phase_3_analytics:
  priority: medium
  items:
    - [ ] Duration tracking
    - [ ] Success/failure rates
    - [ ] Agent utilization metrics
    - [ ] Integration with system-scientist

phase_4_enforcement:
  priority: high
  items:
    - [ ] Block invalid agent spawns
    - [ ] Warn on tier mismatches
    - [ ] Integrate with MECE validation
```

## Integration Points

```yaml
with_workflow_audit:
  - Agent spawn failures → OPP-XXX proposals
  - Missing lineage → observability gap

with_system_scientist:
  - Agent performance → hypothesis testing
  - Utilization patterns → strategic reports

with_remembrance:
  - Significant agent runs → crystallize learnings
  - Failure patterns → prevent recurrence
```

---

*Scriptic architecture ENABLES agentic intelligence.*
*What the agent does must be observable.*
*How the agent decides must be traceable.*
