---
name: pact-goals
description: "Define and re-evaluate the goal of a project before and during work. Use this whenever the user is starting a new project, planning a week without a clear goal yet, asking what to focus on, preparing for an upcoming demo, or when it has been about a week since the project's goal was last revisited. Produces a goal-and-milestone structure with human-evaluable success criteria. Make sure to use this when success looks fuzzy or undefined."
---

# Pact Goals v0.5.0

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
2. Present the picture — a milestone brief (pact-stakeholder-report) on the goal or its nearest milestone is the grounding artifact.
3. Ask exactly three questions, one per turn:
   - Is the goal still the right goal?
   - Is the success criterion still how you'd evaluate it?
   - Are the assumptions still holding?
4. Act on answers: goal changed → `update_bead` with reason; milestone obsolete → update or cancel; assumption broke → record it and ask whether the goal itself moves.
5. Record the check-in: `comment_on_bead` on the goal starting `[goal-check] [YYYY-MM-DD]` with what was said and what changed. This stamp is how the next session knows when the last check happened.

The second question is where a milestone's *meaning* shifts even when its date doesn't — recurring check-ins re-evaluate not just whether the goal is on track but whether its definition of success still holds. Watch for success migrating from "did we build/ship it" toward "did we produce the commercial outcome" (a customer's purchase-driving use case); when it does, rewrite the success criteria to match, and keep the date decision separate from the definition decision — the two move independently.

If the user declines to re-evaluate, accept — record the check-in noting they declined. The stamp matters even when nothing changes. If the same milestone has slipped across multiple check-ins, name the pattern: smaller milestone, changed goal, or an unnamed blocker.

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
