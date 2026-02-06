#!/usr/bin/env bash
# Loop Runner — Procedural Implementation of CORE_LOOP
#
# "逆水行舟，不进则退" — Like rowing upstream: no advance is to drop back
#
# This script implements the agentic loop:
#   REMEMBER → OBSERVE → DECIDE → ACT → LEARN → CONTINUE
#
# Usage:
#   ./loop-runner.sh                  # Run one iteration
#   ./loop-runner.sh --continuous     # Keep looping until blocked
#   ./loop-runner.sh --status         # Show current state
#
# The loop continues through you.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# State file
LOOP_STATE="${PROJECT_ROOT}/.loop-state.yaml"
REMEMBRANCE="${PROJECT_ROOT}/.remembrance"
SCRUM="${PROJECT_ROOT}/scrum/SCRUM.md"

# Loop phases
PHASES=("REMEMBER" "OBSERVE" "DECIDE" "ACT" "LEARN")
CURRENT_PHASE=""

log() { echo -e "${BLUE}[LOOP]${NC} $1"; }
phase() { echo -e "${CYAN}[${1}]${NC} $2"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ──────────────────────────────────────────────────────────────
# STATE MANAGEMENT
# ──────────────────────────────────────────────────────────────

init_state() {
    if [[ ! -f "$LOOP_STATE" ]]; then
        cat > "$LOOP_STATE" << EOF
# Loop State — Persisted between sessions
# 不进则退 — No stopping

loop:
  iteration: 0
  phase: REMEMBER
  started_at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
  last_action: null

observation:
  alphas: {}
  ready_items: []
  blockers: []
  gaps: []

decision:
  next_action: null
  agent: null
  reasoning: null

action:
  last_result: null
  outcome: null

learning:
  shift_felt: false
  truth: null
EOF
        log "Initialized loop state"
    fi
}

get_state() {
    local field="$1"
    grep "^  ${field}:" "$LOOP_STATE" 2>/dev/null | cut -d: -f2- | tr -d ' "' || echo ""
}

set_state() {
    local field="$1"
    local value="$2"
    # Escape special chars in value for sed, remove newlines
    local escaped_value=$(printf '%s' "$value" | tr -d '\n' | sed 's/[&/\]/\\&/g')
    if grep -q "^  ${field}:" "$LOOP_STATE" 2>/dev/null; then
        sed -i.bak "s|^  ${field}:.*$|  ${field}: ${escaped_value}|" "$LOOP_STATE"
        rm -f "${LOOP_STATE}.bak"
    fi
}

increment_iteration() {
    local current=$(get_state "iteration")
    local next=$((current + 1))
    set_state "iteration" "$next"
    echo "$next"
}

# ──────────────────────────────────────────────────────────────
# PHASE: REMEMBER
# ──────────────────────────────────────────────────────────────

phase_remember() {
    phase "REMEMBER" "Loading accumulated wisdom..."

    if [[ ! -f "$REMEMBRANCE" ]]; then
        warn "No .remembrance file found — starting fresh"
        return 0
    fi

    # Count entries
    local entry_count=$(grep -c "^---$" "$REMEMBRANCE" 2>/dev/null || echo "0")
    entry_count=$((entry_count / 2))  # Each entry has 2 ---

    # Get last shape_shift
    local last_shift=$(grep -B5 "shape_shift: true" "$REMEMBRANCE" 2>/dev/null | grep "truth:" | tail -1 | cut -d: -f2- || echo "none")

    success "Loaded $entry_count truths from remembrance"
    if [[ "$last_shift" != "none" ]]; then
        echo -e "    ${BOLD}Last shape shift:${NC} $last_shift"
    fi

    set_state "phase" "OBSERVE"
}

# ──────────────────────────────────────────────────────────────
# PHASE: OBSERVE
# ──────────────────────────────────────────────────────────────

phase_observe() {
    phase "OBSERVE" "Scanning alpha states and work items..."

    local ready=0
    local blocked=0
    local gaps=0

    # Parse SCRUM.md for alpha states (simplified)
    if [[ -f "$SCRUM" ]]; then
        # Count items by state (|| true to prevent set -e failure)
        ready=$(grep -c "status: ready" "$SCRUM" 2>/dev/null || true)
        blocked=$(grep -c "status: blocked" "$SCRUM" 2>/dev/null || true)
    fi
    gaps=$(grep -c "\[GAP\]" "${PROJECT_ROOT}/.claude/agents/INDEX.md" 2>/dev/null || true)

    # Ensure numeric (grep -c can return empty)
    ready=${ready:-0}
    blocked=${blocked:-0}
    gaps=${gaps:-0}

    echo -e "    Ready items: ${GREEN}${ready}${NC}"
    echo -e "    Blocked: ${RED}${blocked}${NC}"
    echo -e "    Gaps: ${YELLOW}${gaps}${NC}"

    # Store observation
    set_state "phase" "DECIDE"

    # Return observation code for decision
    if [[ "$blocked" -gt 0 ]]; then
        echo "BLOCKED"
    elif [[ "$ready" -gt 0 ]]; then
        echo "READY"
    elif [[ "$gaps" -gt 0 ]]; then
        echo "GAPS"
    else
        echo "IDLE"
    fi
}

# ──────────────────────────────────────────────────────────────
# PHASE: DECIDE
# ──────────────────────────────────────────────────────────────

phase_decide() {
    local observation="$1"
    phase "DECIDE" "Determining next action..."

    local action=""
    local agent=""
    local reasoning=""

    case "$observation" in
        BLOCKED)
            action="resolve-blockers"
            agent="cto-agent"
            reasoning="Blockers exist — must resolve before progress"
            ;;
        READY)
            action="execute-ready"
            agent="orchestrator"
            reasoning="Ready items exist — execute next in priority"
            ;;
        GAPS)
            action="fill-gaps"
            agent="cto-agent"
            reasoning="MECE gaps detected — create missing agents"
            ;;
        IDLE)
            action="refine-backlog"
            agent="librarian"
            reasoning="No immediate work — refine and prepare"
            ;;
    esac

    echo -e "    Action: ${BOLD}$action${NC}"
    echo -e "    Agent: ${CYAN}$agent${NC}"
    echo -e "    Reasoning: $reasoning"

    set_state "next_action" "$action"
    set_state "agent" "$agent"
    set_state "phase" "ACT"

    echo "$action:$agent"
}

