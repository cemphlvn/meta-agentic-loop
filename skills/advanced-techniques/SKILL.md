---
name: advanced-techniques
description: Auto-loaded index of meta-agentic patterns, Context7 queries, and sequential/parallel flow orchestration
invocation: /techniques
auto_load: true
---

# Advanced Techniques Index

> Always loaded. Always available. The meta-skill that enables all others.

## Auto-Load Manifest

This skill is loaded automatically at SessionStart via:
```json
{
  "SessionStart": [{
    "matcher": "*",
    "hooks": [{
      "type": "command",
      "command": "cat ${CLAUDE_PLUGIN_ROOT}/skills/advanced-techniques/SKILL.md"
    }]
  }]
}
```

---

## FLOW ORCHESTRATION PATTERNS

### Pattern 1: Sequential Workflow

```yaml
type: sequential
use_when: Steps depend on previous outputs
example: feature → research → implement → review

flow:
  step_1:
    agent: librarian
    action: gather context
    output: $CONTEXT
  step_2:
    agent: ontological-researcher
    action: extract essence
    input: $CONTEXT
    output: $ESSENCE
  step_3:
    agent: code-implementer
    action: write code
    input: $ESSENCE
    output: $CODE
  step_4:
    agent: code-reviewer
    action: review
    input: $CODE
    output: $FEEDBACK
```

**Command Pattern:**
```markdown
---
description: Sequential feature workflow
allowed-tools: Bash(*), Read, Write, Edit
---

**Step 1 - Context:** !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/gather-context.sh`
**Step 2 - Research:** Use ontological-researcher on context
**Step 3 - Implement:** Use code-implementer with research
**Step 4 - Review:** Use code-reviewer on implementation

Report: sequence complete, errors, next steps
```

### Pattern 2: Parallel Workflow

```yaml
type: parallel
use_when: Steps are independent
example: (ontological ∥ epistemological) → synthesis

flow:
  parallel_phase:
    - agent: ontological-researcher
      action: "What IS this?"
      output: $ONTO_RESULT
    - agent: epistemological-researcher
      action: "How do we KNOW?"
      output: $EPIST_RESULT
  synthesis_phase:
    agent: orchestrator
    action: synthesize
    input: [$ONTO_RESULT, $EPIST_RESULT]
    output: $SYNTHESIS
```

**Dispatch Pattern:**
```python
# Parallel agent dispatch
results = await asyncio.gather(
    invoke_agent("ontological-researcher", task),
    invoke_agent("epistemological-researcher", task),
)
synthesis = await invoke_agent("synthesizer", results)
```

### Pattern 3: Conditional Workflow

```yaml
type: conditional
use_when: Branch based on state

flow:
  check:
    condition: tests_passing?
    true_branch: → code-simplifier
    false_branch: → fix_tests → retry

decision_tree:
  if complexity_increased:
    invoke: code-simplifier
  elif structure_changed:
    invoke: repo-strategist
  elif tests_failing:
    invoke: fix_loop
  else:
    invoke: complete
```

### Pattern 4: Orchestration Workflow

```yaml
type: orchestration
use_when: Complex multi-step coordination
example: release workflow

phases:
  1_plan:
    description: Understand dependencies
    tools: [Read, Grep, Glob]
  2_prepare:
    description: Set up prerequisites
    tools: [Bash]
  3_execute:
    description: Run phases
    tools: [Bash, Write, Edit]
  4_monitor:
    description: Track progress
    tools: [Read]
  5_verify:
    description: Confirm success
    tools: [Bash, Read]
  6_report:
    description: Generate summary
    output: WorkflowExecutionReport
```

---

## CONTEXT7 QUERY PATTERNS

### Query Pattern 1: Library Discovery
```yaml
action: resolve-library-id
input:
  libraryName: "anthropic"
  query: "Claude Code hooks patterns 2026"
output: /anthropics/claude-code
```

### Query Pattern 2: Documentation Query
```yaml
action: query-docs
input:
  libraryId: "/anthropics/claude-code"
  query: "SessionStart hook context injection patterns"
output: code snippets + descriptions
```

### Query Pattern 3: Multi-Library Synthesis
```yaml
action: parallel-query
libraries:
  - /anthropics/claude-code
  - /anthropics/skills
  - /anthropics/anthropic-cookbook
