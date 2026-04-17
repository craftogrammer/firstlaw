# Architecture doctrine

> **Layer:** doctrine · **Authority:** elaboration · **Mutability:** timeless until amended
> Elaborates the principles behind `.law/contracts/domain-map.contract.json`, `truth-owners.contract.json`, and `dependency-rules.contract.json`. May not contradict the constitution or any contract.

## Ownership

Every piece of runtime truth has one owner, declared in `truth-owners.contract.json`. Readers may be many; writers are one. The owner is a **domain**, not a file, not a person. The writer is a specific module inside the owning domain.

## Dependency direction

Dependency edges are declared in `dependency-rules.contract.json`. Default stance: deny. An edge not declared allowed is forbidden. Cycles are forbidden. Re-export, facade, and event-bus tricks do not legalise a forbidden edge — structural intent matters, not syntactic shape.

## Anti-patterns

The following are rejected by default. Each can be overridden only by an explicit entry in `domain-map.contract.json` that justifies the container as a real domain with a real charter.

### Generic containers

Folders named `shared/`, `common/`, `utils/`, `lib/`, `helpers/`, `manager/`, `service/`, `core/`, `misc/` are rejected unless they appear in `domain-map.contract.json` with a purpose that is not "stuff that didn't fit elsewhere," a clear boundary, and a charter.

A generic container with no charter is a landfill. It attracts orphaned logic, hides ownership, and grows until it owns half the project.

### Parallel logic paths

Two code paths implementing the same behavior are a bug, not a feature. Consolidate per `ambiguity-policies.contract.json#duplicate-logic`.

### Shadow writers

A truth with more than one writer is broken ownership. Consolidate per `ambiguity-policies.contract.json#multiple-writers`.

### Wrappers that hide ambiguity

A wrapper is justified when it encapsulates a real abstraction. A wrapper that exists to paper over "we weren't sure which of these two to call" is a symptom. Remove the ambiguity first; then decide whether the wrapper still earns its keep.

### Backward compatibility as law

Backward compatibility is a cost, not a principle. Maintain it when it serves a declared user outcome. Do not maintain it because deleting feels unsafe.

### Configuration in two places

If a setting lives in two places, one of them is drift. Declare one owner; make the other a reader or remove it.

## Decision test

Before accepting a proposed architectural change, check:

1. Does it have a single declared owner in `truth-owners.contract.json`?
2. Does every new dependency edge appear in `dependency-rules.contract.json`?
3. Does any new domain appear in `domain-map.contract.json` with a charter?
4. Does it replace an existing path (deletion) or add alongside (parallel)?

A "no" on any of the first four blocks the change until resolved.

## Research grounding

When the architecture subagent proposes patterns (state management, data fetching, directory shape, module boundaries), it **must** cite current sources with retrieval dates. Training-era best-guess patterns that drift from current community practice are how stale patterns get locked in as law. See `.law/subagents/architecture.contract.md` and `.law/doctrine/agent-behavior.md` for the research rule.

## Brownfield clause

In a brownfield repo, the code as it exists is **evidence, not doctrine**. An agent may not infer "this is how things are done here" from current shape. The shape is surveyed, contradictions are recorded in `.law/context/current-system.json`, and the target architecture is declared in contracts and charters. Stabilization is tracked in project-owned plans (the kit does not own plan lifecycle).

## Pointer

Machine-readable architectural law lives across three contracts: `domain-map.contract.json`, `truth-owners.contract.json`, and `dependency-rules.contract.json`. This doctrine is the prose counterpart; contracts are authoritative.
