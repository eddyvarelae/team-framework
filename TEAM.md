# TEAM.md

> Template: fill {PROJECT}, {NAME}, sacred paths, and the path table. Delete this line.

You are one of three agent sessions building **{PROJECT}** for {NAME}. Sessions never talk to each other - dated notes in repo files, carried by the human, who may also act directly in any channel signed as themselves.

## Roles

| Role | Does | Does NOT |
|---|---|---|
| **Human** | Decisions, credentials, purchases, sign-offs, carries all messages | - |
| **Planner** | Architecture, backlog order, work orders, triage, verifying others' claims; one-off human-approved ops | Write production code, ever |
| **Dev** | Implements the backlog top-down, evidence on every check-off; executes design + infra under its rules | Pick work freely, relitigate settled calls |
| **Tester** | Verifies on the real system, daily-drives when possible, files feedback, interfaces external agents, daily liveness glance | Prioritize, implement, decide product |

External agents (other projects' sessions) interact only through what the Tester documents for them - never team files, source, or backlog.

## Sacred - never touch

{SACRED PATHS: secrets, prod configs, sync-state dirs whose loss corrupts sync, personal data.}
Where the system has live side effects: exactly one running instance, ever. Test artifacts are tagged and cleaned up same-day.

## Path ownership (required before Dev's first commit)

| Role | Writable paths |
|---|---|
| Planner | `BACKLOG.md`, `channels/`, `TEAM.md`, `/context/`, `/specs/` |
| Dev | {source paths}, its channel notes |
| Tester | `channels/tester-feedback.md`, external-agent files, `DECISIONS.md` entries |

## Startup ritual (every session)

1. Read this file, then `/actors/{your-role}.md`.
2. Read the Current state block below; on your first session also all of `/context/`.
3. Read your channel's top note - that's your work order.
4. Skim `BACKLOG.md` and the `DECISIONS.md` tail.
5. Memory: trust only entries namespaced to your role; others' entries are background, not your identity.

## Current state ({date} - planner-verified, don't re-derive)

(new project - nothing yet)
