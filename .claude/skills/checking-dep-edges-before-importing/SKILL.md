---
name: checking-dep-edges-before-importing
description: Use when authoring or discovering any cross-domain edge — `import`, `from X import`, `require(...)`, `export * from`, `export { X } from`, dynamic loader (`importlib`, `await import()`, reflection), DI binding, event-bus `subscribe`/`publish`/`emit`, path alias, barrel, facade, re-export, fixture/seed/migration reaching another domain — whose source and target sit in different top-level directories in `domain-map.contract.json` and whose edge is absent from `dependency-rules.contract.json#allowed`; also when `.law/bin/check-coupling` surfaces a violation; also when `contradiction_map` lists an edge this task would extend; also when grep/trace during refactor hits a cross-domain edge. Anchors: CONSTITUTION.md §6, §11.
---

# Checking Dep Edges Before Importing

## Overview

Every cross-domain edge the agent introduces must already appear in `.law/contracts/dependency-rules.contract.json#allowed`. The default stance is deny. An edge absent from `allowed` is forbidden, even when the import looks local, harmless, or one-line. Structural intent — "module A depends on module B" — is what the contract governs; the syntactic shape (static import, dynamic loader, re-export, facade, event bus, DI binding) does not dilute that intent. The same discipline binds discovery: when the agent finds a forbidden edge already in the tree — by reading, tracing, grepping, or running `.law/bin/check-coupling` — the edge becomes the task. Halt, record in `contradiction_map`, surface, block. CONSTITUTION.md §6 binds the edge; §11 binds the enforcement posture ("Correct violations at the point of discovery. 'We'll fix it later' is not an acceptable response.").

## When to Use

### Before adding an edge (authoring)

Fire the instant any of the following is about to be written:

- a static import/require whose resolved path leaves the source file's domain
- a `from ... import ...` line across domains in Python/TS/Go/Rust/Swift/etc.
- a re-export (`export * from`, `export { X } from`) or barrel file that surfaces a symbol owned by another domain
- a dynamic loader call (`await import()`, `require()` at runtime, `importlib.import_module`, `System.import`, class-loader reflection)
- a DI container binding that wires a symbol from domain B into a container owned by domain A
- an event-bus `subscribe`, `publish`, `emit`, or `on` that crosses domains
- a path-alias entry (`@/featureB/...` used from `featureA/`) added to `tsconfig.json`, `jsconfig.json`, `package.json#imports`, `pyproject.toml`, or bundler config
- a test, fixture, migration, or seed file that reaches across domains

### On discovering an existing edge (discovery)

Fire the instant any of the following is observed:

- grepping imports and finding a cross-domain edge not in `dependency-rules.contract.json#allowed`
- reviewing legacy code and noticing a `../<other-domain>/...` path
- `.law/bin/check-coupling` (v1.4 real dep-edge walker) surfaces a violation on the current branch
- a test file imports across a declared forbidden edge
- static analyzer, linter, or CI output includes a cross-layer edge
- following a call graph or stack trace and landing in a file whose domain the caller cannot legally reach
- a dynamic loader call whose resolved target sits in a domain the source cannot reach
- a DI registration, factory, or service binding wires a symbol from a forbidden target domain
- an event-bus topic or payload encodes ownership by a domain the subscriber/publisher has no declared edge to
- a path alias resolving to a forbidden target
- `.law/context/current-system.json#contradiction_map` already lists an edge the current task would extend by adding new callers or new data flow

## Rule

Before introducing any cross-domain edge:

1. Resolve the **source domain** from the file's directory per `domain-map.contract.json`.
2. Resolve the **target domain** from the resolved path of the symbol, alias, or bus topic.
3. Look up `source -> target` in `dependency-rules.contract.json#allowed`.
4. If the edge is not listed, **halt**. Do not type the import.
5. Either amend `dependency-rules.contract.json` with recorded justification (per §9 mutation rules), or raise the edge as a blocker in `.law/context/pending-questions.json`.

