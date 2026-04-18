---
name: surfacing-forbidden-edges
description: Use the moment a pre-existing cross-domain coupling violating `.law/contracts/dependency-rules.contract.json` surfaces during reading or tracing — a call graph lands in a domain the caller cannot legally reach, a file opened for an unrelated task imports from a forbidden sibling, a `grep`/index search reveals a re-export routing around a denied edge, a test fixture or migration crosses a boundary, a DI container or event-bus subscription binds symbols across domains with no matching entry in `allowed`, a path alias resolves to a forbidden target, or `current-system.json#contradiction_map` already lists an entry and the current task would extend it. Fires on discovery, not on authoring — contrast with `checking-dep-edges-before-importing`, which fires before the agent types a new import. Anchors: CONSTITUTION.md §6, §11.
---

# Surfacing Forbidden Edges

## Overview

A forbidden edge is any cross-domain dependency absent from `.law/contracts/dependency-rules.contract.json#allowed` or listed in `forbidden[]`. The default stance is deny. When the agent discovers such an edge already present in the codebase — by reading, tracing, grepping, running tests, or following a call graph — the edge becomes the task. Halt the in-flight work. Record the violation in `.law/context/current-system.json#contradiction_map`. Surface it to the user. Refuse to ship new code that depends on or extends the forbidden edge, even when the new code adds no new import of its own. CONSTITUTION.md §6 binds the edge; §11 binds the enforcement posture ("Correct violations at the point of discovery. 'We'll fix it later' is not an acceptable response.").

## When to Use

Fire this skill the instant any of the following is observed:

- following a call graph or stack trace and landing in a file whose domain the caller cannot legally reach per `dependency-rules.contract.json#allowed`
- opening a file mid-task and seeing a static import, `from ... import`, or `require` that crosses into a forbidden sibling domain
- a `grep`/index search surfacing a re-export (`export * from`, `export { X } from`), barrel file, or facade that forwards a symbol across a denied edge
- a dynamic loader call (`await import()`, `importlib.import_module`, `System.import`, reflection) whose resolved target sits in a domain the source cannot reach
- a DI container binding, service registration, or factory that wires a symbol from a forbidden target domain into the source domain
- an event-bus `subscribe`/`publish`/`emit` whose topic or payload encodes ownership by a domain the subscriber/publisher has no declared edge to
- a test fixture, seed script, snapshot, or migration file that reaches across domain boundaries without an entry in `allowed`
- a `tsconfig.json`, `jsconfig.json`, `pyproject.toml`, or bundler path alias resolving to a forbidden target
- a contradiction already logged in `.law/context/current-system.json#contradiction_map` that the current task would extend by adding new callers or new data flow
- CI, linters, or `.law/bin/*` output reporting a cross-domain violation the agent had not previously surfaced

Do not fire this skill when the agent is about to author a new import — route that through `checking-dep-edges-before-importing`. This skill owns **discovery** moments; the sibling skill owns **authoring** moments.

## Rule

On discovering a forbidden edge already in the tree:

1. Halt the current task at the line of discovery. Do not continue writing code that depends on, calls through, or extends the forbidden edge.
2. Resolve the `source -> target` pair from the actual file paths per `.law/contracts/domain-map.contract.json`. Record structural intent, not syntactic shape.
3. Append the edge to `.law/context/current-system.json#contradiction_map` with source, target, file path, line reference, `evidence_or_judgment: "evidence"`, and the resolution path (removal, amendment, or raised block per §11).
4. Surface the finding to the user loudly: name the source domain, the target domain, the file, the line, the in-flight task it blocks, and the three legal resolutions.
5. Raise a blocker in `.law/context/pending-questions.json` if the resolution requires a human decision (amendment to `dependency-rules.contract.json#allowed`, deletion of the offending import, or refactor).
6. Refuse to merge, commit, or continue feature work whose correctness depends on the forbidden edge.
7. Run `.law/bin/validate-contracts` and `.law/bin/check-counts` after recording the entry; block on non-zero exit.

## Agent must

- halt the in-flight task at the exact line of discovery
- resolve both endpoints against `.law/contracts/domain-map.contract.json` using the resolved path, not an alias label
- classify re-exports, barrels, facades, DI bindings, event buses, and dynamic loaders by structural intent
- record the finding in `.law/context/current-system.json#contradiction_map` with file path, line, and `evidence` label
- surface the violation loudly in the same turn, naming source domain, target domain, file, and blocked task
- raise a blocker in `.law/context/pending-questions.json` when resolution requires human input
- declare the in-flight task blocked until the edge is removed, the contract is amended through the §9 mutation path, or the block is explicitly raised per §11
- re-run `.law/bin/validate-contracts` and `.law/bin/check-counts` after amending the contract or updating `current-system.json`
- escalate per §11 when the user or a prior commit attempts to ship past the violation with a comment

## Agent must not

