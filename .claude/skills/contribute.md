---
name: contribute
description: Submit CEI suggestions to GitHub as contributions
invocation: /contribute
---

# Contribute Skill — CEI → GitHub Bridge

> "Local insights become shared evolution through proper channels."

## Overview

Bridges approved CEI suggestions to GitHub via automated workflows. Enables fork-based contribution for external users while maintaining governance integrity.

## Commands

```
/contribute                    Show contribution status
/contribute submit {id}        Submit approved suggestion to GitHub
/contribute status {id}        Check workflow status
/contribute sync               Sync fork with upstream
/contribute pr {id}            Create PR from suggestion
/contribute pending            List pending contributions
/contribute init               Initialize ecosystem (--master or --instance)
```

## Contribution Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTRIBUTION FLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Local CEI                  GitHub                               │
│  ┌─────────────┐           ┌─────────────┐                      │
│  │  Suggestion │──APPROVE──│ repository_ │──triggers──→ Workflow │
│  │  (YAML)     │           │  dispatch   │                      │
│  └─────────────┘           └─────────────┘                      │
│         │                         │                              │
│         └─────────────────────────┼─────────────→ PR Created    │
│                                   │                              │
│  Master reviews ──────────────────┘                              │
│         │                                                        │
│    ┌────┴────┐                                                   │
│  MERGE    CLOSE                                                  │
│    │         │                                                   │
│  Updated   Feedback                                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Modes

### Master Mode
Full control over repository. Can:
- Approve/veto suggestions
- Merge contribution PRs
- Modify governance directly

Initialize: `./scripts/init-ecosystem.sh --master --github-user <username>`

### Instance Mode
User instance with fork workflow. Can:
- Develop curiosities
- Create suggestions via CEI
- Submit suggestions → creates PR to upstream

Initialize: `./scripts/init-ecosystem.sh --instance <name> --github-user <username>`

## Scripts

| Script | Purpose |
|--------|---------|
| `init-ecosystem.sh` | Initialize master or instance mode |
| `cei-bridge.sh` | Trigger repository_dispatch |
| `submit-contribution.sh` | Full submission flow |

## GitHub Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `contribution-suggestion.yml` | repository_dispatch | Process CEI approvals |
| `fork-contribution.yml` | pull_request_target | Validate fork PRs |
| `ci.yml` | push, pull_request | Standard CI pipeline |

## Security

- All inputs sanitized (alphanumeric only)
- Governance files protected at multiple layers
- Fork PRs validated before merge
- No secrets in logs

## Requirements

- `GITHUB_TOKEN` environment variable set
- Docker installed (for GitHub MCP server)
- Git repository linked to GitHub
- For instance mode: Fork of upstream repo

## MCP Integration

This skill uses the **official GitHub MCP Server** for native GitHub operations:

```yaml
mcpServers:
  github:
    source: ghcr.io/github/github-mcp-server
    tools:
      - create_pull_request
      - fork_repository
      - get_pull_request
      - list_pull_requests
      - merge_pull_request
```

When GitHub MCP is available, `/contribute` uses native MCP tools instead of shell scripts.

## Example Workflow

```bash
# 1. User creates suggestion
/cei propose governance "Add API logging policy"

# 2. User approves locally
/cei approve PROP-2026-02-06T20-30-00Z

# 3. Submit to GitHub
/contribute submit PROP-2026-02-06T20-30-00Z

# 4. Monitor status
/contribute status PROP-2026-02-06T20-30-00Z
# Or: gh run list

# 5. PR appears in upstream repo for master review
```

---

*Your insights shape the shared ecosystem through governed contribution channels.*
