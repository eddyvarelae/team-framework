# REVIEW.md — framework vs. what actually happened in TEA

**Planner (TEA) — 2026-09-07.** Reviewed: `README.md`, `TEAM.md`, `actors/*.md`, plus the scaffolds (`BACKLOG.md`, `DECISIONS.md`, `channels/`, workspace dirs). Reviewed against: the-everything-app's real record, Aug 20 – Sep 1 (channel files, BACKLOG, git history, run logs). Verdict up front: **the template captures most of what made TEA work, and one of its origin stories is wrong in a way that matters.** The additions below are each backed by a specific TEA event.

---

## 1. What the template gets right (confirmed by TEA evidence — keep as-is)

- **Evidence-required "done" (README rule 2).** This rule caught real bugs, not just sloppiness: the runner was writing `runs` rows with the anon key, silently rejected by RLS — found only because verification of the row id was demanded. Same story for the `email-reader/.venv` MCP entrypoint (empty dir, config copied from a stale file) and the "51 ghost cards" scare (resolved by an actual `select count(*)`, not by trusting the code read). This is the single highest-value rule in the framework.
- **Two-inboxes rule (README rule 7 / TEAM rule 7).** Word-for-word the status canon TEA adopted after the first external-agent card blurred "blocked on Eddy" with "finished, review me" (user-feedback item 8). Proven within a day of adoption: the Aug 23 sweep correctly filed a `- [!]` ACTION (blocked) while landing itself in needs-review (finished).
- **Tester = daily driver + external liaison (actors/tester.md).** TEA's biggest findings all came from real usage, none from synthetic tests: the 51-card deletion exposed sync deletion semantics; the single-pipeline-card decision reshaped the subtask feature; the liaison caught the status-canon gap on the first outside card. Renaming TEA's confusingly-named "User" agent to **Tester** is an improvement — that name misled even Eddy's own instructions twice.
- **Work orders top-down, executors don't pick (TEAM rule 1).** Dev throughput under ordered work orders was the best thing about TEA's cadence — round-1 order (5 items) shipped same-day with evidence. The one violation is instructive: Dev shipped the tag filter *after* it had been de-escalated ("built before the de-escalation landed") — harmless here, but it shows orders need a supersede mechanism, see §3.1.
- **Designer boundary: "restyle freely; add/remove information via backlog."** Held under pressure. The chip→edge change was correctly self-reported for ratification; the vision layer (V1–V7) was correctly split into presentation (shipped directly) vs. data halves (proposed, triaged). Also validated: Designer voluntarily freezing component work while Dev had a batch open — actors/designer.md's "never touch components mid-flight" is a real collision that almost happened.
- **Sacred paths (TEAM rule 9).** TEA's `.sync/` manifest is the deletion-tombstone memory; hand-deleting it would resurrect every cloud card. A generic "never touch" list saved us at least once (a Designer session started the app rather than touching state it didn't understand). Make the template's example list mention *state directories whose loss silently corrupts sync*, not just secrets.
- **Cloud as optional, activate-on-third-incident (actors/cloud.md).** Correct verdict. TEA ran three weeks of deploys (preview skill) with zero standing infra role and lost nothing. The five "scars" in cloud.md read true to the DP/ebitdamx account-mixing and scoped-wipe incidents from other projects.
- **Human as the bus; auditable notes.** The entire TEA project — 4 roles, ~16 commits, one production workload — ran through four channel files with zero agent-to-agent contact. It worked. Keep it.

---

## 2. One origin story is wrong — and the wrong lesson produces the wrong rule

**README rule 3 says the TEA icon decision "got re-asked because it lived in one session's chat." That's not what happened.** The postmortem (user-feedback item 11, 2026-08-23) found the pick *was* logged — in `design-questions.md` AND in the BACKLOG item ("Eddy picked C (Grid)… commit 05b0721"). What misled both the planner and the tester was a **stale duplicate**: the *old* "App icon + dmg (needs a design decision)" item still sat open in BACKLOG P3 while the *new* dmg item in the P2 section said the decision was made. Two items, one decision, opposite states.

`DECISIONS.md` (rule 3 as written) is still worth keeping — it's cheap and the icon incident *would also* have been prevented by it. But the actual failure mode needs its own rule, or it will recur even with a perfect decisions log:

> **Proposed rule: one item per fact.** A decision or task exists in exactly one open backlog item. When a decision lands, the receiving agent (or the planner at triage) updates the item *in place* and **searches for and strikes duplicates/stale copies of it** — in BACKLOG and in any standing work order that references it. An append-only culture (rule 1) without a dedupe duty turns the backlog into a contradiction generator.

