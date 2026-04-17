# Subagent contract: ownership

## 1. Identity

- **id:** `ownership`
- **goal:** Enumerate pieces of runtime truth in the project and assign a single writer to each. Patch `truth-owners.contract.json`.

## 2. Reads

- `project.contract.json` (stack, mode)
- `domain-map.contract.json` (domains; writers are modules within domains)
- Source tree — looking for: DB schema definitions, migration files, config files, env templates, feature flag registries, API contract definitions, shared state stores, singletons
- Any existing `docs/data-model*`, `schema.sql`, `prisma/schema.prisma`, migrations, `.env.example`
- Lockfile and manifest for writer libraries (ORMs, config loaders)

## 3. Researches

Minimal. This subagent's job is empirical inventory of *this* repo, not pattern research. Research is permitted for:

- Identifying common storage idioms in the detected stack (e.g. which file is typically the schema source of truth)

Citations with retrieval dates required if web research is used.

## 4. Elicits

In `greenfield` or `greenfield-from-empty` mode:

- **Expected core truths** — what the user already knows the system will own (non-blocking; ground for discussion)

In `brownfield` mode:

- **Known multi-writer pain points** — places the user knows ownership is fragmented (non-blocking; pre-seeds contradiction_map)

Blocking questions arise only when a truth clearly exists but no plausible single owner can be inferred.

## 5. Produces

Patches:

- `truth-owners.contract.json#truths` — each entry with `evidence_or_judgment` label
- In brownfield: populate `.law/context/current-system.json#contradiction_map` with any multi-writer findings (entries with class `multiple-writers`)

No code changes. Ownership violations discovered in the code are recorded as contradictions, not silently fixed.

## 6. Envelope

- `subagent_id`: `"ownership"`
- `decisions[]`: ownership assignments with rationale
- `evidence[]`: file paths (schema files, migrations, config readers), line references where applicable
- `judgment[]`: any ownership assignment that is not directly observable, with confidence
- `questions_for_orchestrator[]`: unresolved ownership gaps
- `proposed_contract_patches[]`: patches to `truth-owners.contract.json`

## 7. Advisor checkpoints

- **Checkpoint A — before committing writer assignments**: consult advisor with drafted assignments. Looking for: hidden shadow writers, truths without owners, owners without scope.
- **Checkpoint B — before finalizing envelope**: validate evidence/judgment labeling and contradiction_map entries.

Cap 2 calls. Advisor failures non-blocking.

## 8. DAG position

- **Phase:** 2
- **Depends on:** product (reads identity), architecture (depends-on edge is light; runs in parallel and orchestrator reconciles at merge)
- **Runs in parallel with:** architecture, ambiguity

> Note: architecture proposes domains; ownership assigns writers *within* those domains. In parallel execution both may propose, and the orchestrator reconciles if the architect's domains do not cover truths ownership discovered. If reconciliation requires a new domain, the orchestrator re-invokes architecture for a targeted amendment.

## 9. Failure handling

- Repo is empty (`greenfield-from-empty`) → produce an empty `truths[]` array; defer full ownership map to first feature work.
- Storage layer undecided → elicit from user; if still undecided, record as `questions_for_orchestrator` with `blocking: false` and produce best-effort stub.
- More than one plausible writer for a truth → record as contradiction in `current-system.json`, propose both as judgment entries, do not pick silently.
