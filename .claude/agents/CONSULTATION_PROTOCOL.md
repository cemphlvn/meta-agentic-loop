# Agent Consultation Protocol

> When in doubt, consult before acting.

---

## Consultation Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│  STRATEGY & MASTERY → CTO Agent                             │
│  "Is this the right approach? What's the senior form?"      │
├─────────────────────────────────────────────────────────────┤
│  PROCEDURAL & OPERATIONAL → DevOps Strategy Agent           │
│  "How should this be done? What's the process?"             │
├─────────────────────────────────────────────────────────────┤
│  BUSINESS ALIGNMENT → Business Strategy Agent               │
│  "Should this be done? Does it align with goals?"           │
└─────────────────────────────────────────────────────────────┘
```

---

## When to Consult CTO Agent

```yaml
consult_cto_when:
  - Unsure about pattern choice
  - Type evolution decision needed
  - Senior form unclear
  - Architecture impact possible
  - New dependency consideration
  - Breaking change potential
  - Logging format questions

cto_provides:
  - Definitive pattern guidance
  - Senior form determination
  - Architecture approval
  - Quality standards clarification
```

### CTO Consultation Format

```yaml
@cto-agent
type: consultation
ticket: <WORK-ITEM-ID>
question: |
  Specific question about approach
observed: |
  What I'm seeing that's causing doubt
options_considered:
  - option_a: description
  - option_b: description
preference: <which option I lean toward, if any>
```

---

## When to Consult DevOps Strategy Agent

```yaml
consult_devops_when:
  - Process flow unclear
  - Deployment question
  - Infrastructure decision
  - Script implementation
  - CI/CD configuration
  - Environment setup
  - Automation approach

devops_provides:
  - Procedural guidance
  - Script templates
  - Deployment patterns
  - Infrastructure decisions
  - Automation strategies
```

### DevOps Consultation Format

```yaml
@agentic-devops-strategy
type: consultation
ticket: <WORK-ITEM-ID>
question: |
  Specific procedural question
context: |
  What I'm trying to accomplish
constraints:
  - timing
  - resources
  - dependencies
```

---

## Consultation Flow

```
1. DOUBT DETECTED
   Agent notices uncertainty about approach or process

2. CLASSIFY DOUBT
   ├── Strategy/Mastery → CTO
   ├── Procedural/Operational → DevOps
   └── Business/Alignment → Business Strategy

3. FORMULATE QUESTION
   Include: ticket, observed, options, preference

4. AWAIT RESPONSE
   Do not proceed with uncertain action

5. INTEGRATE RESPONSE
   Apply guidance, log reasoning

6. CONTINUE WITH CLARITY
```

---

## Doubt Detection Triggers

```yaml
triggers:
  - "I'm not sure if..."
  - "This could be done two ways..."
  - "The pattern here is unclear..."
  - "This might affect..."
  - "The senior form for this is..."
  - "Should I use X or Y..."
  - "The process for this is..."
```

---

## Response Logging

After consultation, log the exchange:

```yaml
---
timestamp: ISO-8601
agent: <consulting-agent>
ticket: <WORK-ITEM-ID>
observed: |
  Doubt encountered: <what caused uncertainty>
reasoning: |
  Consulted <cto|devops> because: <why this was the right consultant>
  Received guidance: <summary of response>
  Applied to: <how guidance changed approach>
action: <what was done after consultation>
outcome: <result>
---
```

---

## Consultation vs Escalation

| Consultation | Escalation |
|--------------|------------|
| "Help me decide" | "I can't proceed" |
| Returns to agent | Transfers ownership |
| Clarifies approach | Blocks until resolved |
| Normal flow | Exception flow |

Most doubts are consultations, not escalations.

---

## Default Consultation Routing

| Agent | Primary Consultant | Secondary |
|-------|-------------------|-----------|
| code-implementer | CTO | DevOps |
| code-reviewer | CTO | - |
| code-simplifier | CTO | - |
| repo-strategist | CTO | DevOps |
| librarian | CTO | - |
| contribution-manager | DevOps | CTO |
| audit-master | CTO | Business Strategy |
| security-auditor | CTO | DevOps |

---

*Doubt is signal. Consultation is strength.*
