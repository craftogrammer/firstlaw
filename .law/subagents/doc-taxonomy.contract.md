# Subagent contract: doc-taxonomy

## 1. Identity

- **id:** `doc-taxonomy`
- **goal:** Validate and specialize the document taxonomy for this project: confirm the standard layers, extend `location_pattern` globs for stack-specific conventions, and classify any existing documents found in the repo. Patch `doc-taxonomy.contract.json`.

## 2. Reads

- `project.contract.json` (stack, mode)
- `doc-taxonomy.contract.json` (pre-seeded standard layers)
- Repo root — enumerate all `.md`, `.mdx`, `.txt`, `.rst`, `.adoc` files
- `docs/` directory (if present)
- Any top-level doc-like files (`NOTES.md`, `TODO.md`, `DESIGN.md`, `HISTORY.md`, etc.)

## 3. Researches

Minimal. Research is permitted to identify stack-specific doc conventions:

- Common generated-doc paths for the detected toolchain (e.g. `docs/api/` for typedoc, `site/` for mkdocs)
- Common vendored-external-reference locations (e.g. `vendor/`, `third_party/`)

Retrieval dates required for any web-sourced claim.

## 4. Elicits

- **Existing doc intent** — for any doc whose layer remains unclear, ask the user which layer applies (blocking when the doc is substantive; non-blocking when trivial)
- **Custom layers** — whether the project needs any layers beyond the standard set (non-blocking; rare)

## 5. Produces

Patches:

- `doc-taxonomy.contract.json#layers` — extend `location_pattern` globs for the detected stack
- `doc-taxonomy.contract.json#layers` — add custom layers on user confirmation
- **Classification manifest** — for each existing doc, one classification entry; stored in `.law/context/current-system.json#doc_classification`
- For docs whose current location contradicts their intended layer's `location_pattern`, propose relocations in `questions_for_orchestrator` (never move silently)

## 6. Envelope

- `subagent_id`: `"doc-taxonomy"`
- `decisions[]`: classifications made, layer additions
- `evidence[]`: file paths of classified docs, excerpts where classification draws from content
- `judgment[]`: any classification not directly observable from the doc's location or header
- `questions_for_orchestrator[]`: unclear classifications and proposed relocations
- `proposed_contract_patches[]`: patches to `doc-taxonomy.contract.json` and `current-system.json`

## 7. Advisor checkpoints

- **Checkpoint A — before committing classifications**: consult advisor on any doc with ambiguous layer.
- **Checkpoint B — before finalizing envelope**: validate no doc remains unclassified.

Cap 2 calls. Advisor failures non-blocking.

## 8. DAG position

- **Phase:** 3
- **Depends on:** product, architecture (reads filled domain-map to recognize charter locations)
- **Runs in parallel with:** adapter, quality-audit

## 9. Failure handling

- Doc too long to read in full → read head, tail, and section headers; classify with confidence and mark as judgment.
- User unavailable on a blocking classification → write to `pending-questions.json` with `blocking: true`; the orchestrator surfaces it at the end of bootstrap.
- Doc appears to belong to multiple layers → record as ambiguity finding (it likely is one), propose split or relocation, never pick silently.
