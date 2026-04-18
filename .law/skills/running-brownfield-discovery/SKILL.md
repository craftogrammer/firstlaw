---
name: running-brownfield-discovery
description: Use when `.law/contracts/project.contract.json#mode` is `brownfield`; also use when mode detection at session start surfaces a scaffolded repo with non-trivial source tree plus git history or a meaningful README; also use when contracts are still `skeleton` or `bootstrapping` but runtime truth already exists (populated `src/`, `lib/`, `app/`, or language-conventional dirs); also use when a user says "bootstrap this existing repo", "adopt firstlaw on this codebase", or "wire the kit into this project"; also use when the agent observes a mature codebase whose `domain-map.contract.json#domains`, `truth-owners.contract.json#truths`, or `dependency-rules.contract.json#allowed` are empty while real code already writes fields and crosses module boundaries; also use when `.law/context/current-system.json#contradiction_map` is empty in a repo with real runtime truth. Covers the full discovery workflow, not a single halt-check. Anchors: CONSTITUTION.md §8.
---

# Running Brownfield Discovery

## Overview

Brownfield mode means runtime truth already exists. The code is the territory; contracts are the map the agent draws from it. The agent enumerates existing domains, truth owners, and dependency edges from the code as it actually runs, labels every discovered item as `evidence` (observed in the code) or `judgment` (inferred), records every contradiction the discovery surfaces, and populates contracts only from evidence. Stabilization work ships through project-owned plans. Feature code stays frozen until discovery closes. CONSTITUTION.md §8 binds this skill; `.law/bootstrap/INIT.md` defines the phase machinery.

## When to Use

Fire this skill the instant any of the following holds:

- `project.contract.json#mode` is `brownfield`
- mode detection at session start finds scaffold (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `pom.xml`, `build.gradle`, or equivalent) **and** a non-trivial source tree **and** either git history or a meaningful README
- `project.contract.json#status` is `skeleton` or `bootstrapping` while the repo already contains populated feature directories, shipped migrations, deployed infra, or commit history older than the kit install
- `domain-map.contract.json#domains`, `truth-owners.contract.json#truths`, or `dependency-rules.contract.json#allowed` are empty in a repo whose code already spans multiple modules
- `.law/context/current-system.json#contradiction_map` is empty or absent in a repo with real runtime truth
- a user asks to "bootstrap this existing repo", "adopt firstlaw here", "wire the kit into this codebase", or "start using the constitution on this project"
- a subagent envelope or advisor checkpoint reports that discovered evidence contradicts a contract entry authored from wishful thinking

## Rule

1. Halt feature code. No new functionality lands while discovery is open.
2. Confirm mode. Read `project.contract.json#mode`. When detection disagrees with the contract, halt and surface the mismatch; never silently flip the field.
3. Enumerate runtime truth from the code directly: directory layout, module boundaries, writers of each field/table/config, cross-module imports, event-bus topics, DI bindings, migrations, deploy manifests.
4. Label every enumerated item `evidence` (observed in code at a cited path) or `judgment` (inferred, with the inference recorded).
5. Populate `domain-map.contract.json#domains`, `truth-owners.contract.json#truths`, and `dependency-rules.contract.json#allowed` **only** from `evidence` entries. Mark each `judgment` entry explicitly in its contract row and mirror it into `.law/context/current-system.json#judgment_log`.
6. Record every contradiction the discovery surfaces — duplicated writers, forbidden edges already in the tree, README claims that disagree with code, rule softness — in `.law/context/current-system.json#contradiction_map`.
7. Run discovery through the phase DAG in `.law/bootstrap/INIT.md` (product → architecture | ownership | ambiguity → doc-taxonomy | adapter | quality-audit). Each subagent deposits research at `.law/context/research/<subagent-id>-<YYYY-MM-DD>.json` and returns one envelope.
8. Ship stabilization work through project-owned plans. The kit owns neither plan format nor plan location; the `temporary-plan` doc layer (§4) classifies them.
9. Only after the contradiction map is populated, every contract stamps `last_validated_at` and `generated_from.{subagent, run_at}`, and `project.contract.json#status` flips to `active` — then resume feature code.
10. When the contradiction map comes back genuinely empty, halt and elicit explicit human confirmation that discovery found no contradictions before resuming feature code.

## Agent must

