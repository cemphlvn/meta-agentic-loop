#!/usr/bin/env bash
# Ecosystem Initialization Script
# Splits repository into meta-agentic-loop (plugin) and user instance
# 2026 Best Practices: Master accessor pattern, CEI bridge, fork workflow

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[INIT]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="${PROJECT_ROOT}/ecosystem.config.yaml"

# Default values
PLUGIN_REPO_NAME="meta-agentic-loop"
PLUGIN_REPO_PATH=""
INSTANCE_NAME=""
GITHUB_USERNAME=""
IS_MASTER="false"
ECOSYSTEM_MODE=""  # humanitic | private

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Initialize the meta-agentic-loop ecosystem.

OPTIONS:
    --master                    Initialize as master accessor (your machine)
    --instance <name>           Initialize as user instance
    --plugin-path <path>        Path for plugin repository
    --github-user <username>    GitHub username for contributions
    --humanitic                 Join Humanitic Ecosystem (open, collaborative)
    --private                   Private/proprietary mode
    --help                      Show this help message

ECOSYSTEM MODES:
    Humanitic Ecosystem (--humanitic):
        - Forever open-source, collaborative
        - Contributions tracked via _vectors
        - Curiosity owners rewarded by contribution degree
        - Companies founded from curiosities credit original vectors
        - Free mutual support between ecosystem members

    Private Mode (--private):
        - Traditional proprietary licensing
        - No contribution tracking to ecosystem
        - Independent operation

ACCESS MODES:
    Master Mode (--master):
        - Full read/write access to all files
        - Can approve/reject contributions
        - Manages plugin repository

    Instance Mode (--instance):
        - User cockpit with curiosity development
        - Suggests changes via CEI → GitHub PR
        - Fork-based contribution workflow

EXAMPLES:
    # Initialize as master in Humanitic Ecosystem
    ./init-ecosystem.sh --master --humanitic --github-user myusername

    # Initialize as instance in Humanitic Ecosystem
    ./init-ecosystem.sh --instance "my-project" --humanitic --github-user contributor

    # Initialize as private instance
    ./init-ecosystem.sh --instance "my-project" --private --github-user myusername
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --master)
                IS_MASTER="true"
                shift
                ;;
            --instance)
                INSTANCE_NAME="$2"
                shift 2
                ;;
            --plugin-path)
                PLUGIN_REPO_PATH="$2"
                shift 2
                ;;
            --github-user)
                GITHUB_USERNAME="$2"
                shift 2
                ;;
            --humanitic)
                ECOSYSTEM_MODE="humanitic"
                shift
                ;;
            --private)
                ECOSYSTEM_MODE="private"
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
}

select_ecosystem_mode() {
    if [[ -n "$ECOSYSTEM_MODE" ]]; then
        return
    fi

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              SELECT ECOSYSTEM MODE                            ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "  [1] HUMANITIC ECOSYSTEM (Recommended)"
    echo "      ├── Forever open-source, collaborative"
    echo "      ├── Contributions tracked via _vectors"
    echo "      ├── Curiosity founders rewarded by contribution degree"
    echo "      ├── Companies credit original vectors"
    echo "      └── Free mutual support between members"
    echo ""
    echo "  [2] PRIVATE"
    echo "      ├── Traditional proprietary licensing"
    echo "      ├── No contribution tracking"
    echo "      └── Independent operation"
    echo ""

    while true; do
        read -rp "Select mode [1/2]: " MODE_CHOICE
        case $MODE_CHOICE in
            1)
                ECOSYSTEM_MODE="humanitic"
                break
                ;;
            2)
                ECOSYSTEM_MODE="private"
                break
                ;;
            *)
                echo "Please enter 1 or 2"
                ;;
        esac
    done

    success "Ecosystem mode: $ECOSYSTEM_MODE"
}

check_dependencies() {
    log "Checking dependencies..."

    local deps=(git node pnpm)
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error "Required dependency not found: $dep"
        fi
    done

    # Check Node version
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ "$NODE_VERSION" -lt 20 ]]; then
        error "Node.js 20+ required (found: $(node -v))"
    fi

    success "All dependencies found"
}

