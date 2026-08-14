---
name: pact-stakeholder-report
description: >-
  Prepare a concise, ownership-first brief on whether a Pact/beads project will hit a specific
  milestone and what is blocking it. Use whenever the user asks to prepare or write a report for a
  named person ("prepare a report for Max", "algo para Will"), or asks "are we going to hit
  [milestone/date]", "vamos a llegar al hito X", "what's blocking [milestone]", "will we make it",
  or "status of [milestone] for [stakeholder]" — even without the words "milestone", "RACI", or
  "report". Produces a short founder-facing brief: a verdict weighted by commercial outcome (not
  task completion), gates separated from blockers, an RACI owner and a date on every gate and
  blocker, delivered and exploratory work both credited, and blockers merged with the decisions
  they need. Interest-aware: reads the stakeholder's user profile and per-pact important_to marks
  to weight prominence. Works on any Pact/beads tracker via its MCP. For a by-person view of who
  is working on what, use the Pact planning view instead.
---

# Stakeholder Milestone Report v0.3.0

## What this produces

A short, shareable brief (markdown file) that answers one question for one stakeholder: **are we
going to hit milestone X, and what's blocking it?** Plus a one-line verdict delivered in chat.

The reader is a busy decision-maker (a founder, an approver, an exec). They want the call, the
ownership of what's in the way, and the decisions only they can make — not an inventory of tickets.
Per Pact: *less is more with humans.* If the brief reads like a memo, it's too long.

## Step 1 — Anchor to the milestone

The report is meaningless without a specific milestone to measure against. Find the milestone bead:

- `list_beads` / `search_beads` for `bead_type: milestone` or titles starting with `Milestone:`.
- Resolve the user's informal reference ("North Star", "el del cohort") against milestone titles.
- If two or more plausibly match, ask once by human title — never by ID.
- If the request is really about a whole goal, anchor to the goal bead instead; the method is identical.

`get_bead` on the anchor. Read its description/acceptance criteria, its **assignee** and **approver**,
its **due date**, and its `depends_on` list. The description often names the real success
condition and constraints (budget window, who must sign off, calendar events) — mine it.

## Step 2 — Walk the dependency tree

`get_bead` each item in `depends_on`. As you go, sort them into three buckets and record, for each,
its **status, due date, assignee, and approver**:

- **Gates** — dependencies that are themselves milestones (sub-milestones). These are the major
  swim lanes the milestone rides on. Each gate usually has its own `depends_on` worth a quick look.
- **Supporting work** — the individual tasks under the milestone or its gates.
- **Moved / out of scope** — items the description or notes say were re-homed elsewhere. Don't report these.

For every bucket, note three things, because the reader needs all three to trust the verdict:
**what's delivered, what's still exploratory, and what's unstarted.** Crediting delivered and
exploratory work is not padding — a reader who only sees gaps assumes nothing happened and makes the
wrong call. Name the work a person actually did (mockups, a spike, a shipped fix), not just the hole.

Also scan the anchor's and gates' notes for **hard dates and constraints** that change the verdict:
an owner going OOO, a budget/runway window, an external dependency. These often matter more than any
single task.

Collect the project's **documented wins** as you walk: beads tagged `win` (`list_beads` with
`tag: win`) and notes prefixed `WIN:` — written by pact-win-detection or by hand. A win is a
client-side outcome (a meeting booked from a generated lead, a renewal, recurring unaided use),
which makes it the strongest form of delivered evidence: credit it by name, and let it reach the
verdict when it drives the commercial call. When no win sweep has run recently, run
pact-win-detection first if it is available in this session.

## Step 3 — Read what this stakeholder cares about

Before forming the verdict, call `get_user_profile` with `user: <the stakeholder>`. The entries are
the person's standing interests, priorities, and reading style. Use them to **weight** the brief:

- Give prominence — earlier placement, more detail — to gates, blockers, and delivered work that
  touch what the profile says they care about. Compress (one line, still present) what they have
  shown no interest in.
- While walking beads in Step 2, check each bead's `important_to` field. If it names this
  stakeholder, surface that pact prominently regardless of its size — in the verdict if it drives
  the call, otherwise at the top of its section.
- Apply the profile selectively: it shapes emphasis and ordering only. Never filter out overdue
  items, blockers, or anything the stakeholder is Accountable for — de-emphasize, don't drop.
- Match any style entries (report format, register, length) when writing the brief.
- If the profile is empty or the call fails, skip this step and write the standard brief.

## Step 4 — Form the verdict

State plainly whether the milestone will land **on the current path**. Judgment, not arithmetic:

- Weight by **commercial outcome, not task completion.** A milestone whose technical work is done but
  whose real-world condition (a user finishing a review unaided, a deal closing) hasn't happened is
  *not* hit. Delivered ≠ converted.
- A gate that's substantively done pending validation is good news — say so.
- A gate stuck on an undecided product call, or core supporting work unstarted and overdue, means the
  milestone is at risk regardless of how much else shipped.
- Be honest and specific about recoverability: what would have to be true this week for it to land.

## Step 5 — Assign ownership in RACI terms

Ownership is the spine of this report. Map Pact roles to RACI so the reader knows exactly who holds each thing:

- **assignee → Responsible** (does the work)
- **approver → Accountable** (signs off / makes the call)
- people who must weigh in but don't own it → **Consulted**
- people who just need to know → **Informed**

Lead every gate and every blocker with its owner. When a blocker is a *decision* rather than work
(e.g. an undecided UX direction), the owner is whoever is Accountable for that decision — usually an
approver or the stakeholder themselves, not the engineer waiting on it. Make that explicit; it's
often the single most useful line in the report.

