# firstlaw

A kit that installs repo law into any project. One `CONSTITUTION.md` at the root, one `.law/` directory holding contracts, schemas, enforcement scripts, skills, bootstrap protocol, and context snapshots. You point a coding agent at `CONSTITUTION.md` and it does the rest — bootstraps the project's law from live research and repo evidence, then enforces it session after session.

v1.5.1 ships nine enforcement scripts, fourteen skills, eight JSON-schema-validated contracts, and a cold-read protocol that runs self-heal before every agent session.

---

## What this is

A discipline kit for projects where an agent is actively shaping the codebase and you care about drift.

The kit ships:

- A constitution (principles — thirteen articles, stack-agnostic)
- Machine-readable contracts (project identity, domain map, truth owners, dependency rules, doc taxonomy, ambiguity policies, quality audit, agent runtime)
- Enforcement scripts (read the contracts, check the code, exit non-zero on violations)
- Skills (agent-loadable capsules that fire on specific cognitive moments — ambiguity detected, about to cross a domain boundary, about to violate an anti-goal)
- A bootstrap protocol (agents run seven subagents in a DAG to fill the contracts from evidence)

The kit does not ship opinions about your stack. It ships slots and a script engine. You populate the slots (or an agent does) with regexes, globs, and domain paths that match your codebase.

## What this is NOT

- Not a CLI, code generator, or framework runner
- Not a replacement for `CLAUDE.md` / `AGENTS.md` / `codex.md` / `.cursorrules` — those remain as tool-facing adapters, patched non-destructively with a pointer to `CONSTITUTION.md`
- Not a style guide, linter, or CI pipeline
- Not a plan or sprint tracker (plans are a recognized document layer; their format, location, and lifecycle are yours)
- Not a plugin or subagent marketplace
- Not battle-tested — one live deployment, five red-team probes, and a partial game-engine probe as of v1.5.1

## Install

From any project root (empty folder is fine):

```sh
curl -fsSL https://raw.githubusercontent.com/craftogrammer/firstlaw/main/install.sh | bash
```

To upgrade an existing installation (overwrites kit files, preserves your populated contracts):

```sh
curl -fsSL https://raw.githubusercontent.com/craftogrammer/firstlaw/main/install.sh | bash -s -- --force
```

Installed layout:

```
CONSTITUTION.md
KIT_VERSION
.gitattributes
.law/
├── KIT_INDEX.md
├── adapters.md
├── bootstrap/
│   ├── INIT.md
│   └── questions/cross-cutting.json
├── subagents/                 # 7 role contracts for the bootstrap DAG
├── contracts/                 # 8 JSON contracts (skeleton on first install)
├── schemas/                   # 9 JSON Schemas validating the contracts
├── doctrine/                  # 3 prose elaborations
├── charters/                  # per-domain law (you author one per domain)
├── skills/                    # 14 agent-loadable skills
├── templates/                 # starter enforcement examples + skill template
├── bin/                       # 9 enforcement scripts
├── git-hooks/                 # pre-commit sample (wires all 9 scripts)
└── context/                   # regenerable snapshots + research audit trail
```

KIT_FILES overwrite on `--force`. TEMPLATE_FILES (your populated contracts, current-system.json, pending-questions.json) are preserved. Re-run the installer after any kit release — the next cold-read auto-heals version drift.

## First session

Open a chat with any coding agent (Claude, Codex, Cursor, Aider) and say:

```
follow CONSTITUTION.md
```

What happens:

1. The agent reads `CONSTITUTION.md`, then `.law/KIT_INDEX.md`, then `.law/contracts/project.contract.json`.
2. If the project is in `skeleton` status, the agent runs `.law/bootstrap/INIT.md` — seven subagents in a DAG (product, architecture, ownership, ambiguity, doc-taxonomy, adapter, quality-audit). Each returns a structured envelope. The orchestrator merges them into the contracts. Expect a 30-minute session on a clean scaffold, longer on brownfield.
3. If the project is `active`, the agent runs the cold-read protocol (six steps, single continuous action) and then acts on your request.

Bootstrap modes:

- **greenfield-from-empty** — no scaffold exists. First-class mode; the kit does not halt on an empty folder.
- **greenfield** — scaffold exists, little or no feature code. Define identity, domains, truth ownership, and dep rules before writing features.
- **brownfield** — existing non-trivial codebase. Discovery is mandatory. The agent enumerates domains, truth owners, and dep edges from the code as it is; labels every finding `evidence` or `judgment`; produces a contradiction map.

## How enforcement works

Two layers, interlocking.

**Mechanical** — nine scripts in `.law/bin/`, all silent on pass, non-zero exit on violation:

