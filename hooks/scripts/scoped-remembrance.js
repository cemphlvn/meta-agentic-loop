#!/usr/bin/env node
/**
 * Scoped Remembrance System
 *
 * Each agent accesses only their portion + parent portions of .remembrance
 *
 * Hierarchy:
 *   SYSTEM (root)
 *   ├── STRATEGIC
 *   │   ├── business-strategy
 *   │   ├── cto-agent
 *   │   └── agentic-devops-strategy
 *   ├── TACTICAL
 *   │   ├── orchestrator
 *   │   ├── librarian
 *   │   ├── ontological-researcher
 *   │   ├── epistemological-researcher
 *   │   └── brand-builder
 *   └── OPERATIONAL
 *       ├── code-implementer
 *       ├── code-reviewer
 *       ├── code-simplifier
 *       └── repo-strategist
 *
 * Access Rules:
 *   - Agent sees: own scope + all ancestors up to SYSTEM
 *   - Strategic agents see: SYSTEM + STRATEGIC
 *   - Tactical agents see: SYSTEM + STRATEGIC + TACTICAL (own branch)
 *   - Operational agents see: SYSTEM + parent tactical + own
 *
 * Usage:
 *   node scoped-remembrance.js read <agent-id>
 *   node scoped-remembrance.js write <agent-id> <truth-json>
 *   node scoped-remembrance.js hierarchy
 */

const fs = require('fs');
const path = require('path');

// Agent hierarchy definition
const HIERARCHY = {
  system: {
    level: 0,
    parent: null,
    children: ['strategic', 'tactical', 'operational']
  },
  // Strategic tier
  strategic: {
    level: 1,
    parent: 'system',
    children: ['business-strategy', 'cto-agent', 'agentic-devops-strategy']
  },
  'business-strategy': { level: 2, parent: 'strategic', children: [] },
  'cto-agent': { level: 2, parent: 'strategic', children: [] },
  'agentic-devops-strategy': { level: 2, parent: 'strategic', children: [] },

  // Tactical tier
  tactical: {
    level: 1,
    parent: 'system',
    children: ['orchestrator', 'librarian', 'ontological-researcher', 'epistemological-researcher', 'brand-builder']
  },
  'orchestrator': { level: 2, parent: 'tactical', children: [] },
  'librarian': { level: 2, parent: 'tactical', children: [] },
  'ontological-researcher': { level: 2, parent: 'tactical', children: [] },
  'epistemological-researcher': { level: 2, parent: 'tactical', children: [] },
  'brand-builder': { level: 2, parent: 'tactical', children: [] },

  // Operational tier
  operational: {
    level: 1,
    parent: 'system',
    children: ['code-implementer', 'code-reviewer', 'code-simplifier', 'repo-strategist']
  },
  'code-implementer': { level: 2, parent: 'operational', children: [] },
  'code-reviewer': { level: 2, parent: 'operational', children: [] },
  'code-simplifier': { level: 2, parent: 'operational', children: [] },
  'repo-strategist': { level: 2, parent: 'operational', children: [] }
};

// Get ancestor chain for an agent
function getAncestorChain(agentId) {
  const chain = [agentId];
  let current = agentId;

  while (HIERARCHY[current]?.parent) {
    current = HIERARCHY[current].parent;
    chain.unshift(current);
  }

  return chain;
}

// Get all scopes an agent can access
function getAccessibleScopes(agentId) {
  const chain = getAncestorChain(agentId);
  // Agent can see: system + their tier + themselves
  return chain;
}

// Parse .remembrance file into structured entries
function parseRemembrance(content) {
  const entries = [];
  const blocks = content.split(/\n---\n/).filter(b => b.trim());

  for (const block of blocks) {
    if (!block.includes('timestamp:')) continue;

    const entry = {};
    const lines = block.split('\n');

    for (const line of lines) {
      const match = line.match(/^(\w+):\s*(.+)$/);
      if (match) {
        const [, key, value] = match;
        entry[key] = value.trim();
      }
    }

    if (entry.agent) {
      // Normalize agent name to match hierarchy
      entry.scope = normalizeAgentId(entry.agent);
      entries.push(entry);
    }
  }

  return entries;
}

// Normalize agent names to hierarchy IDs
function normalizeAgentId(agent) {
  const mapping = {
    'system': 'system',
    'orchestrator': 'orchestrator',
    'main_orchestrator': 'orchestrator',
    'librarian': 'librarian',
    'librarian_agent': 'librarian',
    'business_strategy': 'business-strategy',
    'cto_agent': 'cto-agent',
    'cto': 'cto-agent',
    'agentic_devops': 'agentic-devops-strategy',
    'agentic_devops_strategy': 'agentic-devops-strategy',
    'code_simplifier': 'code-simplifier',
    'code_reviewer': 'code-reviewer',
    'code_implementer': 'code-implementer',
    'repo_strategist': 'repo-strategist',
    'ontological_researcher': 'ontological-researcher',
    'epistemological_researcher': 'epistemological-researcher',
    'brand_builder': 'brand-builder'
  };

  const normalized = agent.toLowerCase().replace(/-/g, '_');
  return mapping[normalized] || normalized.replace(/_/g, '-');
}

