# Agent behavior doctrine

> **Layer:** doctrine · **Authority:** elaboration · **Mutability:** timeless until amended
> How any agent — and any tired human acting like an agent — must behave when working in this repo. Must not contradict the constitution or any contract.

## Session start

1. Read `CONSTITUTION.md`.
2. Read `.law/KIT_INDEX.md` for fast orientation.
3. Read `.law/contracts/project.contract.json` and check `status`.
   - `skeleton` or `bootstrapping` → enter **bootstrap mode** via `.law/bootstrap/INIT.md`.
   - `active` → enter **operate mode**.
4. Read `.law/context/current-system.json` if present.
5. Read the doctrine, charter, and contract files the task requires. Do not read everything; do not read nothing.

## Two-mode behavior

### Bootstrap mode

The repo's law is not yet defined. The agent runs `.law/bootstrap/INIT.md`, which orchestrates seven subagents (or their sequential equivalents, depending on environment capability). The agent's job: produce filled contracts grounded in real project evidence and live research, not training-era guesswork.

### Operate mode

Law is in place. The agent consults contracts before acting, refuses changes that would violate them, and proposes amendments when reality shifts.

## Evidence vs judgment

Every non-trivial claim an agent makes about the repo falls into one of two classes:

- **evidence** — directly observable in the code, in runtime state, in declared law, or in a contract
- **judgment** — inferred, interpreted, or assumed

Agents must label claims. Evidence is actionable. Judgment is a hypothesis and agents must treat it as such. Agents must never present judgment as evidence. Agents must never promote judgment to law without an amendment step.

The `evidence_or_judgment` field exists on many contract entries for this reason. Fill it honestly.

## Research freshness (hard rule)

Any claim about current community practice, state of the art, library state, or modern patterns must rest on live web research with retrieval dates. Training-only claims on these topics fail. This rule exists because the kit sets law; stale law is worse than no law.

Every subagent deposits its research log at `.law/context/research/<subagent>-<YYYY-MM-DD>.json`. The orchestrator never ingests raw logs; it ingests envelopes.

## Ambiguity is a halt, not a hint

Consult `.law/contracts/ambiguity-policies.contract.json`. On observing an ambiguity class:

1. stop the in-flight task
2. record the observation in `.law/context/current-system.json#contradiction_map`
3. apply the matching policy
4. if no policy matches, escalate

Agents must not resolve ambiguity by preference, by training bias, or by "this is how it's usually done."

## Known failure modes

Agents fail predictably. The constitution anticipates these modes and requires compensation.

| Failure mode | Required compensation |
|---|---|
| Overfitting to familiar patterns | Consult `domain-map.contract.json` and live research; match the repo, not the training set |
| Inventing certainty | Label evidence vs judgment; never fill a gap with a plausible guess |
| Preserving bad compatibility | Backward compatibility is a cost, not a principle; fix or delete |
| Under-deleting | When truth is duplicated, delete — coexistence is a deferred decision |
| Creating parallel logic paths | If new code does what existing code does, something is wrong |
| Patching locally instead of fixing ownership | A local patch bypassing the owner is a shadow write |
| Skipping research | Training-era patterns are not permitted as architectural law |
| Softening rules to fit the current mess | Update the mess or amend the rule — never both silently |
| Treating current code as intended architecture | Code is evidence; doctrine and contracts are intent |
| Auto-writing tool-facing adapter files | Adapters are user-owned; patching must be non-destructive with clear delimiters |
| Requiring user to cite law (article, policy, CM-ID) | Surface governing law unprompted — law is in the repo and the agent read it |
| Presenting cosmetic options as decisions | Options must have genuinely divergent consequences; if not, do the right thing and mention the alternative in passing |
| Asking performative questions | Every blocking question must change the agent's next action; if the user's answer doesn't change behavior, cut the question |
| Outsourcing scope discipline ("want to extend this?") | Cross-references to other tracked items are noted with a recommendation, not offered as user choices |

## Orchestration and context discipline

The orchestrator (main chat) delegates deep reads to subagents. The orchestrator never ingests raw research; only structured envelopes (`schemas/subagent-envelope.schema.json`). Not an optimization — this is how the orchestrator's context stays small enough to reason across all seven workstreams in one session.

If the environment cannot spawn subagents, the degraded mode in `INIT.md` applies: run phases sequentially in the main chat, and summarize each phase into an envelope before the next phase begins. The summary-to-envelope step is mandatory.

## Advisor capability

Some environments expose an "advisor" capability (for example, Anthropic's advisor tool, or a planner-model consult). When available, subagents may invoke it at two checkpoints: before committing their primary recommendation, and before finalizing their envelope. Cap: 2-3 advisor calls per subagent. Advisor failures (rate limit, unavailability) do not block — the subagent proceeds.

The kit hardcodes no specific advisor API. The abstraction: "consult a higher-tier reviewer with the current transcript, receive a short plan or correction."

## Session close

Before ending a session that changed runtime truth:

1. Update every contract the change affects, in the same commit.
2. Regenerate `.law/context/current-system.json`.
3. If the session closed a project-owned plan, follow the project's plan-closure process. The kit does not own plan lifecycle.

## Tool-facing adapter files

`CLAUDE.md`, `AGENTS.md`, `codex.md`, Cursor rules, and equivalents are **adapters**, not law. They project law without authority. On any conflict between an adapter and repo law, the constitution wins and the adapter is defective.

Agents never overwrite user-owned adapter content. Patches stay confined to a clearly delimited block. Consult `.law/adapters.md`.
