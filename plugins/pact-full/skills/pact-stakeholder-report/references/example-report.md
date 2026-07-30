# Worked example — the report this skill was distilled from

This is the final, approved version of a real stakeholder milestone report (Cothon, North Star
milestone, prepared for Max). Use it as the quality bar and to see the principles applied: owner-first
gates and blockers, RACI labels, a date on every line, delivered + exploratory work both credited,
and blockers merged with the decisions they need (no separate decisions section).

---

# North Star — status for Max

*Cothon · June 16, 2026*

**The milestone:** Spencer or Marcella at MGF finishes a full review in *My document review* on their own and wants to do it again. Target **June 27**. **Responsible: Will · Accountable: Max.**

*(R = does the work · A = signs off / decides · C = consulted)*

## Will we hit it?

Not on the current path. Yann is Responsible for both gates: the speed gate is essentially closed; the overwhelm gate is stuck on a UX direction that only Will (A) and you (C) can choose. Recoverable if that choice lands before Will leaves on June 19.

## The two gates

**Speed — closed pending validation.** *Gate due June 13; fix shipped ~June 12. R: Yann, built by René · A: Will.* Evidence search is down from 7–20 seconds per claim to ~5–6 seconds for a full page, with caching shipped and the backend stabilized. Only real-cohort validation remains.

**Overwhelm — open, and it's the blocker.** *Gate due June 13, now overdue. R: Yann + Shiva (UX) · A: Will · C: Max.* Shiva has done the exploration: she delivered mockups back in May (comment-style/Word interface, per-paragraph collapse-and-explode, gray highlighting for pending claims) and is now exploring screenshot-trust representation. What's missing is a chosen direction — nothing is built or on staging. The unresolved problem (too many claims, too much highlighting, no signal of what matters first) is what Will named as the reason a writer abandons the tool for ChatGPT.

## Blockers and the calls they need

1. **Overwhelm UX direction — A: Will, C: Max. Needed before June 19.** Shiva's mockups are ready; pick one so she can build and the cohort can test. This is the single unlock.
2. **"Finish it yourself" actions — R: Yann. Overdue since June 9.** Editing a claim, restarting a search, adding evidence, and the unresolved-claims view are all unstarted — without them a user can't complete a review unaided, which is the literal bar. Decide: fast-track, or descope to the minimum that lets one person finish.
3. **Cover for Will — A: Max, before June 19.** Will owns the milestone, approves the overwhelm direction, and onboards Spencer and Marcella — and is out ~5 weeks from June 19. Name a successor for those roles.
4. **The date — A: Max, by June 19.** The full-team budget runs to ~June 30, so June 27 sits at the edge. Hold it only if the overwhelm direction lands this week; otherwise reslip on purpose rather than let it drift.
