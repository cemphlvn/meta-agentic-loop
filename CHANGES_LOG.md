# Changes Log — Claude vs Meta Tracking

> Tracks causality: what changed where and why

## Change Categories

| Category | Scope | Examples |
|----------|-------|----------|
| `CLAUDE` | Project-specific | CLAUDE.md commands, project .remembrance |
| `META` | Reusable plugin | skills/, processes/, observability/ |
| `SYNC` | Both | Changes that propagate between layers |

---

## 2026-02-07 Changes

### CLAUDE Changes (Project Layer)

| Time | File | Change | Caused By |
|------|------|--------|-----------|
| 12:00 | CLAUDE.md | Added CONTINUATION PROTOCOL | shape_shift: remembrance-first |
| 14:00 | CLAUDE.md | Added Tracking commands | User request: Gantt/DUE |
| 15:00 | CLAUDE.md | Added /playground commands | Context7 Feb 2026 patterns |
| 16:00 | CLAUDE.md | Added /techniques, /maintenance | Advanced techniques skill |
| 16:30 | CLAUDE.md | Added /observe commands | Observability request |
| 17:00 | .remembrance | 23 truths accumulated | Session activity |

### META Changes (Plugin Layer)

| Time | File | Change | Caused By |
|------|------|--------|-----------|
| 15:00 | skills/playground/ | Created playground skill | Context7 patterns |
| 16:00 | skills/advanced-techniques/ | Created techniques index | User: always-loaded skill |
| 17:00 | observability/ | Created truth-tracker.sh | User: I→C→O tracking |
| 17:15 | observability/ | Created dynamic-rounds.sh | User: background reporting |
| 17:30 | observability/cockpit/ | Created HTML dashboard | User: exo-dept CII design |

### SYNC Events

| Time | From | To | What |
|------|------|----|------|
| 15:30 | plugin/ | meta-agentic-loop | Playground system (commit aa5fcd8) |
| 16:30 | plugin/ | meta-agentic-loop | Advanced techniques (commit b5489cf) |
| 17:00 | plugin/ | meta-agentic-loop | WHEREDUE integrations (commit 1aab3ab) |
| 17:45 | plugin/ | meta-agentic-loop | Observability module (commit fe25d75) |

---

## Causality Chains

### Chain 1: Shape Shift → CLAUDE.md Update

```
.remembrance entry:
  truth: "Always start with remembrance. Wisdom precedes action."
  shape_shift: true
       ↓
CLAUDE.md update:
  Added CONTINUATION PROTOCOL section
  on_session_start now reads .remembrance FIRST
       ↓
META update:
  hooks/scripts/session-start.sh loads .remembrance
```

### Chain 2: User Request → System Evolution

```
User: "How can I observe truth evolution?"
       ↓
Created: scripts/truth-tracker.sh
Created: .claude/skills/observe.md
       ↓
CLAUDE.md: Added /observe commands
       ↓
META: Synced to observability/ module
       ↓
.remembrance: Logged truth about observability
```

### Chain 3: Context7 → Skill Creation

```
Context7 query: Feb 2026 patterns
       ↓
Created: plugin/skills/playground/
Created: plugin/skills/advanced-techniques/
       ↓
hooks.json: Added SessionStart injections
       ↓
CLAUDE.md: Added /playground, /techniques
```

---

## Format for New Entries

```yaml
timestamp: ISO-8601
category: CLAUDE|META|SYNC
file: path/to/file
change: what was changed
caused_by: what triggered the change
causality_chain: optional reference to chain
```

---

## Metrics

| Metric | Claude Layer | Meta Layer |
|--------|--------------|------------|
| Files Changed Today | 8 | 12 |
| New Commands Added | 15+ | - |
| New Skills Created | - | 3 |
| Truths Logged | 23 | - |
| Syncs to Remote | - | 4 |
