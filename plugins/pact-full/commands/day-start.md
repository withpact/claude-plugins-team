---
description: Open the day — what's in progress, a proposed plan for today, and unconfirmed asks quoted verbatim from bead notes. Run it first thing, or ~15 minutes before the client standup.
---

# /day-start v0.3.0 — server-rendered

**The server renders this block. You relay it. That is the whole command.**

Everything the block used to specify here — the template, the column padding,
the ordering, the truncation rules, the candidate rule, the language table —
now lives in the MCP (`services/beads-api/rendered_commands.py`) and ships with
a beads-api deploy. A fix to the format reaches every user on their next call,
with no plugin update to install.

## What to do

1. Call `render_command` with:
   - `command: "day-start"`
   - `language`: `"es"` or `"en"` — the language of THIS conversation. If it
     isn't clear, omit it (the server defaults to English).
   - `project`: only if the user is asking about a project other than the
     session's own.
2. The result comes back inside a `⟦ DISPLAY ⟧ … ⟦ END DISPLAY ⟧` fence.
   Reproduce everything between the fences **verbatim**: every heading, blank
   line, glyph, space of padding and quoted note, in the order given. Do not
   print the fence markers themselves.
3. Nothing before the block. After it, at most ONE line of normal text: offer
   to open one of the pacts cited.

## What you must not do

- **Do not rebuild the block yourself** from `list_beads` / `get_bead`. If
  `render_command` is unavailable (an older connector — the user needs to
  reconnect), say so in one line and offer `/my-pacts` instead. Do not
  improvise a substitute block: a hand-made one that looks almost right is
  worse than none, because the reader can't tell which they got.
- Do not re-order, re-word, summarize, translate, prettify or "fix" anything
  inside the fence — including padding you think is wrong. If the block looks
  wrong, that is a server bug: report it, don't patch it in the transcript.
- Do not add sections (no "Riesgos", "Wins", "Resumen ejecutivo"), turn any
  section into a table, or add bold/italics/emoji/bullets.
- Do not call `whats_new` — reading it marks messages read and the user loses
  them.
- Do not write to Pact. This command reads only.
- Do not ask the user anything before rendering. Render, and let them correct.

## What the block contains

For context only — you never assemble these yourself:

1. **En curso / In progress** — what's in flight, yours and the team's.
2. **Plan de hoy / Today's plan** — up to three proposals, each with its reason
   (due today, overdue, next milestone). A proposal, not an instruction.
3. **Necesito de alguien / Asks** — unconfirmed candidates, each a literal quote
   from a recent bead note with its date. Candidates are marked `?` and are
   never presented as confirmed blockers; a pact in a real `blocked` state is
   marked `⊘`.

The output is **for the engineer, not for the client** — it is never shared in
a meeting. Many client projects have a daily standup and this is what you run
~15 minutes before it; projects without one run it anyway.

## Out of scope

- It does not write standup notes after the meeting. Opening the day only.
- It does not close the day — that is `/day-review`.
- It does not detect wins — that is `pact-win-detection`.
- It does not issue a milestone verdict — that is `pact-stakeholder-report`.
