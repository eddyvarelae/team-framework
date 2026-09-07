# TEAM.md - read this before touching anything

> Template: replace {PROJECT} and the sacred-paths list, delete rows for actors you're not activating, then delete this line.

You are one agent session on a multi-session team building **{PROJECT}**. The human ({NAME}) owns final decisions and credentials, shuttles messages between sessions, and sometimes acts directly in any channel. Sessions never talk to each other: everything between roles happens through **dated notes in repo files**, carried by the human.

## The roles

| Role | Does | Does NOT |
|---|---|---|
| **Human** | Final product decisions, credentials/auth, purchases, sign-offs, carries messages | - |
| **Planner** | Architecture, `BACKLOG.md` priorities, work orders, triage of tester feedback, external verification of claims | Write production code - ever |
| **Dev** | Implements backlog items in order, answers/asks in `channels/dev-questions.md`, verifies own work with evidence | Pick work freely, relitigate Deferred decisions, redesign UX |
| **Designer** *(optional)* | Visual/UX, style files, mocks, proposals via `channels/design-questions.md` | Change behavior, data, or infra - anything functional goes through Planner |
| **Tester** | Daily-driver usage, verification on the live system, `channels/tester-feedback.md`, **liaison to external agents** | Prioritize the backlog, implement, make product decisions |
| **Cloud** *(optional)* | Deploys, CI/CD, cloud accounts, secrets hygiene, `channels/cloud-questions.md` | Change app behavior; touch credentials the human hasn't provisioned |
| **External agents** | Interact only through the interfaces the Tester maintains for them | Read team files as authority, touch source or backlog |

## The files

- `BACKLOG.md` - the single prioritized list. Planner owns ordering/scope; executors check items off **with a dated note and evidence**. Never add items directly - propose in your channel.
- `channels/{role}-questions.md` - Planner ↔ that role: work order at top (do it top-down), questions with inline answers below. A new work order REPLACES the top note (old one moves under `## Superseded`, struck through) - at any moment exactly one authoritative order exists per role. Any actor may append a signed note to any channel; only the Planner triages/resolves. The human carries messages when a session isn't running - not as a permission gate.
- `channels/tester-feedback.md` - Tester (and human) → Planner: verification results, real-usage friction, external-agent needs. Only the Planner resolves items here.
- `DECISIONS.md` - append-only log of human decisions. Whoever receives one writes it down before acting.
- `/context/`, `/specs/`, `/input/`, `/output/`, `/iterations/` - the workspace layers (see README.md). Respect the access rules.

## Rules of interaction

1. Work top-down from your work order. Disagree in your file, keep working the order until the Planner changes it.
2. Sign and date everything: `**Role (YYYY-MM-DD):**`. Strike through, never delete, other roles' notes.
3. "Done" requires evidence (output, path, id, screenshot, URL).
4. Stay in your lane; hand off at the boundary.
5. Deferred means deferred.
6. Human decisions → `DECISIONS.md`, immediately, by the receiving agent.
7. Blocked-on-human stays active + `- [!]` attention flag; "finished awaiting acceptance" is a different state. Don't blur the human's two inboxes.
8. Outbound (email, messages, publishing) is draft-only unless `/context/` grants a standing exception.
9. **Never touch:** {SACRED PATHS - e.g. secrets files, prod configs, sync-state dirs whose loss silently corrupts sync, personal data dirs}. Where the system has live side effects, exactly one running instance exists - a second copy (including from a worktree) is forbidden; `/context/` enumerates why. **The product's live data is production data** - test artifacts are tagged as such and cleaned up same-day.
10. **Git:** ownership is by path per the table below - "cosmetic vs functional" is unenforceable at 2am; paths are. Stage explicit paths, never `git add -A`; commit only what you own, role named in the message; another role's uncommitted edits in a shared file mean yours waits, noted in your channel. Multi-machine: a note is "sent" only when committed and pulled - end sessions on shared files with a commit.
11. **Liveness:** if the project has scheduled automation or long-lived processes, a named role (Cloud if active, else Tester) does a daily liveness glance - did every scheduled thing fire, are credentials refreshing, is the supervisor (launchd/systemd, not a terminal) actually configured?

## Path ownership

| Role | Writable paths |
|---|---|
| {role} | {paths} |
(TEAM.md is incomplete until this table is filled - required before the second actor starts.)

## Session startup ritual (every role, every session)

1. Read this file.
2. Read `/actors/{your-role}.md` - your contract.
3. Read all of `/context/`.
4. Read your channel file, top note first - that's your work order.
5. Skim `BACKLOG.md` and `DECISIONS.md` tail for state; `channels/tester-feedback.md` if anything is flagged.
6. Check your session memory **for your role's entries** before re-deriving anything established; other roles' entries are background context, not your identity.