Include a one-line RACI legend so a reader who doesn't live in the framework can follow it.

## Step 6 — Write the brief

Use this structure. Skip any section with nothing real in it; never pad to fill it.

```
# [Milestone, plain-language] — status for [Stakeholder]

*[Project] · [date]*

**The milestone:** [the real success condition in one sentence]. Target [date].
**Responsible: [owner] · Accountable: [approver].**

*(R = does the work · A = signs off / decides · C = consulted)*

## Will we hit it?

[2–3 sentences: the verdict on the current path, the single biggest reason, and what would
have to happen for it to land.]

## The gates

**[Gate 1] — [one-line state].** *[due date / shipped date]. R: [owner] · A: [approver].*
[What's delivered, what's exploratory, what remains — one tight paragraph.]

**[Gate 2] — [one-line state].** *[date]. R: [owner] · A: [approver] · C: [if any].*
[...]

## Blockers and the calls they need

1. **[Blocker] — [RACI owner]. [date / "overdue since X"].** [Why it blocks, and the specific
   decision or action needed. One item, one fact — don't repeat it elsewhere.]
2. **[Blocker] — [owner]. [date].** [...]
```

### Writing principles (these are what made the report "good enough")

- **One fact, one place.** The biggest failure mode is repeating the same concern in the verdict, the
  gates, and the blockers — the reader sees it three times and tunes out. Merge blockers with the
  decisions they require into a single list; don't write a separate "decisions" section that restates
  the blockers. The verdict may *reference* a theme without re-stating the item the blocker names.
- **A date on everything.** Every gate and blocker carries a date — due, shipped, or "overdue since."
  Dates are how the reader judges urgency; an undated blocker is just an opinion.
- **Owner first.** Each gate and blocker opens with who holds it (RACI), not with the task.
- **Credit real work.** Name delivered and exploratory work by who did it. Balance keeps it honest.
- **Match the reader's language.** Write the brief in the language the stakeholder reads (the Cothon
  team works in English/Spanish — follow the user's cue).
- **Founder register.** Short sentences, no ticket IDs in prose (parenthetical at most), no closing
  commentary. The brief is the deliverable.

## Choosing an output format

The verdict and "calls needed" prose stay the same across formats — what changes is how the blocking
work is shown. Offer the stakeholder one of these; when unsure, ask once. The first two are pure
markdown (editable, paste-anywhere); the last two are visuals delivered as a standalone `.svg` plus
the markdown brief.

1. **Indented tree (default, markdown).** Nested bullets, one bead per line, consistent
   `[status icon] NUMBER · title — R/A · date`. Indentation = blocking (a child must land for its
   parent). Best when the report lives in Slack or a doc and must stay copy-paste friendly. This is
   the shape shown in `references/example-report.md`.
2. **Table (markdown).** One row per bead with a `Blocks` column carrying the dependency. Sortable
   and scannable; the relationship is read in a column rather than seen. Columns:
   `Status · Number · What · Blocks · Owner (R/A) · Date`.
3. **Dependency graph (SVG).** Milestone on top, gates as boxes, supporting beads as chips, each
   gate's chips inside a shaded container so membership is obvious; arrows point to what a bead
   blocks. Best for a founder skim of "what blocks what." Template: `references/example-graph.svg`.
4. **Gantt timeline (SVG).** One row per bead against a date axis, grouped into shaded swimlanes per
   gate. Bars are colored by status; the **red stretch = the overdue portion, so its length is how
   late an item is.** Vertical guide lines mark today, the deadline, and key dates (an owner's leave,
   a budget edge). Best for showing schedule pressure and slippage. Template:
   `references/example-gantt.svg`.

### Conventions for the SVG visuals (graph and Gantt)

Follow these so every report looks the same:

- **Status colors:** done `#3a9e5c` · in progress `#d6921f` · in review `#3b82c4` · not started
  `#8a8a8a` · overdue/blocker `#d6453d`. Milestones/gates are diamonds; the milestone itself is amber
  (at risk) unless genuinely on track.
- **Labels:** drop the `BEAD-` prefix — keep the number (`0606 · parallel search 15×`). Keep titles
  to a few words.
- **Standalone file:** write concrete hex colors and a white background `rect` (not CSS variables) so
  the `.svg` renders correctly when opened or shared outside chat. Include `role="img"` with `<title>`
  and `<desc>`. Always include a one-line color legend.
- **Graph:** arrows point from a bead to what it blocks (up toward the milestone). Put each gate's
  supporting beads in a faint shaded box to show grouping.
- **Gantt:** map ~22px per day; one shaded lane per gate with a colored left accent and a bold gate
  header, beads indented beneath. Draw the overdue stretch in red up to "today" so lateness is
  literally the bar length.

Read the matching template in `references/` and adapt it to the milestone's beads, dates, and owners
rather than building from scratch.

## Step 7 — Deliver

Save the brief as `[Milestone]-status-for-[Stakeholder].md` in the outputs folder. For a visual
format, also save `[Milestone]-timeline.svg` (or `-graph.svg`) and reference it from the brief with a
relative `![...](...)` link — note to the stakeholder that the two files must travel together for the
image to render, or to drop the SVG straight into Slack/Notion. Present everything with
`present_files`. In chat, give the one-line verdict and the headline blocker — not a recap of the
doc. Offer to record the assessment as a note on the milestone bead so it's in the audit trail.

See `references/example-report.md` for the worked brief, and `references/example-graph.svg` /
`references/example-gantt.svg` for the two visual formats (all from the report this skill was distilled from).
