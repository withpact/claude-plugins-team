---
name: pact-reporting
description: "Produce a by-person Planning View from beads — who is working on what, grouped by person, ordered by load. Use this whenever the user asks to see the team's open work, plan the week, or check what each person has, even if they don't name the format. For whether a milestone will land and who owns the blockers, use pact-stakeholder-report instead."
---

# Pact Reporting v0.3.0

Canonical format for the **Planning View** — the per-person "what is each person doing" view. Pact Client draws on this. You act under the user's own MCP identity.

> The project-level status report was retired. For "how is this project going / will we hit this milestone," use the **pact-stakeholder-report** skill — a milestone-and-ownership brief weighted by commercial outcome. This file now owns only the by-person planning view.

The Planning View requires an anchored goal. If no goal exists for what the user is asking about, redirect to goal elicitation rather than producing a view of nothing.

## Planning View

### When to produce one

Any phrasing that wants the work by person, not a milestone verdict: "qué tiene cada quien," "what's everyone working on," "qué hacemos hoy," "let's plan the week," "qué está pendiente," or **any question naming two or more people and their work** — even with a filter like "overdue" or "due today." The filter narrows scope; it never changes the format.

If the user instead asks whether a specific milestone will land, or wants a brief for a named stakeholder, that is the **pact-stakeholder-report** skill, not this view. When unsure which they want, ask once: "A milestone brief, or a by-person view of the work?"

### Format

Plain markdown, no code block. One block per person **with open work** (no open work → not listed). Each block:

1. A one-line theme synthesizing what the person is focused on. If their beads are genuinely scattered, write "trabajo variado:" — never invent a narrative.
2. A blank line.
3. A markdown bullet list — each bead on its own line, starting with `- ` (hyphen + space, the markdown list marker), then the bead id, then ` — `, then a short paraphrased title.

**The list-marker detail is critical.** `- ` at line start renders as real bullets. An em-dash `—` at line start renders as a paragraph — a wall of text. Each bead on its own line, always:

```
Javier está enfocado en definición del skill y repartir trabajo

- BEAD-0810 — meta del demo de hoy
- BEAD-0800 — pact.md drop-in
- BEAD-0795 — base del drop-in

Sandesh está en el front end (bloqueado)

- BEAD-0521 — project view de los 3 proyectos — esperando scope
```

### Rules

- **Order people by load**, heaviest first.
- **Order beads by urgency** within each person: overdue, due today, this week, later.
- **Annotations mark exceptions, not norms.** `(bloqueado)`, `(vencido)`, `(due hoy)` only where they change a decision. If every bead in a list would carry the same annotation, drop them and put it in the theme line ("todo vencido").
- **Titles are paraphrased for reading**; the id carries traceability.
- **Scope defaults to the anchored goal's descendants.** Transversal (all projects) only on explicit request, or when no goal is anchored.
- **No closing commentary.** The list is the deliverable. Analysis beyond it gets offered as a question, not appended.

### What the planning view never includes

Status verdicts, risks, milestone calls, RACI ownership, totals, percentages, people without open work, bars or charts — none of that. A milestone verdict with ownership is the **pact-stakeholder-report**. This view answers only "who is working on what."