| Script | Checks |
|---|---|
| `verify-adapters` | Every adapter file listed in `project.contract.json#adapters.patched_files` still contains the `BEGIN/END .law/CONSTITUTION-FIRST` delimiter pair. |
| `validate-contracts` | Every `.law/contracts/*.contract.json` validates against its declared JSON Schema. |
| `check-coupling` | Walks source imports (TS/JS/Py) and fails any cross-domain edge not in `dependency-rules.contract.json#allowed`. Default deny. |
| `check-amendment-coupling` | When `project.contract.json#enforcement.coupled_paths` is populated, source changes on those globs must carry a `.law/contracts/*` amendment. |
| `check-truth-ownership` | Reads `truth-owners.contract.json#truths[].write_patterns[]` — regexes you populate per truth per language. Any match outside the truth's owner domain is a shadow-write violation. |
| `check-anti-patterns` | Reads `project.contract.json#identity.anti_goals[].forbidden_patterns[]` and `enforcement.anti_patterns[]`. Regexes you populate. Error-severity matches fail; warnings go to stderr. |
| `check-skill-voice` | Validates every `SKILL.md` in `.law/skills/` and `.claude/skills/` against voice rules (frontmatter shape, forbidden softening verbs in author-voice prose, § citations, required sections). Universal — no project patterns consumed. |
| `check-counts` | `current-system.json` declared counts match reality. Reconciles the amendment log against `git log` of contract edits. |
| `check-setup` | Self-heals remediable drift (missing skill-bridge, stale contract layers from kit upgrades, missing pre-commit hook). Commits atomically when the tree is clean, disk-only when dirty. Surfaces irreducible items (empty `coupled_paths`, blocking questions, unresolved contradictions, kit-version drift). |

Compose them in a pre-commit hook (sample at `.law/git-hooks/pre-commit.sample`), a CI step, or on demand. The sample invokes all nine in order via `python3 .law/bin/<script>`, which sidesteps shebang-honoring differences across shells.

**Documentary** — fourteen skills in `.law/skills/`, loaded by the agent runtime:

- Entry + cold-read: `using-firstlaw`, `cold-reading-the-repo`, `auditing-firstlaw-integrity`
- Discipline skills (halt/check on a specific cognitive moment): `halting-on-ambiguity`, `checking-truth-ownership-before-mutating`, `checking-dep-edges-before-importing`, `refusing-anti-goal-creep`, `resolving-layer-conflicts`, `grounding-with-dated-research`, `logging-amendments-atomically`, `classifying-before-authoring`
- Workflow skills (multi-step): `running-brownfield-discovery`, `maintaining-mechanical-enforcement`
- Meta: `authoring-project-skills`

Skills fire on trigger phrases in their `description` frontmatter. Discipline skills carry rationalization tables that close the specific excuses agents actually use when tempted to bypass the rule.

## Contracts you populate

Eight contracts ship as skeleton files. The bootstrap protocol fills them from evidence + elicitation. The ones with parameterized slots:

- `truth-owners.contract.json` — each truth has an optional `write_patterns[]` array. Populate with regexes matching write-site syntax in your stack (SQL `INSERT/UPDATE/DELETE`, ORM `.create()`/`.save()`, direct file writes, cache SET). `check-truth-ownership` enforces against what you declared. Empty = no enforcement for that truth (prose-only).

- `project.contract.json#identity.anti_goals[]` — each anti-goal is a `{goal, reason}` object with an optional `forbidden_patterns[]` (regex list). Populate when the anti-goal is keyword-detectable ("no OCR", "no telemetry on user identity"). `check-anti-patterns` enforces. Skip for abstract anti-goals ("no feature creep") and rely on the `refusing-anti-goal-creep` skill.

- `project.contract.json#enforcement.anti_patterns[]` — generic project-declared patterns (file-size caps, forbidden imports, forbidden folder names). Each entry has `name`, `pattern`, `severity`, optional `applies_to` globs, optional `allowlist`.

- `dependency-rules.contract.json#allowed` — list of permitted `(source_domain, target_domain)` edges. `check-coupling` walks imports and rejects anything not listed. Default deny.

- `project.contract.json#enforcement.coupled_paths` — glob list of source paths that require a `.law/contracts/*` amendment when they change. `check-amendment-coupling` enforces; empty = no-op.

All slots are optional and backwards-compatible. A fresh install has them empty. You populate incrementally as the project matures.

## Project maturity curve

Mechanical enforcement scales with contract population. Day zero has empty `write_patterns`, empty `forbidden_patterns`, sparse `dependency-rules.allowed`, few declared truths. All the new checks silently exit 0 because there is nothing to enforce against. This is not a bug. The judgment skills (halting-on-ambiguity, refusing-anti-goal-creep, resolving-layer-conflicts, grounding-with-dated-research, running-brownfield-discovery) carry the agent through the early phase while the shape is still forming.

As the project matures, the agent populates the pattern fields as each truth, anti-goal, and domain gets declared (per the `maintaining-mechanical-enforcement` skill). Mechanical coverage grows one commit at a time.

Expect the judgment-to-mechanical ratio to invert as the project matures. Day zero: judgment carries ~90% of the discipline, mechanics ~10%. After some months with the discipline applied: mechanics catch ~80% pre-commit, judgment fires only on genuine ambiguity. Same scripts, same skills; mode-switching is implicit.

