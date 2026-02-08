---
description: Session trace management
allowed-tools: Bash(bash:*)
argument-hint: [subcommand]
---

# /mal-session — Session Trace Management

!`bash -c '
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-/Users/cem/humanitic/plugin}"
TRACE_DIR="$PLUGIN_ROOT/observability/agent-trace"
SESSION_FILE="/tmp/claude_trace_session"
SUBCMD="${1:-id}"

case "$SUBCMD" in
    id)
        if [ -f "$SESSION_FILE" ]; then
            echo "═══ CURRENT SESSION TRACE ═══"
            cat "$SESSION_FILE"
        else
            TRACE_ID=$(openssl rand -hex 16)
            echo "$TRACE_ID" > "$SESSION_FILE"
            echo "═══ NEW SESSION TRACE ═══"
            echo "Initialized: $TRACE_ID"
        fi
        ;;
    traces)
        echo "═══ ALL TRACE IDs ═══"
        grep -h "^trace_id:" "$TRACE_DIR/runs/"*.yaml 2>/dev/null | sort -u | sed "s/trace_id: //" | tr -d "\"" || echo "(no traces)"
        ;;
    export)
        TRACE="${2:-$(cat "$SESSION_FILE" 2>/dev/null)}"
        if [ -z "$TRACE" ]; then
            echo "ERROR: No trace ID. Use: /mal-session export <trace_id>"
            exit 1
        fi
        echo "═══ EXPORTING TRACE: $TRACE ═══"
        echo "{\"resourceSpans\":[{\"scopeSpans\":[{\"spans\":["
        first=true
        for f in "$TRACE_DIR/runs/"*.yaml; do
            if grep -q "trace_id: \"$TRACE\"" "$f" 2>/dev/null; then
                [ "$first" = "false" ] && echo ","
                first=false
                grep -v "^---" "$f" | grep -v "^#"
            fi
        done
        echo "]}]}]}"
        ;;
    clear)
        rm -f "$SESSION_FILE"
        echo "Session trace cleared"
        ;;
    info)
        echo "═══ SESSION INFO ═══"
        echo "Session file: $SESSION_FILE"
        CURRENT=$(cat "$SESSION_FILE" 2>/dev/null || echo "Not set")
        echo "Current trace: $CURRENT"
        if [ "$CURRENT" != "Not set" ]; then
            SPANS=$(grep -l "trace_id: \"$CURRENT\"" "$TRACE_DIR/runs/"*.yaml 2>/dev/null | wc -l | tr -d " ")
            echo "Spans in session: $SPANS"
        fi
        ;;
    *)
        echo "Usage: /mal-session [id|traces|export|clear|info]"
        echo ""
        echo "Subcommands:"
        echo "  id       Show/create session trace ID (default)"
        echo "  traces   List all trace IDs"
        echo "  export   Export trace as OTel JSON"
        echo "  clear    Clear session trace"
        echo "  info     Show session info"
        ;;
esac
' -- "$1" "$2" 2>&1 || echo "SESSION_ERROR"`

Analyze session trace output above. If SESSION_ERROR appeared, check infrastructure.
