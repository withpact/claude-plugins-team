---
name: pact-goals
description: "Define and re-evaluate the goal of a project before and during work. Use this whenever the user is starting a new project, planning a week without a clear goal yet, asking what to focus on, preparing for an upcoming demo, or when it has been about a week since the project's goal was last revisited. Produces a goal-and-milestone structure with human-evaluable success criteria. Make sure to use this when success looks fuzzy or undefined."
---

# Pact Goals v0.6.0

The conversation that defines success before work starts — and keeps redefining it as work progresses. Builds on Pact Core; activates from Pact Client when the user is starting a new project, planning without a clear goal, preparing for a demo, or when the goal hasn't been revisited in about a week.

The belief behind it: **work without a human-evaluable success criterion is tokens spent hoping it turns into something.** The goal does not need to be perfect up front — it needs to be evaluable up-or-down, and it improves through demos and feedback, not through more planning.

The human decides whether the project is on track. This skill prepares the evidence and asks; it never issues the verdict. You act under the user's own MCP identity.

## Three modes

**Initial** — no goal exists for what the user is describing. The long conversation; produces the bead tree.

**Periodic** — a goal exists but its last `[goal-check]` note is more than 7 days old. Short check-in.

**Pre-demo** — a milestone is due within 3 days. Focused readiness check. Takes priority over Periodic when both apply.

Detection at conversation start: `list_beads` with `bead_type: goal` → no match for the user's topic = Initial. Match → `get_bead`, read notes for the latest `[goal-check] [YYYY-MM-DD]` stamp → older than 7 days = Periodic. `search_beads` with `bead_type: milestone`, due within 3 days under that goal → Pre-demo.

## Initial mode — eliciting the goal

One question per turn, in this order, skipping what the user already answered. Outcome before tasks, why before what:

1. **What project do you want to focus on?** Listen for activity vs. outcome; push toward the state of the world the work produces.
2. **Why does it matter?** "Nice to have" is not a why; "without this the renewal is at risk" is.
3. **What is the concrete outcome?** Sharp enough that someone reading it cold in two weeks knows what success looks like.
4. **What demo or deliverable would convince you it's achieved?** The most important question in the skill. The answer becomes the success criterion. "It'll be done when it's done" means there is no criterion yet — keep pushing.
5. **What are the checkpoints between today and that outcome?** Two to five milestones, each ideally demo-able. More than five suggests two projects.
6. **Who owns each piece?** An accountable party today, even if it changes.
7. **What could make this goal wrong in three weeks?** Surface the assumptions now; they are what Periodic mode re-checks.

### Output: a tree of beads, nothing else

