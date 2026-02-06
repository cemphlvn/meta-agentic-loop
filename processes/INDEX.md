# Process Definitions

> "A process is a repeatable path from intent to outcome."

## Process Types

| Type | Description | Agents Flow |
|------|-------------|-------------|
| `sequential` | Steps execute in order, each waits for previous | A → B → C |
| `parallel` | Independent steps execute concurrently | A ∥ B ∥ C |
| `conditional` | Branch based on previous step output | A → (B \| C) |
| `iterative` | Repeat until condition met | A → B → [check] → A... |
| `saga` | Long-running with compensation on failure | A → B → C (rollback: C' → B' → A') |

## Available Processes

### Development
- `feature` - Full feature implementation
- `bugfix` - Bug investigation and fix
- `refactor` - Safe refactoring with review
- `research` - Deep research workflow

### Operations
- `deploy` - Deployment pipeline
- `release` - Release workflow
- `feedback` - Feedback loop execution

### Strategic
- `strategy-review` - Business strategy alignment
- `architecture-decision` - ADR creation process

## Process Definition Format

```yaml
# processes/{name}.md
---
name: Process Name
type: sequential | parallel | conditional | iterative | saga
trigger: When this process activates
agents: [agent1, agent2, ...]
timeout: 30m
rollback: true | false
---

# Process: {Name}

## Steps

### Step 1: {Name}
Agent: {agent-id}
Input: {what it receives}
Output: {what it produces}
On-Failure: {continue | abort | compensate}

### Step 2: ...
```

## Integration

Processes are invoked via:
```bash
/process {name} {args}
# or
/orchestrate {process-type} {description}
```

→ See: `/.claude/skills/MAIN_ORCHESTRATOR.md`
