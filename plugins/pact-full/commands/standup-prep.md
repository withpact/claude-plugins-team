---
description: Deprecated alias for /day-start. Runs the same thing and tells you the new name. Removed in the next minor.
---

# /standup-prep v0.2.0 — deprecated alias for /day-start

This command was renamed. The weekly flow now names its commands by the cadence
they run on, so the `/` menu teaches the rhythm of the week without a manual:
`/week-goal`, `/day-start`, `/close-pact`, `/day-review`, `/week-review`.

## What to do

1. Emit exactly this line, first, before anything else:

   ```
   /standup-prep se llama ahora /day-start
   ```

   In English: `/standup-prep is now /day-start`. One line, from the lookup table,
   never translated on the spot. No explanation, no apology, no migration notes.

2. Then run `/day-start` in full: read `commands/day-start.md` in this plugin and
   follow it exactly, including its block, its line formats and its prohibitions.
   The behaviour is identical — only the name changed.

3. If you cannot read that file, do not improvise the block from memory. Say in
   one line that the command is now `/day-start` and ask the user to run it.

## What this alias never does

**Do not do any of the following.**

- No reproducing the block from memory instead of reading `day-start.md`.
- No adding anything to the deprecation line — not why, not when it goes away.
- No emitting the line more than once, and never inside the block.
- No treating this as a different command: same data calls, same output, same
  prohibitions.

Removed in the next minor. Until then it keeps working exactly as before.
