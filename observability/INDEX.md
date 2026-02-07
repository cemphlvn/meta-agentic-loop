# Observability Module

> I → C → O: Dynamic truth evolution tracking and meta-observability

## Components

| Component | Purpose | Usage |
|-----------|---------|-------|
| truth-tracker.sh | Parse .remembrance, calculate metrics, generate reports | `bash truth-tracker.sh {report\|json\|snapshot\|trends\|full\|watch}` |
| dynamic-rounds.sh | Self-optimizing round-based reporting | `bash dynamic-rounds.sh {init\|tick\|report\|daemon\|status}` |
| cockpit/index.html | Interactive HTML dashboard | Open in browser |

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
