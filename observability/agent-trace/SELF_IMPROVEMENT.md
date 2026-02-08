# Agent Trace → Self-Improvement Pipeline

> **"不进则退"** — Like rowing upstream: no advance is to drop back

## The Gap

The loop-runner.sh implements OBSERVE→DECIDE→ACT→LEARN but:
1. ACT phase says "Would invoke" but doesn't actually spawn agents
2. When agents ARE spawned (manually), traces exist but don't feed back
3. LEARN phase doesn't consume trace data for improvement

## The Bridge

```
TRACES ──────────────────────────────────→ LOOP IMPROVEMENT
   │                                              │
   │  span.yaml files contain:                    │  LEARN phase should:
   │    - operation_name (which agent)            │    - Detect patterns
   │    - parent_span_id (hierarchy)              │    - Identify failures
   │    - duration_ms (latency)                   │    - Crystallize processes
   │    - status.code (success/failure)           │    - Propose improvements
   │    - validation.status (determinism)         │
   └──────────────────────────────────────────────┘
```

## Implementation Plan

### Phase 1: Connect LEARN to Traces

Add to loop-runner.sh LEARN phase:
```bash
phase_learn() {
    # Existing: check shift_felt

    # NEW: Analyze recent traces for patterns
    local trace_analysis=$(analyze_traces)

    # Pattern detection
    if pattern_count > 3; then
        propose_process_template
    fi

    # Failure learning
    if error_rate > 0; then
        propose_validation_rule
    fi

    # Hierarchy enforcement
    if tier_violation_detected; then
        log_hierarchy_warning
    fi
}
```

### Phase 2: Hierarchy Enforcement

PreToolUse hook should validate tier hierarchy:
```yaml
# In validate-spawn.sh
allowed_spawns:
  strategic:
    can_spawn: [strategic, tactical]
    cannot_spawn: [operational]  # Must go through tactical
  tactical:
    can_spawn: [tactical, operational]
    cannot_spawn: [strategic]  # Consultation only
  operational:
    can_spawn: [operational]
    cannot_spawn: [tactical, strategic]  # Execute only
```

### Phase 3: Pattern Crystallization

When LEARN detects repeated sequences:
```
DETECT: librarian → code-implementer → code-reviewer (3+ times)
PROPOSE: Create process template "standard-feature.md"
VALIDATE: User approval
SCRIPT: Add to processes/ directory
```

### Phase 4: Trace-Driven Routing

Use historical trace data to optimize routing:
```
IF agent X has 90% success rate for task type Y:
   → Route Y tasks to X

IF agent Z has high latency for task type W:
   → Consider parallel dispatch or tier upgrade
```

## Metrics for Self-Improvement

| Metric | Source | Improvement Vector |
|--------|--------|-------------------|
| Success Rate | status.code | Identify weak agents |
| Latency P95 | duration_ms | Optimization targets |
| Hierarchy Compliance | parent_span tier vs child tier | Enforcement rules |
| Pattern Frequency | operation sequences | Process crystallization |
| Validation Rate | validation.status | Determinism coverage |

## Files to Modify

1. `loop-runner.sh` — Add trace analysis to LEARN phase
2. `validate-spawn.sh` — Add hierarchy enforcement
3. NEW: `pattern-detector.sh` — Detect recurring sequences
4. NEW: `improvement-proposer.sh` — Generate proposals from patterns
5. NEW: `.loop-improvements.yaml` — Track proposed improvements

## The Virtuous Cycle

```
                    ┌─────────────────────┐
                    │     MORE RUNS       │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │    MORE TRACES      │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   MORE PATTERNS     │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │  MORE PROCESSES     │ ← Scriptic expansion
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   LESS AD-HOC       │ ← Determinism increase
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │  BETTER OUTCOMES    │
                    └──────────┬──────────┘
                               │
                               └───────────────→ (back to MORE RUNS)
```

## Status

- [x] Trace infrastructure (agent-trace/)
- [x] Span schema (OTel-compatible)
- [x] Event queue (queue.jsonl)
- [x] Query commands (mal-trace, mal-metrics)
- [ ] LEARN phase integration
- [ ] Hierarchy enforcement
- [ ] Pattern detection
- [ ] Improvement proposal pipeline
- [ ] Auto-crystallization of processes