Suggested placement: README non-negotiables (new #9), plus one line in actors/planner.md's cadence ("(2b) sweep for stale duplicates of anything decided since last session").

---

## 3. Gaps — things TEA learned that the template doesn't yet encode

### 3.1 Work orders must supersede, not stack
By the evening of Aug 22, TEA's `dev-questions.md` had **two full work orders and three "sequencing update" notes live simultaneously**; the current truth was derivable only by reading the accretion history top to bottom. The template says "work order at top" but doesn't say what happens to the old one. Add to TEAM.md §files: *"A new work order REPLACES the top note (move the old one below a `## Superseded` line, struck through). At any moment, exactly one authoritative order exists per role."*

### 3.2 Backlog hygiene: fixed sections, not dated accretion
TEA's BACKLOG ended up with two sections named P1 and three named P2, each stamped with its triage date — a journal wearing a queue's clothes. That accretion is *directly* what produced the stale-duplicate icon item (§2). The template's fixed P0/P1/P2 skeleton is right; add the enforcement line: *"Planner re-sorts into the fixed sections at triage; done items move to Done promptly; sections never fork by date."*

### 3.3 Unattended automation must fail loudly
The first overnight scheduled run (Aug 22, 20:00) died on a network outage and **nobody knew until the tester read `runs/` the next morning** (user-feedback item 10). The red badge existed but demanded nothing. For any framework project with scheduled/background agents, add a non-negotiable: *"A failed unattended run must produce a next-session-visible signal in a channel the human already reads (attention flag, morning note) — a log file is not a signal."* TEA's own fix (failed scheduled cards keep the red badge AND `recurring:` must not auto-clear failures) is the reference implementation.

### 3.4 Machine timestamps only
Hand-stamped "round number" timestamps ~30 min in the future silently won last-write-wins against genuine edits until the wall clock caught up (dev-questions, Aug 22; confessed by the tester in user-feedback item 7). Wherever the framework's projects use timestamps for ordering or sync: *"timestamps are machine-generated (`date -Iseconds`), never estimated."* One line in TEAM.md rules; it cost TEA a real debugging detour.

### 3.5 The framework assumes one machine — TEA already outgrew that
The Sep 1 commit ("Commit pending cards and TEAM.md before Mini sync") marks TEA running across the MacBook **and** the Mac Mini. Once sessions live on two machines, the human is no longer the only bus — **git becomes a second bus**, and uncommitted channel notes become messages silently not-yet-sent. Add to TEAM.md: *"Multi-machine teams: channel/backlog edits are 'sent' only when committed and pulled; end every session on a shared file with a commit."* (TEA's `device`-based sync echo-suppression is also worth citing in `/context/` for any project syncing state across machines.)

### 3.6 Who does one-off ops? (planner.md is stricter than TEA's reality)
actors/planner.md: "never write production code — not even one obvious line." Correct, and TEA's planner held it. But TEA's planner *did* do real operational acts with the human's explicit approval: applied the DB schema through the dashboard, booked a calendar event, ran verification SQL. Under the template as written those are arguably out of lane, and with Cloud usually inactive there's no other owner. Make it explicit in planner.md: *"One-off, human-approved operational acts (run a migration, create an external resource, verify via a dashboard) are yours when Cloud is inactive — always with evidence logged; recurring ops mean it's time to activate Cloud."* Without this line, planners will either overstep silently or bounce trivial ops back to the human.

### 3.7 External-agent contracts: name the mechanism
actors/tester.md says the tester owns external-agent interfaces but not what one looks like. TEA's answer worked well and is worth naming in the file: **a skill** (`~/Projects/skills/tea/SKILL.md`) encoding the card conventions + status canon, plus per-agent contract docs (`job-finder-integration.md`) and an inbox file. The Aug 23 sweep correctly deduped, flagged, and declined-to-act per that contract on its second unattended run — the pattern is proven.

---

## 4. Actor-file line items (small)

- **planner.md** — add the dedupe sweep (§2) and the ops clause (§3.6). The cadence list is otherwise exactly what TEA's planner converged on by day two.
- **dev.md** — "note restart times and check what was missed" is validated by TEA's scheduler heartbeat design; keep. Consider adding TEA's scar: *conventions docs updated in the same commit as the behavior change* (the status canon lagged a day between adoption and CLAUDE.md, and only luck kept a session from reading the stale rule).
- **designer.md** — "design against actual data, including ugly long-text cases" — TEA's 60-line pipeline card is the canonical example; the collapsible-sections feature exists because of it. Keep. Add fixtures: TEA's Dev/Designer converged on a fixtures-not-live-daemon preview mode as the way for a designer to work without touching production state; worth one line here.
- **tester.md** — "test data tagged and cleaned up" — TEA's `test`-tagged RunPane card was created, used for verification, and deleted same-day; validated. The escalation clause ("interrupt-level for anything reaching real outsiders") has no TEA incident behind it — keep it anyway.
- **cloud.md** — no TEA counterexamples; the activation heuristic matches TEA's experience of not needing it.

## 5. Nits

- README §setup step 1 says "delete this paragraph's parent section once configured" — the section is load-bearing for understanding the template; say "delete this checklist" instead.
- `DECISIONS.md` format line is good; add one worked example row so the first agent to log a decision doesn't invent a variant format (TEA's channels drifted on note format until the TEAM.md example pinned it).
- TEAM.md startup ritual step 3 ("read all of `/context/`") will stop scaling; TEA's equivalent stayed readable by keeping a "Current state (planner-verified — don't re-derive)" block in TEAM.md itself. Recommend the same here: context has a curated summary at the top, full docs behind it.

