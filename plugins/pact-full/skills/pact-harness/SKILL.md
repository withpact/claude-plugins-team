---
name: pact-harness
description: >-
  Generate, or update, the user's own live Management Harness: a dashboard
  artifact they keep open beside the conversation. It reads their Pact projects
  through their own connectors and shows a Daily brief, activity, projects,
  themes, people, archive and "ready to close" with an Approve button. Use it
  when the user asks for the harness, the dashboard, "el tablero", a
  side-by-side view of their project, to update or add a project to their
  harness, or runs /harness. It publishes one artifact; it never writes to a
  pact by itself.
---

# Pact Harness v0.4.2

The harness is one HTML page. It calls the **viewer's own** Pact connectors
from inside the page (the artifact's `mcp` capability), so every person needs
their own copy in their own account. A page shared across organizations can't
use the viewer's connectors. Your job is to fetch the template, fill in its
four placeholders and publish it. Do not redesign the page, and do not paste
pact data into it: it loads everything live.

The page updates itself. When Pact ships a newer template, the page shows
"A new version of the harness is ready" with an **Update** button, and one
click republishes it in place. Nobody has to update a plugin for that.

## 1. Find the user's Pact connectors

Each Pact connector is a beads-api server. You can recognise one by its tools
`whoami`, `list_goals`, `list_beads` and `get_bead`.

- For every such connector in this session, call `whoami` once. It answers
  "Connected as `<dev>` to project `<project>`".
- Record the project name and the connector's **display name** as claude.ai
  shows it. That is the `<connector>` part of `mcp__<connector>__whoami`, with
  underscores read as spaces, for example `Pact MCP` or `ConducereMCP`.
- If the user named projects ("solo Conducere"), keep only those. If they
  didn't, keep every Pact connector.
- With no Pact connector, stop. Tell them to add their Pact connector in
  claude.ai → Settings → Connectors first.

## 2. Get the template

Call `harness_template` (no arguments) on any of those connectors. It returns
JSON `{version, html}`; `html` is the template. If no connector has the tool
yet, use `harness.html` next to this file instead. It is the same template, as
of this plugin's release.

## 3. Fill the placeholders

The template has four tokens, each appearing exactly once. Replace each one
and change nothing else.

| Token | Replace with |
|---|---|
| `__PROJECTS__` | a JS object, one entry per connector, keyed by the project name from `whoami`: `{"pactmd": {"label": "Pact", "server": "Pact MCP", "title": "Pact — Management Harness"}}` |
| `__CHANNELS__` | the display names of the user's Slack and Gmail connectors, `null` for one they don't have: `{"slack": "Slack", "gmail": null}`. A Slack connector has `slack_search_users` and `slack_send_message_draft`; a Gmail connector has `create_draft`. |
| `__OPTIONS__` | `{"add": true}` (shows the "+" that asks you to add a project) |
| `__TITLE__` | `Management Harness` |

- `label`: a short, capitalised project name for the switcher.
- `server`: the exact connector display name.
- `title`: `<label> — Management Harness`.

Write the result to a working file named `harness-<first-project>.html`.

## 4. Publish

Publish it with your Artifact tool (icon `dashboard`) and these capabilities:

```json
{
  "artifact": {},
  "sample": {},
  "mcp": {"servers": [
    {"server": "<Pact display name>", "tools": ["whoami", "list_goals", "list_beads", "get_bead", "list_history", "graph_read", "add_note", "update_status", "message_user", "harness_template"]},
    {"server": "<Slack display name>", "tools": ["slack_search_users", "slack_send_message_draft"]},
    {"server": "<Gmail display name>", "tools": ["create_draft"]}
  ]}
}
```

- Include the Slack and Gmail entries only for connectors the user has, and
  name the same ones in `__CHANNELS__`.
- `artifact` lets the page republish itself when the user clicks Update.
- `sample` lets the page write one-line "Latest" summaries. It runs on the
  viewer's account and asks consent once; without it the page shows a cleaned
  excerpt instead.
- If the user already has a harness artifact, **update that one** (pass its
  URL) instead of creating a second. Read it first, keep every project already
  in its `PROJECTS`, and add the new ones. The page's "+" button copies exactly
  that request into the chat.
- If this surface has no Artifact tool, or it can't declare capabilities, say
  so plainly. Point them to Claude Code or Cowork, where it can. Never fall back
  to a static page with data pasted in.

## 5. Hand it over

Open it beside the conversation and tell the user, in one or two lines:

- The first load asks permission for each connector. Allow it.
- **Daily brief** opens first: their overdue work, what is due this week, what
  waits on their review and what just closed, plus suggested follow-ups.
- **Approve close** really closes the goal: it writes an evidence note, then
  sets the goal `done`. "Start follow-up" writes a Slack or Gmail **draft**,
  so nothing is sent until they send it.
- New versions arrive as an **Update** button on the page itself.

Never share one person's harness with someone in another organization. Their
connectors won't work there; they need their own copy, made with /harness.
