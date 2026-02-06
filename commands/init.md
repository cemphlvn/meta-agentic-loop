---
name: init
description: Initialize project with meta-agentic-loop framework
invocation: /init
arguments:
  - name: name
    description: Project name
    required: false
  - name: philosophy
    description: Default cognitive frame (turkish|chinese|english|unified)
    required: false
    default: unified
---

# Initialize Meta-Agentic Project

> Bootstrap a new project with the eternal forward loop

## On Invocation

When the user runs `/init [name] [--philosophy unified]`:

### 1. Create Directory Structure

```bash
# Core structure
mkdir -p .claude/agents
mkdir -p .claude/skills

# Scrum structure
mkdir -p scrum/roles
mkdir -p scrum/artifacts
mkdir -p scrum/ceremonies
mkdir -p scrum/sprints/SPRINT-001

# Process structure
mkdir -p processes

# Commands and hooks
mkdir -p commands
mkdir -p scripts/hooks
```

### 2. Create CLAUDE.md

Create the main cockpit file with:
- CONTINUATION PROTOCOL section
- COMMANDS section
- CRITICAL FILES section
- AGENT HIERARCHY section

Template variables:
- `{{PROJECT_NAME}}` — from argument or directory name
- `{{PHILOSOPHY}}` — unified|turkish|chinese|english
- `{{TIMESTAMP}}` — ISO-8601

### 3. Create .remembrance

Initialize with system truth:

```yaml
# Agent Remembrance — Scoped Memory System

> 逆水行舟，不进则退 — Like rowing upstream: no advance is to drop back

---
timestamp: {{TIMESTAMP}}
agent: system
scope: system
context: initialization
truth: The remembrance begins empty, wisdom accumulates through experience
reflection: Every agent starts without memory; learning is earned
confidence: 1.0
---
```

### 4. Create Scrum Structure

- `scrum/SCRUM.md` — Main hub with alpha state cards
- `scrum/roles/PRODUCT_OWNER.md`
- `scrum/roles/SCRUM_MASTER.md`
- `scrum/roles/DEVELOPERS.md`
- `scrum/artifacts/PRODUCT_BACKLOG.md`
- `scrum/artifacts/INCREMENT.md`
- `scrum/ceremonies/` — Planning, Review, Retro
- `scrum/sprints/SPRINT-001/GOAL.md`

### 5. Create Process Definitions

- `processes/INDEX.md` — Process types
- `processes/feature.md` — Feature workflow
- `processes/bugfix.md` — Bugfix workflow
- `processes/refactor.md` — Refactor workflow
- `processes/research.md` — Research workflow

### 6. Create Agent Index

- `.claude/agents/INDEX.md` — Empty registry for project to fill

### 7. Link Hooks

Copy or symlink hooks from plugin:
- `scripts/hooks/scoped-remembrance.js`
- `scripts/hooks/session-start.sh`
- `scripts/hooks/session-end.sh`

### 8. Create Start Command

- `commands/start` — Boot script with chance points

---

## Output

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  {{PROJECT_NAME}} initialized with meta-agentic-loop                       ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                            ║
║  Created:                                                                  ║
║    ✓ CLAUDE.md (cockpit)                                                   ║
║    ✓ .remembrance (scoped memory)                                          ║
║    ✓ scrum/ (essence-based)                                                ║
║    ✓ processes/ (workflows)                                                ║
║    ✓ commands/start (boot)                                                 ║
║    ✓ scripts/hooks/ (automation)                                           ║
║                                                                            ║
║  Next:                                                                     ║
║    1. Add domain-specific agents to .claude/agents/                        ║
║    2. Define backlog items in scrum/artifacts/PRODUCT_BACKLOG.md           ║
║    3. Run: /start or ./commands/start                                      ║
║                                                                            ║
║  İleri, daima ileri. 永远前进. Forward, always forward.                     ║
║                                                                            ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## Philosophy Options

| Flag | Frame | Archetype | Principle |
|------|-------|-----------|-----------|
| `--philosophy turkish` | Turkish | Guardian | Duty + Power Within |
| `--philosophy chinese` | Chinese | Sage | Continuous Cultivation |
| `--philosophy english` | English | Builder | Pragmatic Iteration |
| `--philosophy unified` | All three | Synthesized | Unified forward |
