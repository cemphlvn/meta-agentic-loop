#!/bin/bash
# Hypothesis Tracker — Manage system hypotheses and tests
# Usage: hypothesis-tracker.sh [command] [args]
# Commands: list | new | test | approve | reject | report

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/../.."
HYP_DIR="${SCRIPT_DIR}/hypotheses"
TEST_DIR="${SCRIPT_DIR}/tests"
REPORT_DIR="${SCRIPT_DIR}/reports"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TODAY=$(date -u +%Y-%m-%d)

# Initialize directories
mkdir -p "$HYP_DIR" "$TEST_DIR" "$REPORT_DIR"

# Generate hypothesis ID
gen_hyp_id() {
    count=$(ls -1 "${HYP_DIR}"/HYP-*.yaml 2>/dev/null | wc -l | tr -d ' ')
    printf "HYP-%03d" "$((count + 1))"
}

# List all hypotheses
list_hypotheses() {
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║${NC}                    ${CYAN}HYPOTHESIS TRACKER${NC}                                      ${BOLD}║${NC}"
    echo -e "${BOLD}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"

    if ls "${HYP_DIR}"/HYP-*.yaml 1>/dev/null 2>&1; then
        echo -e "${BOLD}║${NC}                                                                            ${BOLD}║${NC}"
        echo -e "${BOLD}║${NC}  ${PURPLE}ID        STATUS      STATEMENT${NC}                                        ${BOLD}║${NC}"
        echo -e "${BOLD}║${NC}  ────────────────────────────────────────────────────────────────────────  ${BOLD}║${NC}"

        for file in "${HYP_DIR}"/HYP-*.yaml; do
            id=$(basename "$file" .yaml)
            status=$(grep "^status:" "$file" | sed 's/status: //')
            statement=$(grep "^  statement:" "$file" | sed 's/  statement: "//' | sed 's/"$//' | cut -c1-45)

            case "$status" in
                proposed) status_color="${YELLOW}" ;;
                testing) status_color="${CYAN}" ;;
                validated) status_color="${GREEN}" ;;
                rejected) status_color="${RED}" ;;
                implemented) status_color="${PURPLE}" ;;
                *) status_color="${NC}" ;;
            esac

            printf "${BOLD}║${NC}  %-9s ${status_color}%-11s${NC} %-45s ${BOLD}║${NC}\n" "$id" "$status" "$statement..."
        done
    else
        echo -e "${BOLD}║${NC}  ${DIM}No hypotheses yet. Create one with: /hypothesis new \"statement\"${NC}         ${BOLD}║${NC}"
    fi

    echo -e "${BOLD}║${NC}                                                                            ${BOLD}║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Create new hypothesis
new_hypothesis() {
    local statement="${1:-}"
    if [ -z "$statement" ]; then
        echo "Usage: hypothesis-tracker.sh new \"hypothesis statement\""
        exit 1
    fi

    local id=$(gen_hyp_id)
    local file="${HYP_DIR}/${id}.yaml"

    cat > "$file" << EOF
# Hypothesis ${id}
---
id: ${id}
created: ${NOW}
agent: system-scientist
status: proposed

hypothesis:
  statement: "${statement}"
  rationale: |
    [Describe why this hypothesis matters]

expected_outcome:
  metric: "[metric to measure]"
  threshold: "[expected value]"

test_protocol:
  method: "[correlation|threshold|trend|comparison]"
  data_source: "[where to get data]"
  interval: "[hourly|daily|weekly]"
  duration: "[test period]"

observations: []

conclusion: null
implementation: null
---
EOF

    echo -e "${GREEN}Created hypothesis:${NC} ${id}"
    echo -e "${DIM}File: ${file}${NC}"
    echo -e "${YELLOW}Next: Edit the file to complete the hypothesis definition${NC}"
}

# Run test for hypothesis
run_test() {
    local id="${1:-}"
    if [ -z "$id" ]; then
        echo "Usage: hypothesis-tracker.sh test HYP-XXX"
        exit 1
    fi

    local file="${HYP_DIR}/${id}.yaml"
    if [ ! -f "$file" ]; then
        echo "Hypothesis not found: ${id}"
        exit 1
    fi

    echo -e "${CYAN}Running test for ${id}...${NC}"

    # Update status to testing
    sed -i '' "s/^status: .*/status: testing/" "$file" 2>/dev/null || \
        sed -i "s/^status: .*/status: testing/" "$file"

    # Add observation
    cat >> "$file" << EOF
  - date: ${TODAY}
    result: "[Test result pending manual analysis]"
    notes: "Automated test triggered at ${NOW}"
EOF

    echo -e "${GREEN}Test initiated for ${id}${NC}"
    echo -e "${DIM}Add observations to the file with results${NC}"
}

