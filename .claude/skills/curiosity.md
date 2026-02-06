---
name: curiosity
description: Develop curiosities with mentor guidance
invocation: /curiosity
---

# Curiosity Skill — Personal Development

> "Curiosity is the fundamental thought vector of growth."

## Overview

Curiosities are areas of focused exploration. Each curiosity:
1. Has a mentor agent (Socratic guide)
2. Generates a `_vector` (fundamental thought vector)
3. Contributes to your culture
4. Can contribute to meta-agentic-loop plugin

## Commands

```
/curiosity                  List all curiosities
/curiosity new {name}       Start new curiosity
/curiosity develop {id}     Work on curiosity with mentor
/curiosity vector {id}      View fundamental thought vector
/curiosity journal {id}     Add journal entry
/curiosity reflect {id}     Deep reflection session
/curiosity contribute {id}  Submit contribution
```

## Curiosity Lifecycle

```
SEED → EXPLORE → DEVELOP → REFINE → CONTRIBUTE
  │       │         │         │          │
Define  Research   Build   Crystallize  Share
```

## Structure

```
/user/curiosities/{id}/
├── CURIOSITY.md        ← Definition
├── _vector.yaml        ← Thought vector
├── mentor/             ← Mentor agent
│   └── sessions/       ← Session logs
├── journal/            ← Reflections
└── contributions/      ← Contributions
```

## _vector Dimensions

| Dimension | Description | Range |
|-----------|-------------|-------|
| `epistemic_humility` | Awareness of knowledge limits | 0.0-1.0 |
| `recursive_depth` | Meta-cognitive layers | 0.0-1.0 |
| `integration_breadth` | Cross-domain connections | 0.0-1.0 |
| `practical_application` | Theory-to-practice | 0.0-1.0 |
| `contribution_orientation` | Sharing vs accumulating | 0.0-1.0 |

## Mentor System

Each curiosity gets a dedicated mentor:
- Asks probing questions
- Challenges assumptions
- Suggests resources
- Tracks progress
- Helps crystallize _vector

### Session Format

```
Mentor: "What drew you to this curiosity?"
You: [response]
Mentor: [follow-up question]
...
Insights: [captured to journal]
Vector: [updated if significant]
```

## Culture Integration

```
Your curiosities → _vectors → aggregate → your culture → propagate to agents

Rule: Culture passes down 80% to children, retains 20%
```

## Starting a New Curiosity

```bash
/curiosity new "machine learning fundamentals"
```

Creates:
1. Curiosity folder structure
2. Initial CURIOSITY.md
3. Empty _vector.yaml
4. Mentor agent configured

---

*Your curiosities shape your culture. Your culture shapes your agents.*
