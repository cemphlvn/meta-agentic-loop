---
name: Voice Adjustment
description: Fine-tune brand voice parameters and style
trigger: When user wants to change brand voice, tone, or communication style
commands:
  - /voice
  - /voice show
  - /voice warmer
  - /voice "like a..."
requiredTools:
  - Read
  - Write
---

# Voice Adjustment Skill

Fine-tune brand voice parameters and style.

## Activation

This skill activates when:
- User mentions "voice", "tone", "style"
- User invokes `/voice [adjustment]`
- User provides voice metaphor

## Parameters

| Parameter | Description | Range |
|-----------|-------------|-------|
| warmth | Emotional temperature | 0 (cold) - 1 (warm) |
| formality | Casual vs professional | 0 (casual) - 1 (formal) |
| humor | Levity level | 0 (serious) - 1 (playful) |
| authority | Expert positioning | 0 (peer) - 1 (authority) |
| vulnerability | Openness level | 0 (guarded) - 1 (open) |
| pace | Communication speed | 0 (slow) - 1 (fast) |

## Commands

### Show Current
```
/voice
/voice show
```
Display current voice parameters.

### Relative Adjustment
```
/voice warmer      → warmth + 10%
/voice colder      → warmth - 10%
/voice more formal → formality + 10%
/voice less formal → formality - 10%
```

### Absolute Adjustment
```
/voice warmth 0.8
/voice humor 0.3
```

### Percentage Adjustment
```
/voice warmth +20%
/voice formality -15%
```

### Metaphor Interpretation
```
/voice "like a wise mentor"
/voice "like a trusted friend"
/voice "like an excited guide"
```

Maps metaphors to parameter combinations.

## Philosophical Alignment

Voice connects to philosophical techniques:

| Voice Style | Best Techniques |
|-------------|-----------------|
| Warm + Vulnerable | Voice Emergence, Jungian |
| Formal + Authoritative | Aristotelian, Nietzschean |
| Casual + Humorous | Socratic, Zen Koan |
| Measured + Educational | Phenomenological |

## Example

```
User: /voice "like a wise but approachable teacher"

Agent: Interpreting voice metaphor...

"Wise but approachable teacher" suggests:
- Authority present but not intimidating
- Warmth to create safety
- Humor for engagement
- Patience (slower pace)

Adjusting parameters:
- warmth: 0.5 → 0.7
- formality: 0.5 → 0.4
- humor: 0.3 → 0.4
- authority: 0.5 → 0.7
- vulnerability: 0.3 → 0.5
- pace: 0.5 → 0.3

Updated voice/parameters.md

Voice Metaphor: "A wise but approachable teacher"
```