create_ecosystem_config() {
    log "Creating ecosystem configuration..."

    if [[ "$IS_MASTER" == "true" ]]; then
        # Master config references available instances
        cat > "$CONFIG_FILE" << EOF
# Ecosystem Configuration (Master)
# Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

ecosystem:
  name: meta-agentic-loop
  version: 1.0.0

instances:
  humanitic:
    path: "./instances/humanitic"
    license: "Humanitic Open License v1.0"
    description: "Open collaborative ecosystem with founder rewards"

instance:
  name: "master"
  type: "master"
  github_user: "${GITHUB_USERNAME}"

plugin:
  repository: "${PLUGIN_REPO_NAME}"
  path: "${PLUGIN_REPO_PATH:-./plugin}"
  upstream: "https://github.com/${GITHUB_USERNAME}/${PLUGIN_REPO_NAME}"

contribution:
  method: cei-to-github
  workflow: fork-pr
  auto_create_pr: true
  track_vectors: true

permissions:
  governance:
    read: all
    write: master-only
  culture:
    read: all
    write: master-only
    suggest: all
  agents:
    read: all
    write: master-only
    propose: all
EOF
    else
        # User instance config
        cat > "$CONFIG_FILE" << EOF
# Ecosystem Configuration (Instance)
# Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

ecosystem:
  name: meta-agentic-loop
  version: 1.0.0
  mode: "${ECOSYSTEM_MODE}"

instance:
  name: "${INSTANCE_NAME}"
  type: "instance"
  github_user: "${GITHUB_USERNAME}"
  ecosystem_mode: "${ECOSYSTEM_MODE}"

plugin:
  repository: "${PLUGIN_REPO_NAME}"
  path: "${PLUGIN_REPO_PATH:-./plugin}"
  upstream: "https://github.com/${GITHUB_USERNAME}/${PLUGIN_REPO_NAME}"

contribution:
  method: cei-to-github
  workflow: fork-pr
  auto_create_pr: true
  track_vectors: $([ "$ECOSYSTEM_MODE" = "humanitic" ] && echo "true" || echo "false")
EOF

        # If humanitic mode, copy instance template
        if [[ "$ECOSYSTEM_MODE" == "humanitic" ]]; then
            log "Linking to Humanitic Ecosystem..."
            echo "" >> "$CONFIG_FILE"
            echo "# Joined Humanitic Ecosystem" >> "$CONFIG_FILE"
            echo "# See: instances/humanitic/ for license and docs" >> "$CONFIG_FILE"
            echo "humanitic_member: true" >> "$CONFIG_FILE"
        fi
    fi

    success "Configuration created: $CONFIG_FILE"
}

init_master() {
    log "Initializing as MASTER accessor..."

    # Create master-specific directories
    mkdir -p "${PROJECT_ROOT}/.master"

    # Create master lock file
    cat > "${PROJECT_ROOT}/.master/MASTER.lock" << EOF
# Master Accessor Lock
# This machine has full read/write access

master: true
created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
user: ${GITHUB_USERNAME}
hostname: $(hostname)

capabilities:
  - governance_write
  - culture_write
  - agent_creation
  - cei_approve
  - cei_veto
  - contribution_merge
EOF

    # Update .gitignore to exclude master lock
    if ! grep -q ".master/" "${PROJECT_ROOT}/.gitignore" 2>/dev/null; then
        echo -e "\n# Master accessor (local only)\n.master/" >> "${PROJECT_ROOT}/.gitignore"
    fi

    success "Master accessor initialized"
}

init_instance() {
    log "Initializing user instance: ${INSTANCE_NAME}..."

    # Ensure user directory exists
    mkdir -p "${PROJECT_ROOT}/user"
    mkdir -p "${PROJECT_ROOT}/user/curiosities"
    mkdir -p "${PROJECT_ROOT}/user/CEI_STRUCTURE/proposals"
    mkdir -p "${PROJECT_ROOT}/user/CEI_STRUCTURE/queue"

    # Create instance profile
    cat > "${PROJECT_ROOT}/user/profile.yaml" << EOF
# User Instance Profile
# Instance: ${INSTANCE_NAME}

user:
  instance_name: "${INSTANCE_NAME}"
  github_user: "${GITHUB_USERNAME}"
  created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

preferences:
  cognitive_frame: unified
  verbosity: standard
  contribution_mode: fork-pr

upstream:
  plugin_repo: "${PLUGIN_REPO_NAME}"
  owner: "${GITHUB_USERNAME}"
  fork: true

cei:
  auto_submit: false
  require_confirmation: true
EOF

    success "User instance initialized: ${INSTANCE_NAME}"
}

