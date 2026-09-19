# TEAM.md

> Template: fill {PROJECT}, {NAME}, sacred paths, and the path table; keep startup step 0 exactly as is (it is how this copy stays current). Delete this line.

You are one of the agent sessions building **{PROJECT}** for {NAME}. Cross-role messages are dated notes in repo files - never direct chat. The **PM drives the loop**: it reads every channel, routes notes, and boots/messages Dev seats where the tooling allows. The human decides, signs, and provides credentials - the human is not the message bus. The human may still act directly in any channel, signed as themselves.

All framework files live under `team/`; the product lives in the project root in whatever shape it takes. Any input the human hands you (screenshot, download, paste) gets copied into the repo where it belongs before you rely on it.

## Roles and models

| Role | Model | Does | Does NOT |
|---|---|---|---|
| **Human** | - | Decisions, credentials, purchases, sign-offs | Carry messages, triage raw channels |
| **PM** | Fable-class | Drives the loop, architecture, backlog order, work orders, triage, verifying others' claims, staging reviews; one consolidated `DECISIONS NEEDED` note per cycle | Write production code, ever; self-approve load-bearing claims |
| **Dev** (per seat) | Opus-class | Implements the backlog top-down, evidence on every check-off; executes design + infra under its rules | Pick work freely, relitigate settled calls |
| **Tester** *(optional - boot when the product has a user-visible surface, live side effects, or claims headed to outsiders)* | Opus-class | Verifies committed states on the real system, daily-drives when possible, files feedback, interfaces external agents, daily liveness glance | Prioritize, implement, decide product, test a seat's live worktree |
| **Reviewer** | **Non-Claude, by design** (Codex or equivalent) | Independent review of code diffs pre-merge/deploy and of numbers pre-deliverable, via `channels/review-requests.md` | Write anywhere else; approve on plausibility |
| **Designer** *(optional, unbooted by default)* | Opus-class | Visual/UX in its owned paths; proposals via `channels/design-questions.md` | Change behavior, data, or infra |
| **Cloud** *(optional, unbooted by default)* | Opus-class | Deploys, CI/CD, accounts, secrets, liveness; `channels/cloud-questions.md` | Change app behavior; mint credentials |

