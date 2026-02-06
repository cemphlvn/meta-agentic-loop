# CII Architecture

## System Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                        LOGICSTICKS.AI                            │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                    CII (Frontend)                          │  │
│  │         Cognitive Intuitive Interface Layer                │  │
│  └────────────────────────────────────────────────────────────┘  │
│                              │                                    │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                  COGSTRA™ Agent Core                       │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │  │
│  │  │ Brand Agent  │  │ Research     │  │ Campaign     │     │  │
│  │  │              │  │ Agents       │  │ Agent        │     │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │  │
│  └────────────────────────────────────────────────────────────┘  │
│                              │                                    │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                    Plugin System                           │  │
│  │  [Video Gen] [Campaign] [Analytics] [Export] [...]        │  │
│  └────────────────────────────────────────────────────────────┘  │
│                              │                                    │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                 Infrastructure (MECE)                      │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │  │
│  │  │Supabase │  │ Vector  │  │ Storage │  │ VIDEO   │       │  │
│  │  │   DB    │  │Embeddings│  │  (S3)  │  │ MODEL   │       │  │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

## The Claude Wrapper Pattern

Every brand/project becomes its own agent context with self-documenting structure:

```
brands/
└── {brand_id}/
    └── .claude/                    # Brand's own agent context
        ├── BRAND.md               # Brand identity (agent-generated)
        ├── agents/
        │   └── brand_agent.md     # Brand-specific agent config
        ├── research/
        │   ├── ontological/       # What IS this brand?
        │   │   ├── essence.md
        │   │   ├── values.md
        │   │   └── truth.md
        │   └── epistemological/   # How do we KNOW this brand?
        │       ├── evidence.md
        │       ├── perception.md
        │       └── validation.md
        ├── campaigns/
        │   └── {campaign_id}/
        │       ├── CAMPAIGN.md
        │       └── projects/
        │           └── {project_id}/
        │               ├── PROJECT.md
        │               └── videos/
        │                   └── {video_id}.md
        ├── segments/
        │   └── psychodemographic.md
        └── .remembrance            # Brand-specific truth log
```

## Research Agent Duality

### Ontological Research Agent
**Question**: "What IS this?"

Investigates:
- Essence and identity
- Core values and principles
- Authentic truth of the brand
- What makes it THIS and not THAT

Output: `/research/ontological/*.md`

### Epistemological Research Agent
**Question**: "How do we KNOW this?"

Investigates:
- Evidence and validation
- Market perception vs intention
- Data-backed insights
- Confidence in claims

Output: `/research/epistemological/*.md`

```
Research Flow:
                    ┌─────────────────┐
                    │  Brand Input    │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              ▼                              ▼
    ┌─────────────────┐            ┌─────────────────┐
    │  Ontological    │            │ Epistemological │
    │  Research Agent │            │ Research Agent  │
    │                 │            │                 │
    │  "What IS it?"  │            │ "How KNOW it?"  │
    └────────┬────────┘            └────────┬────────┘
             │                              │
             │      ┌─────────────┐        │
             └──────►  Synthesis  ◄────────┘
                    │    Agent    │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  .claude/   │
                    │  (docs)     │
                    └─────────────┘
```

## Vector Embedding Architecture

### Psychodemographic Segments
```sql
-- Supabase table structure
CREATE TABLE segments (
    id UUID PRIMARY KEY,
    brand_id UUID REFERENCES brands(id),
    name TEXT,
    description TEXT,

    -- Psychographic dimensions (embedded)
    values_embedding VECTOR(1536),
    beliefs_embedding VECTOR(1536),
    aspirations_embedding VECTOR(1536),

    -- Demographic data
    demographics JSONB,

    -- Philosophical receptivity scores
    philosophical_receptivity JSONB,

    -- Latent truth alignment
    latent_truth_embedding VECTOR(1536)
);

-- Similarity search for segment matching
CREATE INDEX ON segments
USING ivfflat (latent_truth_embedding vector_cosine_ops);
```

### Truth Alignment Matching
```
Content Latent Truth ←──similarity──→ Segment Latent Truth
        │                                      │
        └──────────► Match Score ◄─────────────┘
                          │
                   Video targeting
```

## Plugin System

### Official Plugins (Initial)
1. **Video Generation** - VIDEO_MODEL integration
2. **Campaign Manager** - Campaign/Project/Video hierarchy
3. **Segment Analyzer** - Psychodemographic profiling
4. **Export Suite** - Brand guidelines export

### Plugin Interface
```typescript
interface CIIPlugin {
    id: string;
    name: string;
    version: string;

    // Lifecycle
    onInstall(context: PluginContext): Promise<void>;
    onActivate(brand: Brand): Promise<void>;

    // Commands this plugin provides
    commands: PluginCommand[];

    // UI components
    components?: PluginComponent[];

    // Agent capabilities it adds
    agentCapabilities?: AgentCapability[];
}
```

## Database Schema (Supabase)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   brands    │────<│  campaigns  │────<│  projects   │
└─────────────┘     └─────────────┘     └─────────────┘
      │                                        │
      │                                        │
      ▼                                        ▼
┌─────────────┐                         ┌─────────────┐
│  segments   │                         │   videos    │
│ (vectors)   │                         │             │
└─────────────┘                         └─────────────┘
      │                                        │
      └────────────────┬───────────────────────┘
                       ▼
              ┌─────────────────┐
              │ video_segments  │
              │ (targeting)     │
              └─────────────────┘
```

## Docker Compose Structure

```yaml
services:
  # PostgreSQL with pgvector
  db:
    image: pgvector/pgvector:pg16

  # Supabase services
  supabase-studio:
  supabase-api:
  supabase-auth:

  # Application
  cii-app:
  cogstra-agents:

  # Development
  mailhog:
```
