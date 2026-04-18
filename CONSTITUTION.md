# CONSTITUTION

<!--
COLD-READ PROTOCOL — FOLLOW ON FIRST CONTACT IN EVERY SESSION

Execute the sequence below as a single continuous action. Do not end your turn between steps. Do not summarize-and-ask. Do not hand control back until the sequence finishes or a defined blocker fires.

1. Follow this file in full.
2. Follow `.law/KIT_INDEX.md`.
3. Follow `.law/contracts/project.contract.json` and branch on `status`:
   - `skeleton` or `bootstrapping` → follow `.law/bootstrap/INIT.md` and execute that protocol. The cold-read continues *into* the bootstrap protocol; it does not pause here.
   - `active` → consult the contracts, doctrine, and charters relevant to the current task. Do not read everything.
4. Consult `.law/context/current-system.json` if present.
5. Consult `.law/context/pending-questions.json`. If `.law/context/last-check.log` exists, consult it too.
6. Run `.law/bin/check-setup`. It self-heals remediable kit-version drift (stale contract layers, missing skill bridge, unwired pre-commit hook, absent `last-check.log`) and commits each heal with a matching row in the Amendment log at the bottom of this file. Irreducible surfaces (empty `coupled_paths` with source code present, blocking pending questions, unresolved contradictions, `KIT_VERSION` drift) halt the cold-read and report them. Non-zero exit = halt.
7. Run `.law/bin/verify-adapters`, `.law/bin/validate-contracts`, `.law/bin/check-coupling`, and `.law/bin/check-counts`. Non-zero exit from any = halt and report the failures to the user before acting on the task. If the shell is unavailable, skip and note it.

The turn ends only when one of these fires:

- All seven steps complete in operate mode, and the agent is ready to act on the user's original request.
- A blocking elicitation question defined by the bootstrap protocol is reached (identity, anti-goals, mode confirmation, or an irresolvable discovery gap).
- The quality-audit acknowledgement gate or the 60-minute overrun checkpoint fires (defined in `.law/bootstrap/INIT.md`).
- One of the kit integrity scripts in step 6 or step 7 returned non-zero.

The following are **violations**, not legitimate turn boundaries:

- "I've read CONSTITUTION.md. Want me to read `KIT_INDEX.md` next?"
- "Status is skeleton. Should I open `INIT.md`?"
- "Here's what I found so far — should I proceed?"
- "check-setup reported 2 heals, want me to commit them?" — the script already committed them when the tree was clean, or printed review instructions when dirty. Asking the question means you did not read its output.

Catch the impulse, delete the question, continue reading.

Steps 1–3 are non-negotiable.
-->

This document tops the project's truth hierarchy. Everything else — code, contracts, doctrine, charters, plans, tool configs, adapter files — remains subordinate to it. Every agent follows this file as the first action in any session on this repo.

---

## 0. Status

- **Project name:** *(see `.law/contracts/project.contract.json#identity.name`)*
- **Mode:** *(see `.law/contracts/project.contract.json#mode`)* — one of `greenfield`, `greenfield-from-empty`, `brownfield`
- **Constitution version:** 4
- **Kit version:** *(see `KIT_VERSION` at repo root)*
- **Last amended:** 2026-04-19
- **Amendment authority:** *(a named human or role in the project)*

An **amendment** is any change to this file or to any contract under `.law/contracts/`. Commit amendments together with the change that motivated them, and log them at the bottom of this file.

---

## 1. Precedence

Highest to lowest authority:

1. **`CONSTITUTION.md`** — this file. Highest law.
2. **`.law/contracts/*.contract.json`** — compiled machine-readable law. Schema-validated. Fields here bind all code and all subordinate docs.
3. **`.law/doctrine/*.md`** and **`.law/charters/*.md`** — elaboration. May not contradict the constitution or contracts.
4. **`.law/context/*`** — non-authoritative snapshots, research logs, audit trails. Regenerable. Never treated as truth.
5. **Tool-facing adapter files** (`CLAUDE.md`, `AGENTS.md`, `codex.md`, `.cursorrules`, etc.) patched by the kit — non-authoritative projections only.