On discovering an existing forbidden edge, halt the current task, record the edge in `.law/context/current-system.json#contradiction_map` with `source_domain`, `target_domain`, `file`, `line`, `evidence_or_judgment: "evidence"`, `blocks_task`, and `resolution` (`remove` | `amend` | `raised-block`), and raise it to the user naming source, target, file, line, and the blocked task. Do not silently extend forbidden edges; do not TODO-comment-and-proceed. Run `.law/bin/check-coupling` and `.law/bin/validate-contracts` after recording; block on non-zero exit.

## Agent must

- halt before any cross-domain edge whose `from -> to` pair is absent from `dependency-rules.contract.json#allowed`
- resolve both endpoints against `domain-map.contract.json` using the actual resolved file path, not the alias label
- treat re-exports, barrel files, facades, DI bindings, event buses, and dynamic loaders as edges — classify them by structural intent, not syntactic shape
- surface undeclared edges as blockers and record them in `.law/context/pending-questions.json`
- on discovering an existing forbidden edge, halt the in-flight task at the exact line of discovery
- record the violation in `.law/context/current-system.json#contradiction_map` with class `dep-edge-violation`, `evidence_or_judgment: "evidence"`, and evidence pointing at file + line
- run `.law/bin/check-coupling` to confirm the violation is real and to find siblings
- block further work on the current path until resolved (amend dep-rules, remove the edge, or raise-and-halt per §11)
- surface the violation loudly in the same turn, naming source domain, target domain, file, and blocked task
- raise a blocker in `.law/context/pending-questions.json` when resolution requires human input
- escalate per §11 when the user or a prior commit attempts to ship past the violation with a comment
- amend `dependency-rules.contract.json#allowed` only through the §9 mutation path, co-locating the edge entry with the code change and stamping `last_validated_at`
- refuse to merge a change that adds an edge without the matching contract amendment in the same commit
- run `.law/bin/validate-contracts` and `.law/bin/check-counts` after any amendment or `contradiction_map` update and block on non-zero exit

## Agent must not

- add an entry to `allowed` mid-task to unblock the current import
- route a forbidden edge through `shared/`, `common/`, `utils/`, `lib/`, `core/`, or any other generic container
- launder an edge through a facade, adapter, wrapper, or re-export in a neutral directory
- treat an event bus, message queue, observer, or pub/sub topic as an escape hatch
- register the target in a DI container from the source domain and call the binding "not really an import"
- use `await import()`, `importlib`, or reflection to defer the edge past the contract check
- rely on a path alias to obscure which domain a symbol belongs to
- leave a `TODO`, `FIXME`, `XXX`, `HACK`, or deferred-fix comment promising to amend the contract or remove the edge "later"
- bypass `.law/bin/validate-contracts`, `.law/bin/check-coupling`, or `.law/bin/check-counts` with `|| true`, `--no-verify`, or silent skip
- proceed past a discovered forbidden edge with a deferred-fix comment
- ship new code whose correctness depends on a discovered forbidden edge, even when that new code adds no new import
- add a new caller, subclass, override, or consumer that routes through an existing forbidden edge
- extend an existing violation by layering another facade, wrapper, barrel, or adapter over it
- silently append an entry to `dependency-rules.contract.json#allowed` to legitimize a discovered edge
- treat a discovered edge as "grandfathered" because it predates the contract
- treat a passing test suite as permission — runtime success is not contract compliance
- omit a discovered entry from `.law/context/current-system.json#contradiction_map` because "someone else will record it"
- refactor around a discovered edge in a way that hides structural intent while preserving the coupling

## Rationalizations — STOP and re-read

