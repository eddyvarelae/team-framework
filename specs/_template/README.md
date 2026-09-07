# Per-subject template

Copy this folder when starting a new subject (client, project, campaign, etc.):

```bash
cp -r specs/_template specs/{subject-slug}
mkdir -p input/{subject-slug} output/{subject-slug}
```

Use the same `{subject-slug}` across `/specs/`, `/input/`, and `/output/`.

Then fill in `PRD.md` (and optionally `STYLE.md`, `pricing.md`, `sections.md` — whatever this subject needs).

Do not edit this `_template/` folder directly unless you are evolving the template itself.
