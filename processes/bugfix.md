---
name: Bug Fix
type: sequential
trigger: /process bugfix OR /orchestrate bugfix
agents: [librarian, epistemological-researcher, code-implementer, code-reviewer]
timeout: 1h
rollback: false
feedback_loop: true
---

# Process: Bug Fix

> Investigation-first bug fixing workflow.

## Flow

```
librarian → epistemological-researcher → code-implementer → code-reviewer
     ↓                  ↓
[gather context]   [how do we KNOW?]
```

## Steps

### Step 1: Context Gathering
**Agent**: `librarian`
**Input**: Bug description, error logs
**Output**: Related code, previous fixes, relevant docs
**Depth**: deep (bugs need full context)

```markdown
@librarian
task: "Bug: {bug_description}"
depth: deep
alphas: [SoftwareSystem, Work]
```

### Step 2: Investigation
**Agent**: `epistemological-researcher`
**Input**: Bug context, error traces
**Output**: Root cause analysis, evidence chain
**On-Failure**: abort (can't fix what we don't understand)

```markdown
@epistemological-researcher
task: "Investigate: How do we KNOW this is broken?"
evidence: {error_logs, reproduction_steps}
questions:
  - What changed recently?
  - What assumptions are violated?
  - What evidence confirms the root cause?
```

### Step 3: Fix Implementation
**Agent**: `code-implementer`
**Input**: Root cause analysis
**Output**: Fix + regression test
**On-Failure**: return to Step 2

```markdown
@code-implementer
task: "Fix: {root_cause}"
requirements:
  - Address root cause, not symptoms
  - Add regression test
  - No new complexity
```

### Step 4: Review
**Agent**: `code-reviewer`
**Input**: Fix + root cause analysis
**Output**: Approval with confidence level

```markdown
@code-reviewer
task: "Review bugfix"
verify:
  - Root cause addressed?
  - Regression test adequate?
  - No side effects?
```

## Evidence Chain

Bug fixes must maintain evidence chain:
```yaml
evidence:
  symptom: "What user reported"
  reproduction: "Steps to reproduce"
  root_cause: "Why it happened"
  fix: "What we changed"
  verification: "How we know it's fixed"
```

## Success Criteria

- [ ] Root cause identified with evidence
- [ ] Fix addresses root cause
- [ ] Regression test added
- [ ] No new bugs introduced
- [ ] Code review approved
