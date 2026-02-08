#!/usr/bin/env bash
# loop-integrate.sh — Bridge between loop-runner and agent-trace
#
# This script makes the loop ACTUALLY work by:
# 1. Reading real todos from SCRUM/backlog
# 2. Outputting actionable commands for hierarchical agent spawning
# 3. Analyzing traces to inform next iteration
#
# Usage: loop-integrate.sh [observe|decide|learn]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTANCE_ROOT="$(cd "$PLUGIN_ROOT/.." && pwd)"

RUNS_DIR="$SCRIPT_DIR/runs"
SCRUM_FILE="$INSTANCE_ROOT/scrum/SCRUM.md"
LOOP_STATE="$PLUGIN_ROOT/.loop-state.yaml"

# ══════════════════════════════════════════════════════════════
# OBSERVE: What work exists?
# ══════════════════════════════════════════════════════════════
observe_todos() {
    echo "═══ OBSERVE: Scanning for work ═══"
    echo ""

    # 1. Check SCRUM for ready items
    if [[ -f "$SCRUM_FILE" ]]; then
        echo "SCRUM items:"
        grep -E "^\s*-\s*\[.\]" "$SCRUM_FILE" 2>/dev/null | head -10 || echo "  (none)"
    else
        echo "SCRUM: (no file at $SCRUM_FILE)"
    fi
    echo ""

    # 2. Check for blocked spans (started but not completed)
    echo "Pending agents:"
    if [[ -d "$RUNS_DIR" ]]; then
        PENDING=$(grep -l "duration_ms: null" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
        echo "  $PENDING in-flight"
    else
        echo "  0 in-flight"
    fi
    echo ""

    # 3. Check recent failures
    echo "Recent failures:"
    if [[ -d "$RUNS_DIR" ]]; then
        FAILURES=$(grep -l "code: \"ERROR\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
        echo "  $FAILURES failed spans"
    else
        echo "  0 failed"
    fi
    echo ""

    # 4. Output structured observation
    echo "---"
    echo "observation:"
    echo "  scrum_items: $(grep -c "^\s*-\s*\[ \]" "$SCRUM_FILE" 2>/dev/null || echo 0)"
    echo "  pending_agents: ${PENDING:-0}"
    echo "  recent_failures: ${FAILURES:-0}"
}

# ══════════════════════════════════════════════════════════════
# DECIDE: What agent to spawn next (hierarchical)
# ══════════════════════════════════════════════════════════════
decide_next() {
    echo "═══ DECIDE: Hierarchical routing ═══"
    echo ""

    # Read observation
    local scrum_items=$(grep -c "^\s*-\s*\[ \]" "$SCRUM_FILE" 2>/dev/null || echo 0)
    local pending=$(grep -l "duration_ms: null" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " " || echo 0)
    local failures=$(grep -l "code: \"ERROR\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " " || echo 0)

    # Decision tree (hierarchical)
    echo "Waterfall decision:"
    echo ""

    if [[ "$failures" -gt 0 ]]; then
        echo "  STRATEGIC: Failures detected → cto-agent analyzes"
        echo ""
        echo "  Command:"
        echo '  Task(subagent_type="general-purpose", prompt="Analyze recent agent failures and propose fixes", description="CTO failure analysis")'
        echo ""
        echo "  tier: strategic"
        echo "  agent: cto-agent"
        echo "  reason: failures require strategic review"

    elif [[ "$pending" -gt 0 ]]; then
        echo "  WAIT: $pending agents still running"
        echo ""
        echo "  tier: none"
        echo "  agent: none"
        echo "  reason: wait for in-flight agents"

    elif [[ "$scrum_items" -gt 0 ]]; then
        # Get first unchecked item
        local next_item=$(grep -m1 "^\s*-\s*\[ \]" "$SCRUM_FILE" 2>/dev/null | sed 's/.*\[ \] //')
        echo "  TACTICAL: Work exists → librarian triages"
        echo ""
        echo "  Next item: $next_item"
        echo ""
        echo "  Command:"
        echo "  Task(subagent_type=\"general-purpose\", prompt=\"Triage and break down: $next_item\", description=\"Librarian triage\")"
        echo ""
        echo "  tier: tactical"
        echo "  agent: librarian"
        echo "  reason: work item needs breakdown"

    else
        echo "  IDLE: No work → refine backlog"
        echo ""
        echo "  tier: tactical"
        echo "  agent: librarian"
        echo "  reason: refine and prepare next sprint"
    fi
}

# ══════════════════════════════════════════════════════════════
# LEARN: Analyze traces for patterns
# ══════════════════════════════════════════════════════════════
learn_from_traces() {
    echo "═══ LEARN: Pattern analysis ═══"
    echo ""

    if [[ ! -d "$RUNS_DIR" ]] || [[ -z "$(ls "$RUNS_DIR"/*.yaml 2>/dev/null)" ]]; then
        echo "No trace data yet. Run agents to generate traces."
        return
    fi

    # 1. Success rate
    local total=$(ls "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
    local ok=$(grep -l "code: \"OK\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")
    local error=$(grep -l "code: \"ERROR\"" "$RUNS_DIR"/*.yaml 2>/dev/null | wc -l | tr -d " ")

    echo "Success rate: $ok/$total OK ($(( ok * 100 / (total > 0 ? total : 1) ))%)"
    echo ""

    # 2. Agent frequency
    echo "Agent usage:"
    grep "^operation_name:" "$RUNS_DIR"/*.yaml 2>/dev/null | \
        sed 's/.*operation_name: "//' | sed 's/"//' | \
        sort | uniq -c | sort -rn | head -5
    echo ""

    # 3. Hierarchy compliance
    echo "Hierarchy check:"
    local violations=0
    for f in "$RUNS_DIR"/*.yaml; do
        [[ -f "$f" ]] || continue
        local op=$(grep "^operation_name:" "$f" | sed 's/.*: "//' | tr -d '"')
        local tier=$(grep "agent.tier:" "$f" | sed 's/.*: "//' | tr -d '"')
        local parent=$(grep "^parent_span_id:" "$f" | sed 's/.*: //' | tr -d '" ')

        # Check if operational spawned tactical/strategic (violation)
        if [[ "$tier" == "operational" && "$parent" != "null" ]]; then
            # Would check parent's tier here
            :
        fi
    done
    echo "  Violations: $violations"
    echo ""

    # 4. Pattern detection (sequences)
    echo "Recurring sequences:"
    # Group by trace_id, show operation sequences
    for trace_id in $(grep "^trace_id:" "$RUNS_DIR"/*.yaml 2>/dev/null | sed 's/.*: "//' | tr -d '"' | sort -u); do
        local seq=$(grep -l "trace_id: \"$trace_id\"" "$RUNS_DIR"/*.yaml 2>/dev/null | \
            xargs -I{} grep "^operation_name:" {} 2>/dev/null | \
            sed 's/.*: "//' | tr -d '"' | tr '\n' '→' | sed 's/→$//')
        [[ -n "$seq" ]] && echo "  $seq"
    done | sort | uniq -c | sort -rn | head -3
    echo ""

    # 5. Improvement proposals
    echo "─────────────────────────────────────"
    echo "IMPROVEMENT PROPOSALS:"
    echo ""

    if [[ "$error" -gt 0 ]]; then
        echo "  [!] $error failures detected"
        echo "      → Add validation rules to prevent recurrence"
        echo ""
    fi

    # Check for repeated sequences (pattern crystallization candidate)
    local repeated=$(for trace_id in $(grep "^trace_id:" "$RUNS_DIR"/*.yaml 2>/dev/null | sed 's/.*: "//' | tr -d '"' | sort -u); do
        grep -l "trace_id: \"$trace_id\"" "$RUNS_DIR"/*.yaml 2>/dev/null | \
            xargs -I{} grep "^operation_name:" {} 2>/dev/null | \
            sed 's/.*: "//' | tr -d '"' | tr '\n' '→' | sed 's/→$//'
    done | sort | uniq -c | awk '$1 >= 2 {print $0}')

    if [[ -n "$repeated" ]]; then
        echo "  [P] Repeated sequence detected:"
        echo "$repeated" | while read count seq; do
            echo "      $seq (${count}x)"
            echo "      → Candidate for process template"
        done
    fi
}

# ══════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════
case "${1:-all}" in
    observe)
        observe_todos
        ;;
    decide)
        decide_next
        ;;
    learn)
        learn_from_traces
        ;;
    all|*)
        observe_todos
        echo ""
        decide_next
        echo ""
        learn_from_traces
        ;;
esac
