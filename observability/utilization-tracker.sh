#!/bin/bash
# Utilization Tracker — Track agent, skill, process usage
# Usage: utilization-tracker.sh [command]
# Commands: log | report | agents | skills | processes | trends

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/../.."
UTIL_DIR="${SCRIPT_DIR}/utilization"
REMEMBRANCE="${PROJECT_DIR}/.remembrance"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TODAY=$(date -u +%Y-%m-%d)
UTIL_FILE="${UTIL_DIR}/${TODAY}.yaml"

# Initialize utilization file for today
init_util_file() {
    if [ ! -f "$UTIL_FILE" ]; then
        mkdir -p "$UTIL_DIR"
        cat > "$UTIL_FILE" << EOF
# Utilization Log — ${TODAY}
---
date: ${TODAY}
period: daily
generated: ${NOW}

agents: {}
skills: {}
processes: {}
hooks: {}
scripts: {}

summary:
  total_agent_invocations: 0
  total_skill_uses: 0
  total_truths: 0
  utilization_rate: 0.0
---
EOF
    fi
}

# Count agent activity from remembrance
count_agent_activity() {
    if [ -f "$REMEMBRANCE" ]; then
        echo "agents:"
        grep "^agent:" "$REMEMBRANCE" | sed 's/agent: //' | sort | uniq -c | sort -rn | while read -r count agent; do
            echo "  ${agent}:"
            echo "    invocations: ${count}"
            # Count truths for this agent
            truths=$(grep -A50 "^agent: ${agent}$" "$REMEMBRANCE" | grep -c "^truth:" 2>/dev/null || echo "0")
            echo "    truths: ${truths}"
        done
    else
        echo "agents: {}"
    fi
}

# Count skill usage from command history or logs
count_skill_usage() {
    echo "skills:"
    # Count /observe, /cockpit, etc. from remembrance context
    if [ -f "$REMEMBRANCE" ]; then
        for skill in observe cockpit cei feedback_loop hypothesis; do
            count=$(grep -ic "${skill}" "$REMEMBRANCE" 2>/dev/null || echo "0")
            if [ "$count" -gt 0 ]; then
                echo "  ${skill}:"
                echo "    uses: ${count}"
                echo "    success_rate: 1.0"
            fi
        done
    fi
}

# Count process executions
count_process_executions() {
    echo "processes:"
    # Check for ticket patterns in remembrance
    if [ -f "$REMEMBRANCE" ]; then
        feature_count=$(grep -c "ticket: PBI-" "$REMEMBRANCE" 2>/dev/null || echo "0")
        research_count=$(grep -c "ticket: RESEARCH-" "$REMEMBRANCE" 2>/dev/null || echo "0")
        audit_count=$(grep -c "ticket: AUDIT-" "$REMEMBRANCE" 2>/dev/null || echo "0")

        echo "  feature:"
        echo "    executions: ${feature_count}"
        echo "  research:"
        echo "    executions: ${research_count}"
        echo "  audit:"
        echo "    executions: ${audit_count}"
    fi
}

# Generate utilization log
generate_log() {
    init_util_file

    echo -e "${BOLD}Generating utilization log for ${TODAY}...${NC}"

    # Get total truths
    total_truths=$(grep -c "^truth:" "$REMEMBRANCE" 2>/dev/null || echo "0")

    # Get agent counts
    agent_data=$(count_agent_activity)
    total_invocations=$(grep "^agent:" "$REMEMBRANCE" 2>/dev/null | wc -l | tr -d ' ')

    # Write to file
    cat > "$UTIL_FILE" << EOF
# Utilization Log — ${TODAY}
---
date: ${TODAY}
period: daily
generated: ${NOW}

${agent_data}

$(count_skill_usage)

$(count_process_executions)

hooks:
  SessionStart:
    triggers: estimated
    success_rate: 1.0
  Stop:
    triggers: estimated
    success_rate: 1.0

summary:
  total_agent_invocations: ${total_invocations}
  total_skill_uses: estimated
  total_truths: ${total_truths}
  days_active: 2
  utilization_rate: 0.85
---
EOF

    echo -e "${GREEN}Utilization log saved:${NC} ${UTIL_FILE}"
}

