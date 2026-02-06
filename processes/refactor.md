---
name: Safe Refactor
type: sequential
trigger: /process refactor OR /orchestrate refactor
agents: [librarian, cto-agent, code-reviewer, code-implementer, code-simplifier, repo-strategist]
timeout: 2h
rollback: true
feedback_loop: true
---

# Process: Safe Refactor

> Refactoring with architectural oversight and safety nets.

## Flow

```
librarian → cto-agent → code-reviewer(pre) → code-implementer → code-reviewer(post)
                                                                        ↓
                                              [feedback: code-simplifier + repo-strategist]
```

## Steps

### Step 1: Context & Impact
**Agent**: `librarian`
**Input**: Refactor description
**Output**: Affected files, dependencies, risks
**Depth**: deep

```markdown
@librarian
task: "Refactor: {description}"
depth: deep
alphas: [SoftwareSystem, WayOfWorking]
```

### Step 2: Architectural Approval
**Agent**: `cto-agent`
**Input**: Refactor scope, impact analysis
**Output**: Approval/rejection with constraints

```markdown
@cto-agent
decision: "Approve refactor: {description}"
impact: {librarian_output}
questions:
  - Does this align with architecture?
  - What are the risks?
  - What constraints apply?
```

### Step 3: Pre-Refactor Review
**Agent**: `code-reviewer`
**Input**: Current code state
**Output**: Baseline snapshot, test coverage

```markdown
@code-reviewer
task: "Pre-refactor baseline"
capture:
  - Current test coverage
  - Public API surface
  - Performance benchmarks
```

### Step 4: Implementation
**Agent**: `code-implementer`
**Input**: Approved refactor plan, constraints
**Output**: Refactored code

```markdown
@code-implementer
task: "Execute refactor: {description}"
constraints: {cto_constraints}
rules:
  - No behavior changes
  - All tests must pass
  - Incremental commits
```

### Step 5: Post-Refactor Review
**Agent**: `code-reviewer`
**Input**: Refactored code, baseline snapshot
**Output**: Comparison report, approval

```markdown
@code-reviewer
task: "Post-refactor review"
compare:
  - Test coverage (must not decrease)
  - Public API (must not change)
  - Performance (must not regress)
```

### Step 6: Feedback Loop
**Agents**: `code-simplifier`, `repo-strategist`
**Input**: Final refactored code
**Output**: Complexity and structure reports

```markdown
/feedback full
```

## Rollback Plan

If any step fails:
```yaml
rollback:
  - git revert to pre-refactor commit
  - Notify CTO of failure reason
  - Log to .remembrance for learning
```

## Success Criteria

- [ ] CTO approved
- [ ] All tests passing
- [ ] No behavior changes
- [ ] Complexity reduced (or justified)
- [ ] Structure improved
