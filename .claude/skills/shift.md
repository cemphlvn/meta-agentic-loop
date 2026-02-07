---
name: Shift Felt
description: Trigger SHIFT_FELT protocol to re-read accumulated wisdom
trigger: When context changes significantly or user explicitly triggers reflection
commands:
  - /shift
  - /reflect
  - /remember
requiredTools:
  - Read
---

# Shift Felt Skill

Trigger the SHIFT_FELT protocol to re-read accumulated wisdom.

## Activation

This skill activates when:
- User invokes `/shift` or `/reflect`
- Context has changed significantly
- Before major decisions
- After encountering contradictions

## SHIFT_FELT Protocol

### Automatic Triggers
- Context switch (different domain)
- Contradiction with prior beliefs
- Deep recursion (>3 agent levels)
- Time threshold (long-running task)
- Error recovery

### Manual Trigger
```
/shift
```

## What Happens

1. **Pause** current execution flow
2. **Load** `.remembrance` (brand-specific or global)
3. **Integrate** relevant truths into working context
4. **Resume** with updated understanding

## Remembrance Format

```yaml
---
timestamp: 2024-01-15T10:30:00Z
agent: ontological_researcher
context: brand_research:mindful-coffee
truth: The pause matters more than the outcome
reflection: Rushed experiences lose their meaning
confidence: 0.85
---
```

## Integration Process

When re-reading remembrance:
1. Filter truths by relevance to current context
2. Weight by confidence scores
3. Identify conflicts with current assumptions
4. Update working model

## Commands

### Trigger Shift
```
/shift
```
Explicitly trigger SHIFT_FELT.

### View Remembrance
```
/remember
/remember list
```
Show accumulated truths.

### Record Truth
```
/remember add "The insight I just realized..."
```
Manually record a truth.

## Example

```
User: /shift

Agent: Triggering SHIFT_FELT...

Loading .remembrance...
Found 12 recorded truths.

Relevant to current context (brand research):
1. [0.92] "Authenticity cannot be manufactured"
2. [0.85] "The pause matters more than the outcome"
3. [0.78] "Latent truths hide in what people don't say"

Integrating into working context...

Context updated. Ready to continue with accumulated wisdom.
```