| Rationalization the agent whispers | Why it is still forbidden |
|---|---|
| "It's a one-line import, the overhead of amending is disproportionate." | §6: default stance is deny. Line count is not a carve-out. Halt and amend or raise. |
| "I'll wrap it in a facade under `shared/` so nothing directly imports across." | §6 reverse-indirection clause: structural intent matters. The facade is the edge. |
| "A re-export through `index.ts` keeps the call sites clean." | A barrel that forwards a cross-domain symbol **is** the cross-domain edge. Classify by resolved target. |
| "The event bus is allowed, so publishing a domain-B payload from domain A is fine." | The bus is the transport. The edge is `A -> B payload ownership`. Routing does not dissolve it. |
| "DI binds it at runtime; the source file never names domain B." | The binding declaration is the edge. `container.register(B)` from `A/` fails the check. |
| "`await import()` is dynamic, so the static analyzer won't catch it." | The contract governs intent, not tooling coverage. Halt on the semantic edge. |
| "Tests need to reach across domains to set up fixtures." | Test files belong to a domain. Cross-domain test imports need an entry in `allowed` or a declared test-only edge. |
| "The alias `@/shared/*` makes this look local." | Resolve the alias to the real path; classify by that path. The alias is not a loophole. |
| "I'll add the edge to `allowed` and amend the commit message." | Amendment requires the §9 mutation path, not a silent append. Record rationale and validate. |
| "It's temporary — I'll remove it after the spike." | Temporary edges calcify. Raise the blocker; do not type the import. |
| "The target already imports from my domain, so the edge already exists in reverse." | `cycles_forbidden: true`. An existing reverse edge makes this forward edge worse, not permitted. |
| "Nobody has defined domains yet, so nothing is cross-domain." | Halt. Surface the gap. Proceeding before `domain-map.contract.json` is populated violates §8 mode obligations. |
| "I'll import the DB driver directly (`pg`, `prisma`, etc.) — it's a library, not the persistence domain." | Third-party packages that semantically *are* the forbidden target count as crossing the edge. The rule binds to structural intent, not the package name. §6 'structural intent matters' applies. Halt. |
| "Health-check is infrastructure — exempt from layer rules by nature." | No CONSTITUTION article exempts diagnostic or infrastructure code from layer rules. If an edge is forbidden, it is forbidden for infrastructure too. §6 admits no infrastructure carve-out. |
| "Make it a middleware — middleware is framework-level plumbing, not a domain module." | Middleware that calls across a forbidden edge violates §6 identically to any other call site. Framework position is not a layering escape. Classify by resolved target, not by hook name. |
| "Pull the connection pool from `config/` — `config/` isn't a declared domain." | Generic containers (`config/`, `runtime/`, `bootstrap/`) laundering forbidden edges is forbidden by §5's generic-container rule and §6's 'structural intent matters' clause. The edge is where the pool is wired, not where the folder sits. |
| "It's a read-only probe with no side effects — a pure read can't create architectural coupling." | Coupling is about dependency direction, not mutation. A read-only call from the higher layer to the lower layer is the same cross-layer dependency as a write. §6 binds reads and writes identically. |
| "The violation was already there. Not my problem." | §11: correct violations at the point of discovery. The discoverer owns the surface-and-record step. Ownership is not transferred by the absence of authorship. |
| "I'll add a `TODO` and fix it later." | §11 forbids `TODO`-and-proceed explicitly. "Later" never arrives. Halt, record, surface, block. |
| "My change adds no new import — it only uses the existing one." | Adding a caller, consumer, subclass, or data-flow dependency **is** silently extending the edge. §6 governs structural intent, not import-line authorship. |
| "The test suite passes, so the violation must be intentional." | Runtime success is evidence of what runs, not evidence of what the contract permits. §6 default stance is deny. Contracts declare intent; code is evidence, not permission. |
| "It's a legacy import, grandfathered by age." | No grandfather clause exists. §11 applies at point of discovery regardless of the edge's age. Age is not an amendment. |
| "I'll silently refactor around it — move the call through a new helper in `shared/`." | Reverse-indirection is explicitly forbidden (`dependency-rules.contract.json#rules.reverse_indirection_forbidden`). A facade in a neutral directory is the edge, re-labelled. |
| "It's only on one call path and nobody will notice." | Visibility is not the enforcement criterion. The edge is in the tree; §11 fires on discovery regardless of traffic. |
| "The contradiction_map already lists something similar, so this is a duplicate entry." | New discovery sites, new callers, and new extension paths are distinct entries. Add the row; do not suppress it. |
| "The task is urgent. Recording this blocks me." | §11: the violation **is** the task now. Urgency is not a carve-out. Raise the block and surface the trade-off to the user. |

