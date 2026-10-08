---
description: Open your live Management Harness beside the conversation — activity, projects, themes, people and ready-to-close for your Pact projects, read through your own connectors.
---

# /harness v0.2.0

Load the `pact-harness` skill and follow it exactly: find this user's Pact
connectors with `whoami`, fill the four placeholders of the small **loader**
page printed in the skill, publish it with the capabilities the skill lists,
and open it beside the conversation.

Never publish the full harness template (what `harness_template` returns).
It is about 100 KB; copying it gets cut off and the page loads no data. The
loader fetches the template by itself every time it opens.

If the user passed project names after the command (`/harness conducere`),
include only those projects. With no argument, include every Pact connector
they have.