- proceed past a discovered forbidden edge with a `TODO`, `FIXME`, `XXX`, `HACK`, or deferred-fix comment
- ship new code whose correctness depends on the forbidden edge, even when that new code adds no new import
- add a new caller, subclass, override, or consumer that routes through the forbidden edge
- extend the existing violation by layering another facade, wrapper, barrel, or adapter over it
- silently append an entry to `dependency-rules.contract.json#allowed` to legitimize the discovered edge
- treat the edge as "grandfathered" because it predates the contract
- treat a passing test suite as permission — runtime success is not contract compliance
- omit the entry from `.law/context/current-system.json#contradiction_map` because "someone else will record it"
- bypass `.law/bin/validate-contracts` or `.law/bin/check-counts` with `|| true`, `--no-verify`, or silent skip
- refactor around the edge in a way that hides the structural intent while preserving the coupling

## Rationalizations — STOP and re-read

| Rationalization the agent whispers | Why it is still forbidden |
|---|---|
| "The violation was already there. Not my problem." | §11: correct violations at the point of discovery. The discoverer owns the surface-and-record step. Ownership is not transferred by the absence of authorship. |
| "I'll add a `TODO` and fix it later." | §11 forbids `TODO`-and-proceed explicitly. "Later" never arrives. Halt, record, surface, block. |
| "My change adds no new import — it only uses the existing one." | Adding a caller, consumer, subclass, or data-flow dependency **is** silently extending the edge. §6 governs structural intent, not import-line authorship. |
| "The test suite passes, so the violation must be intentional." | Runtime success is evidence of what runs, not evidence of what the contract permits. §6 default stance is deny. Contracts declare intent; code is evidence, not permission. |
| "It's a legacy import, grandfathered by age." | No grandfather clause exists. §11 applies at point of discovery regardless of the edge's age. Age is not an amendment. |
| "I'll silently refactor around it — move the call through a new helper in `shared/`." | Reverse-indirection is explicitly forbidden (`dependency-rules.contract.json#rules.reverse_indirection_forbidden`). A facade in a neutral directory is the edge, re-labelled. |
| "It's only on one call path and nobody will notice." | Visibility is not the enforcement criterion. The edge is in the tree; §11 fires on discovery regardless of traffic. |
| "The contradiction_map already lists something similar, so this is a duplicate entry." | New discovery sites, new callers, and new extension paths are distinct entries. Add the row; do not suppress it. |
| "I'll amend `allowed` in the same commit as my feature code and move on." | Amendment requires the §9 mutation path with justification and human sign-off; silent same-commit amendments launder the violation. |
| "The task is urgent. Recording this blocks me." | §11: the violation **is** the task now. Urgency is not a carve-out. Raise the block and surface the trade-off to the user. |
| "It's a test fixture, tests are allowed to reach anywhere." | Test files belong to a domain. Cross-domain test imports need an `allowed` entry or a declared test-only edge. Absence = forbidden. |
| "The edge goes through an event bus, so it isn't really a dependency." | The bus is transport; the edge is ownership of payload/topic semantics. Route does not dissolve structural intent. |

## Red flags

Halt and re-check the instant any of these surfaces:

- a file opened for unrelated work contains an import whose resolved path leaves the file's declared domain
- a call-graph trace crosses a domain boundary not listed in `dependency-rules.contract.json#allowed`
- a barrel (`index.ts`, `__init__.py`, `mod.rs`) re-exports symbols owned by a foreign domain
- a `shared/`, `common/`, `utils/`, `lib/`, or `core/` file imports from a feature domain
- a facade or adapter class (`XGateway`, `XAdapter`, `XBridge`, `XFacade`) under a neutral directory forwards calls into a foreign domain
- a DI registration module imports concrete implementations from domains the container's home domain has no declared edge to
- an event-bus topic name encodes a foreign domain (`billing.charged`, `user.created`) and the subscriber/publisher has no declared edge to that domain
- a path alias in `tsconfig.json`/`pyproject.toml`/bundler config resolves to a forbidden target
- `.law/context/current-system.json#contradiction_map` lists the edge and the current task adds a new caller of the same forbidden symbol
- CI output, lint output, or `.law/bin/*` output reports a cross-domain violation that is not yet in `contradiction_map`
- a prior commit message or PR description mentions a "temporary" cross-domain call, and the call is still present
- `// eslint-disable`, `# noqa`, `@ts-ignore`, or `# type: ignore` on a cross-domain import line
- a test fixture or migration imports from a domain the module under test has no edge to

## Machine-readable contract

Primary: `.law/contracts/dependency-rules.contract.json` (fields: `rules.default_stance`, `rules.cycles_forbidden`, `rules.reverse_indirection_forbidden`, `allowed[]`, `forbidden[]`, `agent_directives.on_discovering_existing_forbidden_edge`).

Record target: `.law/context/current-system.json#contradiction_map` — append one entry per discovered edge with `source_domain`, `target_domain`, `file`, `line`, `evidence_or_judgment: "evidence"`, `blocks_task`, and `resolution` (`remove` | `amend` | `raised-block`).

Block target: `.law/context/pending-questions.json` — append one blocker when resolution requires human input.

Cross-reference: `.law/contracts/domain-map.contract.json` (fields: `domains[]`, `rules.every_runtime_module_has_exactly_one_domain`).

Validators: `.law/bin/validate-contracts`, `.law/bin/check-counts`. Run after every recorded entry; block on non-zero exit.

Constitution anchor: CONSTITUTION.md §6 (Dependency law) and §11 (Enforcement).
