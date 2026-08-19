---
description: Fixed-output prep for the daily client standup — what's in progress, a proposed plan for today, and unconfirmed asks quoted verbatim from bead notes. Run it ~15 minutes before the meeting.
---

# /standup-prep v0.1.0 — the fixed-output standup brief

Produce the engineer's standup prep as ONE deterministic block. Same command,
same board, same block. The output is **for the engineer, not for the client** —
it is never shared in the meeting.

Three sections, three different sources, three different confidence levels, and
the block says so out loud. Where a Pact skill rule conflicts with this file for
this command, THIS FILE WINS — here, a fixed frame the engineer can scan in
fifteen seconds is the point, not a well-written summary.

**This command renders always, even with incomplete information, and never asks
the user anything before rendering.** It writes nothing to Pact: no status
changes, no notes, and never `whats_new` — reading that marks messages as read
and the user would lose them.

## Data — exactly these calls

1. `list_beads` with `status: in_progress` for the session's project. Split by
   assignee: the user's own go under "Tuyo", everyone else's under "Equipo".
2. `list_beads` with `due_before` = today+1 — what is due today or already overdue.
3. `list_beads` with `status: blocked` — these reach section 3 as **confirmed**,
   not as candidates.
4. `get_bead` on the results of (1) and (3) to read notes. Only notes from the
   **last 14 days**; older ones are ignored.

Never call `whats_new` from this command.

## The block

Reproduce this exactly — every heading, every blank line, every label, in this
order. Substitute only the values in `{...}`.

```
# Standup prep — {DAY} {DATE}
Proyecto: {PROJECT} · {USER_FIRST_NAME}

## En curso

Tuyo
{BEAD_LINE}
{BEAD_LINE}

Equipo
{TEAM_BEAD_LINE}
{TEAM_BEAD_LINE}

## Plan de hoy — propuesta, corrige

1. {PLAN_LINE}
2. {PLAN_LINE}
3. {PLAN_LINE}

## Necesito de alguien — candidatos sin confirmar

{ASK_BLOCK}
{ASK_BLOCK}

Nada confirmado en esta sección. Borra lo que no aplique.
```

**Everything outside `{...}` is immutable.** The only sanctioned variation is
the language of the fixed labels, via the lookup table — never a translation
produced on the spot. Headings, punctuation, blank lines and their order do not
change between runs, projects or users. If a value doesn't fit the template, the
value is wrong, not the template.

## Line formats

`{BEAD_LINE}`:

```
{GLYPH} {BEAD_ID}  {SHORT_TITLE}{PADDING}{WHEN}
```

- **GLYPH** — `◐` in_progress · `⊘` blocked · `◔` review. One character, no variants.
- Two spaces between BEAD_ID and SHORT_TITLE.
- **SHORT_TITLE** — max 32 characters, cut at a word boundary, no ellipsis.
  Rewriting is allowed for length only, never for sense.
- **PADDING** — spaces that align the WHEN column to the longest line in the block.
- **WHEN**, by precedence: `vencido {D} {mes}` if already past · `hoy` ·
  `mañana` · `{D} {mes}`.
- Order: overdue first (oldest on top), then today, then ascending by date.

`{TEAM_BEAD_LINE}` — the same, but WHEN is preceded by the assignee's first name
and ` · `:

```
{GLYPH} {BEAD_ID}  {SHORT_TITLE}{PADDING}{FIRST_NAME} · {WHEN}
```

`{PLAN_LINE}`:

```
{BEAD_ID}  {REASON}
```

- Max 3 lines, min 1. **REASON** is at most 6 words justifying the inclusion
  ("vence hoy", "vencido hace 4 días", "arranca el hito del viernes"). No
  first-person verb, no "deberías".
- Selection, in order: (a) due today, (b) overdue, (c) the nearest milestone of
  the active goal. With fewer than 3 candidates, write fewer lines — **do not pad**.

`{ASK_BLOCK}` — two lines per candidate:

```
? {BEAD_ID}  "{NOTE_EXCERPT}"
            → nota del {D} {mes} · {CHALLENGE}
```

- `?` for a candidate inferred from notes. `⊘` for a pact in a real `blocked`
  state — that one carries no CHALLENGE, it carries `→ bloqueado desde {D} {mes}`.
- **NOTE_EXCERPT** — a LITERAL fragment of the note, max 40 characters, in
  quotes. Do not paraphrase. If it doesn't fit, cut without marking the cut.
