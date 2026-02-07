#!/bin/bash
# Dynamic Rounds — Self-Optimizing Report System
# Reports to higher-order agents every N rounds (default: 10)
# Optimizes round frequency based on metrics

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/.."
OBSERVABILITY_DIR="${PROJECT_DIR}/.observability"
ROUNDS_FILE="${OBSERVABILITY_DIR}/rounds.json"
REPORTS_DIR="${OBSERVABILITY_DIR}/reports"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Ensure directories exist
mkdir -p "${REPORTS_DIR}"

#───────────────────────────────────────────────────────────────────────────────
# Round State Management
#───────────────────────────────────────────────────────────────────────────────

init_rounds() {
    if [ ! -f "$ROUNDS_FILE" ]; then
        cat > "$ROUNDS_FILE" << 'EOF'
{
  "current_round": 0,
  "report_frequency": 10,
  "last_report": null,
  "optimization": {
    "min_frequency": 5,
    "max_frequency": 50,
    "velocity_threshold_high": 15,
    "velocity_threshold_low": 3
  },
  "history": []
}
EOF
        echo -e "${GREEN}Initialized rounds tracking${NC}"
    fi
}

get_current_round() {
    if [ -f "$ROUNDS_FILE" ]; then
        grep -o '"current_round": [0-9]*' "$ROUNDS_FILE" | grep -o '[0-9]*'
    else
        echo "0"
    fi
}

get_report_frequency() {
    if [ -f "$ROUNDS_FILE" ]; then
        grep -o '"report_frequency": [0-9]*' "$ROUNDS_FILE" | grep -o '[0-9]*'
    else
        echo "10"
    fi
}

increment_round() {
    local current
    current=$(get_current_round)
    local new_round=$((current + 1))

    # Update rounds file
    if [ -f "$ROUNDS_FILE" ]; then
        sed -i '' "s/\"current_round\": ${current}/\"current_round\": ${new_round}/" "$ROUNDS_FILE" 2>/dev/null || \
        sed -i "s/\"current_round\": ${current}/\"current_round\": ${new_round}/" "$ROUNDS_FILE"
    fi

    echo "$new_round"
}

#───────────────────────────────────────────────────────────────────────────────
# Metrics Collection
#───────────────────────────────────────────────────────────────────────────────

collect_metrics() {
    # Get truth tracker metrics
    local truths
    truths=$("${SCRIPT_DIR}/truth-tracker.sh" json 2>/dev/null || echo '{"total_truths": 0}')

    # Calculate velocity (truths per day)
    local total
    total=$(echo "$truths" | grep -o '"total_truths": [0-9]*' | grep -o '[0-9]*' || echo "0")

    echo "$truths"
}

#───────────────────────────────────────────────────────────────────────────────
# Frequency Optimization
#───────────────────────────────────────────────────────────────────────────────

optimize_frequency() {
    local velocity="$1"
    local current_freq
    current_freq=$(get_report_frequency)
    local new_freq="$current_freq"

    # High velocity → more frequent reports
    if [ "$(echo "$velocity > 15" | bc 2>/dev/null || echo 0)" = "1" ]; then
        new_freq=$((current_freq - 2))
        [ "$new_freq" -lt 5 ] && new_freq=5
    # Low velocity → less frequent reports
    elif [ "$(echo "$velocity < 3" | bc 2>/dev/null || echo 0)" = "1" ]; then
        new_freq=$((current_freq + 5))
        [ "$new_freq" -gt 50 ] && new_freq=50
    fi

    if [ "$new_freq" != "$current_freq" ]; then
        sed -i '' "s/\"report_frequency\": ${current_freq}/\"report_frequency\": ${new_freq}/" "$ROUNDS_FILE" 2>/dev/null || \
        sed -i "s/\"report_frequency\": ${current_freq}/\"report_frequency\": ${new_freq}/" "$ROUNDS_FILE"
        echo -e "${YELLOW}Frequency optimized: ${current_freq} → ${new_freq}${NC}"
    fi

    echo "$new_freq"
}

#───────────────────────────────────────────────────────────────────────────────
# Higher-Order Agent Report
#───────────────────────────────────────────────────────────────────────────────

