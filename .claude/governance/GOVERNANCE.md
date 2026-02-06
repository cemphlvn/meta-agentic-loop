# Governance System

> "Agents obey. Users govern. The distinction is immutable."

## Overview

This governance system establishes **user-only** configuration files that agents **cannot modify**. These files define the meta-principles, policies, and ethical boundaries within which all agents operate.

## Locked Files (Agent-Immutable)

```
/.claude/governance/
├── GOVERNANCE.md              ← This file (locked)
├── meta-principles.md         ← User's philosophical foundations (locked)
├── policies.md                ← Operational constraints (locked)
├── curiosity-of-curiosity.md  ← Meta-cognitive principles (locked)
└── ethics.md                  ← Ethical boundaries (locked)
```

## Enforcement Mechanism

### 1. Hook-Based Blocking

```json
{
  "PreToolUse": [{
    "matcher": "Write|Edit|MultiEdit",
    "hooks": [{
      "type": "command",
      "command": "python3 ${PROJECT_ROOT}/scripts/hooks/governance-lock.py"
    }]
  }]
}
```

### 2. Permission Deny Rules

```json
{
  "permissions": {
    "deny": [
      "Edit(.claude/governance/*)",
      "Write(.claude/governance/*)"
    ]
  }
}
```

### 3. Fail-Closed Design

If enforcement hook fails → operation blocked (not allowed).

## Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                     GOVERNANCE HIERARCHY                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  meta-principles.md                                       │   │
│  │  "Why we exist. What we value. Non-negotiable."          │   │
│  │  USER-ONLY. IMMUTABLE BY AGENTS.                         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  curiosity-of-curiosity.md                                │   │
│  │  "How we think about thinking. Meta-cognition."          │   │
│  │  USER-ONLY. IMMUTABLE BY AGENTS.                         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  policies.md                                              │   │
│  │  "Operational rules. What agents must/must not do."      │   │
│  │  USER-ONLY. IMMUTABLE BY AGENTS.                         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  ethics.md                                                │   │
│  │  "Ethical boundaries. Lines that cannot be crossed."     │   │
│  │  USER-ONLY. IMMUTABLE BY AGENTS.                         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  CLAUDE.md, agents/, skills/                             │   │
│  │  "Operational configuration. Agent-modifiable."          │   │
│  │  Agents CAN modify (within policy bounds).               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Modification Protocol

### For Users (Allowed)

```bash
# Edit directly
vim .claude/governance/meta-principles.md

# Or use governance command
/governance edit meta-principles
```

### For Agents (BLOCKED)

```
Agent: "I need to update the policies..."
System: ❌ BLOCKED: Governance files are user-only.
        Use /governance request to propose changes to user.
```

### Proposing Changes (Agents)

Agents can **propose** changes but cannot **execute** them:

```yaml
/governance request:
  file: policies.md
  proposal: |
    Add rule: "All API calls must be logged"
  rationale: |
    Improves auditability...

# Creates: .claude/governance/proposals/PROP-{timestamp}.md
# User reviews and manually applies if approved
```

## Versioning

All governance files are versioned:

```yaml
version: 1.0.0
last_modified: 2026-02-06T20:00:00Z
modified_by: user  # Always "user", never agent
hash: sha256:...
```

## Audit Trail

All access attempts logged to `.claude/governance/.audit-log`:

```
2026-02-06T20:00:00Z | READ  | meta-principles.md | orchestrator | ALLOWED
2026-02-06T20:01:00Z | WRITE | policies.md        | code-impl    | BLOCKED
2026-02-06T20:02:00Z | EDIT  | ethics.md          | audit-master | BLOCKED
```

## Sources

- [Claude Code Security Docs](https://code.claude.com/docs/en/security)
- [Claude Code Permissions](https://code.claude.com/docs/en/permissions)
- [Anthropic Trust Center](https://trust.anthropic.com)
- [Building Safeguards for Claude](https://www.anthropic.com/news/building-safeguards-for-claude)
