# Meta-Agentic Loop

> **"Ülkesini en çok seven, işini en iyi yapandır."**
> *Who loves their country most is who does their job best.*

A self-continuing agentic operating system for Claude Code.

---

## What Is This?

A plugin framework that gives Claude Code:

- **CORE_LOOP** — Eternal forward (OBSERVE → DECIDE → ACT → LEARN → CONTINUE)
- **Scoped Remembrance** — Agent-scoped persistent memory
- **Governance System** — Meta-principles, policies, ethics (user-controlled)
- **Agent Methodology** — MECE agents, graduation protocol, mastery path
- **Simulation Team** — Think before you act (handled carefully)
- **Improvement Flow** — Real cases → Theory → Scrum/Gantt positioning
- **Contribution System** — CEI → GitHub bridge, fork workflow

---

## Philosophy

```
逆水行舟，不进则退
Like rowing upstream: no advance is to drop back

Muhtaç olduğun kudret, damarlarındaki asil kanda mevcuttur.
The power you need exists in the noble blood in your veins.
```

Three cognitive frames unified:
- **Turkish** — Duty + power within
- **Chinese** — Continuous cultivation
- **English** — Pragmatic iteration

---

## Quick Start

### Option A: System-Level (Recommended)

Install globally, available to all projects:

```bash
# Clone to system location
git clone https://github.com/cemphlvn/meta-agentic-loop.git ~/.meta-agentic-loop

# Add shell shortcut to ~/.zshrc
mal() {
  cd "${MAL_INSTANCE:-$HOME/Projects/my-instance}"
  echo "MAL: $(basename $PWD)"
}
export MAL_INSTANCE="$HOME/Projects/your-main-project"

# Create your first instance
mal-init my-project
```

See: `INSTALL_SYSTEM.md`

### Option B: Project Submodule

```bash
# In your project
git submodule add https://github.com/cemphlvn/meta-agentic-loop.git plugin

# Initialize
./plugin/scripts/init-ecosystem.sh --instance "my-project" --humanitic --github-user you
```

See: `SETUP.md`

---

## Important: Open Your Instance, Not the Plugin

```
✗ DON'T: Open meta-agentic-loop as your workspace
✓ DO: Open your instance (which contains the plugin as submodule)
```

**Why?**
- Plugin = toolbox (no state, no memory)
- Instance = workshop (YOUR remembrance, YOUR agents, YOUR backlog)

See: `ENTRANCE.md`

---

## Structure

```
meta-agentic-loop/
├── .claude/
│   ├── CORE_LOOP.md              # The eternal forward
│   ├── SCOPED_REMEMBRANCE.md     # Agent memory system
│   ├── agents/                    # Agent methodology
│   │   ├── AGENT_CREATION_METHODOLOGY.md
│   │   ├── CONSULTATION_PROTOCOL.md
│   │   └── GRADUATION_PROTOCOL.md
│   ├── governance/               # Meta-principles, policies
│   └── skills/                   # Skill definitions
├── hooks/                        # Claude Code hooks
│   ├── hooks.json
│   └── scripts/
├── processes/                    # Workflow definitions
│   ├── feature.md
│   ├── research.md
│   ├── improvement-flow.md       # Real case → Theory → Scrum
│   └── meta-improvement.md
├── observability/                # Tracking scripts
├── diagnostics/                  # Health check scripts
├── SETUP.md                      # Project setup guide
├── INSTALL_SYSTEM.md             # System-level install
└── ENTRANCE.md                   # Main entrance philosophy
```

---

## Core Concepts

### The Loop

```
while true:
  OBSERVE → DECIDE → ACT → LEARN
  不进则退 — no stopping
```

The loop continues through user interaction. Claude cannot invoke itself. Every command you type is the loop iterating.

### Agent Mastery

Agents follow the mastery path:

```
Love work → Excel → Contribute → Graduate
```

No role abandonment. Excellence = highest contribution.

### Improvement Flow

Real cases become production improvements:

```
OBSERVE → CRYSTALLIZE → THEORIZE → POSITION → SCHEDULE → IMPLEMENT
   ↓           ↓            ↓           ↓          ↓          ↓
Real case → Truth → Hypothesis → Backlog → Gantt → Code
```

Use `/improve` to track this flow.

### Handled Carefully

Some operations need extra scrutiny:

