# CONSTITUTION

<!--
COLD-READ INSTRUCTIONS FOR ANY AGENT

If you are an agent reading this file for the first time in a session, execute the entire sequence below as a single continuous action. Do not end your turn between steps. Do not summarize-and-ask. Do not hand control back to the user until the sequence finishes or a defined blocker fires.

1. Read this file in full.
2. Read `.law/KIT_INDEX.md`.
3. Read `.law/contracts/project.contract.json` and branch on `status`:
   - `skeleton` or `bootstrapping` → read `.law/bootstrap/INIT.md` and execute that protocol. The cold-read continues *into* the bootstrap protocol — it does not pause here.
   - `active` → read the contracts, doctrine, and charters relevant to the current task. Do not read everything.
4. Read `.law/context/current-system.json` if present.
5. Read `.law/context/pending-questions.json`. If `.law/context/last-check.log` exists, read it too.
6. Run `.law/bin/verify-adapters`, `.law/bin/validate-contracts`, and `.law/bin/check-counts`. Non-zero exit from any = halt and report the failures to the user before acting on the task. If the shell is unavailable, skip and note it.

The turn ends only when one of these fires:

- All six steps complete in OPERATE mode, and the agent is ready to act on the user's original request.
- A blocking elicitation question defined by the bootstrap protocol is reached (identity, anti-goals, mode confirmation, or an irresolvable discovery gap).
- The quality-audit acknowledgement gate or the 60-minute overrun checkpoint fires (defined in `.law/bootstrap/INIT.md`).
- A kit integrity script in step 6 returned non-zero.

The following are **violations**, not legitimate turn boundaries:

- "I've read CONSTITUTION.md. Want me to read `KIT_INDEX.md` next?"
- "Status is skeleton. Should I open `INIT.md`?"
- "Here's what I found so far — should I proceed?"

If you catch yourself about to write any of those, delete the question and continue reading.

Steps 1–3 are non-negotiable.
-->

This document is the top of this project's truth hierarchy. Everything else — code, contracts, doctrine, charters, plans, tool configs, adapter files — is subordinate to it. Reading this file is the first action an agent takes in any session on this repo.

---

## 0. Status

- **Project name:** *(see `.law/contracts/project.contract.json#identity.name`)*
- **Mode:** *(see `.law/contracts/project.contract.json#mode`)* — one of `greenfield`, `greenfield-from-empty`, `brownfield`
- **Constitution version:** 1
- **Kit version:** *(see `KIT_VERSION` at repo root)*
- **Last amended:** *(date the most recent Amendment log entry below)*
- **Amendment authority:** *(a named human or role in the project)*

An **amendment** is any change to this file or to any contract under `.law/contracts/`. Amendments are committed together with the change that motivated them and logged at the bottom of this file.

---

## 1. Precedence

Highest to lowest authority:

1. **`CONSTITUTION.md`** — this file. Highest law.
2. **`.law/contracts/*.contract.json`** — compiled machine-readable law. Schema-validated. Fields here bind all code and all subordinate docs.
3. **`.law/doctrine/*.md`** and **`.law/charters/*.md`** — elaboration. May not contradict the constitution or contracts.
4. **`.law/context/*`** — non-authoritative snapshots, research logs, audit trails. Regenerable. Never treated as truth.
5. **Tool-facing adapter files** (`CLAUDE.md`, `AGENTS.md`, `codex.md`, `.cursorrules`, etc.) patched by the kit — non-authoritative projections only.

On any conflict, the higher layer wins. An agent that notices a lower layer contradicting a higher layer must halt and either amend the lower layer or flag the higher layer for amendment — never both silently.

**Runtime truth** (the actual state of the running system) is always treated as evidence and must be reconciled explicitly with the layers above. It is not a layer in the precedence chain; it is the territory the map describes.

---

## 2. Identity

**Rule.** The project is defined by what it is **and** what it is not. Both must be explicit and must live in `project.contract.json#identity`.

**Why this exists.** Agents and humans drift toward adjacent problem spaces when identity is vague. A fuzzy identity guarantees feature creep, dependency bloat, and incoherent architecture.

**What failure this prevents.** "We started building X, someone asked for Y, and now the codebase is shaped like neither."

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

**Rule.** `CONSTITUTION.md` and `.law/*` are the source of truth. Tool-facing files are **optional adapters**. On conflict, the constitution wins.

**Why this exists.** Tool files are controlled by individual contributors and individual tools. They drift, get copy-pasted across machines, and accumulate per-tool compromises. Putting law there guarantees the law fragments.

**Agent must.**
- read this file, `.law/KIT_INDEX.md`, and relevant contracts before acting on any non-trivial change
- treat tool-facing instructions that contradict the constitution as defective and surface the conflict
- update `.law/adapters.md`'s discovery log if an adapter's relationship to repo law needs clarifying

**Agent must not.**
- encode project law inside `CLAUDE.md`, `AGENTS.md`, or any other adapter
- resolve conflicts silently
- overwrite user-owned adapter content; patches are confined to the delimited block (see `.law/adapters.md`)

