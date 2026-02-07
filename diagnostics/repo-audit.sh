#!/bin/bash
#
# repo-audit.sh — CTO-Level Repository Diagnostics
#
# Provides comprehensive view of repository structure, health, and data sources
# for strategic decision-making.
#
set -euo pipefail

# Find project root
find_project_root() {
    local dir="${1:-$PWD}"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/CLAUDE.md" ] || [ -f "$dir/.remembrance" ]; then
            echo "$dir"
            return
        fi
        dir=$(dirname "$dir")
    done
    echo "$PWD"
}

PROJECT_ROOT=$(find_project_root)
cd "$PROJECT_ROOT"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║                    CTO REPOSITORY AUDIT                                    ║${NC}"
echo -e "${BOLD}║                    $(date -u +"%Y-%m-%dT%H:%M:%SZ")                            ║${NC}"
echo -e "${BOLD}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"

# 1. Repository Location
echo -e "${BOLD}║                                                                            ║${NC}"
echo -e "${BOLD}║  ${CYAN}1. REPOSITORY INFO${NC}                                                       ║"
echo -e "${BOLD}║  ────────────────────────────────────────────────────────────────────────  ║${NC}"
printf "${BOLD}║${NC}  PWD:            %-54s ${BOLD}║${NC}\n" "$PWD"
printf "${BOLD}║${NC}  Project Root:   %-54s ${BOLD}║${NC}\n" "$PROJECT_ROOT"
printf "${BOLD}║${NC}  Git Branch:     %-54s ${BOLD}║${NC}\n" "$(git branch --show-current 2>/dev/null || echo 'N/A')"
printf "${BOLD}║${NC}  Git Status:     %-54s ${BOLD}║${NC}\n" "$(git status --short 2>/dev/null | wc -l | tr -d ' ') uncommitted changes"

# 2. Structure Health
echo -e "${BOLD}║                                                                            ║${NC}"
echo -e "${BOLD}║  ${CYAN}2. STRUCTURE HEALTH${NC}                                                      ║"
echo -e "${BOLD}║  ────────────────────────────────────────────────────────────────────────  ║${NC}"

check_exists() {
    if [ -e "$1" ]; then
        printf "${BOLD}║${NC}  ${GREEN}✓${NC} %-66s ${BOLD}║${NC}\n" "$1"
    else
        printf "${BOLD}║${NC}  ${RED}✗${NC} %-66s ${BOLD}║${NC}\n" "$1 (MISSING)"
    fi
}

check_exists "CLAUDE.md"
check_exists ".remembrance"
check_exists "plugin/"
check_exists ".claude/agents/INDEX.md"
check_exists ".claude/skills/"
check_exists "scrum/SCRUM.md"
check_exists "scrum/ROADMAP.md"
check_exists ".observability/"
check_exists ".loop-state.yaml"

# 3. Data Sources
echo -e "${BOLD}║                                                                            ║${NC}"
echo -e "${BOLD}║  ${CYAN}3. DATA SOURCES${NC}                                                          ║"
echo -e "${BOLD}║  ────────────────────────────────────────────────────────────────────────  ║${NC}"

remembrance_entries=$(grep -c "^timestamp:" .remembrance 2>/dev/null || echo 0)
shape_shifts=$(grep -c "shape_shift: true" .remembrance 2>/dev/null || echo 0)
remembrance_lines=$(wc -l < .remembrance 2>/dev/null | tr -d ' ')

printf "${BOLD}║${NC}  .remembrance:   %-54s ${BOLD}║${NC}\n" "${remembrance_entries} entries, ${shape_shifts} shifts, ${remembrance_lines} lines"

if [ -f ".observability/remembrance-tracker.json" ]; then
    reads=$(jq '.read_count // 0' .observability/remembrance-tracker.json 2>/dev/null || echo 0)
    printf "${BOLD}║${NC}  Tracker reads:  %-54s ${BOLD}║${NC}\n" "$reads"
fi

if [ -f ".observability/rounds.json" ]; then
    round=$(jq '.current_round // 0' .observability/rounds.json 2>/dev/null || echo 0)
    printf "${BOLD}║${NC}  Current round:  %-54s ${BOLD}║${NC}\n" "$round"
fi

