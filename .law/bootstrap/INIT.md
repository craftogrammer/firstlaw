# Bootstrap protocol (INIT.md)

> **Layer:** doctrine-adjacent · **Authority:** elaboration · **Mutability:** amendable
> The protocol any agent follows when `.law/contracts/project.contract.json#status` is `skeleton` or `bootstrapping`.

## Purpose

Produce filled, research-grounded contracts for this project. Target ceiling: 30 minutes. The ceiling is illustrative — the agent reports overrun and continues; it does not cut research to fit the clock. Correctness beats budget.

---

## 0. Preconditions

- The kit is installed: `CONSTITUTION.md` at repo root, `.law/` populated from the kit distribution.
- The agent has read `CONSTITUTION.md` and `.law/KIT_INDEX.md`.
- The agent has ability to: read files, run shell commands, perform live web research, and (if the environment supports it) spawn subagents and/or invoke an advisor capability.

Empty repos are valid. There is no scaffold precondition that halts bootstrap.

---

## 0.1 Autonomy rule

The agent executes this protocol end-to-end without asking the user for permission between phases, subagents, or file reads. User interaction is reserved for:

- **Blocking elicitation questions** declared by subagent contracts (identity, anti-goals, mode confirmation, discovery gaps the agent cannot resolve from code).
- **Critical quality-audit acknowledgement** (§8).
- **60-minute overrun checkpoint** (§10).
- **Advisor checkpoints** if an advisor capability is available (§4) — these are agent-to-advisor, not agent-to-user.

"Should I proceed to the next phase?" / "Should I run the next subagent?" / "Should I read the next file?" are not legitimate prompts in this protocol. Proceed.

The agent announces state transitions in one-line status messages (mode detected, execution mode chosen, phase starting, phase complete, bootstrap complete). It does not request approval to transition.

---

## 1. Mode detection (automatic, then confirm)

Signals to detect:

| Signal | What it implies |
|---|---|
| Any of: `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `pom.xml`, `build.gradle` | Stack is scaffolded |
| `.git/` with ≥1 commit | History exists |
| Non-trivial source tree under `src/`, `lib/`, `app/`, or language-conventional dirs | Real code exists |
| `README.md` with meaningful content (>200 chars, not boilerplate) | Some intent is documented |

Decide mode:

- **brownfield** — scaffolded AND non-trivial source tree AND (history OR meaningful README)
- **greenfield** — scaffolded but source tree is thin/empty (early project)
- **greenfield-from-empty** — no scaffold at all

Present the detected mode to the user with a one-line rationale. Confirm with interactive elicitation (blocking). Never halt because no scaffold exists; `greenfield-from-empty` is a valid mode.

Write the confirmed mode to `project.contract.json#mode`. Set `project.contract.json#status` to `bootstrapping`.

---

## 2. Execution mode matrix

Pick the execution mode based on environment capability, in this order of preference:

| Mode | When to use | Shape |
|---|---|---|
| **Preferred — subagents** | Environment can spawn isolated-context subagents (e.g. parallel agentic runs) | Orchestrator in main chat; each subagent runs in its own context; returns one envelope each; orchestrator merges. Optional advisor capability applied per subagent. |
| **Advisor-only** | Environment has no subagent capability but exposes an advisor (e.g. Anthropic advisor tool, `/advisor` in Claude Code) | One executor runs phases sequentially; consults advisor at each subagent's Checkpoint A and B. |
| **Degraded** | Environment has neither | Single agent runs phases sequentially in main chat; between phases, writes an envelope to `.law/context/research/` and clears the phase's raw research from its working set. The summary-to-envelope step is mandatory. |

The agent announces the chosen execution mode in a one-line message before proceeding.

---

## 3. Orchestration DAG

```
Phase 1:
   product

Phase 2 (parallel):
   architecture  |  ownership  |  ambiguity

Phase 3 (parallel):
   doc-taxonomy  |  adapter  |  quality-audit

Integration:
   orchestrator merges envelopes → commits contract patches
```

Each subagent reads its contract at `.law/subagents/<id>.contract.md`, constructs its own prompt, and returns one envelope matching `.law/schemas/subagent-envelope.schema.json`.

