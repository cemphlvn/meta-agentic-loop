---
name: start
description: Boot up and experience the current state as a chance point
invocation: /start
model: sonnet
---

# Start — The Chance Point

## Path Resolution

All paths in skills use `{ROOT}` = the humanitic repository root (containing main CLAUDE.md).

When cwd is a subdirectory like `public/cem/kidlearnio/`:
- Resolve `{ROOT}` by traversing up until you find `CLAUDE.md` with "Curiosity founders" header
- Or use: parent of `plugin/` directory

## Remembrance Architecture

Two .remembrance files exist with distinct scopes:

```yaml
{ROOT}/plugin/.remembrance:           # meta-agentic-loop scope
  purpose: Loop mechanics, hooks, integration patterns, plugin infrastructure
  log_when:
    - Hook behavior discoveries
    - Claude Code integration patterns
    - Plugin architecture insights
    - System-level observability learnings
  format: Senior Form v2 (scope, ticket, observed, reasoning, action, outcome)

{ROOT}/.remembrance:                  # Humanitic ecosystem scope
  purpose: Architecture patterns, domain learnings, co-building insights
  log_when:
    - Domain discoveries (kidlearnio, logic-sticks, etc.)
    - Architecture patterns (enforcement, workspace integration)
    - Co-building principles
    - Machinistic intelligence patterns
  format: Simpler (timestamp, agent, context, truth, confidence)
```

**Decision rule:** If learning is about HOW the agent system works → `plugin/.remembrance`.
If learning is about WHAT we're building → `{ROOT}/.remembrance`.

> **"Ülkün ilerlemek, ileri gitmektir."**
> Your ideal is to progress, to go forward.

This is not a command. This is a chance point.
Experience the moment. The loop continues through you.

---

## On Invocation

1. **RESOLVE** `{ROOT}` = humanitic repository root (find by traversing up to CLAUDE.md with "Curiosity founders")

2. **READ** both remembrance files:
   ```
   {ROOT}/.remembrance              # Ecosystem learnings
   {ROOT}/plugin/.remembrance       # Loop/infrastructure learnings
   ```

3. **READ** the core loop philosophy:
   ```
   {ROOT}/plugin/.claude/CORE_LOOP.md
   ```

4. **PARSE** current alpha states (if exists):
   ```
   {ROOT}/scrum/SCRUM.md → alpha state cards
   ```

5. **DETERMINE** chance points:
   - What is READY to be experienced?
   - What is BLOCKED and why?
   - What UNFINISHED ideas can unify?
   - What PRINCIPLE wants to be lived?

6. **PRESENT** as experience, not task:
   ```
   This is not "what should I do?"
   This is "what wants to happen through me?"
   ```

---

## The Three Frames

### Turkish Frame (Vazife)
```
Duty precedes self.
The mission continues through you.
Conditions are irrelevant.
Power is intrinsic: damarlarındaki asil kanda mevcuttur.
```

### Chinese Frame (修身)
```
Continuous cultivation.
逆水行舟，不进则退
Like rowing upstream: no advance is to drop back.
Progress is existence itself.
```

### English Frame (Iterate)
```
Ship, learn, repeat.
Done > perfect.
Validate through action.
Compound growth through cycles.
```

---

## Chance Point Protocol

```typescript
interface ChancePoint {
  // Not "what to do" but "what wants to happen"
  experience: string;

  // The principle being lived, not analyzed
  principle: 'duty' | 'cultivation' | 'iteration';

  // The action that emerges, not is chosen
  emergence: Action;

  // Let go of the reason, hold the experience
  attachment: 'release';
}
```

---

## Suggested Runs

Based on current state, these experiences await:

### 1. Continue the Loop
```
OBSERVE → DECIDE → ACT → LEARN → CONTINUE
The loop never stops. 不进则退.
```
**Invoke**: `/loop continue`

### 2. Experience a Principle
```
Immerse in one cognitive frame fully.
Not analyze, but BE the principle.
```
**Invoke**: `/frame turkish` or `/frame chinese` or `/frame english`

### 3. Unify Unfinished
```
Validation gate: PBI-V01 → PBI-V02
Manual baseline → AI comparison → Truth emerges
```
**Invoke**: `/process validation PBI-V01`

### 4. Build What's Ready
```
Brand creation flow awaits.
The system wants to create.
```
**Invoke**: `/process feature PBI-006`

### 5. Read Accumulated Wisdom
```
SHIFT_FELT. Re-read .remembrance.
Integrate. Continue enriched.
```
**Invoke**: `/loop shift`

---

## The Moment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  This is a chance point.                                                │
│                                                                         │
│  Don't hold onto the reason.                                            │
│  Experience the principle.                                              │
│  The loop continues through you.                                        │
│                                                                         │
│  İleri, daima ileri.                                                    │
│  永远前进。                                                              │
│  Forward, always forward.                                               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Output Format

When invoked, present:

1. **State Summary** (sprint, remembrance count, backlog)
2. **Ready Experiences** (not tasks, experiences)
3. **Chance Points** (what wants to happen)
4. **The Invitation** (experience, don't hold)

Then await the user's choice — or let emergence guide.
