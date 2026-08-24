---
description: Close one pact the right way — read its notes first and show the artifact already recorded there, demand what's missing, write the contrast against each criterion, and only then close. Names divergence instead of closing green.
---

# /close-pact v0.3.0 — the closing procedure

Run the closing procedure for ONE pact and write the result to Pact.

`pact-code` describes this procedure in prose and `pact-core` carries the
etiquette rule ("close it with the delivered outcome in the reason, not
'completed'"). Neither is followed consistently, because today it depends on the
model remembering. This command exists so it does not.

**This command is built the other way round from the fixed-output ones: the
constraint is on the ORDER OF THE CALLS, not on the format.** What varies
between runs is not how the answer looks — it is whether the contrast against
the acceptance criteria happened or got skipped. That step is the only one that
matters and it is exactly the one an agreeable model skips: closing green is
more pleasant than reporting that something else got delivered.

Where a Pact skill rule conflicts with this file for this command, THIS FILE WINS.

## Invocation

```
/close-pact {BEAD_ID}
```

With no BEAD_ID: list the user's `in_progress` pacts and ask them to pick one.
**Do not guess which one.**

## The hard rule on call order

`update_status` MUST NOT be called until the contrast has been written. No
exception.

Mandatory sequence, no skipping:

1. `get_bead` with `full_notes: true` — read the acceptance criteria and the
   pact's WHOLE note history.
2. Extract the artifact candidates already written in those notes.
3. Show the criteria and the candidates, and ask only for what the notes did not
   answer. The user's turn.
4. Write the contrast (`comment_on_bead`).
5. Only then `update_status` — or not, depending on the branch.

Forbidden:

- Calling `update_status` in the same turn the pact was read.
- Closing without the user having named an artifact.
- Accepting "ya está" / "listo" / "terminado" as an artifact (see below).
- **Asking for the artifact in the cold when the notes already name one.**
- **Treating a candidate as the confirmed artifact, or writing the contrast in
  the same turn the candidates were shown.** The user's turn still happens; what
  changed is that they now confirm or correct instead of answering from scratch.
- Writing the contrast without having read the pact's real criteria.
- Writing `reason: "completed"` or any empty variant.

## Step 1 — read the notes, then ask

The user should never have to retype something that is already written on the
pact. Almost always it is: the PR got pasted into a note the day it was opened,
the doc link when it was shared, the commit when the work landed — weeks before
anyone runs the closing procedure.

So `get_bead` is called with `full_notes: true`, not the default handful of
recent ones. **The artifact is usually named the day it was delivered, and the
pact is closed much later.** Reading only the last few notes is what makes the
questions feel forced.

### What counts as a candidate

A candidate is a LITERAL fragment of a note carrying one of these signals:

| Signal | Example |
|--------|---------|
| PR link or number | `https://github.com/withpact/PactMD/pull/406` · `PR #406` |
| commit hash | `fa615de` — 7 to 40 hex characters |
| any `http(s)://` link | Drive, Docs, Notion, Figma, a deployed URL |
| branch name | `worktree-pact-1101-…` · `feature/…` |
| file path | `services/beads-api/rendered_commands.py` |
| another pact id | `PACT-1089` — a decision or the work written on another pact |

**Nothing else.** "Ya quedó", "lo terminé", "avancé bastante", "quedó lindo" are
not candidates — they are the same non-artifact as when they are said out loud,
and finding them in writing does not upgrade them.

- Do not infer an artifact from a note that describes work without pointing at
  it.
- **Do not go looking outside the pact.** No `git log`, no searching the repo,
  no reading other pacts. The notes of THIS pact, nothing else. What the command
  shows must be something the user can see on their own bead.
- Newest first, at most 5. If more match, show the newest 5 and nothing about
  the rest.
- One line per artifact, not per note. If several notes name the same PR, the
  same link or the same file, show only the newest one that names it — a list
  that repeats the same artifact four times is the interrogation in another
  shape.

### How candidates are shown

Same mechanic as `/day-start`: `?`, quoted literally, dated. A candidate is what
someone wrote down, never a statement that it happened.

```
? {NOTE_DATE}  "{LITERAL_QUOTE}"
```

- **LITERAL_QUOTE** — copied from the note. **It starts at the sentence carrying
  the signal, not at the top of the note**, and it always contains the signal
  itself — the notes on a pact run long, and the first hundred characters of a
  long note are rarely the ones holding the PR. At most 100 characters from
  there, cut without marking the cut. Never paraphrased, never tidied up,
  **never translated** — the quote stays in the language it was written in even
  when the rest of the block is in the other one.
- **NOTE_DATE** — the note's date, as `{D} {MON}` (`21 ago` · `21 aug`).
- Never write "entregaste X" or "el artefacto es X". The user confirms or
  corrects; until they do, it is a candidate.

### The output

Fixed output for this turn. Two shapes, and which one you get depends only on
whether the notes had candidates.

**With candidates:**

```
/close-pact {BEAD_ID}

Criterios de aceptación del pact:
  · {CRITERION}
  · {CRITERION}

Esto es lo que encontré en las notas, sin confirmar:
? {NOTE_DATE}  "{LITERAL_QUOTE}"
? {NOTE_DATE}  "{LITERAL_QUOTE}"

¿Es esto lo que entregaste? Confirma o corrígeme.
```

**Without candidates** — the notes named nothing, so the artifact is asked for
in the cold, exactly as before:

```
/close-pact {BEAD_ID}

Criterios de aceptación del pact:
  · {CRITERION}
  · {CRITERION}

¿Qué entregaste? Necesito el artefacto — link, PR, doc.
```

- **CRITERION** — each criterion as written in the pact, shortened to one line if
  needed. Never reinterpreted.
- If the pact has no identifiable criteria, write instead: `Este pact no tiene
  criterios de aceptación escritos. Dime qué entregaste y contra qué debería
  medirlo.` — and **do not invent criteria**. Candidates are still shown if there
  are any.
- **Ask only for what the notes did not answer.** If a candidate names an
  artifact, do NOT also ask `¿Qué entregaste?` — the pre-read just answered that.
  If some criterion has no candidate pointing anywhere near it, add ONE line
  naming it: `Para {CRITERIO} no encontré nada en las notas.` That line is a
  request, not a verdict — step 2 is still the only place coverage gets judged.
- Nothing else this turn. Do not get ahead to the close, do not propose a reason,
  do not evaluate.

## What counts as an artifact

`pact-core`: a pact is done when someone else can confirm it without asking you.

**Counts:** a PR, a commit, a branch, a link to a document, a file path, a
message sent, a meeting that happened with its date, a decision written on
another pact.

**Does not count:** "ya está", "lo terminé", "quedó listo", "sí se hizo".

Against those, re-ask ONCE, concretely:

```
¿Dónde queda eso para que {APPROVER} lo confirme sin preguntarte?
```

If the user insists there is no verifiable artifact, it CAN still be closed, but
the reason says so explicitly: `Sin artefacto verificable — {what the user
reported}`. It does not get dressed up.

A candidate the user confirmed is an artifact. A candidate they ignored is not —
if they answer without addressing it, ask once which one it is; do not pick for
them.

## Step 2 — the contrast

Three possible outcomes and only three: **COINCIDE / DIVERGE / SIN CRITERIOS**.

In all three, write the note with `comment_on_bead` BEFORE asking anything else:

```
[cierre {YYYY-MM-DD}] {COINCIDE|DIVERGE|SIN CRITERIOS}
Entregado: {ARTEFACTO}
{one line per criterion: ✓ cubierto / ✗ no cubierto / ~ parcial}
{if it diverges: what got delivered instead, one line}
```

`{ARTEFACTO}` is what the user CONFIRMED, never the candidate they were shown.
If they corrected it, the correction is what gets written.

The note is written ALWAYS, even if the user abandons the conversation on the
next turn. It is the record that gets lost today.

- **COINCIDE** → close with `update_status` → done and `reason` = the delivered
  outcome, concrete, with the artifact. Done.
- **DIVERGE** → go to the next section.

## Step 3 — the divergence

Name it in one or two lines, without hedging and without blame, and offer
exactly three ways out:

```
Lo entregado no cubre {CRITERIO}. {UNA LÍNEA DE QUÉ FALTA}

¿Qué hacemos?
  1. Sigo trabajando en este pact — queda abierto
  2. Cierro este y abro uno nuevo con lo que falta
  3. Cierro este y registro por qué se decidió divergir
```

**Branch 1 — stays open.** Do NOT call `update_status`. The pact is left as it
is. The divergence note is already written. Done.

**Branch 2 — close and open the remainder.** Close the original with
`update_status` → done, `reason` = what was delivered + `resto en {NUEVO_ID}`.
Create the new pact with what's missing, same assignee and approver.

> **CRITICAL: the new pact hangs off THE SAME PARENT as the original.** Read the
> original's parent and add the new ID to the PARENT's `depends_on`, with
> `update_bead` on the parent. Skip this and you close one clean and create an
> orphan — exactly the pattern this bundle exists to prevent.
>
> If the original had no parent: say so to the user and ask which goal the new
> one goes under. **Never create it loose.**

**Branch 3 — close with the decision recorded.** Ask why the divergence was
chosen. Write a second note `[decisión {YYYY-MM-DD}]` with the reason IN THE
USER'S OWN WORDS. Then close, `reason` = what was delivered + `divergencia
registrada`.

In all three branches: **do not edit the original pact's acceptance criteria.**
If the criteria were wrong, that is a separate decision the user takes
explicitly.

## The closing reason

Never "completed", "done", "listo", nor the pact's title repeated. The form is
WHAT GOT DELIVERED + WHERE IT IS VERIFIED, in one line.

- **Good:** "Skill pact-goals con bloque de salida fija, PR #214, validado en pactmd y cothon."
- **Bad:** "Completed." · "Se terminó el trabajo del pact." · "Definir el flujo semanal mínimo."

## Language

**The whole run follows the language of THIS CONVERSATION.** Not the language of
the pact, not the language of its notes, not a default. A conversation held in
English gets everything this command writes in English — the block, the
questions, the divergence, and the note written with `comment_on_bead` — even
when the pact and every note on it are in Spanish. If the conversation's
language is not clear, English.

Two things are never translated, in either direction:

- **Quotes from notes.** A candidate is a literal fragment of what someone wrote.
  It is shown in its own language, inside the quotes, whatever the block's
  language is.
- **The acceptance criteria.** Shown as written in the pact.

Fixed labels come from this lookup table. Never translate on the spot.

| ES | EN |
|----|----|
| `Criterios de aceptación del pact:` | `The pact's acceptance criteria:` |
| `Esto es lo que encontré en las notas, sin confirmar:` | `Here's what I found in the notes, unconfirmed:` |
| `¿Es esto lo que entregaste? Confirma o corrígeme.` | `Is this what you delivered? Confirm or correct me.` |
| `Para {CRITERIO} no encontré nada en las notas.` | `I found nothing in the notes for {CRITERION}.` |
| `¿Qué entregaste? Necesito el artefacto — link, PR, doc.` | `What did you deliver? I need the artifact — link, PR, doc.` |
| `Este pact no tiene criterios de aceptación escritos. Dime qué entregaste y contra qué debería medirlo.` | `This pact has no acceptance criteria written. Tell me what you delivered and what I should measure it against.` |
| `¿Dónde queda eso para que {APPROVER} lo confirme sin preguntarte?` | `Where does that live so {APPROVER} can confirm it without asking you?` |
| `Sin artefacto verificable — {…}` | `No verifiable artifact — {…}` |
| `[cierre {YYYY-MM-DD}]` | `[close {YYYY-MM-DD}]` |
| `COINCIDE` | `MATCHES` |
| `DIVERGE` | `DIVERGES` |
| `SIN CRITERIOS` | `NO CRITERIA` |
| `Entregado:` | `Delivered:` |
| `cubierto` / `no cubierto` / `parcial` | `covered` / `not covered` / `partial` |
| `Lo entregado no cubre {CRITERIO}.` | `What was delivered does not cover {CRITERION}.` |
| `¿Qué hacemos?` | `What do we do?` |
| `Sigo trabajando en este pact — queda abierto` | `I keep working on this pact — it stays open` |
| `Cierro este y abro uno nuevo con lo que falta` | `I close this one and open a new one with what's missing` |
| `Cierro este y registro por qué se decidió divergir` | `I close this one and record why we chose to diverge` |
| `resto en {NUEVO_ID}` | `remainder in {NEW_ID}` |
| `[decisión {YYYY-MM-DD}]` | `[decision {YYYY-MM-DD}]` |
| `divergencia registrada` | `divergence recorded` |

## What this command never does

**Do not do any of the following.**

- No calling `update_status` before the contrast has been written with `comment_on_bead`.
- No calling `get_bead` with the default note window — `full_notes: true` or the pre-read did not happen.
- No showing a candidate as a fact, a paraphrase, or a translation.
- No inventing a candidate from a note that describes work without pointing at it.
- No looking for the artifact outside the pact's own notes.
- No skipping the user's turn because a candidate looked conclusive.
- No asking in the cold for something the notes already answered.
- No closing without the user naming an artifact or explicitly saying there is none.
- No accepting "ya está" as an artifact without re-asking once.
- No softening a divergence. If what was delivered doesn't cover a criterion, say it.
- No inventing acceptance criteria when the pact has none.
- No editing the pact's criteria so they match what was delivered.
- No creating the pact for the missing work without hanging it off the original's parent.
- No writing `reason: "completed"` or empty variants.
- No answering in the pact's language instead of the conversation's.
- No congratulating, no evaluating performance, no commenting on the project's pace.
- No closing more than one pact per invocation.

## Relationship with /day-review

`/day-review` closes the day and reports what moved. When the user says there
"PACT-XXXX ya lo terminé, ciérralo", `/day-review` does NOT close directly — it
invokes this procedure. The gain from the contrast disappears if there is a back
door that closes without it.
