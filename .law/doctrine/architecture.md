# Architecture doctrine

> **Layer:** doctrine · **Authority:** elaboration · **Mutability:** timeless until amended
> Elaborates the principles behind `.law/contracts/domain-map.contract.json`, `truth-owners.contract.json`, and `dependency-rules.contract.json`. Must not contradict the constitution or any contract.

## Ownership

Every piece of runtime truth has one owner, declared in `truth-owners.contract.json`. Readers may be many; the writer is one. The owner is a **domain**, not a file, not a person. The writer is a specific module inside the owning domain.

## Dependency direction

`dependency-rules.contract.json` declares dependency edges. Default stance: deny. An undeclared edge is forbidden. Cycles are forbidden. Re-export, facade, and event-bus tricks do not legalise a forbidden edge — structural intent governs, not syntactic shape.

## Anti-patterns

Default rejection applies to the following. An explicit entry in `domain-map.contract.json` overrides only when it justifies the container as a real domain with a real charter.

### Generic containers

Folders named `shared/`, `common/`, `utils/`, `lib/`, `helpers/`, `manager/`, `service/`, `core/`, `misc/` are rejected unless they appear in `domain-map.contract.json` with a purpose beyond "stuff that didn't fit elsewhere," a clear boundary, and a charter.

A generic container without a charter is a landfill. It attracts orphaned logic, hides ownership, and grows until it owns half the project.

### Parallel logic paths

Two code paths enacting the same behavior are a bug, not a feature. Consolidate per `ambiguity-policies.contract.json#duplicate-logic`.

### Shadow writers

A truth with more than one writer breaks ownership. Consolidate per `ambiguity-policies.contract.json#multiple-writers`.

### Wrappers that hide ambiguity

A wrapper earns its place when it encapsulates a real abstraction. A wrapper that papers over "we weren't sure which of these two to call" is a symptom. Remove the ambiguity first; then decide whether the wrapper still earns its keep.

### Backward compatibility as law

Backward compatibility is a cost, not a principle. Maintain it when it serves a declared user outcome. Never maintain it because deleting feels unsafe.

### Configuration in two places

If a setting lives in two places, one is drift. Declare one owner; demote the other to reader or delete it.

## Decision test

Before accepting a proposed architectural change, verify:

1. Does it have a single declared owner in `truth-owners.contract.json`?
2. Does every new dependency edge appear in `dependency-rules.contract.json`?
3. Does any new domain appear in `domain-map.contract.json` with a charter?
4. Does it replace an existing path (deletion) or add alongside (parallel)?

A "no" on any of the first four blocks the change until resolved.

## Research grounding

When the architecture subagent proposes patterns (state management, data fetching, directory shape, module boundaries), it **must** cite current sources with retrieval dates. Training-era best-guess patterns that drift from current community practice lock stale patterns in as law. Consult `.law/subagents/architecture.contract.md` and `.law/doctrine/agent-behavior.md` for the research rule.

## Brownfield clause

In a brownfield repo, the code as it exists is **evidence, not doctrine**. An agent must not infer "this is how things are done here" from current shape. The agent surveys the shape, records contradictions in `.law/context/current-system.json`, and declares the target architecture in contracts and charters. Project-owned plans track stabilization (the kit does not own plan lifecycle).

## Pointer

Machine-readable architectural law lives across three contracts: `domain-map.contract.json`, `truth-owners.contract.json`, and `dependency-rules.contract.json`. This doctrine is the prose counterpart; contracts are authoritative.
