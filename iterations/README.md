# /iterations/ — System memory

**Access: APPEND-ONLY.**

This layer documents each **meaningful** iteration: what was requested, what was generated, what was wrong, what changed in the system, and the principle extracted.

It is not a changelog. It is the memory that prevents the system from repeating the same mistakes.

---

## When to create a new iteration

Not every output deserves an iteration log. Create one when:

- Feedback led to an update in `/context/` or `/specs/_template/`
- A principle emerged that should apply to future subjects, not just the current one
- A template, naming convention, or workflow changed
- A pricing/scope/tone rule was learned

For subject-specific feedback that doesn't generalize (a one-off scope decision for a single client), just update `/specs/{subject}/` — no iteration needed.

---

## Structure

```
iterations/
  v-template/        # Canonical skeleton — copy to start a new iteration
  v1-{short-slug}/   # First logged iteration
    manifest.md      # What was requested, context active, workflow used
    feedback.md      # What was corrected or rejected, with detail
    changes.md       # What changed in /context/, /specs/_template/, or output templates
    learning.md      # The generalizable principle extracted
    output/          # Frozen snapshot of the output that motivated the iteration
  v2-{short-slug}/
    ...
```

Naming: `v{N}-{short-slug}` — e.g., `v1-pricing-discount-pattern`, `v2-presentation-format`. The slug helps you find the right iteration later without opening every folder.

## What each file captures

| File | Content |
|---|---|
| `manifest.md` | What was requested, what context was active, what workflow was used, date |
| `feedback.md` | What was corrected or rejected, with detail — quote the human if possible |
| `changes.md` | What concretely changed (files modified, rules updated, templates affected) |
| `learning.md` | The generalizable principle — not "this was wrong" but "the rule that prevents this class of error" |
| `output/` | Frozen snapshot of the output that motivated the iteration (not a live link) |

---

## What a good learning looks like

**Bad:** "The copy was too formal."

**Good:** "Copy for non-technical audiences must avoid acronyms and product-internal terminology. If a term requires explanation, it should either be removed or replaced with the plain-language equivalent."

The learning should be:
- **Specific enough** to update a rule in `/context/`
- **General enough** to apply beyond the single case
- **Honest about edge cases** — write "when NOT to apply" if there are exceptions

---

## Memory vs iterations

If the agent session has its own memory store (e.g., `~/.claude/projects/.../memory/`), use it for cross-session, non-repo knowledge: user preferences, contact info, project status. Use `/iterations/` for changes to the system itself that anyone reading this repo should be able to find.

When in doubt: log an iteration AND save to memory. Iterations are durable in the repo; memory is faster to access during a session.
