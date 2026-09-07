# Team Framework

Run a project with **three AI agent sessions** - Planner, Dev, Tester - coordinated by **you, the human**. Agents never talk to each other: every cross-role message is a dated note in a repo file, and you carry it between sessions. Slower than direct contact, and worth it: every decision stays reconstructable from the files.

This file addresses you, the human operator. Agents enter through `TEAM.md` - its startup ritual sends each one to its own contract in `actors/`.

## Where things live

The **product** lives in the project root, in whatever shape it takes - this framework imposes nothing there. Everything the framework owns is inside `team/`:

- `team/context/` - ground truth: what this is, constraints, sacred paths. Read-only for everyone but the Planner, who keeps it current as the system learns.
- The coordination files below.

## The coordination files (all under `team/`)

- `BACKLOG.md` - one prioritized list. Planner owns order; others propose in their channel, never add directly. Done items carry evidence.
- `channels/dev-questions.md` - Planner ↔ Dev. Work order on top (newest **replaces** the old - exactly one authoritative order at any time), Q&A below.
- `channels/tester-feedback.md` - Tester → Planner. Numbered items; only the Planner resolves them.
- `DECISIONS.md` - whenever the human decides something, the agent who heard it logs it here **before acting**. No agent assumes the others know.

## Inputs: preserve at point of receipt

The human's inputs arrive however they arrive - screenshots (often in a cloud folder), files in Downloads, exports, text pasted straight into a chat. There is no input folder to curate. The rule instead: **the moment an agent uses an input, it copies it into the repo** at the appropriate place in the project tree (e.g. `assets/raw/`, `docs/sources/` - the project decides), and references that path in its note. Downloads rot, screenshots scroll away, pastes die with the chat - the repo copy is the record.

## The rules

1. **Sign and date every note** (`**Role (YYYY-MM-DD):**`); machine timestamps only (`date -Iseconds`). Never rewrite another role's note - strike through and append.
2. **Done requires evidence**, stated at its level: `compiled → tested → observed → witnessed`. Unverified work says so plainly.
3. **One item per fact.** Decisions and tasks live in exactly one open item; when something lands, the Planner strikes stale duplicates. Duplicates are invisible to executors - the sweep is the Planner's job.
4. **Stay in your lane**; findings outside it go to the right file, not fixed on the spot.
5. **Blocked-on-human ≠ finished.** Waiting on the human = active + `ACTION (human):` flag. "Needs review" = finished, awaiting acceptance. Two different inboxes.
6. **Outbound is draft-only** - email, messages, publishing: agents stage, the human sends.
7. **Git by path ownership** (table in TEAM.md). Stage explicit paths, never `git add -A`; commit only what you own, role in the message. Live data is production data.
8. **Automation fails loudly and has an owner.** Unattended processes get a supervisor (launchd, not a terminal), a daily liveness glance (Tester), and failures must surface where the human already looks. Idle gaps can expire credentials - watch them.

## Start a project

1. Copy `team/` into your project root. Boot the Planner: *"You are the Planner for {project}. Read team/TEAM.md and team/actors/planner.md - fresh project, run your First Session."*
2. The Planner sets everything up and tells you when to boot the Dev; boot the Tester once there's something real to verify.
3. Boot line for any actor: *"You are the {actor} for {project}. Read team/TEAM.md, team/actors/{actor}.md, then your channel."*

## Optional actors

**Designer** and **Cloud** have contracts in `actors/` but start unbooted: Dev's own Design and Infra blocks cover their ground until a project earns them. Each optional file opens with its activation criteria (Designer: UI is a differentiator AND its proposals' Dev capacity is budgeted; Cloud: recurring infra work, multi-tenant credential risk, or ~the third infra incident in a month). Read their files only when activating them - they're not part of the 10-minute path.