On any conflict, the higher layer wins. An agent that notices a lower layer contradicting a higher layer must halt and either amend the lower layer or flag the higher layer for amendment — never resolve both silently.

**Runtime truth** (the actual state of the running system) counts as evidence and must be reconciled explicitly with the layers above. It is not a layer in the precedence chain; it is the territory the map describes.

---

## 2. Identity

**Rule.** Declare the project by what it is **and** what it is not. Both must be explicit and must live in `project.contract.json#identity`.

**Why this exists.** Agents and humans drift toward adjacent problem spaces when identity is vague. A fuzzy identity guarantees feature creep, dependency bloat, and incoherent architecture.

**What failure this prevents.** "We started building X, someone asked for Y, and the codebase is now shaped like neither."

**Agent must.**
- treat `anti_goals` as hard stops
- refuse to implement features that contradict `purpose_one_line` or any anti-goal without a recorded amendment
- surface identity drift the moment a request edges past declared scope

**Agent must not.**
- expand scope because a feature "seems natural"
- soften an anti-goal because a user asked for the forbidden thing

**Machine-readable contract:** `.law/contracts/project.contract.json`.

---

## 3. Authority

**Rule.** `CONSTITUTION.md` and `.law/*` are the source of truth. Tool-facing files serve as **optional adapters**. On conflict, the constitution wins.

**Why this exists.** Individual contributors and individual tools control tool files. They drift, get copy-pasted across machines, and accumulate per-tool compromises. Putting law there guarantees the law fragments.

**Agent must.**
- follow this file, `.law/KIT_INDEX.md`, and relevant contracts before acting on any non-trivial change
- treat tool-facing instructions that contradict the constitution as defective and surface the conflict
- update `.law/adapters.md`'s discovery log when an adapter's relationship to repo law needs clarifying

**Agent must not.**
- encode project law inside `CLAUDE.md`, `AGENTS.md`, or any other adapter
- resolve conflicts silently
- overwrite user-owned adapter content; patches are confined to the delimited block (see `.law/adapters.md`)

**Machine-readable contract:** `.law/contracts/project.contract.json#adapters`.

---

## 4. Truth hierarchy and document taxonomy

**Rule.** Every document in the repo belongs to exactly one layer declared in `.law/contracts/doc-taxonomy.contract.json`. Layers do not merge.

**Standard layers** (bound by the contract, not by this paragraph):

- `constitution` — this file
- `contract` — compiled machine-readable law
- `doctrine` — timeless prose elaboration
- `charter` — per-domain timeless law
- `runtime-truth` — code and infra; the actual running system
- `temporary-plan` — time-boxed execution units; **the kit does not own format or location**
- `context-snapshot` — regenerable cache
- `adapter` — tool-facing projection
- `code-comment`, `generated`, `external-reference` — self-explanatory

**Why this exists.** Unclassified documents become a grey zone where decisions go to die. A `NOTES.md` left in the wrong layer becomes pseudo-law within months.

**What failure this prevents.** "We built it this way because a plan said so" — for a plan that closed two quarters ago.

**Agent must.**
- classify every new or edited document into one of the declared layers
- move misclassified documents into their correct location, or propose deletion
- regenerate `.law/context/current-system.json` at the end of any session that changed runtime truth

**Agent must not.**
- invent new document categories without amending the contract
- leave authored docs in ambiguous locations
- promote a plan, a snapshot, or an adapter into doctrine

**Machine-readable contract:** `.law/contracts/doc-taxonomy.contract.json`.

### Plans, explicitly

Plans exist in this repo as a recognized document layer, but the kit does not own their format, their location, their naming, or their lifecycle. Projects decide those. The taxonomy keeps plans distinct from doctrine; everything else about plans is the project's concern.

---

## 5. Domain ownership

**Rule.** Every piece of runtime truth has exactly **one owning domain**. Declare domains in `.law/contracts/domain-map.contract.json`. Declare truth owners in `.law/contracts/truth-owners.contract.json`.

