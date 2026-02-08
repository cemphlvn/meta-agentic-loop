---
description: Run observability workflow audit
allowed-tools: Bash, Read
argument-hint: [mode]
---

# /mal-audit — Workflow Observability Audit

Audit the observability infrastructure for gaps and improvements.

## Modes

### full (default)
Run complete audit:
```bash
!`${CLAUDE_PLUGIN_ROOT}/observability/workflow-audit/audit.sh`
```

### coverage
Show observability coverage metrics:
```bash
!`${CLAUDE_PLUGIN_ROOT}/observability/workflow-audit/audit.sh coverage`
```

### opportunities
List improvement opportunities:
```bash
!`ls ${CLAUDE_PLUGIN_ROOT}/observability/workflow-audit/opportunities/*.yaml 2>/dev/null | while read f; do echo "---"; grep -E "^(id|title|priority|status):" "$f"; done`
```

### evolution
Show observability evolution trajectory:
```bash
!`${CLAUDE_PLUGIN_ROOT}/observability/workflow-audit/audit.sh evolution`
```

## Philosophy

The audit follows the agentic-scriptic duality:
- **Agentic Intelligence**: Flexibility under uncertainty
- **Scriptic Architecture**: Observability and traceability

Goal: NOT rigid determinism, but intelligent adaptation WITH clear observability.

## Evolution Trajectory

```
ad-hoc → observable → adaptive → flourishing
```

## Usage

- `/mal-audit` — Run full audit
- `/mal-audit coverage` — Show coverage %
- `/mal-audit opportunities` — List OPPs
