# Multi-Agent Framework

A template for running a project with a **team of AI agent sessions** that collaborate through files, coordinated by one human. It merges two proven systems:

- **Context-driven workspace** (from `context-framework`, full version): context replaces prompting; the repo's structure is the interface.
- **TEA team protocol** (from `the-everything-app`, Aug 2026): multiple specialized Claude sessions working one codebase without talking to each other directly - roles, channel files, dated notes, work orders, and evidence.

> The problem is never the model. The problem is the absence of structured context - and, with multiple agents, the absence of structured coordination.

---

## The two halves

**1. The workspace (what any single agent reads and writes):**

| Layer | Access | Purpose |
|---|---|---|
| `/context/` | READ-ONLY | Ground truth: what this project is, constraints, non-negotiables. |
| `/specs/` | EDITABLE | How decisions are made, per subject of work. |
| `/input/` | READ-ONLY | External source material consumed, never produced. |
| `/output/` | GENERATED | Machine-generated artifacts are never hand-edited (fix the system, regenerate); role-authored craft deliverables (mocks, icon sources) are owned and edited via their role's paths. |
| `/iterations/` | APPEND-ONLY | Memory of system changes: what was learned, what changed because of it. |

**2. The team (how agents coordinate):**

| Piece | File(s) | Purpose |
|---|---|---|
| Roles | `TEAM.md`, `/actors/*.md` | Who does what, and explicitly what they do NOT do. |
| Work queue | `BACKLOG.md` | One prioritized list. Planner owns order; executors check items off with evidence. |
| Channels | `/channels/*.md` | Role-pair communication: work order at top, Q&A inline below, dated signed notes. |
| Decisions | `DECISIONS.md` | Every human decision logged the moment an agent receives it. |

The human is the bus: agents never talk to each other directly. Every cross-role message is a dated note in a channel file, carried between sessions by the human. This is a feature, not a limitation - it makes every decision auditable and every agent replaceable mid-project.

---

## The actors

Core three (always):

- **Planner** - architecture, priorities, triage, verification of others' claims. Writes no production code, ever.
- **Dev** - implements the backlog in order. Doesn't pick work, doesn't redesign UX, doesn't relitigate decisions. Owns design execution when no Designer is active.
- **Tester** - uses the product as the daily driver, verifies claims on the live system, files feedback, and is the **liaison to agents outside the team**.

Optional (add when the project earns them - see each actor file's activation criteria):

- **Designer** - visual/UX ownership. Activate only when (a) the UI is genuinely a differentiator AND (b) you can budget the Dev capacity its proposals will generate - Designer throughput is structurally a function of Dev bandwidth, and an unbudgeted Designer idles by design, not by fault. When design folds into Dev, one Designer rule stays mandatory: identity and direction calls go to the human as 2-3 **rendered** options, always - pixels travel to the human directly; channels carry the pointers.
- **Cloud** - infra, deploys, CI/CD, credentials hygiene. Activate on recurring infra work or multi-tenant credential risk; otherwise infra stays inside Dev with Cloud's hard rules copied into `/context/`.

And always:

- **The human** - final product decisions, credentials/auth, purchases, sign-offs, and message carrier. Can act directly in any channel (signed as themselves).

## The human's own agent (chief of staff) - deliberately NOT an actor

The human may run a standing personal agent that captures intent, holds cross-project context, drives the human's own tooling (email drafts, calendars, purchases, research), spawns ephemeral worker agents for its own tasks, and carries messages between project teams. This seat exists **per human, not per project**, and it is intentionally outside every team:

- To a project team it appears only as (a) the **human's proxy** - notes signed `**Human (via {agent}) (YYYY-MM-DD):**`, carrying decisions that still get logged to `DECISIONS.md` - or (b) an **external agent** through the Tester's documented interface.
- It never holds a team lane, never triages a backlog, never coordinates team agents directly - that would bypass the auditable bus that makes every decision reconstructable.
- Its ephemeral sub-agents are its own delegates and report only to it; they are not team actors.

Coordination therefore lives in three distinct places: **within a project** - the Planner; **between sessions** - the human (assisted by this agent as carrier); **across the human's whole portfolio** - this agent. Collapsing these into one "main agent" role inside a team is the design error this section exists to prevent. (Origin: TEA's "User" agent was simultaneously in-team tester and the human's chief of staff - it worked only because TEA's product WAS the coordination tool.)

Each actor has an instruction file in `/actors/` - that file IS the actor's system contract. Start a new session, point it at its actor file, and it knows its lane.

---

## Setting up a new project from this template

