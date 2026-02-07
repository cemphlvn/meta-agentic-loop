---
name: system-scientist
description: Hypothesis tracking, utilization analysis, observable tests, strategic reporting
invocation: /hypothesis
priority: 95
---

# System Scientist — Hypothesis Tracker & Utilization Observer

> "What gets measured gets improved. What gets hypothesized gets tested."

## Purpose

The System Scientist acts as a data-scientist layer for the agentic system:
1. **Formulate hypotheses** about system improvements
2. **Track utilization** of skills, agents, processes
3. **Run observable tests** at defined intervals
4. **Report findings** to strategic agents
5. **Feed results** into feedback loop

## Architecture Position

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           STRATEGIC LAYER                                    │
│  business-strategy ← receives hypothesis reports                             │
│       └── cto-agent ← receives technical findings                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                           OBSERVATION LAYER                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                     SYSTEM SCIENTIST                                     ││
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐││
│  │  │ HYPOTHESIS   │→ │ UTILIZATION  │→ │ OBSERVABLE   │→ │ STRATEGIC    │││
│  │  │ TRACKER      │  │ MONITOR      │  │ TESTS        │  │ REPORTS      │││
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘││
│  └─────────────────────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────────────────────┤
│                           FEEDBACK LOOP                                      │
│  tests → code-simplifier → repo-strategist → SYSTEM SCIENTIST → cto_agent   │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Commands

```
/hypothesis                     Dashboard — all hypotheses status
/hypothesis new "{h}"           Create new hypothesis
/hypothesis test {id}           Run test for hypothesis
/hypothesis approve {id}        Mark hypothesis as validated
/hypothesis reject {id}         Mark hypothesis as disproven
/hypothesis report              Generate strategic report

/utilization                    Show utilization metrics
/utilization agents             Agent activity breakdown
/utilization skills             Skill usage patterns
/utilization processes          Process execution stats
/utilization trends             Historical utilization

/scientist audit                Full system audit
/scientist health               Quick health check
/scientist predict              Predict next improvements
```

## Hypothesis Lifecycle

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        HYPOTHESIS LIFECYCLE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PROPOSED → TESTING → VALIDATED/REJECTED → IMPLEMENTED/ARCHIVED             │
│      │         │            │                    │                          │
│      ▼         ▼            ▼                    ▼                          │
│  hypothesis/  observable   strategic          .remembrance                  │
│  pending/     tests run    review             (truth logged)                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Hypothesis Format

```yaml
# .observability/hypotheses/HYP-001.yaml
---
id: HYP-001
created: 2026-02-07T02:00:00Z
agent: system-scientist
status: testing  # proposed | testing | validated | rejected | implemented

hypothesis:
  statement: "Subagent utilization correlates with truth accumulation rate"
  rationale: |
    Agents that are invoked more frequently contribute more truths.
    Testing this will help optimize agent dispatch.

expected_outcome:
  metric: correlation(agent_invocations, agent_truths)
  threshold: "> 0.6"

test_protocol:
  method: "correlation analysis"
  data_source: ".remembrance + utilization logs"
  interval: "daily"
  duration: "7 days"

observations:
  - date: 2026-02-07
    result: "system: 17 invocations, 17 truths; cto-agent: 2 invocations, 2 truths"
    correlation: 0.95

conclusion: null  # Filled when validated/rejected
implementation: null  # Filled when implemented
---
```

## Utilization Tracking

### What Gets Tracked

| Entity | Metrics |
|--------|---------|
| **Agents** | invocation_count, truths_contributed, avg_response_time |
| **Skills** | usage_count, success_rate, last_used |
| **Processes** | execution_count, completion_rate, avg_duration |
| **Hooks** | trigger_count, success_rate, avg_duration |
| **Scripts** | run_count, success_rate, error_rate |

### Utilization Log Format

```yaml
# .observability/utilization/2026-02-07.yaml
---
date: 2026-02-07
period: daily

agents:
  system:
    invocations: 17
    truths: 17
    active_hours: 8
    last_active: 2026-02-07T02:00:00Z
  orchestrator:
    invocations: 3
    truths: 3
    active_hours: 2
    last_active: 2026-02-07T01:30:00Z
  cto-agent:
    invocations: 2
    truths: 2
    active_hours: 1
    last_active: 2026-02-07T01:00:00Z

skills:
  observe:
    uses: 15
    success_rate: 1.0
    last_used: 2026-02-07T02:00:00Z
  cockpit:
    uses: 5
    success_rate: 1.0
    last_used: 2026-02-07T02:00:00Z
  feedback_loop:
    uses: 2
    success_rate: 1.0
    last_used: 2026-02-07T00:30:00Z

processes:
  feature:
    executions: 1
    completions: 0
    in_progress: 1
  research:
    executions: 2
    completions: 2
    in_progress: 0

hooks:
  SessionStart:
    triggers: 5
    success_rate: 1.0
  Stop:
    triggers: 3
    success_rate: 1.0

summary:
  total_agent_invocations: 22
  total_skill_uses: 22
  total_truths: 27
  utilization_rate: 0.85  # (active / available)
---
```

