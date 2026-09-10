# Team Framework

Run a project with a small team of AI agent sessions - PM (the driver, Fable-class), Dev seats (Opus-class), Tester, an external non-Claude Reviewer (Codex or equivalent), plus optional Designer/Cloud. The PM drives the loop; you make the decisions. All framework machinery lives in one folder: **`team/`**.

To use: copy `team/` into your project's root, then boot the PM on a Fable-class model:

> "You are the PM for {project}. Read team/TEAM.md and team/actors/pm.md - fresh project, run your First Session."

Everything else: `team/README.md` (~10-minute read: it + TEAM.md + the core actor contracts).
