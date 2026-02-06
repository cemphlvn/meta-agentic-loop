---
name: governance
description: Manage user-only governance files (meta-principles, policies, ethics)
invocation: /governance
---

# Governance Skill

> "Agents obey. Users govern. The distinction is immutable."

## Commands

```
/governance                    Show governance status
/governance list               List all governance files
/governance read <file>        Read a governance file (agents CAN read)
/governance edit <file>        Open file for USER editing (agents CANNOT use)
/governance request <proposal> Propose changes (agents CAN use)
/governance audit              Audit governance compliance
```

## Governance Files

| File | Purpose | Agent Access |
|------|---------|--------------|
| `GOVERNANCE.md` | System overview | READ only |
| `meta-principles.md` | Philosophical foundations | READ only |
| `curiosity-of-curiosity.md` | Meta-cognition rules | READ only |
| `policies.md` | Operational constraints | READ only |
| `ethics.md` | Ethical boundaries | READ only |

## Enforcement

### Permission Deny Rules
```json
{
  "deny": [
    "Write(.claude/governance/*)",
    "Edit(.claude/governance/*)"
  ]
}
```

### PreToolUse Hook
```json
{
  "matcher": "Write|Edit|MultiEdit",
  "hooks": [{
    "type": "command",
    "command": "python3 scripts/hooks/governance-lock.py"
  }]
}
```

## For Users

### Edit Governance Directly
```bash
# Open in editor
vim .claude/governance/meta-principles.md

# Or use any editor
code .claude/governance/policies.md
```

### View Current State
```bash
/governance list
/governance read meta-principles
```

## For Agents

### Reading (ALLOWED)
```
Agent can READ governance files to understand constraints.
This happens automatically on session start.
```

### Writing (BLOCKED)
```
Agent: "I need to update the policies..."
System: ❌ BLOCKED: Governance files are user-only.
```

### Proposing Changes (ALLOWED)
```yaml
/governance request:
  target: policies.md
  proposal: |
    Add rule: "All API calls must be logged"
  rationale: |
    Improves auditability and debugging

# Creates: .claude/governance/proposals/PROP-{timestamp}.md
# User reviews and manually applies if approved
```

## Proposal Flow

```
1. Agent detects need for governance change
2. Agent uses: /governance request <proposal>
3. System creates proposal file in proposals/
4. User reviews proposal
5. User manually applies (or rejects)
6. Proposal archived
```

## Compliance Check

The `/governance audit` command verifies:
- All governance files present
- All governance files have valid structure
- All agents have read governance on session start
- No unauthorized modification attempts in audit log

## Sources

- [Claude Code Security](https://code.claude.com/docs/en/security)
- [Claude Code Permissions](https://code.claude.com/docs/en/permissions)
- [Anthropic Building Safeguards](https://www.anthropic.com/news/building-safeguards-for-claude)
