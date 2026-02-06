# First-Time Setup Guide

> From zero to contributing in 5 minutes

---

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    ECOSYSTEM ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  meta-agentic-loop          (UNLICENSED PLUGIN - MIT)           │
│  ─────────────────                                               │
│  The core framework. Use freely. No obligations.                │
│  Contains: CORE_LOOP, agents, governance, skills                │
│                                                                  │
│       ↓ voluntary                                                │
│                                                                  │
│  humanitic                  (ECOSYSTEM - Humanitic License)     │
│  ─────────                                                       │
│  Optional ecosystem to join. If you join:                       │
│  - Your contributions are tracked via vectors                   │
│  - You can use others' work freely                              │
│  - Founded companies credit the chain                           │
│                                                                  │
│       ↓ your choice                                              │
│                                                                  │
│  your-project               (YOUR LICENSE)                       │
│  ────────────                                                    │
│  Uses plugin, optionally joins ecosystem                        │
│  Your domain, your rules, your ownership                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Quick Start (One Command)

```bash
# Create new project with meta-agentic-loop
npx create-mal my-project --humanitic --github-user yourusername

# Or manually:
mkdir my-project && cd my-project
git init
git submodule add https://github.com/cemphlvn/meta-agentic-loop.git plugin
./plugin/scripts/init-ecosystem.sh --instance "my-project" --humanitic --github-user you
```

---

## Setup Order

### Step 1: Get the Plugin

```bash
# Option A: As submodule (recommended for projects)
git submodule add https://github.com/cemphlvn/meta-agentic-loop.git plugin

# Option B: Clone standalone (for exploration)
git clone https://github.com/cemphlvn/meta-agentic-loop.git
```

### Step 2: Choose Your Mode

| Mode | Command | What It Means |
|------|---------|---------------|
| **Humanitic** | `--humanitic` | Join open ecosystem, track contributions |
| **Private** | `--private` | Use plugin, no ecosystem obligations |

### Step 3: Initialize

```bash
# As Humanitic member
./plugin/scripts/init-ecosystem.sh \
  --instance "my-project" \
  --humanitic \
  --github-user yourusername

# As private project
./plugin/scripts/init-ecosystem.sh \
  --instance "my-project" \
  --private \
  --github-user yourusername
```

### Step 4: Verify

```bash
# Check structure
ls -la
# Should see: plugin/, .claude/, ecosystem.config.yaml

# Test Claude Code integration
claude --version
```

---

## What Gets Created

```
my-project/
├── plugin/                    → meta-agentic-loop (submodule)
│   ├── .claude/               # Core: LOOP, agents, governance
│   ├── scripts/               # init, hooks
│   └── processes/             # workflows
├── instances/
│   └── humanitic/             → humanitic ecosystem (if joined)
├── .claude/
│   └── agents/                # Your project-specific agents
├── user/
│   ├── curiosities/           # Your areas of exploration
│   └── CEI_STRUCTURE/         # Your contribution proposals
├── ecosystem.config.yaml      # Your instance config
└── .remembrance               # Your accumulated wisdom
```

---

## Contribution Flow

### Auto-Approval (Safe Changes)

Safe changes are auto-approved and merged:

```yaml
auto_approve_criteria:
  - docs_only: true           # Documentation changes
  - typo_fix: true            # Typo corrections
  - test_addition: true       # New tests (not modifying existing)
  - non_breaking: true        # Additions that don't change existing behavior
  - vector_update: true       # Updating own contribution vectors
```

### Admin Review (Risky Changes)

Forwarded to admin for review:

```yaml
requires_admin_review:
  - governance_change: true   # Any governance file
  - agent_modification: true  # Modifying existing agents
  - breaking_change: true     # Changes to public interfaces
  - security_sensitive: true  # Secrets, auth, permissions
  - new_dependency: true      # Adding external dependencies
```

### How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│  1. You make changes in your instance                            │
│                    ↓                                             │
│  2. Run: /contribute submit                                      │
│                    ↓                                             │
│  3. System analyzes: safe or risky?                             │
│        │                    │                                    │
│        ↓                    ↓                                    │
│     SAFE               RISKY                                     │
│        │                    │                                    │
│        ↓                    ↓                                    │
│  Auto-approved      Forwarded to admin                          │
│  PR created         PR created + admin notified                 │
│                    ↓                                             │
│  4. Merged to upstream (plugin or ecosystem)                    │
│                    ↓                                             │
│  5. Your vector credited                                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Scriptable Instantiation

