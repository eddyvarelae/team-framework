# /output/ — Generated artifacts

**Access: GENERATED. Do not edit by hand.**

Everything here is produced by the system from `/context/` + `/specs/` + `/input/`. For multi-subject repos, organize one subfolder per subject — same slug as `/specs/` and `/input/`.

---

## Structure

```
output/
  {subject-slug}/
    {subject-slug}-source.html        # editable source
    Subject - Type - Date.pdf         # rendered deliverable
    ...
  _templates/                         # shared source templates reused across subjects
  _shared/                            # generated artifacts that don't belong to a subject
  ...
```

## Naming conventions

- **Source files** (HTML, markdown, scripts): `{subject-slug}-{type}.{ext}` — lowercase, hyphens.
- **Rendered deliverables** (PDFs, exports): `{Subject Name} - {Type} - {Org Name}.pdf` — title case, spaces, no special characters. Avoid accents and ñ in filenames to prevent issues in external systems.

Adapt to your context. The principle is **consistency within the repo**.

## What belongs here

- Source files (HTML, markdown, scripts) that the system generates
- Rendered deliverables (PDFs, images, exports) ready to ship
- Shared templates in `_templates/` reused across subjects
- Generic, non-subject outputs in `_shared/` (one-pagers, marketing assets, exports)

## What does NOT belong here

- Hand-edited files (if you need a one-off fix, fix the source, regenerate)
- Deliverables without their source (loses traceability)
- Subject material that came in from outside → that's `/input/`

---

## The rule

If a file here is wrong, **the problem is in `/specs/{subject}/` or `/context/`, not in the file**. Fix the source and regenerate.

Editing output directly breaks the system: the next regeneration overwrites the fix, the root cause stays unfixed, and the system never learns.

---

## Regenerating deliverables

Document the regeneration command in this README (or a `_templates/REGENERATE.md`) so any contributor can rebuild any deliverable. Example for HTML → PDF:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="output/{subject-slug}/Subject - Type - Org.pdf" \
  "file:///abs/path/to/output/{subject-slug}/{subject-slug}-source.html"
```