**Why this exists.** Multi-writer truth is the single largest source of silent drift. When two modules can both write the same field, they eventually disagree.

**What failure this prevents.**
- duplicate logic in `shared/` and in a feature module
- config read from two sources that silently diverge
- a field written by three services with different validation rules

**Agent must.**
- consult `truth-owners.contract.json` for the owning domain before mutating any field, table, or config
- refuse to introduce a second writer for an owned truth
- register new truth in `truth-owners.contract.json` in the same change that introduces it

**Agent must not.**
- route new logic into generic containers (`shared/`, `common/`, `utils/`, `lib/`, `manager/`, `service/`, `helpers/`, `core/`, `misc/`) unless that container has an explicit entry in `domain-map.contract.json` with a charter
- use a utility folder as an escape hatch when the real owner is unclear — surface the ambiguity instead (Article 7)

**Machine-readable contracts:** `.law/contracts/domain-map.contract.json`, `.law/contracts/truth-owners.contract.json`.

---

## 6. Dependency law

**Rule.** Only dependency edges declared in `.law/contracts/dependency-rules.contract.json` are permitted between domains. The default stance is deny.

**Why this exists.** Unconstrained dependencies produce cycles, hidden coupling, and architectures that cannot be reasoned about locally.

**What failure this prevents.** A "small import" that introduces a circular dependency through three files; a presentation-layer module reaching into persistence directly.

**Agent must.**
- consult `dependency-rules.contract.json` before adding any cross-domain import
- halt and escalate on any attempt to introduce a forbidden edge
- on discovering a forbidden edge already in the codebase, record it in `.law/context/current-system.json#contradiction_map` and raise it — never silently extend it

**Agent must not.**
- add an edge to `allowed` just to unblock a task
- route around a forbidden edge via re-exports, facades, or event buses (structural intent matters, not syntactic shape)

**Machine-readable contract:** `.law/contracts/dependency-rules.contract.json`.

---

## 7. Ambiguity protocol

**Rule.** Ambiguity is a hard signal. Never resolve it silently. The resolution mechanism lives in `.law/contracts/ambiguity-policies.contract.json`.

**Ambiguity classes include.**
- two things doing one job under different names
- the same setting declared in two places
- unclear ownership of a field, table, or responsibility
- rule softness (`usually`, `normally`, `should` without enforcement)
- runtime behavior that contradicts documented behavior

**Why this exists.** Agents told to "just pick" pick with the bias of their training data, not the project's intent. Humans tired of ambiguity paper over it with comments.

**What failure this prevents.** Two parallel logic paths that both "work" until they disagree and nobody can say which is correct.

**Agent must.**
- halt on encountering any ambiguity class
- record the ambiguity in `.law/context/current-system.json#contradiction_map`
- apply the matching policy from `ambiguity-policies.contract.json` — never invent a resolution
- apply `rules.default_action_when_no_policy_matches` when no matching policy exists

**Agent must not.**
- resolve ambiguity by preferring older or newer code
- wrap the ambiguity in an abstraction to hide it

**Machine-readable contract:** `.law/contracts/ambiguity-policies.contract.json`.

---

## 8. Operating modes

**Rule.** The project operates in exactly one mode, declared in `project.contract.json#mode`:

- **`greenfield`** — the project has a scaffold (manifest, lockfile, or equivalent) but little or no feature code. Define identity, domains, truth ownership, and dependency rules before feature code.
- **`greenfield-from-empty`** — no scaffold exists. The project defines everything from zero. This is a first-class mode; the kit does not halt on an empty folder.
- **`brownfield`** — existing non-trivial codebase. Discovery is mandatory. Populate contracts from evidence, not wishful thinking. Produce a contradiction map.

**Why this exists.** Dropping a constitution into an existing messy repo without discovery produces fiction (contracts that describe what someone wishes were true) or paralysis (nothing matches the rules). Halting on an empty folder punishes the canonical install-then-define flow.

