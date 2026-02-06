---
name: Cockpit
description: Main command interface - shows available commands and system status
trigger: Session start, /cockpit, /help, /status
commands: [/cockpit, /help, /status, /commands]
priority: 100
autoload: true
---

# Cockpit

> Your command center for Logicsticks.ai

## System Status

```
┌─────────────────────────────────────────────────────────────┐
│                      COCKPIT STATUS                          │
├─────────────────────────────────────────────────────────────┤
│  Sprint: {CURRENT_SPRINT}                                    │
│  Goal: {SPRINT_GOAL}                                         │
│  Work State: {WORK_ALPHA_STATE}                              │
│  Way of Working: {WOW_STATE}                                 │
└─────────────────────────────────────────────────────────────┘
```

## Available Commands

### Strategic (Business Owner level)
| Command | Description |
|---------|-------------|
| `/strategy` | Invoke business_strategy for direction |
| `/strategy review` | Review current strategic alignment |
| `/roadmap` | View/update product roadmap |

### Orchestration (System level)
| Command | Description |
|---------|-------------|
| `/orchestrate` | Full orchestration cycle |
| `/scrum` | Display current scrum state |
| `/alpha {name}` | Show specific alpha state |
| `/sprint` | Current sprint status |

### Processes (Workflow level)
| Command | Description |
|---------|-------------|
| `/process feature {desc}` | Feature implementation workflow |
| `/process bugfix {desc}` | Bug investigation and fix |
| `/process refactor {desc}` | Safe refactoring workflow |
| `/process research {topic}` | Deep research workflow |

### Feedback (Quality level)
| Command | Description |
|---------|-------------|
| `/feedback` | Run feedback loop |
| `/feedback complexity` | Complexity analysis only |
| `/feedback structure` | Structure analysis only |
| `/test` | Run test suite |

### Brand (CogStra level)
| Command | Description |
|---------|-------------|
| `/brand create {name}` | Create new brand |
| `/brand analyze` | Gap analysis |
| `/voice` | Show voice parameters |
| `/research ontological` | What IS the brand? |
| `/research epistemological` | How do we KNOW? |

### Documentation (Knowledge level)
| Command | Description |
|---------|-------------|
| `/docs` | Browse documentation |
| `/librarian {query}` | Query librarian for docs |
| `/remember` | View .remembrance |
| `/shift` | Trigger SHIFT_FELT |

### System (Meta level)
| Command | Description |
|---------|-------------|
| `/cockpit` | Show this command center |
| `/help` | Show help |
| `/status` | System status |
| `/config` | View configuration |

## Quick Actions

Based on current state, recommended actions:

```
[Analyze current sprint and alpha states]
[Suggest most impactful next command]
```

## Context Loaded

On session start, these are pre-loaded:
- `/scrum/SCRUM.md` - Alpha states, current sprint
- `/processes/INDEX.md` - Available processes
- `/.remembrance` - Recent wisdom (last 3 entries)

## Agent Tiers

```
STRATEGIC    opus     business-strategy, cto-agent
TACTICAL     sonnet   librarian, researchers, brand-builder
OPERATIONAL  sonnet   implementer, reviewer, simplifier, strategist
```

## Navigation

- `/scrum/SCRUM.md` → Essence-based scrum hub
- `/processes/` → Process definitions
- `/.claude/agents/` → Agent definitions
- `/.claude/skills/` → Skill definitions
- `/docs/` → Documentation

---

*Type a command or describe what you want to do.*
