# .law/ index

> **Layer:** doctrine-adjacent · **Authority:** elaboration · **Mutability:** amendable
> Fast-orient map for any agent entering `.law/` for the first time.

## Precedence (authoritative, highest → lowest)

1. **`CONSTITUTION.md`** — highest law. Anything in `.law/` that contradicts it is defective.
2. **`.law/contracts/*.contract.json`** — compiled machine-readable law. Schema-validated. Fields here bind all code and all subordinate docs.
3. **`.law/doctrine/*.md`** and **`.law/charters/*.md`** — elaboration of the constitution and contracts. May not contradict either.
4. **`.law/context/*`** — non-authoritative snapshots, research logs, and audit trails. Regenerable. Never treated as truth.
5. **Tool-facing adapter files** patched by the kit (e.g. `CLAUDE.md`, `AGENTS.md`, `codex.md`) — non-authoritative projections only. On any conflict with the above, the projection is defective and must be corrected.

On any conflict, the higher layer wins. An agent that notices a lower layer contradicting a higher layer must halt and either amend the lower layer or flag the higher layer for amendment — never both silently.

## Folder map

```
.law/
├── KIT_INDEX.md            ← you are here
├── adapters.md             ← policy for tool-facing files (non-destructive patching)
├── bin/                    ← kit integrity scripts (verify-adapters, validate-contracts, check-coupling)
├── git-hooks/              ← sample pre-commit calling the bin scripts
├── templates/              ← project-owned check examples (truth-owners, dep-direction, anti-patterns)
├── bootstrap/
│   ├── INIT.md             ← the bootstrap protocol
│   └── questions/
│       └── cross-cutting.json   ← identity + mode questions
├── subagents/
│   ├── README.md
│   └── *.contract.md       ← role/goal/output contracts for 7 subagents
├── contracts/              ← compiled machine-readable law (7 files)
├── schemas/                ← JSON Schemas for contracts + envelope (8 files)
├── doctrine/               ← timeless prose (3 files)
├── charters/               ← per-domain timeless law
└── context/                ← regenerable snapshots + research audit trail
    ├── current-system.json
    ├── pending-questions.json
    ├── last-check.log      ← optional; persisted output of `.law/bin/*` runs
    └── research/           ← per-subagent research logs, <id>-<YYYY-MM-DD>.json
```

## How an agent enters

1. Read `CONSTITUTION.md`.
2. Read this file.
3. Read `.law/contracts/project.contract.json`.
4. Branch on `status`:
   - `skeleton` or `bootstrapping` → read `.law/bootstrap/INIT.md` and execute.
   - `active` → read whichever contracts/doctrine/charters are relevant to the current task; do not read everything.
5. Check `.law/context/pending-questions.json`; read `.law/context/last-check.log` if it exists.
6. Run `.law/bin/verify-adapters` and `.law/bin/validate-contracts`; halt on non-zero.

## What this kit does not own

- Plans, sprints, tickets, roadmaps — those are project-owned execution artifacts. The `temporary-plan` layer exists in `doc-taxonomy.contract.json` so plans are recognized and classified, but format, location, and lifecycle belong to the project.
- Code style, linter configs, CI pipelines, PR templates — these are tooling, not law.
- Generated artifacts (API docs, changelogs) — these are `generated` in the taxonomy; regeneration policy is owned by the generator.
