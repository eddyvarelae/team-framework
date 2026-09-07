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
| `/output/` | GENERATED | Everything produced. Never hand-edited; fix the system, regenerate. |
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

Core four (always):

- **Planner** - architecture, priorities, triage, verification of others' claims. Writes no production code, ever.
- **Dev** - implements the backlog in order. Doesn't pick work, doesn't redesign UX, doesn't relitigate decisions.
- **Designer** - visual/UX ownership. Proposes behavior changes; never implements them.
- **Tester** - uses the product as the daily driver, verifies claims on the live system, files feedback, and is the **liaison to agents outside the team**.

Optional (add when the project earns them):

- **Cloud** - infra, deploys, CI/CD, credentials hygiene. See `/actors/cloud.md` for when to activate this role vs. leaving infra inside Dev.

And always:

- **The human** - final product decisions, credentials/auth, purchases, sign-offs, and message carrier. Can act directly in any channel (signed as themselves).

Each actor has an instruction file in `/actors/` - that file IS the actor's system contract. Start a new session, point it at its actor file, and it knows its lane.

---

## Setting up a new project from this template

1. Copy this repo; delete this paragraph's parent section once configured.
2. Fill `/context/` first - highest leverage, slowest to change. Include the project's sacred paths (things no agent may touch).
3. Edit `TEAM.md`: name the project, pick the active actors, list the sacred paths.
4. Open one session per actor. First message: "You are the {actor} for {project}. Read TEAM.md, then /actors/{actor}.md, then follow its startup ritual."
5. Seed `BACKLOG.md` with the planner session; everything flows from there.

---

## Non-negotiable rules (learned the hard way)

1. **Sign and date everything.** Every note is `**Role (YYYY-MM-DD):**`. Never delete or rewrite another role's note - strike through and append.
2. **"Done" requires evidence.** Command output, file path, row id, screenshot, URL. Unverified work says so explicitly - that's respectable; silent assumption isn't.
3. **Log verbal decisions immediately.** Anything the human tells one agent gets written to `DECISIONS.md` by the receiving agent before acting on it. No agent may assume the others heard it. (Origin: the TEA icon decision got re-asked because it lived in one session's chat.)
4. **Stay in your lane; hand off at the boundary.** Finding a bug outside your role means filing it in the right channel, not fixing it.
5. **Fix the system, not the output.** Wrong artifact → wrong `/context/` or `/specs/` → fix there, regenerate, log the iteration if it generalizes.
6. **Deferred means deferred.** `BACKLOG.md`'s Deferred section records decisions already made. Don't rebuild the argument; flag changed reality to the planner.
7. **Blocked-on-human ≠ finished.** A task waiting on the human stays active with an attention flag (`- [!]` / `ACTION (human):`); "needs review" is reserved for finished work awaiting acceptance. The human's two inboxes must never blur.
8. **Outbound is draft-only.** No agent sends email, messages, or publishes externally on the human's behalf - drafts and staged changes, with the final send/click belonging to the human, unless a standing exception is written in `/context/`.

---

## Iterations and memory

Each agent session may keep private memory (preferences, state snapshots). Anything a future contributor should find by reading the repo goes in `/iterations/` AND updates the relevant `/context/` rule. When in doubt, put it in the repo.