Subagents discover additional project-added subagent contracts in `.law/subagents/*.contract.md` and include them in the DAG at the position they declare.

---

## 4. Per-subagent advisor checkpoints

If advisor capability is available, every subagent observes two checkpoints from its own contract:

- **Checkpoint A**: before committing primary recommendation — advisor reviews draft decisions/patches.
- **Checkpoint B**: before finalizing envelope — advisor validates evidence/judgment labeling.

Cap per subagent: 2–3 calls (subagent's contract specifies). Rate limit or unavailability is non-blocking — subagent proceeds and records `advisor_calls_used` + failure notes in envelope.

---

## 5. Elicitation policy

Subagents ask questions via interactive elicitation. Every question is marked `blocking` or non-blocking.

- **Blocking**: halt until answered. Identity anti-goals in `greenfield-from-empty` mode are the canonical blockers.
- **Non-blocking**: if the user is unavailable, subagent accumulates the question in `.law/context/pending-questions.json` and proceeds with a labeled judgment entry.

Cross-cutting questions (identity + mode) live in `.law/bootstrap/questions/cross-cutting.json`. Subagent-specific questions are owned by each subagent — no central library for them.

---

## 6. Research audit trail

Every subagent deposits its research log at:

```
.law/context/research/<subagent-id>-<YYYY-MM-DD>.json
```

The log contains: all queries run, all URLs fetched, retrieval timestamps, raw excerpts. The orchestrator does **not** read research logs. It reads only envelopes. Logs are for later human or agent audit.

---

## 7. Merge and commit

Orchestrator receives envelopes. For each envelope:

1. Apply `proposed_contract_patches[]` in order.
2. If two envelopes touch the same field, reconcile:
   - Prefer evidence over judgment.
   - If both are evidence and differ, halt, surface in `pending-questions.json`.
   - If advisor capability is available, orchestrator may consult advisor on the reconciliation.
3. Append all `judgment[]` entries to `.law/context/current-system.json#judgment_log`.
4. Append all `questions_for_orchestrator[]` to `.law/context/pending-questions.json` or (for blocking) halt and surface.

When all phases complete and no blocking questions remain, flip `project.contract.json#status` to `active`. Stamp `last_validated_at` on every contract.

---

## 8. Quality-audit acknowledgement gate (advisory)

If `quality-audit.contract.json#findings` contains any `critical` severity entries:

- Present them to the user with evidence (URLs + retrieval dates).
- Request acknowledgement. Acknowledgement is recording-only; no action required.
- On acknowledgement, stamp `acknowledged`, `acknowledged_at`, `acknowledged_by`.

**Bootstrap completes regardless of acknowledgement state.** Quality audit is advisory; it never blocks adoption.

---

## 9. Completion checklist

Bootstrap is complete when all of the following are true:

- [ ] `project.contract.json#status` is `active`
- [ ] Every contract's `last_validated_at` is stamped
- [ ] Every contract's `generated_from.{subagent, run_at}` is stamped
- [ ] `.law/context/current-system.json` is regenerated
- [ ] `.law/context/pending-questions.json` has no `blocking: true` entries
- [ ] At least one charter exists per domain registered in `domain-map.contract.json`
- [ ] Quality-audit `critical` findings are acknowledged (if any)
- [ ] Adapter patches applied non-destructively (or deferred, recorded in pending-questions)

The agent reports completion with a one-paragraph summary and the path to `.law/context/current-system.json`.

---

## 10. Budget accounting

Target ceiling: 30 minutes wall-clock.

- If the agent projects to exceed 30 minutes, it emits a one-line notice with an ETA and continues.
- The agent does not cut research to fit the budget. Research freshness is a hard rule; the budget is a soft target.
- If wall-clock exceeds 60 minutes, the agent pauses and asks the user whether to continue, slim scope, or checkpoint for later resumption.

---

## 11. Resume semantics

If bootstrap was interrupted: read `project.contract.json#status`, `.law/context/pending-questions.json`, and each contract's `generated_from` fields. Resume from the last incomplete phase. Do not re-run completed subagents unless their inputs changed.
