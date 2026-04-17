# .law/templates/

Working examples, not kit code. Copy them into your project (typically `scripts/`) and adapt to your real semantics.

These exist because three failure modes need enforcement but can't be generified without lying:

| Template | Covers | Why project-owned |
|---|---|---|
| `check-truth-owners.example.mjs` | multi-writer detection on owned truths | needs project-specific knowledge of storage (SQL, ORM, state store, API) |
| `check-dep-direction.example.mjs` | cross-domain import enforcement | needs project-specific layer classifier and path-alias resolver |
| `check-anti-patterns.example.mjs` | file-size cap, forbidden patterns, generic-folder charter check | thresholds and patterns are doctrine choices |

Each file is a self-contained Node script with hardcoded defaults, comments pointing to what to change, and clear limitations. Exit non-zero on violation; silent on pass. Wire them into your test runner, pre-commit, or CI the same way you'd wire any other check.

The kit will not evolve these templates. They're a starting point; once copied, they're yours.
