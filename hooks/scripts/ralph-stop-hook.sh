#!/bin/bash
# Ralph Stop Hook — Blocks exit and continues loop
#
# Context7 Source: /anthropics/claude-code (Ralph Wiggum plugin)
#
# This hook intercepts Claude's exit attempts and feeds the same prompt back,
# creating a continuous self-referential feedback loop.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(dirname "$PLUGIN_ROOT")}"
RALPH_STATE_FILE="${PROJECT_ROOT}/.claude/ralph-loop.local.md"

# Quick exit if no active loop
if [[ ! -f "$RALPH_STATE_FILE" ]]; then
    exit 0
fi

# Parse frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$RALPH_STATE_FILE" 2>/dev/null || echo "")

# Extract configuration
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//' || echo "1")
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//' || echo "0")
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/' || echo "")

# Check max iterations
if [[ "$MAX_ITERATIONS" -gt 0 ]] && [[ "$ITERATION" -ge "$MAX_ITERATIONS" ]]; then
    echo "🛑 Ralph loop: Max iterations ($MAX_ITERATIONS) reached." >&2
    rm -f "$RALPH_STATE_FILE"
    exit 0
fi

# Get transcript path from hook input
TRANSCRIPT_PATH=""
if [[ -n "${HOOK_INPUT:-}" ]]; then
    TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")
fi

# Check for completion promise in last output
if [[ -n "$COMPLETION_PROMISE" ]] && [[ -n "$TRANSCRIPT_PATH" ]] && [[ -f "$TRANSCRIPT_PATH" ]]; then
    LAST_OUTPUT=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" 2>/dev/null | tail -1 | jq -r '.message.content | map(select(.type == "text")) | map(.text) | join("\n")' 2>/dev/null || echo "")

    if echo "$LAST_OUTPUT" | grep -q "<promise>$COMPLETION_PROMISE</promise>"; then
        echo "✅ Ralph loop: Completion promise satisfied!" >&2
        rm -f "$RALPH_STATE_FILE"
        exit 0
    fi
fi

# Extract the prompt (everything after frontmatter)
PROMPT_TEXT=$(sed '1,/^---$/d' "$RALPH_STATE_FILE" | sed '1,/^---$/d' 2>/dev/null || cat "$RALPH_STATE_FILE")

# Increment iteration
NEXT_ITERATION=$((ITERATION + 1))
sed -i.bak "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$RALPH_STATE_FILE" 2>/dev/null || true
rm -f "${RALPH_STATE_FILE}.bak"

# Block exit and return loop continuation decision
# This is the key mechanism: we block the stop and feed the prompt back
if command -v jq >/dev/null 2>&1; then
    jq -n \
        --arg prompt "$PROMPT_TEXT" \
        --arg msg "🔄 Ralph iteration $NEXT_ITERATION" \
        '{
            "decision": "block",
            "reason": $prompt,
            "systemMessage": $msg
        }'
else
    # Fallback without jq
    cat << EOF
{
    "decision": "block",
    "reason": "Continue working on the task. Iteration $NEXT_ITERATION.",
    "systemMessage": "🔄 Ralph iteration $NEXT_ITERATION"
}
EOF
fi

exit 0
