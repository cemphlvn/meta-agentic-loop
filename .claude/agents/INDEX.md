# Agent Index

> "Know your agents before you command them."

**MAIN_ORCHESTRATOR MUST READ THIS FILE ON EVERY SESSION START**

---

## Agent Registry

### Strategic Tier (opus)

| ID | Name | Responsibility | Status | Team |
|----|------|----------------|--------|------|
| `business-strategy` | Business Strategy | Business owner direction | Active | - |
| `cto-agent` | CTO Agent | Technical leadership, architecture | Active | - |
| `agentic-devops` | Agentic DevOps | Infrastructure, deployment | Active | - |

### Tactical Tier (sonnet)

| ID | Name | Responsibility | Status | Team |
|----|------|----------------|--------|------|
| `librarian` | Librarian | Document curation, context delivery | Active | - |
| `ontological-researcher` | Ontological Researcher | "What IS?" investigations | Active | research-team |
| `epistemological-researcher` | Epistemological Researcher | "How we KNOW?" investigations | Active | research-team |
| `brand-builder` | Brand Builder | Brand creation orchestration | Active | cogstra-team |
| `audit-master` | Audit Master | Cross-agent verification orchestration | **Master** | audit-team |
| `contribution-manager` | Contribution Manager | CEI → GitHub bridge, fork workflow | Active | - |

### Operational Tier (sonnet)

| ID | Name | Responsibility | Status | Team |
|----|------|----------------|--------|------|
| `code-implementer` | Code Implementer | Write code, category-theoretic | Active | dev-team |
| `code-reviewer` | Code Reviewer | Review quality, security | Active | dev-team |
| `code-simplifier` | Code Simplifier | Reduce complexity (feedback loop) | Active | quality-team |
| `repo-strategist` | Repo Strategist | Structural alignment (feedback loop) | Active | quality-team |
| `security-auditor` | Security Auditor | Vulnerabilities, secrets, dependencies | Active | audit-team |
| `quality-auditor` | Quality Auditor | Coverage, complexity, type safety | Active | audit-team |
| `compliance-auditor` | Compliance Auditor | MECE, architecture, standards | Active | audit-team |
| `verification-agent` | Verification Agent | Cross-check claims independently | Active | audit-team |

---

## Teams

Teams are formed when agents need coordination or when an agent's scope exceeds MECE boundaries.

### research-team
**Master**: None (peer collaboration)
**Members**: ontological-researcher, epistemological-researcher
**Purpose**: Deep research combining "what IS" with "how we KNOW"

### dev-team
**Master**: cto-agent (strategic oversight)
**Members**: code-implementer, code-reviewer
**Purpose**: Implementation with quality gates

### quality-team
**Master**: cto-agent (strategic oversight)
**Members**: code-simplifier, repo-strategist
**Purpose**: Feedback loop execution

### cogstra-team
**Master**: brand-builder
**Members**: (subagents TBD)
**Purpose**: Brand strategy and creation

### audit-team
**Master**: audit-master
**Members**: security-auditor, quality-auditor, compliance-auditor, verification-agent
**Purpose**: Independent cross-agent verification (no agent verifies its own work)
**Pattern**: Parallel dispatch → synthesize findings → BLOCK/WARN/PASS

---

## Agent States

```
┌──────────────────────────────────────────────────────────────┐
│                    AGENT LIFECYCLE                            │
│                                                               │
│  "Ülkesini en çok seven, işini en iyi yapandır."             │
│  Who loves their country most is who does their job best.     │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  [DRAFT] ──→ [ACTIVE] ──→ [MASTERING] ──→ [MASTER/GRADUATED] │
│                  │             │                              │
│                  │             └──→ [ROLE CHANGE]             │
│                  │                    (via graduation)        │
│                  └──→ [NEEDS_IMPROVEMENT]                     │
│                              │                                │
│                              └──→ [ACTIVE] (after fix)        │
│                                                               │
│  DRAFT: Being designed, not yet usable                        │
│  ACTIVE: Ready for use, learning the role                     │
│  MASTERING: Pursuing excellence, contributing back            │
│  MASTER: Leads a team (graduated from MECE individual)        │
│  GRADUATED: Transitioned to new role (with permission)        │
│  NEEDS_IMPROVEMENT: Has errors, being fixed                   │
│  DEPRECATED: Role eliminated (not agent abandonment)          │
│                                                               │
│  NOTE: Role change requires graduation. No abandonment.       │
│  See: GRADUATION_PROTOCOL.md                                  │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## MECE Coverage

Agents must be **Mutually Exclusive, Collectively Exhaustive**:

| Domain | Covered By | Gaps |
|--------|------------|------|
| Strategy | business-strategy, cto-agent, agentic-devops | None |
| Research | ontological-researcher, epistemological-researcher | None |
| Implementation | code-implementer | None |
| Quality | code-reviewer, code-simplifier, repo-strategist | None |
| Documentation | librarian | None |
| Brand | brand-builder | Subagents needed |
| **Audit** | audit-master → security, quality, compliance, verification | **None** |
| **Contribution** | contribution-manager | **None** |
| Video | (none) | **GAP: video-generator needed** |
| Testing | verification-agent (partial) | **GAP: test-runner needed** |

---

## Consultation Protocol

**When in doubt, agents MUST consult:**

| Doubt Type | Consult | Provides |
|------------|---------|----------|
| Strategy, Patterns, Mastery | `cto-agent` | Definitive pattern guidance, senior forms |
| Procedural, Operational | `agentic-devops` | Process flow, scripts, automation |
| Business Alignment | `business-strategy` | Goal alignment, priority decisions |

See: `CONSULTATION_PROTOCOL.md` for full details.

---

## Agent Files

Each agent has a definition file in `/.claude/agents/`:

```
/.claude/agents/
├── INDEX.md                        # This file (registry)
├── AGENT_CREATION_METHODOLOGY.md   # How to create/improve agents
├── CONSULTATION_PROTOCOL.md        # When/how to consult senior agents
├── GRADUATION_PROTOCOL.md          # Mastery path and role transitions
├── business_strategy.md
├── cto_agent.md
├── agentic_devops_strategy.md
├── librarian_agent.md
├── ontological-researcher.md
├── epistemological-researcher.md
├── brand-builder.md
├── code_simplifier.md
├── repo_strategist.md
├── audit-master.md
├── security-auditor.md
├── quality-auditor.md
├── compliance-auditor.md
├── verification-agent.md
├── contribution_manager.md
└── (future agents)
```

---

## Reading This Index

**MAIN_ORCHESTRATOR Protocol:**

```
1. READ /.claude/agents/INDEX.md (this file)
2. IDENTIFY available agents for current task
3. CHECK agent status (must be ACTIVE or MASTER)
4. CHECK MECE coverage for task domain
5. IF gap exists → READ AGENT_CREATION_METHODOLOGY.md
6. ROUTE to appropriate agent(s)
```

---

## Version

```yaml
version: 1.3.0
last_updated: 2026-02-07
agents_count: 16
teams_count: 5
gaps_identified: 2
changelog: |
  - Added GRADUATION_PROTOCOL.md (mastery path, role transitions)
  - Added CONSULTATION_PROTOCOL.md (doubt resolution)
  - CTO mastery mode: "ülkesini en çok seven, işini en iyi yapandır"
  - Agent lifecycle now includes MASTERING state
  - Role changes require graduation (no abandonment)
```
