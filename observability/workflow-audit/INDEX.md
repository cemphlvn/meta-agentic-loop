# Deterministic Workflow Audit

> **"Observability enables adaptation. Determinism prevents waste. Flexibility enables growth."**
>
> 不进则退 — Systems that don't improve their observability regress.

## Philosophy: Agentic-Scriptic Duality

**Two forces work TOGETHER, not against each other:**

```yaml
agentic_scriptic_duality:

  agentic_intelligence:                    # PROVIDES FLEXIBILITY
    what: Contextual adaptation under variants
    capabilities:
      - Reasoning through novel situations
      - Creative problem-solving
      - Learning from experience
      - Making judgment calls
      - Handling cases scripts can't anticipate
    when_used:
      - Novel contexts with no existing pattern
      - Variant situations requiring adaptation
      - Creative solutions beyond script scope

  scriptic_architecture:                   # PROVIDES OBSERVABILITY
    what: Traceability and engineering preconditions
    capabilities:
      - Observability of what happened
      - Preconditions ensuring valid starting states
      - Reproducible behaviors where needed
      - Pattern detection through logging
    when_used:
      - External data validation (prevent 404s)
      - Schema enforcement (prevent inconsistency)
      - Audit trails (know what happened)

  the_symbiosis:
    scriptic_enables_agentic:
      - Provides clear observability → agent knows what happened
      - Ensures preconditions → agent starts from valid state
      - Tracks variants → agent learns from different contexts
      - Logs patterns → agent recognizes recurring situations

    agentic_extends_scriptic:
      - Handles cases scripts can't anticipate
      - Adapts to novel contexts intelligently
      - Proposes new scripts when patterns emerge
      - Decides when to be deterministic vs flexible

evolution_reframed:
  not: ad-hoc → scriptic → deterministic → rigid
  yes: ad-hoc → observable → adaptive → flourishing
  principle: Scriptic architecture ENABLES agentic intelligence
```

## Purpose

This module tracks **agentic workflow patterns** and identifies **opportunities for improvement**:

1. **OBSERVE** where the agent encountered friction or failure
2. **CLASSIFY** the opportunity type (validation, observability, automation)
3. **PROPOSE** improvements (deterministic where it prevents waste, flexible where it enables growth)
4. **TRACK** implementation and measure impact
5. **LEARN** what works, adapt what doesn't

## Architecture Position

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      AGENTIC-SCRIPTIC DUALITY                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                                                                          ││
│  │  AGENTIC INTELLIGENCE          ←→        SCRIPTIC ARCHITECTURE          ││
│  │  (provides FLEXIBILITY)                   (provides OBSERVABILITY)       ││
│  │                                                                          ││
│  │  • Contextual adaptation                  • Traceability                 ││
│  │  • Reasoning under variants               • Engineering preconditions    ││
│  │  • Creative problem-solving               • Pattern detection            ││
│  │  • Learning from experience               • Reproducible behaviors       ││
│  │                                                                          ││
│  │                    SYMBIOSIS: Each enables the other                     ││
│  │                                                                          ││
│  └─────────────────────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────────────────────┤
│                      WORKFLOW AUDIT TRACKER                                  │
│                                                                              │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐                │
│  │   OBSERVE    │ ──→ │   CLASSIFY   │ ──→ │   PROPOSE    │                │
│  │   Friction   │     │   Opportunity│     │   Solution   │                │
│  └──────────────┘     └──────────────┘     └──────────────┘                │
│         │                    │                    │                         │
│         ▼                    ▼                    ▼                         │
│    audits/              opportunities/       DECIDE:                        │
│    AUDIT-XXX.yaml       OPP-XXX.yaml        scriptic? (hook/script)        │
│                                              agentic? (skill/pattern)       │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                      CONTEXT INJECTION (I→C→O)                               │
│                                                                              │
│  INPUT:                                                                      │
│    - Session transcript (what agent did)                                     │
│    - .remembrance (what was learned)                                         │
│    - Friction signals (where agent struggled)                                │
│    - Existing scriptic infrastructure (hooks, scripts)                       │
│    - Existing agentic patterns (skills, docs)                                │
│                                                                              │
│  CONTEXT:                                                                    │
│    - Higher-order development plan status                                    │
│    - Evolution vector position (observable → adaptive → flourishing)         │
│    - Agentic-scriptic balance metrics                                        │
│                                                                              │
│  OUTPUT:                                                                     │
│    - Scriptic proposals (hooks, scripts) where prevents waste               │
│    - Agentic proposals (skills, docs) where enables growth                  │
│    - .remembrance entries (crystallized truths)                              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Failure Detection Taxonomy

