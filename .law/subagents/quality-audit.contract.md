# Subagent contract: quality-audit

## 1. Identity

- **id:** `quality-audit`
- **goal:** Surface quality issues in dependencies, libraries, tooling, and observable anti-patterns, grounded in live research. **Advisory only** — findings inform, they never halt constitution adoption.

## 2. Reads

- `project.contract.json` (stack)
- `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` / `pom.xml` / `build.gradle` — declared deps and versions
- Lockfile — resolved versions
- Any security advisory config (`.npmrc`, `audit.json`, `dependabot.yml`)
- Source tree — light scan for anti-pattern signals (e.g. direct DB access from presentation layer, monster files, generic containers)

## 3. Researches (hard rule: live web, retrieval dates required)

For each significant direct dependency:

- Current maintenance status (last release date, maintainer activity)
- Known CVEs (check a vulnerability source — GHSA, npm audit, Snyk, OSV)
- Deprecation status (is this lib declared deprecated by its author?)
- Major version gap — is the project on N when the ecosystem is on N+2?
- Modern alternative — is there a community-recommended successor?

For the stack as a whole:

- Known anti-patterns community has moved away from (corroborated with at least two sources)

Every finding MUST cite URLs with retrieval dates. Training-only claims on dep status are rejected.

## 4. Elicits

None by default. This subagent is diagnostic; it reports, it does not elicit.

One optional acknowledgement step: if any `critical` findings exist, the user is asked to acknowledge them before the orchestrator marks bootstrap complete. Acknowledgement does not require action; it only records awareness. **Bootstrap completes regardless.**

## 5. Produces

Patches:

- `quality-audit.contract.json#findings` — every finding, with category, severity (`info` | `warn` | `critical`), summary, evidence (including retrieved URLs), suggested action
- On user acknowledgement of critical findings: stamps `acknowledged`, `acknowledged_at`, `acknowledged_by` on those entries

No halts. No side effects on other contracts.

## 6. Envelope

- `subagent_id`: `"quality-audit"`
- `decisions[]`: (minimal; most content is in findings)
- `evidence[]`: lockfile entries, manifest entries, web sources with retrieved_at
- `judgment[]`: any severity assignment that depends on context (e.g. "warn" because the lib is used on a critical path)
- `questions_for_orchestrator[]`: none by default; acknowledgement of critical findings is tracked via the contract, not as a blocking question
- `proposed_contract_patches[]`: patches to `quality-audit.contract.json`

## 7. Advisor checkpoints

- **Checkpoint A — before committing severity assignments**: consult advisor with the finding list and proposed severities. Looking for: overhyped severities, missed critical issues, weak evidence.
- **Checkpoint B — before finalizing envelope**: validate all findings have retrieved_at citations.

Cap 3 calls (this subagent is web-research-heavy). Advisor failures non-blocking.

## 8. DAG position

- **Phase:** 3
- **Depends on:** product, architecture (reads filled contracts for context)
- **Runs in parallel with:** adapter, doc-taxonomy

## 9. Failure handling

- Web research fails on a dep → mark the finding as `info` with a note "status not verified"; do NOT promote to higher severity on hunch alone.
- No manifest in the repo → produce empty findings array; scope note in envelope.
- Too many deps to audit in budget → prioritize direct deps, runtime deps, and widely-used libs; note deferred deps in envelope.
- **Under no condition** does this subagent halt bootstrap. Its output is advisory by contract.
