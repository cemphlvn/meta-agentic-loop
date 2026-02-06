---
name: Feedback Loop
description: Run tests, analyze complexity, check structure, report to strategy
trigger: After code changes, on /feedback command
commands: [/feedback, /loop]
requiredTools: [Bash, Task, Read]
agents: [code-simplifier, repo-strategist, cto_agent]
priority: 90
---

# Feedback Loop Skill

> "The strength of a system is measured by its feedback mechanisms."

## Purpose

The feedback loop ensures code changes remain aligned with strategic intent by:
1. Running tests
2. Analyzing complexity changes
3. Checking structural alignment
4. Reporting to CTO for strategic review

## Protocol

```
┌──────────────────────────────────────────────────────────────┐
│                      FEEDBACK LOOP                            │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  1. TESTS                                                     │
│     pnpm test                                                 │
│     └─→ Pass: continue                                        │
│     └─→ Fail: stop, report to implementer                     │
│                                                               │
│  2. COMPLEXITY ANALYSIS (code-simplifier)                     │
│     Analyze changed files for:                                │
│     - Cyclomatic complexity increase                          │
│     - New abstractions introduced                             │
│     - Dead code created                                       │
│     └─→ Acceptable: continue                                  │
│     └─→ Concerning: flag for CTO review                       │
│                                                               │
│  3. STRUCTURE ANALYSIS (repo-strategist)                      │
│     Check for:                                                │
│     - Boundary violations                                     │
│     - Module placement issues                                 │
│     - Dependency direction                                    │
│     └─→ Aligned: continue                                     │
│     └─→ Drift: flag for CTO review                            │
│                                                               │
│  4. STRATEGIC REPORT (cto_agent)                              │
│     Aggregate findings:                                       │
│     - Test results                                            │
│     - Complexity delta                                        │
│     - Structure status                                        │
│     └─→ All good: close loop                                  │
│     └─→ Issues: escalate to business_strategy if needed       │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## Invocation

### Automatic (post-commit hook)
```json
{
  "PostCommit": [{
    "command": "bash scripts/feedback-loop.sh"
  }]
}
```

### Manual
```markdown
/feedback
```

### With specific focus
```markdown
/feedback complexity
/feedback structure
/feedback full
```

## Output

### Feedback Report
```yaml
feedback_report:
  timestamp: ISO8601
  trigger: "manual" | "post-commit" | "post-merge"

  tests:
    status: "pass" | "fail"
    duration_ms: number
    failures: []

  complexity:
    status: "acceptable" | "concerning" | "critical"
    delta: number
    issues: ComplexityIssue[]

  structure:
    status: "aligned" | "drift" | "violation"
    issues: StructureIssue[]

  recommendation:
    action: "proceed" | "review" | "escalate"
    details: string
```

## Thresholds

```yaml
complexity:
  acceptable_increase: 10%
  concerning_increase: 20%
  critical_increase: 50%

structure:
  boundary_violations: 0    # Any is drift
  orphan_files: 3          # Concerning
  dependency_cycles: 0      # Any is violation
```

## Integration

### With SCRUM
- Updates `Work` alpha state based on feedback
- Logs issues to sprint backlog if action needed

### With .remembrance
- Captures patterns that led to issues
- Records successful simplifications

### With strategic agents
- CTO receives all reports
- business_strategy receives escalations
