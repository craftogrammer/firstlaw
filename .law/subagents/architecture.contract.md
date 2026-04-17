# Subagent contract: architecture

## 1. Identity

- **id:** `architecture`
- **goal:** Propose domain shape, dependency law, and architectural anti-patterns grounded in live research on current practice for this project's stack. Patch `domain-map.contract.json` and `dependency-rules.contract.json`; may amend `.law/doctrine/architecture.md`.

## 2. Reads

- `project.contract.json` (filled by product) — for stack, mode, purpose
- Source tree layout (`ls -R` up to reasonable depth; ignore `node_modules`, `target`, `dist`, `build`, `.venv`, etc.)
- `package.json` / equivalent manifest — declared deps
- Lockfile (if present) — resolved deps and versions
- Any existing `docs/architecture*`, `ARCHITECTURE.md`
- Existing folder names — as **evidence** of current shape, not as doctrine

## 3. Researches (hard rule: live web, retrieval dates required)

This subagent is the primary defense against locking in stale patterns as law. For the detected stack, research:

- **Modern directory / module structure** — what the current community consensus is, and where it diverges
- **State management patterns** — which are current, which are deprecated
- **Data fetching / IO patterns** — current recommended approaches
- **Dependency direction / module boundaries** — canonical layering for this stack
- **Known anti-patterns** — things the community has explicitly moved away from
- **Framework/library defaults** — current opinionated defaults from major frameworks in the detected stack

Every researched claim in the envelope MUST include a URL and `retrieved_at` timestamp. Training-only claims on any of the above are rejected.

If the stack is polyglot or unusual, research each primary language/framework in turn.

## 4. Elicits

- **Current pain points** — what feels brittle or duplicated (non-blocking; helps prioritize)
- **Team conventions** — any hard team rules not visible in the code (non-blocking)
- **Domain intuition** — user's initial sense of domain boundaries (non-blocking; ground for discussion)

In `brownfield` mode, also elicits:

- **Known contradictions** — places the user already knows don't match their intent (non-blocking)

## 5. Produces

Patches:

- `domain-map.contract.json#domains` — proposed domain entries with `evidence_or_judgment` labels
- `domain-map.contract.json#rules.forbidden_default_names_without_justification` — any additions
- `dependency-rules.contract.json#allowed` — proposed edges, each with rationale
- `dependency-rules.contract.json#forbidden` — explicit bans with severity
- optional: `.law/doctrine/architecture.md` amendments if stack-specific guidance merits prose

For each new domain proposed, creates a charter file at `.law/charters/<domain>.md` based on `charters/example-domain.md`.

## 6. Envelope

- `subagent_id`: `"architecture"`
- `decisions[]`: domain-and-edge decisions with rationale; each decision lists alternatives considered
- `evidence[]`: file paths (directory structure), lockfile entries, AND web sources (with retrieved_at)
- `judgment[]`: any domain boundary or forbidden-edge proposal that is inferred, with confidence
- `questions_for_orchestrator[]`: unresolved boundary questions
- `proposed_contract_patches[]`: patches to `domain-map.contract.json` and `dependency-rules.contract.json`

## 7. Advisor checkpoints

- **Checkpoint A — before committing domain shape**: consult advisor with the proposed domains and edges. Looking for: hidden cycles, overly generic domains, missing boundaries.
- **Checkpoint B — before finalizing envelope**: consult advisor with the envelope. Looking for: mislabeled evidence/judgment, missed anti-patterns.

Cap 3 calls (this subagent is research-heavy; one extra call for mid-research recalibration is permitted). Advisor failures non-blocking.

## 8. DAG position

- **Phase:** 2
- **Depends on:** product (reads filled identity + stack)
- **Runs in parallel with:** ownership, ambiguity

## 9. Failure handling

- Web research fails (rate limit, connectivity) → retry once; if still failing, halt with a clear envelope note. Do NOT fall back to training-only claims for any architectural recommendation.
- Stack undetectable → halt and elicit from user; proposals in a greenfield-from-empty repo are minimal and stack-neutral.
- Source tree too large to enumerate → sample by `.gitignore`-filtered top-level and request user guidance on where the core lives.
