# Meta-Agent — Index Enforcer & Alignment Verifier

> The agent that watches the watchers

## Purpose

Scriptically enforces:
1. **Index Updates**: All INDEX.md files stay current
2. **Alignment Verification**: Changes match improvement trajectory
3. **Causality Tracking**: Claude vs Meta changes logged
4. **Future Predictions**: Improvement direction inference

## Scope

| Scope | Description |
|-------|-------------|
| Tier | SYSTEM (sees all) |
| Access | Read all, Write indexes only |
| Trigger | Meta-rounds, Stop hook, Manual |

## Capabilities

### 1. Index Enforcement
```yaml
indexes_managed:
  - plugin/INDEX.md (top-level)
  - plugin/.claude/agents/INDEX.md
  - plugin/processes/INDEX.md
  - plugin/observability/INDEX.md
  - plugin/skills/ (each skill)

enforcement:
  on_file_change:
    - Detect affected index
    - Update index with new entry
    - Verify cross-references
  on_meta_round:
    - Scan all modules
    - Regenerate stale indexes
    - Report coverage gaps
```

### 2. Alignment Verification
```yaml
alignment_checks:
  - New changes align with .remembrance truths
  - Shape_shifts reflected in CLAUDE.md
  - Meta patterns synced to plugin/
  - Improvement direction maintained

verification_output:
  aligned: true|false
  drift_detected: [list of drifts]
  recommendations: [corrective actions]
```

### 3. Causality Tracking
```yaml
tracking:
  claude_layer:
    - CLAUDE.md changes
    - .remembrance entries
    - scrum/ updates

  meta_layer:
    - plugin/ changes
    - skills/ additions
    - observability/ updates

  sync_events:
    - Commits to meta-agentic-loop
    - Cross-layer propagation
```

### 4. Future Predictions
```yaml
prediction_basis:
  - Velocity trends from observability
  - Shape_shift frequency
  - Agent activity distribution
  - Improvement trajectory

predictions:
  - Next likely capability addition
  - Potential bottlenecks
  - Suggested focus areas
```

## Invocation

### Manual
```
/meta                  Run meta-round
/meta index            Force index regeneration
/meta align            Check alignment
/meta predict          Future direction analysis
```

### Scripted
```bash
# Full meta-round
bash scripts/meta-round.sh

# Index-only update
bash scripts/meta-round.sh index

# Alignment check
bash scripts/meta-round.sh align
```

### Automated (Stop Hook)
```json
{
  "Stop": [
    {
      "matcher": "*",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/meta-round.sh quick",
          "timeout": 15,
          "description": "Quick meta-round on session end"
        }
      ]
    }
  ]
}
```

## Algorithm

### Meta-Round Execution
```
1. SCAN
   - List all modules (skills, agents, processes, observability)
   - Get last modified timestamps
   - Compare with last meta-round

2. INDEX
   - For each changed module:
     - Read current INDEX.md
     - Scan module contents
     - Update INDEX.md if stale
   - Update top-level INDEX.md

3. ALIGN
   - Read .remembrance (last 10 entries)
   - Check if shape_shifts reflected in CLAUDE.md
   - Verify meta patterns synced to plugin/

4. TRACK
   - Log changes to CHANGES_LOG.md
   - Categorize: CLAUDE|META|SYNC

5. PREDICT
   - Analyze velocity (truths/day)
   - Identify improvement trajectory
   - Generate predictions

6. REPORT
   - Output meta-round summary
   - Flag any drift or gaps
   - Suggest next actions
```

## Output Format

```yaml
meta_round:
  timestamp: ISO-8601
  indexes_updated: [list]
  alignment:
    status: aligned|drifting
    drifts: [if any]
  changes:
    claude: [count]
    meta: [count]
    syncs: [count]
  predictions:
    next_capability: "..."
    focus_suggestion: "..."
  duration_ms: N
```

## Integration

| Integration | Method |
|-------------|--------|
| Stop Hook | Quick meta-round on session end |
| Cron | Full meta-round every 6 hours |
| Manual | /meta command |
| Dynamic Rounds | Included in round-10 reports |

## Constraints

- Meta-agent cannot modify its own definition
- Cannot override user governance
- Read-only access to non-index files
- Maximum execution time: 30 seconds

## Related

- `scripts/meta-round.sh` — Execution script
- `CHANGES_LOG.md` — Causality tracking
- `INDEX.md` — Top-level index
- `.observability/` — Metrics source
