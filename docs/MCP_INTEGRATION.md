# MCP Integration — How It Actually Works

> Understanding enforcement, CLI coordination, and plugin composition

## The Reality

### What's Official vs Third-Party

| Server | Made By | Status |
|--------|---------|--------|
| GitHub MCP | GitHub | Official GitHub product |
| Context7 | Upstash | Third-party (93K+ installs) |
| Playwright | Microsoft | Third-party |
| Sentry | Sentry | Official Sentry product |

**Anthropic's role**: Created MCP protocol, donated to Linux Foundation (AAIF). Does NOT make most MCP servers.

### How CLI and Claude Code Coordinate

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CLI ↔ CLAUDE CODE COORDINATION                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  CLI (Terminal)                        Claude Code (Runtime)         │
│  ─────────────────                     ─────────────────────         │
│                                                                      │
│  claude mcp add ────────────────────→  Server config stored          │
│  claude mcp remove ─────────────────→  Server removed                │
│  claude mcp list ───────────────────→  Show all servers              │
│                                                                      │
│                                        /mcp ─────→ Status, auth      │
│                                        Tool calls → Server executes  │
│                                                                      │
│  Config files:                         Runtime loads:                │
│  ~/.claude.json (user/local)           - User servers                │
│  .mcp.json (project)                   - Project servers             │
│  managed-mcp.json (enterprise)         - Managed servers             │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Enforcement Mechanisms

### Option 1: Enterprise Exclusive Control

Deploy `managed-mcp.json` to system path:

```
macOS:   /Library/Application Support/ClaudeCode/managed-mcp.json
Linux:   /etc/claude-code/managed-mcp.json
Windows: C:\Program Files\ClaudeCode\managed-mcp.json
```

**Effect**: Users CANNOT add ANY other MCP servers. Only managed ones work.

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    }
  }
}
```

### Option 2: Policy-Based Control

In managed settings, use allowlists/denylists:

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverName": "context7" },
    { "serverUrl": "https://mcp.company.com/*" },
    { "serverCommand": ["npx", "-y", "@context7/mcp-server"] }
  ],
  "deniedMcpServers": [
    { "serverUrl": "https://*.untrusted.com/*" }
  ]
}
```

**Effect**: Users CAN add servers, but only those matching allowlist. Denylist always wins.

### Option 3: Plugin-Bundled (Our Approach)

When user installs plugin, MCP servers auto-start:

```
Plugin installed
      ↓
.mcp.json read
      ↓
MCP servers start automatically
      ↓
Tools become available
```

**Effect**: No manual `claude mcp add` needed. Plugin controls which servers run.

---

## How Plugin Composition Works

### 1. Plugin Declares Dependencies

In `plugin.json`:

```json
{
  "name": "meta-agentic-loop",
  "dependencies": {
    "mcpServers": ["context7", "github"]
  }
}
```

### 2. Plugin Bundles Server Configs

In `.mcp.json`:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    },
    "github": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "ghcr.io/github/github-mcp-server"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### 3. On Plugin Enable

1. Claude Code reads `.mcp.json`
2. Starts each configured MCP server
3. Tools become available to all agents
4. User sees servers in `/mcp`

### 4. Can One Plugin Use Another Plugin's Servers?

**Not directly.** But:
- Plugins can depend on the same MCP servers
- Each plugin bundles its own `.mcp.json`
- If server already running, reused (no duplication)

---

## What We Need to Do

### For Meta-Agentic-Loop Users

1. **Install plugin** (fork + clone + init)
2. **Set GITHUB_TOKEN** (required for GitHub MCP)
3. **Claude Code auto-starts MCP servers**
4. **Use /mcp to verify**

### Setup Script Does This

```bash
./scripts/setup-github-mcp.sh
```

1. Checks Docker installed
2. Gets/validates GITHUB_TOKEN
3. Pulls GitHub MCP image
4. Adds token to .env
5. User restarts Claude Code → MCP active

---

## Security Notes

From [Anthropic Docs](https://code.claude.com/docs/en/mcp):

> **Use third party MCP servers at your own risk** - Anthropic has not verified the correctness or security of all these servers.

**Our mitigations**:
- Only use servers with official backing (GitHub, Upstash/Context7)
- Environment variables for secrets (never in repo)
- Governance lock prevents unauthorized modifications
- CEI requires user approval before contributions

---

## January 2026 Policy Update

Anthropic [blocked unauthorized "harnesses"](https://winbuzzer.com/2026/01/10/claude-code-anthropic-blocks-unauthorized-claude-harnesses-and-xai-access-in-major-crackdown-xcxwbn/) from accessing Claude:

- Tools spoofing official client → blocked
- Unauthorized third-party wrappers → blocked
- Official MCP servers → allowed
- Plugin-bundled MCP → allowed (via official plugin system)

**Impact**: Our plugin uses official channels, so it works.

---

## Commands Summary

```bash
# CLI - Configure
claude mcp add github --transport http https://api.githubcopilot.com/mcp/
claude mcp list
claude mcp remove github

# Inside Claude Code - Use
/mcp                    # Status, authenticate
@github:issue://123     # Reference MCP resources
/mcp__github__list_prs  # Execute MCP prompts
```

---

## Sources

- [Claude Code MCP Documentation](https://code.claude.com/docs/en/mcp)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [Context7 Plugin](https://claude.com/plugins/context7) (by Upstash)
- [Model Context Protocol](https://github.com/modelcontextprotocol)
- [Anthropic Crackdown on Unauthorized Access](https://winbuzzer.com/2026/01/10/claude-code-anthropic-blocks-unauthorized-claude-harnesses-and-xai-access-in-major-crackdown-xcxwbn/)
