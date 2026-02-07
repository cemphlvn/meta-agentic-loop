#!/usr/bin/env bash
# HITL Session Spawner — Dedicated sessions for Human-In-The-Loop tasks
#
# When a task requires human input, this spawns a dedicated tmux/screen session
# instead of blocking the main loop.
#
# Usage:
#   ./hitl-session.sh spawn "Task description" "ticket-id"
#   ./hitl-session.sh list                    # List active HITL sessions
#   ./hitl-session.sh attach <session-id>     # Attach to session
#   ./hitl-session.sh resolve <session-id>    # Mark HITL resolved

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HITL_DIR="${PROJECT_ROOT}/.hitl-sessions"
LOOP_STATE="${PROJECT_ROOT}/.loop-state.yaml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log() { echo -e "${BLUE}[HITL]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Ensure HITL directory exists
mkdir -p "$HITL_DIR"

# Generate session ID
gen_session_id() {
    echo "hitl-$(date +%Y%m%d-%H%M%S)-$$"
}

# Check if tmux is available
has_tmux() {
    command -v tmux >/dev/null 2>&1
}

# Check if screen is available
has_screen() {
    command -v screen >/dev/null 2>&1
}

# Spawn a dedicated HITL session
spawn_session() {
    local description="$1"
    local ticket="${2:-HITL-UNKNOWN}"
    local session_id=$(gen_session_id)
    local session_file="${HITL_DIR}/${session_id}.yaml"

    log "Creating HITL session: $session_id"
    log "Description: $description"
    log "Ticket: $ticket"

    # Create session metadata
    cat > "$session_file" << EOF
# HITL Session — Awaiting human input
session_id: $session_id
ticket: $ticket
description: "$description"
created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
status: pending
resolved_at: null
resolution: null
EOF

    # Create session prompt file
    local prompt_file="${HITL_DIR}/${session_id}.prompt"
    cat > "$prompt_file" << EOF
# HITL Session: $session_id
# Ticket: $ticket

## Task Requiring Human Input

$description

## Context

This session was spawned because the main loop encountered a task
requiring human decision-making. The main loop continues in parallel.

## To Resolve

1. Complete the required decision/input
2. Run: ./scripts/hitl-session.sh resolve $session_id
3. The main loop will pick up from here

## Commands Available

/hitl status    — Show this session's status
/hitl complete  — Mark as complete and return to main loop

---
Please provide the required input:
EOF

    # Spawn terminal session
    if has_tmux; then
        # Create tmux session
        tmux new-session -d -s "$session_id" -c "$PROJECT_ROOT" \
            "claude --print \"$(cat "$prompt_file")\"; read -p 'Session complete. Press Enter to close.'"

        success "Tmux session created: $session_id"
        echo ""
        echo "  To attach: tmux attach -t $session_id"
        echo "  To list:   tmux ls"
        echo ""

    elif has_screen; then
        # Create screen session
        screen -dmS "$session_id" bash -c \
            "cd '$PROJECT_ROOT' && claude --print \"$(cat "$prompt_file")\"; read -p 'Press Enter to close.'"

        success "Screen session created: $session_id"
        echo ""
        echo "  To attach: screen -r $session_id"
        echo "  To list:   screen -ls"
        echo ""

    else
        # No terminal multiplexer — just create the session file
        warn "No tmux or screen available — session created but not attached"
        echo ""
        echo "  Session file: $session_file"
        echo "  Prompt file: $prompt_file"
        echo ""
        echo "  To continue manually:"
        echo "  cd $PROJECT_ROOT && claude < $prompt_file"
        echo ""
    fi

    # Update main loop state to indicate HITL spawned (not blocked)
    if [[ -f "$LOOP_STATE" ]]; then
        # Add HITL session reference
        if ! grep -q "hitl_sessions:" "$LOOP_STATE"; then
            echo "" >> "$LOOP_STATE"
            echo "hitl_sessions:" >> "$LOOP_STATE"
        fi
        echo "  - $session_id" >> "$LOOP_STATE"
    fi

    echo "$session_id"
}

# List active HITL sessions
list_sessions() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    ACTIVE HITL SESSIONS                       ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    local count=0
    for session_file in "$HITL_DIR"/*.yaml 2>/dev/null; do
        [[ -f "$session_file" ]] || continue

        local session_id=$(basename "$session_file" .yaml)
        local status=$(grep "status:" "$session_file" | cut -d: -f2- | tr -d ' ')
        local description=$(grep "description:" "$session_file" | cut -d: -f2- | tr -d '"')
        local ticket=$(grep "ticket:" "$session_file" | cut -d: -f2- | tr -d ' ')

        if [[ "$status" == "pending" ]]; then
            echo -e "  ${YELLOW}●${NC} $session_id"
        else
            echo -e "  ${GREEN}●${NC} $session_id"
        fi
        echo -e "    Ticket: $ticket"
        echo -e "    Status: $status"
        echo -e "    Task: $description"
        echo ""

        ((count++)) || true
    done

    if [[ $count -eq 0 ]]; then
        echo "  No active HITL sessions"
    fi

    echo ""
}

# Resolve a HITL session
resolve_session() {
    local session_id="$1"
    local session_file="${HITL_DIR}/${session_id}.yaml"

    if [[ ! -f "$session_file" ]]; then
        error "Session not found: $session_id"
        exit 1
    fi

    log "Resolving session: $session_id"

    # Update session status
    sed -i.bak "s/^status: pending/status: resolved/" "$session_file"
    echo "resolved_at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$session_file"
    rm -f "${session_file}.bak"

    # Remove from loop state
    if [[ -f "$LOOP_STATE" ]]; then
        sed -i.bak "/$session_id/d" "$LOOP_STATE"
        rm -f "${LOOP_STATE}.bak"
    fi

    # Kill tmux/screen session if running
    if has_tmux && tmux has-session -t "$session_id" 2>/dev/null; then
        tmux kill-session -t "$session_id"
    elif has_screen && screen -list | grep -q "$session_id"; then
        screen -X -S "$session_id" quit
    fi

    success "Session resolved: $session_id"
    log "Main loop will continue from here"
}

# Attach to a session
attach_session() {
    local session_id="$1"

    if has_tmux && tmux has-session -t "$session_id" 2>/dev/null; then
        tmux attach -t "$session_id"
    elif has_screen && screen -list | grep -q "$session_id"; then
        screen -r "$session_id"
    else
        error "Session not found or not running: $session_id"
        exit 1
    fi
}

# CLI
case "${1:-}" in
    spawn)
        spawn_session "${2:-HITL task}" "${3:-HITL-000}"
        ;;
    list)
        list_sessions
        ;;
    attach)
        if [[ -z "${2:-}" ]]; then
            error "Session ID required"
            echo "Usage: $0 attach <session-id>"
            exit 1
        fi
        attach_session "$2"
        ;;
    resolve)
        if [[ -z "${2:-}" ]]; then
            error "Session ID required"
            echo "Usage: $0 resolve <session-id>"
            exit 1
        fi
        resolve_session "$2"
        ;;
    *)
        echo "HITL Session Spawner — Dedicated sessions for human input"
        echo ""
        echo "Usage: $(basename "$0") <command> [args]"
        echo ""
        echo "Commands:"
        echo "  spawn <description> [ticket]  Spawn new HITL session"
        echo "  list                          List active sessions"
        echo "  attach <session-id>           Attach to session"
        echo "  resolve <session-id>          Mark session resolved"
        echo ""
        echo "HITL sessions run in parallel to the main loop."
        echo "The main loop continues while awaiting human input."
        ;;
esac