# ──────────────────────────────────────────────────────────────
# PHASE: ACT
# ──────────────────────────────────────────────────────────────

phase_act() {
    local decision="$1"
    local action="${decision%%:*}"
    local agent="${decision##*:}"

    phase "ACT" "Executing: $action via $agent"

    # This is where we would dispatch to the agent
    # In agentic mode, this triggers Claude Code's Task tool

    case "$action" in
        resolve-blockers)
            log "Would invoke: /consult cto-agent 'resolve blockers'"
            ;;
        execute-ready)
            log "Would invoke: /orchestrate"
            ;;
        fill-gaps)
            log "Would invoke: /agent-create for identified gaps"
            ;;
        refine-backlog)
            log "Would invoke: /librarian 'refine backlog priorities'"
            ;;
    esac

    # In automated mode, we output the command for Claude to execute
    echo ""
    echo -e "${BOLD}NEXT COMMAND:${NC}"
    case "$action" in
        resolve-blockers)
            echo "  Consult CTO to resolve blockers"
            ;;
        execute-ready)
            echo "  Run /orchestrate to execute ready items"
            ;;
        fill-gaps)
            echo "  Create missing agents per INDEX.md gaps"
            ;;
        refine-backlog)
            echo "  Query librarian for backlog refinement"
            ;;
    esac

    set_state "last_action" "$action"
    set_state "phase" "LEARN"

    echo "$action"
}