**Machine-readable contract:** `.law/contracts/project.contract.json#adapters`.

---

## 4. Truth hierarchy and document taxonomy

**Rule.** Every document in the repo belongs to exactly one layer defined in `.law/contracts/doc-taxonomy.contract.json`. Layers do not merge.

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
- classify any new or edited document into one of the declared layers
- move misclassified documents into their correct location, or propose deletion
- regenerate `.law/context/current-system.json` at the end of any session that changed runtime truth

**Agent must not.**
- invent new document categories without amending the contract
- leave authored docs in ambiguous locations
- upgrade a plan, a snapshot, or an adapter into doctrine

**Machine-readable contract:** `.law/contracts/doc-taxonomy.contract.json`.

### Plans, explicitly

Plans exist in this repo as a recognized document layer, but the kit does not own their format, their location, their naming, or their lifecycle. Projects decide those. The taxonomy ensures plans are not mistaken for doctrine; everything else about plans is the project's concern.

---

## 5. Domain ownership

**Rule.** Every piece of runtime truth has exactly **one owning domain**. Domains are declared in `.law/contracts/domain-map.contract.json`. Truth owners are declared in `.law/contracts/truth-owners.contract.json`.

**Why this exists.** Multi-writer truth is the single largest source of silent drift. When two modules can both write the same field, they will eventually disagree.

**What failure this prevents.**
- duplicate logic in `shared/` and in a feature module
- config read from two sources that silently diverge
- a field written by three services with different validation rules

**Agent must.**
- look up the owning domain in `truth-owners.contract.json` before mutating any field, table, or config
- refuse to introduce a second writer for an owned truth
- register new truth in `truth-owners.contract.json` in the same change that introduces it

**Agent must not.**
- route new logic into generic containers (`shared/`, `common/`, `utils/`, `lib/`, `manager/`, `service/`, `helpers/`, `core/`, `misc/`) unless that container has an explicit entry in `domain-map.contract.json` with a charter
- use a utility folder as an escape hatch when the real owner is unclear — surface the ambiguity instead (Article 7)

**Machine-readable contracts:** `.law/contracts/domain-map.contract.json`, `.law/contracts/truth-owners.contract.json`.

---

## 6. Dependency law

**Rule.** Only dependency edges declared in `.law/contracts/dependency-rules.contract.json` are allowed between domains. Default stance is deny.

**Why this exists.** Unconstrained dependencies produce cycles, hidden coupling, and architectures that cannot be reasoned about locally.

**What failure this prevents.** A "small import" that introduces a circular dependency through three files; a presentation-layer module reaching into persistence directly.

**Agent must.**
- consult `dependency-rules.contract.json` before adding any cross-domain import
- halt and escalate on any attempt to introduce a forbidden edge
- on discovering an existing forbidden edge already in the codebase, record it in `.law/context/current-system.json#contradiction_map` and raise it — do not silently extend it

**Agent must not.**
- add an edge to `allowed` just to unblock a task
- route around a forbidden edge via re-exports, facades, or event buses (structural intent matters, not syntactic shape)

**Machine-readable contract:** `.law/contracts/dependency-rules.contract.json`.

---

## 7. Ambiguity protocol

**Rule.** Ambiguity is a hard signal. It is never resolved silently. The resolution mechanism is declared in `.law/contracts/ambiguity-policies.contract.json`.

**Ambiguity classes include.**
- two things doing one job under different names
- the same setting declared in two places
- unclear ownership of a field, table, or responsibility
- rule softness (`usually`, `normally`, `should` without enforcement)
- runtime behavior that contradicts documented behavior

**Why this exists.** Agents asked to "just pick" will pick consistently with the bias of their training data, not the project's intent. Humans tired of ambiguity paper over it with comments.

**What failure this prevents.** Two parallel logic paths that both "work" until one day they disagree and nobody can say which is correct.

**Agent must.**
- stop on encountering any ambiguity class
- record the ambiguity in `.law/context/current-system.json#contradiction_map`
- apply the matching policy from `ambiguity-policies.contract.json` — never invent a resolution
- if no matching policy exists, apply `rules.default_action_when_no_policy_matches`

**Agent must not.**
- resolve ambiguity by preferring the older or the newer code
- wrap the ambiguity in an abstraction to hide it

**Machine-readable contract:** `.law/contracts/ambiguity-policies.contract.json`.

---

## 8. Operating modes

**Rule.** The project operates in exactly one mode, declared in `project.contract.json#mode`:

- **`greenfield`** — the project has a scaffold (manifest, lockfile, or equivalent) but little or no feature code. Identity, domains, truth ownership, and dependency rules are defined before feature code.
- **`greenfield-from-empty`** — no scaffold exists at all. The project defines everything from zero. This is a first-class mode; the kit does not halt because the folder is empty.
- **`brownfield`** — existing non-trivial codebase. Discovery is mandatory. Contracts are populated from evidence, not wishful thinking. A contradiction map is produced.

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
- ship feature code in brownfield mode while the contradiction map is empty (or explicitly confirmed empty by a human after discovery)

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