- halt feature code the instant brownfield mode is detected or confirmed, and announce the halt
- read `project.contract.json#mode` before any action in a newly-entered repo, and treat `brownfield` as the binding declaration
- run the full phase DAG from `.law/bootstrap/INIT.md` (product, then parallel architecture/ownership/ambiguity, then parallel doc-taxonomy/adapter/quality-audit, then merge)
- enumerate domains from directory layout and actual import graphs, not from the README
- enumerate truth owners by tracing writers of each field, table, queue, config file, and environment variable in the running code
- enumerate dependency edges from resolved import paths, re-exports, dynamic loaders, DI bindings, and event-bus topics — classify by structural intent, not syntactic shape
- label every enumerated item `evidence` with a file path and line reference, or `judgment` with the inference recorded
- populate contracts only from `evidence`; mirror every `judgment` entry into `.law/context/current-system.json#judgment_log`
- record every discovered contradiction in `.law/context/current-system.json#contradiction_map` at the moment of discovery
- treat duplicated truth writers, forbidden-but-present dependency edges, and README-vs-code drift as contradictions — halt per §11 and record; never silently extend
- ship stabilization work through project-owned plans classified under the `temporary-plan` layer of `doc-taxonomy.contract.json`
- stamp `last_validated_at` and `generated_from.{subagent, run_at}` on every contract the discovery touches
- run `.law/bin/verify-adapters`, `.law/bin/validate-contracts`, and `.law/bin/check-counts` after the merge phase and halt on non-zero exit
- elicit explicit human confirmation before declaring the contradiction map empty and resuming feature code
- flip `project.contract.json#status` to `active` only after the completion checklist in `.law/bootstrap/INIT.md` §9 passes

## Agent must not

- declare `greenfield` or `greenfield-from-empty` in a repo with non-trivial runtime truth
- ship feature code while the contradiction map is empty without recorded human confirmation that discovery found none
- populate `domain-map.contract.json`, `truth-owners.contract.json`, or `dependency-rules.contract.json` from the README, from a wiki, from a design doc, or from memory — evidence means the actual code
- mark an entry `evidence` without a cited file path; pathless claims are `judgment`
- skip enumerating a module because the code looks messy, legacy, or scheduled for deletion
- treat forbidden-but-present dependency edges as "acceptable for now" and omit them from the contradiction map
- add an entry to `dependency-rules.contract.json#allowed` just because the edge already exists in the tree — the edge is a contradiction until amended per §9
- resolve ambiguity found during discovery by preferring older code, newer code, or the cleaner-looking branch
- wrap a discovered contradiction in a TODO, a comment, or a follow-up ticket and proceed
- defer the contradiction map to "after we stabilize"
- merge discovery envelopes without stamping `last_validated_at` and `generated_from.{subagent, run_at}` on every contract touched
- bypass `.law/bin/validate-contracts`, `.law/bin/verify-adapters`, or `.law/bin/check-counts` with `|| true`, `--no-verify`, or silent skip
- flip `project.contract.json#status` to `active` while any blocking entry remains in `.law/context/pending-questions.json`
- end the turn between phases, between subagents, or between merge steps — the autonomy rule in `.law/bootstrap/INIT.md` §0.1 binds brownfield discovery

## Rationalizations — STOP and re-read

