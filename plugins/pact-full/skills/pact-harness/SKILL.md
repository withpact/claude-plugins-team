---
name: pact-harness
description: >-
  Generate the user's own live Management Harness, a dashboard artifact they
  keep open beside the conversation. It reads their Pact projects through their
  own connectors and shows activity, projects, themes, people, archive and
  "ready to close" with an Approve button. Use it when the user asks for the
  harness, the dashboard, "el tablero", a side-by-side view of their project, or
  runs /harness. It publishes one artifact; it never writes to a pact by itself.
---

# Pact Harness v0.2.3

The harness is a page in `harness.html`, next to this file. It calls the
viewer's own Pact connectors from inside the page, using the artifact's `mcp`
capability. Because of that, every person gets their own copy, wired to the
connectors *they* have. Your job is to fill in its one placeholder and publish
it. Do not redesign the page, and do not paste pact data into it: it loads
everything live.

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

## 2. Fill the placeholder

Read `harness.html`. Replace the single token `__PROJECTS__` with a JS object
literal. The key is the project name from `whoami`:

```js
{
  "pactmd":    {"label": "Pact",      "server": "Pact MCP",     "title": "Pact — Management Harness"},
  "conducere": {"label": "Conducere", "server": "ConducereMCP", "title": "Conducere — Management Harness"}
}
```

- `label`: a short, capitalised project name for the switcher.
- `server`: the exact connector display name.
- `title`: `<label> — Management Harness`.

Change nothing else in the file. Write the result to a working file named
`harness-<first-project>.html`.

## 3. Publish

Publish it with your Artifact tool (icon `dashboard`). Declare one `mcp`
server entry per connector:

```json
{"mcp": {"servers": [
  {"server": "<display name>", "tools": ["list_goals", "list_beads", "get_bead", "list_history", "add_note", "update_status"]}
]}}
```

- Leave `list_history` out of a connector that doesn't expose it; the page
  falls back to goal notes and says so.
- If the user already has a harness artifact from an earlier run, update that
  one (pass its URL) instead of creating a second.
- If this surface has no Artifact tool, or it can't declare capabilities, say
  so plainly. Point them to Claude Code or Cowork, where it can. Never fall back
  to a static page with data pasted in.

## 4. Hand it over

Open it beside the conversation and tell the user, in one or two lines:

- The first load asks permission for each connector. Allow it.
- **Approve** under "Ready to close" really closes the goal: it writes an
  evidence note, then sets the goal `done`.
- "Copy for Claude" in any pact's panel copies its handle, so they can paste it
  here and keep talking about it.

The page is private to them until they share it from its Share menu. Anyone it
is shared with sees it through *their own* connectors, not the author's.
