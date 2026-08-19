---
description: Close the week on the goal with two separate verdicts — delivery and client outcome — and force a decision on every milestone that didn't land. No milestone is left in limbo.
---

# /week-review v0.1.0 — the week close, with a forced decision

Close the week. This is the last of the five moments of the minimal weekly flow:

```
Lunes    /pact-goals     fija el goal de la semana
Diario   /standup-prep   abre el día
         /close-pact     cierra trabajo entregado
         /wrap-up        cierra el día
Viernes  /week-review    ¿llegó el goal? y qué pasa con lo que no
```

Without this moment, `/pact-goals` starts Monday in Periodic mode assuming
somebody evaluated the previous week. Nobody evaluated it.

It is the twin of `/close-pact` one level up: same contrast against acceptance
criteria, same ban on closing green without evidence, applied to the whole goal.
The difference that defines the command: `/close-pact` closes or doesn't close.
**This one has to leave the board clean for Monday.** Every milestone that didn't
land comes out of here with a decision taken — new date, trimmed scope, or
cancelled with a reason. None stays in limbo.

Where a Pact skill rule conflicts with this file for this command, THIS FILE WINS.

## Data — exactly these calls

1. `get_bead` on the week's goal → acceptance criteria, assumptions, `depends_on`.
2. `get_bead` on each milestone under the goal → status, its own criterion, notes.
3. `search_beads` with `tag: win`, `updated_since: {Monday of this week}` → the
   wins `/wrap-up` recorded.
4. `search_beads` with `updated_since: {Monday}`, `include_closed: true`,
   `status: done` → what closed during the week.

If the goal has no written acceptance criteria, say so explicitly and **do not
invent them**. The delivery verdict in that case is "Sin criterios", NOT
"Cumplido". Never call `whats_new`.

## The block

Reproduce this exactly — every heading, every blank line, every label, in this
order. Substitute only the values in `{...}`.

```
# Week review — {GOAL_ID} · {GOAL_SLUG}
Semana del {MONDAY} al {FRIDAY} · {PROJECT}

## Entrega

{DELIVERY_VERDICT}

{MILESTONE_LINE}
{MILESTONE_LINE}

## Resultado para el cliente

{OUTCOME_VERDICT}

{WIN_LINE}

## Sin resolver

{PENDING_LINE}
{PENDING_LINE}
```

**Everything outside `{...}` is immutable.** The only sanctioned variation is
the language of the fixed labels, via the lookup table — never a translation
produced on the spot. Headings, punctuation, blank lines and their order do not
change between runs, projects or users. If a value doesn't fit the template, the
value is wrong, not the template.

## The double-verdict rule

`pact-core`: delivery is not value; value is the commercial outcome. The verdict
splits in two and **NEVER collapses into one**:

- **Entrega** — were the goal's acceptance criteria met? Answered against the
  pact, with artifacts.
- **Resultado** — did anything move on the client's side? Answered from what the
  user reports and from the `WIN:` notes `/wrap-up` left during the week.

The two can come out different and almost always do. If the command joins them,
Friday always comes out green. A goal delivered with no commercial movement is
reported as delivered and not converted, not as a success.

**FORBIDDEN: writing a combined verdict of the "la semana salió bien" kind.**

## Section formats

`{DELIVERY_VERDICT}` — one line, one of these FOUR exactly, no variants and no
added nuance:

- `Cumplido — los {N} hitos entregados con artefacto.`
- `Parcial — {X} de {N} hitos entregados.`
- `No cumplido — {X} de {N} hitos entregados.`
- `Sin criterios — el goal no tiene criterios de aceptación escritos.`

`{MILESTONE_LINE}`:

```
{GLYPH} {BEAD_ID}  {SHORT_TITLE}{PADDING}{EVIDENCE}
```

- **GLYPH** — `●` delivered with an artifact · `~` closed with no verifiable
  artifact · `○` not delivered.
- **EVIDENCE** — the artifact in max 6 words ("PR #214", "doc en Drive",
  "validado en 2 proyectos"). Closed with no artifact: `sin artefacto`. Not
  delivered: `—`.
- **The `~` glyph matters and must NOT be softened**: a milestone closed without
  an artifact is not the same as one delivered.

`{OUTCOME_VERDICT}` — one line, one of these THREE exactly:

- `Movió — {what changed on the client's side, max 12 words}.`
- `Sin movimiento todavía — entregado, no convertido.`
- `Sin dato — nadie registró movimiento de cliente esta semana.`

**"Sin dato" and "Sin movimiento" ARE NOT THE SAME.** The first is a recording
failure; the second is real information. Do not use them interchangeably.

