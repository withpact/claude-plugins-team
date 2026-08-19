---
description: Monday's move — set or re-check the week's goal and render the weekly goal block: outcome, owner, due date, and every milestone hanging off it in fixed columns.
---

# /week-goal v0.1.0 — the Monday command

Set the week's goal, or re-check the one that already exists, and show it as the
**weekly goal block**.

This command is a thin surface. The procedure and the template both live in the
`pact-goals` skill — load it and follow it. Do not restate the template here and
do not compose an alternative: `pact-goals` → *The weekly goal block* is the
single source of truth, and reproducing it from memory is exactly the drift this
command exists to stop.

## What to run

1. Load the **`pact-goals`** skill.
2. Pick the mode the skill defines:
   - A goal for this week already exists → **Periodic mode**, the check-in.
     Its step 2 renders the weekly goal block; the block is the first thing in
     the response, then the check-in questions, one per turn.
   - No goal exists yet → **Initial mode**, the elicitation. It ends with a goal
     and its milestones; render the weekly goal block once they exist.
3. Nothing else. This command adds no sections, no verdict, and no commentary of
   its own on top of what the skill produces.

## Which goal

The week's goal is the open goal whose due date is nearest within the next 7
days. If several qualify, **name the one you picked** and say so in one line
after the block — never pick silently by inferred relevance.

The selection rule for a project carrying several open goals at once is defined
separately (PACT-1087); until then, naming your pick is what keeps it honest.

## What this command never does

**Do not do any of the following.**

- No restating, paraphrasing or "improving" the template from `pact-goals`.
- No text before the block. The block is the first thing in the response.
- No verdict on whether the goal will be met. That is `pact-stakeholder-report`.
- No closing the week. That is `/week-review` on Friday.
- No creating pacts that do not hang off the goal.

## Where it sits in the week

```
Lunes    /week-goal      fija la meta de la semana
Diario   /day-start      abre el día
         /close-pact     cierra trabajo entregado
         /day-review     cierra el día
Viernes  /week-review    ¿llegó la meta? y qué pasa con lo que no
```