### Full Automation

```bash
#!/bin/bash
# create-instance.sh

PROJECT_NAME="$1"
GITHUB_USER="$2"
MODE="${3:-humanitic}"  # Default to humanitic

# Create project
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"
git init

# Add plugin
git submodule add https://github.com/cemphlvn/meta-agentic-loop.git plugin

# Initialize
./plugin/scripts/init-ecosystem.sh \
  --instance "$PROJECT_NAME" \
  --"$MODE" \
  --github-user "$GITHUB_USER" \
  --non-interactive

# Add humanitic if chosen
if [ "$MODE" = "humanitic" ]; then
  git submodule add https://github.com/cemphlvn/humanitic.git instances/humanitic
fi

# Initial commit
git add -A
git commit -m "Initialize $PROJECT_NAME with meta-agentic-loop"

echo "✓ Project created: $PROJECT_NAME"
echo "  Mode: $MODE"
echo "  Plugin: plugin/"
echo "  Next: cd $PROJECT_NAME && claude"
```

### Usage

```bash
# Humanitic mode (default)
./create-instance.sh my-project myusername

# Private mode
./create-instance.sh my-project myusername private
```

---

## License Clarification

```
┌─────────────────────────────────────────────────────────────────┐
│  meta-agentic-loop                                               │
│  ─────────────────                                               │
│  License: MIT (Unlicensed from Humanitic perspective)           │
│                                                                  │
│  You can:                                                        │
│  ✓ Use commercially                                              │
│  ✓ Modify freely                                                 │
│  ✓ Distribute                                                    │
│  ✓ Use privately                                                 │
│  ✓ Never contribute back                                         │
│                                                                  │
│  No obligations. The plugin is a gift.                          │
├─────────────────────────────────────────────────────────────────┤
│  humanitic (ecosystem)                                           │
│  ─────────                                                       │
│  License: Humanitic Open License v1.0                           │
│                                                                  │
│  If you JOIN (voluntary):                                        │
│  ✓ Use all ecosystem work freely                                │
│  ✓ Track your contributions via vectors                         │
│  ✓ Get credited when others build on your work                  │
│  ✓ Credit others when you build on theirs                       │
│                                                                  │
│  Joining is optional. Benefits flow both ways.                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Admin Configuration

As admin/owner of the ecosystem, configure auto-approval:

```yaml
# In your project's .github/contribution-policy.yaml
contribution_policy:
  admin_users:
    - cemkoc
    - your-other-admins

  auto_approve:
    enabled: true
    criteria:
      - path: "docs/**"
      - path: "*.md"
      - path: "tests/**"
        type: addition_only
      - label: "safe"

  require_review:
    - path: ".claude/governance/**"
    - path: ".claude/agents/**"
      except: "new files"
    - path: "scripts/**"
    - label: "risky"
    - label: "breaking"

  notify_admin:
    method: github_issue
    create_issue: true
    assign_to: admin_users
```

---

## Verification Checklist

After setup, verify:

```bash
# 1. Plugin is linked
ls plugin/.claude/CORE_LOOP.md

# 2. Config exists
cat ecosystem.config.yaml

# 3. Submodules are initialized
git submodule status

# 4. Claude Code recognizes it
# Start Claude and run:
# /loop  (should show the core loop)
# /help  (should show available commands)
```

---

## Troubleshooting

### Submodule not initialized

```bash
git submodule update --init --recursive
```

### Plugin files missing

```bash
cd plugin && git checkout main && cd ..
```

### Claude Code not recognizing .claude/

Ensure `.claude/` is in your project root or symlinked:
```bash
ln -s plugin/.claude .claude
```

---

## Next Steps

1. **Explore**: Read `plugin/.claude/CORE_LOOP.md`
2. **Configure**: Edit `ecosystem.config.yaml` for your project
3. **Create Agents**: Add to `.claude/agents/` for your domain
4. **Contribute**: Run `/contribute` to give back

---

*The loop continues through you.*