if [ -d "plugin/observability/hypotheses/" ]; then
    hyp_count=$(ls -1 plugin/observability/hypotheses/*.yaml 2>/dev/null | wc -l | tr -d ' ')
    printf "${BOLD}║${NC}  Hypotheses:     %-54s ${BOLD}║${NC}\n" "$hyp_count active"
fi

# 4. Scripts & Duplicates
echo -e "${BOLD}║                                                                            ║${NC}"
echo -e "${BOLD}║  ${CYAN}4. SCRIPTS AUDIT${NC}                                                         ║"
echo -e "${BOLD}║  ────────────────────────────────────────────────────────────────────────  ║${NC}"

# Count scripts
scripts_count=$(find scripts/ -name "*.sh" -type f 2>/dev/null | wc -l | tr -d ' ')
plugin_scripts=$(find plugin/ -name "*.sh" -type f 2>/dev/null | wc -l | tr -d ' ')
printf "${BOLD}║${NC}  scripts/:       %-54s ${BOLD}║${NC}\n" "$scripts_count files"
printf "${BOLD}║${NC}  plugin/:        %-54s ${BOLD}║${NC}\n" "$plugin_scripts files"

# Check for symlinks (good) vs duplicates (bad)
symlinks=$(find scripts/ -type l 2>/dev/null | wc -l | tr -d ' ')
printf "${BOLD}║${NC}  Symlinks:       %-54s ${BOLD}║${NC}\n" "$symlinks (canonical references)"

# 5. Potential Issues
echo -e "${BOLD}║                                                                            ║${NC}"
echo -e "${BOLD}║  ${CYAN}5. POTENTIAL ISSUES${NC}                                                      ║"
echo -e "${BOLD}║  ────────────────────────────────────────────────────────────────────────  ║${NC}"

issues=0

# Check for hardcoded growth rate values (not YAML delimiter counting which uses /2 legitimately)
hardcoded=$(grep -r "truths.*/ 2\|growth.*/ 2" plugin/observability/*.sh scripts/*.sh 2>/dev/null | grep -v "get_actual_days\|Binary" | wc -l | tr -d ' ')
if [ "$hardcoded" -gt 0 ]; then
    printf "${BOLD}║${NC}  ${YELLOW}⚠${NC}  Hardcoded growth /2: %-44s ${BOLD}║${NC}\n" "$hardcoded instances"
    issues=$((issues + 1))
fi

# Check for broken symlinks
broken=$(find . -xtype l 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
if [ "$broken" -gt 0 ]; then
    printf "${BOLD}║${NC}  ${RED}✗${NC}  Broken symlinks: %-48s ${BOLD}║${NC}\n" "$broken"
    issues=$((issues + 1))
fi

# Check for large files
large=$(find . -size +1M -not -path "./node_modules/*" -not -path "./.git/*" 2>/dev/null | wc -l | tr -d ' ')
if [ "$large" -gt 0 ]; then
    printf "${BOLD}║${NC}  ${YELLOW}⚠${NC}  Large files (>1MB): %-46s ${BOLD}║${NC}\n" "$large"
fi

if [ "$issues" -eq 0 ]; then
    printf "${BOLD}║${NC}  ${GREEN}✓${NC}  No critical issues detected                                        ${BOLD}║${NC}\n"
fi

# 6. Loop State
echo -e "${BOLD}║                                                                            ║${NC}"
echo -e "${BOLD}║  ${CYAN}6. LOOP STATE${NC}                                                             ║"
echo -e "${BOLD}║  ────────────────────────────────────────────────────────────────────────  ║${NC}"

if [ -f ".loop-state.yaml" ]; then
    phase=$(grep "^phase:" .loop-state.yaml | cut -d: -f2 | tr -d ' ')
    last=$(grep "^last_phase:" .loop-state.yaml | cut -d: -f2 | tr -d ' ')
    printf "${BOLD}║${NC}  Current phase:  %-54s ${BOLD}║${NC}\n" "$phase"
    printf "${BOLD}║${NC}  Last phase:     %-54s ${BOLD}║${NC}\n" "$last"
else
    printf "${BOLD}║${NC}  ${YELLOW}⚠${NC}  No .loop-state.yaml found                                         ${BOLD}║${NC}\n"
fi

echo -e "${BOLD}║                                                                            ║${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Optional: detailed output
case "${1:-}" in
    --json)
        echo "{\"project_root\": \"$PROJECT_ROOT\", \"remembrance_entries\": $remembrance_entries, \"shape_shifts\": $shape_shifts, \"issues\": $issues}"
        ;;
    --files)
        echo -e "\n${BOLD}All .sh files:${NC}"
        find . -name "*.sh" -not -path "./node_modules/*" | sort
        ;;
    --duplicates)
        echo -e "\n${BOLD}Checking for duplicate scripts (by content hash):${NC}"
        find . -name "*.sh" -not -path "./node_modules/*" -type f -exec md5 {} \; 2>/dev/null | sort | uniq -d -w32
        ;;
esac
