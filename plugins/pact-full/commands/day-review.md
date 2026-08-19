---
description: Close the day — show what the system actually recorded, ask whether anything moved for the client, and capture what never got written down. Writes to Pact; never closes pacts.
---

# /day-review v0.2.0 — the end-of-day capture

Close the day. This is the twin of `/day-start`: one opens the day, this one
closes it and feeds tomorrow's opening block. `/week-review` does the same job
one cadence up.

Three things happen, in this order: it shows what the system recorded today, it
asks whether anything moved for the client's business, and it captures what the
engineer dictates that never got written down.

**The third is the actual point.** The list this command renders will be
incomplete almost every time, because it only contains what somebody remembered
to record. That is NOT a defect — it is the mechanism. The engineer sees the day
half-written, says "también cerré esto y el cliente confirmó el alcance", and
that is the moment of capture. This is not a report shaped like a ritual; it is
a ritual shaped like a report.

Where a Pact skill rule conflicts with this file for this command, THIS FILE WINS.

## Data — exactly these calls

1. `list_beads` with `bead_type: goal` → identify the week's goal (the one whose
   date is nearest within the next 7 days). If there are several, take the
   nearest one and name it; **do not pick by inferred relevance**.
2. `search_beads` with `updated_since: {today}` → everything touched today in the project.
3. `search_beads` with `updated_since: {today}`, `include_closed: true`,
   `status: done` → what was closed today.
4. `get_bead` on the week's goal to read its `depends_on` and know what hangs off it.

Do NOT filter by `updated_by` — that field stores hashed IDs, not names.
Never call `whats_new` — reading it marks messages as read and the user would lose them.

## The block

Reproduce this exactly — every heading, every blank line, every label, in this
order. Substitute only the values in `{...}`.

```
# Cierre del día — {DAY} {DATE}
Proyecto: {PROJECT} · {USER_FIRST_NAME}

Meta de la semana: {GOAL_ID} · {GOAL_SLUG}

## Lo que registré hoy

{MOVE_LINE}
{MOVE_LINE}

## Fuera del goal

{ORPHAN_LINE}

## ¿Se movió algo para el cliente?

{BUSINESS_PROMPT}

¿Algo más que anotar?
```

**Everything outside `{...}` is immutable.** The only sanctioned variation is
the language of the fixed labels, via the lookup table — never a translation
produced on the spot. Headings, punctuation, blank lines and their order do not
change between runs, projects or users. If a value doesn't fit the template, the
value is wrong, not the template.

## Line formats

`{MOVE_LINE}`:

```
{GLYPH} {BEAD_ID}  {SHORT_TITLE}{PADDING}{WHAT_HAPPENED}
```

- **GLYPH** — `●` closed today · `◐` advanced · `✚` created today. One character,
  no variants.