## Cold-read protocol

Every session on a firstlaw-governed repo starts with the cold-read. The protocol is defined in `CONSTITUTION.md`'s top comment block and enforced by `cold-reading-the-repo`:

1. Follow `CONSTITUTION.md` in full.
2. Follow `.law/KIT_INDEX.md`.
3. Follow `project.contract.json` and branch on `status` (skeleton → bootstrap; active → consult task-relevant contracts).
4. Consult `current-system.json`.
5. Consult `pending-questions.json` and `last-check.log`.
6. Run `.law/bin/check-setup` — self-heals drift, surfaces irreducible items, halts on non-zero exit.
7. Run `verify-adapters`, `validate-contracts`, `check-coupling`, `check-amendment-coupling`, `check-counts`, `check-truth-ownership`, `check-anti-patterns`, `check-skill-voice` — halt on non-zero.

The protocol runs as a single continuous action. Summarize-and-ask mid-sequence is an explicit violation, not a legitimate turn boundary.

## Precedence

Highest to lowest authority:

1. `CONSTITUTION.md`
2. `.law/contracts/*.contract.json` (schema-validated)
3. `.law/doctrine/*.md` and `.law/charters/*.md` (must not contradict the above)
4. `.law/context/*` (regenerable snapshots, research audit — never source of truth)
5. Tool-facing adapter files (`CLAUDE.md`, `AGENTS.md`, `codex.md`, `.cursorrules`, etc.) — non-authoritative projections, patched non-destructively

On conflict, the higher layer wins. Agents halt on ambiguity; resolution is explicit. The adapter files get a kit-managed block at the top (or after YAML frontmatter) pointing at `CONSTITUTION.md` and the contracts as sources of truth. User content outside the delimited block is inviolate.

## Hard rules (selection)

- **Research freshness** — architecture, library, or dep-quality claims cite live web sources with retrieval dates. Training-only recall is rejected.
- **Evidence vs judgment** — every non-trivial contract entry is labeled `evidence` or `judgment`. Judgment never becomes law without an amendment step.
- **Single writer** — every piece of runtime truth has exactly one owning domain. Shadow writes are forbidden and mechanically detectable via `write_patterns`.
- **Default-deny dependencies** — cross-domain edges must appear in `dependency-rules.contract.json#allowed`. Undeclared edges fail `check-coupling`.
- **Atomic mutations (§9)** — any change to repo law updates the corresponding contract in the same commit, with a matching row in the CONSTITUTION.md amendment log. `check-counts` reconciles the log against `git log`.
- **Non-destructive adapter patches** — tool-facing files are patched only inside the delimited block; user content outside is preserved byte-for-byte; structural conflicts halt the patch.
- **Quality audit is advisory** — critical findings require human acknowledgement but never block bootstrap or operate mode.
- **Empty repos are valid** — `greenfield-from-empty` is a first-class mode.

Full set in `CONSTITUTION.md` articles 1–13.

## Upgrading

Each release bumps `KIT_VERSION` and appends an amendment-log row. To upgrade:

```sh
curl -fsSL https://raw.githubusercontent.com/craftogrammer/firstlaw/main/install.sh | bash -s -- --force
```

Then `follow CONSTITUTION.md`. The next cold-read runs `check-setup`, which auto-heals drift between the old kit state and the new (stale contract layers, missing skill-bridge, unwired pre-commit, absent `last-check.log`). Heals commit atomically if your tree is clean; otherwise they land on disk with review instructions.

## When not to use this kit

- If nobody is going to populate the contracts with project-specific patterns — mechanical enforcement stays empty and the kit is prose-only.
- If your project has no architectural decisions that survive longer than a sprint — the overhead of contracts + charters + amendment log exceeds the drift they prevent.
- If you are solo on a small codebase and comfortable reasoning about the whole thing in your head — the kit is built for the scale where drift bites, not where it doesn't yet.
- If your agent of choice ignores its own instruction files (CLAUDE.md / AGENTS.md / equivalent) — the kit relies on the adapter-patching mechanism to route agents back to CONSTITUTION.md.

## Scope honesty

This is v1.5.1 as of 2026-04-19. One live deployment so far. Five independent red-team probes found real load-bearing bugs across v1.2→v1.5; each became a fix in the next release. A complex game-engine probe partially reported; the rest is pending.

Expect to iterate on 3–5 files after first real adoption reveals gaps in your stack's write-site patterns or your project's specific ambiguity classes. Contribute back patterns that recur across projects; resist turning the kit into a framework that knows about your ORM.

## Versioning

`KIT_VERSION` at repo root tracks the installed kit version. Versions are single-string (`1.5.1`). The CONSTITUTION.md amendment log records every release with a one-line summary of what changed. No semver enforcement yet — minor bumps may include regression-fix commits that break nothing, or small schema additions that are backwards-compatible.

## License and contributing

See the repository for license terms. Contributions welcome via pull request; every PR touching `.law/contracts/` or `CONSTITUTION.md` must include a matching amendment-log row per §9.
