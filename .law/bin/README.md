# .law/bin/

Single-purpose integrity scripts. Each performs one task. Compose them as you wish — git hooks, CI, shell pipelines, a Makefile, `npm run` entries.

| Script | Does | Exits non-zero when |
|---|---|---|
| `verify-adapters` | confirms every adapter file listed in `project.contract.json#adapters.patched_files` retains the `BEGIN/END .law/CONSTITUTION-FIRST` delimiter pair | delimiter absent or file gone |
| `validate-contracts` | runs `check-jsonschema` (or `ajv`) against every `.law/contracts/*.contract.json` using its declared `$schema` | contract fails schema, or no validator installed |
| `check-coupling` | if a diff touches paths declared in `project.contract.json#enforcement.coupled_paths` yet touches nothing under `.law/contracts/`, flags it | coupling violated (opt-in; empty globs = no-op) |
| `check-counts` | confirms counts in `current-system.json` match reality: `summary.open_blockers_count` versus blocking pending-questions, prose `"N open contradictions"` versus unresolved `contradiction_map` entries | counts drift |

## Composition

Serial, fail fast:

```sh
.law/bin/verify-adapters && .law/bin/validate-contracts && .law/bin/check-coupling && .law/bin/check-counts
```

Persist output for the next cold-read:

```sh
.law/bin/verify-adapters .law/bin/validate-contracts .law/bin/check-coupling .law/bin/check-counts 2>&1 | tee .law/context/last-check.log
```

Bypass a single check when you know what you're doing:

```sh
.law/bin/check-coupling || true
```

## Dependencies

- `python3` — `verify-adapters`, `check-coupling`, `check-counts`.
- A JSON Schema validator for `validate-contracts`, selected in priority order:
  1. `check-jsonschema` when installed (`pipx install check-jsonschema`) — handles `date-time` natively
  2. `ajv` when installed globally (`npm install -g ajv-cli ajv-formats` — both packages required; `-c ajv-formats` passes automatically)
  3. `npx ajv-cli` automatically with `ajv-formats` pulled into the cache (zero pre-install; requires Node on PATH)
- `git` — `check-coupling`.

`validate-contracts` fails closed when none of the three exists. The other scripts degrade gracefully (missing contract → exit 0 or 2 with a clear message).

## What these do NOT check

Truth-owner writer violations, cross-domain import violations, anti-pattern gates (file size, fallback chains, etc.) — these demand project-specific semantics. Consult `.law/templates/` for starting points you copy and adapt.
