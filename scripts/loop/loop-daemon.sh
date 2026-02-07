#!/usr/bin/env bash
# Loop Daemon — Auto-continuation without human prompting
#
# "逆水行舟，不进则退" — Like rowing upstream: no advance is to drop back
#
# This daemon monitors loop state and invokes Claude when needed.
# It's the bridge between "Claude can't invoke Claude" and "loop never stops".
#
# Usage:
#   ./loop-daemon.sh start      # Start daemon in background
#   ./loop-daemon.sh stop       # Stop daemon
#   ./loop-daemon.sh status     # Check if running
#   ./loop-daemon.sh foreground # Run in foreground (for debugging)
#
# Requirements:
#   - Claude CLI must be in PATH
#   - Project must have .loop-state.yaml
#
# HITL Mode:
#   When a task requires human input, daemon pauses and notifies.
#   Set LOOP_HITL_REQUIRED=true in .loop-state.yaml to trigger.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Config
LOOP_STATE="${PROJECT_ROOT}/.loop-state.yaml"
PID_FILE="${PROJECT_ROOT}/.loop-daemon.pid"
LOG_FILE="${PROJECT_ROOT}/.loop-daemon.log"
CHECK_INTERVAL=30  # seconds between checks
MAX_IDLE_MINUTES=5  # auto-continue if idle this long
CLAUDE_CMD="claude"  # or path to claude

# Colors (for foreground mode)
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" >> "$LOG_FILE"
    if [[ "${FOREGROUND:-false}" == "true" ]]; then
        echo -e "${BLUE}[DAEMON]${NC} $1"
    fi
}

warn() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $1"
    echo "$msg" >> "$LOG_FILE"
    if [[ "${FOREGROUND:-false}" == "true" ]]; then
        echo -e "${YELLOW}[WARN]${NC} $1"
    fi
}

error() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$msg" >> "$LOG_FILE"
    if [[ "${FOREGROUND:-false}" == "true" ]]; then
        echo -e "${RED}[ERROR]${NC} $1"
    fi
}

