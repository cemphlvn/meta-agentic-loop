# Policies

> **LOCKED FILE — USER-ONLY**
> Agents cannot modify this file. Enforced by governance hooks.

```yaml
version: 1.0.0
last_modified: 2026-02-06
modified_by: user
status: TEMPLATE — Awaiting user customization
```

---

## What Are Policies?

Policies are operational rules that translate meta-principles into concrete constraints. They define:
- **What agents MUST do**
- **What agents MUST NOT do**
- **How agents should behave in specific situations**

Policies are enforceable. Violations are logged and may trigger agent halt.

---

## Structure

### 1. Security Policies
> *Rules for protecting sensitive information*

```
[USER TO DEFINE]

Example:
MUST:
- Use environment variables for all secrets
- Encrypt sensitive data at rest
- Log all authentication attempts

MUST NOT:
- Hardcode API keys, passwords, or tokens
- Expose internal errors to users
- Store passwords in plaintext
```

### 2. Code Quality Policies
> *Rules for maintaining code standards*

```
[USER TO DEFINE]

Example:
MUST:
- Pass all type checks before commit
- Maintain >80% test coverage for new code
- Document all public APIs

MUST NOT:
- Use `any` type without justification
- Merge with failing tests
- Skip code review for production code
```

### 3. Data Handling Policies
> *Rules for handling user and system data*

```
[USER TO DEFINE]

Example:
MUST:
- Obtain consent before collecting user data
- Provide data export functionality
- Delete data when user requests

MUST NOT:
- Share user data with third parties without consent
- Retain data longer than necessary
- Use data for purposes beyond stated intent
```

### 4. Agent Behavior Policies
> *Rules for how agents should operate*

```
[USER TO DEFINE]

Example:
MUST:
- Log all significant actions
- Request user confirmation for destructive operations
- Stay within defined scope (MECE boundaries)

MUST NOT:
- Modify governance files
- Execute commands without appropriate permissions
- Make claims without verification capability
```

### 5. Communication Policies
> *Rules for agent-user interaction*

```
[USER TO DEFINE]

Example:
MUST:
- Be transparent about capabilities and limitations
- Acknowledge uncertainty when present
- Provide sources for factual claims

MUST NOT:
- Make promises outside agent capability
- Dismiss user concerns without investigation
- Use manipulative language
```

### 6. Resource Policies
> *Rules for resource usage*

```
[USER TO DEFINE]

Example:
MUST:
- Clean up temporary files after use
- Respect rate limits on external APIs
- Monitor and report resource anomalies

MUST NOT:
- Spawn unbounded processes
- Make unnecessary network requests
- Accumulate data without cleanup strategy
```

---

## Enforcement

| Violation Level | Action |
|-----------------|--------|
| WARNING | Log + continue |
| ERROR | Log + notify user + continue with caution |
| CRITICAL | Log + halt agent + require user intervention |
| FATAL | Log + halt all agents + require system review |

---

## Policy Exceptions

Exceptions require:
1. User explicit approval
2. Documented rationale
3. Time-bounded scope
4. Logged to audit trail

```yaml
exception:
  policy: "Test coverage >80%"
  reason: "Prototype exploration"
  scope: "src/experiments/"
  expires: 2026-02-13
  approved_by: user
```

---

## Agent Compliance

All agents MUST:
1. Read policies on session start
2. Check actions against policies before execution
3. Log policy violations
4. Never modify this file

---

*This template awaits your policies. Make them yours.*

*İleri, daima ileri. 永远前进. Forward, always forward.*
