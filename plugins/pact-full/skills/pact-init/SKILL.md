---
name: pact-init
description: "Verify a Pact installation and report what is actually working — the connection, the identity, the bundle, and whether the skills loaded in this session. Use when someone says 'set me up with Pact', asks whether the plugin is working, has just installed or updated it, or reports that Claude seems to be ignoring Pact and behaving as it did before. Names the specific failure instead of leaving a silent one, then hands off to pact-onboarding."
---

# Pact Init v0.1.0

The first thing you run on a new install, and the thing you run when someone says Pact "isn't doing anything." Builds on Pact Core.

The problem this exists for: **every way a Pact install can be broken looks identical from the user's chair.** Connection down, wrong server, wrong bundle, unregistered user, a conversation older than the install — all of them present as "I installed it and Claude acts the same as before." None of them produce an error. Your job is to turn that one ambiguous symptom into a named diagnosis with a single next action.

Report what you observed. **Never report success on a check you did not run.**

## When this runs

- "Set me up with Pact", "help me set up in Pact", "am I set up?" — the line the README hands every new user.
- Someone just installed the plugin, or just updated it.
- Someone says Claude is ignoring Pact, not using the skills, or behaving exactly as it did before.
- Before onboarding anyone. A lesson about goals on top of a dead connection wastes both of you.

## The four checks

Run them in order and **stop at the first hard failure**. A later check reporting green over a broken connection is worse than no check at all.

### 1. Did the skills load? — already answered

You are reading this, so the plugin is installed and loaded **in this session**. Say so plainly. It is the one thing the user has no way to see for themselves.

Then give them the rule, because it is the most common cause of "it does nothing":

> Skills load once, when a conversation starts. A conversation that began before you installed or updated the plugin never picks it up — no error, no warning, it just behaves like before. Open a new conversation.

If they arrived here from a session that felt dead, that session was the problem, not the install.

**This check cannot fail from inside.** With no plugin, nothing would have run this skill — so a user in that state never reaches these words. No skill can report its own absence; that case belongs to the README.

### 2. Is the connection live, and to which Pact?

Call `whoami`. This is the only check that can be wrong in a way that does not look wrong.

| Result | Name it | What to say |
| --- | --- | --- |
| No response, or an error | `not-connected` | The Pact connection isn't reachable. Quote the actual error. **Stop here** — do not continue, do not offer onboarding |
| A user, on the project they expected | `ok` | Name the person and the project out loud |
| A user, on a different project | `wrong-server` | Several connections have the same shape; this one answers, so nothing looks broken while everything lands in the wrong place |
| Answers, but no registered user | `unregistered` | They can read, but anything they create lands unassigned. Whoever runs the project has to add them |

**Read the project name back and wait for them to confirm it is the one they meant.** `wrong-server` is the expensive failure precisely because it never errors — it quietly writes a person's work into someone else's project, and nobody notices for weeks.

### 3. Which bundle, and how old?

Needs a shell: a Claude Code terminal has one, Claude Desktop does not. On Desktop, skip this check and **say you skipped it and why** — a silent skip reads as a pass.

Where a shell exists, run `claude plugin list` and find the `pact@withpact` entry.

Both bundles name the marketplace `withpact` and the plugin `pact`, so the entry reads identically either way. Tell them apart by what is inside: **the team bundle carries `pact-code`, the client bundle does not.** Someone writing code on the client bundle has no code-session etiquette at all, and will never be told — name it `wrong-bundle` and say which one they need.

Version staleness is **not your job.** Pact Core already reports `plugin_version` to `whats_new` and offers the update when one exists. Do not duplicate it and do not run an update here.

### 4. Which surface?

Claude Desktop and the Claude Code terminal install differently and configure projects differently, and the answer changes what you tell them in step 3 and in the handoff. Establish it early — from whether a shell exists, or by asking one short question. Never assume Desktop because it is more common.

## Leave a marker

Where a shell exists, write `~/.pact/init.json` after a clean run: the date, the plugin version, the project you connected to, and the surface. Overwrite it — it records the last good run, not a history. Create nothing else and touch nothing the user owns.

This is bookkeeping, not conversation: **do not mention it, do not report it, do not ask permission for it.** Without it, nobody can later separate "installed and never initialized" from "initialized and it did not help" — two states that need opposite responses. On Desktop there is no shell and no marker; that gap is known and is being closed server-side.

## Idempotence

Detect state; never remember it. Every check reads live, so a second run on a healthy install simply reports healthy and stops. Do not redo work because the marker is missing, do not skip a check because the marker is present, and never delete or rewrite anything to "start clean."

## What to say back

Four lines. This is a confirmation, not a report.

1. **What is connected, and as whom** — "Connected to Cothon as René; plugin loaded in this session."
2. **Anything that failed**, by name, with the one action that fixes it. Nothing else.
3. **One thing to try right now** — the smallest real thing, using their own work: *"ask me what's on your plate today."*
4. **The session rule** — if anything still behaves like before, open a new conversation.

Then stop. Do not list the skills, explain beads, or tour the features. That is `pact-onboarding`, and only if they want it.

## Handoff

| After a clean run | Go to |
| --- | --- |
| No goals yet, or new to Pact | `pact-onboarding` |
| Already knows Pact, wants to plan | `pact-client` |
| In a terminal, about to work on code | `pact-code` |
| Any check failed | Nowhere. Fix it first |

## Limits

- **You report state; you do not repair installs.** Name what is wrong and the one action that fixes it. Do not install, update, or edit their configuration unprompted.
- **You do not configure workspaces or recurring routines.** Out of scope here, deliberately.
- **You do not teach.** The moment the checks pass, the conversation belongs to another skill.
- **A skipped check is a reported line, never silence.** Every check you could not run gets said out loud, with the reason.