setup_git_hooks() {
    log "Setting up git hooks..."

    local hooks_dir="${PROJECT_ROOT}/.git/hooks"

    if [[ ! -d "$hooks_dir" ]]; then
        warn "Not a git repository, skipping git hooks"
        return
    fi

    # Pre-push hook to validate governance files
    cat > "${hooks_dir}/pre-push" << 'EOF'
#!/usr/bin/env bash
# Validate governance files are not pushed by non-master

MASTER_LOCK=".master/MASTER.lock"
GOVERNANCE_PATTERN=".claude/governance/"

if [[ ! -f "$MASTER_LOCK" ]]; then
    # Check if governance files are being pushed
    CHANGED=$(git diff --cached --name-only | grep "$GOVERNANCE_PATTERN" || true)
    if [[ -n "$CHANGED" ]]; then
        echo "ERROR: Cannot push governance changes from non-master instance"
        echo "Use CEI to propose governance changes instead."
        exit 1
    fi
fi

exit 0
EOF
    chmod +x "${hooks_dir}/pre-push"

    success "Git hooks configured"
}

setup_cei_bridge() {
    log "Setting up CEI → GitHub bridge..."

    # Create the bridge script
    cat > "${PROJECT_ROOT}/scripts/cei-bridge.sh" << 'BRIDGESCRIPT'
#!/usr/bin/env bash
# CEI to GitHub Bridge
# Triggers GitHub workflow when CEI suggestion is approved

set -euo pipefail

SUGGESTION_ID="$1"
SUGGESTION_TYPE="${2:-general}"
TARGET_FILE="${3:-}"

if [[ -z "$SUGGESTION_ID" ]]; then
    echo "Usage: cei-bridge.sh <suggestion_id> [type] [target_file]"
    exit 1
fi

# Load config
CONFIG_FILE="ecosystem.config.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: ecosystem.config.yaml not found. Run init-ecosystem.sh first."
    exit 1
fi

# Get GitHub token from environment or gh cli
GITHUB_TOKEN="${GITHUB_TOKEN:-$(gh auth token 2>/dev/null || true)}"
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "ERROR: GITHUB_TOKEN not set and gh cli not authenticated"
    exit 1
fi

# Get repository info
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
    echo "ERROR: Could not determine repository"
    exit 1
fi

echo "Triggering CEI contribution workflow..."
echo "  Suggestion: $SUGGESTION_ID"
echo "  Type: $SUGGESTION_TYPE"
echo "  Repository: $REPO"

# Trigger repository dispatch
curl -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${REPO}/dispatches" \
    -d "{
        \"event_type\": \"cei-suggestion-approved\",
        \"client_payload\": {
            \"suggestion_id\": \"${SUGGESTION_ID}\",
            \"suggestion_type\": \"${SUGGESTION_TYPE}\",
            \"target_file\": \"${TARGET_FILE}\"
        }
    }"

echo "Workflow triggered successfully!"
BRIDGESCRIPT
    chmod +x "${PROJECT_ROOT}/scripts/cei-bridge.sh"

    success "CEI bridge configured"
}

