---
name: Deep Research
type: parallel-then-sequential
trigger: /process research OR /orchestrate research
agents: [librarian, ontological-researcher, epistemological-researcher]
timeout: 1h
rollback: false
output: docs/research/{topic}.md
---

# Process: Deep Research

> Parallel ontological + epistemological research, then synthesis.

## Flow

```
                    ┌─→ ontological-researcher ──┐
librarian ──────────┤                            ├──→ synthesis
                    └─→ epistemological-researcher┘
```

## Steps

### Step 1: Context Gathering
**Agent**: `librarian`
**Input**: Research topic
**Output**: Existing knowledge, gaps, related docs
**Depth**: deep

```markdown
@librarian
task: "Research: {topic}"
depth: deep
alphas: [Opportunity, Requirements]
```

### Step 2a: Ontological Research (parallel)
**Agent**: `ontological-researcher`
**Input**: Topic + existing knowledge
**Output**: "What IS {topic}?"

```markdown
@ontological-researcher
task: "What IS {topic}?"
questions:
  - What is its essence?
  - What are its necessary properties?
  - What distinguishes it from similar things?
  - What is its purpose/telos?
```

### Step 2b: Epistemological Research (parallel)
**Agent**: `epistemological-researcher`
**Input**: Topic + existing knowledge
**Output**: "How do we KNOW about {topic}?"

```markdown
@epistemological-researcher
task: "How do we KNOW about {topic}?"
questions:
  - What evidence supports our understanding?
  - What are our sources?
  - What assumptions are we making?
  - How certain can we be?
```

### Step 3: Synthesis
**Agent**: `librarian` (or main orchestrator)
**Input**: Both research outputs
**Output**: Unified research document

```markdown
# Research: {topic}

## Ontological Findings (What IS it?)
{ontological_output}

## Epistemological Findings (How do we KNOW?)
{epistemological_output}

## Synthesis
{combined insights}

## Confidence Level
{based on evidence quality}

## Open Questions
{remaining unknowns}
```

## Output Location

Research outputs are saved to:
```
docs/research/{topic-slug}.md
```

And indexed by librarian.

## Integration with .remembrance

Key insights trigger SHIFT_FELT:
```yaml
---
timestamp: {ISO}
trigger: SHIFT_FELT
context: research:{topic}
truth: {key insight}
confidence: {0-1}
---
```

## Success Criteria

- [ ] Ontological questions answered
- [ ] Epistemological evidence gathered
- [ ] Synthesis completed
- [ ] Document saved and indexed
- [ ] Key insights logged to .remembrance