**Agent must (greenfield / greenfield-from-empty).**
1. Fill `project.contract.json#identity` — name, purpose, primary users, success criteria, anti-goals.
2. Fill `domain-map.contract.json#domains` — domains and boundaries (may be a single domain at the start).
3. Fill `truth-owners.contract.json#truths` — who writes what (may be empty at the start; populated as truth appears).
4. Fill `dependency-rules.contract.json#allowed` — allowed edges.
5. Classify any existing docs per `doc-taxonomy.contract.json`.
6. Patch any discovered adapter files non-destructively.
7. Only then begin feature code.

**Agent must (brownfield).**
1. Run discovery: enumerate existing domains, truth owners, and dependency edges from the code as it actually is.
2. Label every discovered item as `evidence` (observed in the code) or `judgment` (inferred).
3. Produce the contradiction map in `.law/context/current-system.json`.
4. Populate contracts only from evidence; mark inferred entries explicitly.
5. Ship stabilization work through project-owned plans; the kit does not own plan format.
6. Only then resume feature code.

**Agent must not.**
- declare greenfield mode in a repo that already has non-trivial runtime truth
- ship feature code in brownfield mode while the contradiction map is empty (unless a human explicitly confirms empty after discovery)

### Mechanical vs judgment over the project lifecycle

Mechanical enforcement scales with contract population. A day-zero project has empty `write_patterns`, empty `forbidden_patterns`, sparse `dependency-rules.allowed`, and few declared truths — the new `.law/bin/check-truth-ownership`, `check-anti-patterns`, and `check-coupling` scripts all exit 0 silently because they have nothing to enforce against. This is not a bug. The judgment skills (`halting-on-ambiguity`, `refusing-anti-goal-creep`, `resolving-layer-conflicts`, `grounding-with-dated-research`, `running-brownfield-discovery`) carry the agent through the early phase where the shape is still forming.

As the project matures, agents MUST populate contract pattern fields as they declare each truth, anti-goal, and domain (per `maintaining-mechanical-enforcement`). Each commit that declares a new truth must include matching `write_patterns`; each anti-goal that is keyword-detectable must include `forbidden_patterns`; each stack change must audit and update existing patterns. Mechanical coverage grows one commit at a time.

**Expect the judgment-to-mechanical ratio to invert as the project matures.** Day zero: judgment carries 90% of the discipline, mechanics 10%. Year later (mature shape): mechanics catch 80% at pre-commit, judgment fires only on genuine ambiguity. The kit supports both phases without mode-switching — the same scripts and skills apply at every maturity.

---

## 9. Mutation rules

**Rule.** Any change that affects repo law must update the corresponding contract in the same change.

| Change | Contract to update |
|---|---|
| New or renamed domain | `domain-map.contract.json`; create `.law/charters/<domain>.md` |
| New runtime truth | `truth-owners.contract.json` |
| Changed ownership of existing truth | `truth-owners.contract.json` (with amendment note) |
| New allowed or forbidden dependency edge | `dependency-rules.contract.json` |
| New ambiguity policy or changed default action | `ambiguity-policies.contract.json` |
| New doc layer or changed layer rules | `doc-taxonomy.contract.json` |
| New dependency quality finding or acknowledgement | `quality-audit.contract.json` |
| Any change to identity, mode, pointers, stack, or anti-goals | `project.contract.json` and this file |
| Changed runtime-specific load model or discovery path | `agent-runtime.contract.json` (with retrieval date) |
| New or changed write-site pattern, forbidden-pattern, or anti-pattern | relevant contract's `write_patterns` / `forbidden_patterns` / `anti_patterns` field (same commit) |

Every contract stamps `last_validated_at` on touch and updates `generated_from.run_at` when a subagent re-derives it.

**Why this exists.** Code and law diverge fast unless updates stay atomic.

**What failure this prevents.** "The docs say X, the code does Y, nobody knows which is right."

**Agent must** co-locate law updates with the code change that triggered them.

**Agent must not** defer contract updates — in practice, "later" never arrives.

---

## 10. Agent failure model

Agents (and tired humans) fail in specific, repeated ways. This constitution expects those failures and demands compensation. Consult `.law/doctrine/agent-behavior.md` for the full table. The ones that bite most:

