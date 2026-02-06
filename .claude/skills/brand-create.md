---
name: Create Brand
trigger: When user wants to create a new brand, initialize brand building, or run /brand create
commands:
  - /brand create
  - /brand init
requiredTools:
  - Write
  - Read
  - Task
  - Glob
subagents:
  - ontological-researcher
  - epistemological-researcher
---

# Brand Creation Skill

Create a new brand with full research synthesis.

## Activation

This skill activates when:
- User says "create a brand" or "new brand"
- User invokes `/brand create "Name"`
- User wants to start building a brand from scratch

## Workflow

### 1. Gather Context
Collect:
- Brand name
- Industry/vertical
- Initial description or aspirations
- Any existing assets (optional)

### 2. Create Folder Structure
```
brands/{slug}/
└── .claude/
    ├── BRAND.md
    ├── agents/
    │   └── brand_agent.md
    ├── research/
    │   ├── ontological/
    │   └── epistemological/
    ├── voice/
    │   └── parameters.md
    ├── segments/
    ├── campaigns/
    └── .remembrance
```

### 3. Dispatch Research Agents
Use Task tool to spawn:

**Ontological Researcher**
- Investigate brand essence
- Extract core values
- Detect brand truth
- Map differentiation

**Epistemological Researcher**
- Map evidence for claims
- Analyze perception gaps
- Validate positioning
- Identify knowledge gaps

### 4. Synthesize Research
Combine findings into:
- BRAND.md (core identity document)
- Voice parameters
- Initial segment hypotheses

### 5. Initialize Remembrance
Create brand-specific .remembrance with founding truths.

## Output

After completion:
- Brand folder exists at `brands/{slug}/`
- Research documents populated
- Brand ready for campaigns

## Example

```
User: /brand create "Mindful Coffee"

Agent: Creating brand "Mindful Coffee"...

1. Creating folder structure at brands/mindful-coffee/.claude/
2. Dispatching ontological researcher...
3. Dispatching epistemological researcher...
4. Synthesizing research...
5. Writing BRAND.md...

Brand "Mindful Coffee" created.

Essence: Coffee as a meditation practice
Truth: "The pause matters more than the drink"
Voice: Warm, contemplative, unhurried

Next: /research full or /campaign create
```