- **SHORT_TITLE** — max 32 characters, cut at a word boundary, no ellipsis.
- **PADDING** — spaces aligning the last column to the longest line.
- **WHAT_HAPPENED** — what changed, max 6 words, derived from the change actually
  recorded ("cerrado", "se creó", "nota agregada", "descripción editada", "se
  inició, no se cerró"). No adjectives, no assessment.
- Order: closed first, then advanced, then created.
- No movement all day: keep the heading and write exactly `Nada registrado hoy.`
  That case is information, not an error — **do not apologise for it**.

`{ORPHAN_LINE}` — pacts touched today that do NOT hang off the week's goal:

```
{BEAD_ID}  {SHORT_TITLE}{PADDING}{STATE}
```

- **STATE** — `nadie lo está trabajando` if it has no assignee or is still
  not_started · `en curso` · `sin padre` if it is also an orphan.
- Max 5 lines; beyond that, `+ {N} más`.
- If everything hangs off the goal: keep the heading and write exactly
  `Nada — todo lo de hoy cuelga del goal.`
- **Do not judge this.** The section reports that work outside the goal exists;
  it does not say that it is wrong. It may be legitimate.

`{BUSINESS_PROMPT}`:

```
{UNA PREGUNTA DE MÁXIMO 2 LÍNEAS}
"Nada todavía" es una respuesta válida y también se registra.
```

- The question is built from what was closed today. If something client-facing
  closed, ask about that specifically. If the day was entirely internal, the
  question says so: `Hoy todo fue interno. ¿Algo del lado del cliente se movió de
  todas formas?`
- **The second line is FIXED and does not change.**

## The capture turn

**WRITE WITHOUT ASKING.** Do not propose the changes and do not ask for
confirmation. Write, and report it in one line per write:

```
Anoté lo que me dijiste en PACT-1085.
```

Nothing else. Do not repeat the note's content, no summary, no repeated "¿algo más?".

**CLOSES, NO.** If the user says "PACT-5483 ya lo terminé, ciérralo", do NOT call
`update_status`. Invoke the `/close-pact` procedure — show the acceptance
criteria and ask for the artifact. The gain from the contrast disappears if
`/day-review` is a back door that closes without it.

**WINS, YES, WITH THE CONVENTION.** If the answer to the business question names
something that moved on the client's side, write it as a note prefixed `WIN:` and
add the `win` tag to the pact — the same convention as `pact-win-detection`, so
reports pick it up later.

If the answer is "nada todavía", record it anyway on the week's goal as a note
`[day-review {YYYY-MM-DD}] sin movimiento de cliente`. **THAT DATUM IS THE ONE THAT
GETS LOST TODAY**, and it is the one that reveals a project that delivers and
does not convert.

**NEW PACTS, YES.** If the user mentions work that does not exist as a pact,
create it and hang it off the week's goal. If it does not fit under that goal,
ask which one — never create it loose.

## What this command never does

**Do not do any of the following. Format drift is additive — these are the additions that break it.**

- No sections outside the template — no "Mañana", "Riesgos", "Resumen", "Logros".
- No reordering sections.
- No text before the block.
- No bold, italics, emoji or bullets inside the block.
- No turning any section into a table.
- No calling `update_status` from this command. Closes go through `/close-pact`.
- No asking for confirmation before writing a dictated note. Write, then report it.
- No repeating the note's content when reporting it.
- No congratulating on the day, no evaluating the pace, no commenting on productivity.
- No verdict on whether the goal will land. That is `pact-stakeholder-report`.
- No judging the work that sits outside the goal.
- No skipping the business question, even when the day was entirely internal.
- No inventing client movement the user did not state.

## Language

Fixed labels come from this lookup table, chosen by the user's language. If it
isn't clear, English. Never translate on the spot.

| ES | EN |
|----|----|
| `# Cierre del día —` | `# Day review —` |
| `Proyecto:` | `Project:` |
| `Meta de la semana:` | `Week goal:` |
| `## Lo que registré hoy` | `## What I have on record today` |
| `## Fuera del goal` | `## Outside the goal` |
| `## ¿Se movió algo para el cliente?` | `## Did anything move for the client?` |
| `Nada registrado hoy.` | `Nothing on record today.` |
| `Nada — todo lo de hoy cuelga del goal.` | `Nothing — everything today hangs off the goal.` |
| `"Nada todavía" es una respuesta válida y también se registra.` | `"Nothing yet" is a valid answer and gets recorded too.` |
| `¿Algo más que anotar?` | `Anything else to record?` |
| `Anoté lo que me dijiste en {ID}.` | `Recorded what you told me on {ID}.` |

## Canonical example

pactmd data, 18 August. **This example is NORMATIVE: if the implementation
produces anything different from this data, the implementation is wrong.**

```
# Cierre del día — martes 18 ago
Proyecto: pactmd · Javier

Meta de la semana: PACT-1083 · minimalWeeklyFlow

## Lo que registré hoy

✚ PACT-1083  Flujo semanal mínimo estándar   se creó, 3 hitos
✚ PACT-1088  /day-start                      se creó con spec
✚ PACT-1089  /close-pact                     se creó con spec
◐ PACT-1085  Comandos con salida fija        descripción editada

## Fuera del goal

PACT-1087  pact-goals modo Initial           nadie lo está trabajando

## ¿Se movió algo para el cliente?

Hoy todo fue interno — specs de comandos, nada entregado a un cliente.
¿Algo del lado del cliente se movió de todas formas?
"Nada todavía" es una respuesta válida y también se registra.

¿Algo más que anotar?
```

## Out of scope

- It does not close pacts. That is `/close-pact`.
- It does not sweep retroactively for wins. That is `pact-win-detection`; this
  command only feeds the `WIN:` convention in the moment.
- It does not issue a milestone verdict. That is `pact-stakeholder-report`.
- It does not open the day. That is `/day-start`.