# Check if daemon is running
is_running() {
    if [[ -f "$PID_FILE" ]]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Get value from loop state
get_state() {
    local field="$1"
    grep "${field}:" "$LOOP_STATE" 2>/dev/null | head -1 | cut -d: -f2- | tr -d ' "' || echo ""
}

# Check if HITL is required
needs_hitl() {
    local hitl=$(grep "hitl_required:" "$LOOP_STATE" 2>/dev/null | head -1 | cut -d: -f2- | tr -d ' ')
    [[ "$hitl" == "true" ]]
}

# Get last modification time of loop state (seconds since epoch)
get_state_mtime() {
    if [[ "$(uname)" == "Darwin" ]]; then
        stat -f %m "$LOOP_STATE" 2>/dev/null || echo "0"
    else
        stat -c %Y "$LOOP_STATE" 2>/dev/null || echo "0"
    fi
}

# Check if Claude is currently running
claude_running() {
    pgrep -f "claude" >/dev/null 2>&1
}

# Notify user (cross-platform)
notify_user() {
    local title="$1"
    local message="$2"

    if command -v osascript >/dev/null 2>&1; then
        # macOS
        osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
    elif command -v notify-send >/dev/null 2>&1; then
        # Linux
        notify-send "$title" "$message" 2>/dev/null || true
    fi

    log "NOTIFICATION: $title - $message"
}

# Invoke Claude to continue the loop
invoke_claude() {
    local prompt="$1"
    log "Invoking Claude: $prompt"

    # Check if Claude CLI exists
    if ! command -v "$CLAUDE_CMD" >/dev/null 2>&1; then
        error "Claude CLI not found in PATH"
        return 1
    fi

    # Run Claude in the project directory
    cd "$PROJECT_ROOT"

    # Use --print to avoid interactive mode for simple continuation
    # The prompt tells Claude to continue the loop
    "$CLAUDE_CMD" --print "$prompt" >> "$LOG_FILE" 2>&1 &

    log "Claude invoked with PID $!"
}

# Main daemon loop
daemon_loop() {
    log "Daemon starting..."
    log "Project: $PROJECT_ROOT"
    log "Check interval: ${CHECK_INTERVAL}s"
    log "Max idle: ${MAX_IDLE_MINUTES}m"

    local last_mtime=0
    local idle_checks=0
    local max_idle_checks=$((MAX_IDLE_MINUTES * 60 / CHECK_INTERVAL))

    while true; do
        # Check if loop state exists
        if [[ ! -f "$LOOP_STATE" ]]; then
            warn "No loop state file — waiting..."
            sleep "$CHECK_INTERVAL"
            continue
        fi

        # Check if Claude is already running
        if claude_running; then
            log "Claude is active — waiting..."
            idle_checks=0
            sleep "$CHECK_INTERVAL"
            continue
        fi

        # Check for HITL requirement
        if needs_hitl; then
            notify_user "Loop: HITL Required" "Human input needed to continue"
            log "HITL required — pausing daemon loop"
            sleep "$CHECK_INTERVAL"
            continue
        fi

        # Check loop state modification
        local current_mtime=$(get_state_mtime)

        if [[ "$current_mtime" == "$last_mtime" ]]; then
            # State hasn't changed — count idle
            ((idle_checks++)) || true

            if [[ $idle_checks -ge $max_idle_checks ]]; then
                # Idle for too long — auto-continue
                local phase=$(get_state "phase")
                log "Idle for ${MAX_IDLE_MINUTES}m, phase: $phase — auto-continuing"

                invoke_claude "Continue the loop. Current phase: $phase. 不进则退 — no stopping."

                idle_checks=0
                sleep 10  # Wait for Claude to start
            fi
        else
            # State changed — reset idle counter
            idle_checks=0
            last_mtime=$current_mtime

            local phase=$(get_state "phase")
            log "State updated, phase: $phase"

            # Check if phase indicates completion without continuation
            if [[ "$phase" == "CONTINUE" ]]; then
                log "Phase is CONTINUE but Claude not running — triggering"
                invoke_claude "The loop is in CONTINUE phase but stopped. Continue to next iteration. 不进则退"
                sleep 10
            fi
        fi

        sleep "$CHECK_INTERVAL"
    done
}

# Start daemon in background
start_daemon() {
    if is_running; then
        echo "Daemon already running (PID: $(cat "$PID_FILE"))"
        exit 1
    fi

    echo "Starting loop daemon..."

    # Run in background
    nohup "$0" foreground >> "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"

    echo "Daemon started (PID: $!)"
    echo "Log: $LOG_FILE"
}

# Stop daemon
stop_daemon() {
    if ! is_running; then
        echo "Daemon not running"
        exit 0
    fi

    local pid=$(cat "$PID_FILE")
    echo "Stopping daemon (PID: $pid)..."
    kill "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
    echo "Daemon stopped"
}

# Show status
show_status() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                      LOOP DAEMON STATUS                       ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    if is_running; then
        local pid=$(cat "$PID_FILE")
        echo -e "  Status:    ${GREEN}RUNNING${NC} (PID: $pid)"
    else
        echo -e "  Status:    ${RED}STOPPED${NC}"
    fi

    if [[ -f "$LOOP_STATE" ]]; then
        local phase=$(get_state "phase")
        local timestamp=$(get_state "timestamp")
        echo -e "  Phase:     $phase"
        echo -e "  Updated:   $timestamp"

        if needs_hitl; then
            echo -e "  HITL:      ${YELLOW}REQUIRED${NC}"
        else
            echo -e "  HITL:      ${GREEN}Not needed${NC}"
        fi
    else
        echo "  Loop state: Not found"
    fi

    if [[ -f "$LOG_FILE" ]]; then
        echo ""
        echo "  Last 5 log entries:"
        tail -5 "$LOG_FILE" | sed 's/^/    /'
    fi

    echo ""
}

# CLI
case "${1:-}" in
    start)
        start_daemon
        ;;
    stop)
        stop_daemon
        ;;
    status)
        show_status
        ;;
    foreground)
        FOREGROUND=true
        daemon_loop
        ;;
    restart)
        stop_daemon
        sleep 1
        start_daemon
        ;;
    *)
        echo "Loop Daemon — Auto-continuation for Claude Code"
        echo ""
        echo "Usage: $(basename "$0") <command>"
        echo ""
        echo "Commands:"
        echo "  start       Start daemon in background"
        echo "  stop        Stop daemon"
        echo "  status      Show daemon status"
        echo "  foreground  Run in foreground (for debugging)"
        echo "  restart     Stop and start daemon"
        echo ""
        echo "The daemon monitors .loop-state.yaml and invokes Claude"
        echo "when the loop has been idle for ${MAX_IDLE_MINUTES} minutes."
        echo ""
        echo "不进则退 — No advance is to drop back"
        ;;
esac
