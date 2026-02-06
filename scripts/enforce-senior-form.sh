#!/usr/bin/env bash
# Enforce Senior Form Updates
# When types evolve, new entries must use senior form

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EVOLUTION_REGISTRY="${PROJECT_ROOT}/.evolution-registry.yaml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[SENIOR-FORM]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }

usage() {
    cat << EOF
Usage: $(basename "$0") <command> [args]

Commands:
    register <junior> <senior> [deprecated_after]
        Register a type evolution from junior to senior form

    check <file>
        Check if file uses any deprecated junior forms

    migrate <file>
        Auto-migrate file from junior to senior forms where safe

    list
        List all registered evolutions

Examples:
    $(basename "$0") register "old_pattern" "new_pattern" "2026-03-01"
    $(basename "$0") check .remembrance
    $(basename "$0") migrate instances/humanitic/librarian/_vector.yaml
EOF
}

# Initialize registry if not exists
init_registry() {
    if [[ ! -f "$EVOLUTION_REGISTRY" ]]; then
        cat > "$EVOLUTION_REGISTRY" << 'EOF'
# Type Evolution Registry
# CTO-managed: Senior forms supersede junior forms

evolutions: []

# Format:
# - junior: "old_pattern"
#   senior: "new_pattern"
#   registered: ISO-8601
#   deprecated_after: ISO-8601 or null
#   migration_safe: true/false
#   notes: "why this evolved"
EOF
        log "Created evolution registry: $EVOLUTION_REGISTRY"
    fi
}

# Register a new evolution
register_evolution() {
    local junior="$1"
    local senior="$2"
    local deprecated="${3:-}"

    init_registry

    # Check if already registered
    if grep -q "junior: \"$junior\"" "$EVOLUTION_REGISTRY" 2>/dev/null; then
        warn "Evolution already registered for: $junior"
        return 1
    fi

    # Append to registry
    cat >> "$EVOLUTION_REGISTRY" << EOF

  - junior: "$junior"
    senior: "$senior"
    registered: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
    deprecated_after: ${deprecated:-null}
    migration_safe: true
    notes: "Registered via enforce-senior-form.sh"
EOF

    success "Registered evolution: $junior → $senior"
}

# Check file for junior forms
check_file() {
    local file="$1"

    if [[ ! -f "$EVOLUTION_REGISTRY" ]]; then
        log "No evolutions registered yet"
        return 0
    fi

    local found_junior=false
    local today=$(date -u +"%Y-%m-%d")

    # Parse evolutions (simplified - in production use yq or python)
    while IFS= read -r line; do
        if [[ "$line" =~ junior:\ \"(.+)\" ]]; then
            junior="${BASH_REMATCH[1]}"
            if grep -q "$junior" "$file" 2>/dev/null; then
                warn "Found junior form in $file: $junior"
                found_junior=true
            fi
        fi
    done < "$EVOLUTION_REGISTRY"

    if [[ "$found_junior" == "false" ]]; then
        success "No deprecated junior forms found in: $file"
    else
        error "File contains deprecated junior forms. Run: $(basename "$0") migrate $file"
        return 1
    fi
}

# Migrate file to senior forms
migrate_file() {
    local file="$1"

    if [[ ! -f "$EVOLUTION_REGISTRY" ]]; then
        log "No evolutions registered"
        return 0
    fi

    log "Migrating: $file"

    local temp_file=$(mktemp)
    cp "$file" "$temp_file"

    local migrated=0

    # Parse and apply migrations (simplified)
    local junior=""
    local senior=""

    while IFS= read -r line; do
        if [[ "$line" =~ junior:\ \"(.+)\" ]]; then
            junior="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ senior:\ \"(.+)\" ]]; then
            senior="${BASH_REMATCH[1]}"
            if [[ -n "$junior" && -n "$senior" ]]; then
                if grep -q "$junior" "$temp_file" 2>/dev/null; then
                    sed -i.bak "s/$junior/$senior/g" "$temp_file"
                    log "  Migrated: $junior → $senior"
                    ((migrated++))
                fi
            fi
            junior=""
            senior=""
        fi
    done < "$EVOLUTION_REGISTRY"

    if [[ $migrated -gt 0 ]]; then
        mv "$temp_file" "$file"
        rm -f "${temp_file}.bak"
        success "Migrated $migrated patterns in $file"
    else
        rm -f "$temp_file" "${temp_file}.bak"
        log "No migrations needed"
    fi
}

# List all evolutions
list_evolutions() {
    if [[ ! -f "$EVOLUTION_REGISTRY" ]]; then
        log "No evolutions registered"
        return 0
    fi

    echo ""
    echo "Type Evolution Registry"
    echo "━━━━━━━━━━━━━━━━━━━━━━━"
    grep -E "junior:|senior:|deprecated_after:" "$EVOLUTION_REGISTRY" | \
        sed 's/^  - /\n/' | \
        sed 's/^    /  /'
    echo ""
}

# Main
case "${1:-}" in
    register)
        [[ -z "${2:-}" || -z "${3:-}" ]] && { usage; exit 1; }
        register_evolution "$2" "$3" "${4:-}"
        ;;
    check)
        [[ -z "${2:-}" ]] && { usage; exit 1; }
        check_file "$2"
        ;;
    migrate)
        [[ -z "${2:-}" ]] && { usage; exit 1; }
        migrate_file "$2"
        ;;
    list)
        list_evolutions
        ;;
    *)
        usage
        exit 1
        ;;
esac
