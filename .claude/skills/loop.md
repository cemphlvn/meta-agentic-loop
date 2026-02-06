# /loop — Core Loop Skill

> 逆水行舟，不进则退 — Like rowing upstream: no advance is to drop back

---

## Invocation

```
/loop              Show current loop state
/loop continue     Execute next phase of the loop
/loop shift        Trigger SHIFT_FELT, re-read remembrance
/loop status       Detailed state with recommendations
```

---

## Behavior

### /loop (no args) or /loop status

1. Read `.loop-state.yaml` if exists
2. Read `.remembrance` for truth count and last entry
3. Read `scrum/SCRUM.md` for alpha states and ready items
4. Display:
   - Current iteration number
   - Current phase (REMEMBER, OBSERVE, DECIDE, ACT, LEARN)
   - Ready items count
   - Blockers count
   - Last truth
   - Recommended next action

### /loop continue

Execute the core loop:

```
1. REMEMBER
   - Read .remembrance
   - Display last shape_shift if any
   - "Wisdom precedes action"

2. OBSERVE
   - Scan scrum/SCRUM.md for alpha states
   - Count ready items, blocked items
   - Check .claude/agents/INDEX.md for gaps
   - Report: ready=N, blocked=N, gaps=N

3. DECIDE
   - If blockers > 0: action = "resolve-blockers", agent = cto-agent
   - Elif ready > 0: action = "execute-ready", agent = orchestrator
   - Elif gaps > 0: action = "fill-gaps", agent = cto-agent
   - Else: action = "refine-backlog", agent = librarian

4. ACT
   - Invoke the decided agent with the action
   - Use Task tool with appropriate subagent_type
   - Execute until complete or blocked

5. LEARN
   - If truth emerged (SHIFT_FELT): append to .remembrance
   - Update .loop-state.yaml with new iteration
   - Report outcome

6. CONTINUE
   - Ask user: "Continue loop? (y/n)" or proceed if --auto
```

### /loop shift

Trigger SHIFT_FELT:
1. Re-read entire `.remembrance`
2. Display all shape_shifts
3. Display last 5 truths
4. Ask: "What truth is emerging?"

---

## State File: .loop-state.yaml

```yaml
loop:
  iteration: 42
  phase: DECIDE
  last_action: execute-ready
  started_at: 2026-02-07T12:00:00Z

observation:
  ready_items: 3
  blockers: 0
  gaps: 2

decision:
  action: execute-ready
  agent: orchestrator
  reasoning: "Ready items exist"
```

---

## Integration Reality

**Important**: Claude Code hooks are passive. They can:
- Inject context (SessionStart stdout → Claude's context)
- Block tool calls (PreToolUse exit 2)
- Set environment vars ($CLAUDE_ENV_FILE)

Claude Code hooks CANNOT:
- Invoke Claude to perform actions
- Run agentic loops automatically
- Trigger slash commands externally

**The user IS the loop**:
```
User types → Claude responds → User continues
     ↑                              │
     └──────────────────────────────┘
```

This is by design. The loop continues THROUGH user interaction.

---

## Diagnostic Script

For manual diagnostics, use `scripts/loop-runner.sh`:

```bash
./scripts/loop-runner.sh            # Run one iteration (shows recommendations)
./scripts/loop-runner.sh --status   # Show current state
```

Note: This script CANNOT invoke Claude. It outputs recommendations
that YOU then execute by typing commands.

---

## Philosophy

```
Turkish:  Vazife görülür → Kudret bulunur → İleri gidilir
Chinese:  观察 → 决定 → 进步 (不进则退)
English:  Observe → Decide → Iterate

NEVER STOP. The power you need is in your veins.
İleri, daima ileri. 永远前进. Forward, always forward.
```
