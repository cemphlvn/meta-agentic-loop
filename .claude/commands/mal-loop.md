---
description: Run the self-improving agent loop
allowed-tools: Bash(bash:*), Task
argument-hint: [observe|decide|learn|run]
---

# /mal-loop — Self-Improving Agent Loop

!`bash ${CLAUDE_PLUGIN_ROOT:-/Users/cem/humanitic/plugin}/observability/agent-trace/loop-integrate.sh $ARGUMENTS 2>&1 || echo "LOOP_ERROR"`

## After Output

Based on the output above:

1. **If DECIDE shows a Command**: Execute it using the Task tool with the specified agent
2. **If LEARN shows Improvement Proposals**: Present them for user approval
3. **If OBSERVE shows pending agents**: Wait for completion, then re-run `/mal-loop`

## Hierarchy Rules (MUST FOLLOW)

```
STRATEGIC (cto-agent, business-strategy)
    │ can spawn
    ▼
TACTICAL (librarian, ontological-researcher, epistemological-researcher)
    │ can spawn
    ▼
OPERATIONAL (code-implementer, code-reviewer, security-auditor)
```

- Strategic agents analyze, decide direction
- Tactical agents break down, coordinate
- Operational agents execute specific tasks

## Loop Modes

- `/mal-loop observe` — Scan todos, pending, failures
- `/mal-loop decide` — Determine next agent (hierarchical)
- `/mal-loop learn` — Analyze traces for patterns
- `/mal-loop run` — Full iteration (observe→decide→learn)

## The Cycle

```
/mal-loop observe → see work
/mal-loop decide  → get next command
[Execute command] → agent runs (traced)
/mal-loop learn   → analyze, improve
[repeat]
```