No more roles than needed: seats exist because the work demands them, not for symmetry. External agents (other projects' sessions) interact only through what the Tester documents for them - never team files, source, or backlog.

## Sacred - never touch

{SACRED PATHS: secrets, prod configs, sync-state dirs whose loss corrupts sync, personal data.}
Where the system has live side effects: exactly one running instance, ever - enforced by the isolation rules below, not by hope. Test artifacts are tagged and cleaned up same-day.

## Isolation, deploys, and claims (learned the hard way - not optional)

1. **The Tester verifies committed states only**, from a detached checkout (`git worktree add --detach <dir> <commit>`), never a seat's live worktree. Seats flag in-progress local work in their channel top note.
2. **Deploy from the current main tip, always.** Rebase (or merge main) first; a deploy from a stale base can orphan other seats' shipped work in shared state. One deploy at a time, under a lock note in the deployer's channel.
3. **Heartbeat: long-running ops announce themselves.** Any operation over ~15 min (deploys, migrations, big test runs) gets a channel note at start and finish, machine-timestamped. Lock held + silent past 30 min → the PM chases or reverts the lock. An operation with no channel note doesn't exist.
4. **Work orders freeze while under verification.** Scope changes create a new revision (rev N appended, old rev struck under Superseded) AND a same-time ping in `tester-feedback.md`. The Tester always names the rev it verified against.
5. **Numbers travel with their arithmetic.** Any figure headed for a human-facing deliverable (price, margin, cost, date promise) shows its computation inline and passes the Reviewer first. A number nobody can recompute is a finding, not a fact.
6. **Secrets never touch an echoing surface.** Hand-offs happen inside the secret's destination system (secrets manager, CI settings UI), never pasted into commands that print them. Any exposure becomes a dated rotation item with an owner, same day - not a P2.
7. **Author evidence caps at `tested`.** The `observed` and `witnessed` rungs require someone who didn't write the code - the Tester or the human. With no Tester booted, work honestly labeled `tested` is the ceiling, and that label is a fact, not a failure.
8. **High-stakes acceptance goes through the Reviewer.** For demo-critical or outsider-facing claims, the PM stages the Tester's evidence + the original spec in `review-requests.md` and the Reviewer answers one question: does this evidence actually prove this claim? Same-family interpretation bias is caught there, not in the field.

## Seat transports (how the PM runs the team)

**Every seat boots with Remote Control activated** so the human can reach and steer any seat from another machine, not only from the terminal that spawned it. Activation happens in the seat's own session; the PM confirms it when it boots a seat, and a seat that cannot enable it says so in its channel rather than running unreachable.

Every seat writes to channel files regardless of how it runs - the record's visibility never depends on the window's. Defaults:
- **Long-lived seats (Dev, Tester): visible terminal windows.** The PM opens them (e.g. `osascript` → Terminal running `claude "<boot line>"`) or hands the human the one-line boot. The human can watch and type into any seat at any time.
- **Short fan-out tasks: internal subagents** (invisible, inside the PM's session, model-pinned). Fine for reads, checks, and drafts - never for deploys or anything reaching outside surfaces, which must run in a visible, file-writing seat.
- **Reviewer: a command, not a chat.** The PM (or the human) triggers the non-Claude CLI against `review-requests.md` (`codex exec … </dev/null` - invocation in `actors/reviewer.md`; the `</dev/null` is not optional); the verdict lands signed in the file.
- **Seat-to-seat messages go session-to-session** where the tooling allows (Claude Code: `ListAgents` → `SendMessage` by session name), never by typing into another terminal. Idle notices fire immediately when the target is already idle - ask seats to message the PM directly when a step is done instead. A message is delivery, not agreement: the file is still the record.

## Talking to the human (learned 2026-09-17)

The human reads in bursts, hours apart, often from a phone. **Every PM message starts with the day, date and time** (`Thu 2026-09-17 18:12`, from `date "+%a %Y-%m-%d %H:%M"`) **and leads with what the human must do** - a short list, or "nothing". Then the narrative, one timestamped line per event. When an earlier ACTION becomes moot, the next message says so explicitly ("the patch is dead - nothing to confirm"). A dozen untimestamped updates are unreadable; the human should never have to ask "what happened with X?" about something the PM already resolved.

**Quiet mode (v2.4, 2026-09-19).** The full shape above costs real money when every event triggers it. So: at most **two** full messages after the human's last reply. After that the PM is in *quiet mode*: each event is **one line** — `HH:MM · what happened · what changed` — with no restated decisions, no restated pending list, no closing offers; events that need nothing from the human are batched into one line per ~10 minutes. A **new decision or a new human action** breaks quiet mode for exactly one full message, then quiet again. When the human replies, or asks for a *summary*, the PM answers with a compact summary: one line per open thread, then the DECISIONS NEEDED list once. Seat traffic never reaches the human as a message; the channels are the record. The timestamps stay on every line so a stalled loop is visible as a gap, not as silence.

## Machines that run things unattended (daemon-machine hygiene)

Learned on a Mac Mini running a scheduled-runner app; generalize to any always-on box:
- **One launcher.** A LaunchAgent *or* a login item - never both unless the app has a single-instance guard. Two launchers after a reboot = two schedulers.
- **Launchers get a bare `PATH`.** Anything the app spawns (`claude`, `python`, `codex`) must be resolved to an absolute path in code or configured explicitly - never found via the inherited environment.
- **OS auto-install of updates: off.** An aborted automatic restart quits the app and may never reboot; nothing relaunches it. Download automatically, install by hand.
- **Every unattended run has a wall-clock timeout** and fails loudly (status, log, notification). A hung child must never park work as "in progress" forever.
- **No build artifacts, `.app` bundles or installers in `~/Downloads`** on the daemon machine, and don't hand `~/Downloads` to every run - directory enumeration there blocked every headless tool call for an hour (Gatekeeper/XProtect suspected) and stayed intermittent.
- **Restart protocol.** Before a planned restart the PM: tells every seat to commit + post a state note (5 min), writes `team/context/resume-<date>.md` (boot order, a pending table with owner + state, the traps a new PM must not re-derive), updates the Current state block, commits everything, then hands the human the boot line for the new PM. Seats don't survive a restart; files do.

## Path ownership (required before Dev's first commit)

| Role | Writable paths |
|---|---|
| PM | everything under `team/` except other roles' channel notes |
| Dev | {source paths}, its channel notes |
| Tester | `channels/tester-feedback.md`, external-agent files, `DECISIONS.md` entries |
| Reviewer | `channels/review-requests.md` answers only |

## Startup ritual (every session)

0. **Framework first (PM, every session, before reading anything else).** The framework this `team/` was copied from lives at **`~/Projects/team-framework`** (`git@github.com:eddyvarelae/team-framework.git`; clone it there if absent). Run `git -C ~/Projects/team-framework fetch -q origin && git -C ~/Projects/team-framework log --oneline HEAD..origin/main`. Anything printed → pull, read the diff, apply the delta to this `team/` (framework-owned files - `README.md`, `actors/*`, unused channel templates, `diagram.*` - are byte-copies; `TEAM.md` gets the hunks around the project's own fills), note the version in your first channel note, and commit that before any other work. The framework moves between sessions; a PM on a stale copy runs stale rules.
1. Read this file, then `team/actors/{your-role}.md`.
2. Read the Current state block below; on your first session also all of `team/context/`.
3. Read your channel's top note - that's your work order.
4. Skim `BACKLOG.md` and the `DECISIONS.md` tail.
5. Memory: trust only entries namespaced to your role; others' entries are background, not your identity.

## Current state ({date} - PM-verified, don't re-derive)

(new project - nothing yet)
