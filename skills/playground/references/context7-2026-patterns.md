# Context7 Best Practices — February 2026

> Patterns for effective Claude Code plugins and skills

## Plugin Architecture

### Directory Structure (Standard)
```
plugin-name/
├── .claude-plugin/
│   └── plugin.json           # Manifest (required)
├── hooks/
│   ├── hooks.json            # Hook definitions
│   └── scripts/              # Hook scripts
├── skills/
│   └── skill-name/
│       ├── SKILL.md          # Main skill file
│       ├── scripts/          # Executable scripts
│       ├── references/       # Load-on-demand docs
│       └── assets/           # Templates, icons
├── commands/
│   └── command-name.md       # Slash commands
├── templates/
│   └── *.tmpl                # Project templates
└── README.md
```

### Manifest Best Practices
```json
{
  "name": "kebab-case-name",
  "version": "1.0.0",
  "description": "Brief, action-oriented (<100 chars)",
  "keywords": ["category", "capability", "domain"],
  "components": {
    "skills": ["list", "of", "skills"],
    "hooks": {
      "SessionStart": "brief description",
      "Stop": "brief description"
    }
  }
}
```

## Hook Patterns

### SessionStart — Context Loading
```json
{
  "SessionStart": [{
    "matcher": "*",
    "hooks": [{
      "type": "command",
      "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/load-context.sh",
      "timeout": 10
    }]
  }]
}
```

**Best Practices:**
- Keep under 10s timeout
- Output to stdout for context injection
- Use `$CLAUDE_ENV_FILE` for env vars
- Fail gracefully (don't block session)

### PreToolUse — Validation
```json
{
  "PreToolUse": [{
    "matcher": "Write|Edit",
    "hooks": [{
      "type": "prompt",
      "prompt": "Verify this change aligns with current task"
    }]
  }]
}
```

**Best Practices:**
- Use specific matchers, not "*"
- Prompt hooks for validation
- Command hooks for side effects
- Return 0 to allow, non-zero to block

### Stop — Persistence
```json
{
  "Stop": [{
    "matcher": "*",
    "hooks": [{
      "type": "command",
      "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/persist.sh"
    }]
  }]
}
```

**Best Practices:**
- Persist state changes
- Log session summary
- Update metrics
- Clean up temp files

## Skill Design

### Progressive Disclosure
```markdown
# SKILL.md Structure

## Quick Reference (always visible)
- Essential commands
- Most common patterns

## Details (reference files)
references/advanced-patterns.md
references/troubleshooting.md
references/api-reference.md
```

**Rules:**
- SKILL.md < 500 lines
- Core workflow in main file
- Details in references/
- Describe WHEN to read each reference

### Context Economy
```yaml
# Load hierarchy
tier_1_always: # <1KB
  - Current phase
  - Active PBI
  - Blocking issues

tier_2_on_demand: # <5KB
  - Full sprint state
  - Agent activity
  - Compliance metrics

tier_3_deep_dive: # <20KB
  - Historical events
  - Full audit logs
  - Evolution timeline
```

### Script Organization
```
scripts/
├── main.sh           # Entry point
├── lib/
│   ├── utils.sh      # Shared functions
│   └── config.sh     # Configuration
└── commands/
    ├── dashboard.sh  # /playground
    ├── metrics.sh    # /playground metrics
    └── export.sh     # /playground export
```

## Higher-Order Context

### Injection Hierarchy
```
1. System prompt (Claude's base)
2. CLAUDE.md (project instructions)
3. SessionStart hooks (plugin context)
4. Skill invocation (task-specific)
5. User message (immediate intent)
```

### Context Tags
```xml
<!-- Structured injection -->
<playground-context>
  <phase>ACT</phase>
  <sprint>SPRINT-001</sprint>
</playground-context>

<!-- Affects Claude's behavior -->
<operating-mode>
  <focus>PBI-V01</focus>
  <constraints>no-new-features</constraints>
</operating-mode>
```

### Mode Switching
```bash
# Via skill command
/playground mode focused    # Inject focus constraints
/playground mode exploratory  # Remove constraints
/playground mode strict     # Add verification prompts
```

## Error Handling

### Graceful Degradation
```bash
#!/bin/bash
set -euo pipefail

# Try primary source
if [ -f "${PROJECT_DIR}/.loop-state.yaml" ]; then
    PHASE=$(parse_yaml ...)
else
    # Fallback to default
    PHASE="OBSERVE"
    echo "# Note: Using default phase, .loop-state.yaml not found" >&2
fi
```

### Error Reporting
```yaml
# In .remembrance
---
timestamp: 2026-02-07T14:00:00Z
agent: playground
scope: operational
observed: |
  Hook script failed: playground-metrics.py
  Exit code: 1
  Stderr: ModuleNotFoundError: yaml
reasoning: |
  Missing dependency in plugin environment
action: Logged error, continued with cached metrics
outcome: Dashboard displayed stale data (acceptable)
---
```

## Testing

### Hook Testing
```bash
# Test SessionStart hook
CLAUDE_PROJECT_DIR=/path/to/project \
CLAUDE_PLUGIN_ROOT=/path/to/plugin \
bash hooks/scripts/session-start.sh

# Verify output
# Should output valid context without errors
```

### Skill Testing
```bash
# Verify skill structure
ls -la skills/playground/
# SKILL.md, scripts/, references/

# Test metrics script
python3 skills/playground/scripts/playground-metrics.py /path/to/project
# Should output valid JSON
```

## Distribution

### Git-based Installation
```bash
# Clone to plugins directory
git clone https://github.com/org/plugin-name ~/.claude/plugins/plugin-name

# Or add as submodule in project
git submodule add https://github.com/org/plugin-name .claude/plugins/plugin-name
```

### Update Pattern
```bash
cd ~/.claude/plugins/plugin-name
git pull origin main
```