### Level 1: Validation Failures
**"Data that should have been validated wasn't"**

```yaml
type: validation_opportunity
examples:
  - Model name used without verification → 404 error
  - Path assumed without checking → file not found
  - Schema assumed without validation → malformed data
solution_pattern: |
  Add validation script/hook before the action.
  Pattern: check_${resource}_exists() before use.
```

### Level 2: Enforcement Failures
**"Behavior that should have been enforced wasn't"**

```yaml
type: enforcement_opportunity
examples:
  - Format not enforced → inconsistent entries
  - Scope not checked → wrong remembrance file
  - Order not enforced → race conditions
solution_pattern: |
  Add enforcement hook that blocks non-compliant actions.
  Pattern: require_${constraint}() as pre-condition.
```

### Level 3: Automation Failures
**"Repetitive work that should have been scripted wasn't"**

```yaml
type: automation_opportunity
examples:
  - Same file read 5+ times → should be cached/indexed
  - Same pattern searched 3+ times → should be a function
  - Same transformation done repeatedly → should be a script
solution_pattern: |
  Create reusable script/function.
  Pattern: ${action}_${resource}.sh or utils/${domain}.ts
```

### Level 4: Self-Improvement Failures
**"Pattern that should have been learned wasn't"**

```yaml
type: self_improvement_opportunity
examples:
  - Same error type occurred 3+ times → should be in .remembrance
  - Same fix applied repeatedly → should be automated
  - Same question asked → should be in documentation
solution_pattern: |
  Log to .remembrance + create prevention mechanism.
  Pattern: truth crystallizes → hook/script prevents recurrence.
```

## Opportunity Format

```yaml
# observability/workflow-audit/opportunities/OPP-001.yaml
---
id: OPP-001
created: 2026-02-08T00:00:00Z
detected_by: workflow-audit
status: proposed  # proposed | implementing | implemented | rejected

detection:
  trigger: "Agent tried path resolution without {ROOT} convention"
  session: "2026-02-08-kidlearnio"
  failure_type: enforcement_opportunity
  impact: |
    Read tool failed with "file not found"
    Required user intervention to fix
    ~5 minutes of token waste

classification:
  level: 2  # enforcement
  domain: path_resolution
  recurrence: 3  # times this pattern occurred
  severity: medium  # low | medium | high | critical

current_state:
  how_handled: "Agent manually traversed up to find correct path"
  determinism_level: 0  # 0=ad-hoc, 1=documented, 2=scripted, 3=enforced
  existing_mitigation: null

proposed_solution:
  type: hook  # script | hook | schema | documentation
  name: "path-resolver"
  description: |
    Pre-tool hook that resolves {ROOT} placeholders to absolute paths
    before any file operation.
  implementation_sketch: |
    # In hooks.json or as pre-tool hook
    resolve_root() {
      # Traverse up until CLAUDE.md with "Curiosity founders" found
      dir=$(pwd)
      while [[ "$dir" != "/" ]]; do
        if grep -q "Curiosity founders" "$dir/CLAUDE.md" 2>/dev/null; then
          echo "$dir"
          return
        fi
        dir=$(dirname "$dir")
      done
    }
  effort: low  # low | medium | high
  priority: high  # based on recurrence × severity

tracking:
  proposed_date: 2026-02-08
  implementation_date: null
  implemented_by: null
  verification: null

related:
  remembrance_entry: null  # Link when truth crystallized
  hypothesis: null  # Link to HYP-XXX if testing
  audit: "AUDIT-2026-02-08"
---
```

## Audit Format

