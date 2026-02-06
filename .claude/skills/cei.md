---
name: cei
description: Cognitively Ergonomic Interface - manage agent suggestions
invocation: /cei
---

# CEI Skill — Cognitively Ergonomic Interface

> "Agents suggest. Users decide. Evolution continues."

## Overview

CEI is where agent suggestions flow for user review. Agents cannot modify governance or culture directly — they propose changes that users approve, veto, or send for research.

## Commands

```
/cei                   Dashboard view
/cei stats             Proposal statistics
/cei review            Start review session
/cei pending           List pending items
/cei next              Get next item to review
/cei approve {id}      Approve proposal
/cei veto {id} {why}   Veto with reason
/cei research {id}     Request more research
/cei improve {id}      Send back with feedback
/cei maintenance       View maintenance queue
/cei implement {id}    Start implementation
/cei complete {id}     Mark as completed

# Propose (create new suggestions)
/cei propose {type} "{summary}"
```

## Proposal Types

| Type | Use When |
|------|----------|
| `process` | Suggest workflow improvements |
| `agent` | Suggest agent creation/improvement |
| `culture` | Suggest culture vector changes |
| `governance` | Suggest meta-principle changes (rare) |
| `bugfix` | Report something broken |
| `feature` | Suggest new capability |

## Proposal Types

| Type | Description | Typical Source |
|------|-------------|----------------|
| `governance_improvement` | Changes to policies/ethics | compliance-auditor |
| `culture_suggestion` | Updates to culture vectors | any sub-agent |
| `process_change` | Workflow modifications | orchestrator |
| `agent_creation` | New agent proposal | cto-agent |

## Decision Flow

```
Agent creates proposal
      ↓
/user/CEI_STRUCTURE/proposals/PROP-{timestamp}.yaml
      ↓
User reviews with /cei review
      ↓
Decision:
  APPROVE → maintenance team implements
  VETO → rejected with reason
  RESEARCH → assigned for investigation
  IMPROVE → sent back with feedback
```

## Integration

### With Governance
```
Governance proposals → CEI → user approval → governance updated
```

### With Culture
```
Culture suggestions → CEI → user approval → culture propagated
```

### With Maintenance Team
```
Approved items → maintenance team → implemented → verified
```

## Queue Locations

| Queue | File | Purpose |
|-------|------|---------|
| Pending | `queue/pending.yaml` | Awaiting review |
| Approved | `queue/approved.yaml` | Ready for implementation |
| Vetoed | `queue/vetoed.yaml` | Rejected |
| Research | `queue/research.yaml` | Needs investigation |

## For Agents

To create a proposal:
```yaml
# Agent creates in /user/CEI_STRUCTURE/proposals/
type: command
command: |
  Create proposal file:
  /user/CEI_STRUCTURE/proposals/PROP-{timestamp}.yaml

  With format:
  ---
  id: PROP-{timestamp}
  agent: {your-agent-id}
  type: {proposal-type}
  proposal:
    summary: "{brief}"
    details: "{full details}"
    rationale: "{why}"
  confidence: {0.0-1.0}
  ---
```

---

*Suggestions shape the system. Decisions shape the future.*
