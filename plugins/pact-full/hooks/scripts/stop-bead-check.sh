#!/bin/sh
# Pact - Stop hook: flag code work that never made it into a bead.
#
# Zero external dependencies on purpose: POSIX sh + grep + sed + git only.
# Anything else (jq, python, node) would turn "install the plugin" into
# "install the plugin AND its prerequisites" on the user's machine.
#
# Silent by default. It speaks only when ALL of these hold:
#   1. the session actually used Pact (whats_new, get_bead, list_beads, ...)
#   2. nothing was written back to a bead (no note, no status change, no new bead)
#   3. the working tree changed, or commits landed, since the session's first turn
# Anything unexpected -> exit 0 and stay quiet. Never break someone's turn.
#
# Opt out at any time:  export PACT_STOP_HOOK=off

set -u

# --- opt-out ---------------------------------------------------------------
if [ "${PACT_STOP_HOOK:-on}" = "off" ]; then
    exit 0
fi

INPUT=$(cat 2>/dev/null) || exit 0
if [ -z "$INPUT" ]; then
    exit 0
fi

# Claude Code sets this when the turn is already continuing because a Stop hook
# blocked it. Never stack a second block on top of our own.
if printf '%s' "$INPUT" | grep -q '"stop_hook_active"[ ]*:[ ]*true'; then
    exit 0
fi

# --- read the fields we need, without a JSON parser ------------------------
# Every value we want is a plain string (uuid, absolute path), so a single
# quoted-capture is enough. If a field is missing we bail out silently.
json_str() {
    printf '%s' "$INPUT" |
        sed -n "s/.*\"$1\"[ ]*:[ ]*\"\\([^\"]*\\)\".*/\\1/p" |
        head -n 1
}

SESSION_ID=$(json_str session_id)
TRANSCRIPT=$(json_str transcript_path)
CWD=$(json_str cwd)

# A subagent finishing is not the user finishing.
AGENT_ID=$(json_str agent_id)
if [ -n "$AGENT_ID" ]; then
    exit 0
fi

if [ -z "$SESSION_ID" ] || [ -z "$TRANSCRIPT" ] || [ -z "$CWD" ]; then
    exit 0
fi
if [ ! -r "$TRANSCRIPT" ] || [ ! -d "$CWD" ]; then
    exit 0
fi
if ! git -C "$CWD" rev-parse --git-dir >/dev/null 2>&1; then
    exit 0
fi

# --- per-session state -----------------------------------------------------
# Holds the git baseline taken at the session's first Stop, and a flag so we
# speak at most once per session.
SAFE_ID=$(printf '%s' "$SESSION_ID" | tr -c 'A-Za-z0-9._-' '_')
STATE_DIR="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}}/pact-stop-check"
if ! mkdir -p "$STATE_DIR" 2>/dev/null; then
    exit 0
fi
STATE="$STATE_DIR/$SAFE_ID"

if [ -f "$STATE" ]; then
    if grep -q '^NUDGED=1' "$STATE" 2>/dev/null; then
        exit 0
    fi
    BASE=$(sed -n 's/^BASE=//p' "$STATE" 2>/dev/null | head -n 1)
else
    BASE=$(git -C "$CWD" rev-parse HEAD 2>/dev/null || echo "")
    printf 'BASE=%s\n' "$BASE" >"$STATE" 2>/dev/null || exit 0
    # First Stop of the session establishes the baseline; judging work now
    # would just be measuring whatever was already on disk.
    exit 0
fi

# --- did this session touch Pact at all? -----------------------------------
# Tool names arrive as mcp__<server>__<tool>, and <server> varies per install
# (mcp__beads__get_bead, mcp__claude_ai_Pact_MCP__whats_new, ...), so match on
# the tool suffix. No Pact activity means this is somebody else's repo and we
# have no business commenting on it.
PACT_ANY='"name":"mcp__[A-Za-z0-9_]*__(whats_new|list_beads|search_beads|get_bead|list_goals|create_bead|update_status|comment_on_bead|add_note|update_bead|reschedule_bead)"'
PACT_WRITE='"name":"mcp__[A-Za-z0-9_]*__(comment_on_bead|add_note|update_status|create_bead|update_bead)"'

if ! grep -Eq "$PACT_ANY" "$TRANSCRIPT" 2>/dev/null; then
    exit 0
fi
if grep -Eq "$PACT_WRITE" "$TRANSCRIPT" 2>/dev/null; then
    exit 0
fi

# --- did anything actually change? -----------------------------------------
DIRTY=$(git -C "$CWD" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
[ -n "$DIRTY" ] || DIRTY=0

COMMITS=0
if [ -n "$BASE" ]; then
    COMMITS=$(git -C "$CWD" rev-list --count "$BASE"..HEAD 2>/dev/null || echo 0)
fi
[ -n "$COMMITS" ] || COMMITS=0

if [ "$DIRTY" -eq 0 ] && [ "$COMMITS" -eq 0 ]; then
    exit 0
fi

# --- speak, once -----------------------------------------------------------
printf 'NUDGED=1\n' >>"$STATE" 2>/dev/null

if [ "$COMMITS" -gt 0 ]; then
    CHANGED="$DIRTY uncommitted file(s) and $COMMITS new commit(s)"
else
    CHANGED="$DIRTY uncommitted file(s)"
fi

cat <<EOF
{"decision":"block","reason":"Pact: this session read from Pact and left $CHANGED, but nothing was written back to a bead. Before you finish, log what happened: comment_on_bead on the bead this work belongs to (what changed and what it means for someone reading tomorrow, not a file list), or update_status if it is finished. If this work genuinely belongs to no bead, tell the user that in one line instead - do not invent one.","systemMessage":"Pact: work not yet logged to a bead."}
EOF

exit 0
