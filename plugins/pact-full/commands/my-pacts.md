---
description: Your open pacts as one structured table — stable handles, Responsible & Accountable, due dates, and an explicit completeness check.
---

# /my-pacts v0.2.0 — the structured personal view

Produce the user's open pacts as ONE deterministic table. This command is a
fixed format: same command, same board, same table. No free-form substitution,
no editorializing. Where a Pact skill rule conflicts with this file for this
command ("no bead IDs unless asked", "paraphrase titles for reading"), THIS
FILE WINS — here, stable handles and verbatim titles are the point: the reader
must be able to trust every cell as a fact from the board, not a retelling.

## Data — exactly these calls

1. `whoami` — once, to confirm identity and project. If several Pact servers
   are connected, use the one whose project the user is working in; ask once
   if genuinely ambiguous.
2. `list_beads` with `assignee: <identity>` — pacts the user is Responsible for.
3. `list_beads` with `approver: <identity>` — pacts the user is Accountable for.

Both list calls return open pacts only (the server default) — do not pass a
status filter. If the assignee call returns zero and the user clearly has
work, retry once with their display name; if still zero, report zero — never
pad, never guess.

## Render — strict

Merge the two result sets, deduplicating by PACT id. Sort by due date
ascending, undated last (the server's own order). Render exactly:

1. One header line: `**Your pacts in <project> — <today YYYY-MM-DD>**`
2. One markdown table:

   | Pact | Title | R | A | Due |

   - **Pact** — the stable handle exactly as the server returned it:
     `PACT-#### · alias`. Never invent, shorten, or paraphrase a handle.
   - **Title** — verbatim from the server. Truncate past 80 chars with `…`;
     never reword.
   - **R / A** — the Responsible (assignee) and Accountable (approver) names
     exactly as returned; `—` where the server shows none.
   - **Due** — `YYYY-MM-DD` as returned; `—` when none. Prefix dates already
     past with `⚠`.

3. The reconciliation footer — always, as the last line. This is the
   completeness proof:

   `✓ Complete: Responsible query returned N_R · Accountable returned N_A · overlap N_B → N rows above. Nothing omitted.`

   The counts come from the servers' own `**N pact(s)**` headers and your
   dedup, and must satisfy N = N_R + N_A − N_B. If the row count doesn't
   reconcile, fix the table — never the footer.

## What this command never does

- No status column. Status is not a real Pact metric and its values don't
  track reality (PACT-1063). The server's list lines still carry a status
  glyph and word — drop them here; status stays everywhere else in Pact.
- No summary, no theme line, no risk commentary, no advice, no next steps.
- No dropping "boring" rows, no adding related items. The table answers
  exactly one question: *what is mine, and is it all here?*
- No mutations. This command only reads.

After the footer you may add exactly one line:

`Drill in: "get PACT-####" · act: "reschedule / close / comment on PACT-####"`
