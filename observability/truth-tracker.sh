#!/bin/bash
# Truth Tracker — Dynamic Observability for System Evolution
# Parses .remembrance, calculates trends, generates reports
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/.."
REMEMBRANCE="${PROJECT_DIR}/.remembrance"
EVOLUTION="${PROJECT_DIR}/scrum/EVOLUTION.md"
OUTPUT_DIR="${PROJECT_DIR}/.observability"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_ONLY=$(date -u +"%Y-%m-%d")

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Ensure output directory exists
mkdir -p "${OUTPUT_DIR}/snapshots"
mkdir -p "${OUTPUT_DIR}/trends"

#───────────────────────────────────────────────────────────────────────────────
# PHASE 1: Parse .remembrance for truths
#───────────────────────────────────────────────────────────────────────────────

get_total_truths() {
    grep -c '^---$' "$REMEMBRANCE" 2>/dev/null | awk '{print int($1/2)}' || echo "0"
}

get_shape_shifts() {
    grep -c 'shape_shift: true' "$REMEMBRANCE" 2>/dev/null || echo "0"
}

get_agent_counts() {
    grep 'agent:' "$REMEMBRANCE" 2>/dev/null | sed 's/.*agent:[[:space:]]*//' | sort | uniq -c | sort -rn || echo ""
}

get_recent_truths() {
    grep 'truth:' "$REMEMBRANCE" 2>/dev/null | sed 's/.*truth:[[:space:]]*//' | tail -5 || echo ""
}

get_date_counts() {
    grep 'timestamp:' "$REMEMBRANCE" 2>/dev/null | sed 's/.*timestamp:[[:space:]]*//' | cut -d'T' -f1 | sort | uniq -c || echo ""
}

# Calculate actual days from timestamp range (CTO fix: was hardcoded /2)
get_actual_days() {
    local dates
    dates=$(grep 'timestamp:' "$REMEMBRANCE" 2>/dev/null | sed 's/.*timestamp:[[:space:]]*//' | cut -d'T' -f1 | sort -u)

    if [ -z "$dates" ]; then
        echo "1"
        return
    fi

    local oldest newest
    oldest=$(echo "$dates" | head -1)
    newest=$(echo "$dates" | tail -1)

    # Cross-platform date calculation (macOS + Linux)
    local oldest_sec newest_sec days
    if date --version >/dev/null 2>&1; then
        # GNU date (Linux)
        oldest_sec=$(date -d "$oldest" +%s 2>/dev/null || echo "0")
        newest_sec=$(date -d "$newest" +%s 2>/dev/null || echo "0")
    else
        # BSD date (macOS)
        oldest_sec=$(date -jf "%Y-%m-%d" "$oldest" +%s 2>/dev/null || echo "0")
        newest_sec=$(date -jf "%Y-%m-%d" "$newest" +%s 2>/dev/null || echo "0")
    fi

    if [ "$oldest_sec" = "0" ] || [ "$newest_sec" = "0" ]; then
        echo "1"
        return
    fi

    days=$(( (newest_sec - oldest_sec) / 86400 + 1 ))
    [ "$days" -lt 1 ] && days=1
    echo "$days"
}

#───────────────────────────────────────────────────────────────────────────────
# PHASE 2: Generate visual report
#───────────────────────────────────────────────────────────────────────────────

