---
name: scoped-remembrance
description: Agent-scoped memory system — each agent sees own + ancestors
invocation: /remembrance
---

# Scoped Remembrance Protocol

> **Principle**: Each agent accesses only their portion + parent portions of accumulated wisdom.

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    AGENT-SCOPED MEMORY SYSTEM                              ║
║                                                                            ║
║  "Know thyself, know thy ancestors, ignore thy siblings"                   ║
║                                                                            ║
║  An agent sees:                                                            ║
║    ✓ SYSTEM truths (universal)                                             ║
║    ✓ TIER truths (strategic/tactical/operational)                          ║
║    ✓ OWN truths (personal learnings)                                       ║
║    ✗ SIBLING truths (other agents at same level)                           ║
║    ✗ CHILD truths (agents below in hierarchy)                              ║
║                                                                            ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## Hierarchy

```
SYSTEM (root) ─────────────────────────────────────────
│   All agents can read system-level truths
│
├── STRATEGIC ─────────────────────────────────────────
│   │   Sees: SYSTEM + STRATEGIC
│   │
│   ├── {{strategic-agent-1}}
│   ├── {{strategic-agent-2}}
│   └── {{strategic-agent-3}}
│
├── TACTICAL ──────────────────────────────────────────
│   │   Sees: SYSTEM + TACTICAL
│   │
│   ├── orchestrator
│   ├── librarian
│   └── {{domain-agents}}
│
└── OPERATIONAL ───────────────────────────────────────
        Sees: SYSTEM + OPERATIONAL

        ├── code-simplifier
        ├── code-reviewer
        └── {{implementation-agents}}
```

---

## Memory Entry Format

```yaml
---
timestamp: ISO-8601
agent: <agent-id>           # Determines scope
scope: <tier>               # Optional: system|strategic|tactical|operational
context: <what-triggered>
truth: <the-realized-truth>
reflection: <why-this-matters>
confidence: 0.0-1.0
---
```

---

## Automation

### SessionStart Hook
```bash
# Loads scoped remembrance into agent context
node hooks/scripts/scoped-remembrance.js read $CLAUDE_AGENT_ID
```

### Stop Hook (SessionEnd)
```bash
# Persists accumulated truths to .remembrance
node hooks/scripts/scoped-remembrance.js write $CLAUDE_AGENT_ID "$TRUTH_JSON"
```

---

## Access Rules

| Agent Tier | Can See | Cannot See |
|------------|---------|------------|
| Strategic | SYSTEM + STRATEGIC + own | Tactical, Operational |
| Tactical | SYSTEM + TACTICAL + own | Strategic, Operational |
| Operational | SYSTEM + OPERATIONAL + own | Strategic, Tactical |

---

## SHIFT_FELT Integration

When an agent experiences SHIFT_FELT:
1. Re-read scoped .remembrance
2. Integrate relevant accumulated wisdom
3. Continue forward with enriched prior

Triggers:
- Context switch (new domain)
- Contradiction detected
- Deep recursion (>3 levels)
- Reflection interval
- Error encountered