extract_plugin() {
    log "Extracting plugin-only files..."

    local plugin_dir="${PLUGIN_REPO_PATH:-${PROJECT_ROOT}/plugin}"
    mkdir -p "$plugin_dir"

    # Files that belong to the plugin (template/framework)
    local plugin_files=(
        ".claude/CORE_LOOP.md"
        ".claude/SCOPED_REMEMBRANCE.md"
        ".claude/agents/AGENT_CREATION_METHODOLOGY.md"
        ".claude/agents/INDEX.md"
        ".claude/governance/GOVERNANCE.md"
        ".claude/governance/meta-principles.md"
        ".claude/governance/curiosity-of-curiosity.md"
        ".claude/governance/policies.md"
        ".claude/governance/ethics.md"
        ".claude/skills/"
        "scripts/hooks/scoped-remembrance.js"
        "scripts/hooks/governance-lock.py"
        "processes/"
        "user/USER_COCKPIT.md"
        "user/CEI_STRUCTURE/CEI.md"
        "user/CEI_STRUCTURE/maintenance/MAINTENANCE_TEAM.md"
        "user/curiosities/INDEX.md"
    )

    log "Plugin files would be copied to: $plugin_dir"
    log "Run with --extract to actually copy files"

    success "Plugin extraction configured"
}

print_next_steps() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "                    ECOSYSTEM INITIALIZED"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    # Show ecosystem mode
    if [[ "$ECOSYSTEM_MODE" == "humanitic" ]]; then
        echo "┌─────────────────────────────────────────────────────────────┐"
        echo "│  HUMANITIC ECOSYSTEM                                        │"
        echo "├─────────────────────────────────────────────────────────────┤"
        echo "│  ✓ Forever open-source                                      │"
        echo "│  ✓ Contributions tracked via _vectors                       │"
        echo "│  ✓ Curiosity founders rewarded by contribution             │"
        echo "│  ✓ Companies credit original vectors                        │"
        echo "│  ✓ Free mutual support between members                      │"
        echo "└─────────────────────────────────────────────────────────────┘"
        echo ""
    else
        echo "Mode: PRIVATE"
        echo ""
    fi

    if [[ "$IS_MASTER" == "true" ]]; then
        echo "Access: MASTER ACCESSOR"
        echo ""
        echo "You have full control over:"
        echo "  - Governance files (meta-principles, policies, ethics)"
        echo "  - Culture propagation"
        echo "  - Agent creation"
        echo "  - CEI approval/veto"
        echo ""
        echo "Next steps:"
        echo "  1. Push to GitHub: git push origin main"
        echo "  2. Enable GitHub Actions in repository settings"
        echo "  3. Contributors can fork and submit suggestions"
        echo "  4. Review suggestions with: /cei review"

        if [[ "$ECOSYSTEM_MODE" == "humanitic" ]]; then
            echo ""
            echo "Humanitic Rewards:"
            echo "  - Your curiosity _vectors tracked"
            echo "  - Contributors to your repo credited"
            echo "  - Founded companies credit contribution chain"
        fi
    else
        echo "Access: USER INSTANCE (${INSTANCE_NAME})"
        echo ""
        echo "You can:"
        echo "  - Develop curiosities: /curiosity new <name>"
        echo "  - Suggest changes: /cei propose"
        echo "  - View your culture: /culture"
        echo ""
        echo "To contribute to meta-agentic-loop:"
        echo "  1. Fork the repository on GitHub"
        echo "  2. Create suggestion: /cei propose"
        echo "  3. Approve locally: /cei approve <id>"
        echo "  4. Bridge to GitHub: ./scripts/cei-bridge.sh <id>"

        if [[ "$ECOSYSTEM_MODE" == "humanitic" ]]; then
            echo ""
            echo "Humanitic Benefits:"
            echo "  - Your curiosity _vectors tracked for rewards"
            echo "  - Contributions credited to ecosystem"
            echo "  - Use other Humanitic repos freely"
            echo "  - Mutual support from ecosystem members"
        fi
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════════════"
}

main() {
    parse_args "$@"

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║            META-AGENTIC-LOOP ECOSYSTEM INITIALIZER            ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    check_dependencies

    if [[ -z "$GITHUB_USERNAME" ]]; then
        warn "No GitHub username provided. Some features disabled."
    fi

    # Select ecosystem mode (humanitic vs private)
    select_ecosystem_mode

    create_ecosystem_config

    if [[ "$IS_MASTER" == "true" ]]; then
        init_master
    elif [[ -n "$INSTANCE_NAME" ]]; then
        init_instance
    else
        warn "No mode specified. Use --master or --instance <name>"
    fi

    setup_git_hooks
    setup_cei_bridge

    print_next_steps
}

main "$@"
