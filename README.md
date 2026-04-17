# firstlaw

A template for installing **repo law** into a project.

One `CONSTITUTION.md` at the root. A `.law/` directory for compiled law, doctrine, charters, subagent contracts, bootstrap protocol, and context snapshots. An agent reads the constitution cold and either runs the bootstrap protocol (if law is in skeleton state) or operates within the law (if filled).

## Why

Agents and humans drift. They invent certainty when the repo is unclear. They preserve bad compatibility because deleting feels unsafe. They patch locally instead of correcting ownership. They create parallel logic paths. They treat current code as intended architecture. They write long-lived decisions into throwaway plans.

This kit gives a project a stable, researched, machine-readable source of truth that survives those drifts. Bootstrap is grounded in live web research (not training-era patterns), real repo evidence, and user elicitation — not templates copy-pasted across projects.

## What this is NOT

- not a CLI, generator, or workflow runner
- not a replacement for `CLAUDE.md`, `AGENTS.md`, `codex.md`, Cursor rules — those are adapters, non-authoritative, patched non-destructively
- not a plugin or subagent framework
- not a style guide, linter config, or CI pipeline
- not a plan, sprint, or ticket manager — the kit recognizes plans as a document layer but does not own their format, location, or lifecycle

## Install

From any project root (empty folder is fine):

```sh
curl -fsSL https://raw.githubusercontent.com/craftogrammer/firstlaw/main/install.sh | sh
```

Or with force (overwrite existing files):

```sh
curl -fsSL https://raw.githubusercontent.com/craftogrammer/firstlaw/main/install.sh | sh -s -- --force
```

Then open a new chat with any coding agent and say:

```
read CONSTITUTION.md
```

The agent detects skeleton state and runs `.law/bootstrap/INIT.md`.

## Adopted-project shape

```
CONSTITUTION.md
.law/
├── KIT_INDEX.md
├── adapters.md
├── bin/                # kit integrity scripts (verify-adapters, validate-contracts, check-coupling)
├── git-hooks/          # sample pre-commit
├── templates/          # project-owned check examples
├── bootstrap/
│   ├── INIT.md
│   └── questions/cross-cutting.json
├── subagents/          # 7 role/goal/output contracts
├── contracts/          # 7 machine-readable compiled law files
├── schemas/            # 8 JSON Schemas
├── doctrine/           # 3 timeless prose files
├── charters/           # per-domain timeless law
└── context/            # regenerable snapshots + research audit
```

## Bootstrap in 30 minutes

The agent runs seven subagents in a DAG, each producing a structured envelope:

```
Phase 1:    product
Phase 2:    architecture  |  ownership  |  ambiguity
Phase 3:    doc-taxonomy  |  adapter    |  quality-audit
```

Execution mode adapts to the environment:

- **Subagents** (preferred): each runs in an isolated context, returns one envelope, orchestrator merges
- **Advisor-only**: single executor consults an advisor capability at each subagent's checkpoints
- **Degraded**: single agent runs phases sequentially with mandatory summary-to-envelope between phases

30 minutes is an illustrative ceiling. The agent reports overrun and continues; it does not cut research to fit the clock.

## Precedence

1. `CONSTITUTION.md` — highest law
2. `.law/contracts/*.contract.json` — compiled machine-readable law
3. `.law/doctrine/*.md` and `.law/charters/*.md` — elaboration, may not contradict above
4. `.law/context/*` — non-authoritative snapshots and audit
5. Tool-facing adapter files (`CLAUDE.md`, `AGENTS.md`, etc.) — non-authoritative projections, patched non-destructively

On conflict, higher layer wins. Agents halt on ambiguity; resolution is explicit, never silent.

## Hard rules

- **Research freshness**: every architectural, library, or dep-quality claim cites live web sources with retrieval dates. Training-only claims on those topics are rejected.
- **Evidence vs judgment**: every non-trivial claim in every contract is labelled `evidence` or `judgment`. Judgment never becomes law without an amendment step.
- **Single writer**: every piece of runtime truth has one writer. Shadow writes are forbidden.
- **Default-deny dependencies**: cross-domain edges must be declared allowed; undeclared is forbidden.
- **Non-destructive adapter patches**: tool-facing files are patched only inside a delimited block; user content outside is inviolate; conflicts halt.
- **Quality audit is advisory**: critical findings require acknowledgement, never halt bootstrap.
- **Empty repos are valid**: `greenfield-from-empty` is a first-class mode; no scaffold precondition.

## Enforcement

The kit ships three small programs in `.law/bin/` that enforce properties of the kit itself:

- `verify-adapters` — adapter delimiter blocks stayed intact
- `validate-contracts` — contracts validate against their schemas. Uses `check-jsonschema` or `ajv + ajv-formats` if globally installed; otherwise falls back to `npx ajv-cli` (zero pre-install on any Node machine; uses the `ajv-formats` plugin automatically for `date-time` support).
- `check-coupling` — opt-in; source-path changes are accompanied by contract amendments

Compose them however you want. Example git pre-commit (copy `.law/git-hooks/pre-commit.sample` to `.git/hooks/pre-commit`):

```sh
#!/usr/bin/env sh
set -e
.law/bin/verify-adapters
.law/bin/validate-contracts
.law/bin/check-coupling
```

Example GitHub Actions step (uses npx fallback, no pre-install needed):

```yaml
- name: firstlaw integrity
  run: |
    .law/bin/verify-adapters
    .law/bin/validate-contracts
    .law/bin/check-coupling
```

Project-specific enforcement (truth-owner writers, cross-domain imports, anti-patterns) lives in your `scripts/` directory. Starting points are in `.law/templates/`.

## Versioning

`KIT_VERSION` in the repo root tracks the installed kit version. Upgrades are manual: re-run `install.sh` with `--force` after backing up any kit-owned files that were edited (contracts are meant to be edited; doctrine and schemas should usually not be).

## Scope honesty

This is a v1 starting point, not a battle-tested product. Expect to iterate on 3–5 files after first real adoption reveals gaps. Contribute back patterns that recur across projects; resist turning the kit into a framework.
