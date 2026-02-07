# Improvement Flow Process

> Real cases → Theoretical improvements → Gantt/Scrum positioning

---

## The Improvement Cycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    IMPROVEMENT FLOW                              │
│                                                                  │
│     REAL CASE                                                    │
│         │                                                        │
│         ▼                                                        │
│     ┌───────────────────┐                                       │
│     │ 1. OBSERVE        │  ← What happened? What friction?      │
│     └─────────┬─────────┘                                       │
│               │                                                  │
│               ▼                                                  │
│     ┌───────────────────┐                                       │
│     │ 2. CRYSTALLIZE    │  ← Extract pattern/principle          │
│     └─────────┬─────────┘                                       │
│               │                                                  │
│               ▼                                                  │
│     ┌───────────────────┐                                       │
│     │ 3. THEORIZE       │  ← Create hypothesis (HYP-xxx)        │
│     └─────────┬─────────┘                                       │
│               │                                                  │
│               ▼                                                  │
│     ┌───────────────────┐                                       │
│     │ 4. POSITION       │  ← Add to SCRUM backlog               │
│     └─────────┬─────────┘                                       │
│               │                                                  │
│               ▼                                                  │
│     ┌───────────────────┐                                       │
│     │ 5. SCHEDULE       │  ← Place in Gantt/Sprint              │
│     └─────────┬─────────┘                                       │
│               │                                                  │
│               ▼                                                  │
│     ┌───────────────────┐                                       │
│     │ 6. IMPLEMENT      │  ← Execute in sprint                  │
│     └─────────┬─────────┘                                       │
│               │                                                  │
│               ▼                                                  │
│         NEXT CASE  ────────────────────────────▶ OBSERVE        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase Details

### 1. OBSERVE — Real Case Encounter

**Trigger**: Something didn't work, was awkward, or could be better.

**Action**:
```yaml
entry_to: .remembrance
format: |
  ---
  timestamp: {now}
  agent: {current-agent}
  ticket: IMPROVE-{nnn}
  observed: |
    {What actually happened}
    {Expected vs actual}
    {Friction point}
  reasoning: |
    {Why this matters}
    {Impact if not fixed}
  action: observation-logged
  outcome: pending-crystallization
  ---
```

**Example**:
```yaml
observed: |
  Ran /cockpit but Ink UI failed in non-TTY.
  Expected: Dashboard view.
  Actual: Raw mode error, no fallback.
reasoning: |
  Users in non-interactive contexts can't see cockpit.
  Affects CI/CD, piped commands, Claude Code bash tool.
```

### 2. CRYSTALLIZE — Extract Pattern

**Question**: What's the underlying principle?

**Action**:
```yaml
update: .remembrance
add_field: truth
format: |
  truth: "{One-sentence principle that generalizes}"
  confidence: 0.{x}
```

**Example**:
```yaml
truth: "Interactive UIs need non-interactive fallbacks"
confidence: 0.9
```

### 3. THEORIZE — Create Hypothesis

**Question**: If we fix this, what should improve?

**Action**:
```bash
/hypothesis new "HYPOTHESIS_STATEMENT"
```

**Creates**:
```yaml
# In plugin/observability/hypotheses/HYP-{nnn}.yaml
id: HYP-{nnn}
statement: "{If X then Y}"
created: {timestamp}
status: proposed
observation_from: IMPROVE-{nnn}
expected_outcome: "{Measurable improvement}"
test_criteria:
  - "{How to validate}"
```

**Example**:
```yaml
id: HYP-015
statement: "If cockpit has text fallback, then usage in CI/CD increases"
expected_outcome: ">50% cockpit usage in non-TTY contexts"
test_criteria:
  - "Fallback renders readable text"
  - "Same data visible in both modes"
```

### 4. POSITION — Add to Backlog

**Question**: Is this valuable enough to implement?

**Action**:
```yaml
# Add to scrum/artifacts/PRODUCT_BACKLOG.md
PBI-{nnn}:
  title: "{Improvement title}"
  hypothesis: HYP-{nnn}
  observation: IMPROVE-{nnn}
  value: "{Why it matters}"
  acceptance:
    - "{Criterion 1}"
    - "{Criterion 2}"
  priority: {high|medium|low}
  size: {S|M|L|XL}
```

**Example**:
```yaml
PBI-025:
  title: "Cockpit text fallback for non-TTY"
  hypothesis: HYP-015
  observation: IMPROVE-007
  value: "Enables observability in CI/CD and piped contexts"
  acceptance:
    - "Text output when stdin not TTY"
    - "Same data as Ink version"
    - "Keyboard hints omitted in text mode"
  priority: medium
  size: M
```