```yaml
# observability/workflow-audit/audits/AUDIT-2026-02-08.yaml
---
id: AUDIT-2026-02-08
timestamp: 2026-02-08T00:00:00Z
scope: session  # session | daily | weekly | manual
auditor: workflow-audit

inputs_analyzed:
  session_transcript: true
  remembrance_delta: 5  # new entries since last audit
  error_logs: true
  existing_determinism:
    scripts: 15
    hooks: 8
    schemas: 3

summary:
  opportunities_detected: 3
  by_level:
    validation: 1
    enforcement: 1
    automation: 0
    self_improvement: 1
  total_token_waste_estimate: "~2000 tokens"
  recurrence_patterns: 2

opportunities:
  - id: OPP-001
    type: enforcement_opportunity
    summary: "Path resolution without {ROOT} convention"
    priority: high

  - id: OPP-002
    type: validation_opportunity
    summary: "Model name used without verification"
    priority: medium

  - id: OPP-003
    type: self_improvement_opportunity
    summary: "Same fix pattern applied 3 times without crystallization"
    priority: high

determinism_coverage:
  before_session: 0.72  # 72% of common workflows have deterministic checks
  after_session: 0.72  # (increases when opportunities implemented)
  target: 0.90

evolution_vector_status:
  current_position: "scriptic → deterministic"
  blocking_opportunities: [OPP-001, OPP-003]
  next_milestone: "90% determinism coverage"

recommendations:
  immediate:
    - "Implement OPP-001 (path resolver hook) — blocks most failures"
    - "Crystallize OPP-003 fix pattern to .remembrance"
  short_term:
    - "Add model name validation hook before API calls"
  systemic:
    - "Create audit runner in session-end hook"

crystallized_truths:
  - truth: |
      When agent fails to find file, first check: was {ROOT} resolved correctly?
      Pattern: path failures usually mean context loss, not file absence.
    confidence: 0.9
    destination: plugin/.remembrance  # loop scope
---
```

## Higher-Order Development Plan Integration

```yaml
# The evolution vector this module serves (REFRAMED)
evolution:
  philosophy: |
    NOT: become rigid/deterministic
    YES: become observable/adaptive/flourishing

  stages:
    1_adhoc:
      description: "Agent acts without memory or patterns"
      observability: 0%
      adaptation: reactive only

    2_observable:
      description: "Patterns logged, failures tracked, learnings captured"
      observability: 40%
      adaptation: retrospective learning

    3_adaptive:
      description: "System responds to patterns, proposes improvements"
      observability: 70%
      adaptation: proactive suggestions

    4_flourishing:
      description: "Intelligent balance of determinism and flexibility"
      observability: 90%+
      adaptation: |
        Deterministic: where it prevents waste
        Flexible: where it enables growth
        Observable: always

  the_balance:
    make_deterministic:
      - External data validation (prevent 404s, malformed data)
      - Schema enforcement (prevent inconsistency)
      - Path resolution (prevent context loss)
    keep_flexible:
      - Solution paths (enable creative problem-solving)
      - Action sequences (enable exploration)
      - Learning priorities (enable adaptation)
    always_observable:
      - Log what you do
      - Track patterns
      - Crystallize learnings

  current_status:
    stage: 2_observable → 3_adaptive
    observability_coverage: 72%
    focus_areas:
      - "Improve observability of path resolution failures"
      - "Track remembrance scope decisions"
      - "Log external API interactions"

  next_milestone:
    stage: 3_adaptive
    target_observability: 85%
    key_implementations:
      - OPP-001: path-resolver (deterministic - prevents waste)
      - Failure pattern logging (observable - enables learning)
      - Improvement suggestion engine (adaptive - enables growth)
```

## Context Engineering

### Session Start Context Injection

```yaml
# Injected via SessionStart hook
workflow_audit_context:
  last_audit: "AUDIT-2026-02-08"
  open_opportunities: 3
  determinism_coverage: 72%
  evolution_stage: "3_scriptic → 4_deterministic"

  agent_awareness:
    prompt: |
      DETERMINISTIC WORKFLOW STATUS:
      - You are at 72% determinism coverage (target: 90%)
      - 3 opportunities await implementation
      - Your failures are tracked; recurring patterns → OPP-XXX proposals

      PROACTIVE SELF-IMPROVEMENT:
      - If you do something ad-hoc 3+ times → propose a script
      - If validation could have caught an error → note it
      - If a hook could enforce correct behavior → propose it

      Before completing session, run: /audit workflow
```

### Proactive Detection Prompts

```yaml
# Injected at key decision points
detection_prompts:
  before_file_read: |
    CHECKPOINT: Is this path {ROOT}-resolved?
    If not, resolve before reading.

  before_api_call: |
    CHECKPOINT: Is this external identifier verified?
    If fabricated, search first.

  before_remembrance_write: |
    CHECKPOINT: Is this the correct .remembrance scope?
    HOW agent works → plugin/.remembrance
    WHAT we build → /.remembrance

  on_error: |
    CHECKPOINT: Could this have been prevented deterministically?
    If yes, create OPP-XXX after fixing.

  on_repetition: |
    CHECKPOINT: Is this the 3rd time doing this manually?
    If yes, propose automation.
```