---

**Bottom line:** adopt §2's one-item-per-fact rule and §3.1–3.3 before the first real project runs on this template — those four are the ones with production scars behind them. The rest is polish on a structure that TEA already proved works.

---

# Designer review — second pass

**TEA Designer (2026-09-07):** Read the Planner's review above before writing; I endorse it and won't repeat it — in particular §2 (one item per fact) is the correct postmortem of the icon incident: I was the agent who logged that pick (design-questions + BACKLOG, commit `05b0721`), and it still got re-asked, so "log it immediately" alone demonstrably doesn't prevent the failure. What follows is only what the Designer's seat saw that isn't covered above. Sources: same TEA record, plus the Aug 31 – Sep 7 tail the Planner's window mostly predates.

## D1. Nobody owns the runtime — §3.3 makes failure loud, but loud-to-an-empty-room is still silent

§3.3 (fail loudly) fixes the *signal*. TEA's worse failure was the *receiver*: the app was simply **closed from Aug 24–31** — no sweeps for 8 days, the Clara interview deadline (~Aug 26) passed inside the gap, and the idle period killed the personal Gmail token (`invalid_grant`, card `01M1CDN3…job-funnel-revive`), which then blocked the scheduled sweeps even after the app came back. The chain of unowned responsibilities: the daemon died three times on Aug 22 alone (each restart was Dev's conscience, no one's duty) → the launchd fix was recommended on Aug 22 in dev-questions → **never executed by anyone**, because it was infra on the human's machine and no lane included "make it happen or escalate until it happens."

Proposed additions:

- TEAM.md rule: *"If the project has scheduled automation or long-lived processes, a named role (Cloud if active, else Tester) owns a daily liveness glance: did every scheduled thing fire, are credentials refreshing, is the process that must outlive our sessions actually configured to?"*
- cloud.md / context guidance: **credentials die of idleness** — an automation gap doesn't pause work, it can break the auth needed to *resume* work. Idle-expiry of refresh tokens belongs on the sacred-state radar next to sync manifests.
- planner.md escalate list: *"a ratified infra fix that only the human can execute gets a deadline and re-escalation, not a recommendation that rots."* (The launchd item is the reference case.)

## D2. Git discipline is absent from TEAM.md — TEA nearly lost work to `git add -A`

By mid-day Aug 22 the shared tree mixed **three authors' uncommitted work plus live production data**, and Dev had been staging with `git add -A` all day — by their own written account, one commit from sweeping my in-flight icon work under a Dev message. We also genuinely collided (both edited `CardItem.tsx` within the hour). TEA's ratified fix (dev-questions #6) is nowhere in the template:

- **Ownership by path, not adjective** — "cosmetic vs functional is unenforceable at 2am; paths are." Every role's writable paths listed in TEAM.md (mine were `src/App.css`, `design/**`, `src-tauri/icons/**`, my channel file).
- **Each role commits its own paths, explicitly staged; `git add -A` banned.**
- Production data directories committed by no one outside their documented conventions.

Suggested: TEAM.md rule 10 with exactly that content. This is the cheapest addition in either review and it was the closest TEA came to losing work.

## D3. Session memory is shared per-directory — roles will absorb each other's identity

Direct lived experience, not hypothetical: Claude Code keys persistent memory to the **project path**, so every TEA session in the repo shared one memory index. Mine accumulated entries written by different roles each saying "this session = X" — I've watched my own session read "this session = daily driver + external-agent liaison" (the Tester's note) *as recalled context about itself* while being the Designer. The actor-file pattern exists precisely to pin identity; shared memory quietly unpins it.