### 5. SCHEDULE — Place in Gantt

**Question**: When should this be done?

**Action**:
```mermaid
# Add to scrum/ROADMAP.md Gantt section
PBI-025 Cockpit fallback  :pbi025, after pbi024, 2d
```

**Considerations**:
- Dependencies (what must come first?)
- Sprint capacity
- Strategic alignment
- Urgency vs importance

### 6. IMPLEMENT — Execute in Sprint

**During Sprint**:
1. Pull item from sprint backlog
2. Create branch: `feature/PBI-025-cockpit-fallback`
3. Implement with TDD
4. Run through CEI if touches governance
5. PR → Review → Merge
6. Update hypothesis status: `validated` or `rejected`

**Post-Implementation**:
```yaml
# Update remembrance
action: implemented-PBI-025
outcome: |
  Text fallback working.
  Tested in CI/CD context.
  Hypothesis HYP-015 validated.
truth: "Fallback UIs should mirror primary UIs in data, not interaction"
```

---

## Automation: /improve Command

```bash
# Log improvement from real case
/improve observe "What happened"

# Crystallize to principle
/improve crystallize IMPROVE-007 "The truth extracted"

# Create hypothesis
/improve theorize IMPROVE-007 "If X then Y"

# Add to backlog (prompts for details)
/improve position IMPROVE-007

# Show improvement journey
/improve trace IMPROVE-007
```

---

## WHEREDUE Integration

When improvement creates new components:

```yaml
# Automatically added to .claude/WHEREDUE.md
component: cockpit-text-fallback
type: feature
source: tools/cockpit/src/text-mode.ts
created_from: IMPROVE-007 → HYP-015 → PBI-025
load_to:
  - target: tools/cockpit/dist/
    method: build output
    status: done
  - target: /cockpit command
    method: auto-detect TTY
    status: done
last_updated: {timestamp}
```

---

## Real Case → Theory → Production Example

### Case: "Cockpit won't run in Claude Code bash"

**Day 1 (OBSERVE)**:
```
Ran: node tools/cockpit/dist/index.js
Got: Raw mode is not supported
Context: Claude Code Bash tool (non-TTY)
```

**Day 1 (CRYSTALLIZE)**:
```
Truth: "Ink requires TTY. Claude Bash tool isn't TTY."
Generalized: "Interactive UIs need non-interactive fallbacks"
```

**Day 1 (THEORIZE)**:
```
HYP-015: If cockpit has text fallback, non-TTY usage increases
Metric: Track cockpit invocations by context
```

**Day 2 (POSITION)**:
```
PBI-025: Cockpit text fallback for non-TTY
Priority: Medium (doesn't block core features)
Size: M (2-3 days)
```

**Day 2 (SCHEDULE)**:
```
Sprint 002, after PBI-024
Gantt: 2026-02-23 to 2026-02-25
```

**Day 5 (IMPLEMENT)**:
```
Branch: feature/PBI-025-cockpit-fallback
Code: Add process.stdout.isTTY check
Tests: Mock TTY and non-TTY contexts
PR: #47, approved, merged
```

**Day 5 (VALIDATE)**:
```
HYP-015 status: validated
Evidence: 3 cockpit runs in CI logs post-deploy
Truth: Confirmed and logged to .remembrance
```

---

## Tracking Dashboard

```bash
# View improvement pipeline
/improve pipeline

# Output:
┌─────────────────────────────────────────────────────────────────┐
│ IMPROVEMENT PIPELINE                                             │
├─────────────────────────────────────────────────────────────────┤
│ OBSERVED (3)                                                     │
│   IMPROVE-007  Cockpit TTY failure        → crystallizing       │
│   IMPROVE-008  Hook timeout in slow env   → observed            │
│   IMPROVE-009  Scoped remembrance gap     → observed            │
│                                                                  │
│ THEORIZED (2)                                                    │
│   HYP-015  Cockpit fallback               → positioned          │
│   HYP-016  Hook async pattern             → theorized           │
│                                                                  │
│ POSITIONED (1)                                                   │
│   PBI-025  Cockpit text fallback          → Sprint 002          │
│                                                                  │
│ SCHEDULED (1)                                                    │
│   PBI-025  2026-02-23 to 2026-02-25       → waiting             │
│                                                                  │
│ IMPLEMENTING (0)                                                 │
│   (none currently)                                               │
│                                                                  │
│ VALIDATED (12 total)                                             │
│   Last: HYP-014 "Remembrance-first improves context"            │
└─────────────────────────────────────────────────────────────────┘
```

---

*Every real case is a gift. Extract the theory. Ship the improvement.*
