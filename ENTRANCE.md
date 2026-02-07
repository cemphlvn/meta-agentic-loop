# Main Entrance Point — Strategic Decision

> Documented by philosophers and strategists
> "The door through which you enter shapes the room you see."

---

## The Decision

```
┌─────────────────────────────────────────────────────────────────┐
│                    ENTRANCE POINT DECISION                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Q: Clone meta-agentic-loop repo OR an instance of it?          │
│                                                                  │
│  A: ALWAYS clone/open YOUR INSTANCE, never the plugin alone.    │
│                                                                  │
│  Reason: The plugin is a TOOL. You are the CRAFTSMAN.           │
│          Open your workshop, not the toolbox.                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Philosophy

### Chinese Frame (修炼 — Cultivation)
The plugin is the method (法). Your instance is the practice (修).
You don't open the manual — you open your training ground.
The method lives inside the practice, not beside it.

### Turkish Frame (Görev — Duty)
The plugin is capability (kudret). Your instance is duty (görev).
Power exists to serve purpose. Open the purpose, power follows.

### English Frame (Pragmatic)
The plugin has no state, no memory, no domain.
Your instance has YOUR remembrance, YOUR agents, YOUR backlog.
Work happens in context, not in abstraction.

---

## The Entrance

```
YOUR INSTANCE (always open this)
├── plugin/                    ← The toolbox (submodule)
├── .claude/agents/            ← YOUR domain agents
├── .remembrance               ← YOUR accumulated wisdom
├── scrum/                     ← YOUR backlog, YOUR sprints
└── CLAUDE.md                  ← YOUR cockpit

meta-agentic-loop alone (never open as workspace)
├── Template agents            ← Generic, not yours
├── Example processes          ← Patterns, not practice
└── No domain context          ← Abstract, not concrete
```

---

## System Shortcut

### The `mal` Command

Add to `~/.zshrc` or `~/.bashrc`:

```bash
# Meta-Agentic-Loop: Open your instance
mal() {
  local instance_dir="${MAL_INSTANCE:-$HOME/Projects/my-instance}"

  if [[ -n "$1" ]]; then
    # mal <project> — open specific instance
    instance_dir="$HOME/Projects/$1"
  fi

  if [[ ! -d "$instance_dir" ]]; then
    echo "Instance not found: $instance_dir"
    echo "Create one with: mal-init <name>"
    return 1
  fi

  cd "$instance_dir"
  echo "╔═══════════════════════════════════════════════════════════════╗"
  echo "║                    META-AGENTIC-LOOP                          ║"
  echo "╠═══════════════════════════════════════════════════════════════╣"
  echo "║  Instance: $(basename $instance_dir)"
  echo "║  Plugin:   $(git -C plugin describe --tags 2>/dev/null || echo 'local')"
  echo "║                                                               ║"
  echo "║  Commands: claude         Start Claude Code                   ║"
  echo "║            /loop          Show loop state                     ║"
  echo "║            /improve       Improvement pipeline                ║"
  echo "╚═══════════════════════════════════════════════════════════════╝"
}

# Create new instance
mal-init() {
  local name="${1:-my-instance}"
  local target="$HOME/Projects/$name"

  if [[ -d "$target" ]]; then
    echo "Already exists: $target"
    return 1
  fi

  echo "Creating instance: $name"
  mkdir -p "$target"
  cd "$target"
  git init
  git submodule add https://github.com/cemphlvn/meta-agentic-loop.git plugin
  ./plugin/scripts/init-ecosystem.sh --instance "$name" --humanitic --github-user "$USER"

  echo ""
  echo "Instance created: $target"
  echo "Next: mal $name && claude"
}

# Set default instance
export MAL_INSTANCE="$HOME/Projects/logicsticks.ai"  # Change to your main instance
```

### Usage

```bash
# Open default instance
mal

# Open specific instance
mal logicsticks.ai
mal my-brand

# Create new instance
mal-init new-project

# Then start Claude
claude
```

---

## Why Not Open Plugin Directly?

| Aspect | Plugin Alone | Your Instance |
|--------|--------------|---------------|
| .remembrance | Empty template | YOUR wisdom |
| Agents | Generic examples | YOUR domain experts |
| Backlog | Empty | YOUR work items |
| Hooks | Work but no context | Load YOUR context |
| Improvement | Can't position in YOUR Gantt | Flows to YOUR sprints |

**The plugin is the seed. Your instance is the tree.**

---

## Installation Checklist

```bash
# 1. Add to shell config
echo 'source ~/.mal-shortcuts.sh' >> ~/.zshrc

# 2. Create shortcuts file
cat > ~/.mal-shortcuts.sh << 'EOF'
# [Paste the mal() and mal-init() functions above]
EOF

# 3. Set your default instance
echo 'export MAL_INSTANCE="$HOME/Projects/your-main-project"' >> ~/.mal-shortcuts.sh

# 4. Reload shell
source ~/.zshrc

# 5. Test
mal
```

---

## Strategic Alignment

This entrance point decision aligns with:

1. **Core Loop Philosophy**: Work happens in YOUR context, not abstraction
2. **Scoped Remembrance**: Wisdom accumulates in YOUR instance
3. **Improvement Flow**: Real cases position in YOUR Gantt
4. **CEI Bridge**: Contributions flow FROM your instance TO plugin

**The plugin improves through your practice. Your practice deepens through the plugin.**

---

*Open your instance. The loop continues through you.*