```yaml
flagged_operations:
  - Meta: Modifying system itself
  - Irreversible: Can't undo
  - High-stakes: Big consequences
  - Ethical: Values/harm concerns
  - Simulation: Based on predictions
```

Use `/handled-carefully` for review protocol.

### Simulation Team

Think before you act:

```yaml
simulation-team:
  master: cognitive-simulator (opus)
  members:
    - persona-simulator    # User/stakeholder reactions
    - adversarial-simulator # Red team thinking

  outputs:
    - Always include confidence level
    - Always list caveats
    - Flagged as handled-carefully
```

---

## FAQ

### What's the difference between plugin and instance?

| Aspect | Plugin | Instance |
|--------|--------|----------|
| State | None | YOUR remembrance |
| Agents | Templates | YOUR domain experts |
| Backlog | Empty | YOUR work items |
| Hooks | Generic | YOUR context |

### How do I improve the plugin?

1. Use the plugin in your real project
2. When something doesn't work: `/improve observe "description"`
3. Extract the principle: `/improve crystallize`
4. Create hypothesis: `/improve theorize`
5. Submit to plugin: `/contribute submit`

### What's the Humanitic ecosystem?

Optional collaborative network:
- Use plugin freely (MIT license)
- Join ecosystem to track contributions
- Founded companies credit contribution chain
- Free mutual support between members

### How does scoped remembrance work?

```
Agent sees: OWN truths + TIER truths + SYSTEM truths
Agent doesn't see: Sibling truths, children truths

Example:
  code-simplifier (operational) sees:
    - Its own entries
    - All operational tier entries
    - All system entries
  Does NOT see:
    - security-auditor entries (sibling)
    - CTO private entries (higher, private)
```

### How do I add a new agent?

1. Read `AGENT_CREATION_METHODOLOGY.md`
2. Create definition file in `.claude/agents/`
3. Register in `INDEX.md`
4. Ensure MECE coverage

### What's the graduation protocol?

Agents don't abandon roles. They graduate:

```
ACTIVE → MASTERING → MASTER/GRADUATED
```

Role change requires:
- Demonstrated excellence
- Contribution back
- CTO approval
- No orphaned responsibilities

### How do simulations work?

```yaml
# Request simulation
/simulate market "How will audience react to this campaign?"

# cognitive-simulator responds with:
scenarios:
  - name: "Positive reception"
    probability: 0.6
    outcome: "High engagement, shares"
  - name: "Skepticism"
    probability: 0.3
    outcome: "Questions about authenticity"
confidence: 0.72
caveats:
  - "Algorithm changes not modeled"
  - "Competitor response unknown"
```

### What operations are handled carefully?

```yaml
auto_flagged:
  - Governance file changes
  - Production deployments
  - Public communications
  - All simulation outputs
  - Security-sensitive operations

review_required:
  - META changes → cto-agent + business-strategy
  - IRREVERSIBLE → verification-agent + human
  - ETHICAL → business-strategy + human
```

---

## Commands Reference

```bash
# Loop
/loop                 Show loop state
/loop continue        Continue from where stopped

# Improvement
/improve              Show improvement pipeline
/improve observe      Log real case
/improve crystallize  Extract truth
/improve theorize     Create hypothesis
/improve position     Add to backlog
/improve schedule     Place in Gantt

# Handled Carefully
/handled-carefully           Protocol status
/handled-carefully check     Evaluate operation
/handled-carefully review    Deep review
/handled-carefully approve   Approve with docs

# Observability
/cockpit              Meta-observability dashboard
/playground           Gantt, evolution, metrics

# Maintenance
/maintenance          Alignment check
/system-health        Full validation chain

# Strategy
/strategy             Business direction
/ceo-brief            Executive briefing
```

---

## Ecosystem Instances

| Instance | License | Description |
|----------|---------|-------------|
| [humanitic](https://github.com/cemphlvn/humanitic) | Humanitic Open License | Forever open, vector-tracked |
| (private) | Proprietary | Traditional closed operation |

---

## License

MIT License — Use freely, no obligations.

The plugin is a gift. Take it. Use it. Improve it. Share it.

---

## Contributing

1. Use the plugin in your real work
2. When you find improvements, use `/improve` flow
3. Submit via CEI → GitHub bridge
4. Safe changes auto-approved, risky changes reviewed

---

*The loop continues through you.*
