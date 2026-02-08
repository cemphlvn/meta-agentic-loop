#!/usr/bin/env bash
# observability/workflow-audit/audit.sh
# Deterministic workflow audit runner
#
# Purpose: Detect where scriptic/deterministic enforcement could prevent failures
# Usage: ./audit.sh [audit|opportunities|evolution|coverage]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
HUMANITIC_ROOT="$(dirname "$PLUGIN_ROOT")"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Directories
AUDITS_DIR="$SCRIPT_DIR/audits"
OPPORTUNITIES_DIR="$SCRIPT_DIR/opportunities"

mkdir -p "$AUDITS_DIR" "$OPPORTUNITIES_DIR"

#─────────────────────────────────────────────────────────────────────────────
# OBSERVABILITY COVERAGE CALCULATION
# Philosophy: NOT rigid determinism, YES intelligent adaptation
# Deterministic WHERE it prevents waste; Flexible WHERE it enables growth
#─────────────────────────────────────────────────────────────────────────────
calculate_coverage() {
    local scripts=0
    local hooks=0
    local schemas=0
    local documented=0
    local remembrance_entries=0

    # Count scripts (automation layer)
    if [[ -d "$PLUGIN_ROOT/scripts" ]]; then
        scripts=$(find "$PLUGIN_ROOT/scripts" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
    fi

    # Count hooks (enforcement layer - where determinism prevents waste)
    if [[ -f "$PLUGIN_ROOT/hooks.json" ]]; then
        hooks=$(grep -c '"type"' "$PLUGIN_ROOT/hooks.json" 2>/dev/null || echo 0)
    fi

    # Count documented patterns (flexibility layer - guides but doesn't constrain)
    if [[ -d "$PLUGIN_ROOT/.claude/skills" ]]; then
        documented=$(find "$PLUGIN_ROOT/.claude/skills" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi

    # Count schemas (observability layer)
    schemas=$(find "$PLUGIN_ROOT/observability" -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ')

    # Count remembrance entries (learning layer)
    if [[ -f "$PLUGIN_ROOT/.remembrance" ]]; then
        remembrance_entries=$(grep -c "^---$" "$PLUGIN_ROOT/.remembrance" 2>/dev/null || echo 0)
    fi

    # Calculate coverage score (weighted for OBSERVABILITY not rigidity)
    # remembrance=3pts (learning is key), documented=2pts (flexibility)
    # schemas=2pts (observability), hooks=2pts, scripts=1pt
    local total_mechanisms=$((remembrance_entries * 3 + documented * 2 + schemas * 2 + hooks * 2 + scripts * 1))
    local target_score=100  # Adjust based on expected mechanisms
    local coverage=$((total_mechanisms * 100 / target_score))

    if [[ $coverage -gt 100 ]]; then
        coverage=100
    fi

    echo "$coverage"
}

#─────────────────────────────────────────────────────────────────────────────
# FAILURE PATTERN DETECTION
#─────────────────────────────────────────────────────────────────────────────
detect_failure_patterns() {
    echo -e "${CYAN}=== FAILURE PATTERN ANALYSIS ===${NC}"
    echo ""

    local ecosystem_remembrance="$HUMANITIC_ROOT/.remembrance"
    local plugin_remembrance="$PLUGIN_ROOT/.remembrance"

    local validation_failures=0
    local enforcement_failures=0
    local automation_candidates=0

    # Analyze ecosystem remembrance
    if [[ -f "$ecosystem_remembrance" ]]; then
        echo -e "${BLUE}Ecosystem .remembrance:${NC}"

        # Look for validation failure patterns
        validation_failures=$(grep -ciE "404|not found|does not exist|invalid|malformed" "$ecosystem_remembrance" 2>/dev/null | tr -d '[:space:]')
        [[ -z "$validation_failures" ]] && validation_failures=0
        echo "  Validation failure signals: $validation_failures"

        # Look for enforcement failure patterns
        enforcement_failures=$(grep -ciE "wrong|incorrect|should have|forgot|missed" "$ecosystem_remembrance" 2>/dev/null | tr -d '[:space:]')
        [[ -z "$enforcement_failures" ]] && enforcement_failures=0
        echo "  Enforcement failure signals: $enforcement_failures"

        # Look for automation candidates (repeated patterns)
        automation_candidates=$(grep -ciE "again|repeatedly|every time|always" "$ecosystem_remembrance" 2>/dev/null | tr -d '[:space:]')
        [[ -z "$automation_candidates" ]] && automation_candidates=0
        echo "  Automation opportunity signals: $automation_candidates"
    fi

    echo ""

    # Analyze plugin remembrance
    if [[ -f "$plugin_remembrance" ]]; then
        echo -e "${BLUE}Plugin .remembrance:${NC}"

        local p_validation=$(grep -ciE "404|not found|does not exist|invalid" "$plugin_remembrance" 2>/dev/null | tr -d '[:space:]' || echo 0)
        local p_enforcement=$(grep -ciE "wrong|incorrect|should have|forgot" "$plugin_remembrance" 2>/dev/null | tr -d '[:space:]' || echo 0)
        local p_automation=$(grep -ciE "again|repeatedly|every time" "$plugin_remembrance" 2>/dev/null | tr -d '[:space:]' || echo 0)

        # Ensure we have valid numbers
        [[ -z "$p_validation" ]] && p_validation=0
        [[ -z "$p_enforcement" ]] && p_enforcement=0
        [[ -z "$p_automation" ]] && p_automation=0

        echo "  Validation failure signals: $p_validation"
        echo "  Enforcement failure signals: $p_enforcement"
        echo "  Automation opportunity signals: $p_automation"

        validation_failures=$((validation_failures + p_validation))
        enforcement_failures=$((enforcement_failures + p_enforcement))
        automation_candidates=$((automation_candidates + p_automation))
    fi

    echo ""
    echo -e "${YELLOW}TOTALS:${NC}"
    echo "  Level 1 (Validation):  $validation_failures opportunities"
    echo "  Level 2 (Enforcement): $enforcement_failures opportunities"
    echo "  Level 3 (Automation):  $automation_candidates opportunities"
    echo ""

    # Return total opportunities
    echo $((validation_failures + enforcement_failures + automation_candidates))
}

#─────────────────────────────────────────────────────────────────────────────
# EVOLUTION VECTOR STATUS
#─────────────────────────────────────────────────────────────────────────────
show_evolution() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    HIGHER-ORDER DEVELOPMENT PLAN                          ║${NC}"
    echo -e "${CYAN}║                                                                           ║${NC}"
    echo -e "${CYAN}║  Philosophy: NOT rigid determinism, YES intelligent adaptation            ║${NC}"
    echo -e "${CYAN}║  Deterministic WHERE it prevents waste; Flexible WHERE it enables growth  ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    local coverage=$(calculate_coverage)

    echo -e "${BLUE}EVOLUTION VECTOR (Observability-Flexibility Duality):${NC}"
    echo ""
    echo "  1_adhoc ──────→ 2_observable ──────→ 3_adaptive ──────→ 4_flourishing"
    echo "    0%                40%                 70%                90%+"
    echo ""

    # Determine current stage
    local stage=""
    local stage_desc=""
    if [[ $coverage -lt 40 ]]; then
        stage="1_adhoc → 2_observable"
        stage_desc="Building observability: logging patterns, tracking failures"
    elif [[ $coverage -lt 70 ]]; then
        stage="2_observable → 3_adaptive"
        stage_desc="Patterns logged, learnings captured, proposing improvements"
    elif [[ $coverage -lt 90 ]]; then
        stage="3_adaptive → 4_flourishing"
        stage_desc="System responds to patterns, balancing determinism and flexibility"
    else
        stage="4_flourishing"
        stage_desc="Intelligent balance: deterministic where it prevents waste, flexible where it enables growth"
    fi

    echo -e "  ${GREEN}CURRENT POSITION:${NC} $stage"
    echo -e "  ${GREEN}OBSERVABILITY:${NC} ${coverage}%"
    echo -e "  ${GREEN}DESCRIPTION:${NC} $stage_desc"
    echo ""

    # Show progress bar
    echo -e "${BLUE}PROGRESS:${NC}"
    local filled=$((coverage / 5))
    local empty=$((20 - filled))
    printf "  ["
    printf "%0.s█" $(seq 1 $filled) 2>/dev/null || true
    printf "%0.s░" $(seq 1 $empty) 2>/dev/null || true
    printf "] %d%%\n" "$coverage"
    echo ""

    # The balance
    echo -e "${YELLOW}THE BALANCE:${NC}"
    echo "  Deterministic: validate external data, enforce schemas (prevents waste)"
    echo "  Flexible: solution paths, creative exploration (enables growth)"
    echo "  Observable: always log, always learn (enables adaptation)"
    echo ""

    # Next milestone
    local next_milestone=""
    local next_target=""
    if [[ $coverage -lt 40 ]]; then
        next_milestone="2_observable"
        next_target="40%"
    elif [[ $coverage -lt 70 ]]; then
        next_milestone="3_adaptive"
        next_target="70%"
    elif [[ $coverage -lt 90 ]]; then
        next_milestone="4_flourishing"
        next_target="90%"
    else
        next_milestone="FLOURISHING"
        next_target="maintain balance"
    fi

    echo -e "${YELLOW}NEXT MILESTONE:${NC} $next_milestone (target: $next_target)"
}

#─────────────────────────────────────────────────────────────────────────────
# MAIN AUDIT
#─────────────────────────────────────────────────────────────────────────────
run_audit() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    OBSERVABILITY WORKFLOW AUDIT                           ║${NC}"
    echo -e "${CYAN}║                         $TODAY                                      ║${NC}"
    echo -e "${CYAN}║                                                                           ║${NC}"
    echo -e "${CYAN}║  Observability enables adaptation. Flexibility enables growth.            ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Coverage
    local coverage=$(calculate_coverage)
    echo -e "${GREEN}Observability Coverage:${NC} ${coverage}%"
    echo ""

    # Count mechanisms by layer
    echo -e "${BLUE}=== OBSERVABILITY LAYERS ===${NC}"
    local scripts=$(find "$PLUGIN_ROOT/scripts" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
    local hooks=$(grep -c '"type"' "$PLUGIN_ROOT/hooks.json" 2>/dev/null || echo 0)
    local skills=$(find "$PLUGIN_ROOT/.claude/skills" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    local schemas=$(find "$PLUGIN_ROOT/observability" -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ')
    local remembrance=$(grep -c "^---$" "$PLUGIN_ROOT/.remembrance" 2>/dev/null || echo 0)

    echo "  Learning (.remembrance):  $remembrance entries"
    echo "  Flexibility (skills):     $skills patterns"
    echo "  Observability (schemas):  $schemas definitions"
    echo "  Enforcement (hooks):      $hooks (where determinism prevents waste)"
    echo "  Automation (scripts):     $scripts"
    echo ""

    # Detect failures
    local total_opportunities
    total_opportunities=$(detect_failure_patterns)

    # List open opportunities
    local open_opportunities=$(find "$OPPORTUNITIES_DIR" -name "OPP-*.yaml" -exec grep -l 'status: proposed' {} \; 2>/dev/null | wc -l | tr -d ' ')

    echo -e "${YELLOW}=== OPPORTUNITY STATUS ===${NC}"
    echo "  Open opportunities: $open_opportunities"
    echo "  Friction signals detected: $total_opportunities"
    echo ""

    # Generate audit file
    local audit_file="$AUDITS_DIR/AUDIT-$TODAY.yaml"
    cat > "$audit_file" << EOF
---
id: AUDIT-$TODAY
timestamp: $TIMESTAMP
scope: manual
auditor: workflow-audit
philosophy: "Observability enables adaptation. Determinism prevents waste. Flexibility enables growth."

observability_coverage: $coverage

layers:
  learning:
    remembrance_entries: $remembrance
    purpose: "Crystallized truths enable adaptation"
  flexibility:
    skills: $skills
    purpose: "Documented patterns guide without constraining"
  observability:
    schemas: $schemas
    purpose: "Definitions enable tracking and learning"
  enforcement:
    hooks: $hooks
    purpose: "Deterministic where it prevents waste"
  automation:
    scripts: $scripts
    purpose: "Reduce repetitive friction"

friction_signals:
  total: $total_opportunities

open_opportunities: $open_opportunities

evolution_stage: $(
    if [[ $coverage -lt 40 ]]; then echo "1_adhoc → 2_observable"
    elif [[ $coverage -lt 70 ]]; then echo "2_observable → 3_adaptive"
    elif [[ $coverage -lt 90 ]]; then echo "3_adaptive → 4_flourishing"
    else echo "4_flourishing"
    fi
)

the_balance:
  deterministic_where: "prevents waste (external validation, schemas)"
  flexible_where: "enables growth (solution paths, exploration)"
  observable_always: "enables learning"
---
EOF

    echo -e "${GREEN}Audit saved:${NC} $audit_file"
    echo ""

    # Show evolution
    show_evolution
}

#─────────────────────────────────────────────────────────────────────────────
# LIST OPPORTUNITIES
#─────────────────────────────────────────────────────────────────────────────
list_opportunities() {
    echo -e "${CYAN}=== OPEN OPPORTUNITIES ===${NC}"
    echo ""

    local count=0
    for opp in "$OPPORTUNITIES_DIR"/OPP-*.yaml; do
        if [[ -f "$opp" ]]; then
            local id=$(grep "^id:" "$opp" | cut -d: -f2 | tr -d ' ')
            local status=$(grep "^status:" "$opp" | cut -d: -f2 | tr -d ' ')
            local type=$(grep "failure_type:" "$opp" | cut -d: -f2 | tr -d ' ')

            if [[ "$status" == "proposed" ]]; then
                echo -e "  ${YELLOW}$id${NC} [$type] - $status"
                count=$((count + 1))
            fi
        fi
    done

    if [[ $count -eq 0 ]]; then
        echo "  No open opportunities."
    fi

    echo ""
    echo "Total open: $count"
}

#─────────────────────────────────────────────────────────────────────────────
# MAIN
#─────────────────────────────────────────────────────────────────────────────
case "${1:-audit}" in
    audit)
        run_audit
        ;;
    opportunities|opps)
        list_opportunities
        ;;
    evolution|evo)
        show_evolution
        ;;
    coverage)
        echo "Determinism Coverage: $(calculate_coverage)%"
        ;;
    *)
        echo "Usage: $0 [audit|opportunities|evolution|coverage]"
        echo ""
        echo "Commands:"
        echo "  audit         Run full workflow audit (default)"
        echo "  opportunities List open opportunities"
        echo "  evolution     Show evolution vector status"
        echo "  coverage      Show determinism coverage only"
        ;;
esac
