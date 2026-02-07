---
name: Meta-Improvement Process
type: sequential
trigger: /process meta-improve OR Stop hook OR session.end
agents: [system-scientist, code-simplifier, repo-strategist, cto_agent]
timeout: 30m
rollback: false
feedback_loop: true
deterministic: true
---

# Process: Meta-Improvement

> 逆水行舟，不进则退 — Rowing upstream: no advance is to drop back.
> The system that improves the system.

## Philosophy

This is **not** ad-hoc auditing. This is deterministic reflection:
1. Every session ends with meta-improvement
2. Findings crystallize into .remembrance
3. SCRUM/Gantt always move forward
4. The loop never stops

## Flow

```
┌─────────────────────────────────────────────────────────┐
│                   META-IMPROVEMENT                       │
│                                                          │
│  OBSERVE: data-audit → What changed? What broke?        │
│      ↓                                                   │
│  PHILOSOPHIZE: system-scientist → Why? What pattern?    │
│      ↓                                                   │
│  CRYSTALLIZE: → .remembrance (senior form)              │
│      ↓                                                   │
│  PLAN: → Update SCRUM alphas, Gantt due dates           │
│      ↓                                                   │
│  CONTINUE: → Next session starts with updated state     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Steps

### Step 1: Data Audit
**Agent**: DevOps perspective
**Input**: Current session's changes
**Output**: Data correctness report
**Deterministic**: Run every session

```yaml
audit:
  sources:
    - .remembrance (new entries since last read)
    - tools/cockpit/src/utils/dataLoader.ts (data flow)
    - .observability/*.json (metrics)
  checks:
    - field_preservation: Are all fields extracted?
    - timestamp_validity: Can we calculate actual days?
    - scope_coverage: Are entries properly scoped?
```

### Step 2: Philosophize
**Agent**: `system-scientist`
**Input**: Audit findings
**Output**: Pattern recognition, hypothesis generation
**Deterministic**: Extract truths from patterns

```yaml
philosophize:
  questions:
    - What pattern emerges from the audit?
    - What hypothesis should we test?
    - What system improvement is needed?
  outputs:
    - truth: Crystallized insight
    - hypothesis: Testable improvement claim (HYP-XXX)
    - action: What to change
```

### Step 3: Crystallize to Remembrance
**Agent**: System
**Input**: Philosophized findings
**Output**: .remembrance entry (senior form)
**Deterministic**: Always log

```yaml
# Senior form entry
---
timestamp: {ISO-8601}
agent: system-scientist
scope: system
ticket: META-{session}
observed: |
  {audit_findings}
reasoning: |
  {philosophize_output}
action: {what_will_change}
outcome: pending
truth: {crystallized_insight}
confidence: {0.0-1.0}
---
```

### Step 4: Update SCRUM & Gantt
**Agent**: `orchestrator`
**Input**: Current alpha states, identified work
**Output**: Updated SCRUM.md, ROADMAP.md
**Deterministic**: Always progress

```yaml
scrum_update:
  - Check alpha state transitions
  - Add new work items if identified
  - Update Work.Prepared → Work.Started if ready

gantt_update:
  - Update DUE dates based on progress
  - Add milestones for new hypotheses
  - Flag blocked items
```

### Step 5: Set Continuation Point
**Agent**: System
**Input**: Current loop state
**Output**: .loop-state.yaml update
**Deterministic**: Always save state

```yaml
continuation:
  phase: {OBSERVE|DECIDE|ACT|LEARN}
  last_truth: {last_remembrance_entry}
  next_action: {what_to_do_next}
  hypotheses_active: [HYP-001, ...]
```

## Triggers

| Event | Action |
|-------|--------|
| Session end (Stop hook) | Run full meta-improvement |
| Major feature complete | Run audit + philosophize |
| Hypothesis tested | Crystallize result |
| Shape shift detected | Re-read remembrance + continue |

## Handoff to Next Session

```yaml
handoff:
  from: current_session
  to: next_session
  continuation:
    file: .loop-state.yaml
    remembrance_delta: +{n} entries
    scrum_state: {alpha_changes}
    gantt_state: {due_updates}
  instructions: |
    1. Read .loop-state.yaml
    2. Read scoped .remembrance
    3. Continue from last phase
    4. 不进则退 — keep moving
```

## Success Criteria

- [ ] Audit findings logged
- [ ] At least one truth crystallized
- [ ] SCRUM alphas checked
- [ ] Gantt DUE dates verified
- [ ] Loop state saved
- [ ] Next session can continue seamlessly
