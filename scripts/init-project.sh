#!/bin/bash
# ══════════════════════════════════════════════════════════════════════════════
#                    META-AGENTIC-LOOP — Project Initializer
# ══════════════════════════════════════════════════════════════════════════════
#
# Usage: ./init-project.sh [project-name] [--philosophy unified|turkish|chinese|english]
#
# ══════════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Defaults
PROJECT_NAME="${1:-$(basename $(pwd))}"
PHILOSOPHY="unified"
SPRINT_GOAL="Foundation & Core Setup"

# Generate sequential timestamps (1 second apart for ordering)
TIMESTAMP_1=$(date -u +%Y-%m-%dT%H:%M:%SZ)
sleep 1
TIMESTAMP_2=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TIMESTAMP="${TIMESTAMP_1}"  # For CLAUDE.md compatibility

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --philosophy)
      PHILOSOPHY="$2"
      shift 2
      ;;
    --goal)
      SPRINT_GOAL="$2"
      shift 2
      ;;
    *)
      if [[ ! "$1" =~ ^-- ]]; then
        PROJECT_NAME="$1"
      fi
      shift
      ;;
  esac
done

# Colors
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                    META-AGENTIC-LOOP INITIALIZER                          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}     逆水行舟，不进则退                                                      ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}     ${DIM}Like rowing upstream: no advance is to drop back${NC}                     ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${DIM}Project: ${PROJECT_NAME}${NC}"
echo -e "${DIM}Philosophy: ${PHILOSOPHY}${NC}"
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# 1. Create Directory Structure
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${GREEN}Creating directory structure...${NC}"

mkdir -p .claude/agents
mkdir -p .claude/skills
mkdir -p scrum/roles
mkdir -p scrum/artifacts
mkdir -p scrum/ceremonies
mkdir -p scrum/sprints/SPRINT-001
mkdir -p processes
mkdir -p commands
mkdir -p scripts/hooks
mkdir -p docs/architecture
mkdir -p docs/librarian

# ──────────────────────────────────────────────────────────────────────────────
# 2. Create CLAUDE.md from template
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${GREEN}Creating CLAUDE.md...${NC}"

sed -e "s/{{PROJECT_NAME}}/${PROJECT_NAME}/g" \
    -e "s/{{PHILOSOPHY}}/${PHILOSOPHY}/g" \
    -e "s/{{TIMESTAMP}}/${TIMESTAMP}/g" \
    -e "s/{{SPRINT_GOAL}}/${SPRINT_GOAL}/g" \
    "$PLUGIN_ROOT/templates/CLAUDE.md.tmpl" > CLAUDE.md

# ──────────────────────────────────────────────────────────────────────────────
# 3. Create .remembrance from template
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${GREEN}Creating .remembrance...${NC}"

sed -e "s/{{PROJECT_NAME}}/${PROJECT_NAME}/g" \
    -e "s/{{TIMESTAMP_1}}/${TIMESTAMP_1}/g" \
    -e "s/{{TIMESTAMP_2}}/${TIMESTAMP_2}/g" \
    -e "s/{{TIMESTAMP}}/${TIMESTAMP}/g" \
    "$PLUGIN_ROOT/templates/remembrance.tmpl" > .remembrance

# ──────────────────────────────────────────────────────────────────────────────
# 4. Copy scrum templates
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${GREEN}Creating scrum structure...${NC}"

if [ -d "$PLUGIN_ROOT/templates/scrum" ]; then
  cp -r "$PLUGIN_ROOT/templates/scrum/"* scrum/ 2>/dev/null || true
fi

# Create minimal SCRUM.md if not copied
if [ ! -f "scrum/SCRUM.md" ]; then
  cat > scrum/SCRUM.md << 'SCRUM_EOF'
# SCRUM.md - Essence-Based Orchestration Hub

> "The essence of agility is not the practice, but the alpha states we traverse."

## Alpha State Cards

### Opportunity
| State | Status |
|-------|--------|
| Identified | [ ] |
| Value Established | [ ] |
| Viable | [ ] |

### Requirements
| State | Status |
|-------|--------|
| Conceived | [ ] |
| Bounded | [ ] |
| Coherent | [ ] |

### Software System
| State | Status |
|-------|--------|
| Architecture Selected | [ ] |
| Demonstrable | [ ] |
| Usable | [ ] |

### Work
| State | Status |
|-------|--------|
| Initiated | [ ] |
| Prepared | [ ] |
| Started | [ ] |

## Current Sprint

```yaml
sprint: SPRINT-001
goal: "Foundation & Core Setup"
state: Work.Initiated
```

## Product Backlog

| ID | Title | State | Priority |
|----|-------|-------|----------|
| PBI-001 | (Add your first item) | Backlog | P1 |

→ Full: `/scrum/artifacts/PRODUCT_BACKLOG.md`
SCRUM_EOF
fi

