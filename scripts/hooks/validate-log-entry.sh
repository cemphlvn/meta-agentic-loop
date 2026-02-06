#!/usr/bin/env bash
# Validate Log Entry Format
# CTO-enforced: All logs must include observed + reasoning + ticket

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_file="$1"
entry_content="${2:-}"

# If entry content not provided, read from stdin
if [[ -z "$entry_content" ]]; then
    entry_content=$(cat)
fi

errors=()
warnings=()

# Required fields
required_fields=("timestamp" "agent" "observed" "reasoning")

for field in "${required_fields[@]}"; do
    if ! echo "$entry_content" | grep -q "^${field}:"; then
        errors+=("Missing required field: $field")
    fi
done

# Check for ticket reference (required for non-system entries)
if ! echo "$entry_content" | grep -q "^ticket:"; then
    agent=$(echo "$entry_content" | grep "^agent:" | cut -d: -f2 | tr -d ' ')
    if [[ "$agent" != "system" ]]; then
        warnings+=("Missing ticket reference (required for non-system entries)")
    fi
fi

# Check observed field has content
observed=$(echo "$entry_content" | sed -n '/^observed:/,/^[a-z]*:/p' | head -n -1 | tail -n +2)
if [[ -z "$observed" || "$observed" =~ ^[[:space:]]*$ ]]; then
    errors+=("'observed' field is empty - must describe what was noticed")
fi

# Check reasoning field has content
reasoning=$(echo "$entry_content" | sed -n '/^reasoning:/,/^[a-z]*:/p' | head -n -1 | tail -n +2)
if [[ -z "$reasoning" || "$reasoning" =~ ^[[:space:]]*$ ]]; then
    errors+=("'reasoning' field is empty - must explain why action was taken")
fi

# Check confidence is present and valid
if echo "$entry_content" | grep -q "^confidence:"; then
    confidence=$(echo "$entry_content" | grep "^confidence:" | cut -d: -f2 | tr -d ' ')
    if ! [[ "$confidence" =~ ^[0-1](\.[0-9]+)?$ ]]; then
        errors+=("'confidence' must be between 0.0 and 1.0")
    fi
fi

# Output results
if [[ ${#errors[@]} -gt 0 ]]; then
    echo -e "${RED}[INVALID]${NC} Log entry validation failed:"
    for error in "${errors[@]}"; do
        echo -e "  ${RED}✗${NC} $error"
    done
    exit 1
fi

if [[ ${#warnings[@]} -gt 0 ]]; then
    echo -e "${YELLOW}[WARN]${NC} Log entry has warnings:"
    for warning in "${warnings[@]}"; do
        echo -e "  ${YELLOW}!${NC} $warning"
    done
fi

echo -e "${GREEN}[VALID]${NC} Log entry format correct"
exit 0