# Approve hypothesis
approve_hypothesis() {
    local id="${1:-}"
    if [ -z "$id" ]; then
        echo "Usage: hypothesis-tracker.sh approve HYP-XXX"
        exit 1
    fi

    local file="${HYP_DIR}/${id}.yaml"
    if [ ! -f "$file" ]; then
        echo "Hypothesis not found: ${id}"
        exit 1
    fi

    # Update status
    sed -i '' "s/^status: .*/status: validated/" "$file" 2>/dev/null || \
        sed -i "s/^status: .*/status: validated/" "$file"

    echo -e "${GREEN}Hypothesis ${id} VALIDATED${NC}"
    echo -e "${YELLOW}Next: Log to .remembrance and implement${NC}"
}

# Reject hypothesis
reject_hypothesis() {
    local id="${1:-}"
    if [ -z "$id" ]; then
        echo "Usage: hypothesis-tracker.sh reject HYP-XXX"
        exit 1
    fi

    local file="${HYP_DIR}/${id}.yaml"
    if [ ! -f "$file" ]; then
        echo "Hypothesis not found: ${id}"
        exit 1
    fi

    # Update status
    sed -i '' "s/^status: .*/status: rejected/" "$file" 2>/dev/null || \
        sed -i "s/^status: .*/status: rejected/" "$file"

    echo -e "${RED}Hypothesis ${id} REJECTED${NC}"
    echo -e "${DIM}Archive or update with learnings${NC}"
}

# Generate strategic report
generate_report() {
    local report_file="${REPORT_DIR}/REPORT-${TODAY}.yaml"

    # Count hypotheses by status
    local proposed=$(grep -l "^status: proposed" "${HYP_DIR}"/*.yaml 2>/dev/null | wc -l | tr -d ' ')
    local testing=$(grep -l "^status: testing" "${HYP_DIR}"/*.yaml 2>/dev/null | wc -l | tr -d ' ')
    local validated=$(grep -l "^status: validated" "${HYP_DIR}"/*.yaml 2>/dev/null | wc -l | tr -d ' ')
    local rejected=$(grep -l "^status: rejected" "${HYP_DIR}"/*.yaml 2>/dev/null | wc -l | tr -d ' ')

    # Get utilization summary
    local total_truths=$(grep -c "^truth:" "${PROJECT_DIR}/.remembrance" 2>/dev/null || echo "0")
    local shape_shifts=$(grep -c "shape_shift: true" "${PROJECT_DIR}/.remembrance" 2>/dev/null || echo "0")

    cat > "$report_file" << EOF
# Strategic Report — ${TODAY}
---
report_id: REPORT-${TODAY}
generated: ${NOW}
period: daily
recipients: [business-strategy, cto-agent]

executive_summary: |
  System operating with ${total_truths} accumulated truths.
  ${shape_shifts} shape shifts detected (significant learning events).
  Hypotheses: ${proposed} proposed, ${testing} testing, ${validated} validated.

hypothesis_status:
  proposed: ${proposed}
  testing: ${testing}
  validated: ${validated}
  rejected: ${rejected}

utilization_summary:
  total_truths: ${total_truths}
  shape_shifts: ${shape_shifts}

recommendations:
  - "Review hypotheses in testing status"
  - "Implement validated hypotheses"
  - "Consider new hypotheses based on shape_shifts"

action_items:
  - priority: high
    item: "Review ${testing} hypotheses under testing"
    assigned_to: cto-agent
---
EOF

    echo -e "${GREEN}Strategic report generated:${NC} ${report_file}"
}

# Main
case "${1:-list}" in
    list)
        list_hypotheses
        ;;
    new)
        new_hypothesis "${2:-}"
        ;;
    test)
        run_test "${2:-}"
        ;;
    approve)
        approve_hypothesis "${2:-}"
        ;;
    reject)
        reject_hypothesis "${2:-}"
        ;;
    report)
        generate_report
        ;;
    *)
        echo "Usage: hypothesis-tracker.sh [list|new|test|approve|reject|report]"
        ;;
esac