# ──────────────────────────────────────────────────────────────────────────────
# 5. Copy process templates
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${GREEN}Creating process definitions...${NC}"

if [ -d "$PLUGIN_ROOT/templates/processes" ]; then
  cp -r "$PLUGIN_ROOT/templates/processes/"* processes/ 2>/dev/null || true
fi

# Create minimal INDEX.md if not copied
if [ ! -f "processes/INDEX.md" ]; then
  cat > processes/INDEX.md << 'PROC_EOF'
# Process Index

## Process Types

| Type | Description |
|------|-------------|
| `sequential` | Steps execute in order |
| `parallel` | Independent steps execute concurrently |
| `conditional` | Branch based on output |

## Available Processes

| Process | Type | Description |
|---------|------|-------------|
| feature | sequential | Feature implementation |
| bugfix | sequential | Bug investigation and fix |
| refactor | conditional | Safe refactoring |
| research | parallel | Deep research |

→ Details in individual `.md` files
PROC_EOF
fi

# ──────────────────────────────────────────────────────────────────────────────
# 6. Create Agent Index
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${GREEN}Creating agent index...${NC}"

cat > .claude/agents/INDEX.md << 'AGENT_EOF'
# Agent Index

> Mutually Exclusive, Collectively Exhaustive (MECE) agent registry

## Agent Registry

### Strategic Tier
| ID | Name | Responsibility | Status |
|----|------|----------------|--------|
| (Add your strategic agents) | | | |

### Tactical Tier
| ID | Name | Responsibility | Status |
|----|------|----------------|--------|
| orchestrator | Orchestrator | Main routing and coordination | Active |
| librarian | Librarian | Document curation | Active |

### Operational Tier
| ID | Name | Responsibility | Status |
|----|------|----------------|--------|
| code-simplifier | Code Simplifier | Complexity reduction | Active |
| code-reviewer | Code Reviewer | Quality review | Active |
| repo-strategist | Repo Strategist | Structure alignment | Active |

## MECE Coverage

| Domain | Covered By | Gaps |
|--------|------------|------|
| Orchestration | orchestrator | - |
| Documentation | librarian | - |
| Code Quality | code-simplifier, code-reviewer | - |
| Structure | repo-strategist | - |

→ Add domain-specific agents as needed
AGENT_EOF

# ──────────────────────────────────────────────────────────────────────────────
# 7. Copy hooks
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${GREEN}Setting up hooks...${NC}"

cp "$PLUGIN_ROOT/hooks/scripts/"* scripts/hooks/ 2>/dev/null || true
chmod +x scripts/hooks/*.sh 2>/dev/null || true
chmod +x scripts/hooks/*.js 2>/dev/null || true

# ──────────────────────────────────────────────────────────────────────────────
# 8. Create start command
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${GREEN}Creating start command...${NC}"

cat > commands/start << 'START_EOF'
#!/bin/bash
# Boot up and show chance points

set -e
cd "$(dirname "$0")/.."

echo ""
echo "逆水行舟，不进则退"
echo "Like rowing upstream: no advance is to drop back"
echo ""

# State
TRUTH_COUNT=$(grep -c "^---$" .remembrance 2>/dev/null | awk '{print int($1/2)}' || echo "0")
SPRINT=$(grep "^sprint:" scrum/SCRUM.md 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' "' || echo "UNKNOWN")

echo "STATE:"
echo "  Sprint: $SPRINT"
echo "  Truths: $TRUTH_COUNT accumulated"
echo ""

echo "CHANCE POINTS:"
echo "  1. /loop continue  — Continue the loop"
echo "  2. /frame <name>   — Experience a principle"
echo "  3. /process <type> — Execute a workflow"
echo "  4. /loop shift     — Re-read remembrance"
echo ""

echo "İleri, daima ileri. 永远前进. Forward, always forward."
echo ""
START_EOF

chmod +x commands/start

# ──────────────────────────────────────────────────────────────────────────────
# Done
# ──────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}${PROJECT_NAME}${NC} initialized with meta-agentic-loop                          ${CYAN}║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  Created:                                                                 ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}    ${GREEN}✓${NC} CLAUDE.md (cockpit)                                                  ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}    ${GREEN}✓${NC} .remembrance (scoped memory)                                         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}    ${GREEN}✓${NC} scrum/ (essence-based)                                               ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}    ${GREEN}✓${NC} processes/ (workflows)                                               ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}    ${GREEN}✓${NC} .claude/agents/INDEX.md                                              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}    ${GREEN}✓${NC} commands/start (boot)                                                ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  Next:                                                                    ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}    1. Add domain-specific agents to .claude/agents/                       ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}    2. Define backlog items in scrum/artifacts/PRODUCT_BACKLOG.md          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}    3. Run: /start or ./commands/start                                     ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  İleri, daima ileri. 永远前进. Forward, always forward.                    ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
