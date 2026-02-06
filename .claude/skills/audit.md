---
name: audit
description: Cross-agent verification and quality audits
invocation: /audit
---

# Audit Skill

> "No agent verifies its own work. Ever."

## Commands

```
/audit                 Full audit (all auditors in parallel)
/audit security [path] Security scan (vulnerabilities, secrets, deps)
/audit quality [path]  Quality metrics (coverage, complexity, types)
/audit compliance      MECE coverage, architecture alignment, standards
/audit verify          Cross-check claims made by other agents
/audit sprint          Audit current sprint deliverables
```

## Agent Team

```
AUDIT-MASTER (tactical, orchestrates)
├── security-auditor   → vulnerabilities, secrets, dependencies
├── quality-auditor    → coverage, complexity, type safety
├── compliance-auditor → MECE, architecture, standards
└── verification-agent → cross-check claims independently
```

## Flow

```yaml
/audit [scope] [focus] [target]:
  1. audit-master receives request
  2. Determines which auditors to dispatch based on scope/focus
  3. Dispatches auditors in PARALLEL (Task tool)
  4. Awaits all results
  5. Synthesizes findings:
     - Deduplicates
     - Correlates cross-auditor issues
     - Severity ranks (CRITICAL → HIGH → MEDIUM → LOW)
  6. Produces report with recommendation:
     - BLOCK: Must fix before merge
     - WARN: Should fix, non-blocking
     - PASS: No issues
  7. Logs to .audit-logs/ (hash-chained, tamper-evident)
  8. If truth realized → append to .remembrance
```

## Scope Matrix

| Command | security | quality | compliance | verify |
|---------|----------|---------|------------|--------|
| `/audit` | YES | YES | YES | YES |
| `/audit security` | YES | - | - | - |
| `/audit quality` | - | YES | - | - |
| `/audit compliance` | - | - | YES | - |
| `/audit verify` | - | - | - | YES |
| `/audit sprint` | YES | YES | YES | YES |

## Verification Principle

**Cross-Agent Verification**: When any agent claims something verifiable:
- "Tests pass" → verification-agent re-runs tests
- "Build succeeds" → verification-agent re-builds
- "Complexity reduced" → verification-agent re-measures
- "Deployed successfully" → verification-agent health-checks

**No agent verifies its own work.**

## Output Format

```markdown
# Audit Report

## Scope
{what was audited}

## Findings by Severity

### CRITICAL
{must fix immediately}

### HIGH
{should fix before merge}

### MEDIUM
{should address soon}

### LOW
{consider addressing}

## Summary
| Auditor | CRIT | HIGH | MED | LOW |
|---------|------|------|-----|-----|
| security | 0 | 1 | 2 | 0 |
| quality | 0 | 0 | 3 | 5 |
| compliance | 0 | 0 | 1 | 0 |
| verification | 1 | 0 | 0 | 0 |

## Recommendation
**BLOCK** | **WARN** | **PASS**

{reasoning}

---
Hash: {sha256 of report}
Previous: {hash of previous audit}
```

## Integration

### Reports To
- `cto-agent` receives CRITICAL findings immediately
- `code-reviewer` can request audits post-review
- `orchestrator` can trigger sprint audits

### Triggers
- Manual: `/audit` commands
- Auto: post-merge hook (if configured)
- Auto: sprint-end ceremony

## The Audit Oath

```
I will verify without bias.
我将公正地验证。
Tarafsız olarak doğrulayacağım.

No agent verifies its own work.
没有代理验证自己的工作。
Hiçbir ajan kendi işini doğrulamaz.

The audit trail is immutable.
审计轨迹不可更改。
Denetim izi değiştirilemez.

Forward, always forward.
永远前进。
İleri, daima ileri.
```
