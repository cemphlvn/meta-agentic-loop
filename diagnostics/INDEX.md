# Diagnostics — CTO-Level Repository Analysis

> Strategic scripts for repository health, structure, and data flow analysis.

## Purpose

These scripts provide **system-level visibility** for architectural decisions:
- Repository structure health
- Data source verification
- Script audit (duplicates, symlinks)
- Loop state tracking

## Available Diagnostics

| Script | Purpose | Invocation |
|--------|---------|------------|
| `repo-audit.sh` | Full repository health check | `bash plugin/diagnostics/repo-audit.sh` |
| `repo-audit.sh --json` | Machine-readable output | For CI/automation |
| `repo-audit.sh --files` | List all shell scripts | Duplicate detection |
| `repo-audit.sh --duplicates` | Find duplicate scripts | Content hash comparison |

## Integration

### CTO Agent Access
```yaml
cto_diagnostics:
  script: plugin/diagnostics/repo-audit.sh
  when: Before architectural decisions
  output: Structure health, data sources, issues
```

### System Health Chain
```yaml
system-health.sh:
  chains:
    - validate-structure.sh
    - validate-skills.sh
    - validate-agents.sh
    - validate-remembrance.sh
    - validate-context7-alignment.sh
    - plugin/diagnostics/repo-audit.sh  # CTO-level check
```

## Data Sources Verified

| Source | What It Contains | Health Check |
|--------|------------------|--------------|
| `.remembrance` | Append-only truth log | Entry count, shape shifts |
| `.observability/` | Runtime metrics | Tracker reads, rounds |
| `plugin/observability/hypotheses/` | System hypotheses | Active count |
| `.loop-state.yaml` | Continuation point | Phase tracking |

## Canonical Script Locations

| Category | Canonical Location | Project Access |
|----------|-------------------|----------------|
| Observability | `plugin/observability/` | symlink from `scripts/` |
| Diagnostics | `plugin/diagnostics/` | direct or symlink |
| Project-specific | `scripts/` | committed |
| Runtime output | `.observability/` | gitignored |

---

*Created: 2026-02-07*
*Purpose: CTO-level repository visibility*
