# Team Framework

*v2.8 (2026-09-26): canary words - the PM starts every message with the word from its boot line, seats start every note with theirs; a missing word means a lost contract. `scripts/health.sh` fails loudly on stale framework copies, stale locks, silent orders, unanswered reviews and missing words.*
*v2.7 (2026-09-26): the PM merges main and deploys by default, on standing grants given at the First Session; a new event source is confirmed Enabled before smoking.*
*v2.6 (2026-09-26): seats boot non-prompting (`--permission-mode auto`) in their own worktree; denied actions go to the human, never to another seat; secrets written by the human with the newline stripped.*
*v2.5 (2026-09-25): economy - PM messages only for actions, decisions and milestones; one verifier per claim; Reviewer by materiality; three-line channel notes; no acks; `scripts/reviewer.sh`.*
*v2.4 (2026-09-19): quiet mode - after two unanswered PM messages, one-line timestamped events until the human replies; full summary on request.*
*v2.3 (2026-09-17): the PM checks this repo for updates at every boot and applies the delta before working.*
*v2.2 (2026-09-17): human-facing message rules, daemon-machine hygiene, restart protocol, Reviewer invocation, session-to-session seat messaging - all from the first two days of running a real project on v2.*

Run a project with a small team of AI agent sessions - PM (the driver, Fable-class), Dev seats (Opus-class), Tester, an external non-Claude Reviewer (Codex or equivalent), plus optional Designer/Cloud. The PM drives the loop; you make the decisions. All framework machinery lives in one folder: **`team/`**.

To use: copy `team/` into your project's root, then boot the PM on a Fable-class model:

> "You are the PM for {project}. Canary: {WORD}. Read team/TEAM.md and team/actors/pm.md - fresh project, run your First Session."

`{WORD}` is a canary word you pick and write nowhere: every PM message starts with it, and one that does not has lost its contract.

Everything else: `team/README.md` (~10-minute read: it + TEAM.md + the core actor contracts).
