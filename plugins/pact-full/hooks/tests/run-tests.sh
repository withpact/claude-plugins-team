#!/bin/sh
# Tests for the Pact Stop hook. Same rule as the hook itself: POSIX sh only,
# no jq/python/node, so this runs anywhere the hook does.
#
#   sh pact-skills/pact-full/hooks/tests/run-tests.sh

set -u

HOOK_DIR=$(cd "$(dirname "$0")/.." && pwd)
HOOK="$HOOK_DIR/scripts/stop-bead-check.sh"
WORK="${TMPDIR:-/tmp}/pact-stop-hook-tests.$$"
PASS=0
FAIL=0

cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

mkdir -p "$WORK" || exit 1

# --- fixtures --------------------------------------------------------------

# A git repo with one commit, plus an uncommitted edit.
make_repo() {
    repo="$WORK/$1"
    mkdir -p "$repo"
    git -C "$repo" init -q 2>/dev/null
    printf 'v1\n' >"$repo/app.py"
    git -C "$repo" add app.py
    git -C "$repo" -c user.email=t@t -c user.name=t commit -qm init
    printf '%s' "$repo"
}

dirty_repo() {
    repo=$(make_repo "$1")
    printf 'v2\n' >>"$repo/app.py"
    printf '%s' "$repo"
}

# Transcript lines shaped like the real thing. Server prefix varies per
# install, so the fixtures deliberately use two different ones.
transcript() {
    path="$WORK/$1.jsonl"
    shift
    : >"$path"
    for tool in "$@"; do
        printf '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"%s"}]}}\n' \
            "$tool" >>"$path"
    done
    printf '%s' "$path"
}

# --- harness ---------------------------------------------------------------

# run <name> <transcript> <cwd> <extra-json-fields>
run() {
    printf '{"session_id":"%s","transcript_path":"%s","cwd":"%s","hook_event_name":"Stop"%s}' \
        "$1" "$2" "$3" "$4" | sh "$HOOK" 2>/dev/null
}

check() {
    label="$1"
    expected="$2" # "silent" | "block"
    actual="$3"
    case "$expected" in
        silent)
            if [ -z "$actual" ]; then
                PASS=$((PASS + 1))
                printf '  ok   %s\n' "$label"
            else
                FAIL=$((FAIL + 1))
                printf '  FAIL %s -- expected silence, got: %s\n' "$label" "$actual"
            fi
            ;;
        block)
            if printf '%s' "$actual" | grep -q '"decision":"block"'; then
                PASS=$((PASS + 1))
                printf '  ok   %s\n' "$label"
            else
                FAIL=$((FAIL + 1))
                printf '  FAIL %s -- expected a block, got: %s\n' "$label" "$actual"
            fi
            ;;
    esac
}

# Each test gets its own plugin-data dir so session state never leaks.
fresh_state() {
    CLAUDE_PLUGIN_DATA="$WORK/state.$1"
    export CLAUDE_PLUGIN_DATA
}

READ_ONLY=$(transcript read_only mcp__beads__whats_new mcp__beads__get_bead)
WROTE=$(transcript wrote mcp__beads__get_bead mcp__beads__comment_on_bead)
NO_PACT=$(transcript no_pact Bash Read Edit)
CONNECTOR=$(transcript connector mcp__claude_ai_Pact_MCP__whats_new)

printf 'Pact Stop hook\n'

# 1. The first Stop of a session only records the git baseline.
fresh_state 1
REPO=$(dirty_repo r1)
check "first stop of a session stays quiet (baseline)" silent \
    "$(run s1 "$READ_ONLY" "$REPO" '')"

# 2. Second Stop, work touched, nothing logged -> speak.
check "unlogged work after reading a bead is flagged" block \
    "$(run s1 "$READ_ONLY" "$REPO" '')"

# 3. ...but only once per session.
check "does not flag the same session twice" silent \
    "$(run s1 "$READ_ONLY" "$REPO" '')"

# 4. A session that wrote to a bead is left alone.
fresh_state 4
REPO=$(dirty_repo r4)
run s4 "$WROTE" "$REPO" '' >/dev/null
check "session that logged to a bead is left alone" silent \
    "$(run s4 "$WROTE" "$REPO" '')"

# 5. Somebody else's repo: no Pact activity at all, so not our business.
fresh_state 5
REPO=$(dirty_repo r5)
run s5 "$NO_PACT" "$REPO" '' >/dev/null
check "non-Pact session is never touched" silent \
    "$(run s5 "$NO_PACT" "$REPO" '')"

# 6. Read a bead, changed nothing -> nothing to report.
fresh_state 6
REPO=$(make_repo r6)
run s6 "$READ_ONLY" "$REPO" '' >/dev/null
check "clean tree produces no nudge" silent \
    "$(run s6 "$READ_ONLY" "$REPO" '')"

# 7. The claude.ai connector prefix is recognised too.
fresh_state 7
REPO=$(dirty_repo r7)
run s7 "$CONNECTOR" "$REPO" '' >/dev/null
check "claude.ai connector tool names are recognised" block \
    "$(run s7 "$CONNECTOR" "$REPO" '')"

# 8. Never stack a block on top of our own.
fresh_state 8
REPO=$(dirty_repo r8)
run s8 "$READ_ONLY" "$REPO" '' >/dev/null
check "respects stop_hook_active" silent \
    "$(run s8 "$READ_ONLY" "$REPO" ',"stop_hook_active":true')"

# 9. A subagent finishing is not the user finishing.
fresh_state 9
REPO=$(dirty_repo r9)
run s9 "$READ_ONLY" "$REPO" '' >/dev/null
check "ignores subagent stops" silent \
    "$(run s9 "$READ_ONLY" "$REPO" ',"agent_id":"agent-123"')"

# 10. Opt-out is absolute.
fresh_state 10
REPO=$(dirty_repo r10)
run s10 "$READ_ONLY" "$REPO" '' >/dev/null
check "PACT_STOP_HOOK=off silences it" silent \
    "$(PACT_STOP_HOOK=off run s10 "$READ_ONLY" "$REPO" '')"

# 11. Outside a git repo there is no work to measure.
fresh_state 11
mkdir -p "$WORK/plain"
run s11 "$READ_ONLY" "$WORK/plain" '' >/dev/null
check "non-git directory is ignored" silent \
    "$(run s11 "$READ_ONLY" "$WORK/plain" '')"

# 12. Garbage in, silence out.
fresh_state 12
check "malformed input is ignored" silent \
    "$(printf 'not json' | sh "$HOOK" 2>/dev/null)"

# 13. New commits count as work even with a clean tree.
fresh_state 13
REPO=$(make_repo r13)
run s13 "$READ_ONLY" "$REPO" '' >/dev/null
printf 'v2\n' >>"$REPO/app.py"
git -C "$REPO" add app.py
git -C "$REPO" -c user.email=t@t -c user.name=t commit -qm work
check "commits made during the session count as work" block \
    "$(run s13 "$READ_ONLY" "$REPO" '')"

printf '\n%s passed, %s failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
