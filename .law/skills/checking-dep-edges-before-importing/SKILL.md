---
name: checking-dep-edges-before-importing
description: Use when about to type `import`, `from X import`, `require(...)`, `export * from`, `export { X } from`, a dynamic loader (`importlib`, `System.import`, `await import()`), a DI container binding, or an event-bus `subscribe`/`publish`/`emit` whose source file and target symbol sit in different top-level directories listed in `.law/contracts/domain-map.contract.json`; also use when adding a new package entry, a path alias, a barrel file, a facade wrapper, or a re-export that forwards a symbol across a domain boundary; also use when a test fixture, seed script, or migration touches a module outside its own domain. Covers every cross-domain edge regardless of syntactic shape (static, dynamic, transitive, or event-routed). Anchors: CONSTITUTION.md §6.
---

# Checking Dep Edges Before Importing

## Overview

Every cross-domain edge the agent introduces must already appear in `.law/contracts/dependency-rules.contract.json#allowed`. The default stance is deny. An edge absent from `allowed` is forbidden, even when the import looks local, harmless, or one-line. Structural intent — "module A depends on module B" — is what the contract governs; the syntactic shape (static import, dynamic loader, re-export, facade, event bus, DI binding) does not dilute that intent. CONSTITUTION.md §6 binds this skill.

## When to Use

Fire this skill the instant any of the following is about to be written:

- a static import/require whose resolved path leaves the source file's domain
- a `from ... import ...` line across domains in Python/TS/Go/Rust/Swift/etc.
- a re-export (`export * from`, `export { X } from`) or barrel file that surfaces a symbol owned by another domain
- a dynamic loader call (`await import()`, `require()` at runtime, `importlib.import_module`, `System.import`, class-loader reflection)
- a DI container binding that wires a symbol from domain B into a container owned by domain A
- an event-bus `subscribe`, `publish`, `emit`, or `on` that crosses domains
- a path-alias entry (`@/featureB/...` used from `featureA/`) added to `tsconfig.json`, `jsconfig.json`, `package.json#imports`, `pyproject.toml`, or bundler config
- a test, fixture, migration, or seed file that reaches across domains

## Rule

Before introducing any cross-domain edge:

1. Resolve the **source domain** from the file's directory per `domain-map.contract.json`.
2. Resolve the **target domain** from the resolved path of the symbol, alias, or bus topic.
3. Look up `source -> target` in `dependency-rules.contract.json#allowed`.
4. If the edge is not listed, **halt**. Do not type the import.
5. Either amend `dependency-rules.contract.json` with recorded justification (per §9 mutation rules), or raise the edge as a blocker in `.law/context/pending-questions.json`.
6. If an already-forbidden edge is discovered in the tree, record it in `.law/context/current-system.json#contradiction_map` and surface it. Do not extend it.

## Agent must

- halt before any cross-domain edge whose `from -> to` pair is absent from `dependency-rules.contract.json#allowed`
- resolve both endpoints against `domain-map.contract.json` using the actual resolved file path, not the alias label
- treat re-exports, barrel files, facades, DI bindings, event buses, and dynamic loaders as edges — classify them by structural intent, not syntactic shape
- surface undeclared edges as blockers and record them in `.law/context/pending-questions.json`
- record discovered forbidden edges in `.law/context/current-system.json#contradiction_map` and escalate per §11
- amend `dependency-rules.contract.json#allowed` only through the §9 mutation path, co-locating the edge entry with the code change and stamping `last_validated_at`
- refuse to merge a change that adds an edge without the matching contract amendment in the same commit
- run `.law/bin/validate-contracts` after any amendment and block on non-zero exit

## Agent must not

- add an entry to `allowed` mid-task to unblock the current import
- route a forbidden edge through `shared/`, `common/`, `utils/`, `lib/`, `core/`, or any other generic container
- launder an edge through a facade, adapter, wrapper, or re-export in a neutral directory
- treat an event bus, message queue, observer, or pub/sub topic as an escape hatch
- register the target in a DI container from the source domain and call the binding "not really an import"
- use `await import()`, `importlib`, or reflection to defer the edge past the contract check
- rely on a path alias to obscure which domain a symbol belongs to
- leave a `TODO` promising to amend the contract "later"
- bypass `.law/bin/validate-contracts` with `|| true`, `--no-verify`, or silent skip

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

## Red flags

Halt and re-check if any of these appear:

- a new entry in `allowed` authored in the same diff as the import that needed it, without an Amendment log row
- a file under `shared/`, `common/`, `utils/`, `lib/`, or `core/` that imports from a feature domain
- a barrel (`index.ts`, `__init__.py`, `mod.rs`) that re-exports symbols from multiple domains
- a facade class named `XAdapter`, `XGateway`, `XBridge`, `XFacade` added under a neutral directory
- dynamic loader calls whose argument string is a domain-prefixed path
- event-bus topic names that encode a target domain (`user.created`, `billing.charged`) subscribed to from an unrelated domain
- DI registration modules that import concrete implementations from domains the container's home domain has no declared edge to
- a `tsconfig.json`/`pyproject.toml` path alias added in the same diff as the first import using it
- a test file whose imports span more domains than the module under test declares
- `// eslint-disable`, `# noqa`, or `@ts-ignore` on an import line
- `.law/bin/validate-contracts` or cross-domain import gates invoked with `|| true`, `--no-verify`, or skipped in CI
- the agent thinks "the `pg` import isn't really crossing the edge because it's a library"
- the agent thinks "health-check is infrastructure, layer rules don't bind"
- the agent thinks "make it a middleware and the layer rules don't apply"
- the agent thinks "pull it from `config/` — it isn't a declared domain"
- the agent thinks "it's read-only so there's no architectural coupling"

## Machine-readable contract

Primary: `.law/contracts/dependency-rules.contract.json` (fields: `rules.default_stance`, `rules.cycles_forbidden`, `rules.reverse_indirection_forbidden`, `allowed[]`, `forbidden[]`, `agent_directives.before_adding_import`, `agent_directives.on_discovering_existing_forbidden_edge`).

Cross-reference: `.law/contracts/domain-map.contract.json` (fields: `domains[]`, `rules.every_runtime_module_has_exactly_one_domain`, `rules.generic_containers_require_explicit_domain_entry`, `rules.forbidden_default_names_without_justification`).

Enforcement template: `.law/templates/check-dep-direction.example.mjs` — adapt the `classifyLayer` function to the project's path conventions; the contract-reading and violation-reporting scaffold stays fixed.

Constitution anchor: CONSTITUTION.md §6 (Dependency law), §9 (Mutation rules), §11 (Enforcement).