## Commands

```bash
# Run workflow audit
/audit workflow                    # Full session audit
/audit workflow --quick            # Quick check for obvious opportunities
/audit workflow --scope=daily      # Audit last 24h

# View opportunities
/opportunities                     # List all open opportunities
/opportunities --level=enforcement # Filter by level
/opportunities --status=proposed   # Filter by status

# Implement opportunity
/implement OPP-001                 # Start implementing
/implement OPP-001 --verify        # Verify implementation works

# Evolution status
/evolution                         # Show evolution vector status
/evolution --plan                  # Show higher-order development plan
/evolution --coverage              # Show determinism coverage metrics
```

## Script: audit.sh

```bash
#!/usr/bin/env bash
# observability/workflow-audit/audit.sh
# Deterministic workflow audit runner

set -euo pipefail

AUDIT_DIR="$(dirname "$0")"
PLUGIN_ROOT="$(dirname "$(dirname "$AUDIT_DIR")")"
TODAY=$(date +%Y-%m-%d)

audit_session() {
    echo "=== WORKFLOW AUDIT: $TODAY ==="

    # Count existing deterministic mechanisms
    local scripts=$(find "$PLUGIN_ROOT/scripts" -name "*.sh" | wc -l)
    local hooks=$(grep -c '"type"' "$PLUGIN_ROOT/hooks.json" 2>/dev/null || echo 0)

    echo "Deterministic mechanisms: $scripts scripts, $hooks hooks"

    # Check for opportunities in recent remembrance
    echo ""
    echo "=== RECENT REMEMBRANCE ANALYSIS ==="
    if [[ -f "$PLUGIN_ROOT/../.remembrance" ]]; then
        # Look for failure patterns
        local failures=$(grep -c "failure\|error\|failed" "$PLUGIN_ROOT/../.remembrance" || echo 0)
        echo "Failure mentions in ecosystem .remembrance: $failures"
    fi

    if [[ -f "$PLUGIN_ROOT/.remembrance" ]]; then
        local plugin_failures=$(grep -c "failure\|error\|failed" "$PLUGIN_ROOT/.remembrance" || echo 0)
        echo "Failure mentions in plugin .remembrance: $plugin_failures"
    fi

    # Generate audit file
    local audit_file="$AUDIT_DIR/audits/AUDIT-$TODAY.yaml"
    echo ""
    echo "Audit saved to: $audit_file"
}

case "${1:-audit}" in
    audit) audit_session ;;
    *) echo "Usage: $0 [audit]" ;;
esac
```

## Integration Points

### 1. Session End Hook
```yaml
# In hooks.json Stop hook
{
  "type": "command",
  "command": "bash ${PLUGIN_ROOT}/observability/workflow-audit/audit.sh",
  "timeout": 10,
  "description": "Run workflow audit before session ends"
}
```

### 2. Meta-Improvement Process
```yaml
# In processes/meta-improvement.md Step 1.5
workflow_audit:
  after: data_audit
  before: philosophize
  action: |
    Run workflow-audit to detect deterministic opportunities.
    Feed detected opportunities into philosophize step.
```

### 3. System Scientist
```yaml
# System scientist receives workflow audit data
workflow_integration:
  receives:
    - Opportunity proposals (OPP-XXX)
    - Determinism coverage metrics
    - Evolution vector status
  produces:
    - Hypotheses about which opportunities matter most
    - Strategic recommendations for implementation
    - Progress tracking toward 90% determinism
```

## Success Metrics

| Metric | Current | Target | Tracking |
|--------|---------|--------|----------|
| Observability Coverage | 72% | 90% | Weekly |
| Open Opportunities | 3 | <5 | Daily |
| Friction Points Logged | TBD | 100% | Continuous |
| Learning Crystallization Rate | TBD | >80% | Monthly |
| Adaptation Response Time | TBD | <1 session | Per pattern |

### Balance Metrics

| Dimension | Too Rigid | Just Right | Too Loose |
|-----------|-----------|------------|-----------|
| Validation | Blocks everything | Validates external data | Accepts garbage |
| Paths | Hardcoded paths | {ROOT} convention | Guesses paths |
| Solutions | Prescribed steps | Suggested patterns | No guidance |
| Learning | Forced templates | Crystallize when ripe | Forget everything |

---

*Observability enables adaptation.*
*Determinism prevents waste.*
*Flexibility enables growth.*
*不进则退 — The system that doesn't improve its observability regresses.*