// Filter entries by agent scope
function filterByScope(entries, agentId) {
  const accessibleScopes = getAccessibleScopes(agentId);

  return entries.filter(entry => {
    // System entries are always visible
    if (entry.scope === 'system') return true;

    // Check if entry's scope is in accessible scopes
    return accessibleScopes.includes(entry.scope);
  });
}

// Format entries back to .remembrance format
function formatRemembrance(entries) {
  return entries.map(entry => {
    let block = '---\n';
    for (const [key, value] of Object.entries(entry)) {
      if (key !== 'scope') { // Don't include internal scope field
        block += `${key}: ${value}\n`;
      }
    }
    block += '---';
    return block;
  }).join('\n\n');
}

// Read scoped remembrance for an agent
function readScoped(agentId, remembrancePath) {
  const content = fs.readFileSync(remembrancePath, 'utf-8');
  const entries = parseRemembrance(content);
  const filtered = filterByScope(entries, agentId);

  // Add header
  const header = `# Scoped Remembrance for: ${agentId}
# Accessible scopes: ${getAccessibleScopes(agentId).join(' → ')}
# Total entries visible: ${filtered.length}

`;

  return header + formatRemembrance(filtered);
}

// Append new truth to remembrance
function writeScoped(agentId, truthJson, remembrancePath) {
  const truth = typeof truthJson === 'string' ? JSON.parse(truthJson) : truthJson;

  const entry = `
---
timestamp: ${new Date().toISOString()}
agent: ${agentId}
context: ${truth.context || 'unspecified'}
truth: ${truth.truth}
reflection: ${truth.reflection || ''}
confidence: ${truth.confidence || 0.8}
---
`;

  fs.appendFileSync(remembrancePath, entry);
  return { success: true, agent: agentId, entry };
}

// Print hierarchy
function printHierarchy() {
  console.log(`
AGENT HIERARCHY & REMEMBRANCE SCOPES
=====================================

SYSTEM (root) ─────────────────────────────────────────
│   All agents can read system-level truths
│
├── STRATEGIC ─────────────────────────────────────────
│   │   Sees: SYSTEM + STRATEGIC
│   │
│   ├── business-strategy
│   │       Sees: SYSTEM → STRATEGIC → business-strategy
│   │
│   ├── cto-agent
│   │       Sees: SYSTEM → STRATEGIC → cto-agent
│   │
│   └── agentic-devops-strategy
│           Sees: SYSTEM → STRATEGIC → agentic-devops-strategy
│
├── TACTICAL ──────────────────────────────────────────
│   │   Sees: SYSTEM + TACTICAL
│   │
│   ├── orchestrator
│   │       Sees: SYSTEM → TACTICAL → orchestrator
│   │
│   ├── librarian
│   │       Sees: SYSTEM → TACTICAL → librarian
│   │
│   ├── ontological-researcher
│   │       Sees: SYSTEM → TACTICAL → ontological-researcher
│   │
│   ├── epistemological-researcher
│   │       Sees: SYSTEM → TACTICAL → epistemological-researcher
│   │
│   └── brand-builder
│           Sees: SYSTEM → TACTICAL → brand-builder
│
└── OPERATIONAL ───────────────────────────────────────
    │   Sees: SYSTEM + OPERATIONAL
    │
    ├── code-implementer
    │       Sees: SYSTEM → OPERATIONAL → code-implementer
    │
    ├── code-reviewer
    │       Sees: SYSTEM → OPERATIONAL → code-reviewer
    │
    ├── code-simplifier
    │       Sees: SYSTEM → OPERATIONAL → code-simplifier
    │
    └── repo-strategist
            Sees: SYSTEM → OPERATIONAL → repo-strategist
`);
}

// CLI
const [,, command, ...args] = process.argv;
const remembrancePath = path.join(process.cwd(), '.remembrance');

switch (command) {
  case 'read':
    if (!args[0]) {
      console.error('Usage: scoped-remembrance.js read <agent-id>');
      process.exit(1);
    }
    console.log(readScoped(args[0], remembrancePath));
    break;

  case 'write':
    if (!args[0] || !args[1]) {
      console.error('Usage: scoped-remembrance.js write <agent-id> <truth-json>');
      process.exit(1);
    }
    const result = writeScoped(args[0], args.slice(1).join(' '), remembrancePath);
    console.log(JSON.stringify(result, null, 2));
    break;

  case 'hierarchy':
    printHierarchy();
    break;

  case 'scopes':
    if (!args[0]) {
      console.error('Usage: scoped-remembrance.js scopes <agent-id>');
      process.exit(1);
    }
    console.log(JSON.stringify({
      agent: args[0],
      accessibleScopes: getAccessibleScopes(args[0]),
      ancestorChain: getAncestorChain(args[0])
    }, null, 2));
    break;

  default:
    console.log(`
Scoped Remembrance System
=========================

Commands:
  read <agent-id>              Read remembrance filtered by agent scope
  write <agent-id> <json>      Append truth to remembrance
  hierarchy                    Print agent hierarchy
  scopes <agent-id>            Show accessible scopes for agent

Examples:
  node scoped-remembrance.js read librarian
  node scoped-remembrance.js write cto-agent '{"truth":"...","context":"..."}'
  node scoped-remembrance.js hierarchy
`);
}
