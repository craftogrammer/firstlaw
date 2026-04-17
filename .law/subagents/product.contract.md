# Subagent contract: product

## 1. Identity

- **id:** `product`
- **goal:** Produce a crisp, honest statement of product identity — what this project is, who it is for, what it will not do — and patch `project.contract.json#identity` plus amend `.law/doctrine/product.md` if warranted.

## 2. Reads

- `README.md` at the repo root (if present)
- `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `pom.xml`, `build.gradle` — for project name, description, keywords
- Any `docs/` or `ARCHITECTURE.md`, `VISION.md`, `ROADMAP.md` files
- Git log first 50 commits (if `.git` exists) — extract the shape of early intent
- Any existing `CLAUDE.md`, `AGENTS.md`, `codex.md` files — for current working assumptions (evidence, not authority)

## 3. Researches

None by default. Product identity is sourced from the user and the repo, not the web. If the project name resolves to a public entity (npm package, GitHub repo) and live research would clarify scope, this is optional — cite retrieval date if used.

## 4. Elicits

Questions this subagent may ask via interactive elicitation. All are `blocking: true` in `greenfield-from-empty` mode; in `greenfield` or `brownfield` mode, default inferred answers are proposed and user confirms.

- **name** — project name. (inferrable from manifest)
- **purpose_one_line** — subject-verb-user-outcome sentence.
- **primary_users** — concrete archetype(s).
- **success_criteria** — observable outcomes.
- **anti_goals** — explicit list of things this project will not do, with reasons.

## 5. Produces

Patches:

- `project.contract.json#identity` (all fields)
- `project.contract.json#status` → `bootstrapping` → on completion of DAG, orchestrator flips to `active`
- `project.contract.json#generated_from.{subagent, run_at}`
- optional: `.law/doctrine/product.md` amendments if the project context changes the doctrine's framing

No code changes. No plan files.

## 6. Envelope

Required envelope fields:

- `subagent_id`: `"product"`
- `decisions[]`: identity decisions with rationale
- `evidence[]`: references to manifest files, git log excerpts, user statements, with retrieval dates where applicable
- `judgment[]`: any inferred claim about user archetype or anti-goals, with confidence
- `questions_for_orchestrator[]`: unresolved identity questions
- `proposed_contract_patches[]`: the patch to `project.contract.json`

## 7. Advisor checkpoints

If advisor capability is available:

- **Checkpoint A — before committing primary recommendation**: consult advisor with the drafted identity + anti-goals. Looking for: hidden contradiction between purpose and anti-goals, vague user archetype, anti-goals missing reasons.
- **Checkpoint B — before finalizing envelope**: consult advisor with the finalized envelope. Looking for: evidence/judgment mislabeling, unsupported claims.

Cap 2 calls. Advisor failures are non-blocking; subagent proceeds.

## 8. DAG position

- **Phase:** 1 (runs first)
- **Depends on:** nothing
- **Produces input for:** architecture, ownership, ambiguity, doc-taxonomy, adapter, quality-audit (they may read the filled identity)

## 9. Failure handling

- User unavailable on a blocking question → write to `.law/context/pending-questions.json` and halt the product phase; do not guess.
- Manifest absent and no README and no git history → operate in `greenfield-from-empty` mode: elicit all identity fields from scratch; do not fabricate.
- Research failure (if research was optional and was attempted): proceed without, note in envelope.
