---
name: Campaign Management
description: Create and manage marketing campaigns, projects, and video content
trigger: When user wants to create campaigns, projects, or generate videos
commands:
  - /campaign create
  - /campaign list
  - /campaign status
  - /project create
  - /project list
  - /video generate
requiredTools:
  - Read
  - Write
  - Task
  - Glob
subagents:
  - brand-builder
---

# Campaign Management Skill

Create and manage marketing campaigns, projects, and video content.

## Activation

This skill activates when:
- User mentions "campaign", "project", "video"
- User invokes `/campaign`, `/project`, or `/video`
- User wants to test content against segments

## Hierarchy

```
Brand
└── Campaign (marketing initiative)
    └── Project (specific test or effort)
        └── Video (individual content piece)
```

## Campaign Commands

### Create Campaign
```
/campaign create "Q1 Launch Campaign"
```
Creates:
```
brands/{brand}/.claude/campaigns/{id}/
├── CAMPAIGN.md
└── projects/
```

### List Campaigns
```
/campaign list
```

### Campaign Status
```
/campaign status
```

## Project Commands

### Create Project
```
/project create "Segment A - Socratic Hook Test"
```
Creates:
```
campaigns/{campaign}/projects/{id}/
├── PROJECT.md
└── videos/
```

Requires:
- Active campaign
- Target segment
- Latent truth to test

### List Projects
```
/project list
```

## Video Commands

### Generate Video
```
/video generate
/video generate --technique=socratic
/video generate --format=short --segment=young-professionals
```

Options:
- `--technique`: Philosophical technique to apply
- `--format`: short, long, ad, story, reel
- `--segment`: Target segment ID
- `--truth`: Latent truth statement to test

### Video Workflow
1. Load project context
2. Select philosophical technique
3. Generate prompt from technique + truth
4. Call VIDEO_MODEL API
5. Record in project's videos folder
6. Calculate segment alignment

## Segment Alignment

Videos are tested against segments via vector similarity:

```
Video Latent Truth Embedding
         ↓
    cosine similarity
         ↓
Segment Latent Truth Embedding
         ↓
    Alignment Score (0-1)
```

High alignment = content resonates with segment.

## Example

```
User: /campaign create "Summer Brand Awareness"

Agent: Creating campaign "Summer Brand Awareness"...

Campaign created at:
brands/acme/.claude/campaigns/summer-brand-awareness/

Objective: [Not yet defined]
Target Segments: [Not yet assigned]

Next:
- /project create "Segment Test"
- Set objective with /campaign objective "..."

---

User: /project create "Young Professionals - Voice Emergence Test"

Agent: Creating project...

Project: Young Professionals - Voice Emergence Test
Segment: young-professionals
Technique: voice_emergence
Latent Truth: [To be defined]

Next:
- Define truth: /project truth "The unspoken reality..."
- Generate: /video generate

---

User: /video generate --technique=socratic

Agent: Generating video...

Technique: Socratic Hook
Format: short (15s)
Prompt: "Question that challenges assumption about [topic]..."

[Calling VIDEO_MODEL API...]

Video generated:
- ID: vid_abc123
- Status: ready
- Alignment with young-professionals: 0.82

Documented at:
projects/young-professionals-test/videos/vid_abc123.md
```