generate_report() {
    local total_truths
    total_truths=$(get_total_truths)
    local shape_shifts
    shape_shifts=$(get_shape_shifts)
    local agent_counts
    agent_counts=$(get_agent_counts)
    local recent_truths
    recent_truths=$(get_recent_truths)
    local actual_days growth
    actual_days=$(get_actual_days)
    growth=$(echo "scale=1; ${total_truths} / ${actual_days}" | bc 2>/dev/null || echo "N/A")

    # Print dashboard
    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║                    TRUTH EVOLUTION DASHBOARD                               ║${NC}"
    echo -e "${BOLD}║                    ${TIMESTAMP}                            ║${NC}"
    echo -e "${BOLD}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}║                                                                            ║${NC}"
    printf "${BOLD}║${NC}  ${CYAN}TOTAL TRUTHS:${NC} %-10s ${CYAN}SHAPE SHIFTS:${NC} %-10s ${CYAN}GROWTH:${NC} %s/day     ${BOLD}║${NC}\n" \
        "$total_truths" "$shape_shifts" "$growth"
    echo -e "${BOLD}║                                                                            ║${NC}"
    echo -e "${BOLD}║  AGENT ACTIVITY                                                            ║${NC}"
    echo -e "${BOLD}║  ────────────────────────────────────────────────────────────────────────  ║${NC}"

    echo "$agent_counts" | head -8 | while IFS= read -r line; do
        if [ -n "$line" ]; then
            count=$(echo "$line" | awk '{print $1}')
            agent=$(echo "$line" | awk '{print $2}')
            # Create bar (max 20 chars)
            bar_len=$((count * 2))
            [ "$bar_len" -gt 20 ] && bar_len=20
            bar=$(printf '█%.0s' $(seq 1 $bar_len) 2>/dev/null || echo "█")
            printf "${BOLD}║${NC}  %-18s ${GREEN}%-22s${NC} %3d actions       ${BOLD}║${NC}\n" "$agent" "$bar" "$count"
        fi
    done

    echo -e "${BOLD}║                                                                            ║${NC}"
    echo -e "${BOLD}║  RECENT TRUTHS                                                             ║${NC}"
    echo -e "${BOLD}║  ────────────────────────────────────────────────────────────────────────  ║${NC}"

    echo "$recent_truths" | while IFS= read -r truth; do
        if [ -n "$truth" ]; then
            truncated=$(echo "$truth" | cut -c1-66)
            printf "${BOLD}║${NC}  ${YELLOW}◆${NC} %-68s ${BOLD}║${NC}\n" "$truncated"
        fi
    done

    echo -e "${BOLD}║                                                                            ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

#───────────────────────────────────────────────────────────────────────────────
# PHASE 3: Generate JSON metrics
#───────────────────────────────────────────────────────────────────────────────

generate_json() {
    local total_truths
    total_truths=$(get_total_truths)
    local shape_shifts
    shape_shifts=$(get_shape_shifts)
    local agent_counts
    agent_counts=$(get_agent_counts)
    local date_counts
    date_counts=$(get_date_counts)

    # Build agent JSON
    local agent_json=""
    local first=true
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            local count agent
            count=$(echo "$line" | awk '{print $1}')
            agent=$(echo "$line" | awk '{print $2}')
            if [ "$first" = true ]; then
                agent_json="    \"${agent}\": ${count}"
                first=false
            else
                agent_json="${agent_json},\n    \"${agent}\": ${count}"
            fi
        fi
    done <<< "$agent_counts"

    # Build date JSON
    local date_json=""
    first=true
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            local count date_val
            count=$(echo "$line" | awk '{print $1}')
            date_val=$(echo "$line" | awk '{print $2}')
            if [ "$first" = true ]; then
                date_json="    \"${date_val}\": ${count}"
                first=false
            else
                date_json="${date_json},\n    \"${date_val}\": ${count}"
            fi
        fi
    done <<< "$date_counts"

    cat << EOF
{
  "timestamp": "${TIMESTAMP}",
  "total_truths": ${total_truths},
  "shape_shifts": ${shape_shifts},
  "growth_rate_per_day": $(echo "scale=2; ${total_truths} / $(get_actual_days)" | bc 2>/dev/null || echo "0"),
  "by_agent": {
$(echo -e "$agent_json")
  },
  "by_date": {
$(echo -e "$date_json")
  }
}
EOF
}

#───────────────────────────────────────────────────────────────────────────────
# PHASE 4: Save snapshot
#───────────────────────────────────────────────────────────────────────────────

save_snapshot() {
    local snapshot_file="${OUTPUT_DIR}/snapshots/${DATE_ONLY}.json"
    generate_json > "$snapshot_file"
    echo -e "${GREEN}Snapshot saved:${NC} $snapshot_file"
}

#───────────────────────────────────────────────────────────────────────────────
# PHASE 5: Calculate trends
#───────────────────────────────────────────────────────────────────────────────

calculate_trends() {
    echo -e "\n${BOLD}TREND ANALYSIS${NC}"
    echo "─────────────────────────────────────"

    local snapshots
    snapshots=$(find "${OUTPUT_DIR}/snapshots" -name "*.json" -type f 2>/dev/null | sort | tail -7)

    if [ -z "$snapshots" ]; then
        echo "  No snapshots yet. Run: $0 snapshot"
        return
    fi

    local prev_truths=0
    echo "$snapshots" | while IFS= read -r snapshot; do
        if [ -f "$snapshot" ]; then
            date=$(basename "$snapshot" .json)
            truths=$(grep -o '"total_truths": [0-9]*' "$snapshot" 2>/dev/null | grep -o '[0-9]*' || echo "0")
            shifts=$(grep -o '"shape_shifts": [0-9]*' "$snapshot" 2>/dev/null | grep -o '[0-9]*' || echo "0")
            printf "  %s  │  Truths: %3d  │  Shifts: %d\n" "$date" "$truths" "$shifts"
        fi
    done
}

#───────────────────────────────────────────────────────────────────────────────
# PHASE 6: Evolution summary from EVOLUTION.md
#───────────────────────────────────────────────────────────────────────────────

evolution_summary() {
    if [ ! -f "$EVOLUTION" ]; then
        echo "No EVOLUTION.md found"
        return
    fi

    echo -e "\n${BOLD}EVOLUTION SUMMARY${NC}"
    echo "─────────────────────────────────────"

    # Count capabilities
    local capabilities
    capabilities=$(grep -c '^| ' "$EVOLUTION" 2>/dev/null || echo "0")

    # Last 5 events
    echo -e "\n${CYAN}Recent Events:${NC}"
    grep '^| 2026-' "$EVOLUTION" 2>/dev/null | tail -5 | while IFS='|' read -r _ timestamp event agent ticket outcome _; do
        printf "  %s │ %-20s │ %s\n" "$(echo "$timestamp" | tr -d ' ')" "$(echo "$agent" | tr -d ' ')" "$(echo "$event" | tr -d ' ' | cut -c1-30)"
    done

    # Shape shifts
    echo -e "\n${YELLOW}Shape Shifts (Major Insights):${NC}"
    grep '◆\|shape_shift' "$EVOLUTION" "$REMEMBRANCE" 2>/dev/null | head -5 | while IFS= read -r line; do
        echo "  $line" | cut -c1-70
    done
}

#───────────────────────────────────────────────────────────────────────────────
# MAIN
#───────────────────────────────────────────────────────────────────────────────

case "${1:-report}" in
    report)
        generate_report
        ;;
    json)
        generate_json
        ;;
    snapshot)
        save_snapshot
        ;;
    trends)
        calculate_trends
        ;;
    evolution)
        evolution_summary
        ;;
    full)
        generate_report
        save_snapshot
        calculate_trends
        evolution_summary
        ;;
    watch)
        echo "Watching for changes... (Ctrl+C to stop)"
        while true; do
            clear
            generate_report
            sleep 10
        done
        ;;
    *)
        echo "Usage: $0 {report|json|snapshot|trends|evolution|full|watch}"
        echo ""
        echo "Commands:"
        echo "  report    - Show visual dashboard"
        echo "  json      - Output metrics as JSON"
        echo "  snapshot  - Save current state to .observability/"
        echo "  trends    - Show trend analysis from snapshots"
        echo "  evolution - Show evolution summary"
        echo "  full      - All of the above"
        echo "  watch     - Live dashboard (updates every 10s)"
        exit 1
        ;;
esac
