---
description: Close one pact the right way — show its acceptance criteria, demand the artifact, write the contrast against each criterion, and only then close. Names divergence instead of closing green.
---

# /close-pact v0.2.0 — the closing procedure

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

1. `get_bead` — read acceptance criteria and notes.
2. Show them to the user and **ask for the artifact**. The user's turn.
3. Write the contrast (`comment_on_bead`).
4. Only then `update_status` — or not, depending on the branch.

Forbidden:

- Calling `update_status` in the same turn the pact was read.
- Closing without the user having named an artifact.
- Accepting "ya está" / "listo" / "terminado" as an artifact (see below).
- Writing the contrast without having read the pact's real criteria.
- Writing `reason: "completed"` or any empty variant.

## Step 1 — show the criteria, ask for the artifact

Fixed output for this turn:

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
  medirlo.` — and **do not invent criteria**.
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

## Step 2 — the contrast

Three possible outcomes and only three: **COINCIDE / DIVERGE / SIN CRITERIOS**.

In all three, write the note with `comment_on_bead` BEFORE asking anything else:

```
[cierre {YYYY-MM-DD}] {COINCIDE|DIVERGE|SIN CRITERIOS}
Entregado: {ARTEFACTO}
{one line per criterion: ✓ cubierto / ✗ no cubierto / ~ parcial}
{if it diverges: what got delivered instead, one line}
```

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

## What this command never does

**Do not do any of the following.**

- No calling `update_status` before the contrast has been written with `comment_on_bead`.
- No closing without the user naming an artifact or explicitly saying there is none.
- No accepting "ya está" as an artifact without re-asking once.
- No softening a divergence. If what was delivered doesn't cover a criterion, say it.
- No inventing acceptance criteria when the pact has none.
- No editing the pact's criteria so they match what was delivered.
- No creating the pact for the missing work without hanging it off the original's parent.
- No writing `reason: "completed"` or empty variants.
- No congratulating, no evaluating performance, no commenting on the project's pace.
- No closing more than one pact per invocation.

## Relationship with /day-review

`/day-review` closes the day and reports what moved. When the user says there
"PACT-XXXX ya lo terminé, ciérralo", `/day-review` does NOT close directly — it
invokes this procedure. The gain from the contrast disappears if there is a back
door that closes without it.
