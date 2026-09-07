# /input/ — External source material

**Access: READ-ONLY.**

This layer holds documents, data, and references the system needs to consume but does not produce: client briefs, source PDFs, raw datasets, third-party references, existing assets being built upon.

For multi-subject repos, organize one subfolder per subject — same slug as `/specs/` and `/output/`.

---

## Structure

```
input/
  {subject-slug}/
    brief.pdf
    photos/
    chat-export.txt
    existing-contract.pdf
    references/
    ...
  ...
```

## What belongs here

- PDFs, photos, audio, chat transcripts the subject sent
- Visual references the subject shared (sites they like, brand examples)
- Raw data to be processed
- Existing assets being built upon (prior versions, competitor outputs)
- Anything the agent needs to read but did not produce

## What does NOT belong here

- **Analysis or summaries derived from these inputs** → `/specs/{subject}/` or `/output/{subject}/`
- **Your own organization's truth** (whitepaper, brand assets) → `/context/`
- **Generated artifacts** → `/output/{subject}/`

---

## Operational notes

- If the file is not subject-specific (a generic reference, a shared asset), it belongs in `/context/examples/` or `/context/design-system/reference/` instead.
- If content is very large (raw video, big datasets), keep the original outside the repo and put a `pointer.md` here with the location and a short description.
- Name files clearly. If there are many, add an `index.md` listing what each one is and why it's relevant.

---

## The rule

`/input/` is what came in from outside. The moment you analyze it, summarize it, or transform it, the result moves out — to `/specs/` if it informs decisions, to `/output/` if it's a deliverable.