generate_higher_order_report() {
    local round="$1"
    local report_file="${REPORTS_DIR}/round-${round}-report.md"
    local metrics
    metrics=$(collect_metrics)

    cat > "$report_file" << EOF
# Dynamic Round Report — Round ${round}

> Generated: ${TIMESTAMP}
> Report Type: Higher-Order Agent Briefing

## System State

$(echo "$metrics" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(f\"- **Total Truths**: {data.get('total_truths', 0)}\")
    print(f\"- **Shape Shifts**: {data.get('shape_shifts', 0)}\")
    print(f\"- **Growth Rate**: {data.get('growth_rate_per_day', 0)}/day\")
    print()
    print('### Agent Activity')
    for agent, count in data.get('by_agent', {}).items():
        print(f'- {agent}: {count} actions')
except:
    print('- Metrics unavailable')
" 2>/dev/null || echo "- Metrics parsing failed")

## Timeline (Last 5 Entries)

$(grep -A8 '^---$' "${PROJECT_DIR}/.remembrance" 2>/dev/null | grep -E '^(timestamp|agent|truth):' | tail -15 | \
  sed 's/^/- /' || echo "- No entries")

## Emergent Patterns

$(grep 'shape_shift: true' "${PROJECT_DIR}/.remembrance" 2>/dev/null | wc -l | tr -d ' ') major paradigm shifts detected.

## Recommendations for Higher-Order Agents

1. Review shape_shift entries for strategic implications
2. Verify agent activity balance (current: system-heavy)
3. Check velocity against sprint goals

---
*Next report: Round $((round + $(get_report_frequency)))*
EOF

    echo -e "${GREEN}Report generated:${NC} $report_file"
}

#───────────────────────────────────────────────────────────────────────────────
# Background Process Mode
#───────────────────────────────────────────────────────────────────────────────

run_background_daemon() {
    local interval="${1:-60}"  # Default: check every 60 seconds

    echo -e "${BOLD}Starting Dynamic Rounds Daemon${NC}"
    echo "  Interval: ${interval}s"
    echo "  Report frequency: $(get_report_frequency) rounds"
    echo "  PID: $$"
    echo ""

    while true; do
        # Increment round
        local round
        round=$(increment_round)
        local freq
        freq=$(get_report_frequency)

        echo -e "[$(date +%H:%M:%S)] Round ${round}"

        # Check if report needed
        if [ $((round % freq)) -eq 0 ]; then
            echo -e "${CYAN}Report round reached. Generating higher-order report...${NC}"
            generate_higher_order_report "$round"

            # Optimize frequency based on velocity
            local metrics
            metrics=$(collect_metrics)
            local velocity
            velocity=$(echo "$metrics" | grep -o '"growth_rate_per_day": [0-9.]*' | grep -o '[0-9.]*' || echo "0")
            optimize_frequency "$velocity"
        fi

        sleep "$interval"
    done
}

#───────────────────────────────────────────────────────────────────────────────
# MAIN
#───────────────────────────────────────────────────────────────────────────────

case "${1:-status}" in
    init)
        init_rounds
        ;;
    tick)
        # Manual round increment
        init_rounds
        round=$(increment_round)
        freq=$(get_report_frequency)
        echo "Round: $round (report every $freq)"
        if [ $((round % freq)) -eq 0 ]; then
            generate_higher_order_report "$round"
        fi
        ;;
    report)
        # Force report now
        init_rounds
        round=$(get_current_round)
        generate_higher_order_report "$round"
        ;;
    daemon)
        # Background daemon mode
        init_rounds
        run_background_daemon "${2:-60}"
        ;;
    status)
        init_rounds
        echo -e "${BOLD}Dynamic Rounds Status${NC}"
        echo "─────────────────────────────────"
        echo "  Current Round: $(get_current_round)"
        echo "  Report Frequency: every $(get_report_frequency) rounds"
        echo "  Reports Dir: ${REPORTS_DIR}"
        ls -la "${REPORTS_DIR}" 2>/dev/null | tail -5 || echo "  No reports yet"
        ;;
    optimize)
        # Manual optimization trigger
        metrics=$(collect_metrics)
        velocity=$(echo "$metrics" | grep -o '"growth_rate_per_day": [0-9.]*' | grep -o '[0-9.]*' || echo "0")
        echo "Current velocity: $velocity/day"
        optimize_frequency "$velocity"
        ;;
    *)
        echo "Usage: $0 {init|tick|report|daemon [interval]|status|optimize}"
        echo ""
        echo "Commands:"
        echo "  init              Initialize round tracking"
        echo "  tick              Increment round, report if due"
        echo "  report            Force generate report now"
        echo "  daemon [seconds]  Run as background daemon (default: 60s)"
        echo "  status            Show current round status"
        echo "  optimize          Manually trigger frequency optimization"
        exit 1
        ;;
esac