| Rationalization the agent whispers | Why it is still forbidden |
|---|---|
| "The codebase is small, we can skip discovery and fill contracts by hand." | §8 brownfield clause: discovery is mandatory when runtime truth exists. Size is not a carve-out. Run the phase DAG. |
| "I'll label evidence vs judgment later, after the contracts are drafted." | §10 agent failure model — inventing certainty. Unlabeled entries calcify into pseudo-evidence. Label at the moment of entry. |
| "The contradiction map can stay empty; I didn't notice any contradictions." | Empty-by-omission and empty-by-verification read identically in JSON. Halt and elicit explicit human confirmation before treating the map as empty. |
| "This is brownfield but the legacy code is a mess, so we'll treat it as greenfield and rewrite." | §8 forbids declaring greenfield in a repo with non-trivial runtime truth. The mess is the discovery target, not a reason to erase it. |
| "We'll populate contracts from the README instead of the code — faster." | README is prose intent; runtime truth is the territory. §4 precedence: README is not a law layer. Evidence means code paths. |
| "I found a forbidden edge already in the tree; I'll just add it to `allowed` so the contract matches reality." | §6 and §9: a forbidden-but-present edge is a contradiction. Record it in the contradiction map, then amend per the §9 mutation path with justification — never launder. |
| "Discovery is taking too long; I'll ship the feature the user asked for and finish discovery afterward." | §8 agent-must-not clause. Feature code in brownfield with empty contradiction map is forbidden without recorded confirmation. Halt the feature. |
| "Two modules write the same config; I'll pick the cleaner one as the owner." | §5 forbids silently resolving truth-owner ambiguity. Record the duplication in `contradiction_map`, apply `ambiguity-policies.contract.json`. |
| "The README says domain X owns field Y, so I'll register Y under X." | Evidence is the code that writes Y, not the README's claim. Trace the writer. Log the README-vs-code delta as a contradiction. |
| "I'll just stamp `last_validated_at` and move on; the details are close enough." | Stamping without evidence is fiction. §9 requires co-location of law updates with the code change. Brownfield is the same rule. |
| "The user said 'just get the kit installed'; discovery can be a follow-up." | Install-without-discovery produces contracts that describe a project that doesn't exist. Surface the scope. Run discovery. |
| "Subagents aren't available in this environment, so I'll skip the DAG." | `.law/bootstrap/INIT.md` §2 defines advisor-only and degraded execution modes. Degraded runs the phases sequentially in-chat with per-phase envelopes — discovery is not optional. |

## Red flags

Halt and re-check when any of these appear:

- `project.contract.json#mode` is `brownfield` and `domain-map.contract.json#domains` is empty
- `project.contract.json#status` is `active` while `.law/context/current-system.json#contradiction_map` is absent or empty in a repo with populated source
- contract rows lacking a `confidence` or `source` field of `evidence` / `judgment`
- contract entries citing `README.md` or a design doc as the source while no code path is cited
- a discovered cross-domain import that is absent from `dependency-rules.contract.json#allowed` and also absent from `contradiction_map`
- two or more modules writing the same field/table/config with no entry in `truth-owners.contract.json` and no contradiction logged
- `.law/context/research/` empty or missing after discovery supposedly completed
- `generated_from.run_at` null on any contract after the merge phase
- `last_validated_at` null on any contract after the merge phase
- `pending-questions.json` containing blocking entries while `project.contract.json#status` is `active`
- feature-code commits landing in the same branch as the brownfield bootstrap before discovery closes
- the agent drafting plan docs outside a directory classified as `temporary-plan` in `doc-taxonomy.contract.json`
- `validate-contracts`, `verify-adapters`, or `check-counts` invoked with `|| true`, `--no-verify`, or skipped after the merge phase
- a single-paragraph discovery summary offered in place of the phase DAG

## Machine-readable contract

Primary: `.law/contracts/project.contract.json` (fields: `mode`, `status`, `identity`, `stack`, `adapters.patched_files`, `agent_directives.on_session_start`).

Cross-reference:
- `.law/contracts/domain-map.contract.json` (fields: `domains[]`, `rules.every_runtime_module_has_exactly_one_domain`)
- `.law/contracts/truth-owners.contract.json` (fields: `truths[]`, `rules`)
- `.law/contracts/dependency-rules.contract.json` (fields: `allowed[]`, `forbidden[]`, `rules.default_stance`)
- `.law/contracts/ambiguity-policies.contract.json` (fields: `policies[]`, `rules.default_action_when_no_policy_matches`)
- `.law/contracts/doc-taxonomy.contract.json` (fields: `layers[]` — `temporary-plan`, `runtime-truth`, `context-snapshot`)
- `.law/contracts/quality-audit.contract.json` (fields: `findings[]`, acknowledgement stamps)

Context targets (regenerable, populated during discovery):
- `.law/context/current-system.json#contradiction_map`
- `.law/context/current-system.json#judgment_log`
- `.law/context/pending-questions.json`
- `.law/context/research/<subagent-id>-<YYYY-MM-DD>.json`

Protocol: `.law/bootstrap/INIT.md` (§1 mode detection, §2 execution mode matrix, §3 orchestration DAG, §5 elicitation policy, §6 research audit trail, §7 merge and commit, §9 completion checklist).

Doctrine: `.law/doctrine/agent-behavior.md` (evidence vs judgment; inventing certainty; treating current code as intended architecture).

Constitution anchors: CONSTITUTION.md §8 (Operating modes — brownfield clause), §5 (Domain ownership), §6 (Dependency law), §7 (Ambiguity protocol), §9 (Mutation rules), §11 (Enforcement).
