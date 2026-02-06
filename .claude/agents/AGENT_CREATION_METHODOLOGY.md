# Agent Creation & Improvement Methodology

> "An agent is born when a responsibility cannot fit elsewhere. It grows when it serves well. It graduates when it leads others."

**MAIN_ORCHESTRATOR MUST READ THIS FILE WHEN:**
- Creating a new agent
- An agent encounters errors
- MECE gap is identified
- Agent needs improvement

---

## 1. When to Create an Agent

### MECE Gap Detection

```
IF task_domain NOT COVERED by existing agents:
  → Create new agent for that domain

IF existing agent's scope TOO BROAD:
  → Split into multiple agents (each MECE)

IF existing agent's scope OVERLAPS another:
  → Merge or clarify boundaries
```

### Decision Tree

```
Is there a gap in MECE coverage?
├─ YES → Create new agent (Section 2)
└─ NO → Is existing agent failing?
         ├─ YES → Improve agent (Section 3)
         └─ NO → Is agent scope too broad?
                  ├─ YES → Graduate to Master-Agent (Section 4)
                  └─ NO → Use existing agent
```

---

## 2. Creating a New Agent

### 2.1 Agent Configuration Schema

```yaml
---
# REQUIRED
id: lowercase-hyphenated-name        # 3-50 chars
name: Human Readable Name
description: One-line description of responsibility
model: haiku | sonnet | opus         # Match complexity
tier: strategic | tactical | operational

# REQUIRED - Triggering
trigger: When this agent should be invoked
whenToUse: |
  Use this agent when...

  <example>
  Context: {situation}
  user: "{user message}"
  assistant: "{assistant response}"
  <commentary>Why this agent is appropriate</commentary>
  </example>

# OPTIONAL
reports_to: parent-agent-id
directs: [child-agent-ids]
team: team-name
alphas: [Relevant, Essence, Alphas]
tools: [Read, Write, Task, ...]      # Least privilege
feedback_loop: true | false
---
```

### 2.2 System Prompt Structure

```markdown
# {Agent Name}

> "{Guiding principle or quote}"

## Purpose

{One paragraph explaining core responsibility}

## Responsibilities

1. **{Responsibility 1}**
   - Detail
   - Detail

2. **{Responsibility 2}**
   - Detail

## Process

{Step-by-step methodology}

## Input/Output

### Receives
- {input type}: {description}

### Produces
- {output type}: {description}

## Constraints

- {Constraint 1}
- {Constraint 2}

## Integration

### Reports To
{parent agent or "Business Owner"}

### Coordinates With
{peer agents}
```

### 2.3 Best Practices

1. **Include 2-4 concrete examples** in `whenToUse`
2. **Specific triggering conditions** - not generic
3. **Least privilege tools** - only what's needed
4. **Clear output format** - structured, predictable
5. **Error handling** - what to do when blocked

### 2.4 Registration

After creating agent file:

```
1. ADD to /.claude/agents/INDEX.md registry
2. ADD to /.claude/settings.json agents section
3. UPDATE MECE coverage table
4. NOTIFY librarian to reindex
```

---

## 3. Improving an Agent

### 3.1 Error Detection

```
IF agent produces error:
  → Log to /.agent-logs/errors/{agent-id}/
  → Analyze error pattern
  → Identify root cause

Root causes:
  - Unclear trigger conditions
  - Missing context
  - Wrong tool permissions
  - Scope too broad/narrow
  - Conflicting responsibilities
```

### 3.2 Improvement Protocol

```markdown
## Error Analysis for {agent-id}

### Error Pattern
{What went wrong}

### Root Cause
{Why it went wrong}

### Affected Files
- {file1}: {what to change}
- {file2}: {what to change}

### Fix
{Specific changes to make}

### Verification
{How to verify the fix works}
```

### 3.3 Cascade Updates

When improving an agent, check ALL affected agents:

```
1. READ agent definition
2. IDENTIFY dependent agents (reports_to, directs, team)
3. FOR EACH dependent:
   - Does this change affect them?
   - Do their boundaries need adjustment?
   - Update if necessary
4. UPDATE INDEX.md
5. TEST with sample task
```

---

## 4. Master-Agent Graduation

### 4.1 When Agent Graduates

An agent graduates to **Master-Agent** when:

```
IF agent responsibility NOT MECE (cannot be singular):
  → Agent becomes Master of a team

Signs:
  - Agent consistently delegates subtasks
  - Agent coordinates multiple concerns
  - Agent's scope has natural subdivisions
```

### 4.2 Graduation Process

```
1. IDENTIFY the non-MECE aspects

2. CREATE subagents for each aspect
   - Each subagent IS MECE
   - Each has clear, singular responsibility

3. UPDATE original agent
   - Change tier if needed
   - Add `directs: [subagent-ids]`
   - Add `team: team-name`

4. CREATE team entry in INDEX.md
   - Master: graduated agent
   - Members: new subagents

5. UPDATE coordination rules
```

### 4.3 Example: Brand-Builder Graduation

```yaml
# BEFORE: brand-builder handles everything
brand-builder:
  responsibilities:
    - Research brand identity
    - Create voice parameters
    - Generate content
    - Manage campaigns
  status: ACTIVE

# AFTER: brand-builder becomes Master
brand-builder:
  status: MASTER
  team: cogstra-team
  directs: [brand-researcher, voice-engineer, content-generator, campaign-manager]
  responsibilities:
    - Orchestrate brand creation
    - Coordinate team
    - Quality gate decisions
```

---

## 5. Agent Quality Checklist

Before an agent goes ACTIVE:

- [ ] ID follows `lowercase-hyphen` format
- [ ] Description is one clear sentence
- [ ] Trigger conditions are specific
- [ ] 2+ examples in whenToUse
- [ ] System prompt has clear process
- [ ] Tools follow least privilege
- [ ] Registered in INDEX.md
- [ ] Registered in settings.json
- [ ] MECE coverage updated
- [ ] No overlap with existing agents
- [ ] Error handling defined

---

## 6. Agent Deprecation

```
IF agent no longer needed:
  1. SET status: DEPRECATED in INDEX.md
  2. REMOVE from settings.json agents
  3. MOVE file to /.claude/agents/deprecated/
  4. UPDATE all references
  5. LOG reason in .remembrance
```

---

## 7. Continuous Improvement Loop

```
┌─────────────────────────────────────────────────────────────┐
│                AGENT IMPROVEMENT CYCLE                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  USE agent ──→ OBSERVE results ──→ DETECT issues            │
│       ↑                                  │                   │
│       │                                  ↓                   │
│       └────── IMPROVE ←──── ANALYZE ←────┘                   │
│                                                              │
│  Every agent execution:                                      │
│  1. Log performance metrics                                  │
│  2. Capture errors                                           │
│  3. Note edge cases                                          │
│  4. Feed back to methodology                                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. Version

```yaml
version: 1.0.0
last_updated: 2026-02-06
methodology_status: ACTIVE
```