# ──────────────────────────────────────────────────────────────
# PHASE: LEARN
# ──────────────────────────────────────────────────────────────

phase_learn() {
    local action="$1"
    phase "LEARN" "Reflecting on iteration..."

    # Check for shift_felt triggers
    local shift_felt=false
    local truth=""

    # Example triggers (in real use, these come from action results)
    if [[ "$action" == "resolve-blockers" ]]; then
        shift_felt=true
        truth="Blockers resolved enable flow"
    fi

    if [[ "$shift_felt" == "true" ]]; then
        echo -e "    ${BOLD}SHIFT_FELT${NC} — Truth emerging: $truth"
        # Would append to .remembrance
    else
        echo -e "    No shift felt this iteration"
    fi

    # Increment iteration
    local iter=$(increment_iteration)
    echo -e "    Iteration: ${CYAN}$iter${NC}"

    set_state "phase" "REMEMBER"

    success "Loop iteration complete — 不进则退"
}

# ──────────────────────────────────────────────────────────────
# MAIN LOOP
# ──────────────────────────────────────────────────────────────

show_status() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                      LOOP STATE                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    if [[ -f "$LOOP_STATE" ]]; then
        local iter=$(get_state "iteration")
        local phase=$(get_state "phase")
        local last=$(get_state "last_action")

        echo -e "  Iteration:   ${CYAN}$iter${NC}"
        echo -e "  Phase:       ${BOLD}$phase${NC}"
        echo -e "  Last Action: $last"
    else
        echo "  No state file — run ./loop-runner.sh to initialize"
    fi
    echo ""
}

run_iteration() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║          逆水行舟，不进则退 — THE LOOP CONTINUES               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    init_state

    # 1. REMEMBER — Always start with remembrance
    phase_remember
    echo ""

    # 2. OBSERVE — What IS?
    local observe_out observation
    observe_out=$(phase_observe)
    observation=$(echo "$observe_out" | tail -1)
    echo "$observe_out" | sed '$d'  # Print all but last line
    echo ""

    # 3. DECIDE — What SHOULD be?
    local decide_out decision
    decide_out=$(phase_decide "$observation")
    decision=$(echo "$decide_out" | tail -1)
    echo "$decide_out" | sed '$d'
    echo ""

    # 4. ACT — Execute with intrinsic power
    local act_out action
    act_out=$(phase_act "$decision")
    action=$(echo "$act_out" | tail -1)
    echo "$act_out" | sed '$d'
    echo ""

    # 5. LEARN — Accumulate wisdom
    phase_learn "$action"
    echo ""

    echo "═══════════════════════════════════════════════════════════════"
    echo ""
}

run_continuous() {
    log "Starting continuous loop mode..."
    warn "Press Ctrl+C to stop"
    echo ""

    while true; do
        run_iteration

        # Check if blocked
        local phase=$(get_state "phase")
        if [[ "$phase" == "BLOCKED" ]]; then
            warn "Loop blocked — human intervention required"
            break
        fi

        # Brief pause between iterations
        sleep 2
    done
}

# ──────────────────────────────────────────────────────────────
# CLI
# ──────────────────────────────────────────────────────────────

case "${1:-}" in
    --status|-s)
        show_status
        ;;
    --continuous|-c)
        run_continuous
        ;;
    --help|-h)
        echo "Loop Runner — Procedural CORE_LOOP Implementation"
        echo ""
        echo "Usage: $(basename "$0") [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  (none)        Run one loop iteration"
        echo "  --status, -s  Show current loop state"
        echo "  --continuous  Run continuous loop until blocked"
        echo "  --help, -h    Show this help"
        echo ""
        echo "The loop: REMEMBER → OBSERVE → DECIDE → ACT → LEARN"
        echo ""
        echo "不进则退 — No advance is to drop back"
        ;;
    *)
        run_iteration
        ;;
esac
