# Charter: example-domain

> **Layer:** charter · **Authority:** elaboration · **Mutability:** timeless until amended
> Placeholder example. Delete this file once the project has at least one real domain charter, or keep it renamed for reference.

## 1. Identity

- **Domain id:** `example-domain`
- **Purpose:** One-sentence statement of what this domain is responsible for.
- **Primary consumer:** Which domain or interface calls this one.

## 2. Boundary

### In

- `<input-1>` from `<source>`, shape: `<shape>`
- `<input-2>` from `<source>`, shape: `<shape>`

### Out

- `<output-1>` consumed by `<consumer>`, shape: `<shape>`

### Not this domain

- `<adjacent responsibility>` — belongs to `<other-domain>`, via `<interface>`
- `<adjacent responsibility>` — belongs to `<other-domain>`, via `<interface>`

## 3. Owned truths

| Truth id | Storage | Writer module | Readers allowed |
|---|---|---|---|
| `<truth-id>` | `<storage>` | `<writer-module>` | `<reader-domains>` |

Matches `.law/contracts/truth-owners.contract.json`.

## 4. Dependencies

- **Depends on:** `<other-domain>` — for `<reason>`
- **Depended on by:** `<other-domain>`, `<other-domain>` — informational

All edges declared in `.law/contracts/dependency-rules.contract.json`.

## 5. Invariants

1. `<property that must always hold>` — enforced by `<test, schema, or review gate>`
2. `<property that must always hold>` — enforced by `<test, schema, or review gate>`

## 6. Domain-specific anti-patterns

- `<anti-pattern>` — `<why forbidden>`

## 7. Amendment log

| Date | Amendment | Author |
|---|---|---|
| `<YYYY-MM-DD>` | Initial charter. | `<name>` |
