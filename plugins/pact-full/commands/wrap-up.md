---
description: Deprecated alias for /day-review. Runs the same thing and tells you the new name. Removed in the next minor.
---

# /wrap-up v0.2.0 — deprecated alias for /day-review

This command was renamed. `/wrap-up` never said what it was wrapping up, and it
read as the end of the week rather than the end of the day. The flow now names its
commands by cadence: `/week-goal`, `/day-start`, `/close-pact`, `/day-review`,
`/week-review` — and `/day-review` is the explicit twin of `/week-review`.

## What to do

1. Emit exactly this line, first, before anything else:

   ```
   /wrap-up se llama ahora /day-review
   ```

   In English: `/wrap-up is now /day-review`. One line, from the lookup table,
   never translated on the spot. No explanation, no apology, no migration notes.

2. Then run `/day-review` in full: read `commands/day-review.md` in this plugin
   and follow it exactly, including its block, its capture turn and its
   prohibitions. The behaviour is identical — only the name changed.

3. If you cannot read that file, do not improvise the block from memory, and do
   not write anything to Pact. Say in one line that the command is now
   `/day-review` and ask the user to run it.

## What this alias never does

**Do not do any of the following.**

- No reproducing the block from memory instead of reading `day-review.md`.
- No adding anything to the deprecation line — not why, not when it goes away.
- No emitting the line more than once, and never inside the block.
- No writing to Pact on the fallback path of step 3.

Removed in the next minor. Until then it keeps working exactly as before.
