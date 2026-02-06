---
name: plugin-publish
description: Publish Claude Code plugins to GitHub and marketplace
invocation: /plugin-publish
---

# Plugin Publishing Skill

> Publish Claude Code plugins to GitHub and register in marketplaces

## Publishing Flow

### 1. Validate Plugin Structure
```bash
# Required files
.claude-plugin/plugin.json    # Manifest (required)
README.md                     # Documentation (required)
LICENSE                       # License file (recommended)

# Optional components
commands/                     # Slash commands
agents/                       # Agent definitions
skills/                       # Skill definitions
hooks/                        # Event handlers
```

### 2. Validate Manifest
```json
{
  "name": "plugin-name",           // Required
  "version": "1.0.0",              // Required (semver)
  "description": "...",            // Required
  "author": "...",                 // Required
  "repository": "...",             // Required for distribution
  "license": "MIT",                // Recommended
  "keywords": [...]                // Recommended for discovery
}
```

### 3. Push to GitHub
```bash
# Initialize and commit
git init
git add -A
git commit -m "Initial commit: plugin-name v1.0.0"

# Create GitHub repo
gh repo create plugin-name --public --description "..." --source=. --push

# Add topics for discovery
gh repo edit --add-topic claude-code --add-topic plugin

# Create release
gh release create v1.0.0 --title "v1.0.0" --notes "Release notes..."
```

### 4. Register in Marketplace (Community)

Claude Code plugins are distributed via:
- **GitHub repos** — Primary distribution
- **Community marketplaces** — Curated lists (marketplace.json)
- **npm** — Optional for JS/TS plugins

To add to a community marketplace:
```bash
# Fork the marketplace repo
gh repo fork anthropics/claude-code-plugins

# Add entry to marketplace.json
{
  "name": "meta-agentic-loop",
  "description": "Self-continuing agentic framework",
  "repository": "https://github.com/user/meta-agentic-loop",
  "version": "1.0.0",
  "category": "framework",
  "tags": ["agentic", "scrum", "memory"]
}

# Submit PR
gh pr create --title "Add meta-agentic-loop plugin"
```

### 5. Installation Methods

Users can install via:
```bash
# From GitHub directly
git clone https://github.com/user/plugin-name ~/.claude/plugins/plugin-name

# From marketplace (if registered)
/plugin marketplace add user/plugin-name
/plugin install plugin-name

# Local development
cc --plugin-dir /path/to/plugin
```

---

## Quick Publish Checklist

- [ ] plugin.json complete with all required fields
- [ ] README.md with installation instructions
- [ ] LICENSE file present
- [ ] All scripts executable (`chmod +x`)
- [ ] Git repo initialized
- [ ] Pushed to GitHub
- [ ] Topics added for discovery
- [ ] Release created with notes
- [ ] Tested installation on clean environment

---

## Example: Publish meta-agentic-loop

```bash
# 1. Validate
cat .claude-plugin/plugin.json

# 2. Git
cd /path/to/meta-agentic-loop
git init && git add -A
git commit -m "Initial commit"

# 3. GitHub
gh repo create meta-agentic-loop --public --source=. --push
gh repo edit --add-topic claude-code --add-topic plugin
gh release create v1.0.0 --title "v1.0.0"

# 4. Test installation
mkdir /tmp/test-project && cd /tmp/test-project
git clone https://github.com/user/meta-agentic-loop ~/.claude/plugins/meta-agentic-loop
# Then run /init
```