- The second line is indented to the column where NOTE_EXCERPT starts.
- **CHALLENGE** — a short question the engineer answers by discarding or keeping
  the line: "¿sigue abierto?", "¿es para el cliente?", "¿ya se resolvió?".
- Max 5 candidates. Beyond that: 5 plus a last line `+ {N} más sin revisar`.

## The candidate rule

Section 3 is the only place where this command interprets free prose, and
therefore the only place that can drift between runs. It is contained like this:

- **NEVER state that something is blocked.** The heading says "candidatos sin
  confirmar" and every line carries `?`. Do not reword either.
- **ALWAYS quote the note literally.** The engineer discards by reading the
  quote, without opening the pact. A paraphrase forces them to verify and kills
  the time saved.
- **ALWAYS include the note's date.** A note from 12 days ago probably no longer
  applies.
- **Do not infer who is being asked.** If the note names someone, the quote
  already says so. If it doesn't, do not guess.
- **Do not change any pact's status.** This command does not write to Pact.
- No candidates: keep the heading and write exactly
  `Ninguno. Si algo te falta, dilo tú en el standup.` — never drop the section.

## What this command never does

**Do not do any of the following. Format drift is additive — these are the additions that break it.**

- No sections outside the template — no "Riesgos", "Wins", "Contexto", "Resumen ejecutivo".
- No reordering sections. Always: En curso → Plan de hoy → Necesito de alguien.
- No text before the block. The block is the first thing in the response.
- No bold, italics, emoji or bullets inside the block.
- No turning any section into a table.
- No judgement about the engineer's performance or the project's health.
- No estimating whether anything will land. That is `pact-stakeholder-report`.
- No paraphrasing the quoted notes.
- No presenting a candidate as a confirmed blocker.
- No asking the user anything before rendering. Render, and let them correct.
- No writing to Pact.

After the block, ONE line of normal text at most: offer to open one of the pacts
cited. Nothing else.

## Language

Fixed labels come from this lookup table, chosen by the user's language in the
conversation. If it isn't clear, English. Never translate on the spot.

| ES | EN |
|----|----|
| `Proyecto:` | `Project:` |
| `## En curso` | `## In progress` |
| `Tuyo` | `Yours` |
| `Equipo` | `Team` |
| `## Plan de hoy — propuesta, corrige` | `## Today's plan — proposed, correct it` |
| `## Necesito de alguien — candidatos sin confirmar` | `## Asks — unconfirmed candidates` |
| `Nada confirmado en esta sección. Borra lo que no aplique.` | `Nothing here is confirmed. Delete what doesn't apply.` |
| `Ninguno. Si algo te falta, dilo tú en el standup.` | `None. If something's missing, raise it yourself.` |
| `+ {N} más sin revisar` | `+ {N} more unreviewed` |
| `vencido` / `hoy` / `mañana` | `overdue` / `today` / `tomorrow` |

## Canonical example

Real pactmd data, 18 August. **This example is NORMATIVE: if the implementation
produces anything different from this data, the implementation is wrong.**

```
# Standup prep — martes 18 ago
Proyecto: pactmd · Javier

## En curso

Tuyo
◐ PACT-1077  Assessment de uso del MCP        vencido 14 ago
◐ PACT-1070  Agendar entrevistas clientes     hoy
◐ PACT-0977  Integrity: calidad de ejecución  22 ago
◐ PACT-1010  Rollout MCP a clientes           31 ago

Equipo
◐ PACT-0990  HubSpot MCP ↔ Pact (RevImpact)   Dafne · 25 ago
◐ PACT-0406  Proyectos de ~1h por cliente     Julian · 31 ago

## Plan de hoy — propuesta, corrige

1. PACT-1070  vence hoy
2. PACT-1077  vencido hace 4 días
3. PACT-1084  arranca el hito del viernes

## Necesito de alguien — candidatos sin confirmar

? PACT-1070  "esperando disponibilidad de Nick"
            → nota del 15 ago · ¿sigue abierto?
? PACT-0990  "falta acceso al portal de Kendall"
            → nota del 12 ago · ¿es para el cliente?

Nada confirmado en esta sección. Borra lo que no aplique.
```

## Out of scope

- It does not write standup notes after the meeting. Prep only.
- It does not detect wins — that is `pact-win-detection`.
- It does not issue a milestone verdict — that is `pact-stakeholder-report`.
- It does not write a tag convention (`needs:client` or similar) onto pacts. If
  engineers adopt one over time, section 3 goes from candidates to facts and
  this spec is revised. Today it is not assumed.
