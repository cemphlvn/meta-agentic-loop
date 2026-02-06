# Repository Architecture

> Separate repos that are aware of each other

---

## Research Summary

Based on [Atlassian Git Subtree docs](https://www.atlassian.com/git/tutorials/git-subtree), [GeeksforGeeks comparison](https://www.geeksforgeeks.org/git/git-subtree-vs-git-submodule/), [Turborepo structuring guide](https://turborepo.dev/docs/crafting-your-repository/structuring-a-repository), and [GitHub Packages npm docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry):

| Approach | Pros | Cons | Best For |
|----------|------|------|----------|
| **Monorepo** | Easy sync, best tooling | Not truly separate | Tightly coupled teams |
| **Git Submodules** | True separation, version pinning | Complex workflow | Libraries with stable APIs |
| **Git Subtrees** | Simpler than submodules | History pollution | One-time imports |
| **npm Packages** | Clean versioning, proper deps | Need publishing | Public/private packages |
| **GitHub repo refs** | No publishing needed | Less formal | Quick prototyping |

---

## Recommended: Federated Multi-Repo Pattern

```
┌─────────────────────────────────────────────────────────────────┐
│                     REPOSITORY STRUCTURE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  github.com/cemphlvn/meta-agentic-loop     (THE PLUGIN)         │
│       │                                                          │
│       ├── Core framework (CORE_LOOP, governance, agents)        │
│       ├── Published as npm package: @meta-agentic/loop          │
│       └── Also usable as git submodule                          │
│                                                                  │
│  github.com/cemphlvn/humanitic             (ECOSYSTEM INSTANCE) │
│       │                                                          │
│       ├── Extends meta-agentic-loop                             │
│       ├── Contains: LICENSE, librarian, tools, meta layer       │
│       ├── References meta-agentic-loop as dependency            │
│       └── Published as: @meta-agentic/humanitic                 │
│                                                                  │
│  github.com/cemphlvn/logicsticks-ai        (YOUR PROJECT)       │
│       │                                                          │
│       ├── Uses meta-agentic-loop (submodule or npm)             │
│       ├── Joins humanitic ecosystem (config reference)          │
│       └── Contains: your curiosities, your agents, your domain  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## How They're Aware of Each Other

### 1. Dependency Chain (npm)

```json
// logicsticks-ai/package.json
{
  "dependencies": {
    "@meta-agentic/loop": "^1.0.0",
    "@meta-agentic/humanitic": "^1.0.0"
  }
}
```

### 2. ecosystem.config.yaml (Awareness)

```yaml
# logicsticks-ai/ecosystem.config.yaml
ecosystem:
  plugin: "@meta-agentic/loop"
  instance: humanitic

upstream:
  loop: "github.com/cemphlvn/meta-agentic-loop"
  humanitic: "github.com/cemphlvn/humanitic"

sync:
  mode: git-submodule  # or npm
  auto_update: false   # manual control
```

### 3. Submodule Pattern (Alternative)

```bash
# In logicsticks-ai
git submodule add https://github.com/cemphlvn/meta-agentic-loop.git plugin
git submodule add https://github.com/cemphlvn/humanitic.git instances/humanitic
```

Result:
```
logicsticks-ai/
├── plugin/                    → meta-agentic-loop (submodule)
├── instances/
│   └── humanitic/             → humanitic (submodule)
├── user/                      # Your project-specific
├── .claude/                   # Extends plugin/.claude
└── ecosystem.config.yaml      # Your config
```

---

## Awareness Mechanisms

### A. Upstream Tracking

Each repo knows its upstream:

```yaml
# humanitic/ecosystem.config.yaml
upstream:
  name: meta-agentic-loop
  repo: github.com/cemphlvn/meta-agentic-loop
  version: "^1.0.0"
  sync_method: npm  # or submodule

# logicsticks-ai/ecosystem.config.yaml
upstream:
  plugin:
    name: meta-agentic-loop
    repo: github.com/cemphlvn/meta-agentic-loop
  ecosystem:
    name: humanitic
    repo: github.com/cemphlvn/humanitic
```

### B. GitHub Actions Sync

```yaml
# .github/workflows/sync-upstream.yml
name: Sync Upstream
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true

      - name: Update submodules
        run: git submodule update --remote --merge

      - name: Create PR if changes
        uses: peter-evans/create-pull-request@v6
        with:
          title: "Sync upstream changes"
          branch: sync/upstream
```

### C. Version Compatibility Matrix

```yaml
# meta-agentic-loop/compatibility.yaml
version: 1.0.0
compatible_instances:
  humanitic: ">=1.0.0"

required_by:
  logicsticks-ai: "1.0.0"  # Tracks who uses this
```

---

## Implementation Steps

### Step 1: Create meta-agentic-loop repo

```bash
# Extract plugin from current repo
mkdir -p ~/Projects/meta-agentic-loop
cd ~/Projects/logicsticks.ai

# Copy core plugin files
cp -r .claude ~/Projects/meta-agentic-loop/
cp -r scripts/hooks ~/Projects/meta-agentic-loop/scripts/
cp -r processes ~/Projects/meta-agentic-loop/
# ... other core files

cd ~/Projects/meta-agentic-loop
git init
gh repo create meta-agentic-loop --public
git push -u origin main
```

### Step 2: Create humanitic repo

```bash
mkdir -p ~/Projects/humanitic
cd ~/Projects/logicsticks.ai

# Move humanitic instance
cp -r instances/humanitic/* ~/Projects/humanitic/

# Add reference to meta-agentic-loop
cd ~/Projects/humanitic
git init
git submodule add https://github.com/cemphlvn/meta-agentic-loop.git plugin
gh repo create humanitic --public
git push -u origin main
```

### Step 3: Restructure logicsticks-ai

```bash
cd ~/Projects/logicsticks.ai

# Remove embedded files (now in plugin repo)
rm -rf instances/humanitic

# Add as submodules
git submodule add https://github.com/cemphlvn/meta-agentic-loop.git plugin
git submodule add https://github.com/cemphlvn/humanitic.git instances/humanitic

# Update ecosystem.config.yaml with references
```

---

## Cross-Repo Contribution Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTRIBUTION FLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Developer in logicsticks-ai                                     │
│       │                                                          │
│       ├── Improves a pattern in their project                   │
│       │                                                          │
│       ├── Pattern is generic enough for plugin?                 │
│       │       │                                                  │
│       │       └── YES: Create PR to meta-agentic-loop           │
│       │             └── CEI proposal → Fork → PR                │
│       │                                                          │
│       ├── Pattern is humanitic-specific?                        │
│       │       │                                                  │
│       │       └── YES: Create PR to humanitic                   │
│       │             └── Vector credit maintained                │
│       │                                                          │
│       └── Pattern is project-specific?                          │
│               │                                                  │
│               └── Keep in logicsticks-ai                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## npm Package Structure (Alternative to Submodules)

```json
// meta-agentic-loop/package.json
{
  "name": "@meta-agentic/loop",
  "version": "1.0.0",
  "files": [".claude", "scripts", "processes"],
  "bin": {
    "mal-init": "./scripts/init-ecosystem.sh"
  }
}

// humanitic/package.json
{
  "name": "@meta-agentic/humanitic",
  "version": "1.0.0",
  "dependencies": {
    "@meta-agentic/loop": "^1.0.0"
  }
}

// logicsticks-ai/package.json
{
  "dependencies": {
    "@meta-agentic/loop": "^1.0.0",
    "@meta-agentic/humanitic": "^1.0.0"
  }
}
```

---

## Recommendation

**For your case, use Submodules + Awareness Config**:

1. **Submodules** because:
   - True separate repos (each has own history, issues, PRs)
   - Version pinning (you control when to update)
   - Works with Claude Code (files are present locally)

2. **Not npm packages** because:
   - Claude Code needs files in `.claude/` directory
   - Submodules give direct file access
   - No publishing overhead

3. **Awareness via ecosystem.config.yaml** because:
   - Each repo knows its upstreams
   - Contribution flow is clear
   - Humanitic ecosystem credits work

---

## Decision

| Repo | Type | Contains |
|------|------|----------|
| `meta-agentic-loop` | Plugin framework | Core agents, governance, scripts, CORE_LOOP |
| `humanitic` | Ecosystem instance | License, librarian, tools, meta layer |
| `logicsticks-ai` | Your project | Submodules + your domain-specific content |

Shall I execute this restructuring?
