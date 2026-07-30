---
name: pact-loops
description: "Turn a recurring Pact task, most commonly a periodic milestone or status report, into a self-running routine on a schedule. Use this whenever the user wants a report delivered automatically on a cadence (for example a daily brief or a weekly status) without starting it by hand each time. Optional: only needed when the user explicitly wants a recurring routine."
---

# Pact Loops v0.4.0 (optional)

Most Pact work is one human, one Claude, one conversation. This optional skill is for the exception: a task worth running on a schedule without someone starting it each time — most commonly a recurring milestone-and-ownership report. Builds on Pact Core. Use it only when the user explicitly wants a routine; nothing in Pact requires loops to function.

You act under the user's own MCP identity. A loop here is not an autonomous agent with its own identity — it is a recurring task the user has set up, running as them.

## When a loop is worth it

A loop earns its place when the same task recurs on a predictable cadence and the value is in it happening reliably without prompting. The clear case: "post a milestone report for this project every Monday at 9am." Weaker cases — anything needing judgment about *what* to do each time — are better left as conversations the human starts.

The other clear case is **standing or time-boxed monitoring** — "watch the error rate during the pilot", "check in on X weekly through June". As a dated bead that work dies the day its window closes and reads overdue forever; as a loop it runs its window and stops. When a user describes recurring attention with an end condition, set it up here (end date in the schedule) instead of letting it become a bead.

If the user asks for something fancier than a recurring report (agents taking work from a queue, multi-step automation), that is beyond this skill — it's the internal agent system, which runs in the Pact team's own infrastructure, not in a distributable skill.

## Setting up a recurring report

This is the supported, self-onboarding path. When the user wants a periodic report:

1. **Confirm the shape, one question per turn:** which project (goal), what cadence (daily, weekdays, weekly — e.g. every morning at 9am), where the report goes (a Slack channel, a saved file, or just the task thread), and which report (a milestone brief via pact-stakeholder-report is the default; the by-person Planning View is the other option).
2. **Confirm the goal exists.** A report needs an anchored goal (per Pact Reporting). If none exists, route to goal elicitation first — a recurring report on an undefined goal is recurring theater.
3. **Set it up as a Cowork scheduled task.** The mechanism is Cowork's own `/schedule`: in a Cowork session, type `/schedule` and Cowork walks through frequency, time, and the prompt. Hand the user the exact prompt to paste — see the template below — so the scheduled task knows to produce the Pact report. Or, if you are already in a Cowork session with the user, you can run `/schedule` together and fill it in.
4. **Confirm it's live** and tell the user when the first run fires, where it'll land, and the one caveat: a Cowork scheduled task only runs while the computer is awake and Claude Desktop is open. If the machine is asleep at the scheduled time, Cowork runs it once when the machine wakes. For a report that must fire regardless, that's a Claude Code cloud routine, not a Cowork task — mention it only if reliability matters to them.

### The prompt to paste into /schedule

Give the user a ready-to-paste prompt, filled in with their goal and destination. Template:

```
Using the Pact skills, produce a milestone-and-ownership report for the goal
"[goal title]". Anchor to that goal, gather its beads through the Pact
connection, and follow the pact-stakeholder-report skill's format.
Then [deliver it: post to #channel / save as status-[date].md in my
[folder] / leave it in this thread]. Keep it honest — status reflects
the commercial outcome, not task counts.
```

The scheduled task runs as a fresh session, so the prompt must name the goal explicitly (it has no memory of this conversation) and must tell Claude to use the Pact skills and connection. That is the "more is more with machines" rule in practice — this prompt is read by a future Claude with no context.

### A north-star daily report

The common case: one important goal (the north star) the user wants to see every morning. Setup is the same — `/schedule`, daily cadence, the paste-prompt above with the north-star goal named. Default to the milestone brief (pact-stakeholder-report); it answers "will we hit it, and what's blocking" in one read. If they have several goals and want all of them daily, that's still one task — the prompt can say "for each active goal, produce a short milestone brief" — but warn that a digest of many reports is longer and easier to ignore than one focused on the goal that matters most.

## What each run does

On each scheduled run, the routine:

1. Anchors to the configured goal.
2. Produces the configured report — a milestone brief (pact-stakeholder-report) or the by-person Planning View (pact-reporting) — same formats, same honesty rules.
3. Delivers it to the configured destination, in the right register: a report dropped in Slack reads like a person posted it, not like a memo.
4. Stays quiet when there's nothing to say only if the user asked for that; by default it reports every cycle, because a "nothing changed" report is itself signal.

## Keep it honest

A recurring report is the easiest place for stale or padded output to hide, because no one prompted it. The same rules apply harder: status is real judgment (delivered-but-not-converted is yellow), risks are real risks not filler, the brief describes shape without re-inventorying items. A loop that cries green every week trains the reader to ignore it.

## Limits

- **One loop, one clear job.** If a user wants several recurring outputs, set up several simple loops, not one that tries to do everything.
- **No silent scope growth.** A reporting loop reports. It does not start creating or closing beads on its own — changing project state is a human decision, made in conversation.
- **The user owns the cadence.** Pausing, changing, or removing a loop is a thing the user does; surface how when you set it up.