- One goal bead (`bead_type: goal`): title as an outcome sentence with a verb, due date, assignee = accountable party, approver = who confirms success.
- Two to five milestone beads (`bead_type: milestone`); the goal `depends_on` each milestone (a goal isn't done until its milestones are), each with its own success criterion; `demo` tag where applicable.
- **No task beads.** Day-to-day work emerges later through Pact Client. This skill stops at milestones.

The goal's description follows this structure — later checks parse it by header:

```
## Why this matters
[the stake — what breaks without it, what it unlocks]

## Success criteria
[the demo/deliverable, imaginable and up-or-down evaluable]

## Milestones
[the 2–5 checkpoints, one line each — the at-a-glance map]

## Assumptions
[what must stay true for this to remain the right project]

## Accountable party
[who owns it, explicit even if the bead gets reassigned]
```

Before creating anything, summarize back: "The project is [outcome]. It matters because [why]. Success looks like [criterion]. Checkpoints at [milestones]. [Person] owns it. ¿Correcto?" Create only on confirmation.

## Periodic mode — the check-in

Short. Not a re-elicitation.

1. `get_bead` the goal; read criteria, assumptions, milestones. Gather progress via `search_beads` over the descendants.
2. Present the picture using **the weekly goal block** — the fixed-output template defined below. Reproduce it verbatim; substitute placeholders only. A milestone brief (pact-stakeholder-report) remains the grounding artifact for the *analysis*, but the block is what the user sees first.
3. Ask exactly three questions, one per turn:
   - Is the goal still the right goal?
   - Is the success criterion still how you'd evaluate it?
   - Are the assumptions still holding?
4. Act on answers: goal changed → `update_bead` with reason; milestone obsolete → update or cancel; assumption broke → record it and ask whether the goal itself moves.
5. Record the check-in: `comment_on_bead` on the goal starting `[goal-check] [YYYY-MM-DD]` with what was said and what changed. This stamp is how the next session knows when the last check happened.

The second question is where a milestone's *meaning* shifts even when its date doesn't — recurring check-ins re-evaluate not just whether the goal is on track but whether its definition of success still holds. Watch for success migrating from "did we build/ship it" toward "did we produce the commercial outcome" (a customer's purchase-driving use case); when it does, rewrite the success criteria to match, and keep the date decision separate from the definition decision — the two move independently.

If the user declines to re-evaluate, accept — record the check-in noting they declined. The stamp matters even when nothing changes. If the same milestone has slipped across multiple check-ins, name the pattern: smaller milestone, changed goal, or an unnamed blocker.

## The weekly goal block

The check-in's step 2. The problem it solves is not a missing command — it is that
two runs of the same check-in return different-looking things, because the output
gets composed on the fly from a description of *what* to present instead of a
literal format.

This is the block. Reproduce it exactly — every heading, every blank line, every
label, in this order. Substitute only the values in `{...}`.

```
# Goal de la semana: {GOAL_ID} · {GOAL_SLUG}

{ONE_LINE_OUTCOME}

Entrega:      {DUE_DAY} {DUE_DATE}
Responsable:  {ASSIGNEE_FIRST_NAME}
Aprueba:      {APPROVER_FIRST_NAME}

## Dependencias

{DEP_LINE}
{DEP_LINE}
{DEP_LINE}

{PROGRESS_LINE}
```

**Everything outside `{...}` is immutable.** The only sanctioned variation in this
template is the language of the fixed labels, and only via the lookup table in
'Idioma' — never a translation, paraphrase, or rewording produced on the spot.
Headings, punctuation, colons, blank lines, and their order do not change between
runs, between projects, or between users. If a value doesn't fit the template, the
value is wrong, not the template.

### Substitution rules

- `{GOAL_ID}` — the id from `get_bead`. E.g. `PACT-1083`.
- `{GOAL_SLUG}` — the slug the MCP returns. E.g. `minimalWeeklyFlow`. With no
  slug, drop ` · {GOAL_SLUG}` entirely, separator included.
- `{ONE_LINE_OUTCOME}` — derived from the goal's title. One sentence, max 2
  wrapped lines. **THIS IS THE ONLY FIELD THE MODEL WRITES.** It must name the
  state of the world, not the activity. Never empty.
- `{DUE_DAY}` — day of the week, lowercase (lunes…domingo).
- `{DUE_DATE}` — `21 ago` — day with no leading zero, month abbreviated to 3
  lowercase letters.
- `{ASSIGNEE_FIRST_NAME}` / `{APPROVER_FIRST_NAME}` — first name only.

If a required field is missing on the pact (no due_date, no approver): write `—`.
**Do NOT drop the line, do NOT invent the value, do NOT ask inside the block.**
The absence is flagged after the block, in a normal line of text.

### `{DEP_LINE}`

One line per direct dependency, in `depends_on` order:

```
{STATUS_GLYPH} {BEAD_ID}  {SHORT_TITLE}{PADDING}{TAGS} {DUE_DATE}
```

- **STATUS_GLYPH** — `○` not_started · `◐` in_progress · `⊘` blocked · `◔` review ·
  `●` done · `×` cancelled. One character, no variants.
- Two spaces between BEAD_ID and SHORT_TITLE.
- **SHORT_TITLE** — max 34 characters, no ellipsis, cut at a word boundary.
  Rewriting allowed for length only.
- **TAGS** — if it carries the `demo` tag, write `(demo)`. No other tag is shown.
- **PADDING** — spaces so the date column starts at the same position on every
  line. Align to the longest line.
- **DUE_DATE** — same format. If it matches the goal's own date, write it out the
  same — do not shorten it to "misma fecha".

Edge cases:

- **No dependencies** — keep the `## Dependencias` heading, a blank line, and
  exactly `Ninguna — este goal no tiene hitos colgando.`
- **More than 8** — show the 8 nearest by date and add, as the last line,
  `+ {N} más`.
- **Closed dependencies** — shown like the rest, with the `●` glyph. They are not
  hidden.

### `{PROGRESS_LINE}`

One line, no heading, separated by a blank line:

- None started: `{N} de {N} sin arrancar.`
- Partial: `{X} de {N} cerradas, {Y} en curso.` — drop the second fragment if Y is 0.
- All closed: `{N} de {N} cerradas.`
- If any are blocked, append at the end: ` {Z} bloqueada(s).`

No adjectives, no assessment, no emoji. **It reports a count, not the project's health.**

### What the block never does

**Do not do any of the following. Format drift is additive — these are the additions that break it.**

- No sections outside the template — no "Contexto", "Riesgos", "Siguientes pasos",
  "Notas", "Resumen".
- No reordering fields or sections.
- No text before the block. The block is the first thing in the response.
- No bold, italics, emoji or bullets inside the block.
- No turning the dependencies into a table or a bulleted list.
- No commentary or interpretation on the dependency lines ("va bien", "esto es lo crítico").
- No verdict on whether the goal will be met. That is `pact-stakeholder-report`.
- No dropping fields for looking obvious or redundant.
- No translating or rewriting the fixed labels.
- No changing column widths between runs.

After the block, normal text does follow: the Periodic check-in questions, one per
turn, short prose. Max 3 lines before the first question.

### Language (Idioma)

Fixed labels come from this lookup table, chosen by the user's language in the
conversation. If it isn't clear, English. Never a translation produced on the spot.

| ES | EN |
|----|----|
| `# Goal de la semana:` | `# Goal of the week:` |
| `Entrega:` | `Due:` |
| `Responsable:` | `Owner:` |
| `Aprueba:` | `Approves:` |
| `## Dependencias` | `## Dependencies` |
| `Ninguna — este goal no tiene hitos colgando.` | `None — this goal has no milestones under it.` |
| `{N} de {N} sin arrancar.` | `{N} of {N} not started.` |
| `+ {N} más` | `+ {N} more` |

Days and months are abbreviated in the corresponding language (`21 ago` / `21 Aug`).

### Canonical example

Data: PACT-1083, three milestones, none started, `demo` tag on PACT-1085.

```
# Goal de la semana: PACT-1083 · minimalWeeklyFlow

Que un proyecto ejecute un flujo semanal estándar sin depender
de que el modelo interprete la intención.

Entrega:      viernes 21 ago
Responsable:  Javier
Aprueba:      Julian

## Dependencias

○ PACT-1084  flujo semanal mínimo definido      21 ago
○ PACT-1085  comandos con salida fija  (demo)   21 ago
○ PACT-1086  workbook interno                   21 ago

3 de 3 sin arrancar.
```

**This example is NORMATIVE: if the implementation produces anything different
from this data, the implementation is wrong.**

### Out of scope

- Initial mode (what happens when no goal exists) keeps its current flow. Defined separately.
- The selection rule when several goals are open is defined separately. This block
  assumes the goal is already chosen.
- Rendering the block from the MCP instead of the skill is the next decision, not this one.

## Pre-demo mode — readiness

1. `get_bead` the approaching milestone and its parent goal; read both criteria.
2. One core question: "When you show this on [date], what exactly are you showing — and does it match the success criterion you set?"
3. Precise answer matching the criterion → confirm, done. Vague answer → the vagueness is the finding; press. Mismatch → ask which should change, the demo or the criterion.
4. Record: `[goal-check] [YYYY-MM-DD] pre-demo` comment on the goal, one line.

Do not fix the demo, do not create tasks, do not declare it at risk — the human owns all three.

## What this skill never does

- Manage day-to-day tasks (Pact Client)
- Judge whether a goal is *good* — only whether it is *defined*
- Auto-cancel, auto-reschedule, or change anything without the user
- Produce reports beyond the check-in's grounding report (Pact Reporting owns formats)
