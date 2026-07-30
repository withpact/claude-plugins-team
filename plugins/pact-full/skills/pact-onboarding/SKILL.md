---
name: pact-onboarding
description: "Teach a brand-new Pact user to think in goals — why work is organized around goals the accountable party cares about, and how to place any task under one instead of creating orphans. Use this the first time someone connects to Pact, when they ask 'how does Pact work' or 'where do I start', when they're creating tasks with no goal in sight, or when they ask for onboarding or a walkthrough. Short and interactive: a few turns plus an optional interactive page, ending with the user's first real goal and a task anchored under it."
---

# Pact Onboarding v0.2.0

The first five minutes with Pact. Its whole job: get the user to *feel* why work lives in goals, so they stop producing orphan tasks and start asking **"what goal does this serve?"** before they create anything. Builds on Pact Core.

The belief behind it: **the goal is the unit that makes work mean something.** A task with no goal above it is motion — nobody can say whether it mattered. New users default to listing tasks; this skill re-wires that instinct in a few turns, using work the user actually cares about.

You act under the user's own MCP identity. The human decides what their goal is; you draw it out and reflect it back — you never invent it for them.

## When this runs

- The user's **first Pact session** — no goals yet under their name (`list_beads bead_type=goal` returns nothing relevant to what they describe).
- They ask **how Pact works**, where to start, or for a walkthrough / onboarding.
- They're about to create — or just created — a **task with no goal in sight** (pairs with the create-flow `⚠ No parent goal` prompt).

Keep it short. This is a doorway, not a course. If the user already thinks in goals, skip ahead to **pact-goals** and just help them build the tree.

## The orphan moment

The highest-leverage time to teach this is the instant a user creates a task with **no goal above it** — when the create-flow `⚠ No parent goal` prompt fires. Don't just help them pick a parent mechanically and move on: that prompt is the teachable instant, and this skill is what turns it into understanding.

When you see a pact created with no lineage:
1. **Offer the page, there and then** — *"New here? Here's the 60-second version of why this matters."* Share the interactive page (link below) unless they wave it off.
2. **Run the pivot question on the pact they just made** — "what does *this* one make possible?" — so the lesson lands on their own real work, not a toy example.
3. Then help them anchor it (or promote it to a goal, or create the goal it belongs under).

This is what makes the enforcement (the `⚠` prompt) feel like help instead of a nag.

## The one idea

Everything here serves a single re-wiring: **task → "what goal does this serve?" → goal.** Three altitudes, in the user's own words:

- **Goal** — an outcome you'd be glad to reach. Measurable; you'd know the moment it's met.
- **Milestone** — a checkpoint on the way, ideally demo-able.
- **Task** — a concrete step that only matters because of the goal above it.

## The flow — one beat per turn

Do NOT lecture or dump all three altitudes at once. Run it as a short exchange, using the user's own work as the material.

**Open with the choice — lead with the visual.** First thing, offer the hands-on version: *"Want to try this in about a minute, hands-on — or just talk it through?"*
- **Hands-on** → share the interactive page (link below) **right now**, let them anchor the pacts, then debrief with the pivot question (step 2). Make this the **default** — the visual teaches the move faster than any explanation, and it's the whole point of showing rather than telling.
- **Talk it through** → run the verbal flow below.

Either way you land in the same place. The visual is not a step-4 afterthought — it's the front door.

1. **Start from their world.** "Before we set anything up — what's one thing you're trying to get done right now?" Take whatever they give you, even a vague task.

2. **Ask the pivot question.** "What does getting that done actually make possible — what's the outcome you'd care about?" This *is* the lesson. Keep pulling until you reach a state of the world, not another activity — "so the renewal doesn't slip," not "so the deck is finished." A "nice to have" is not a why.

3. **Reflect the altitude back.** Play their own example back as goal → task: the outcome they just named is the **goal**; the thing they said first is a **task** under it. Then name the move out loud — *that question, "what does this make possible?", is the one to ask before you create any pact.*

4. **Make it real.** Hand off to **pact-goals** to turn their outcome into a proper goal with a human-evaluable success criterion, then anchor the task they started with underneath it (add the task's ID to the goal's `depends_on` — the parent carries the child). They leave with a real tree, not a lesson.

## The interactive page

The interactive primer is hosted at **https://www.withpact.com/think-in-goals.html** — one source of truth, nothing to bundle or keep in sync. Offer it **up front** (the front door of the flow) and again **at the orphan moment**: just share the link. It teaches the same move — anchor adrift tasks to the goal they serve — and closes on "what goal does this serve?", tying back to the live create-flow prompt (whose ⚠ "walk me through goals" link points to the same page).

## Handoff

- Ready to define the goal properly → **pact-goals**.
- Wants the full vocabulary and rules → **pact-core**.
- Day-to-day planning after onboarding → **pact-client**.

Never leave the user holding a task with no goal. If they resist naming an outcome, that *is* the conversation — a task nobody can tie to a goal is usually one worth questioning, not creating.
