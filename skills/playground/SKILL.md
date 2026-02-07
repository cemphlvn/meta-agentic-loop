---
name: playground
description: Interactive cockpit for system observability, evolution tracking, and higher-order context management
invocation: /playground
---

# Playground — System Observability Interface

> Higher-order context that affects Claude as a plugin

## Purpose

The Playground provides:
1. **Observability** — See what the system is doing behind the scenes
2. **Evolution tracking** — Watch the system improve itself
3. **Gantt visualization** — Roadmap with DUE dates
4. **Metrics dashboard** — Agent activity, compliance scores
5. **Higher-order control** — Affect Claude's behavior through context injection

## Commands

### View Commands
```
/playground              Show full dashboard
/playground gantt        Mermaid Gantt chart
/playground evolution    System self-improvement timeline
/playground metrics      Agent activity + compliance
/playground hidden       Behind-the-scenes events
```

### Control Commands
```
/playground inject {ctx}  Inject higher-order context
/playground mode {m}      Switch operating mode
/playground trace on|off  Enable/disable event tracing
```

## Dashboard Layout

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                         PLAYGROUND DASHBOARD                               ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                            ║
║  ┌─────────────────────────┐  ┌─────────────────────────────────────────┐ ║
║  │ LOOP STATE              │  │ SPRINT PROGRESS                         │ ║
║  │ ━━━━━━━━━━━━━━━━━━━━━━━ │  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │ ║
║  │ Phase: ACT              │  │ SPRINT-001 ████████░░░░░░ 60%           │ ║
║  │ Frame: UNIFIED          │  │ PBI-V01    ████████████░░ 80%           │ ║
║  │ Last: 2m ago            │  │ Gate: 2026-02-15                        │ ║
║  └─────────────────────────┘  └─────────────────────────────────────────┘ ║
║                                                                            ║
║  ┌─────────────────────────────────────────────────────────────────────┐  ║
║  │ EVOLUTION (last 24h)                                                 │  ║
║  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │  ║
║  │ ● Shape-shift: remembrance-first enforced                           │  ║
║  │ ● Integration: user IS the loop                                     │  ║
║  │ ● Compliance: 0% → 95%                                              │  ║
║  │ ● Truths logged: 16                                                 │  ║
║  └─────────────────────────────────────────────────────────────────────┘  ║
║                                                                            ║
║  ┌─────────────────────────────────────────────────────────────────────┐  ║
║  │ AGENT ACTIVITY                                                       │  ║
║  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │  ║
║  │ system             ████████████████████████  8 actions              │  ║
║  │ orchestrator       ████████████░░░░░░░░░░░░  3 actions              │  ║
║  │ cto-agent          ████████░░░░░░░░░░░░░░░░  2 actions              │  ║
║  │ code-implementer   ████░░░░░░░░░░░░░░░░░░░░  1 action               │  ║
║  └─────────────────────────────────────────────────────────────────────┘  ║
║                                                                            ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

## Implementation

### Data Sources

```yaml
sources:
  loop_state: .loop-state.yaml
  remembrance: .remembrance
  evolution: scrum/EVOLUTION.md
  roadmap: scrum/ROADMAP.md
  backlog: scrum/artifacts/PRODUCT_BACKLOG.md
  audits: .audit/
```

### Context Injection

The playground injects higher-order context via SessionStart:

```bash
# scripts/playground-context.sh
#!/bin/bash
set -euo pipefail

# Read current state
LOOP_STATE=$(cat "${CLAUDE_PROJECT_DIR}/.loop-state.yaml" 2>/dev/null || echo "phase: OBSERVE")
COMPLIANCE=$(grep -o 'OVERALL.*[0-9]\+%' "${CLAUDE_PROJECT_DIR}/.audit/scripts-audit-"*.md 2>/dev/null | tail -1 || echo "OVERALL: N/A")
TRUTHS_COUNT=$(grep -c '^---$' "${CLAUDE_PROJECT_DIR}/.remembrance" 2>/dev/null || echo "0")
TRUTHS_COUNT=$((TRUTHS_COUNT / 2))

# Inject as system context
cat << EOF
<playground-context>
loop_state: ${LOOP_STATE}
compliance: ${COMPLIANCE}
truths_accumulated: ${TRUTHS_COUNT}
session_start: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
</playground-context>
EOF
```

### Metrics Calculation

```python
# scripts/playground-metrics.py
import yaml
import json
from datetime import datetime, timedelta
from pathlib import Path

def calculate_metrics(project_root: Path) -> dict:
    """Calculate playground dashboard metrics."""

    remembrance = project_root / ".remembrance"
    evolution = project_root / "scrum" / "EVOLUTION.md"

    # Parse remembrance for agent activity
    agents = {}
    if remembrance.exists():
        content = remembrance.read_text()
        for block in content.split("---"):
            if "agent:" in block:
                agent = block.split("agent:")[1].split("\n")[0].strip()
                agents[agent] = agents.get(agent, 0) + 1

    # Calculate compliance trend
    audits = list((project_root / ".audit").glob("*.md"))
    compliance_history = []
    for audit in sorted(audits):
        content = audit.read_text()
        if "OVERALL" in content:
            pct = int(content.split("OVERALL")[1].split("%")[0].split()[-1])
            compliance_history.append(pct)

    return {
        "agent_activity": agents,
        "compliance_trend": compliance_history,
        "truths_count": sum(agents.values()),
        "timestamp": datetime.utcnow().isoformat()
    }
```

## Higher-Order Context Patterns

### Pattern 1: Mode Injection

```json
{
  "mode": "focused",
  "constraints": ["no-new-features", "fix-only"],
  "priority": "PBI-V01"
}
```

### Pattern 2: Frame Override

```json
{
  "frame": "turkish",
  "archetype": "Guardian",
  "principle": "Duty first, power within"
}
```

### Pattern 3: Trace Enabled

```json
{
  "trace": true,
  "log_level": "debug",
  "output": ".playground/trace.log"
}
```

## Integration Points

```yaml
hooks:
  SessionStart:
    - playground-context.sh  # Inject dashboard state
  Stop:
    - playground-persist.sh  # Save metrics
  PostToolUse:
    - playground-trace.sh    # Log tool usage (if trace on)

skills:
  - /playground             # Main dashboard
  - /gantt                  # Roadmap view
  - /evolution              # Self-improvement log
  - /metrics                # Agent activity
  - /hidden                 # Behind-the-scenes

mcp:
  - context7                # Documentation queries
  - serena                  # Semantic code tools
```

## Best Practices (Context7 Feb 2026)

1. **Progressive Disclosure** — SKILL.md < 500 lines, details in references/
2. **Context Economy** — Load only what's needed for current task
3. **Parallel Execution** — Independent hooks run concurrently
4. **State Persistence** — YAML for structured state, .remembrance for truths
5. **Observability** — Every action should be traceable
6. **User as Loop** — Claude can't invoke itself; user interaction IS continuation
