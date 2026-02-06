---
name: Feature Implementation
type: sequential
trigger: /process feature OR /orchestrate feature
agents: [librarian, ontological-researcher, code-implementer, code-reviewer, code-simplifier]
timeout: 2h
rollback: false
feedback_loop: true
---

# Process: Feature Implementation

> Full feature workflow from research to review.

## Flow

```
librarian → ontological-researcher → code-implementer → code-reviewer
                                                              ↓
                                            [feedback loop: code-simplifier]
```

## Steps

### Step 1: Context Gathering
**Agent**: `librarian`
**Input**: Feature description
**Output**: Relevant documents, alpha states, recommendations
**Depth**: standard
**On-Failure**: abort

```markdown
@librarian
task: "{feature_description}"
depth: standard
alphas: [Requirements, SoftwareSystem]
```

### Step 2: Research
**Agent**: `ontological-researcher`
**Input**: Librarian context + feature description
**Output**: Understanding of what needs to be built
**On-Failure**: abort

```markdown
@ontological-researcher
task: "Understand what {feature} IS"
context: {librarian_output}
```

### Step 3: Implementation
**Agent**: `code-implementer`
**Input**: Research findings + architectural constraints
**Output**: Working code
**On-Failure**: abort

```markdown
@code-implementer
task: "Implement {feature}"
constraints: {research_output}
patterns: category-theoretic, MECE
```

### Step 4: Review
**Agent**: `code-reviewer`
**Input**: Implementation + original requirements
**Output**: Review report, approval/rejection
**On-Failure**: return to Step 3

```markdown
@code-reviewer
task: "Review {feature} implementation"
criteria: [correctness, patterns, security, tests]
```

### Step 5: Feedback Loop
**Agent**: `code-simplifier`
**Input**: Final implementation
**Output**: Complexity report
**On-Failure**: continue (informational)

```markdown
/feedback
```

## Handoff Documents

Each step produces a handoff:
```yaml
handoff:
  from: {agent}
  to: {next_agent}
  task: {original_task}
  output: {step_output}
  recommendations: []
  blockers: []
```

## Success Criteria

- [ ] All steps completed
- [ ] Code review approved
- [ ] Tests passing
- [ ] Complexity acceptable
- [ ] Alpha states updated