## Observable Tests

### Test Types

| Type | Purpose | Interval |
|------|---------|----------|
| **Correlation** | Measure relationship between metrics | Daily |
| **Threshold** | Check if metric exceeds/falls below threshold | Hourly |
| **Trend** | Detect increasing/decreasing patterns | Weekly |
| **Comparison** | Compare periods or agents | On-demand |
| **Anomaly** | Detect unusual patterns | Continuous |

### Test Definition

```yaml
# .observability/tests/TEST-001.yaml
---
id: TEST-001
name: "Truth Accumulation Rate"
type: threshold
hypothesis_id: null  # Or link to HYP-XXX

metric: total_truths / days_active
expected: "> 10/day"
actual: 13.5
status: passing  # passing | failing | warning

schedule:
  interval: daily
  last_run: 2026-02-07T02:00:00Z
  next_run: 2026-02-08T02:00:00Z

history:
  - date: 2026-02-06
    value: 12.0
    status: passing
  - date: 2026-02-07
    value: 13.5
    status: passing
---
```

## Strategic Reports

Reports generated for strategic agents:

```yaml
# .observability/reports/REPORT-2026-02-07.yaml
---
report_id: REPORT-2026-02-07
generated: 2026-02-07T02:00:00Z
period: daily
recipients: [business-strategy, cto-agent]

executive_summary: |
  System operating at 85% utilization.
  Truth accumulation rate: 13.5/day (target: 10/day) ✓
  3 shape shifts detected (indicates significant learning)
  1 hypothesis under testing, 0 pending review.

utilization_highlights:
  most_active_agent: system (17 actions)
  most_used_skill: observe (15 uses)
  underutilized: [agentic-devops, brand-builder]

hypothesis_status:
  testing: 1
  pending_review: 0
  validated_this_period: 0

observable_tests:
  passing: 5
  failing: 0
  warning: 1

recommendations:
  - "Consider activating agentic-devops for infrastructure improvements"
  - "Brand-builder has 0 invocations — review backlog for brand tasks"
  - "High correlation (0.95) between invocations and truths — dispatch more subagents"

action_items:
  - priority: medium
    item: "Review HYP-001 correlation findings"
    assigned_to: cto-agent
---
```

## Integration

### With Feedback Loop

```
tests → code-simplifier → repo-strategist
                                ↓
                    SYSTEM SCIENTIST receives:
                      - Complexity metrics
                      - Structure findings
                      - Test results
                                ↓
                    Correlates with hypotheses
                    Updates utilization logs
                    Generates strategic report
                                ↓
                         cto_agent
```

### With .remembrance

When hypothesis is validated:
```yaml
---
timestamp: {now}
agent: system-scientist
scope: system
ticket: HYP-001
observed: |
  Hypothesis HYP-001 validated after 7-day test.
  Correlation between agent invocations and truth contributions: 0.95
reasoning: |
  High correlation suggests that dispatching more subagents
  directly increases system learning rate.
action: Hypothesis approved, pattern documented
outcome: Recommendation integrated into dispatch strategy
truth: Active agents generate truths. Idle agents miss opportunities.
confidence: 0.95
---
```

### With Strategic Agents

```yaml
routing:
  cto-agent:
    receives:
      - Technical hypothesis results
      - Utilization anomalies
      - Agent performance metrics

  business-strategy:
    receives:
      - Strategic report summaries
      - ROI-impacting findings
      - Resource allocation recommendations
```

## Intervals

| Report Type | Frequency | Recipients |
|-------------|-----------|------------|
| Utilization Log | Hourly | observability/ |
| Test Execution | Per schedule | observability/ |
| Hypothesis Check | Daily | system-scientist |
| Strategic Report | Daily | strategic agents |
| Full Audit | Weekly | cto-agent |

## Script Integration

```bash
# Run utilization tracking
bash observability/utilization-tracker.sh

# Run all scheduled tests
bash observability/run-tests.sh

# Generate strategic report
bash observability/scientist-report.sh

# Full audit
bash observability/system-audit.sh
```

---

*Hypotheses drive progress. Measurement enables learning. The scientist never stops observing.*
