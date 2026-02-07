#!/bin/bash
# Playground Context Injection
# Injects higher-order context at SessionStart
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Read loop state
if [ -f "${PROJECT_DIR}/.loop-state.yaml" ]; then
    LOOP_PHASE=$(grep -oP 'phase:\s*\K\w+' "${PROJECT_DIR}/.loop-state.yaml" 2>/dev/null || echo "OBSERVE")
else
    LOOP_PHASE="OBSERVE"
fi

# Read compliance from latest audit
COMPLIANCE="N/A"
LATEST_AUDIT=$(find "${PROJECT_DIR}/.audit" -name "*.md" -type f 2>/dev/null | sort -r | head -1)
if [ -n "${LATEST_AUDIT}" ] && [ -f "${LATEST_AUDIT}" ]; then
    COMPLIANCE=$(grep -oP 'OVERALL\s+.*?(\d+)%' "${LATEST_AUDIT}" 2>/dev/null | grep -oP '\d+' | tail -1 || echo "N/A")
fi

# Count truths in remembrance
TRUTHS_COUNT=0
if [ -f "${PROJECT_DIR}/.remembrance" ]; then
    TRUTHS_COUNT=$(grep -c '^---$' "${PROJECT_DIR}/.remembrance" 2>/dev/null || echo "0")
    TRUTHS_COUNT=$((TRUTHS_COUNT / 2))
fi

# Get current sprint
SPRINT="N/A"
if [ -f "${PROJECT_DIR}/scrum/SCRUM.md" ]; then
    SPRINT=$(grep -oP 'sprint:\s*\K[A-Z0-9-]+' "${PROJECT_DIR}/scrum/SCRUM.md" 2>/dev/null || echo "N/A")
fi

# Get overdue items
OVERDUE_COUNT=0
TODAY=$(date +%Y-%m-%d)
if [ -f "${PROJECT_DIR}/scrum/ROADMAP.md" ]; then
    OVERDUE_COUNT=$(grep -P "^\| .+\| \d{4}-\d{2}-\d{2} \|" "${PROJECT_DIR}/scrum/ROADMAP.md" 2>/dev/null | \
        grep -v "DONE" | \
        awk -F'|' -v today="$TODAY" '{if ($5 < today) print}' | wc -l || echo "0")
fi

# Output context for Claude
cat << EOF
<playground-context>
loop_phase: ${LOOP_PHASE}
compliance_score: ${COMPLIANCE}%
truths_accumulated: ${TRUTHS_COUNT}
current_sprint: ${SPRINT}
overdue_items: ${OVERDUE_COUNT}
session_start: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
</playground-context>
EOF