query: "agent orchestration workflow patterns"
synthesis: merge results, deduplicate, rank by relevance
```

### Available Libraries (Indexed)

| Library ID | Snippets | Score | Use For |
|------------|----------|-------|---------|
| /anthropics/claude-code | 780 | 71 | Hooks, plugins, skills |
| /anthropics/skills | 886 | 69.7 | Skill creation patterns |
| /anthropics/anthropic-cookbook | 1226 | 85.6 | API patterns, tools |
| /websites/platform_claude | 5916 | 87.3 | Official docs |
| /anthropics/courses | 2196 | 89.9 | Learning patterns |

---

## META-AGENTIC-LOOP INDEX

### Plugin Components

```yaml
location: github.com/cemphlvn/meta-agentic-loop

core:
  - CORE_LOOP.md          # Philosophy: OBSERVE → DECIDE → ACT → LEARN
  - .remembrance          # Scoped memory system
  - ecosystem.config.yaml # Plugin configuration

hooks:
  - SessionStart: Load context + remembrance
  - Stop: Persist learnings
  - PreToolUse: Verify agent scope

skills:
  - core-loop           # Loop continuation
  - scoped-remembrance  # Memory management
  - playground          # Observability dashboard
  - advanced-techniques # THIS SKILL

agents:
  - orchestrator        # MECE routing
  - librarian           # Document curation
  - code-simplifier     # Complexity reduction
  - repo-strategist     # Structure alignment

processes:
  - feature.md          # librarian → research → implement → review
  - bugfix.md           # investigate → fix → verify
  - refactor.md         # cto-approve → review → implement → review
  - research.md         # (onto ∥ epist) → synthesis
```

### Key Files to Consult

```yaml
for_workflow_design:
  - processes/INDEX.md
  - skills/skill-creator/references/workflows.md

for_agent_creation:
  - .claude/agents/AGENT_CREATION_METHODOLOGY.md
  - .claude/agents/INDEX.md

for_context7_patterns:
  - skills/playground/references/context7-2026-patterns.md

for_observability:
  - .maintenance/MAINTENANCE_LOG.md
  - scrum/EVOLUTION.md
  - scrum/ROADMAP.md
```

---

## AGENT DISPATCH RULES

### Routing Decision Tree

```
INPUT: task description
│
├─ Is it about WHAT something IS?
│  └─ → ontological-researcher
│
├─ Is it about HOW we KNOW?
│  └─ → epistemological-researcher
│
├─ Is it about WRITING code?
│  └─ → code-implementer
│
├─ Is it about REVIEWING code?
│  └─ → code-reviewer
│
├─ Is it about FINDING documents?
│  └─ → librarian
│
├─ Is it about REDUCING complexity?
│  └─ → code-simplifier
│
├─ Is it about STRUCTURE alignment?
│  └─ → repo-strategist
│
├─ Is it STRATEGIC?
│  └─ → business-strategy → cto-agent
│
└─ UNKNOWN → orchestrator (will route)
```

### Tool Constraints by Agent

| Agent | Read | Write | Edit | Bash | Task |
|-------|------|-------|------|------|------|
| librarian | ✓ | - | - | - | - |
| researcher | ✓ | - | - | - | - |
| code-reviewer | ✓ | - | - | - | - |
| code-implementer | ✓ | ✓ | ✓ | ✓ | - |
| code-simplifier | ✓ | ✓ | ✓ | - | - |
| orchestrator | ✓ | - | - | - | ✓ |

---

## TEACHING PROTOCOL (Master → Youngsters)

### When Agent Completes Task

```yaml
1. Log to .remembrance:
   - observed: what was noticed
   - reasoning: why action taken
   - action: what was done
   - outcome: result
   - truth: crystallized insight (optional)

2. Check for SHIFT_FELT:
   - Context switch detected?
   - Contradiction found?
   - Deep recursion occurred?
   → If yes: re-read .remembrance

3. Propagate learning:
   - Tactical agents: log to operational
   - Strategic agents: brief CEO
```

### Error Recovery Protocol

```yaml
on_error:
  1. Log error to .remembrance
  2. Read AGENT_CREATION_METHODOLOGY.md
  3. Identify scope issue
  4. Either:
     - Fix agent definition
     - Split into subagents
     - Graduate to Master-Agent
  5. Update INDEX.md
  6. Retry with corrected agent
```

---

## COMMANDS

```
/techniques              Show this index
/techniques flow         Show flow patterns
/techniques context7     Show Context7 query patterns
/techniques agents       Show agent dispatch rules
/techniques teach        Show teaching protocol
```

---

*Always loaded. Updated: 2026-02-07. Source: Context7 + meta-agentic-loop*
