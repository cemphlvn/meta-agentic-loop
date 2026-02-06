---
name: Research
trigger: When user wants to investigate a brand, understand its essence, validate claims, or run /research
commands:
  - /research
  - /research ontological
  - /research epistemological
  - /research full
requiredTools:
  - Read
  - Write
  - Task
  - Glob
  - Grep
subagents:
  - ontological-researcher
  - epistemological-researcher
---

# Research Skill

Conduct deep research on brands using ontological and epistemological methods.

## Activation

This skill activates when:
- User asks to research or investigate a brand
- User invokes `/research [mode]`
- User wants to understand brand essence or validate claims

## Research Modes

### Ontological ("What IS it?")
```
/research ontological
```
Investigates:
- **Essence**: Irreducible core of the brand
- **Values**: Implicit and explicit values
- **Truth**: What unspoken reality the brand voices
- **Differentiation**: What the brand IS NOT

Output: `research/ontological/*.md`

### Epistemological ("How do we KNOW?")
```
/research epistemological
```
Investigates:
- **Evidence**: Data supporting claims
- **Perception**: Intended vs perceived brand
- **Validation**: Which claims are verifiable
- **Gaps**: What we don't know

Output: `research/epistemological/*.md`

### Full (Both + Synthesis)
```
/research full
```
Runs both, then synthesizes:
- Cross-validates findings
- Identifies tensions
- Produces integrated brief

## Meta-Agentic Protocol

During research:
1. Load `.techniques/meta/awareness.md`
2. Check SHIFT_FELT triggers
3. Re-read `.remembrance` if shift detected
4. Record new truths discovered

## Truth Detection

When research reveals a truth:
```yaml
timestamp: [ISO-8601]
agent: [research agent name]
context: [what was being investigated]
truth: [the realization]
reflection: [what this means]
confidence: [0.0-1.0]
```

Append to brand's `.remembrance`.

## Example

```
User: /research ontological

Agent: Running ontological research on current brand...

Investigating:
- What IS this brand at its core?
- What values drive its decisions?
- What truth does it voice for others?

[Dispatching ontological-researcher subagent...]

Findings:
- Essence: "Accessible luxury through craft"
- Core Values: Quality > Scale, Education > Sales
- Truth: "You deserve better without pretension"
- Anti-Identity: NOT exclusive, NOT mass-market

Writing to research/ontological/...

Truth realized and recorded to .remembrance:
"Accessible luxury resolves the tension between desire and guilt"
```
