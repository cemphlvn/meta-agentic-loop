# Meta-Agentic-Loop — System Index

> 逆水行舟，不进则退 — Like rowing upstream: no advance is to drop back

## Purpose

Reusable agentic framework providing:
- **Core Loop**: OBSERVE → DECIDE → ACT → LEARN → CONTINUE
- **Scoped Remembrance**: Agent-scoped memory with hierarchy
- **Essence Scrum**: OMG Essence 1.2 alpha states
- **Observability**: I → C → O truth evolution tracking
- **Skills & Processes**: Reusable workflows

## Module Index

| Module | Path | Purpose |
|--------|------|---------|
| **Agents** | `.claude/agents/` | Agent definitions, hierarchy, methodology |
| **Skills** | `skills/` | Reusable skill definitions |
| **Processes** | `processes/` | Workflow definitions (feature, bugfix, research) |
| **Observability** | `observability/` | Truth tracking, dynamic rounds, cockpit |
| **Hooks** | `hooks/` | SessionStart, Stop, PreToolUse hooks |
| **Scripts** | `scripts/` | Automation (loop-runner, maintenance) |
| **Templates** | `templates/` | Scaffolding templates |
| **Docs** | `docs/` | Techniques, patterns, guides |

## Change Taxonomy

Changes in this system are classified by scope:

```
┌─────────────────────────────────────────────────────────────┐
│  CLAUDE LAYER (Project-specific)                            │
│  • CLAUDE.md         → Project cockpit, commands            │
│  • .remembrance      → Accumulated truths (project scope)   │
│  • scrum/            → Sprint state, backlog                │
│  • .claude/agents/   → Project agent customizations         │
├─────────────────────────────────────────────────────────────┤
│  META LAYER (Reusable plugin)                               │
│  • plugin/           → meta-agentic-loop framework          │
│  • observability/    → Truth tracking, dashboards           │
│  • skills/           → Portable skill definitions           │
│  • processes/        → Workflow templates                   │
│  • hooks/            → Event handlers                       │
└─────────────────────────────────────────────────────────────┘
```

## Causality Chain

How remembrance influences the system:

```
.remembrance (truth logged)
    ↓
SHIFT_FELT trigger
    ↓
Re-read accumulated wisdom
    ↓
Update CLAUDE.md (if pattern emerges)
    ↓
Update agents/skills (if reusable)
    ↓
Sync to meta-agentic-loop (if universal)
```

## Key Files

| File | Scope | Purpose |
|------|-------|---------|
| `INDEX.md` | meta | This file — system map |
| `.remembrance` | claude | Truth accumulation |
| `SETUP.md` | meta | Installation guide |
| `README.md` | meta | Public documentation |
| `.claude/agents/INDEX.md` | meta | Agent registry |
| `processes/INDEX.md` | meta | Process registry |
| `observability/INDEX.md` | meta | Observability module docs |

## Metrics (Current)

| Metric | Value | Source |
|--------|-------|--------|
| Total Truths | 23 | .remembrance |
| Shape Shifts | 2 | shape_shift: true entries |
| Agents Defined | 18+ | .claude/agents/INDEX.md |
| Skills Available | 7+ | skills/ |
| Processes | 4 | processes/INDEX.md |

## Quick Commands

```bash
# View system state
bash observability/truth-tracker.sh report

# Start dynamic reporting
bash observability/dynamic-rounds.sh daemon 60 &

# Open visual cockpit
open observability/cockpit/index.html

# Check maintenance status
bash scripts/maintenance-check.sh
```

## Integration Points

```yaml
SessionStart:
  - Load scoped remembrance
  - Inject playground context
  - Load advanced-techniques skill
  - Show WHEREDUE pending items
  - Display truth dashboard

Stop:
  - Persist session learnings
  - Save observability snapshot

PreToolUse:
  - Verify agent scope (Task tool)
  - Security checks (Write tool)
```

## Version

- **Plugin Version**: 1.1.0
- **Last Sync**: 2026-02-07
- **Repository**: github.com/cemphlvn/meta-agentic-loop
