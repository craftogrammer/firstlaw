# Subagents

> **Layer:** doctrine-adjacent · **Authority:** elaboration · **Mutability:** amendable

Each file `<name>.contract.md` in this folder declares the **role, goal, and output contract** of one subagent. The kit does not supply ready-to-use prompt text. Each run of the bootstrap protocol in `.law/bootstrap/INIT.md` writes its own prompts from these contracts, conditioned on the detected project.

## Why role/goal/output-only

Hardcoded prompts drift: they encode training-era assumptions, ship stale tool names, and lock in opinionated phrasing that doesn't match every environment. A contract specifies *what* must be produced and *what must be true about how it was produced* (evidence labeling, research freshness, advisor checkpoints), not *what words to use*.

## Shape of every subagent contract

Each file contains these sections:

1. **Identity** — id, one-line goal.
2. **Reads** — files and live sources the subagent must inspect.
3. **Researches** — topics that require live web research with retrieval dates. Training-only answers are rejected on these topics.
4. **Elicits** — questions the subagent may ask the user via interactive elicitation. Marked `blocking` or non-blocking.
5. **Produces** — exact contract patches + any doctrine/charter edits.
6. **Envelope** — fields the subagent must populate in its return envelope (schema: `schemas/subagent-envelope.schema.json`).
7. **Advisor checkpoints** — optional; applied if the environment exposes advisor capability.
8. **DAG position** — phase and dependencies.
9. **Failure handling** — what to do on research failure, user unavailable, schema mismatch.

## How the orchestrator uses subagents

Preferred mode: spawn each subagent as an isolated context. The orchestrator passes the subagent's contract + the current state of `.law/contracts/*` + any prior envelopes the subagent depends on (per DAG). The subagent returns one envelope. The orchestrator merges patches, reconciles conflicts, appends to `.law/context/current-system.json`.

Degraded mode: orchestrator runs phases sequentially in the main chat. Between phases it writes an envelope to `.law/context/research/` and clears that phase's raw research from its working set before starting the next phase. This is mandatory, not optional — the degraded mode trades parallelism for sequentiality but must not trade context discipline.

## Extensibility

A project may add its own subagent by dropping `<name>.contract.md` in this folder and declaring its DAG position. `INIT.md` discovers these on each run.
