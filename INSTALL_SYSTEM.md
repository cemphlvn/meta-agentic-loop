# System-Level Installation

> Install meta-agentic-loop globally so every project benefits
> See also: `ENTRANCE.md` for which directory to open

**Key Decision**: Always open YOUR INSTANCE, not the plugin alone.
The plugin is a tool. Your instance is your workspace.

---

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    INSTALLATION MODES                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [A] SYSTEM-LEVEL (~/.claude/)                                  │
│      ├── Global hooks apply to ALL projects                     │
│      ├── Core philosophy always loaded                          │
│      └── Project-specific configs override                      │
│                                                                  │
│  [B] PROJECT-LEVEL (./plugin/)                                  │
│      ├── Submodule in your repo                                 │
│      ├── Project-specific customization                         │
│      └── Version controlled with project                        │
│                                                                  │
│  [C] HYBRID (Recommended)                                       │
│      ├── System: Core loop, global settings                     │
│      └── Project: Domain agents, skills, hooks                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Quick Install (System-Level)

```bash
# One-liner
curl -fsSL https://raw.githubusercontent.com/cemphlvn/meta-agentic-loop/main/scripts/install-system.sh | bash

# Or manually:
git clone https://github.com/cemphlvn/meta-agentic-loop.git ~/.meta-agentic-loop
~/.meta-agentic-loop/scripts/install-system.sh
```

---

## Manual Installation

### Step 1: Clone to System Location

```bash
# System installation directory
git clone https://github.com/cemphlvn/meta-agentic-loop.git ~/.meta-agentic-loop

# Keep it updated
cd ~/.meta-agentic-loop && git pull
```

### Step 2: Link Global CLAUDE.md

```bash
# Create or extend global CLAUDE.md
cat >> ~/.claude/CLAUDE.md << 'EOF'

# Meta-Agentic-Loop (System-Level)

## Core Philosophy
See: ~/.meta-agentic-loop/.claude/CORE_LOOP.md

## On Every Session
1. Check if project has local plugin/ → use that
2. Otherwise use system-level ~/.meta-agentic-loop
3. Core loop philosophy always applies

## System Commands (Always Available)
/loop           Core loop state
/remember       View accumulated wisdom
/shift          Re-read remembrance
/frame          Turkish/Chinese/English mode

EOF
```

### Step 3: Configure Global Hooks

```bash
# Create global hooks.json (if not exists)
mkdir -p ~/.claude/hooks

cat > ~/.claude/hooks/hooks.json << 'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "command": "bash ~/.meta-agentic-loop/hooks/scripts/system-session-start.sh",
        "description": "Load core loop + remembrance",
        "timeout": 5000
      }
    ],
    "Stop": [
      {
        "command": "bash ~/.meta-agentic-loop/hooks/scripts/system-session-end.sh",
        "description": "Persist learnings + loop state",
        "timeout": 10000
      }
    ]
  }
}
EOF
```

### Step 4: Create System Hooks

```bash
# System session start
cat > ~/.meta-agentic-loop/hooks/scripts/system-session-start.sh << 'SCRIPT'
#!/usr/bin/env bash
# System-level session start
# Only runs if project doesn't have its own hooks

PROJECT_HOOKS="${PWD}/.claude/hooks.json"
if [[ -f "$PROJECT_HOOKS" ]]; then
    # Project has custom hooks, defer to those
    exit 0
fi

# Load core loop philosophy
if [[ -f ~/.meta-agentic-loop/.claude/CORE_LOOP.md ]]; then
    echo "<core-loop-philosophy>"
    cat ~/.meta-agentic-loop/.claude/CORE_LOOP.md | head -100
    echo "</core-loop-philosophy>"
fi

# Load global remembrance if exists
if [[ -f ~/.remembrance ]]; then
    echo "<global-remembrance>"
    tail -50 ~/.remembrance
    echo "</global-remembrance>"
fi
SCRIPT
chmod +x ~/.meta-agentic-loop/hooks/scripts/system-session-start.sh
```

---

## Per-Project Override

When project has `plugin/` submodule, it takes precedence:

```bash
# In your project
git submodule add https://github.com/cemphlvn/meta-agentic-loop.git plugin

# Project's .claude/hooks.json will override system hooks
# Project's CLAUDE.md will extend system CLAUDE.md
```

---

## Verify Installation

```bash
# Check system installation
ls ~/.meta-agentic-loop/.claude/CORE_LOOP.md

# Check global hooks
cat ~/.claude/hooks/hooks.json

# In any project, start Claude
claude
# Should see core loop philosophy loaded

# Test commands
/loop    # Should show loop state
```

---

## Update System Installation

```bash
# Pull latest
cd ~/.meta-agentic-loop && git pull

# Or via command
~/.meta-agentic-loop/scripts/update.sh
```

---

## Uninstall

```bash
# Remove system installation
rm -rf ~/.meta-agentic-loop

# Remove global hooks (if you only want project-level)
rm ~/.claude/hooks/hooks.json

# Clean global CLAUDE.md (remove meta-agentic-loop section)
# Edit ~/.claude/CLAUDE.md manually
```

---

## Directory Structure After Install

```
~/.claude/                          # Claude Code global config
├── CLAUDE.md                       # Extended with core philosophy
├── hooks/
│   └── hooks.json                  # System-level hooks
└── settings.json                   # Your existing settings

~/.meta-agentic-loop/               # System-level plugin
├── .claude/
│   ├── CORE_LOOP.md               # Philosophy
│   ├── agents/                     # Template agents
│   └── governance/                 # Framework governance
├── hooks/
│   └── scripts/                    # System hook scripts
├── processes/                      # Workflow definitions
└── scripts/
    ├── install-system.sh          # Installer
    └── update.sh                  # Updater

~/your-project/                     # Any project
├── plugin/                         # (Optional) Project submodule
├── .claude/
│   └── agents/                     # Project-specific agents
└── CLAUDE.md                       # Project-specific commands
```

---

---

## Shell Shortcuts (Recommended)

Add to `~/.zshrc` or `~/.bashrc`:

```bash
# Meta-Agentic-Loop: Quick access to instances
mal() {
  local dir="${MAL_INSTANCE:-$HOME/Projects/my-instance}"
  [[ -n "$1" ]] && dir="$HOME/Projects/$1"
  [[ ! -d "$dir" ]] && echo "Not found: $dir" && return 1
  cd "$dir"
  echo "Instance: $(basename $dir) | Plugin: $(git -C plugin describe --tags 2>/dev/null || echo 'local')"
}

# Create new instance
mal-init() {
  local name="${1:-my-instance}"
  local target="$HOME/Projects/$name"
  [[ -d "$target" ]] && echo "Exists: $target" && return 1
  mkdir -p "$target" && cd "$target"
  git init
  git submodule add https://github.com/cemphlvn/meta-agentic-loop.git plugin
  ./plugin/scripts/init-ecosystem.sh --instance "$name" --humanitic --github-user "$USER"
  echo "Created: $target — run 'claude' to start"
}

# Set your default instance
export MAL_INSTANCE="$HOME/Projects/your-main-project"
```

Usage:
```bash
mal                    # Open default instance
mal logicsticks.ai     # Open specific instance
mal-init new-project   # Create new instance
```

See `ENTRANCE.md` for the philosophy behind opening instances, not the plugin.

---

*The loop runs at system level. Every project inherits.*