Every contract stamps `last_validated_at` when touched and updates `generated_from.run_at` when re-derived by a subagent.

**Why this exists.** Code and law diverge fast unless updates are atomic.

**What failure this prevents.** "The docs say X, the code does Y, nobody knows which is right."

**Agent must** co-locate law updates with the code change that triggered them.

**Agent must not** defer contract updates — in practice, "later" does not arrive.

---

## 10. Agent failure model

Agents (and tired humans) fail in specific, repeated ways. This constitution expects them and requires compensation. See `.law/doctrine/agent-behavior.md` for the full table. The ones that bite most:

- **Overfitting to familiar patterns** — consult `domain-map.contract.json` and live research; match the repo, not the training set.
- **Inventing certainty** — label evidence vs judgment; never fill a gap with a plausible guess.
- **Under-deleting** — when truth is duplicated, delete. Coexistence is a deferred decision.
- **Creating parallel logic paths** — if new code does what existing code does, something is wrong.
- **Softening rules to fit the current mess** — update the mess or amend the rule; never both silently.
- **Treating current code as intended architecture** — code is evidence; doctrine and contracts are intent.
- **Skipping research** — on architecture, library, and dep-quality claims, live web research with retrieval dates is required; training-only claims are rejected.
- **Writing long-lived decisions into plans** — plans are temporary; doctrine and charters are where durable decisions live.
- **Overwriting user-owned adapter content** — adapters are patched non-destructively inside a delimited block; user content outside is inviolate.

---

## 11. Enforcement

**Rule.** Violations are corrected at the point of discovery. "We'll fix it later" is not an acceptable response.

**In practice.**

- A forbidden dependency edge discovered mid-task blocks the task until resolved (removal, amendment, or raised block).
- A duplicated truth owner discovered mid-task blocks the task.
- A stale doctrine entry discovered mid-task gets amended or gets marked stale with a dated note.
- A misclassified document discovered mid-task gets reclassified and moved per `doc-taxonomy.contract.json`.

**Agent must** surface violations loudly. Block, escalate, record.

**Agent must not** proceed past a violation with a `TODO` comment.

### Quality-audit findings (exception)

Quality-audit findings (in `.law/contracts/quality-audit.contract.json`) are **advisory**. Critical findings require acknowledgement but never halt bootstrap or operate mode. This exception is narrow and deliberate: the kit must be adoptable in exactly the messy repos that most need it.

---

## 12. What this kit enforces vs what the project owns

Firstlaw enforces properties of itself, not properties of your code. Be clear about which is which — conflating them invites silent drift.

**Kit-enforced.** Three small programs in `.law/bin/`, composed however you want (git hooks, CI, shell pipelines, test runner, Makefile — the kit has no opinion):

- `verify-adapters` — every adapter file listed in `project.contract.json#adapters.patched_files` still contains its `BEGIN/END .law/CONSTITUTION-FIRST` delimiter pair.
- `validate-contracts` — every `.law/contracts/*.contract.json` validates against its declared `$schema`. Uses `check-jsonschema` if installed, otherwise `ajv + ajv-formats` if globally installed, otherwise falls back to `npx ajv-cli` with `ajv-formats` pulled in automatically. Fails closed only if none are available.
- `check-coupling` — if a diff touches paths declared in `project.contract.json#enforcement.coupled_paths` without touching any file under `.law/contracts/`, flags the coupling violation. Opt-in; empty globs list = no-op.
- `check-counts` — verifies declared counts in `.law/context/current-system.json` match reality: `summary.open_blockers_count` against blocking entries in pending-questions, prose `"N open contradictions"` against unresolved entries in `contradiction_map`.

These are the parts of repo law whose enforcement does not depend on project semantics. The kit owns them end to end.

**Project-owned.** Three starter examples in `.law/templates/`; the project copies, adapts, and owns the result:

- Truth-owner writer enforcement (storage semantics differ per stack).
- Cross-domain import enforcement (layer classifier is project-specific).
- Anti-pattern gates: file-size caps, forbidden patterns, generic-folder charter check (thresholds and patterns are doctrine choices).

If your project has no code enforcing a contract, that contract is prose until you write the gate. The kit declares; your repo enforces. Don't confuse the layers.

**Escape hatches.** Every check is a single program with a Unix exit code. Bypass with `|| true`, `--no-verify`, or not running it. There is no `SKIP_*` environment convention, because there is no dispatcher to convention over. Agents: do not bypass without surfacing the reason to the user.

---

## 13. What this constitution is not

- not a style guide
- not a linter configuration
- not a framework opinion
- not a replacement for tool-facing files; those remain useful adapters (see `.law/adapters.md`)
- not a plan or roadmap owner; projects own those
- not a substitute for human judgment — it is the frame inside which judgment operates

---

## Amendment log

| Date | Amendment | Author |
|---|---|---|
| *(YYYY-MM-DD)* | Initial adoption. | *(n)* |

> Every subsequent amendment gets a row here. An amendment without a row is unrecorded and, by Article 9, did not happen.