- **Overfitting to familiar patterns** — consult `domain-map.contract.json` and live research; match the repo, not the training set.
- **Inventing certainty** — label evidence vs judgment; never fill a gap with a plausible guess.
- **Under-deleting** — when truth is duplicated, delete. Coexistence defers the decision.
- **Creating parallel logic paths** — when new code does what existing code does, something is wrong.
- **Softening rules to fit the current mess** — update the mess or amend the rule; never do both silently.
- **Treating current code as intended architecture** — code is evidence; doctrine and contracts declare intent.
- **Skipping research** — on architecture, library, and dep-quality claims, live web research with retrieval dates is required; training-only claims are rejected.
- **Writing long-lived decisions into plans** — plans are temporary; durable decisions belong in doctrine and charters.
- **Overwriting user-owned adapter content** — patch adapters non-destructively inside the delimited block; user content outside is inviolate.

---

## 11. Enforcement

**Rule.** Correct violations at the point of discovery. "We'll fix it later" is not an acceptable response.

**In practice.**

- A forbidden dependency edge discovered mid-task blocks the task until resolved (removal, amendment, or raised block).
- A duplicated truth owner discovered mid-task blocks the task.
- A stale doctrine entry discovered mid-task gets amended or gets marked stale with a dated note.
- A misclassified document discovered mid-task gets reclassified and moved per `doc-taxonomy.contract.json`.
- Kit-version drift discovered at cold-read auto-heals via `.law/bin/check-setup`. Drift the script cannot heal (ambiguity, missing user decisions, empty `enforcement.coupled_paths` with source code present) blocks the session.

**Agent must** surface violations loudly. Block, escalate, record.

**Agent must not** proceed past a violation with a `TODO` comment.

### Quality-audit findings (exception)

Quality-audit findings (in `.law/contracts/quality-audit.contract.json`) are **advisory**. Critical findings require acknowledgement but never halt bootstrap or operate mode. This exception is narrow and deliberate: the kit must be adoptable in exactly the messy repos that most need it.

---

## 12. What this kit enforces vs what the project owns

Firstlaw enforces properties of itself, not properties of your code. Keep the distinction explicit — conflating them invites silent drift.

**Kit-enforced.** Five small programs in `.law/bin/`, composed however you want (git hooks, CI, shell pipelines, test runner, Makefile — the kit has no opinion):

- `check-setup` — self-heals remediable kit-version drift on cold-read (stale contract layers, missing skill bridge, unwired pre-commit hook, absent `last-check.log`). Idempotent. Auto-commits heals when the working tree is clean; otherwise prints review instructions and skips commit. Surfaces irreducible blockers. Runs first in the cold-read script sequence.
- `verify-adapters` — every adapter file listed in `project.contract.json#adapters.patched_files` still contains its `BEGIN/END .law/CONSTITUTION-FIRST` delimiter pair.
- `validate-contracts` — every `.law/contracts/*.contract.json` validates against its declared `$schema`. Uses `check-jsonschema` if installed, otherwise `ajv + ajv-formats` if globally installed, otherwise falls back to `npx ajv-cli` with `ajv-formats` pulled in automatically. Fails closed only if none are available.
- `check-anti-patterns` — walks source files for matches against `project.contract.json#identity.anti_goals[].forbidden_patterns` and `#enforcement.anti_patterns[]`. Error-severity matches fail; warnings printed. Empty = no-op.
- `check-coupling` — walks source-tree imports across domains declared in `domain-map.contract.json`; fails any edge not in `dependency-rules.contract.json#allowed` (default deny). Starter languages: TypeScript, JavaScript, Python. Adapts per project.
- `check-amendment-coupling` — flags source-tree changes lacking a matching `.law/contracts/*` amendment when `project.contract.json#enforcement.coupled_paths` is populated. Opt-in; empty globs list = no-op.
- `check-counts` — verifies declared counts in `.law/context/current-system.json` match reality: `summary.open_blockers_count` against blocking entries in pending-questions, prose `"N open contradictions"` against unresolved entries in `contradiction_map`.
- `check-skill-voice` — validates every `.law/skills/*/SKILL.md` and `.claude/skills/*/SKILL.md` against kit-owned voice rules (frontmatter shape, forbidden softening verbs, § citation, required sections). Universal check.
- `check-truth-ownership` — walks source files for matches against `truth-owners.contract.json#truths[].write_patterns`. Any match outside the truth's owner domain fails. Empty patterns = no-op.

