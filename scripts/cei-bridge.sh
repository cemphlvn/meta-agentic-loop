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
