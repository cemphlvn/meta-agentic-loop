# Observability Module

> I → C → O: Dynamic truth evolution tracking and meta-observability

## Components

| Component | Purpose | Usage |
|-----------|---------|-------|
| truth-tracker.sh | Parse .remembrance, calculate metrics | `/observe` |
| dynamic-rounds.sh | Self-optimizing round-based reporting | Background daemon |
| utilization-tracker.sh | Agent/skill/process usage metrics | `/utilization` |
| hypothesis-tracker.sh | Hypothesis lifecycle management | `/hypothesis` |
| cockpit/dashboard.html | Visual HTML dashboard | `/cockpit html` |

## Module Structure

```
observability/
├── INDEX.md                    # This file
├── truth-tracker.sh            # Truth evolution
├── dynamic-rounds.sh           # Self-optimizing rounds
├── utilization-tracker.sh      # Usage metrics
├── hypothesis-tracker.sh       # Hypothesis lifecycle
├── cockpit/
│   └── dashboard.html          # Visual dashboard
├── hypotheses/
│   └── HYP-XXX.yaml           # Individual hypotheses
├── utilization/
│   └── YYYY-MM-DD.yaml        # Daily utilization logs
├── tests/
│   └── TEST-XXX.yaml          # Observable test definitions
├── reports/
│   └── REPORT-YYYY-MM-DD.yaml # Strategic reports
└── snapshots/
    └── YYYY-MM-DD.json        # Point-in-time metrics
```

## Quick Start

```bash
# Initialize rounds
bash observability/dynamic-rounds.sh init

# View dashboard
bash observability/truth-tracker.sh report

# Start daemon (background)
bash observability/dynamic-rounds.sh daemon 60 &

# Open cockpit
open observability/cockpit/index.html
```

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│  INPUTS (I)                                                  │
│  • .remembrance           → Accumulated truths               │
│  • scrum/EVOLUTION.md     → System timeline                  │
│  • .observability/rounds.json → Round state                  │
├─────────────────────────────────────────────────────────────┤
│  CLAUDE PROCESSING (C)                                       │
│  • truth-tracker.sh       → Parse, calculate, visualize      │
│  • dynamic-rounds.sh      → Round management, optimization   │
│  • cockpit/index.html     → Interactive visualization        │
├─────────────────────────────────────────────────────────────┤
│  OUTPUTS (O)                                                 │
│  • Visual dashboard (ASCII + HTML)                           │
│  • JSON metrics for integrations                             │
│  • Trend analysis from snapshots                             │
│  • Higher-order agent reports                                │
└─────────────────────────────────────────────────────────────┘
```

## Integration

```yaml
# In hooks.json SessionStart
{
  "type": "command",
  "command": "bash ${CLAUDE_PLUGIN_ROOT}/observability/truth-tracker.sh report",
  "timeout": 5,
  "description": "Show truth evolution dashboard"
}
```

## Metrics Tracked

- `total_truths` — Count of wisdom entries
- `shape_shifts` — Major paradigm changes
- `growth_rate_per_day` — Velocity of learning
- `by_agent` — Activity per agent
- `by_date` — Timeline distribution
- `current_round` — Dynamic round number
- `report_frequency` — Self-optimizing interval

## Design Principles

- **CII (Cognitive Interface Intelligence)**: Intent-driven, contextual, adaptive
- **Exo-Dept**: External observation layer, dark theme, minimal cognitive load
- **Self-Optimizing**: Round frequency adjusts based on velocity metrics

## System Scientist Layer

The System Scientist acts as a data-scientist for the agentic system:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SYSTEM SCIENTIST                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │ HYPOTHESIS   │→ │ UTILIZATION  │→ │ OBSERVABLE   │→ │ STRATEGIC    │    │
│  │ TRACKER      │  │ MONITOR      │  │ TESTS        │  │ REPORTS      │    │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘    │
│         ↓                ↓                  ↓                 ↓             │
│    hypotheses/      utilization/        tests/           reports/          │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Hypothesis Lifecycle

```
PROPOSED → TESTING → VALIDATED/REJECTED → IMPLEMENTED/ARCHIVED
    ↓          ↓            ↓                     ↓
hypotheses/  observable   strategic          .remembrance
pending/     tests run    review             (truth logged)
```

### Strategic Agent Integration

```yaml
business-strategy receives:
  - Strategic reports (daily)
  - ROI-impacting findings
  - Resource recommendations

cto-agent receives:
  - Technical hypothesis results
  - Utilization anomalies
  - Agent performance metrics
```

## Current State

| Metric | Value | Status |
|--------|-------|--------|
| Total Truths | 27 | growing |
| Shape Shifts | 3 | learning |
| Hypotheses Testing | 1 | HYP-001 |
| Utilization Rate | 85% | healthy |

### First System Hypothesis (HYP-001)

> "Agent invocation frequency correlates with truth contribution rate"

- **Expected**: correlation > 0.8
- **Observed Day 1**: 1.0 (perfect correlation)
- **Implication**: Dispatch more subagents → faster system learning

---

*Observation enables improvement. Hypotheses drive progress. The scientist never stops observing.*
