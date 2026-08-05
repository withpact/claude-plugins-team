# Pact

A coordination system for planning projects and reporting on them through your own Claude. You define what success looks like, structure the work, and see where things stand — all coordinated through a shared system called beads.

## What's inside

This plugin installs nine skills that activate on their own when relevant:

- **pact-core** — the shared foundation: how Pact thinks about work, and how it keeps everything coordinated through beads.
- **pact-init** — checks that your setup actually works: the connection, who you're connected as, and whether the skills loaded.
- **pact-onboarding** — the first five minutes: how to place work under a goal instead of leaving it adrift.
- **pact-client** — planning: take in work, structure it, decide what matters, see where a project stands.
- **pact-goals** — defining a project's goal and what success looks like, and revisiting it over time.
- **pact-reporting** — per-person planning views: who is working on what.
- **pact-stakeholder-report** — will we hit a milestone, and who owns what's in the way.
- **pact-code** (optional) — keeps a Claude Code session coordinated through beads.
- **pact-loops** (optional) — recurring reports delivered on a schedule.

And one slash command:

- **/my-pacts** — your open pacts as one structured table: stable `PACT-#### · alias` handles, Responsible & Accountable, due dates, and a completeness check. Same command, same table, every time.

## The one automatic check (Claude Code only)

The hardest thing to keep alive in a coding session is the answer to *"what got done?"*. Claude writes the code, the session ends, and the project is quietly a day out of date.

So this plugin watches for exactly that case. When Claude finishes a turn in Claude Code, it checks three things: did this session look at Pact, did the code change, and was anything written back to a bead. If the first two are true and the third isn't, Claude is asked to log what happened before it finishes.

It stays quiet the rest of the time — in repositories where you never opened Pact, in sessions where nothing changed, and in sessions where the work was already logged. It speaks at most once per session, and it never blocks your work.

Nothing to install or configure; it arrives with the plugin. To switch it off, set `PACT_STOP_HOOK=off` in your environment.

## Setup

1. Install this plugin.
2. Make sure the Pact connection is added to your Claude, so it can read and write your beads. If you don't have it, ask whoever shared Pact with you.
3. Say to Claude: **"Set me up with Pact."** It checks the connection, tells you which project you're connected to, and walks you into your first one.

That's it — nothing technical to configure. The skills run as you, in conversation.

**If Claude seems to ignore all of this**, the conversation is probably older than the install. Skills load when a conversation starts, so one that began before you installed the plugin never picks it up — and it won't tell you. Open a new conversation and say *"set me up with Pact."*

## First things to try

- *"Help me plan a new project."*
- *"How is [project] going?"* — a status report.
- *"Who's working on what?"* — a planning view.
