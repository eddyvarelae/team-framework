# /context/ — Source of truth

**Access: READ-ONLY.**

This layer contains the structural reality of the business or project: what it is, who it serves, how it operates, what it sounds like, what is non-negotiable. The agent reads this before doing anything else.

Nothing here is a task or instruction — it describes what is true about the business, the product, the audience, and the constraints.

---

## What belongs here

Organize by topic, not by subject. The same `/context/` serves every subject in `/specs/`.

Common subfolders (use what fits, skip what doesn't):

```
context/
  company/         # whitepaper, product bible, mission, positioning
  audience/        # who this is for, what they care about (or domains/ for verticals)
  voice/           # tone, vocabulary, what to avoid
  services/        # one file per offering / capability
  pricing/         # pricing model, ranges, discount logic
  design-system/   # colors, typography, components, visual references
  constraints/     # legal, regulatory, technical non-negotiables
  examples/        # analyzed past artifacts as reference (not active templates)
```

## What does NOT belong here

- **Subject-specific facts** (one client, one campaign, one project) → those go in `/specs/{subject}/`
- **Source documents from clients** → `/input/{subject}/`
- **Generated artifacts** → `/output/{subject}/`
- **Tasks, priorities, to-dos** → not in this repo; use your task tracker

---

## The rule

`/context/` changes only when **the fundamental reality of the business changes** — a new service, a new pricing model, a brand evolution, a redefined audience. It is **not** updated based on feedback about a single output.

When a learning emerges from working on a subject:
- If it's specific to that subject → update `/specs/{subject}/`
- If it's generalizable → update the relevant `/context/` file AND log an iteration

That iteration loop is what makes `/context/` get smarter over time without becoming a pile of one-off notes.