These parts of repo law do not depend on project semantics for enforcement. The kit owns them end to end.

**Project-owned.** Three starter examples in `.law/templates/`; the project copies, adapts, and owns the result:

- Truth-owner writer enforcement (storage semantics differ per stack).
- Cross-domain import enforcement (layer classifier is project-specific).
- Anti-pattern gates: file-size caps, forbidden patterns, generic-folder charter check (thresholds and patterns are doctrine choices).

If your project has no code enforcing a contract, that contract remains prose until you write the gate. The kit declares; your repo enforces. Don't confuse the layers.

**Escape hatches.** Every check is a single program with a Unix exit code. Bypass with `|| true`, `--no-verify`, or not running it. No `SKIP_*` environment convention exists, because no dispatcher exists to convention over. Agents must not bypass without surfacing the reason to the user.

---

## 13. What this constitution is not

- not a style guide
- not a linter configuration
- not a framework opinion
- not a replacement for tool-facing files; those remain useful adapters (consult `.law/adapters.md`)
- not a plan or roadmap owner; projects own those
- not a substitute for human judgment — it is the frame inside which judgment operates

---

## Amendment log

| Date | Amendment | Author |
|---|---|---|
| *(YYYY-MM-DD)* | Initial adoption. | *(n)* |
| 2026-04-18 | Added `skill` layer to doc-taxonomy contract and schema. | Coordinator batch (elegant-discovering-gizmo) |
| 2026-04-18 | Added `.law/bin/check-setup` self-heal on cold-read; bumped cold-read protocol to run it first (new step 6), moved kit-integrity checks to step 7; bumped Constitution version to 2. | firstlaw v1.3 |
| 2026-04-19 | v1.4: real cross-domain import checker; old coupling script renamed to `check-amendment-coupling`; brownfield self-heal pass-with-warning for plan-backed contradictions; `validate-contracts` Windows Cygwin fix via Python polyglot; new contracts `agent-runtime.contract.json` + schema; new schema `current-system.schema.json`; ambiguity-policies +3 (design-fork, multi-candidate-owner, shadow-reader); dep-edge skill +5 rationalizations; authoring-project-skills refresh; `.gitattributes` shipped; check-setup output attribution + disposition + reload hint; INIT §5.1 degraded/headless mode; Constitution version bumped to 3. | firstlaw v1.4 |
| 2026-04-19 | v1.5: parameterized mechanical enforcement (check-truth-ownership, check-anti-patterns, check-skill-voice); extended check-setup (unclassified-doc surface + EXPECTED_KIT_VERSION regression fix); extended check-counts (amendment-log reconciliation); fixed validate-contracts silent-fail regression from v1.4; updated pre-commit.sample to wire all enforcement scripts; schema additions for write_patterns / forbidden_patterns / anti_patterns; fixed stale coupled_paths description; new workflow skill maintaining-mechanical-enforcement; merged surfacing-forbidden-edges into checking-dep-edges-before-importing; slimmed using-firstlaw and authoring-project-skills; extracted skill-template.md; §8 maturity-curve subsection added; Constitution version bumped to 4. | firstlaw v1.5 |
| 2026-04-19 | v1.5.1: skill-voice cleanup surfaced by new `check-skill-voice` — fenced CONSTITUTION violation quotes in `cold-reading-the-repo`; changed `using-firstlaw` and `cold-reading-the-repo` descriptions to start with `Use when`; replaced inline softening-verb enumerations in `authoring-project-skills` with pointer to `.law/bin/check-skill-voice`; trimmed `checking-dep-edges-before-importing` frontmatter to ≤1024 chars. | firstlaw v1.5.1 |

> Record every subsequent amendment with a row here. An amendment without a row is unrecorded and, by Article 9, did not happen.