`{WIN_LINE}` — one line per `WIN:` note of the week:

```
{BEAD_ID}  {WIN_EXCERPT}
```

- **WIN_EXCERPT** — a LITERAL fragment of the note, max 50 characters. Do not
  paraphrase.
- No wins: keep the heading and write exactly `Ninguno registrado esta semana.`

`{PENDING_LINE}` — one row per milestone NOT delivered:

```
{BEAD_ID}  {SHORT_TITLE}  → ?
```

- They render with `→ ?` because the decision has not been taken yet; it gets
  resolved in the decision turn below.
- If everything was delivered: keep the heading and write exactly
  `Nada — la semana cierra limpia.`

## The decision turn — what makes this command useful

After the block, FOR EACH UNDELIVERED MILESTONE, one at a time and in order:

```
{BEAD_ID} — {SHORT_TITLE}

  1. Se mueve — nueva fecha
  2. Se recorta — cambia el alcance, cierro lo entregado
  3. Se abandona — cancelado con razón
```

**Branch 1 — move.** Ask for the new date. `update_bead` with the `due_date` and
a reason = why it moves, in the user's own words. **NEVER move without a written
reason**: `pact-core` says an overdue item is a decision waiting to be taken, not
background noise.

**Branch 2 — trim.** Close the milestone with what was delivered and create a new
one with what got trimmed. The new one hangs off THE SAME GOAL, adding its ID to
the GOAL's `depends_on` with `update_bead` on the goal. Never leave it loose.

**Branch 3 — drop.** Ask why. `update_status` → `cancelled` with the reason IN
THE USER'S OWN WORDS, not yours.

Rules for this turn:

- **ONE MILESTONE AT A TIME.** Do not present all three together, do not ask for
  them to be answered in a batch.
- **THERE IS NO FOURTH OPTION.** "Lo vemos el lunes" is not accepted — that is
  exactly the limbo this command exists to eliminate. If the user insists, the
  option is 1 with Monday's date, and it gets written that way.
- **DO NOT SUGGEST which one to pick.** Present the three and wait.

## Closing the goal

Only AFTER every pending item is resolved:

- `comment_on_bead` on the goal prefixed `[week-review {YYYY-MM-DD}]`, containing
  the two verdicts SEPARATELY and the decisions taken.
- If the delivery verdict is `Cumplido`: close the goal with `update_status` →
  done, `reason` = what was delivered + the outcome verdict. EVEN IF the outcome
  is "Sin movimiento" — the goal closes on delivery, and the lack of conversion
  stays written.
- In any other case: the goal stays open and its date is resolved with the same
  three-option mechanic.
- If one of the goal's assumptions broke during the week, name it in one line and
  ask whether the goal is still the right one. **Do not decide that yourself.**

## What this command never does

**Do not do any of the following.**

- No collapsing the two verdicts into one. Delivery and outcome are reported
  separately, always.
- No reporting "Cumplido" if any milestone was closed without a verifiable artifact.
- No confusing "Sin dato" with "Sin movimiento".
- No inventing acceptance criteria when the goal has none.
- No paraphrasing the quoted `WIN:` notes.
- No offering a fourth option for pending milestones. Leaving it for Monday is not accepted.
- No suggesting which of the three options to take.
- No moving a date without a written reason.
- No creating the trimmed milestone without hanging it off the goal.
- No cancelling anything without the reason in the user's own words.
- No congratulating on the week, no evaluating the pace, no commenting on productivity.
- No sections outside the template.

## Language

Fixed labels come from this lookup table, chosen by the user's language. If it
isn't clear, English. Never translate on the spot.

| ES | EN |
|----|----|
| `Semana del {MONDAY} al {FRIDAY} ·` | `Week of {MONDAY} to {FRIDAY} ·` |
| `## Entrega` | `## Delivery` |
| `## Resultado para el cliente` | `## Client outcome` |
| `## Sin resolver` | `## Unresolved` |
| `Ninguno registrado esta semana.` | `None recorded this week.` |
| `Nada — la semana cierra limpia.` | `Nothing — the week closes clean.` |
| `Se mueve` / `Se recorta` / `Se abandona` | `Moves` / `Trimmed` / `Dropped` |

The four delivery verdicts and the three outcome verdicts translate literally and
fixedly. They are never reformulated.

## Out of scope

- It does not set next week's goal. That is `/pact-goals` on Monday.
- It does not close individual day-to-day pacts. That is `/close-pact`.
- It does not produce the stakeholder brief. That is `pact-stakeholder-report`,
  which can run afterwards with the board already clean.
- It does not sweep retroactively for wins. It reads the ones `/wrap-up` recorded.
