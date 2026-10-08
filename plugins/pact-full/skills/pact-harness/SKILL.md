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

# Pact Harness v0.5.1

The harness is one HTML page. It calls the **viewer's own** Pact connectors
from inside the page (the artifact's `mcp` capability), so every person needs
their own copy in their own account. A page shared across organizations can't
use the viewer's connectors. Your job is to fill in the four placeholders of a
small loader page and publish it. Do not redesign the page, and do not paste
pact data into it: it loads everything live.

The page keeps itself current: it loads the latest harness from the Pact
server every time it opens. Nobody republishes it or updates a plugin for a
new design.

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

## 2. Write the page from this loader

The page you publish is a small **loader**, not the full harness. When it opens, it
asks the viewer's Pact connector for the latest harness (`harness_template`) and
mounts it in place. So the page is always current, and you never copy the big
template: in claude.ai a 100 KB copy gets cut off, and the page then shows a bare
header with no data.

Copy this loader exactly, byte for byte, into a working file named
`harness-<first-project>.html`:

```html
<title>__TITLE__</title>
<div id="boot" style="font:14px system-ui,sans-serif;color:#6b6a65;padding:32px 20px;text-align:center">Loading your Management Harness…</div>
<script>
// Pact harness loader. The page itself is tiny: on open it asks the viewer's Pact
// connector for the latest harness (`harness_template`) and mounts it here, so it is
// always current and nobody republishes or updates a plugin to get a new design.
const CONFIG = {projects: __PROJECTS__, channels: __CHANNELS__, options: __OPTIONS__};
(async () => {
  const boot = document.getElementById("boot");
  const say = (t) => { boot.textContent = t; };
  const mcp = window.claude ? await window.claude.use("mcp") : null;
  if (!mcp) return say("Open this page in claude.ai with your Pact connector to see your harness.");
  let best = null, why = "";
  for (const p of Object.values(CONFIG.projects)) {
    try {
      const r = await mcp.callTool(p.server, "harness_template", {}, {cache: {staleTime: 600000, gcTime: 86400000}});
      const t = r && r.payload;
      if (t && t.html && (!best || t.version > best.version)) best = t;
    } catch (e) {
      why = e && e.code === "server_not_connected" ? `Add ${p.server} in claude.ai Settings → Connectors.`
          : e && e.code === "needs_reauth" ? `Reconnect ${p.server} in claude.ai Settings → Connectors.`
          : e && e.code === "selection_required" ? `Pick which ${p.server} connector to use when claude.ai asks, then reload.`
          : e && (e.code === "tool_error" || e.code === "bad_request") ? `${p.server} doesn't serve the harness yet. Ask the Pact team to deploy it.`
          : (e && e.message) || "The connector didn't answer.";
    }
  }
  if (!best) return say(why || "Your Pact connector didn't return the harness.");
  const tok = (k) => "__" + k + "__";
  const lit = (v) => JSON.stringify(v).replace(/</g, "\\u003c");
  const html = best.html
    .replace(tok("PROJECTS"), lit(CONFIG.projects))
    .replace(tok("CHANNELS"), lit(CONFIG.channels))
    .replace(tok("OPTIONS"), lit(CONFIG.options))
    .replace(tok("TITLE"), document.title.replace(/[&<>]/g, ""));
  const doc = new DOMParser().parseFromString(html, "text/html");
  window.__HARNESS_LOADER__ = best.version;
  for (const el of doc.querySelectorAll("link[rel=stylesheet],link[rel=preconnect],style")) document.head.appendChild(document.importNode(el, true));
  const scripts = [...doc.body.querySelectorAll("script")];
  scripts.forEach((s) => s.remove());
  boot.remove();
  for (const n of [...doc.body.childNodes]) document.body.appendChild(document.importNode(n, true));
  for (const s of scripts) { const x = document.createElement("script"); x.textContent = s.textContent; document.body.appendChild(x); }
})().catch((e) => { const b = document.getElementById("boot"); if (b) b.textContent = "The harness failed to load: " + ((e && e.message) || e); });
</script>
```

## 3. Fill the placeholders

The loader has four tokens, each appearing exactly once. Replace each one and
change nothing else.

| Token | Replace with |
|---|---|
| `__PROJECTS__` | a JS object, one entry per connector, keyed by the project name from `whoami`: `{"pactmd": {"label": "Pact", "server": "Pact MCP", "title": "Pact — Management Harness"}}` |
| `__CHANNELS__` | the display names of the user's Slack and Gmail connectors, `null` for one they don't have: `{"slack": "Slack", "gmail": null}`. A Slack connector has `slack_search_users` and `slack_send_message_draft`; a Gmail connector has `create_draft`. |
| `__OPTIONS__` | `{"add": true}` (shows the "+" that asks you to add a project) |
| `__TITLE__` | `Management Harness` |

- `label`: a short, capitalised project name for the switcher.
- `server`: the exact connector display name.
- `title`: `<label> — Management Harness`.

Never paste the full template (what `harness_template` returns) into the
page. The loader fetches it by itself.

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
- `artifact` lets older full-template copies republish themselves; keep it.
- `sample` lets the page write one-line "Latest" summaries. It runs on the
  viewer's account and asks consent once; without it the page shows a cleaned
  excerpt instead.
- If the user already has a harness artifact, **update that one** (pass its
  URL) instead of creating a second. Read it first, keep every project already
  in its `PROJECTS` (or `CONFIG.projects` in a loader page), and add the new
  ones. If it is an older full-template page, replace it with the loader.
  The page's "+" button copies exactly that request into the chat.
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
- New versions show up on their own the next time the page opens.

Never share one person's harness with someone in another organization. Their
connectors won't work there; they need their own copy, made with /harness.