1. Copy this repo; delete this checklist once configured.
2. Fill `/context/` first - highest leverage, slowest to change. Include the project's sacred paths (things no agent may touch).
3. Edit `TEAM.md`: name the project, pick the active actors, list the sacred paths.
4. Open one session per actor. First message: "You are the {actor} for {project}. Read TEAM.md, then /actors/{actor}.md, then follow its startup ritual."
5. Seed `BACKLOG.md` with the planner session; everything flows from there.
6. Before the second actor starts: declare path ownership in TEAM.md and agree the commit protocol (non-negotiable 11).

---

## Non-negotiable rules (learned the hard way)

1. **Sign and date everything - with machine timestamps.** Every note is `**Role (YYYY-MM-DD):**`; any timestamp used for ordering or sync is machine-generated (`date -Iseconds`), never estimated - hand-stamped times silently win last-write-wins races. Never delete or rewrite another role's note - strike through and append.
2. **"Done" requires evidence.** Command output, file path, row id, screenshot, URL. Unverified work says so explicitly - that's respectable; silent assumption isn't.
3. **Log verbal decisions immediately.** Anything the human tells one agent gets written to `DECISIONS.md` by the receiving agent before acting on it. No agent may assume the others heard it.
4. **Stay in your lane; hand off at the boundary.** Finding a bug outside your role means filing it in the right channel, not fixing it.
5. **Fix the system, not the output.** Wrong artifact → wrong `/context/` or `/specs/` → fix there, regenerate, log the iteration if it generalizes.
6. **Deferred means deferred.** `BACKLOG.md`'s Deferred section records decisions already made. Don't rebuild the argument; flag changed reality to the planner.
7. **Blocked-on-human ≠ finished.** A task waiting on the human stays active with an attention flag (`- [!]` / `ACTION (human):`); "needs review" is reserved for finished work awaiting acceptance. The human's two inboxes must never blur.
8. **Outbound is draft-only.** No agent sends email, messages, or publishes externally on the human's behalf - drafts and staged changes, with the final send/click belonging to the human, unless a standing exception is written in `/context/`.
9. **One item per fact.** A decision or task exists in exactly one open backlog item. When a decision lands, the receiver updates the item in place and searches for and strikes stale duplicates - in BACKLOG and in standing work orders. Append-only culture without a dedupe duty turns the backlog into a contradiction generator. (Origin: TEA's icon decision WAS logged, twice - what misled two agents was a stale duplicate item still claiming it was open. Duplicates are invisible to executors by construction; the dedupe duty is the Planner's.)
10. **Unattended automation fails loudly AND stays alive.** A failed unattended run must produce a next-session-visible signal in a channel the human already reads - a log file is not a signal. Every long-lived process has a named owner (Cloud if active, else Tester) doing a daily liveness glance, and a written supervision contract in `/context/` (launchd/systemd - an agent's terminal is not a supervisor). Know that **credentials die of idleness**: an automation gap can expire the auth needed to resume. And a ratified infra fix only the human can execute gets a deadline and re-escalation, not a recommendation that rots. (Origin: TEA's daemon was down 8 days; a deadline passed inside the gap and the idle period killed the refresh token.)
11. **One repo, many hands: ownership is by path.** TEAM.md is incomplete until it contains a path-ownership table. Stage explicit paths - never `git add -A`/`commit -a`; each actor commits only files it owns, role named in the commit; if a shared file holds another role's uncommitted edits, leave yours unstaged and say so in your channel. Parallel implementers get git worktrees - safe for editing, **never for running**: where the system has live side effects, exactly one running instance exists. On multi-machine teams, git is a second bus: channel edits are "sent" only when committed and pulled - end every session on a shared file with a commit.
12. **Evidence has levels, and every project needs a safe preview.** Check-offs state their rung: `compiled` → `tested` → `observed` (ran on the real system, output attached) → `witnessed` (human/Tester saw it). Different rungs earn different trust. And every project defines a safe preview - fixtures any actor can exercise without production state or side effects - or "done" can't mean "verified" for actors who can't reach the live system, and items must say so.

---

## Iterations and memory

Each agent session may keep private memory (preferences, state snapshots). **Role-namespace all of it**: session memory is usually keyed to the project directory, so every actor in the repo shares one store - entries must name their role ("the Designer session owns..."), never "this session...", or roles silently absorb each other's identity. Treat other roles' entries as background context, not your own.

Anything a future contributor should find by reading the repo goes in `/iterations/` AND updates the relevant `/context/` rule. When in doubt, put it in the repo.