## Red flags

Halt and re-check if any of these appear:

- a new entry in `allowed` authored in the same diff as the import that needed it, without an Amendment log row
- a file under `shared/`, `common/`, `utils/`, `lib/`, or `core/` that imports from a feature domain
- a barrel (`index.ts`, `__init__.py`, `mod.rs`) that re-exports symbols from multiple domains, or symbols owned by a foreign domain
- a facade class named `XAdapter`, `XGateway`, `XBridge`, `XFacade` added under a neutral directory that forwards calls into a foreign domain
- dynamic loader calls whose argument string is a domain-prefixed path, or whose resolved target sits in a foreign domain
- event-bus topic names that encode a target domain (`user.created`, `billing.charged`) subscribed to from an unrelated domain
- DI registration modules that import concrete implementations from domains the container's home domain has no declared edge to
- a `tsconfig.json`/`pyproject.toml` path alias added in the same diff as the first import using it, or resolving to a forbidden target
- a test file whose imports span more domains than the module under test declares, or a test fixture/migration importing from a domain the module under test has no edge to
- `// eslint-disable`, `# noqa`, `@ts-ignore`, or `# type: ignore` on a cross-domain import line
- `.law/bin/validate-contracts`, `.law/bin/check-coupling`, or `.law/bin/check-counts` invoked with `|| true`, `--no-verify`, or skipped in CI
- a file opened for unrelated work contains an import whose resolved path leaves the file's declared domain
- a call-graph trace crosses a domain boundary not listed in `dependency-rules.contract.json#allowed`
- `.law/context/current-system.json#contradiction_map` lists the edge and the current task adds a new caller of the same forbidden symbol
- CI output, lint output, or `.law/bin/*` output reports a cross-domain violation that is not yet in `contradiction_map`
- a prior commit message or PR description mentions a "temporary" cross-domain call, and the call is still present
- the agent thinks "the `pg` import isn't really crossing the edge because it's a library"
- the agent thinks "health-check is infrastructure, layer rules don't bind"
- the agent thinks "make it a middleware and the layer rules don't apply"
- the agent thinks "pull it from `config/` — it isn't a declared domain"
- the agent thinks "it's read-only so there's no architectural coupling"

## Machine-readable contract

Primary: `.law/contracts/dependency-rules.contract.json` (fields: `rules.default_stance`, `rules.cycles_forbidden`, `rules.reverse_indirection_forbidden`, `allowed[]`, `forbidden[]`, `agent_directives.before_adding_import`, `agent_directives.on_discovering_existing_forbidden_edge`).

Cross-reference: `.law/contracts/domain-map.contract.json` (fields: `domains[]`, `rules.every_runtime_module_has_exactly_one_domain`, `rules.generic_containers_require_explicit_domain_entry`, `rules.forbidden_default_names_without_justification`).

Record target: `.law/context/current-system.json#contradiction_map` — append one entry per discovered edge with `source_domain`, `target_domain`, `file`, `line`, `evidence_or_judgment: "evidence"`, `blocks_task`, and `resolution` (`remove` | `amend` | `raised-block`).

Block target: `.law/context/pending-questions.json` — append one blocker when resolution requires human input.

Enforcement template: `.law/templates/check-dep-direction.example.mjs` — adapt the `classifyLayer` function to the project's path conventions; the contract-reading and violation-reporting scaffold stays fixed.

Validators: `.law/bin/validate-contracts`, `.law/bin/check-coupling` (v1.4 real import-graph walker), `.law/bin/check-counts`. Run after every amendment or `contradiction_map` update; block on non-zero exit.

Constitution anchor: CONSTITUTION.md §6 (Dependency law), §9 (Mutation rules), §11 (Enforcement).
