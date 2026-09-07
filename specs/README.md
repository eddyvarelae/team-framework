# /specs/ — Per-subject working documents

**Access: EDITABLE.**

This is where the system makes per-subject decisions. A "subject" is whatever unit of work this repo handles — a client, a project, a campaign, a feature, an experiment.

For single-subject repos, files live directly here. For multi-subject repos (the common case), each subject gets its own subfolder.

---

## Structure

```
specs/
  _template/         # Skeleton to copy when starting a new subject
  {subject-slug}/    # One folder per active subject
    PRD.md           # What is being built, scope, audience, decisions
    STYLE.md         # Per-subject tone/format adjustments (optional)
    sections.md      # Per-subject structural decisions (optional)
    ...              # Whatever other files this subject needs
  ...
```

Use the same `{subject-slug}` across `/specs/`, `/input/`, and `/output/`. Consistency makes the system navigable.

## What belongs here

- Subject-specific scope and decisions
- Per-subject contacts, deadlines, internal notes
- Argumentation behind a decision ("why this scope, not that")
- The `_template/` skeleton for new subjects

## What does NOT belong here

- **General rules that apply to all subjects** → those go in `/context/`
- **Source documents from the subject** → `/input/{subject}/`
- **Generated artifacts** → `/output/{subject}/`
- **Design system, brand voice, pricing model** → all in `/context/`

---

## How to start a new subject

```bash
cp -r specs/_template specs/{subject-slug}
mkdir -p input/{subject-slug} output/{subject-slug}
```

Then fill the skeleton in `specs/{subject-slug}/` with the specifics.

---

## The rule

If a decision is specific to this subject, it lives here. If the decision applies across subjects, **move it to `/context/`** — don't leave generalizable knowledge buried in one subject's spec.

When you learn something generalizable while working on a subject, do both:
1. Apply the learning to that subject's spec immediately
2. Move the generalization to `/context/` (and log an iteration if material)
