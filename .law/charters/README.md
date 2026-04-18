# Charters

> **Layer:** charter · **Authority:** elaboration · **Mutability:** timeless until amended

A **charter** declares the timeless law of a single domain. One file per domain. Lives at `.law/charters/<domain>.md`. The domain id must match an entry in `.law/contracts/domain-map.contract.json#domains[].id`.

Charters must not contradict `CONSTITUTION.md` or any contract in `.law/contracts/`.

## When to create a charter

The moment a domain enters `domain-map.contract.json`. A domain without a charter is incomplete and must not receive feature code.

## When to amend a charter

When the domain's responsibility, boundary, owned truths, or allowed dependencies change. Date every amendment in the charter's own log.

## What a charter must contain

### 1. Identity

- **Domain id** — matches the entry in `domain-map.contract.json`
- **Purpose** — one-sentence statement of what this domain owns
- **Primary consumer** — which other domain(s) or human interface consumes this domain

### 2. Boundary

- **In** — inputs this domain accepts, with shape and source
- **Out** — outputs this domain produces
- **Not this domain** — explicit list of responsibilities that look adjacent but belong elsewhere

The "not this domain" section bears load. It blocks scope creep during feature work.

### 3. Owned truths

Every runtime truth this domain owns. Each entry matches a record in `truth-owners.contract.json`.

### 4. Dependencies

- **Depends on** — domains this domain may call. Each edge appears in `dependency-rules.contract.json`.
- **Depended on by** — domains that call this one. Informational; the dependency rules contract remains the source of truth.

### 5. Invariants

Properties that must always hold for this domain. Invariants carry enforcement: they map to tests, validation schemas, or review gates. An invariant without an enforcement path is not an invariant.

### 6. Domain-specific anti-patterns

Domain-local variants of the patterns in `.law/doctrine/architecture.md`.

### 7. Amendment log

Dated entries. Log every meaningful change to this charter.

## What a charter must not contain

- roadmaps, feature lists, or execution plans (those belong in project-owned temporary-plan docs)
- implementation details that belong in code
- vague aspirational language
- unenforceable rules

## Example

Consult `example-domain.md` for the minimal shape.
