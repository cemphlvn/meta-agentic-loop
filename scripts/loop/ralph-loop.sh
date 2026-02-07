#!/bin/bash
# Ralph Wiggum Loop — Non-stopping Claude Code runs
#
# Context7 Source: /anthropics/claude-code (Ralph Wiggum plugin)
#
# "Ralph is a Bash loop" — Geoffrey Huntley
#
# Usage:
#   ./ralph-loop.sh "Your task" --max-iterations 50 --completion-promise "DONE"
#   ./ralph-loop.sh --continue   # Resume from state file
#   ./ralph-loop.sh --cancel     # Cancel active loop

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
RALPH_STATE_FILE="${PROJECT_ROOT}/.claude/ralph-loop.local.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log() { echo -e "${BLUE}[RALPH]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

# Parse arguments
PROMPT=""
MAX_ITERATIONS=0
COMPLETION_PROMISE=""
CONTINUE_MODE=false
CANCEL_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --completion-promise)
            COMPLETION_PROMISE="$2"
            shift 2
            ;;
        --continue)
            CONTINUE_MODE=true
            shift
            ;;
        --cancel)
            CANCEL_MODE=true
            shift
            ;;
        *)
            PROMPT="$1"
            shift
            ;;
    esac
done

# Cancel mode
if [[ "$CANCEL_MODE" == "true" ]]; then
    if [[ -f "$RALPH_STATE_FILE" ]]; then
        rm "$RALPH_STATE_FILE"
        success "Ralph loop cancelled"
    else
        warn "No active Ralph loop"
    fi
    exit 0
fi

# Continue mode
if [[ "$CONTINUE_MODE" == "true" ]]; then
    if [[ ! -f "$RALPH_STATE_FILE" ]]; then
        warn "No active Ralph loop to continue"
        exit 1
    fi
    log "Continuing Ralph loop..."
else
    # Initialize new loop
    if [[ -z "$PROMPT" ]]; then
        echo "Ralph Wiggum Loop — Non-stopping Claude Code"
        echo ""
        echo "Usage: $(basename "$0") \"Task description\" [options]"
        echo ""
        echo "Options:"
        echo "  --max-iterations N      Stop after N iterations (0 = unlimited)"
        echo "  --completion-promise S  Stop when Claude outputs <promise>S</promise>"
        echo "  --continue              Resume from state file"
        echo "  --cancel                Cancel active loop"
        echo ""
        echo "Examples:"
        echo "  $0 \"Implement all tests\" --max-iterations 20"
        echo "  $0 \"Build REST API\" --completion-promise \"COMPLETE\""
        echo ""
        exit 0
    fi

    # Create state file
    mkdir -p "$(dirname "$RALPH_STATE_FILE")"
    cat > "$RALPH_STATE_FILE" << EOF
---
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: "$COMPLETION_PROMISE"
started_at: "$(date -Iseconds)"
---

# Ralph Loop Task

$PROMPT

---

## Instructions

Work on this task iteratively. After each iteration:
- Check your progress against the goal
- Commit meaningful changes
- If task complete, output: <promise>${COMPLETION_PROMISE:-COMPLETE}</promise>

The loop will continue until:
- You output the completion promise tag
- Max iterations reached ($MAX_ITERATIONS, 0 = unlimited)
- Loop is cancelled

不进则退 — No advance is to drop back
EOF

    success "Ralph loop initialized"
    log "State file: $RALPH_STATE_FILE"
    log "Max iterations: $MAX_ITERATIONS (0 = unlimited)"
    log "Completion promise: ${COMPLETION_PROMISE:-COMPLETE}"
fi

# The core Ralph loop
log "Starting Ralph loop..."
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  RALPH WIGGUM LOOP — Non-stopping Claude Code                 ║"
echo "║  Press Ctrl+C to interrupt (loop can be resumed)              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

cd "$PROJECT_ROOT"

while true; do
    # Check if state file still exists
    if [[ ! -f "$RALPH_STATE_FILE" ]]; then
        warn "State file removed — loop cancelled"
        break
    fi

    # Parse current iteration
    ITERATION=$(sed -n 's/^iteration: *//p' "$RALPH_STATE_FILE" | head -1)
    MAX=$(sed -n 's/^max_iterations: *//p' "$RALPH_STATE_FILE" | head -1)

    # Check max iterations
    if [[ "$MAX" -gt 0 ]] && [[ "$ITERATION" -ge "$MAX" ]]; then
        success "Max iterations ($MAX) reached"
        rm "$RALPH_STATE_FILE"
        break
    fi

    log "Iteration $ITERATION"

    # Feed prompt to Claude with --continue flag
    # The --continue flag tells Claude to continue the conversation
    if command -v claude >/dev/null 2>&1; then
        cat "$RALPH_STATE_FILE" | claude --continue 2>&1 | tee -a "${PROJECT_ROOT}/.ralph-output.log"
        CLAUDE_EXIT=$?
    else
        warn "Claude CLI not found"
        break
    fi

    # Check for completion promise in output
    if [[ -f "${PROJECT_ROOT}/.ralph-output.log" ]]; then
        PROMISE=$(sed -n 's/^completion_promise: *"\(.*\)"$/\1/p' "$RALPH_STATE_FILE" | head -1)
        if [[ -n "$PROMISE" ]] && grep -q "<promise>$PROMISE</promise>" "${PROJECT_ROOT}/.ralph-output.log" 2>/dev/null; then
            success "Completion promise satisfied: $PROMISE"
            rm "$RALPH_STATE_FILE"
            break
        fi
    fi

    # Increment iteration
    NEXT=$((ITERATION + 1))
    sed -i.bak "s/^iteration: .*/iteration: $NEXT/" "$RALPH_STATE_FILE"
    rm -f "${RALPH_STATE_FILE}.bak"

    # Brief pause between iterations
    sleep 2
done

success "Ralph loop complete"
