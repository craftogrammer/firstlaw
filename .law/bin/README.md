# .law/bin/

Small, single-purpose integrity scripts. Each does one thing. Compose them however you want — git hooks, CI, shell pipelines, a Makefile, `npm run` entries.

| Script | Does | Exit non-zero when |
|---|---|---|
| `verify-adapters` | checks every adapter file listed in `project.contract.json#adapters.patched_files` still contains the `BEGIN/END .law/CONSTITUTION-FIRST` delimiter pair | delimiter missing or file gone |
| `validate-contracts` | runs `check-jsonschema` (or `ajv`) against every `.law/contracts/*.contract.json` using its declared `$schema` | schema-invalid contract, or no validator installed |
| `check-coupling` | if a diff touches paths declared in `project.contract.json#enforcement.coupled_paths` but touches nothing under `.law/contracts/`, flags it | coupling violated (opt-in; empty globs = no-op) |

## Composition

Serial, fail fast:

```sh
.law/bin/verify-adapters && .law/bin/validate-contracts && .law/bin/check-coupling
```

Persist output for the next cold-read:

```sh
.law/bin/verify-adapters .law/bin/validate-contracts .law/bin/check-coupling 2>&1 | tee .law/context/last-check.log
```

Bypass a single check when you know what you're doing:

```sh
.law/bin/check-coupling || true
```

## Dependencies

- `python3` — `verify-adapters`, `check-coupling`.
- A JSON Schema validator for `validate-contracts`, picked in priority order:
  1. `check-jsonschema` if installed (`pipx install check-jsonschema`)
  2. `ajv` if installed globally (`npm install -g ajv-cli`)
  3. `npx ajv-cli` automatically (zero pre-install; needs Node on PATH — covers most JS/TS projects)
- `git` — `check-coupling`.

`validate-contracts` fails closed if none of the three is available. The other scripts degrade gracefully (missing contract → exit 0 or 2 with a clear message).

## What these do NOT check

Truth-owner writer violations, cross-domain import violations, anti-pattern gates (file size, fallback chains, etc.) — those require project-specific semantics. See `.law/templates/` for starting points you copy and adapt.