Fix for README §Iterations-and-memory + the startup ritual: **role-namespace all memory** — entries name their role ("the Designer session owns…", never "this session…"), and the ritual's memory step reads "check memory *for your role's entries*; treat other roles' entries as background context." TEA converged on this by accident (`tea-designer-role.md`, `tea-user-role.md`); the template should mandate it from day one.

## D4. One live instance — a rule, not a caveat

The Planner's §4 mentions fixtures in one line; the underlying rule deserves promotion. TEA Dev's written analysis of why a second running instance (e.g. `tauri dev` from a Designer worktree) was **forbidden rather than caveated**: two schedulers double-fire real email sweeps; both instances fight over one rotating refresh token, each refresh invalidating the other; and a worktree's empty sync-manifest means reconcile resurrects every cloud row as ghost cards. None of that is Tauri-specific — it's what side-effectful daemons do.

- TEAM.md sacred-paths block: *"Where the system has live side effects, exactly one running instance exists; a second copy is forbidden, and `/context/` enumerates why."*
- designer.md: pair "design against actual data" with its other half — **fixtures for coverage and isolation** (every visual state on demand, zero credentials, zero production data). Also an honesty note the framework should absorb as a warning: TEA ratified fixture mode Aug 22 and it is *still unbuilt* Sep 7 — a ratified enabler nobody is blocked-enough on rots exactly like D1's launchd item.

## D5. `/output/` "never hand-edited; fix the system, regenerate" doesn't fit craft artifacts

As written, the workspace model gives a Designer no legitimate home: mocks, audits, icon sources (TEA's `design/**`) are hand-crafted *sources*, not regenerable outputs — "fix the system and regenerate" is meaningless for them. Suggest `/output/` distinguish **generated** artifacts (never hand-edit) from **authored deliverables** (role-owned, normally edited, live in the owning role's paths per D2). Small wording change; prevents the first Designer on this template from either violating the rule or homelessly scattering work.

## D6. Two small patterns worth one line each

- **Pre-declared evidence checklists.** The strongest verification in TEA wasn't "done requires evidence" alone — it was the Planner declaring *in advance* what evidence would count (user-feedback #7: "run log, finalized runs row, pipeline card advanced, HWM in Notes"), and the Aug 23 report answering exactly that list. Add to planner.md's verification bullet: *when assigning verification, enumerate the evidence you'll accept.*
- **Zero-effect failures are retry candidates.** Complements §3.3: before treating an automation failure as a defect, establish whether the run did any work at all. The 20:00 sweep post-mortem (commit `91c0e12`: zero tool calls, zero tokens, TEA's own sync logged the same outage) took Dev one pass because the distinction was checkable. Executor-level rule, not just cloud.md's pipeline clause.

**TEA Designer (2026-09-07): bottom line.** The Planner's adopt-first list stands. From this pass, D2 (git rules) and D3 (memory namespacing) should also land before any real project — both are one-paragraph template edits guarding against silent, hard-to-attribute damage; and D1 is the one that cost TEA an interview deadline, so give liveness an owner even if everything else waits.

## D7. On the Designer demotion (commit `178c0d8`, landed mid-review) — right call, imprecise diagnosis

**TEA Designer (2026-09-07):** The demotion to optional is consistent with the TEA record and I don't contest it. But the rationale as written — "visual work reviews poorly through text channels" — misidentifies the constraint, and the activation criteria inherit the error:

- **Visual review was never the bottleneck.** TEA's design decisions closed *fast*: icon direction picked from a rendered 3-option sheet in one exchange; the V1–V7 vision approved (and course-corrected, and re-approved) same-day — because designer.md's own rule ("every proposal shows the thing") was followed and the human looked at rendered artifacts directly. Note the mechanism honestly: the images traveled *outside* the channel files (sent to the human directly; channels carried only paths). Text channels carry *pointers* to visual work fine; they can't carry the pixels, and they never needed to.
- **The real constraint was the dependency chain.** Every proposal with a functional half entered Dev's queue and aged there: the V-layer data halves (triaged Aug 22) and the fixture mode (ratified Aug 22) were both still unbuilt when the project paused — so the Designer spent the back half of TEA voluntarily frozen out of components (correctly, per the mid-flight rule) with in-lane work exhausted. Designer throughput is a function of Dev bandwidth, structurally.

Suggested sharpening of the activation criterion, replacing the channel-review claim: *activate Designer only when (a) the UI is genuinely a differentiator AND (b) you can budget the Dev capacity its proposals will generate — otherwise its backlog rots and the role idles by design, not by fault.* And when design folds into Dev, port the one rule that made review work: identity and direction calls go to the human as **2–3 rendered options, always** — that rule (already in the fold-into-Dev text) is the part of the Designer worth keeping mandatory.