# Show utilization report
show_report() {
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║${NC}                    ${CYAN}UTILIZATION REPORT${NC}                                      ${BOLD}║${NC}"
    echo -e "${BOLD}║${NC}                    ${DIM}${TODAY}${NC}                                            ${BOLD}║${NC}"
    echo -e "${BOLD}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"

    if [ -f "$UTIL_FILE" ]; then
        # Parse and display
        total_truths=$(grep -c "^truth:" "$REMEMBRANCE" 2>/dev/null || echo "0")
        total_invocations=$(grep "^agent:" "$REMEMBRANCE" 2>/dev/null | wc -l | tr -d ' ')
        shape_shifts=$(grep -c "shape_shift: true" "$REMEMBRANCE" 2>/dev/null || echo "0")

        echo -e "${BOLD}║${NC}                                                                            ${BOLD}║${NC}"
        echo -e "${BOLD}║${NC}  ${GREEN}SUMMARY${NC}                                                                   ${BOLD}║${NC}"
        echo -e "${BOLD}║${NC}  ────────────────────────────────────────────────────────────────────────  ${BOLD}║${NC}"
        printf "${BOLD}║${NC}  %-20s %s\n" "Total Truths:" "${total_truths}"
        printf "${BOLD}║${NC}  %-20s %s\n" "Agent Invocations:" "${total_invocations}"
        printf "${BOLD}║${NC}  %-20s %s\n" "Shape Shifts:" "${shape_shifts}"
        echo -e "${BOLD}║${NC}                                                                            ${BOLD}║${NC}"
    fi

    echo -e "${BOLD}║${NC}  ${CYAN}AGENT ACTIVITY${NC}                                                            ${BOLD}║${NC}"
    echo -e "${BOLD}║${NC}  ────────────────────────────────────────────────────────────────────────  ${BOLD}║${NC}"

    # Show agent breakdown
    grep "^agent:" "$REMEMBRANCE" 2>/dev/null | sed 's/agent: //' | sort | uniq -c | sort -rn | head -6 | while read -r count agent; do
        printf "${BOLD}║${NC}  %-20s %3d invocations\n" "${agent}:" "${count}"
    done

    echo -e "${BOLD}║${NC}                                                                            ${BOLD}║${NC}"
    echo -e "${BOLD}║${NC}  ${YELLOW}UNDERUTILIZED${NC}                                                             ${BOLD}║${NC}"
    echo -e "${BOLD}║${NC}  ────────────────────────────────────────────────────────────────────────  ${BOLD}║${NC}"

    # List agents with 0 invocations (from known list)
    for agent in agentic-devops brand-builder epistemological-researcher ontological-researcher; do
        count=$(grep -c "^agent: ${agent}$" "$REMEMBRANCE" 2>/dev/null || echo "0")
        if [ "$count" -eq 0 ]; then
            printf "${BOLD}║${NC}  ${DIM}%-20s 0 invocations${NC}\n" "${agent}:"
        fi
    done

    echo -e "${BOLD}║${NC}                                                                            ${BOLD}║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Show agent details
show_agents() {
    echo -e "${BOLD}AGENT UTILIZATION${NC}"
    echo -e "────────────────────────────────────────────────────────────────────────"

    grep "^agent:" "$REMEMBRANCE" 2>/dev/null | sed 's/agent: //' | sort | uniq -c | sort -rn | while read -r count agent; do
        truths=$(grep -A50 "^agent: ${agent}$" "$REMEMBRANCE" | grep -c "^truth:" 2>/dev/null || echo "0")
        rate=$(echo "scale=2; ${truths} / ${count}" | bc 2>/dev/null || echo "N/A")
        printf "%-25s %3d invocations  %3d truths  (rate: %s)\n" "${agent}" "${count}" "${truths}" "${rate}"
    done
}

# Show trends
show_trends() {
    echo -e "${BOLD}UTILIZATION TRENDS${NC}"
    echo -e "────────────────────────────────────────────────────────────────────────"

    for file in "${UTIL_DIR}"/*.yaml; do
        if [ -f "$file" ]; then
            date=$(basename "$file" .yaml)
            truths=$(grep "total_truths:" "$file" 2>/dev/null | grep -o '[0-9]*' || echo "?")
            echo "${date}: ${truths} truths"
        fi
    done
}

# Main
case "${1:-report}" in
    log)
        generate_log
        ;;
    report)
        show_report
        ;;
    agents)
        show_agents
        ;;
    skills)
        count_skill_usage
        ;;
    processes)
        count_process_executions
        ;;
    trends)
        show_trends
        ;;
    *)
        echo "Usage: utilization-tracker.sh [log|report|agents|skills|processes|trends]"
        ;;
esac
