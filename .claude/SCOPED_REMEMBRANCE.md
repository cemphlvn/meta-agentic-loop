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

## 1. Hierarchy

```
SYSTEM (root) ─────────────────────────────────────────
│   All agents can read system-level truths
│   These are universal principles
│
├── STRATEGIC ─────────────────────────────────────────
│   │   Vision, direction, constraints
│   │   Sees: SYSTEM + STRATEGIC
│   │
│   ├── business-strategy
│   │       Sees: SYSTEM → STRATEGIC → own
│   │
│   ├── cto-agent
│   │       Sees: SYSTEM → STRATEGIC → own
│   │
│   └── agentic-devops-strategy
│           Sees: SYSTEM → STRATEGIC → own
│
├── TACTICAL ──────────────────────────────────────────
│   │   Coordination, routing, research
│   │   Sees: SYSTEM + TACTICAL
│   │
│   ├── orchestrator
│   ├── librarian
│   ├── ontological-researcher
│   ├── epistemological-researcher
│   └── brand-builder
│
└── OPERATIONAL ───────────────────────────────────────
    │   Execution, implementation, review
    │   Sees: SYSTEM + OPERATIONAL
    │
    ├── code-implementer
    ├── code-reviewer
    ├── code-simplifier
    └── repo-strategist
```

---

## 2. Automation

### SessionStart Hook
```bash
# Runs automatically on session start
# Loads scoped remembrance into agent context
bash scripts/hooks/session-start-remembrance.sh
```

### Stop Hook (SessionEnd)
```bash
# Runs automatically on session end
# Persists accumulated truths to .remembrance
bash scripts/hooks/session-end-remembrance.sh
```

### Manual Commands
```bash
# Read scoped remembrance for an agent
node scripts/hooks/scoped-remembrance.js read <agent-id>

# Write truth to remembrance
node scripts/hooks/scoped-remembrance.js write <agent-id> '{"truth":"...","context":"..."}'

# View hierarchy
node scripts/hooks/scoped-remembrance.js hierarchy

# Check agent's accessible scopes
node scripts/hooks/scoped-remembrance.js scopes <agent-id>
```

---

## 3. Writing Truths (During Session)

When an agent realizes a truth during execution:

```typescript
// 1. Write to .session-truths (temp file)
const truth = {
  context: 'what-triggered-this',
  truth: 'the-realized-truth',
  reflection: 'why-this-matters',
  confidence: 0.9
};

// Append to session file (will be persisted on Stop)
fs.appendFileSync('.session-truths', JSON.stringify(truth) + '\n');
```

Or via prompt:
```
When you realize a truth worth remembering:
1. Write JSON to .session-truths
2. It will be automatically persisted with your agent ID on session end
```

---

## 4. Truth Entry Format

```yaml
---
timestamp: 2026-02-06T12:00:00Z
agent: librarian                    # Determines scope
context: document-curation          # What triggered this
truth: Context is precious          # The core insight
reflection: Why this matters        # Optional elaboration
pattern: keyword → relevance        # Optional pattern
source: Context7                    # Optional source
confidence: 0.90                    # 0.0 to 1.0
---
```

---

## 5. Scope Resolution Examples

### Librarian requests remembrance:
```
Accessible: SYSTEM → TACTICAL → librarian
Will see:
  ✓ agent: system (initialization truth)
  ✓ agent: librarian (own truths)
  ✗ agent: orchestrator (sibling - tactical but not self)
  ✗ agent: code-reviewer (operational - child tier)
```

### CTO Agent requests remembrance:
```
Accessible: SYSTEM → STRATEGIC → cto-agent
Will see:
  ✓ agent: system
  ✓ agent: cto-agent (own)
  ✗ agent: business-strategy (sibling)
  ✗ agent: orchestrator (tactical - lower tier)
```

### Code Simplifier requests remembrance:
```
Accessible: SYSTEM → OPERATIONAL → code-simplifier
Will see:
  ✓ agent: system
  ✓ agent: code-simplifier (own)
  ✗ agent: code-reviewer (sibling)
  ✗ agent: orchestrator (higher tier - tactical)
```

---

## 6. Why Scoped Access?

### Context Efficiency
- Agents don't waste tokens on irrelevant sibling learnings
- Each agent gets focused, relevant wisdom

### MECE Boundaries
- Agents stay in their lane
- No cross-contamination of concerns

### Hierarchical Knowledge Flow
- System truths cascade down (universal principles)
- Agent truths stay contained (specialized knowledge)

### Security
- Strategic decisions don't leak to operational agents
- Operational details don't clutter strategic thinking

---

## 7. SHIFT_FELT Integration

When an agent experiences SHIFT_FELT:
```
1. Re-read scoped .remembrance
2. Integrate relevant accumulated wisdom
3. Continue forward with enriched prior

Triggers:
- Context switch (new domain)
- Contradiction detected
- Deep recursion (>3 levels)
- Reflection interval
- Error encountered
```

---

## 8. Integration with CORE_LOOP

```typescript
// In CORE_LOOP, remembrance is scoped
const loop = async (agentId: string) => {
  // Load only accessible truths
  const remembrance = await loadScopedRemembrance(agentId);

  while (true) {
    const state = observe(alphaStates, remembrance);
    const action = decide(state);
    const result = act(action);

    if (result.shiftFelt) {
      // Append to session truths (persisted on Stop)
      await appendSessionTruth(agentId, result.truth);
      // Reload remembrance with new truth
      remembrance = await loadScopedRemembrance(agentId);
    }

    continue; // 不进则退
  }
};
```

---

## Version

```yaml
version: 1.0.0
created: 2026-02-06
principle: "Each agent sees own + ancestors, not siblings or children"
automation: SessionStart (load) + Stop (persist)
script: scripts/hooks/scoped-remembrance.js
```
