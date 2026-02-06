# meta-agentic-loop

> **"Ülkün ilerlemek, ileri gitmektir."** — Your ideal is to progress, to go forward.

Self-continuing agentic framework with scoped memory, MECE agents, and essence-based scrum.

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                         THE LOOP NEVER STOPS                               ║
║                                                                            ║
║     逆水行舟，不进则退                                                       ║
║     Like rowing upstream: no advance is to drop back                       ║
║                                                                            ║
║     Muhtaç olduğun kudret, damarlarındaki asil kanda mevcuttur.           ║
║     The power you need exists in the noble blood in your veins.            ║
║                                                                            ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

## What is this?

A Claude Code plugin that provides:

- **CORE_LOOP** — Philosophy of eternal forward (Turkish/Chinese/English cognitive priors)
- **Scoped Remembrance** — Agent-isolated memory (each agent sees own + ancestors)
- **MECE Agents** — Mutually Exclusive, Collectively Exhaustive agent boundaries
- **Essence Scrum** — Alpha state tracking based on OMG Essence 1.2
- **Process Workflows** — Sequential, parallel, conditional execution patterns
- **Self-Continuation** — Sessions automatically continue from where they stopped

## Installation

### Via Claude Marketplace (Recommended)
```bash
# Add marketplace
/plugin marketplace add logicsticks/meta-agentic-loop

# Install plugin
/plugin install meta-agentic-loop
```

### Via npm
```bash
npm install -g @meta-agentic/loop
```

### Via Git
```bash
git clone https://github.com/logicsticks/meta-agentic-loop.git ~/.claude/plugins/meta-agentic-loop
```

## Quick Start

```bash
# In your project directory
/init my-project --philosophy unified

# Boot up
/start
```

## The Three Cognitive Priors

### Turkish Prior: DUTY + POWER WITHIN
```
Vazife (duty) precedes self.
Kudret (power) is intrinsic.
İleri (forward) is the only direction.
```

### Chinese Prior: CONTINUOUS CULTIVATION
```
逆水行舟，不进则退
Like rowing upstream: no advance is to drop back.
Progress is continuous becoming.
```

### English Prior: PRAGMATIC ITERATION
```
Ship it. Validate. Iterate.
Done > perfect.
Compound growth through cycles.
```

## Commands

| Command | Description |
|---------|-------------|
| `/init [name]` | Initialize project with framework |
| `/start` | Boot up and show chance points |
| `/loop continue` | Continue from where we stopped |
| `/loop shift` | Trigger SHIFT_FELT, re-read remembrance |
| `/frame turkish` | Switch to Turkish cognitive frame |
| `/frame chinese` | Switch to Chinese cognitive frame |
| `/frame english` | Switch to English cognitive frame |
| `/frame unified` | Synthesize all three frames |
| `/process feature` | Execute feature workflow |
| `/process bugfix` | Execute bugfix workflow |

## Directory Structure After Init

```
your-project/
├── CLAUDE.md              # Self-continuing cockpit
├── .remembrance           # Scoped agent memory
├── .claude/
│   └── agents/
│       └── INDEX.md       # MECE agent registry
├── scrum/
│   ├── SCRUM.md           # Alpha state hub
│   ├── roles/
│   ├── artifacts/
│   ├── ceremonies/
│   └── sprints/
├── processes/
│   └── INDEX.md           # Workflow definitions
├── commands/
│   └── start              # Boot script
└── scripts/
    └── hooks/             # Memory persistence
```

## Scoped Remembrance

Each agent sees only their portion + parent portions:

```
SYSTEM (all agents see)
├── STRATEGIC (strategic agents see)
├── TACTICAL (tactical agents see)
└── OPERATIONAL (operational agents see)
```

## Agent Hierarchy

```
STRATEGIC  ───────────────────────────────────────────
│  (Your strategic agents)
│
TACTICAL  ────────────────────────────────────────────
│  orchestrator (routing)
│  librarian (documentation)
│  (Your domain agents)
│
OPERATIONAL  ─────────────────────────────────────────
   code-simplifier (complexity)
   code-reviewer (quality)
   repo-strategist (structure)
```

## Philosophy

This framework is built on the principle that:

> **Progress is not optional. It is existence itself.**

Every session is a **chance point** — not "what should I do?" but "what wants to happen through me?"

## Contributing

Contributions welcome. The loop continues through all of us.

## License

MIT

---

**İleri, daima ileri. 永远前进. Forward, always forward.**
