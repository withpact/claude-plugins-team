# `pact-full` hooks

Pact etiquette as **mechanism**, not instruction.

`pact-code` tells the model to log what it did to a bead. Until v0.14.0 nothing
happened when it didn't — and a coding session that leaves no trace in Pact
makes the project silently out of date, which is exactly the question clients
pay for ("what got done?"). This folder is the enforcement side of that skill.

Only `pact-full` ships hooks. The client bundle (`pact/`) has no `pact-code`
and no business running scripts on a founder's laptop.

| File | What it is |
|------|------------|
| `hooks.json` | Hook manifest. One `Stop` entry, 10s timeout, `${CLAUDE_PLUGIN_ROOT}`-relative command. |
| `scripts/stop-bead-check.sh` | The hook. POSIX `sh` + `grep`/`sed`/`git`, no other dependencies. |
| `tests/run-tests.sh` | 13 tests, same dependency rule. Run with `sh pact-skills/pact-full/hooks/tests/run-tests.sh`. |

## What the Stop hook does

At the end of a Claude Code turn it asks three questions and stays silent
unless **all three** point the same way:

1. **Did this session use Pact at all?** Matched on the tool-name suffix
   (`mcp__<anything>__get_bead`, `…__whats_new`, …) because the MCP server
   prefix differs per install (`mcp__beads__…` vs
   `mcp__claude_ai_Pact_MCP__…`). No Pact call → this is somebody else's repo,
   say nothing.
2. **Was anything written back?** A `comment_on_bead` / `add_note` /
   `update_status` / `create_bead` / `update_bead` anywhere in the transcript
   ends it — the work is already logged.
3. **Did anything actually change?** Uncommitted files, or commits since the
   baseline `HEAD` captured at the session's *first* `Stop`.

Read + changed + not logged → it blocks the stop **once** and asks the model to
log what happened, explicitly instructing it to say *"this belongs to no
pact"* rather than invent one. Everything else is silence.

Guards, all failing quiet (`exit 0`): `stop_hook_active` (never stack a block
on our own), a non-empty `agent_id` (a subagent finishing is not the user
finishing), unreadable transcript, non-git `cwd`, malformed stdin, and the
first `Stop` of a session (which only records the git baseline — judging then
would just measure whatever was already on disk).

Per-session state lives in `${CLAUDE_PLUGIN_DATA:-$TMPDIR}/pact-stop-check/<session-id>`
and holds `BASE=<sha>` plus a `NUDGED=1` flag, which is what makes it
at-most-once per session.

## Why it looks like this

- **Zero runtime dependencies.** The JSON on stdin is parsed with `sed`, not
  `jq` — `jq` is not on macOS by default, so a hook needing it would fail every
  turn and the fix would be "install jq first", which is precisely the friction
  we are removing. Python and node are not guaranteed on a client machine
  either.
- **Opt-out by env var, not `userConfig`.** `PACT_STOP_HOOK=off` costs nobody
  anything until they want it; `userConfig` prompts the user at enable time.
- **Conservative scoping.** A session with no Pact call at all is left alone,
  even if code changed. The plugin is user-scope, so its hooks fire in *every*
  session including someone's weekend project, and "it nagged me in a repo that
  has nothing to do with you" costs more than a missed reminder. This is a
  deliberate trade-off to revisit as user volume grows — the alternative
  (nudge whenever code changed) would also catch the engineer who never opens
  Pact, which is the other half of the problem.

## Release gotchas

- **Hooks do not reload mid-session.** Unlike `SKILL.md`, a hook change reaches
  users only on `/reload-plugins` or a new session. Plan announcements
  accordingly.
- **The exec bit is part of the artifact.** The published script must be
  `100755`; a lost exec bit installs a hook that silently never runs, and
  nothing surfaces the failure. Verify it on the marketplace repo after
  publishing, not just locally.
- **Version collisions do not show up as git conflicts.** Two branches bumping
  `plugin.json` to the same number auto-merge clean (identical string on both
  sides) and only `CHANGELOG.md` conflicts — publishing two different bundles
  under one number, which `VERSIONING.md` forbids and which breaks the update
  notice. `scripts/check-plugin-versions.py` is the only thing that catches
  this class; run it before release.

## Performance

Transcript scanning is two `grep -E` passes, so it scales with transcript size:
~53ms on a real 2MB session transcript, well inside the 10s timeout.

## History

Shipped in `pact-full` v0.14.0 (PactMD PR #380, merged 2026-08-05) under
PACT-1066, serving PACT-0977 (integrity of execution).

Candidates deliberately **not** built yet, recorded so they are not
re-litigated from scratch:

- **`SessionStart` injecting the message box** — higher value in principle, but
  hooks are separate processes and do not inherit the session's MCP
  connection, so it needs a credential story first.
- **`PreToolUse` gate on `update_status`** — reject non-outcome closes like
  "completed PACT-1234".
